import { createHash } from 'node:crypto';
import { GodfieldLeagueService } from './godfield-league.js';
import { GodfieldService } from './godfield.service.js';
import { godfieldConfig } from './godfield-source.js';
import { contentReceipt } from './content-receipt.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { audit } from '../admin/admin.audit.js';
import { highwayBetContract, highwayContributionContract, highwayBuffContract, highwayActionMaterials } from './godfield-highway-contract.js';
import { highwayInitialFleet, highwayLevelFromPower, highwayAttributes, highwayMileage } from './godfield-highway-race.js';
const mode = 'highway-play-v1', durations = { 1: 150, 2: 60, 3: 30, 4: 60, 5: 60 };
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
const whole = (v, min, max, label) => { if (!/^\d+$/.test(String(v)) || !Number.isSafeInteger(Number(v)) || Number(v) < min || Number(v) > max)
    fail(label + ' không hợp lệ.'); return Number(v); };
export const highwayPlayPolicy = { id: 'pool-v1', notice: 'MÔ PHỎNG LOCAL được người dùng duyệt: cược tiêu Chip thật trong kho LOCAL; hoàn vé theo quỹ vé/vé trên các tàu thắng đồng hạng. Buff lấy bậc highway_num theo chênh lệch trợ giúp/quấy rối, áp từ chặng kế tiếp. Không phải thuật toán server gốc.',
    payout: 'Chỉ hạng nhất đạt39700 mới hoàn vé qua Thư; chia quỹ theo số vé cược trên các tàu đồng hạng nhất, làm tròn xuống. Không đạt mốc: không hoàn. Không tạo vé hay phần thưởng ngoài quỹ. Tỷ lệ hiển thị là tạm tính, còn thay đổi trước khi đóng cược.',
    buffs: 'Cộng số đạo cụ theo nhóm; hiệu trợ giúp trừ quấy rối, lấy bậc thấp hơn/gần nhất trong highway_num và chặn ở bậc cuối nguồn. Không dùng moneyfix/levelfix. Mỗi lần bấm buff tiêu1đạo cụ; dưới ngưỡng chưa tăng chỉ số. Buff lúc nghỉ áp từ chặng kế; buff xung kích áp ở chặng kết toán cuối để không hồi tố.',
    levels: 'Tổng năng lượng chung góp riêng cho tàu trong vòng hiện tại. Chỉ góp lúc chuẩn bị, sau khi cược. Cấp2 nguồn vẫn75tốc độ như cấp1; cấp3/4/5 là85/100/125. Không tự tăng khác bảng.',
    blocked: 'Chưa mở ao thưởng vật phẩm, thành tựu, bảng xếp hạng tuần hoặc cửa hàng2: chưa có kết toán server gốc. Khoang/khe nứt chỉ sửa lợi tức của kho thưởng chưa mở, nên giữ khóa và không tiêu các đạo cụ này.' };
/** Một ledger/người/vũ trụ/vòng trong bảng mode_state hiện có. Đoàn tàu được
 * dựng chung từ các ledger, không tạo tài khoản giả hay trộn namespace QA cũ.
 * Mọi ghi/chi phí/kết toán nằm trong BEGIN IMMEDIATE hoặc contentReceipt. */
