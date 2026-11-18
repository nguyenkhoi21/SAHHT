import { createHash, randomInt } from 'node:crypto';
import { EventPlanner, eventFail } from './event-planner.js';
import { treasureKinds, treasurePresets, defaultTreasure } from './treasure-source.js';
import { rewardProblem } from './hot-campaigns.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { readConfigSync } from './local-content.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { audit } from '../admin/admin.audit.js';
const integer = (n, min = 0, max = 100000000) => Number.isSafeInteger(n) && n >= min && n <= max;
const array = (v, max = 200) => Array.isArray(v) && v.length > 0 && v.length <= max;
function validateTreasure(c) {
    const problems = [], check = (ok, text) => { if (!ok)
        problems.push(text); }, reward = (r, label) => { const error = rewardProblem(r); if (error)
        problems.push(label + ': ' + error); };
    if (!c || !Object.hasOwn(treasureKinds, c.kind))
        return ['Chọn đúng loại sự kiện.'];
    check(typeof c.name === 'string' && c.name.trim().length > 0 && c.name.length <= 80, 'Tên cần1–80ký tự.');
    check(integer(c.sourceVersion, 1) && treasurePresets(c.kind).some(p => p.version === c.sourceVersion), 'Phiên bản nguồn không hợp lệ.');
    check(typeof c.notice === 'string' && c.notice.length <= 20000, 'Nội dung quy tắc tối đa20.000ký tự.');
    check(c.policy === 'LOCAL_CONFIGURED', 'Cần xác nhận quy tắc LOCAL tùy chỉnh.');
    const weighted = (rows, label, heroes = false) => { if (!array(rows, 100)) {
        problems.push(label + ': cần1–100quà.');
        return;
    } check(rows.some((v) => integer(v.weight, 1, 1000000)), label + ': cần tỷ trọng dương.'); for (const r of rows) {
        check(integer(r.weight, 0, 1000000), label + ': tỷ trọng nguyên0–1.000.000.');
        if (r.blocked && r.weight === 0)
            continue;
        reward([r.reward], label);
        if (heroes)
            check(r.reward?.[0] === 5, label + ': cần thẻ tướng/nguyên liệu theo giao diện gốc.');
    } };
    const prices = (rows, n, label) => check(Array.isArray(rows) && rows.length === n && rows.every((v) => integer(v, 0, 100000000)), label + ': cần ' + n + 'giá nguyên không âm.');
    if (c.kind === 'treasure') {
        prices(c.prices, 2, 'Giá tìm kho báu');
        check(c.keyItem === 203, 'Chìa khóa nguồn phải là #203.');
        check(c.tenBonus === 1, 'Nguồn: tìm10 tặng1.');
        check(Array.isArray(c.wheel) && c.wheel.length === 8, 'Vòng quay cần8ô.');
        if (Array.isArray(c.wheel)) {
            check(new Set(c.wheel.map((r) => r.slot)).size === 8 && c.wheel.every((r) => integer(r.slot, 1, 8) && integer(r.weight, 0, 1000000)), 'Vị trí1–8 không trùng, tỷ trọng hợp lệ.');
            check(c.wheel.some((r) => r.weight > 0), 'Vòng quay cần tỷ trọng dương.');
            c.wheel.forEach((r) => reward(r.rewards, 'Ô ' + r.slot));
        }
        weighted(c.extras, 'Quà phụ');
        check(Array.isArray(c.milestones) && c.milestones.length === 3, 'Cần3mốc gốc.');
        c.milestones?.forEach((r, i) => { check(r.key === String(i + 1) && integer(r.threshold, 1), 'Mốc cần ID1–3 và số lần dương.'); reward(r.rewards, 'Mốc ' + r.key); });
        check(array(c.exchanges, 200), 'Cần1–200món đổi.');
        c.exchanges?.forEach((r) => { check(/^\d{1,9}$/.test(r.key) && integer(r.cost, 1) && integer(r.limit, -1, 1000000) && integer(r.playerLimit, 0, 1000000) && [1, 2, 3].includes(r.group), 'Món đổi cần ID/cost/giới hạn mỗi người/nhóm hợp lệ.'); reward(r.rewards, 'Đổi #' + r.key); });
        check(new Set(c.exchanges?.map((r) => r.key)).size === c.exchanges?.length, 'ID đổi không trùng.');
    }
    else if (c.kind === 'labyrinth') {
        check(Array.isArray(c.pools) && c.pools.length === 2, 'Cần hai bể Kim Cương/Ngọc Rồng.');
        c.pools?.forEach((p, i) => { check(p.type === i + 1, 'Bể phải đúng thứ tự1–2.'); prices(p.prices, 14, 'Giá14lượt'); check(Array.isArray(p.cost) && p.cost.length === 3 && [6, 9].includes(p.cost[0]) && !rewardProblem([p.cost], true), 'Loại tiền rút cần Xu hoặc vật phẩm nguồn.'); check(Array.isArray(p.refresh) && p.refresh.length === 1 && !rewardProblem(p.refresh, true) && p.refresh.every((r) => [6, 9].includes(r[0])), 'Giá tạo mới cần đúng một dòng Xu/vật phẩm nguồn để khớp giao diện gốc.'); check(Array.isArray(p.groups) && p.groups.length === 3, 'Cần3nhóm quà.'); let count = 0; p.groups?.forEach((g) => { check(integer(g.count, 1, 14) && integer(g.weight, 1, 1000000), 'Số ô/tỷ trọng nhóm chưa đúng.'); count += g.count; weighted(g.entries, 'Nhóm ' + g.key); check(g.entries?.filter((v) => v.weight > 0).length >= g.count, 'Không đủ quà khác dòng để tạo bể không lặp.'); }); check(count === 14, 'Tổng số ô bể phải đúng14.'); });
    }
    else {
        prices(c.singlePrices, 10, 'Giá lật');
        prices(c.packPrices, 10, 'Giá đóng gói');
        check(array(c.refreshPrices, 20) && c.refreshPrices.every((v) => integer(v)), 'Giá tạo mới chưa hợp lệ.');
        check(Array.isArray(c.luckRange) && c.luckRange.length === 2 && integer(c.luckRange[0]) && integer(c.luckRange[1], c.luckRange[0]), 'Khoảng điểm may mắn chưa đúng.');
        check(integer(c.luckMax, 1) && integer(c.pieceChance, 0, 100) && c.pieceCount === 9, 'Điểm tối đa/tỷ lệ0–100/9mảnh chưa đúng.');
        weighted(c.mystery, 'Quà thần bí', true);
        c.mystery?.forEach((r) => check((readConfigSync('character_detail')[r.reward?.[1]]?.quality ?? 0) >= 3, 'Quà thần bí cần thẻ phẩm chất3+ để dùng hoạt ảnh gốc.'));
        check(Array.isArray(c.groups) && c.groups.length === 5, 'Cần5nhóm thẻ.');
        c.groups?.forEach((g, i) => { weighted(g.entries, 'Nhóm thẻ ' + g.key, true); if (i < 4)
            check(array(g.distribution, 10) && g.distribution.every((r) => Array.isArray(r) && r.length === 2 && integer(r[0], 0, 9) && integer(r[1], 1, 1000000)), 'Số thẻ/tỷ trọng nhóm chưa đúng.'); });
        if (c.groups?.length === 5)
            check(c.groups.slice(0, 4).reduce((s, g) => s + Math.max(0, ...(g.distribution ?? []).map((r) => r[0])), 0) <= 10, 'Tổng tối đa4nhóm không được vượt10thẻ.');
    }
    return problems;
}
export function treasureProblems(c) { try {
    return validateTreasure(c);
}
catch (e) {
    if (e instanceof TypeError)
        return ['Cấu trúc cấu hình không hợp lệ; tải mẫu nguồn rồi sửa bằng trình soạn.'];
    throw e;
} }
export class TreasureEvents {
    db;
    now;
    rng;
    constructor(db, now = Date.now, rng = randomInt) {
        this.db = db;
        this.now = now;
        this.rng = rng;
    }
    configs() { return this.db.prepare('SELECT * FROM treasure_event_configs ORDER BY id DESC').all().map(r => ({ ...r, definition: JSON.parse(String(r.definition)) })); }
    admin(kind) { if (!Object.hasOwn(treasureKinds, kind))
        eventFail('Loại sự kiện không hợp lệ.'); return { kind, ...treasureKinds[kind], presets: treasurePresets(kind), prototype: defaultTreasure(kind), configs: this.configs().filter(c => c.kind === kind), notice: 'Đã được chủ dự án cho phép cấu hình tỷ trọng/tỷ lệ LOCAL. Snapshot hiện có không bị sửa; công bố cấu hình rồi gắn vào lịch mới để áp cho cả đợt mới.' }; }
    save(admin, b) { const c = b.definition; if (!c || !Object.hasOwn(treasureKinds, c.kind) || typeof c.name !== 'string' || !c.name.trim() || c.name.length > 80)
        eventFail('Cần tên và loại sự kiện hợp lệ.'); const problems = treasureProblems(c); this.db.exec('BEGIN IMMEDIATE'); try {
        let id = b.id, revision = 1;
        if (id) {
            const old = this.db.prepare('SELECT * FROM treasure_event_configs WHERE id=?').get(id);
            if (!old || old.status !== 'draft' || old.revision !== b.revision || old.kind !== c.kind)
                eventFail('Nháp đã thay đổi hoặc đã công bố.');
            revision = Number(old.revision) + 1;
            this.db.prepare('UPDATE treasure_event_configs SET name=?,definition=?,revision=? WHERE id=?').run(c.name, JSON.stringify(c), revision, id);
        }
        else
            id = Number(this.db.prepare("INSERT INTO treasure_event_configs(kind,name,status,definition,created_at) VALUES(?,?,'draft',?,?)").run(c.kind, c.name, JSON.stringify(c), this.now()).lastInsertRowid);
        audit(this.db, admin, 'treasure.config.save', null, 'Lưu cấu hình ' + c.name, null, { id, revision, problems });
        this.db.exec('COMMIT');
        return { id, revision, problems };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    publish(admin, b) { this.db.exec('BEGIN IMMEDIATE'); try {
        const r = this.configs().find(c => c.id === b.id);
        if (!r || r.revision !== b.revision || r.status !== 'draft')
            eventFail('Nháp không còn khớp.');
        const problems = treasureProblems(r.definition);
        if (problems.length)
            eventFail(problems.slice(0, 6).join(' '));
        this.db.prepare("UPDATE treasure_event_configs SET status='published',revision=revision+1 WHERE id=?").run(b.id);
        audit(this.db, admin, 'treasure.config.publish', null, 'Công bố cấu hình ' + r.name, null, { id: b.id, policy: 'LOCAL_CONFIGURED' });
        this.db.exec('COMMIT');
        return { ok: true };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    pick(rows, weight) { const total = rows.reduce((s, v) => s + weight(v), 0); if (!Number.isSafeInteger(total) || total < 1)
        eventFail('Bể quà không có tỷ trọng dương.'); let n = this.rng(total); if (!integer(n, 0, total - 1))
        throw Error('RNG không hợp lệ.'); for (const r of rows) {
        n -= weight(r);
        if (n < 0)
            return r;
    } throw Error('Thiếu miền tỷ trọng.'); }
    choose(rows) { return structuredClone(this.pick(rows, r => r.weight).reward); }
    deck(c) { let cards = []; for (let i = 0; i < 5; i++) {
        const g = c.groups[i], count = i === 4 ? 10 - cards.length : this.pick(g.distribution, r => r[1])[0];
        for (let n = 0; n < count; n++)
            cards.push(this.choose(g.entries));
    } for (let i = cards.length - 1; i > 0; i--) {
        const n = this.rng(i + 1);
        if (!integer(n, 0, i))
            throw Error('RNG không hợp lệ.');
        [cards[i], cards[n]] = [cards[n], cards[i]];
    } return cards; }
    pool(p) { const pool = []; for (const g of p.groups) {
        let entries = [...g.entries];
        for (let n = 0; n < g.count; n++) {
            const chosen = this.pick(entries, (v) => v.weight);
            pool.push([...chosen.reward, g.weight]);
            entries = entries.filter(v => v !== chosen);
        }
    } return pool; }
    initial(c) { if (c.kind === 'treasure')
        return { spins: 0, claims: [], exchanges: {}, lastSlot: 1 }; if (c.kind === 'labyrinth')
        return { pools: c.pools.map((p) => this.pool(p)), logs: [Array(14).fill(0), Array(14).fill(0)], cycles: [0, 0] }; const cards = this.deck(c); return { cards, showTeam: structuredClone(cards), owned: {}, open: 0, refresh: 0, score: 0, pieces: [], mystery: this.choose(c.mystery), history: [] }; }
    target(kind) { return treasureKinds[kind].target; }
    active(s, kind) { const profile = new ProgressionEconomyService(this.db).profile(s), planner = new EventPlanner(this.db, this.now), target = this.target(kind), entry = planner.visibility(profile.level ?? 1, profile.vip ?? 0).entries[target]; if (!entry)
        eventFail('Sự kiện đang tắt hoặc ngoài lịch/cấp/VIP.'); return planner.selection(target).occurrence; }
    run(s, kind) {
        const e = this.active(s, kind);
        let row = this.db.prepare('SELECT * FROM treasure_event_runs WHERE user_id=? AND occurrence_id=? AND kind=?').get(s.user_id, e.id, kind);
        if (!row) {
            const rule = new EventPlanner(this.db, this.now).rules().find(r => r.id === e.ruleId), id = rule?.definition.contentId, config = this.configs().find(c => c.kind === kind && c.status === 'published' && (!id || c.id === id));
            if (!config)
                eventFail('Chưa có cấu hình quà đã công bố cho sự kiện này.');
            const issues = treasureProblems(config.definition);
            if (issues.length)
                eventFail('Cấu hình quà chưa hợp lệ: ' + issues[0]);
            const state = this.initial(config.definition);
            this.db.prepare('INSERT INTO treasure_event_runs VALUES(?,?,?,?,?,?,0,?)').run(s.user_id, e.id, kind, config.id, JSON.stringify(config.definition), JSON.stringify(state), this.now());
            row = this.db.prepare('SELECT * FROM treasure_event_runs WHERE user_id=? AND occurrence_id=? AND kind=?').get(s.user_id, e.id, kind);
        }
        return { e, row: row, c: JSON.parse(String(row.snapshot)), state: JSON.parse(String(row.state)) };
    }
    exchangeUsed(occurrence, key) { return Number(this.db.prepare("SELECT COALESCE(sum(CAST(json_extract(state,?) AS INTEGER)),0) n FROM treasure_event_runs WHERE occurrence_id=? AND kind='treasure'").get('$.exchanges.\"' + key + '\"', occurrence)?.n ?? 0); }
    balance(s, id) { return Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0); }
    wire(s, run, type = 1, extra = {}) {
        const { e, row, c, state: t } = run, base = { event_kind: c.kind, event_occurrence: e.id, event_revision: Number(row.revision), event_policy: c.policy, config_id: row.config_id, version: c.sourceVersion, event_configs: {}, ...extra }, remaining = Math.max(0, Math.floor((e.ends - this.now()) / 1000));
        if (c.kind === 'treasure') {
            const ranking = this.db.prepare("SELECT p.game_uid,COALESCE(json_extract(s.profile,'$.name'),p.game_uid) name,json_extract(r.state,'$.spins') score FROM treasure_event_runs r JOIN player_profiles p ON p.user_id=r.user_id JOIN player_state s ON s.user_id=r.user_id WHERE r.occurrence_id=? AND r.kind='treasure' ORDER BY CAST(json_extract(r.state,'$.spins') AS INTEGER) DESC,r.user_id LIMIT 100").all(e.id);
            const exchanges = Object.fromEntries(c.exchanges.map((x) => [x.key, { sort: x.group, player_limit: x.playerLimit, limit_num: x.limit, need_key_num: x.cost, version: c.sourceVersion, reward: x.rewards }]));
            base.event_configs = { one_piece: { [c.sourceVersion]: { one_coin: c.prices[0], ten_coin: c.prices[1], show_ranking: 1, notice: c.notice, ...Object.fromEntries(c.milestones.flatMap((m) => [['score_' + m.key, m.threshold], ['reward_' + m.key, m.rewards]])) } }, one_piece_rate: Object.fromEntries(c.wheel.map((w, i) => [String(i + 1), { id: w.slot, show_id: w.slot, version: c.sourceVersion, rate: w.weight, score: w.sourceScore, has_reduce: 0, reward: w.rewards }])), one_piece_exchange: exchanges, one_piece_rank_reward: {} };
            return { ...base, remainder_time: remaining, score: t.spins, rank: ranking.findIndex(r => r.game_uid === s.game_uid) + 1, open_times: t.spins, index: t.lastSlot, show_ranking: 1, rank_info: ranking, key_num: this.balance(s, c.keyItem), step_reward: t.claims.map(Number), exchange_index: { gifts: Object.fromEntries([1, 2].map(group => ['exchange_' + group, Object.fromEntries(c.exchanges.filter((x) => (x.group === 1 ? 1 : 2) === group).map((x) => [x.key, { remain: x.limit <= 0 ? -1 : Math.max(0, x.limit - (x.group === 3 ? this.exchangeUsed(e.id, x.key) : (t.exchanges[x.key] ?? 0))) }]))])) }, gifts: extra.reward_tuples ?? [], ...extra };
        }
        if (c.kind === 'labyrinth') {
            const p = c.pools[type - 1], used = t.logs[type - 1].reduce((a, b) => a + b, 0);
            base.event_configs = Object.fromEntries(c.pools.map((p) => [p.type === 1 ? 'new_roulette_diamond' : 'new_roulette_item', { [c.sourceVersion]: { notice: c.notice, refresh_price: p.refresh, reward_chance: p.groups.map((g) => [Number(g.key), g.weight]) } }]));
            return { ...base, remain_time: remaining, diamond_pool: t.pools[0], item_pool: t.pools[1], diamond_log: Object.fromEntries(t.logs[0].map((v, i) => [i, v])), item_log: Object.fromEntries(t.logs[1].map((v, i) => [i, v])), need_cost: [[p.cost[0], p.cost[1], p.prices[Math.min(used, 13)]]], ...extra };
        }
        base.event_configs = { clone_lane: { [c.sourceVersion]: { price: c.singlePrices, price_all: c.packPrices, cost: c.refreshPrices, notice: '[LOCAL tùy chỉnh tỷ trọng/tỷ lệ]\n' + c.notice, ...Object.fromEntries(c.groups.map((g, i) => ['reward_' + (i + 1), g.entries.map((r) => [...r.reward, r.weight])])), secret_reward: c.mystery.map((r) => [...r.reward, r.weight]), des: 'Đầy điểm may mắn: lượt rút/đóng gói tiếp theo chắc chắn có một ảnh ghép.', des_1: 'Lượt tiếp theo chắc chắn có một ảnh ghép!' } } };
        return { ...base, time_count_down: remaining, card_team: t.cards, show_team: t.showTeam ?? [...Object.values(t.owned), ...t.cards], own_card_team: t.owned, one_times: false, open_times: t.open, refresh_times: t.refresh, score: t.score, score_max: c.luckMax, secret_land: t.pieces, secret_reward: t.mystery, logs: { logs: [] }, ...extra };
    }
    index(s, kind, type = 1, notice = false) { if (![1, 2].includes(type))
        eventFail('Bể quà không tồn tại.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const result = this.wire(s, this.run(s, kind), type);
        if (kind === 'pantheon' && notice)
            result.logs = result.logs.logs;
        this.db.exec('COMMIT');
        return result;
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    action(s, kind, method, q) {
        if (typeof q.request_id !== 'string' || !/^[\w:-]{8,160}$/.test(q.request_id) || typeof q.event_occurrence !== 'string' || q.event_occurrence.length > 160 || !/^\d{1,9}$/.test(String(q.event_revision)))
            eventFail('Mở lại sự kiện bằng APK mới để đồng bộ lượt.');
        const args = { type: String(q.type ?? 1), sort: String(q.sort ?? ''), step: String(q.step ?? ''), id: String(q.id ?? '') }, hash = createHash('sha256').update(JSON.stringify([kind, method, q.event_occurrence, String(q.event_revision), args])).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT * FROM treasure_event_receipts WHERE user_id=? AND request_id=?').get(s.user_id, q.request_id);
            if (old) {
                if (old.fingerprint !== hash)
                    eventFail('Mã giao dịch đã dùng cho thao tác khác.');
                this.db.exec('COMMIT');
                return { ...JSON.parse(String(old.result)), replayed: true };
            }
            const run = this.run(s, kind), { c, state: t, row, e } = run;
            if (q.event_occurrence !== e.id || Number(q.event_revision) !== row.revision)
                eventFail('Trạng thái sự kiện đã thay đổi; mở lại trước khi tiếp tục.');
            let rewards = [], type = Number(args.type), view = {}, charged = [];
            const cost = (r) => { new ProgressionEconomyService(this.db, this.now).cost(s, r); charged.push(...r); };
            if (kind === 'treasure') {
                if (['open_roulette', 'open_roulette10'].includes(method)) {
                    const ten = method === 'open_roulette10';
                    cost([[9, 0, c.prices[ten ? 1 : 0]]]);
                    const n = ten ? 10 + c.tenBonus : 1;
                    for (let i = 0; i < n; i++) {
                        const w = this.pick(c.wheel, r => r.weight);
                        t.lastSlot = c.wheel.indexOf(w) + 1;
                        rewards.push(...w.rewards, [6, c.keyItem, 1], this.choose(c.extras));
                    }
                    t.spins += n;
                }
                else if (method === 'step_reward') {
                    const m = c.milestones.find((m) => m.key === args.step);
                    if (!m || t.spins < m.threshold)
                        eventFail('Chưa đạt mốc tìm kho báu.');
                    if (t.claims.includes(m.key))
                        eventFail('Mốc đã nhận.');
                    t.claims.push(m.key);
                    rewards = m.rewards;
                }
                else if (method === 'exchange') {
                    const x = c.exchanges.find((x) => x.key === args.id);
                    if (!x)
                        eventFail('Món đổi không tồn tại.');
                    const n = t.exchanges[x.key] ?? 0, global = this.exchangeUsed(e.id, x.key);
                    if (x.playerLimit > 0 && n >= x.playerLimit || x.limit > 0 && (x.group === 3 ? global : n) >= x.limit)
                        eventFail('Đã hết lượt đổi.');
                    cost([[6, c.keyItem, x.cost]]);
                    t.exchanges[x.key] = n + 1;
                    rewards = x.rewards;
                }
                else
                    eventFail('Thao tác Kho báu không được hỗ trợ.');
            }
            else if (kind === 'labyrinth') {
                if (![1, 2].includes(type))
                    eventFail('Bể quà không tồn tại.');
                const i = type - 1, p = c.pools[i], used = t.logs[i].reduce((a, b) => a + b, 0);
                if (method === 'open_new_roulette') {
                    if (used >= 14)
                        eventFail('Đã rút hết bể; tạo bể mới trước.');
                    cost([[p.cost[0], p.cost[1], p.prices[used]]]);
                    const choices = t.pools[i].map((r, j) => ({ r, j })).filter((v) => !t.logs[i][v.j]), v = this.pick(choices, v => v.r[3]);
                    t.logs[i][v.j] = 1;
                    rewards = [v.r.slice(0, 3)];
                }
                else if (method === 'refresh_new_roulette') {
                    if (used !== 14)
                        cost(p.refresh);
                    t.pools[i] = this.pool(p);
                    t.logs[i] = Array(14).fill(0);
                    t.cycles[i]++;
                }
                else
                    eventFail('Thao tác Mê cung không được hỗ trợ.');
            }
            else {
                const resetMystery = () => { t.pieces = []; t.mystery = this.choose(c.mystery); };
                if (['draw', 'pack'].includes(method)) {
                    if (!t.cards.length)
                        eventFail('Đã hết thẻ; phát bộ mới trước.');
                    if (t.pieces.length === 9)
                        resetMystery();
                    const all = method === 'pack', slot = Number(args.sort);
                    if (!all && (!integer(slot, 0, 9) || t.owned[String(slot)]))
                        eventFail('Vị trí thẻ đã lật hoặc không hợp lệ.');
                    cost([[9, 0, all ? c.packPrices[10 - t.cards.length] : c.singlePrices[t.open]]]);
                    if (all) {
                        for (const card of t.cards)
                            rewards.push(card);
                        t.owned = { ...t.owned };
                        let n = 0;
                        for (let j = 0; j < 10; j++)
                            if (!t.owned[String(j)])
                                t.owned[String(j)] = t.cards[n++];
                        t.open = 10;
                        t.cards = [];
                    }
                    else {
                        const index = this.rng(t.cards.length);
                        if (!integer(index, 0, t.cards.length - 1))
                            throw Error('RNG không hợp lệ.');
                        const card = t.cards.splice(index, 1)[0];
                        t.owned[String(slot)] = card;
                        t.open++;
                        rewards.push(card);
                    }
                    const roll = this.rng(100);
                    if (!integer(roll, 0, 99))
                        throw Error('RNG không hợp lệ.');
                    if (t.score >= c.luckMax || roll < c.pieceChance) {
                        const missing = Array.from({ length: 9 }, (_, i) => i + 1).filter(i => !t.pieces.includes(i));
                        const part = this.rng(missing.length);
                        if (!integer(part, 0, missing.length - 1))
                            throw Error('RNG không hợp lệ.');
                        t.pieces.push(missing[part]);
                        t.score = 0;
                        if (t.pieces.length === 9) {
                            rewards.push(t.mystery);
                            view = { secret_land: [...t.pieces], secret_reward: [...t.mystery] };
                            resetMystery();
                        }
                    }
                    else {
                        const gain = this.rng(c.luckRange[1] - c.luckRange[0] + 1);
                        if (!integer(gain, 0, c.luckRange[1] - c.luckRange[0]))
                            throw Error('RNG không hợp lệ.');
                        t.score = Math.min(c.luckMax, t.score + c.luckRange[0] + gain);
                    }
                }
                else if (method === 'refresh_team' || method === 'clean_data') {
                    if (method === 'clean_data' && t.cards.length)
                        eventFail('Chưa lật hết bộ thẻ; không tạo mới miễn phí.');
                    if (method === 'refresh_team')
                        cost([[9, 0, c.refreshPrices[Math.min(t.refresh, c.refreshPrices.length - 1)]]]);
                    t.cards = this.deck(c);
                    t.showTeam = structuredClone(t.cards);
                    t.owned = {};
                    t.open = 0;
                    if (method === 'refresh_team')
                        t.refresh++;
                    if (t.pieces.length === 9)
                        resetMystery();
                }
                else if (method === 'refresh_secret')
                    resetMystery();
                else
                    eventFail('Thao tác Chúng thần điện không được hỗ trợ.');
            }
            if (kind === 'pantheon' && method === 'pack') {
                t.cards = this.deck(c);
                t.showTeam = structuredClone(t.cards);
                t.owned = {};
                t.open = 0;
            }
            const delivery = rewards.length ? grantGodfieldReward(this.db, s, rewards) : { reward: {}, reward_tuples: [] };
            this.db.prepare('UPDATE treasure_event_runs SET state=?,revision=revision+1,updated_at=? WHERE user_id=? AND occurrence_id=? AND kind=?').run(JSON.stringify(t), this.now(), s.user_id, e.id, kind);
            row.revision = Number(row.revision) + 1;
            const result = this.wire(s, run, type, { ...delivery, gifts: delivery.reward_tuples ?? [], cost: charged, ...view });
            this.db.prepare('INSERT INTO treasure_event_receipts VALUES(?,?,?,?,?,?,?,?)').run(s.user_id, q.request_id, hash, e.id, kind, method, JSON.stringify(result), this.now());
            audit(this.db, null, 'treasure.play.' + kind, s.user_id, 'Thao tác ' + treasureKinds[kind].name, null, { method, occurrence: e.id, requestId: q.request_id, cost: charged, rewards, policy: c.policy });
            this.db.exec('COMMIT');
            return result;
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
