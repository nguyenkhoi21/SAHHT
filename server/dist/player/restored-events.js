import { randomInt, createHash } from 'node:crypto';
import { RestoredEventSettlement } from './restored-event-settlement.js';
import { EventPlanner, eventDay, eventFail as fail } from './event-planner.js';
import { restoredKinds, restoredDefault, restoredSource } from './restored-event-source.js';
import { rewardProblem } from './hot-campaigns.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { WelfareService } from './welfare.service.js';
import { readConfigSync } from './local-content.js';
import { audit } from '../admin/admin.audit.js';
import { beginHotSpend, endHotSpend } from './hot-spending.js';
const int = (v, min = 0, max = 100000000) => Number.isSafeInteger(v) && v >= min && v <= max;
export const investmentFreeTurns = (vip) => Math.min(7, 3 + Math.max(0, Math.floor(vip) - 2));
export const investmentRechargeVnd = 100000;
export class RestoredEvents {
    db;
    now;
    rng;
    constructor(db, now = Date.now, rng = randomInt) {
        this.db = db;
        this.now = now;
        this.rng = rng;
    }
    configs() { return this.db.prepare('SELECT * FROM restored_event_configs ORDER BY id DESC').all().map(r => ({ ...r, definition: JSON.parse(String(r.definition)) })); }
    problems(c) {
        const errors = [], check = (x, msg) => { if (!x)
            errors.push(msg); }, reward = (r, label) => { const p = rewardProblem(r); if (p)
            errors.push(label + ': ' + p); };
        try {
            if (!c || !Object.hasOwn(restoredKinds, c.kind))
                return ['Loại sự kiện không hợp lệ.'];
            check(typeof c.name === 'string' && c.name.trim() && c.name.length <= 80, 'Tên cần1–80ký tự.');
            check(c.policy === 'LOCAL_CONFIGURED', 'Cần xác nhận cấu hình LOCAL.');
            check(int(c.sourceVersion, 1) && !!restoredSource(c.kind === 'investment' ? 'gringotts' : 'chuzheng_version')[c.sourceVersion], 'Phiên bản nguồn không hợp lệ.');
            check(typeof c.notice === 'string' && c.notice.length <= 20000, 'Nội dung tối đa20.000ký tự.');
            if (c.kind === 'investment') {
                check([c.rule.time1, c.rule.time2, c.rule.time3].join(',') === '3,6,9', 'Giữ kỳ hạn nguồn3/6/9giờ.');
                check(int(c.rule.max_coin, 1), 'Mốc đầu tư toàn server phải dương.');
                check(int(c.rule.quickly_point, 0, 100), 'Phí gia tốc0–100%.');
                check(Array.isArray(c.rule.refresh_coin) && c.rule.refresh_coin.length > 0 && c.rule.refresh_coin.length <= 30 && c.rule.refresh_coin.every((v) => int(v)), 'Giá tạo mới không hợp lệ.');
                reward(c.rule.charge_reward, 'Quà toàn server');
                check(c.rule.charge_reward.length <= 3, 'Quà toàn server tối đa3ô như bảng runtime Việt.');
                for (const k of ['coin_point1', 'coin_point2', 'coin_point3'])
                    check(Array.isArray(c.rule[k]) && c.rule[k].length === 2 && c.rule[k].every((v) => int(v, 0, 1000)) && c.rule[k][0] <= c.rule[k][1], 'Khoảng hệ số kỳ hạn chưa hợp lệ.');
                check(int(c.upWeight, 0, 1000000) && int(c.downWeight, 0, 1000000) && c.upWeight + c.downWeight > 0, 'Tỷ trọng lên/xuống phải có tổng dương.');
                check(Array.isArray(c.rates) && c.rates.length === 9, 'Cần9bậc đầu tư nguồn.');
                for (const r of c.rates)
                    for (const k of ['coin_up', 'coin_down', 'refresh_rate_up', 'refresh_rate_down'])
                        check(Array.isArray(r[k]) && r[k].length > 0 && r[k].length <= 20 && r[k].some((v) => v[2] > 0) && r[k].every((v) => Array.isArray(v) && v.length === 3 && int(v[0]) && int(v[1], v[0]) && int(v[2], 0, 1000000)), 'Khoảng/tỷ trọng bậc đầu tư không hợp lệ.');
                for (let v = 0; v <= 15; v++)
                    check(c.vip[String(v)]?.free_times === investmentFreeTurns(v) && int(c.vip[String(v)]?.charge_coin, 1), 'Lượt miễn phí phải đúng VIP0–2:3, VIP3:4, VIP4:5, VIP5:6, VIP6+:7.');
            }
            else {
                check(c.duration === 7200, 'Giữ thời gian nguồn2giờ.');
                check(int(c.freeDaily, 0, 1000), 'Lượt miễn phí0–1000/ngày.');
                check(Array.isArray(c.tierWeights) && c.tierWeights.length === 3 && c.tierWeights.every((n) => int(n, 0, 1000000)) && c.tierWeights.some((n) => n > 0), 'Tỷ trọng S/SS/SSS không hợp lệ.');
                check(Array.isArray(c.rule.task) && c.rule.task.length === 3 && new Set(c.rule.task).size === 3, 'Chọn đúng3loại nhiệm vụ khác nhau.');
                check(c.rule.pass === 92854 && int(c.rule.need, 1), 'Vé nguồn #92854 và mốc nạp phải hợp lệ.');
                for (const tier of ['s', 'ss', 'sss'])
                    check(int(c.rule['score_' + tier], 1, 100000), 'Điểm nhiệm vụ phải dương.');
                for (const id of c.rule.task) {
                    const t = c.tasks[id], original = restoredSource('chuzheng_task')[id];
                    check(!!original && typeof t?.name === 'string' && t.name.length <= 80, 'Nhiệm vụ phải có trong nguồn.');
                    check(JSON.stringify(t.card) === JSON.stringify(original.card), 'Giữ danh sách tướng nguồn của nhiệm vụ.');
                    for (const tier of ['s', 'ss', 'sss']) {
                        check(t['break_' + tier] === original['break_' + tier] && t['evolution_' + tier] === original['evolution_' + tier], 'Giữ yêu cầu Chuyển Thế/Siêu Tiến Hóa gốc.');
                        reward(t['reward_' + tier], 'Quà ' + t.name + ' ' + tier);
                        check(t['reward_' + tier].length === 1, 'UI gốc mỗi hạng nhiệm vụ có1ô thưởng.');
                    }
                }
            }
        }
        catch (e) {
            if (e instanceof TypeError)
                return ['Cấu hình thiếu trường; tải mẫu nguồn và sửa bằng biểu mẫu.'];
            throw e;
        }
        return errors;
    }
    save(admin, b) { const c = b.definition, problems = this.problems(c); if (!c || !Object.hasOwn(restoredKinds, c.kind) || typeof c.name !== 'string' || !c.name.trim())
        fail('Chọn tên/loại sự kiện.'); this.db.exec('BEGIN IMMEDIATE'); try {
        let id = b.id, revision = 1;
        if (id) {
            const old = this.db.prepare('SELECT * FROM restored_event_configs WHERE id=?').get(id);
            if (!old || old.kind !== c.kind || old.status !== 'draft' || old.revision !== b.revision)
                fail('Nháp đã thay đổi hoặc đã công bố.');
            revision = Number(old.revision) + 1;
            this.db.prepare('UPDATE restored_event_configs SET definition=?,name=?,revision=? WHERE id=?').run(JSON.stringify(c), c.name, revision, id);
        }
        else
            id = Number(this.db.prepare("INSERT INTO restored_event_configs(kind,name,status,definition,created_at) VALUES(?,?,'draft',?,?)").run(c.kind, c.name, JSON.stringify(c), this.now()).lastInsertRowid);
        audit(this.db, admin, 'restored.config.save', null, 'Lưu nháp ' + c.name, null, { id, revision, problems });
        this.db.exec('COMMIT');
        return { id, revision, problems };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    publish(admin, b) { this.db.exec('BEGIN IMMEDIATE'); try {
        const c = this.configs().find(c => c.id === b.id);
        if (!c || c.status !== 'draft' || c.revision !== b.revision)
            fail('Nháp đã thay đổi hoặc đã công bố.');
        const problems = this.problems(c.definition);
        if (problems.length)
            fail(problems.join(' '));
        this.db.prepare("UPDATE restored_event_configs SET status='published',revision=revision+1 WHERE id=?").run(b.id);
        audit(this.db, admin, 'restored.config.publish', null, 'Công bố ' + c.name, null, { id: b.id });
        this.db.exec('COMMIT');
        return { ok: true };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    pick(rows, weight) { const total = rows.reduce((s, r) => s + weight(r), 0); if (!int(total, 1, 100000000))
        fail('Tổng tỷ trọng không hợp lệ.'); let n = this.rng(total); if (!int(n, 0, total - 1))
        throw Error('RNG ngoài miền.'); for (const r of rows) {
        n -= weight(r);
        if (n < 0)
            return r;
    } throw Error('Thiếu miền bốc.'); }
    uniform(a, b) { const n = this.rng(b - a + 1); if (!int(n, 0, b - a))
        throw Error('RNG ngoài miền.'); return a + n; }
    range(rows) { const r = this.pick(rows, r => r[2]); return this.uniform(r[0], r[1]); }
    profile(s) { return new ProgressionEconomyService(this.db).profile(s); }
    charge(s, from, to) { return Number(this.db.prepare("SELECT COALESCE(sum(event_amount),0) n FROM hot_recharges WHERE user_id=? AND realm='local-1' AND created_at>=? AND created_at<?").get(s.user_id, from, to)?.n ?? 0); }
    investmentAllowance(s, c, used) {
        const free = investmentFreeTurns(this.profile(s).vip ?? 0), rechargeVnd = Number(this.db.prepare("SELECT COALESCE(sum(price),0) n FROM hot_recharges WHERE user_id=? AND realm='local-1' AND created_at>=? AND created_at<?").get(s.user_id, c.starts, Math.min(this.now() + 1, c.ends))?.n ?? 0), paid = Math.min(2, Math.floor(rechargeVnd / investmentRechargeVnd));
        return { free, paid, total: free + paid, remaining: Math.max(0, free + paid - used), rechargeVnd, thresholdVnd: investmentRechargeVnd };
    }
    run(s, kind, occurrence) {
        if (occurrence) {
            const r = this.db.prepare('SELECT * FROM restored_event_runs WHERE user_id=? AND occurrence_id=? AND kind=?').get(s.user_id, occurrence, kind);
            if (!r)
                fail('Không có đợt sự kiện của tài khoản.');
            return this.decode(r);
        }
        const planner = new EventPlanner(this.db, this.now), target = restoredKinds[kind].target, p = this.profile(s);
        let e = planner.selection(target).occurrence;
        if (!planner.visibility(p.level ?? 1, p.vip ?? 0).entries[target])
            e = null;
        if (!e) {
            const old = this.db.prepare('SELECT * FROM restored_event_runs WHERE user_id=? AND kind=? ORDER BY updated_at DESC LIMIT 1').get(s.user_id, kind);
            if (old)
                return this.decode(old);
            return fail('Sự kiện đang tắt/ngoài lịch hoặc chưa đủ cấp/VIP.');
        }
        let row = this.db.prepare('SELECT * FROM restored_event_runs WHERE user_id=? AND occurrence_id=? AND kind=?').get(s.user_id, e.id, kind);
        if (!row) {
            const rule = planner.rules().find(r => r.id === e.ruleId), config = this.configs().find(c => c.kind === kind && c.status === 'published' && (!rule?.definition.contentId || c.id === rule.definition.contentId));
            if (!config)
                fail('Chưa có cấu hình đã công bố; chọn cấu hình trong lịch sự kiện.');
            const problems = this.problems(config.definition);
            if (problems.length)
                fail(problems[0]);
            const c = { ...config.definition, starts: e.starts, ends: e.ends }, state = kind === 'investment' ? { investments: {}, used: 0, refresh: 0, quick: 0, big: false } : { tasks: {}, chosen: {}, score: 0, scoreAt: this.now() };
            this.db.prepare('INSERT INTO restored_event_runs VALUES(?,?,?,?,?,?,0,?)').run(s.user_id, e.id, kind, config.id, JSON.stringify(c), JSON.stringify(state), this.now());
            row = this.db.prepare('SELECT * FROM restored_event_runs WHERE user_id=? AND occurrence_id=? AND kind=?').get(s.user_id, e.id, kind);
        }
        return this.decode(row);
    }
    decode(row) { return { row, c: JSON.parse(String(row.snapshot)), t: JSON.parse(String(row.state)) }; }
    ensureOpen(s, run) { const p = this.profile(s), planner = new EventPlanner(this.db, this.now), target = restoredKinds[run.row.kind].target; if (planner.selection(target).occurrence?.id !== run.row.occurrence_id || !planner.visibility(p.level ?? 1, p.vip ?? 0).entries[target])
        fail('Đợt đã hết hoặc bị tắt; chỉ nhận khoản/nhiệm vụ đã bắt đầu.'); }
    wire(s, run, extra = {}) {
        const { row, c, t } = run, base = { restored_kind: c.kind, restored_occurrence: row.occurrence_id, restored_revision: Number(row.revision), restored_configs: {}, version: c.sourceVersion, restored_claim_only: new EventPlanner(this.db, this.now).selection(restoredKinds[c.kind].target).occurrence?.id !== row.occurrence_id, ...extra };
        if (c.kind === 'investment') {
            const investing = {};
            for (let i = 1; i <= 9; i++)
                investing[i] = t.investments[i] ?? { coin: 0, time: 0, time_long: 0, flag: 0, per: [], in_come: 0 };
            const score = Number(this.db.prepare("SELECT COALESCE(sum(CAST(json_extract(state,'$.total') AS INTEGER)),0) n FROM restored_event_runs WHERE occurrence_id=? AND kind='investment'").get(row.occurrence_id).n), allowance = this.investmentAllowance(s, c, t.used), vipRows = Object.fromEntries(Object.entries(c.vip).map(([id, v]) => [id, { ...v, free_times: investmentFreeTurns(+id) }])), vip = { ...c.vip[String(Math.min(15, this.profile(s).vip ?? 0))], free_times: allowance.free };
            return { ...base, investing, investing_times: t.used, refresh_times: t.refresh, free_times: t.quick === 0 ? 1 : 0, buy_investing_times: allowance.paid, investing_allowance: allowance, is_bag_reward: t.big ? 1 : 0, score, logs: this.investmentLogs(row.occurrence_id), time_count_down: Object.fromEntries(Object.entries(investing).map(([k, v]) => [k, Math.max(0, Math.ceil(((v.end ?? 0) - this.now()) / 1000))])), restored_configs: { gringotts: { [c.sourceVersion]: c.rule }, gringotts_VIP: { ...vipRows, [String(this.profile(s).vip ?? 0)]: vip } } };
        }
        const day = eventDay(this.now()), start = Date.parse(day + 'T00:00:00+07:00'), used = t.chosen[day] ?? 0, tasks = {};
        for (const id of c.rule.task) {
            const v = t.tasks[id];
            tasks[id] = v ? { ...v, status: v.status === 1 && v.end <= this.now() ? 2 : v.status, remain_time: v.status === 1 ? Math.max(0, Math.ceil((v.end - this.now()) / 1000)) : 0, cards: { ...v.cards, pick_cards: Object.values(t.tasks).flatMap((x) => x.selected ?? []) } } : { status: 0, remain_time: 0 };
        }
        const ranks = this.db.prepare("SELECT p.game_uid uid,json_extract(p2.profile,'$.show_name') name,CAST(json_extract(r.state,'$.score') AS INTEGER) score FROM restored_event_runs r JOIN player_profiles p ON p.user_id=r.user_id JOIN player_state p2 ON p2.user_id=r.user_id WHERE r.occurrence_id=? AND r.kind='dispatch' ORDER BY score DESC,CAST(json_extract(r.state,'$.scoreAt') AS INTEGER),r.user_id LIMIT 100").all(row.occurrence_id).map((r, i) => ({ ...r, rank: i + 1 }));
        return { ...base, tasks, score: t.score, choose_task_times: Math.max(0, c.freeDaily + Math.floor(this.charge(s, Math.max(start, c.starts), Math.min(start + 86400000, c.ends)) / c.rule.need) - used), remain_time: Math.max(0, Math.ceil((c.ends - this.now()) / 1000)), show_ranks: ranks, restored_configs: { chuzheng_version: { [c.sourceVersion]: c.rule }, chuzheng_task: c.tasks } };
    }
    packet(s, result) {
        const items = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id);
        return { ...result, _client_cache_update: { ...result._client_cache_update, item: { items: { update: Object.fromEntries(items.filter(r => Number(r.quantity) > 0).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: items.filter(r => !r.quantity).map(r => String(r.config_id)) } } } };
    }
    index(s, kind) { new RestoredEventSettlement(this.db, this.now).deliver(s.user_id); this.db.exec('BEGIN IMMEDIATE'); try {
        const r = this.packet(s, this.wire(s, this.run(s, kind)));
        this.db.exec('COMMIT');
        return r;
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    execute(s, kind, action, p) {
        new RestoredEventSettlement(this.db, this.now).deliver(s.user_id);
        const key = p.get('request_id'), occurrence = p.get('restored_occurrence'), revision = p.get('restored_revision');
        if (!key || !/^[-\w:.]{8,160}$/.test(key) || !occurrence || !/^\d+$/.test(revision ?? ''))
            fail('Mở lại sự kiện bằng APK LOCAL mới để đồng bộ.');
        const hash = createHash('sha256').update(JSON.stringify([kind, action, occurrence, revision, p.get('sort'), p.get('time_long'), p.get('task_id'), p.get('card_list'), p.get('card_ids')])).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT * FROM restored_event_ops WHERE user_id=? AND request_id=?').get(s.user_id, key);
            if (old) {
                if (old.fingerprint !== hash)
                    fail('Mã thao tác đã dùng cho nội dung khác.');
                const result = this.packet(s, this.wire(s, this.run(s, kind, occurrence), { reward: [], replayed: true }));
                this.db.exec('COMMIT');
                return result;
            }
            const run = this.run(s, kind, occurrence), { c, t, row } = run;
            if (Number(revision) !== row.revision)
                fail('Trạng thái đã đổi; mở lại sự kiện trước khi tiếp tục.');
            let rewards = [];
            const cost = (n) => { if (n > 0)
                new ProgressionEconomyService(this.db, this.now).cost(s, [[9, 0, n]]); };
            if (kind === 'investment') {
                const next = t.used + 1, allowance = this.investmentAllowance(s, c, t.used);
                if (action === 'refresh') {
                    this.ensureOpen(s, run);
                    if (next > 9)
                        fail('Đã hết9lượt đầu tư.');
                    if (allowance.remaining < 1)
                        fail('Hết lượt đầu tư; mỗi 100.000 VNĐ nạp thêm một lượt, tối đa hai lượt.');
                    beginHotSpend(this.db, s.user_id, 'gringotts.refresh', key, this.now());
                    cost(c.rule.refresh_coin[Math.min(t.refresh, c.rule.refresh_coin.length - 1)]);
                    endHotSpend(this.db, s.user_id);
                    const dir = this.pick(['up', 'down'], v => v === 'up' ? c.upWeight : c.downWeight), r = c.rates[next - 1], coin = this.range(r['coin_' + dir]), rate = this.range(r['refresh_rate_' + dir]), per = [1, 2, 3].map(i => Math.floor(rate * this.uniform(c.rule['coin_point' + i][0], c.rule['coin_point' + i][1]) / 100) / 100);
                    t.investments[next] = { coin, per, flag: 0, time: 0, time_long: 0, in_come: 0 };
                    t.refresh++;
                }
                else if (action === 'investing') {
                    this.ensureOpen(s, run);
                    if (next > allowance.total)
                        fail('Không còn lượt đầu tư.');
                    const v = t.investments[next], hours = Number(p.get('time_long')), i = [c.rule.time1, c.rule.time2, c.rule.time3].indexOf(hours);
                    if (!v || i < 0)
                        fail('Tạo mới và chọn kỳ hạn nguồn trước.');
                    cost(v.coin);
                    v.time = Math.floor(this.now() / 1000);
                    v.end = this.now() + hours * 3600000;
                    v.time_long = hours;
                    v.profit = Math.floor(v.coin * v.per[i]);
                    v.in_come = v.coin + v.profit;
                    t.used++;
                    t.total = (t.total ?? 0) + v.coin;
                }
                else if (action === 'get_reward' || action === 'quickly_reward') {
                    const v = t.investments[Number(p.get('sort'))];
                    if (!v?.time_long || v.flag)
                        fail('Khoản đầu tư chưa tồn tại hoặc đã nhận.');
                    let deduction = 0;
                    if (v.end > this.now()) {
                        if (action !== 'quickly_reward')
                            fail('Khoản đầu tư chưa đến hạn.');
                        if (t.quick > 0)
                            deduction = Math.min(v.profit, Math.ceil((v.end - this.now()) / 3600000) * c.rule.quickly_point * v.profit / 100);
                        t.quick++;
                    }
                    v.flag = 1;
                    v.paid = v.coin + Math.max(0, Math.floor(v.profit - deduction));
                    rewards = [[9, 0, v.paid]];
                }
                else if (action === 'get_big_reward') {
                    if (t.big || !t.used)
                        fail('Chưa tham gia hoặc đã nhận quà mốc.');
                    const score = this.wire(s, run).score;
                    if (score < c.rule.max_coin)
                        fail('Tổng đầu tư chưa đạt mốc.');
                    rewards = c.rule.charge_reward;
                    t.big = true;
                }
                else
                    fail('Thao tác Cổ Linh Các không hợp lệ.');
            }
            else {
                const taskId = String(p.get('task_id')), cfg = c.tasks[taskId];
                if (!c.rule.task.includes(Number(taskId)) || !cfg)
                    fail('Nhiệm vụ không thuộc đợt này.');
                let v = t.tasks[taskId];
                if (action === 'choose_task') {
                    this.ensureOpen(s, run);
                    if (v && v.status !== 0)
                        fail('Nhiệm vụ đã bắt đầu, không thể đổi.');
                    if (!v) {
                        if (this.wire(s, run).choose_task_times < 1)
                            fail('Hết lượt chọn nhiệm vụ hôm nay.');
                        const tier = this.pick(['s', 'ss', 'sss'], v => c.tierWeights[['s', 'ss', 'sss'].indexOf(v)]), pool = [...new Set(cfg.card)], need = [];
                        while (need.length < 4)
                            need.push(pool.splice(this.uniform(0, pool.length - 1), 1)[0]);
                        v = { status: 0, remain_time: 0, level: tier, cards: { need_cards: need, limit_break: cfg['break_' + tier], limit_evo: cfg['evolution_' + tier], pick_cards: [] }, selected: [] };
                        t.tasks[taskId] = v;
                        t.chosen[eventDay(this.now())] = (t.chosen[eventDay(this.now())] ?? 0) + 1;
                    }
                }
                else if (action === 'start_task') {
                    this.ensureOpen(s, run);
                    if (!v || v.status !== 0)
                        fail('Nhiệm vụ chưa chọn hoặc đã bắt đầu.');
                    const ids = p.has('card_ids') ? JSON.parse(p.get('card_ids')) : (p.get('card_list') ?? '').split('_'), busy = new Set(Object.values(t.tasks).flatMap((x) => x.selected ?? []));
                    if (!Array.isArray(ids) || ids.length !== 4 || ids.some(id => typeof id !== 'string' || id.length > 100) || new Set(ids).size !== 4)
                        fail('Chọn4tướng khác nhau.');
                    const heroes = ids.map((id) => { const r = this.db.prepare('SELECT config_id,state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, id); if (!r || busy.has(id))
                        fail('Tướng không thuộc tài khoản hoặc đang phái đi.'); const h = JSON.parse(String(r.state)); if (h.bre < v.cards.limit_break || h.super_step < v.cards.limit_evo)
                        fail('Tướng chưa đạt Chuyển Thế/Siêu Tiến Hóa.'); return Number(r.config_id); });
                    if (heroes.slice().sort((a, b) => a - b).join(',') !== v.cards.need_cards.slice().sort((a, b) => a - b).join(','))
                        fail('Chọn đúng4tướng yêu cầu.');
                    v.selected = ids;
                    v.status = 1;
                    v.end = this.now() + 7200000;
                }
                else if (action === 'immediately_finish_task') {
                    if (!v || ![0, 1].includes(v.status))
                        fail('Chọn nhiệm vụ trước khi Hoàn thành ngay.');
                    if (v.status === 0)
                        this.ensureOpen(s, run);
                    if (v.status === 0 || v.end > this.now())
                        new ProgressionEconomyService(this.db, this.now).cost(s, [[6, c.rule.pass, 1]]);
                    rewards = cfg['reward_' + v.level];
                    t.score += c.rule['score_' + v.level];
                    t.scoreAt = this.now();
                    delete t.tasks[taskId];
                }
                else if (action === 'get_task_reward') {
                    if (!v || v.status !== 1 || v.end > this.now())
                        fail('Nhiệm vụ chưa hoàn thành hoặc đã nhận.');
                    rewards = cfg['reward_' + v.level];
                    t.score += c.rule['score_' + v.level];
                    t.scoreAt = this.now();
                    delete t.tasks[taskId];
                }
                else
                    fail('Thao tác Xuất Chinh không hợp lệ.');
            }
            let delivery = {};
            if (rewards.length)
                delivery = new WelfareService(this.db).applyInTransaction(s, rewards, { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') });
            this.db.prepare('UPDATE restored_event_runs SET state=?,revision=revision+1,updated_at=? WHERE user_id=? AND occurrence_id=? AND kind=?').run(JSON.stringify(t), this.now(), s.user_id, occurrence, kind);
            row.revision = Number(row.revision) + 1;
            const result = this.packet(s, this.wire(s, run, { ...delivery, reward: rewards }));
            this.db.prepare('INSERT INTO restored_event_ops VALUES(?,?,?,?,?,?,?,?)').run(s.user_id, key, hash, occurrence, kind, action, JSON.stringify(result), this.now());
            audit(this.db, null, 'restored.' + kind + '.' + action, s.user_id, restoredKinds[kind].name, null, { occurrence, revision: row.revision, rewards });
            this.db.exec('COMMIT');
            return result;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    investmentLogs(occurrence) {
        return this.db.prepare("SELECT json_extract(p.profile,'$.show_name') name,j.value investment FROM restored_event_runs r JOIN player_state p ON p.user_id=r.user_id,json_each(r.state,'$.investments') j WHERE r.occurrence_id=? AND r.kind='investment' AND json_extract(j.value,'$.time_long')>0 ORDER BY CAST(json_extract(j.value,'$.time') AS INTEGER) DESC,r.user_id LIMIT 20").all(occurrence).map(r => {
            const v = JSON.parse(String(r.investment)), name = String(r.name ?? 'Người chơi').replace(/[<>&{}\[\]#]/g, '').slice(0, 32);
            return name + ' đầu tư ' + v.coin + ' Xu · ' + v.time_long + ' giờ' + (v.flag ? ' · đã nhận ' + v.paid + ' Xu' : '');
        });
    }
    admin(kind) { const table = kind === 'investment' ? 'gringotts' : 'chuzheng_version'; return { kind, ...restoredKinds[kind], prototype: restoredDefault(kind), presets: Object.entries(restoredSource(table)).map(([id, c]) => ({ id: Number(id), starts: c.start_time, ends: c.end_time })), configs: this.configs().filter(c => c.kind === kind), notice: 'Công bố cấu hình rồi gắn ID vào lịch sự kiện. Snapshot người chơi đã tham gia giữ nguyên. Thời gian đang chạy không bị đổi theo chỉnh sửa mới.' }; }
    history(kind, page = 1) { page = Math.max(1, Math.min(10000, Math.floor(page) || 1)); return { page, total: this.db.prepare('SELECT count(*) n FROM restored_event_ops WHERE kind=?').get(kind).n, items: this.db.prepare('SELECT user_id,occurrence_id,action,created_at FROM restored_event_ops WHERE kind=? ORDER BY created_at DESC LIMIT 30 OFFSET ?').all(kind, (page - 1) * 30), runs: this.db.prepare('SELECT user_id,occurrence_id,config_id,revision,state,updated_at FROM restored_event_runs WHERE kind=? ORDER BY updated_at DESC LIMIT 30').all(kind).map(r => ({ ...r, state: JSON.parse(String(r.state)) })) }; }
}