export class GodfieldHighwayPlay {
    db;
    now;
    economy;
    store;
    constructor(db, now, economy) {
        this.db = db;
        this.now = now;
        this.economy = economy;
        this.store = new GodfieldLeagueService(db, now);
    }
    enabled() { if (process.env.APP_ENV === 'online' || process.env.LOCAL_HIGHWAY_PLAY !== '1')
        fail('Cược/góp/buff chỉ mở ở bản chơi LOCAL đã duyệt; không chạy trên ONLINE.'); }
    check(id) { this.enabled(); new GodfieldService(this.db).assertUnlocked(id); }
    atomic(fn) { if (this.db.isTransaction)
        return fn(); this.db.exec('BEGIN IMMEDIATE'); try {
        const r = fn();
        this.db.exec('COMMIT');
        return r;
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    clock() {
        const now = this.now(), day = new Date(now + 7 * 3600000).toISOString().slice(0, 10), weekday = new Date(now + 7 * 3600000).getUTCDay() || 7, rows = godfieldConfig('highway_time'), open_area = rows[1].open_area[weekday - 1];
        const qa = this.db.prepare("SELECT starts_at,ends_at FROM local_activity_settings WHERE activity_id='highway-play' AND enabled=1").get();
        let round = 0, start = 0, rate = 1, virtualStart = 0, key = '', simulated = false;
        if (qa && now >= Number(qa.starts_at) && now < Number(qa.ends_at)) {
            start = Number(qa.starts_at);
            rate = 900000 / (Number(qa.ends_at) - start);
            if (![1, 6].includes(rate))
                fail('Đồng hồ đua QA không hợp lệ.');
            round = 1;
            virtualStart = Date.parse(day + 'T' + rows[1].ready_time + '+07:00') / 1000;
            key = 'qa:' + start;
            simulated = true;
        }
        else
            for (const [k, r] of Object.entries(rows)) {
                if (Number(k) % 2 === 0)
                    continue;
                const at = Date.parse(day + 'T' + r.ready_time + '+07:00');
                if (now >= at && now < at + 900000) {
                    round = Number(k);
                    start = at;
                    virtualStart = at / 1000;
                    key = day + ':' + round;
                    break;
                }
            }
        const c = this.stage({ key, area: 0, round, start, virtualStart, rate, day }, now);
        return { ...c, open_area, simulated, policy: highwayPlayPolicy };
    }
    stage(m, now) {
        let elapsed = Math.max(0, (now - m.start) * m.rate / 1000), offset = 0, sort = 0, step = 0, nav = 0, remaining = 0;
        if (m.round) {
            for (const phase of godfieldConfig('highway_time')[m.round].timelist) {
                if (phase === 2)
                    nav++;
                if (elapsed < durations[phase]) {
                    sort = phase;
                    step = phase === 1 ? 0 : phase === 2 ? nav : nav + 1;
                    remaining = (durations[phase] - elapsed) / m.rate;
                    break;
                }
                elapsed -= durations[phase];
                offset += durations[phase];
            }
            if (!sort) {
                sort = 6;
                step = 5;
                remaining = Math.max(0, (900 - (now - m.start) * m.rate / 1000) / m.rate);
                offset = 600;
            }
        }
        return { meta: m, round_id: m.round, sort, step, ts_start: m.virtualStart + offset, now: m.virtualStart + Math.max(0, (now - m.start) * m.rate / 1000), remaining, rate: m.rate, real_at: now / 1000 };
    }
    current(areaValue) { const area = whole(areaValue, 1, 6, 'Vũ trụ'), c = this.clock(); if (!c.round_id)
        fail('Ngoài giờ đua. Quản trị có thể mở riêng một vòng QA LOCAL.'); if (!c.open_area.includes(area))
        fail('Vũ trụ này ngoài lịch hôm nay.'); return { ...c, meta: { ...c.meta, area, key: c.meta.key + ':' + area } }; }
    rows(m) { return this.db.prepare('SELECT user_id,state FROM godfield_mode_state WHERE mode=? AND period=? ORDER BY user_id').all(mode, m.key).map(r => ({ id: Number(r.user_id), value: JSON.parse(String(r.state)) })); }
    own(id, m) { return this.rows(m).find(r => r.id === id)?.value; }
    put(id, v) { this.store.put(id, mode, v.meta.key, v); }
    tier(group, count) { const rows = godfieldConfig('highway_num')[group].bufffix; return Math.sign(count) * (rows.filter(r => r[0] <= Math.abs(count)).at(-1)?.[1] ?? 0); }
    fleet(m, now) {
        const all = this.rows(m), c = this.stage(m, now), pool = all.reduce((n, r) => n + r.value.bet.num, 0);
        const ships = highwayInitialFleet(m.area).map(s => {
            const own = all.filter(r => r.value.bet.ship_id === s.ship_id), tickets = own.reduce((n, r) => n + r.value.bet.num, 0), events = all.flatMap(r => r.value.actions).filter(a => a.ship === s.ship_id), power = events.reduce((n, a) => n + (a.energy ?? 0), 0), lv = highwayLevelFromPower(power).level, steps = {}, counts = {}, last = [0, 0, 0];
            for (let i = 1; i <= 5; i++) {
                const actions = events.filter(a => a.step === i), cnt = {};
                for (const a of actions)
                    if (a.sort)
                        cnt[a.sort] = (cnt[a.sort] ?? 0) + a.count;
                counts[i] = cnt;
                const cumulative = (sort) => events.filter(a => a.step <= i && !a.finalStage && a.sort === sort).reduce((n, a) => n + a.count, 0), next = [1, 2, 3].map(g => this.tier(g, cumulative(g) - cumulative(g + 3)));
                steps[i] = { speed_add1: next[0] - last[0], speed_add2: next[1] - last[1], ship_income_add: next[2] - last[2] };
                last.splice(0, 3, ...next);
            }
            const ship = { ...s, lv, power, steps, all: counts, pool, bet_num: tickets, bet_people: own.length, odds: tickets ? Math.floor(pool * 100 / tickets) : Math.floor((pool + 5) * 100 / 5) };
            // Mốc đến tính từ các chặng thật, không hồi tố buff vừa dùng vào quá khứ.
            let distance = 0, achieve_ts = 0;
            const segments = [[150, 1], [240, 2], [330, 3], [420, 4], [480, 5], [540, 5]], point = Number(godfieldConfig('highway_time')[m.round].point);
            for (const [at, step] of segments) {
                const a = highwayAttributes(ship, step).effective, speed = a.speed + a.extraSpeed;
                if (!achieve_ts && speed > 0 && distance + speed * 60 >= point)
                    achieve_ts = m.virtualStart + at + (point - distance) / speed;
                distance += speed * 60;
            }
            const finalAt = m.virtualStart + 540, arrivedBeforeFinal = achieve_ts && achieve_ts <= finalAt ? achieve_ts : 0;
            const atFinal = highwayMileage({ ...ship, achieve_ts: arrivedBeforeFinal }, { round_id: m.round, sort: 5, step: 5, ts_start: finalAt, now: finalAt });
            const completeSteps = structuredClone(steps), net = (g) => events.filter(a => a.sort === g).reduce((n, a) => n + a.count, 0);
            for (const [i, key] of ['speed_add1', 'speed_add2', 'ship_income_add'].entries())
                completeSteps[5][key] += this.tier(i + 1, net(i + 1) - net(i + 4)) - last[i];
            const fullShip = { ...ship, steps: completeSteps }, finalAttr = highwayAttributes(fullShip).effective, finalSpeed = finalAttr.speed + finalAttr.extraSpeed, finalDistance = atFinal + finalSpeed * 60;
            const effectiveShip = c.sort >= 5 ? fullShip : ship, achieved = achieve_ts && achieve_ts <= Math.min(c.now, finalAt) ? achieve_ts : finalSpeed > 0 && atFinal < point && c.now >= finalAt + (point - atFinal) / finalSpeed ? finalAt + (point - atFinal) / finalSpeed : 0;
            const mileage = c.sort === 6 ? finalDistance : c.sort === 5 ? atFinal + finalSpeed * Math.min(60, Math.max(0, c.now - finalAt)) : highwayMileage({ ...ship, achieve_ts: achieved }, { ...c, round_id: m.round });
            const attributes = highwayAttributes(effectiveShip, c.sort === 1 ? 0 : c.step);
            // Lua cjson decode(null) là userdata truthy. Clientv12 dùng `if m.cap`
            // rồi math.min(n,m.cap), nên pha không có trần PHẢI bỏ trường, không gửi null.
            return { ...effectiveShip, achieve_ts: achieved, mileage, attributes, finalDistance, local_motion: { real_at: c.real_at, rate: m.rate, remaining: c.remaining, moving: [2, 4, 5].includes(c.sort), ...([2, 4].includes(c.sort) ? { cap: point } : {}), speed: attributes.effective.speed + attributes.effective.extraSpeed } };
        });
        return { ships, pool, c };
    }
    settle() {
        this.atomic(() => {
            const pending = this.db.prepare("SELECT user_id,state FROM godfield_mode_state WHERE mode=? AND json_extract(state,'$.settled') IS NULL").all(mode), periods = new Map();
            for (const r of pending) {
                const v = JSON.parse(String(r.state));
                if (this.now() >= v.meta.start + 600000 / v.meta.rate)
                    periods.set(v.meta.key, v.meta);
            }
            for (const m of periods.values()) {
                const { ships, pool } = this.fleet(m, m.start + 600000 / m.rate), max = Math.max(...ships.map(s => s.finalDistance)), winners = max >= godfieldConfig('highway_time')[m.round].point ? ships.filter(s => s.finalDistance === max).map(s => s.ship_id) : [], rows = this.rows(m), winnerTickets = rows.filter(r => winners.includes(r.value.bet.ship_id)).reduce((n, r) => n + r.value.bet.num, 0);
                for (const { id, value: v } of rows) {
                    if (v.settled)
                        continue;
                    const tickets = winnerTickets && winners.includes(v.bet.ship_id) ? Number(BigInt(v.bet.num) * BigInt(pool) / BigInt(winnerTickets)) : 0, mailId = 'highway-refund-' + createHash('sha256').update(m.key + ':' + id).digest('hex');
                    if (tickets > 0)
                        this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(id, mailId, 'Hoàn vé đua Tháp · MÔ PHỎNG LOCAL\n' + highwayPlayPolicy.payout + '\nVũ trụ' + m.area + ' · tàu' + v.bet.ship_id + ' · hoàn' + tickets + 'vé. Nhận thư để đưa vào túi.', JSON.stringify([[6, 9101353, tickets]]));
                    v.settled = { winners, pool, winnerTickets, returned: tickets, mailId: tickets ? mailId : null, distance: ships[v.bet.ship_id - 1].finalDistance, at: this.now() };
                    this.put(id, v);
                    audit(this.db, null, 'highway.play.settle', id, 'LOCAL: kết toán quỹ vé, không tạo thưởng ngoài quỹ', null, { period: m.key, ...v.settled });
                }
            }
        });
    }
    bets(id) { const out = {}, current = this.clock(); for (const row of this.db.prepare("SELECT state FROM godfield_mode_state WHERE user_id=? AND mode=? ORDER BY json_extract(state,'$.meta.start')").all(id, mode)) {
        const v = JSON.parse(String(row.state));
        if (v.meta.day !== current.meta.day)
            continue;
        out[v.meta.round] ??= {};
        out[v.meta.round][v.meta.area] = { ...v.bet, round_id: v.meta.round, can_reward: v.settled ? (v.settled.returned > 0 ? 1 : 2) : 0, returned: v.settled?.returned ?? 0 };
    } return out; }
    area(id, areaValue) {
        this.check(id);
        this.settle();
        const area = whole(areaValue, 1, 6, 'Vũ trụ');
        if (!this.clock().round_id)
            return { ...this.index(id), data: highwayInitialFleet(area).map(s => ({ ...s, all: {}, finalDistance: 0, attributes: highwayAttributes(s) })), add_buff_recard: {}, pool: 0 };
        const c = this.current(area), { ships, pool } = this.fleet(c.meta, this.now()), own = this.own(id, c.meta), record = {};
        for (const a of own?.actions ?? []) {
            record[a.ship] ??= {};
            const k = a.energy ? '10' : String(a.sort);
            record[a.ship][k] = (record[a.ship][k] ?? 0) + (a.energy ?? a.count ?? 0);
        }
        return { ...c, round_key: c.meta.key.slice(0, -2), data: ships, power: this.economy.power(id), betting: this.bets(id), add_buff_recard: record, gift_box: {}, pool, local_play: 'pool-v1', qa_only: false, qa_clock: { real_at: c.real_at, virtual_at: c.now, rate: c.rate, remaining: c.remaining }, policy: highwayPlayPolicy };
    }
    index(id) { this.check(id); this.settle(); const c = this.clock(), ship_data = {}; if (c.round_id)
        for (const a of c.open_area)
            ship_data[a] = this.fleet({ ...c.meta, area: a, key: c.meta.key + ':' + a }, this.now()).ships; return { ...c, round_key: c.meta.key, ship_data, betting: this.bets(id), power: this.economy.power(id), tasks: {}, gift_box: {}, local_play: 'pool-v1', qa_clock: { real_at: c.real_at, virtual_at: c.now, rate: c.rate, remaining: c.remaining }, policy: highwayPlayPolicy }; }
    execute(s, method, p, body, run) { this.check(s.user_id); return contentReceipt(this.db, s.user_id, method, p.get('request_id'), body, () => { const r = run(); audit(this.db, null, method, s.user_id, 'LOCAL pool-v1: giao dịch theo quy tắc đã duyệt', null, body); return { ...r, _client_cache_update: this.economy.cache(s.user_id) }; }, old => ({ ...old, replayed: true, reward: [], _client_cache_update: this.economy.cache(s.user_id) })); }
    bet(s, p) {
        const body = { area: p.get('area_id'), ship: p.get('ship_id'), num: p.get('num'), roundKey: p.get('round_key') };
        return this.execute(s, 'highway.betting', p, body, () => {
            const c = this.current(body.area), b = highwayBetContract(c.round_id, body.area, body.ship, body.num);
            if (c.sort !== 1)
                fail('Đã đóng cược; chỉ cược khi chuẩn bị.');
            if (body.roundKey + ':' + c.meta.area !== c.meta.key)
                fail('Vòng đã đổi; mở lại danh sách trước khi cược.');
            if (this.own(s.user_id, c.meta))
                fail('Mỗi người chỉ cược một tàu/vũ trụ/vòng.');
            new ProgressionEconomyService(this.db).cost(s, b.cost);
            this.put(s.user_id, { meta: c.meta, bet: { ship_id: b.ship, num: b.tickets, lv: 1, odds: 0 }, actions: [] });
            return this.index(s.user_id);
        });
    }
    contribute(s, p) {
        const body = { area: p.get('area_id'), num: p.get('num'), roundKey: p.get('round_key') };
        return this.execute(s, 'highway.add_power', p, body, () => {
            const c = this.current(body.area), a = highwayContributionContract(body.num), v = this.own(s.user_id, c.meta);
            if (c.sort !== 1 || body.roundKey + ':' + c.meta.area !== c.meta.key)
                fail('Chỉ góp trong chuẩn bị của vòng đang xem.');
            if (!v)
                return fail('Hãy cược một tàu trước khi góp.');
            if (this.economy.power(s.user_id) < a.energy)
                fail('Không đủ năng lượng Tháp; chưa trừ đồ.');
            if (a.cargo)
                fail('Khoang lợi tức còn chờ công thức kho thưởng; chưa tiêu vật liệu hoặc năng lượng.');
            const total = this.fleet(c.meta, this.now()).ships[v.bet.ship_id - 1].power;
            if (!Number.isSafeInteger(total + a.energy))
                fail('Tổng năng lượng vượt giới hạn.');
            new ProgressionEconomyService(this.db).cost(s, a.cost.filter(r => r[0] !== 111));
            this.economy.setPower(s.user_id, this.economy.power(s.user_id) - a.energy);
            if (a.energy)
                v.actions.push({ ship: v.bet.ship_id, step: 1, energy: a.energy });
            for (const [i, n] of [a.aether, a.accelerator, a.cargo].entries())
                if (n)
                    v.actions.push({ ship: v.bet.ship_id, step: 1, sort: i + 1, count: n });
            this.put(s.user_id, v);
            return this.area(s.user_id, body.area);
        });
    }
    buff(s, p) {
        const body = { area: p.get('area_id'), ship: p.get('ship_id'), sort: p.get('sort'), roundKey: p.get('round_key') };
        return this.execute(s, 'highway.add_buff', p, body, () => {
            const c = this.current(body.area), v = this.own(s.user_id, c.meta), b = highwayBuffContract(body.sort, body.ship, v?.bet.ship_id ?? null);
            if (body.roundKey + ':' + c.meta.area !== c.meta.key || ![3, 4].includes(c.sort))
                fail('Chỉ trợ giúp/quấy rối lúc nghỉ giữa chặng hoặc xung kích hợp lệ.');
            const ship = this.fleet(c.meta, this.now()).ships[b.ship - 1];
            if (c.sort === 4 && ship.mileage < godfieldConfig('highway_time')[c.round_id].point)
                fail('Tàu chưa tới mốc cho thao tác xung kích.');
            if (b.group === 3)
                fail('Khoang/khe nứt tác động kho thưởng còn thiếu công thức; chưa tiêu đạo cụ.');
            new ProgressionEconomyService(this.db).cost(s, b.cost);
            v.actions.push({ ship: b.ship, step: c.step, sort: b.sort, count: 1, finalStage: c.sort === 4 });
            this.put(s.user_id, v);
            return this.area(s.user_id, body.area);
        });
    }
    startQa(adminId, id, key, rateValue) {
        this.check(id);
        const rate = whole(rateValue, 1, 6, 'Tốc độ QA');
        if (![1, 6].includes(rate))
            fail('QA chỉ hỗ trợ1× hoặc6×.');
        return contentReceipt(this.db, id, 'admin.highway.play_round', key, { rate }, () => {
            const old = this.db.prepare("SELECT * FROM local_activity_settings WHERE activity_id='highway-play'").get();
            if (old && this.now() < Number(old.ends_at))
                fail('Vòng QA trước chưa kết thúc; không cắt ngang cược đang có.');
            const c = this.clock();
            if (c.round_id)
                fail('Đang có vòng theo lịch nguồn; không ghi đè vòng đang hoạt động.');
            this.settle();
            const at = this.now();
            this.db.prepare("INSERT INTO local_activity_settings VALUES('highway-play',1,?,?) ON CONFLICT(activity_id) DO UPDATE SET enabled=1,starts_at=excluded.starts_at,ends_at=excluded.ends_at").run(at, at + 900000 / rate);
            audit(this.db, adminId, 'highway.play.qa_round', id, 'LOCAL: mở một vòng có tiêu đồ thật, không cấp tài nguyên; không đổi giờ toàn game', old, { startsAt: at, rate });
            return this.clock();
        }, old => ({ ...old, replayed: true }));
    }
    prepareResources(adminId, id, key) {
        this.check(id);
        return contentReceipt(this.db, id, 'admin.highway.play_resources', key, { preset: 'level5-tools-v1' }, () => {
            const before = this.economy.power(id), energy = 140580, after = before + energy;
            if (!Number.isSafeInteger(after))
                fail('Ví năng lượng vượt giới hạn.');
            const mailId = 'highway-qa-materials-' + createHash('sha256').update(id + ':' + key).digest('hex'), tuples = [[6, 9101353, 50], ...highwayActionMaterials.flatMap((cid, i) => i % 3 === 2 ? [] : [[6, cid, i % 3 === 0 ? 15 : 12]])];
            this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(id, mailId, 'Vật liệu QA đua Tháp LOCAL\nQuản trị chủ động chuẩn bị để kiểm cược/góp/buff. Không phải thưởng đua hoặc bù giao dịch cũ.', JSON.stringify(tuples));
            this.economy.setPower(id, after);
            const r = { before, after, added: energy, mailId, tuples };
            audit(this.db, adminId, 'highway.play.qa_resources', id, 'LOCAL QA: cộng140580năng lượng và gửi vật liệu nguồn qua Thư; không đặt cược hộ', null, r);
            return r;
        }, old => ({ ...old, replayed: true }));
    }
    diagnostics(id) { this.check(id); return { clock: this.clock(), policy: highwayPlayPolicy, history: this.db.prepare('SELECT period,state FROM godfield_mode_state WHERE user_id=? AND mode=? ORDER BY updated_at DESC LIMIT 30').all(id, mode).map(r => ({ period: r.period, ...JSON.parse(String(r.state)) })), areas: this.clock().round_id ? this.clock().open_area.map(a => this.area(id, a)) : [] }; }
}
