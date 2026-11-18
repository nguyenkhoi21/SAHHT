import { GodfieldService, godfieldState } from './godfield.service.js';
import { GodfieldLeagueService } from './godfield-league.js';
import { godfieldConfig } from './godfield-source.js';
import { contentReceipt } from './content-receipt.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { readConfigSync } from './local-content.js';
import { calendarParts, calendarZone } from './event-calendar.js';
import { audit } from '../admin/admin.audit.js';
import { auxRewardKind, auxiliaryDefinition } from './auxiliary-state.js';
const fail = (msg) => { throw Object.assign(Error(msg), { statusCode: 422 }); };
const active = (v) => !['0', '-1'].includes(v);
const fingerprint = (p) => [...p].filter(([k]) => !['request_id', 'rans', 'user_token', 'mk', 'method', 'rand'].includes(k)).sort(([a], [b]) => a.localeCompare(b));
export const templeBlockers = [
    'Điểm khởi đầu1600mỗi điện do người dùng xác nhận. SOURCE BLOCKED: chưa có biểu thức thắng/thua và ngưỡng chênh lệch ghép của universe_arena; chưa mở trận có kết toán điểm.',
    'SOURCE BLOCKED: chưa có mốc chốt tuần/xử lý đồng hạng và phân phối thưởng mùa; không tự gửi thưởng BXH.',
    'LOCAL: kỳ tuần dùng lịch thứ2 của server hiện tại; nguồn notice192 chỉ ghi chu kỳ1tuần, chưa ghi ngày đổi kỳ/múi giờ server gốc.',
    'Vinh dự lưu riêng từng điện và giữ qua đổi kỳ; chưa có nguồn reset tiền nên không xóa số dư. Mốc thưởng điểm nhận một lần mỗi điện, chưa tự reset quyền nhận theo mùa.',
];
// Thần Điện hiện dùng universe_arena, không phải god_field_temple đã bỏ trong mainBig.
// Tái sử dụng bảng mode_state schema25 và validator ba đội, không sửa đội Main/Godfield.
export class GodfieldTempleService {
    db;
    now;
    store;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
        this.store = new GodfieldLeagueService(db, now);
    }
    clock() {
        const now = this.now(), p = calendarParts(now), monday = new Date(p.date + 'T00:00:00Z');
        monday.setUTCDate(monday.getUTCDate() - (p.weekday - 1));
        const ranges = Object.values(godfieldConfig('universe_arena'));
        const date = (s) => Date.parse(s.replace(' ', 'T') + '+07:00');
        const windows = [...new Set(ranges.map(r => r.start_time + '|' + r.end_time))].map(s => { const [a, b] = s.split('|'); return { start: a, end: b, active: now >= date(a) && now < date(b) }; });
        return { now, day: p.date, week: monday.toISOString().slice(0, 10), timezone: calendarZone, windows, open: windows.some(w => w.active), weekRule: 'LOCAL lịch thứ2; thiếu mốc đổi tuần server gốc' };
    }
    check(id) { new GodfieldService(this.db).assertUnlocked(id); if (!this.clock().open)
        fail('Thần Điện đang ngoài khoảng thời gian cấu hình Việt Nam.'); }
    raw(id) { return this.store.state(id, 'temple-formation', this.clock().week); }
    visibleState(id, state) {
        const owned = new Set(this.db.prepare('SELECT id FROM player_heroes WHERE user_id=?').all(id).map(r => String(r.id))), out = structuredClone(state);
        for (let t = 1; t <= 3; t++)
            out.god_field_ids[t] = out.god_field_ids[t].map((h) => active(h) && !owned.has(h) ? '-1' : h);
        return out;
    }
    // Chỉ đóng dấu copy/lệnh khóa khi người chơi thật sự mở chế độ hoặc bấm lưu.
    join(id) {
        this.check(id);
        const old = this.raw(id);
        if (old.formation)
            return old;
        const source = new GodfieldService(this.db).packet(id);
        if (!source.is_formation)
            fail('Hãy lưu đủ ba đội Thần Vực trước khi vào Thần Điện.');
        const locks = { '1': [], '2': [], '3': [] };
        for (let t = 1; t <= 3; t++)
            locks[t] = source.god_field_ids[t].filter(active);
        const next = { formation: godfieldState(this.db, id), locks };
        this.store.put(id, 'temple-formation', this.clock().week, next);
        const history = this.store.state(id, 'temple-history', 'permanent', {});
        for (let t = 1; t <= 3; t++) {
            const stats = this.store.state(id, 'temple-team-' + t, this.clock().week);
            if (stats.score === undefined)
                this.store.put(id, 'temple-team-' + t, this.clock().week, { score: 1600, vin_times: 0, fail_times: 0, max_vin_times: 0, max_fail_times: 0, history_score: 1600 });
            history[t] = Math.max(Number(history[t] ?? 0), 1600);
        }
        this.store.put(id, 'temple-history', 'permanent', history);
        audit(this.db, null, 'temple.formation.join', id, 'Sao đội Thần Vực vào kỳ Thần Điện riêng; khóa tướng theo notice192, không chuyển đồ hoặc sửa Main', null, { week: this.clock().week, locks });
        return next;
    }
    transaction(run) { if (this.db.isTransaction)
        return run(); this.db.exec('BEGIN IMMEDIATE'); try {
        const out = run();
        this.db.exec('COMMIT');
        return out;
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    formation(id) { return this.transaction(() => { const row = this.join(id), state = this.visibleState(id, row.formation); return { ...new GodfieldService(this.db).packet(id, state), lock_cards_id: row.locks, cycle: this.clock().week, source_blockers: templeBlockers }; }); }
    run(s, method, p, fn) {
        return contentReceipt(this.db, s.user_id, method, p.get('request_id'), fingerprint(p), () => { this.check(s.user_id); const out = fn(); audit(this.db, null, method, s.user_id, 'Thần Điện: chi phí/đồ nguồn, nonce và state độc lập', null, { requestId: p.get('request_id') }); return out; }, old => ({ ...old, replayed: true, reward: [], _client_cache_update: undefined }));
    }
    save(s, p) {
        return this.run(s, 'universe_arena.set_god_field', p, () => {
            const row = this.join(s.user_id), next = new GodfieldService(this.db).updatedState(s, p, this.visibleState(s.user_id, row.formation));
            for (let t = 1; t <= 3; t++)
                for (const h of next.god_field_ids[t].filter(active))
                    for (let other = 1; other <= 3; other++)
                        if (other !== t && row.locks[other].includes(h))
                            fail('Tướng đã thuộc đội' + other + ' Thần Điện trong kỳ này; tháo ra không mở khóa chuyển đội.');
            // notice192.8: Anh Hồn/Đá Thánh/Huy Chương có tác dụng trong trận nhưng không đổi tại đây.
            for (const k of ['soul', 'god_stone', 'medal'])
                for (let t = 1; t <= 3; t++)
                    if (JSON.stringify(next[k + '_pos_' + t]) !== JSON.stringify(row.formation[k + '_pos_' + t]))
                        fail('Không thay ' + k + ' trong Thần Điện; hệ này kế thừa bản sao lúc tham gia.');
            const locks = structuredClone(row.locks);
            for (let t = 1; t <= 3; t++)
                locks[t] = [...new Set([...locks[t], ...next.god_field_ids[t].filter(active)])];
            this.store.put(s.user_id, 'temple-formation', this.clock().week, { formation: next, locks });
            return this.formation(s.user_id);
        });
    }
    team(n) { if (!/^[123]$/.test(String(n)))
        fail('Đấu trường Thần Điện phải là1,2hoặc3.'); return Number(n); }
    stats(id, t) { const state = this.store.state(id, 'temple-team-' + t, this.clock().week, { score: null, vin_times: 0, fail_times: 0, max_vin_times: 0, max_fail_times: 0, history_score: 0 }); return { ...state, grade_score: this.store.state(id, 'temple-honor', 'permanent', {})[t] ?? 0 }; }
    people(t) { return this.db.prepare("SELECT m.user_id,m.state,p.game_uid,s.profile FROM godfield_mode_state m JOIN player_profiles p ON p.user_id=m.user_id JOIN player_state s ON s.user_id=m.user_id WHERE m.mode=? AND m.period=?").all('temple-team-' + t, this.clock().week).flatMap(r => { const v = JSON.parse(String(r.state)); return typeof v.score === 'number' ? [{ id: Number(r.user_id), uid: String(r.game_uid), name: JSON.parse(String(r.profile)).show_name, score: v.score }] : []; }).sort((a, b) => b.score - a.score || a.id - b.id); }
    ranks(id) { this.check(id); const out = {}; for (let t = 1; t <= 3; t++) {
        const list = this.people(t);
        out[t] = { rank_infos: list.map(({ id, ...r }, i) => ({ ...r, rank: i + 1 })), my_rank: list.findIndex(r => r.id === id) + 1 };
    } out.all = { rank_infos: [], my_rank: 0, source_blocker: 'Chưa có công thức tổng xếp hạng ba đấu trường; không tự cộng điểm/hạng thay thế.' }; return { ...out, source_blockers: templeBlockers }; }
    index(id) { const f = this.formation(id), r = this.ranks(id), occupant = {}, team_ranks = {}; for (let t = 1; t <= 3; t++) {
        const top = r[t].rank_infos[0];
        occupant[t] = top ? { name: top.name, u_id: top.uid } : {};
        team_ranks[t] = r[t].my_rank || 'Chưa tham gia';
    } return { ...f, occupant, team_ranks, all_rank: r.all.my_rank, history_rank: 0, clock: this.clock() }; }
    teamIndex(id, n) { const t = this.team(n), f = this.formation(id), v = this.stats(id, t); return { ...v, my_score: v.score ?? 0, score_established: v.score !== null, my_rank: this.ranks(id)[t].my_rank, god_field_ids: f.god_field_ids[t], combat: f['god_combat_' + t], team_id: t, source_blockers: templeBlockers }; }
    rewards(id) { this.check(id); const history = this.store.state(id, 'temple-history', 'permanent', {}), claims = this.store.state(id, 'temple-claims', 'permanent', {}); return { team_history_score: Object.fromEntries([1, 2, 3].map(t => [t, history[t] ?? 0])), rank_reward: Object.fromEntries([1, 2, 3].map(t => [t, claims[t] ?? {}])) }; }
    claim(s, p) {
        return this.run(s, 'universe_arena.get_reward', p, () => {
            const t = this.team(p.get('team_id')), key = p.get('reward_id') ?? '', r = godfieldConfig('universe_arena_grade')[key];
            if (!r?.reward?.length)
                fail('Mốc này không có phần thưởng nguồn.');
            const state = this.rewards(s.user_id);
            if (state.team_history_score[t] < r.score[0])
                fail('Chưa đạt điểm lịch sử nhận thưởng.');
            if (state.rank_reward[t][key])
                fail('Mốc thưởng này đã nhận.');
            const out = grantGodfieldReward(this.db, s, r.reward);
            state.rank_reward[t][key] = true;
            this.store.put(s.user_id, 'temple-claims', 'permanent', state.rank_reward);
            return { ...this.rewards(s.user_id), ...out };
        });
    }
    period(refresh) { const c = this.clock(); if (refresh === 1)
        return c.day; if (refresh === 2)
        return c.week; if (refresh === 3)
        return c.day.slice(0, 7); return fail('Thiếu quy tắc reset cửa hàng Thần Điện.'); }
    shop(id) { this.check(id); const exchange_log = {}, grade_score = {}; for (let t = 1; t <= 3; t++) {
        grade_score[t] = this.stats(id, t).grade_score;
        exchange_log[t] = {};
        for (const [key, r] of Object.entries(godfieldConfig('universe_arena_shop')))
            exchange_log[t][key] = { times: this.store.state(id, 'temple-shop-' + t, this.period(r.refresh), {})[key] ?? 0 };
    } return { exchange_log, grade_score }; }
    buy(s, p) {
        return this.run(s, 'universe_arena.buy_goods', p, () => {
            this.join(s.user_id);
            const t = this.team(p.get('team_id')), key = p.get('goods_id') ?? '', r = godfieldConfig('universe_arena_shop')[key], cost = Number(r?.['arena_' + t]);
            if (!r || !Number.isSafeInteger(cost) || cost <= 0)
                fail('Mặt hàng không bán trong đấu trường đã chọn.');
            for (const [type, cid] of r.reward)
                if (type === 6 && !readConfigSync('item')[cid])
                    fail('Thiếu định nghĩa item#' + cid + ' trong nguồn Việt Nam; chưa trừ vinh dự.');
            const period = this.period(r.refresh), v = this.stats(s.user_id, t), bought = this.store.state(s.user_id, 'temple-shop-' + t, period, {}), n = Number(bought[key] ?? 0);
            if (r.times !== -1 && n >= r.times)
                fail('Đã hết lượt đổi mặt hàng trong kỳ.');
            if (v.grade_score < cost)
                fail('Không đủ vinh dự của đấu trường' + t + '.');
            const out = grantGodfieldReward(this.db, s, r.reward);
            const purse = this.store.state(s.user_id, 'temple-honor', 'permanent', {});
            purse[t] = v.grade_score - cost;
            bought[key] = n + 1;
            this.store.put(s.user_id, 'temple-honor', 'permanent', purse);
            this.store.put(s.user_id, 'temple-shop-' + t, period, bought);
            return { ...this.shop(s.user_id), ...out };
        });
    }
    battle(_s, _p) { return fail('Chưa có công thức ghép/cộng trừ điểm Thần Điện được xác minh; chưa khởi tạo trận hoặc tiêu vinh dự.'); }
    logs(id, n) { const t = this.team(n), v = this.stats(id, t); return { ...v, score: v.score ?? 0, rank: this.ranks(id)[t].my_rank, battle_tips: [], source_blockers: templeBlockers }; }
    heroes() { return { info: [], phase: 1, source_blocker: 'Bảng quán quân kỳ trước chỉ có sau kết toán mùa đã xác minh; chưa tạo người thắng giả.' }; }
    catalog() { const items = readConfigSync('item'), heroes = readConfigSync('character_detail'); return Object.entries(godfieldConfig('universe_arena_shop')).map(([id, r]) => ({ id, prices: [r.arena_1, r.arena_2, r.arena_3], limit: r.times, refresh: r.refresh, sourceBlocked: r.reward.some(([type, cid]) => type === 6 && !items[cid]) ? 'Thiếu định nghĩa item#' + r.reward.find(([type, cid]) => type === 6 && !items[cid])[1] : null, rewards: r.reward.map(([type, configId, quantity]) => ({ type, configId, quantity, name: type === 5 ? heroes[configId]?.name : type === 6 ? items[configId]?.name : auxRewardKind(type) ? (auxiliaryDefinition(auxRewardKind(type), configId).talisman_name ?? auxiliaryDefinition(auxRewardKind(type), configId).name) : 'Vật phẩm tiến trình nguồn #' + configId })) })); }
    diagnostics(id) { const row = this.raw(id), clock = this.clock(); return { clock, joined: !!row.formation, locks: row.locks ?? {}, teams: row.formation ? new GodfieldService(this.db).packet(id, this.visibleState(id, row.formation)) : null, shop: clock.open ? this.shop(id) : null, rewards: clock.open ? this.rewards(id) : null, ranks: clock.open ? this.ranks(id) : null, catalog: this.catalog(), blockers: templeBlockers }; }
    prepareQa(adminId, id, key, n, amount) { if (process.env.APP_ENV === 'online')
        fail('Không cấp QA Thần Điện trên ONLINE.'); const t = this.team(n); if (!Number.isSafeInteger(amount) || amount < 0 || amount > 10000)
        fail('Vinh dự QA từ0đến10000.'); return contentReceipt(this.db, id, 'temple.qa.honor', key, { t, amount }, () => { this.check(id); const v = this.store.state(id, 'temple-honor', 'permanent', {}); v[t] = (v[t] ?? 0) + amount; this.store.put(id, 'temple-honor', 'permanent', v); audit(this.db, adminId, 'temple.qa.honor', id, 'LOCAL: cộng vinh dự để kiểm cửa hàng; không đặt điểm/hạng/lực chiến', null, { t, amount }); return this.shop(id); }, () => ({ ...this.shop(id), replayed: true })); }
}
