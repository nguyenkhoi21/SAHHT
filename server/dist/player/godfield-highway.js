import { GodfieldService } from './godfield.service.js';
import { GodfieldLeagueService } from './godfield-league.js';
import { godfieldConfig } from './godfield-source.js';
import { readConfigSync } from './local-content.js';
import { contentReceipt } from './content-receipt.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { audit } from '../admin/admin.audit.js';
import { GodfieldHighwayPlay } from './godfield-highway-play.js';
import { verifyHighwayHelperSource, highwayInitialFleet, highwayShipLevels, highwayQaRace, highwayContributionPreview, highwayAttributes, highwayMileage } from './godfield-highway-race.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
const int = (v, min, max, label) => { if (!/^\d+$/.test(String(v)) || !Number.isSafeInteger(Number(v)) || Number(v) < min || Number(v) > max)
    fail(label + ' không hợp lệ.'); return Number(v); };
export const highwayBlockers = [
    'LOCAL đã được người dùng duyệt: chuyển đổi liệt kê nguyên liệu đang sở hữu thuộc pool nguồn, không mô phỏng thuật toán chọn ô ngẫu nhiên của server gốc.',
    'Cửa hàng1/3 hiển thị đủ8dòng cố định trong mỗi bảng nguồn. Giới hạn mua lưu tích lũy; chưa tự reset/làm mới vì thiếu lịch chính xác. Cửa hàng2 cần thuật toán chọn hàng, giữ khóa.',
    '8 tàu/vũ trụ cùng cấp1 theo xác nhận người dùng. Lõi hành trình đối chiếu Lua; bản xem trước Admin không phải cuộc đua đang hoạt động. Chọn biến động tốc độ/đặt cược/trợ giúp/quấy rối/phát thưởng/thành tựu/xếp hạng chưa mở.',
    'Năng lượng lưu riêng, không tự reset ví qua ngày. Trần chuyển đổi theo ngày+07 đã xác minh từ highway_txt1; múi giờ server gốc chưa ghi trong nguồn.',
];
export class GodfieldHighwayService {
    db;
    now;
    store;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
        this.store = new GodfieldLeagueService(db, now);
    }
    play() { return new GodfieldHighwayPlay(this.db, this.now, { power: id => this.power(id), setPower: (id, n) => this.setPower(id, n), cache: id => this.cache(id) }); }
    check(id) { new GodfieldService(this.db).assertUnlocked(id); }
    wallet(id) { return this.store.state(id, 'highway-energy', 'permanent', { power: 0 }); }
    power(id) { const n = this.wallet(id).power; if (!Number.isSafeInteger(n) || n < 0)
        fail('Ví năng lượng không hợp lệ; chưa thay dữ liệu.'); return n; }
    setPower(id, power) { if (!Number.isSafeInteger(power) || power < 0)
        fail('Năng lượng vượt giới hạn số an toàn.'); this.store.put(id, 'highway-energy', 'permanent', { power }); }
    cache(id) { return { item: { items: { update: Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(id).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: [] } } }; }
    execute(s, method, p, body, fn) { this.check(s.user_id); return contentReceipt(this.db, s.user_id, method, p.get('request_id'), body, () => { const result = fn(); audit(this.db, null, method, s.user_id, 'Tháp Hoang Tinh Tế LOCAL: economy nguồn, không đặt cược hoặc sửa đội', null, { ...body, power: this.power(s.user_id) }); return result; }, old => ({ ...old, ...(method === 'highway.buy' ? this.shop(s.user_id, body.sort) : this.conversion(s.user_id)), power: this.power(s.user_id), reward: [], _client_cache_update: this.cache(s.user_id), replayed: true })); }
    clock() {
        verifyHighwayHelperSource();
        const c = this.store.clock(), rows = godfieldConfig('highway_time'), sec = (v) => v.split(':').map(Number).reduce((n, x, i) => n + x * [3600, 60, 1][i], 0), time = new Date(c.now + 7 * 3600000), second = time.getUTCHours() * 3600 + time.getUTCMinutes() * 60 + time.getUTCSeconds();
        const range = Object.entries(rows).find(([, r]) => second >= sec(r.ready_time) && second <= sec(r.end_time));
        // sortTime/timelist từ game_god_escort_helper:150s chuẩn bị,60s bay,
        //30s nghỉ xen kẽ,60s xung kích,60s kết toán. Đây là lịch hiển thị, không mở đua.
        let round_id = 0, sort = 0, step = 0, ts_start = 0;
        if (range) {
            round_id = Number(range[0]);
            const r = range[1];
            ts_start = Math.floor(c.now / 1000) - second + sec(r.ready_time);
            if (r.timelist[0] === 6)
                sort = 6;
            else {
                let elapsed = second - sec(r.ready_time), navigation = 0;
                for (const stage of r.timelist) {
                    if (stage === 2)
                        navigation++;
                    const duration = { 1: 150, 2: 60, 3: 30, 4: 60, 5: 60 }[stage];
                    if (!duration)
                        fail('Thiếu thời lượng giai đoạn nguồn.');
                    if (elapsed < duration) {
                        sort = stage;
                        step = stage === 1 ? 0 : stage === 2 ? navigation : navigation + 1;
                        break;
                    }
                    elapsed -= duration;
                    ts_start += duration;
                }
                if (!sort) {
                    sort = 5;
                    step = navigation + 1;
                    ts_start -= 60;
                }
            }
        }
        const weekday = time.getUTCDay() || 7, open_area = rows['1'].open_area[weekday - 1];
        return { now: c.now, day: c.day, week: c.week, timezone: c.timezone, round_id, sort, step, ts_start, open_area, racingEnabled: false, sourceSchedule: rows };
    }
    fleetPreparation() { const c = this.clock(); return { status: 'PREVIEW_ONLY', evidence: '8 tàu/vũ trụ cùng cấp1: người dùng xác nhận29/10/2026. Tên/cấp/tốc độ/tỷ lệ lấy bảng Việt Nam; chưa có cược hoặc cuộc đua thật.', levelRule: 'Ngưỡng tổng năng lượng mọi người đã góp vào tàu, theo người dùng xác nhận29/10/2026. Không trả lại giá mỗi cấp. Công cụ xem thử không trừ ví hoặc sửa tàu trong game.', levels: highwayShipLevels(), areas: Array.from({ length: 6 }, (_, i) => ({ area: i + 1, scheduled: c.open_area.includes(i + 1), ships: highwayInitialFleet(i + 1) })) }; }
    levelPreview(id, total, added) {
        this.check(id);
        if (process.env.APP_ENV === 'online')
            fail('Xem thử góp năng lượng chỉ dùng LOCAL.');
        const previous = int(total, 0, Number.MAX_SAFE_INTEGER, 'Tổng đã góp'), increment = int(added, 0, Number.MAX_SAFE_INTEGER, 'Góp thêm');
        if (!Number.isSafeInteger(previous + increment))
            fail('Tổng năng lượng vượt giới hạn số an toàn.');
        const contribution = highwayContributionPreview(previous, increment), inspect = (level) => { const ship = { ship_id: 1, lv: level, steps: {} }; return { attributes: highwayAttributes(ship), firstLegMileage: highwayMileage(ship, { round_id: 1, sort: 2, step: 1, ts_start: 1000, now: 1060 }) }; };
        return { qa_only: true, persisted: false, charged: 0, reward: [], contribution, before: inspect(contribution.before.level), after: inspect(contribution.after.level), notice: 'Xem thử quy tắc tổng năng lượng; không góp thật, không sửa ví/tàu hoặc tạo thưởng. Chặng đối chiếu60giây gốc, chưa thêm biến động.' };
    }
    qaPeriod(area, now) { return new Date(now + 7 * 3600000).toISOString().slice(0, 10) + ':' + area; }
    qaSharedPower(area, now) {
        const totals = Array(8).fill(0);
        for (const row of this.db.prepare("SELECT state FROM godfield_mode_state WHERE mode='highway-qa-contribution' AND period=?").all(this.qaPeriod(area, now))) {
            const powers = JSON.parse(String(row.state)).power;
            if (!Array.isArray(powers) || powers.length !== 8)
                fail('Dữ liệu đoàn tàu QA không hợp lệ; chưa thay dữ liệu.');
            for (let i = 0; i < 8; i++)
                totals[i] = int(totals[i] + int(powers[i], 0, Number.MAX_SAFE_INTEGER, 'Tổng góp QA'), 0, Number.MAX_SAFE_INTEGER, 'Tổng góp chung QA');
        }
        return totals;
    }
    qaFleet() {
        if (process.env.APP_ENV === 'online')
            fail('Đoàn tàu QA chỉ dùng LOCAL.');
        const now = this.now(), weekday = new Date(now + 7 * 3600000).getUTCDay() || 7, areas = godfieldConfig('highway_time')['1'].open_area[weekday - 1];
        return { day: new Date(now + 7 * 3600000).toISOString().slice(0, 10), notice: 'Năng lượng MÔ PHỎNG riêng theo ngày LOCAL, chung giữa các tài khoản. Áp lại toàn bộ hành trình QA theo cấp mới; không phải lịch sử góp trong cuộc đua thật. Không trừ ví, dùng đồ hoặc phát thưởng.', areas: areas.map(area => ({ area, ships: highwayQaRace(now, area, this.qaSharedPower(area, now)).data })) };
    }
    prepareQaContribution(adminId, id, key, areaValue, shipValue, amountValue) {
        this.check(id);
        if (process.env.APP_ENV === 'online')
            fail('Không góp năng lượng mô phỏng trên ONLINE.');
        const area = int(areaValue, 1, 6, 'Vũ trụ'), ship = int(shipValue, 1, 8, 'Tàu'), amount = int(amountValue, 1, 140580, 'Năng lượng mô phỏng góp thêm');
        return contentReceipt(this.db, id, 'admin.highway.qa_contribute', key, { area, ship, amount }, () => {
            const now = this.now(), weekday = new Date(now + 7 * 3600000).getUTCDay() || 7;
            if (!godfieldConfig('highway_time')['1'].open_area[weekday - 1].includes(area))
                fail('Vũ trụ này ngoài lịch hôm nay.');
            const period = this.qaPeriod(area, now), totals = this.qaSharedPower(area, now), before = totals[ship - 1], own = this.store.state(id, 'highway-qa-contribution', period, { power: Array(8).fill(0) });
            if (!Array.isArray(own.power) || own.power.length !== 8)
                fail('Dữ liệu góp QA không hợp lệ.');
            if (!Number.isSafeInteger(before + amount) || !Number.isSafeInteger(own.power[ship - 1] + amount))
                fail('Tổng góp QA vượt giới hạn số an toàn.');
            own.power[ship - 1] += amount;
            this.store.put(id, 'highway-qa-contribution', period, own);
            const result = { qa_only: true, charged: 0, reward: [], replayed: false, period, area, ship, amount, ...highwayContributionPreview(before, amount) };
            audit(this.db, adminId, 'highway.qa_contribute', id, 'LOCAL: cộng năng lượng mô phỏng cho tàu QA; không trừ ví/đồ hoặc phát thưởng', { area, ship, total: before }, result);
            return result;
        }, old => ({ ...old, replayed: true }));
    }
    qaArea(id, value) { this.check(id); if (process.env.APP_ENV === 'online')
        fail('Đua mô phỏng chỉ dùng LOCAL.'); const area = int(value, 1, 6, 'Vũ trụ'), now = this.now(), weekday = new Date(now + 7 * 3600000).getUTCDay() || 7; if (!godfieldConfig('highway_time')['1'].open_area[weekday - 1].includes(area))
        fail('Vũ trụ này ngoài lịch hôm nay.'); return highwayQaRace(now, area, this.qaSharedPower(area, now)); }
    qaAllAreas(id) { this.check(id); if (process.env.APP_ENV === 'online')
        fail('Đua mô phỏng chỉ dùng LOCAL.'); return highwayQaRace(this.now(), 1); }
    index(id) { this.check(id); const c = this.clock(); return { round_id: c.round_id, sort: c.sort, step: c.step, power: this.power(id), ship_data: {}, betting: {}, tasks: {}, gift_box: {}, source_blockers: highwayBlockers }; }
    conversion(id) { this.check(id); const goods = {}, items = readConfigSync('item'), own = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=? AND quantity>0 ORDER BY config_id').all(id), pools = godfieldConfig('highway_trans'); for (const [tier, r] of Object.entries(pools)) {
        const pool = new Set(r.lack);
        for (const item of own) {
            const cid = Number(item.config_id);
            if (pool.has(cid) && items[cid])
                goods[cid * 10 + Number(tier)] = { item_id: cid, num: Number(item.quantity), c_id: Number(tier) };
        }
    } return { goods, power: this.power(id), trans_log: this.store.state(id, 'highway-conversion', this.clock().day, {}), refresh_times: 0, local_approximation: highwayBlockers[0] }; }
    convert(s, p) {
        const pos = int(p.get('pos_id'), 1, Number.MAX_SAFE_INTEGER, 'Ô nguyên liệu'), count = int(p.get('cost_num'), 1, 9999, 'Số lượng');
        return this.execute(s, 'highway.trans', p, { pos, count }, () => {
            const tier = pos % 10, cid = (pos - tier) / 10, r = godfieldConfig('highway_trans')[tier];
            if (!r || !r.lack.includes(cid) || !readConfigSync('item')[cid])
                fail('Nguyên liệu không thuộc danh sách nguồn; chưa tiêu.');
            const c = this.clock(), log = this.store.state(s.user_id, 'highway-conversion', c.day, {}), gain = Number(r.score) * count, used = Number(log[tier] ?? 0);
            if (!Number.isSafeInteger(gain) || gain <= 0 || used + gain > r.limit)
                fail('Vượt trần năng lượng chuyển đổi trong ngày của nhóm này.');
            new ProgressionEconomyService(this.db).cost(s, [[6, cid, count]]);
            this.setPower(s.user_id, this.power(s.user_id) + gain);
            log[tier] = used + gain;
            this.store.put(s.user_id, 'highway-conversion', c.day, log);
            return { ...this.conversion(s.user_id), gained: gain, reward: [], _client_cache_update: this.cache(s.user_id) };
        });
    }
    sort(value) { const sort = int(value, 1, 3, 'Cửa hàng'); if (sort === 2)
        fail('Cửa hàng Chip cược chưa có quy tắc chọn hàng gốc; chưa mở mua/làm mới.'); return sort; }
    rows(sort) { return Object.entries(godfieldConfig('highway_shop')).filter(([, r]) => r.sort === sort).sort(([a], [b]) => Number(a) - Number(b)); }
    serverBought(key) { return Number(this.db.prepare("SELECT COALESCE(SUM(CAST(json_extract(result,'$.purchased') AS INTEGER)),0) n FROM player_content_operations WHERE method='highway.buy' AND json_extract(result,'$.goods_id')=?").get(Number(key)).n); }
    shop(id, value) { this.check(id); const sort = this.sort(value), rows = this.rows(sort), buy_log = this.store.state(id, 'highway-shop', 'permanent', {}), server_buy_log = {}; for (const [key, r] of rows)
        if (r.type === 1)
            server_buy_log[key] = this.serverBought(key); return { shop_goods: rows.map(([key]) => Number(key)), buy_log, server_buy_log, refresh_times: 0, power: this.power(id), source_blockers: highwayBlockers }; }
    buy(s, p) {
        const sort = this.sort(p.get('sort')), goods = int(p.get('goods_id'), 1, 100000, 'Mặt hàng'), quantity = int(p.get('num') ?? '1', 1, 99, 'Số lượng');
        return this.execute(s, 'highway.buy', p, { sort, goods, quantity }, () => {
            const row = godfieldConfig('highway_shop')[goods];
            if (!row || row.sort !== sort)
                fail('Mặt hàng không thuộc cửa hàng đã chọn.');
            const log = this.store.state(s.user_id, 'highway-shop', 'permanent', {}), bought = row.type === 1 ? this.serverBought(String(goods)) : Number(log[goods] ?? 0);
            if (![1, 2].includes(row.type) || !Number.isSafeInteger(row.limit) || row.limit < 1)
                fail('Thiếu quy tắc giới hạn mua nguồn.');
            if (bought + quantity > row.limit)
                fail(row.type === 1 ? 'Đã hết lượt mua toàn server.' : 'Đã hết lượt mua cá nhân.');
            const costs = row.price.map(([type, cid, n]) => [type, cid, n * quantity]), energy = costs.filter(r => r[0] === 111).reduce((n, r) => n + r[2], 0);
            if (costs.some(r => !Number.isSafeInteger(r[2]) || r[2] < 0) || energy > this.power(s.user_id))
                fail('Không đủ năng lượng hoặc giá nguồn không hợp lệ.');
            for (const [type, cid] of costs)
                if (type === 111 && cid !== 0)
                    fail('Loại năng lượng không hợp lệ.');
            new ProgressionEconomyService(this.db).cost(s, costs.filter(r => r[0] !== 111));
            this.setPower(s.user_id, this.power(s.user_id) - energy);
            const rewards = grantGodfieldReward(this.db, s, row.reward.map(([type, cid, n]) => [type, cid, n * quantity]));
            log[goods] = Number(log[goods] ?? 0) + quantity;
            this.store.put(s.user_id, 'highway-shop', 'permanent', log);
            const result = this.shop(s.user_id, sort);
            if (row.type === 1)
                result.server_buy_log[goods] = bought + quantity;
            return { ...result, ...rewards, goods_id: goods, purchased: quantity };
        });
    }
    blocked() { return fail('Phần đua/đặt cược/làm mới này chưa đủ thuật toán nguồn; không tiêu tài nguyên hoặc giả kết quả.'); }
    diagnostics(id, qaAllowed = true) { this.check(id); const items = readConfigSync('item'); return { clock: this.clock(), power: this.power(id), fleetPreparation: this.fleetPreparation(), qaFleet: qaAllowed && process.env.APP_ENV !== 'online' ? this.qaFleet() : undefined, conversion: this.conversion(id), limits: Object.entries(godfieldConfig('highway_trans')).map(([tier, r]) => ({ tier: Number(tier), score: r.score, limit: r.limit, sourcePool: r.lack.length })), catalog: Object.entries(godfieldConfig('highway_shop')).map(([key, r]) => ({ id: Number(key), sort: r.sort, price: r.price, limit: r.limit, scope: r.type === 1 ? 'Toàn server' : 'Cá nhân', supported: [1, 3].includes(r.sort), reward: r.reward.map(([type, cid, n]) => ({ type, configId: cid, quantity: n, name: type === 6 ? items[cid]?.name : 'Năng lượng', icon: type === 6 ? items[cid]?.icon : null })) })), shops: { 1: this.shop(id, 1), 3: this.shop(id, 3) }, history: this.db.prepare("SELECT method,created_at,result FROM player_content_operations WHERE user_id=? AND method IN('highway.trans','highway.buy') ORDER BY created_at DESC LIMIT 30").all(id).map(r => ({ method: r.method, created_at: r.created_at, result: JSON.parse(String(r.result)) })), blockers: highwayBlockers }; }
}
