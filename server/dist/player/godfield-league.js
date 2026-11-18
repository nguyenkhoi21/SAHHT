import { randomBytes, randomUUID } from 'node:crypto';
import { GodfieldService, godfieldState } from './godfield.service.js';
import { godfieldThreeRounds } from './godfield-battle.js';
import { godfieldConfig } from './godfield-source.js';
import { calendarParts, calendarZone } from './event-calendar.js';
import { contentReceipt } from './content-receipt.js';
import { PlayerService } from './player.service.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { readConfigSync } from './local-content.js';
import { audit } from '../admin/admin.audit.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
const clean = (p) => [...p].filter(([k]) => !['request_id', 'rans', 'user_token', 'mk', 'method', 'rand'].includes(k)).sort(([a], [b]) => a.localeCompare(b));
export const godfieldLeagueAdapters = { groups: 'LOCAL được người dùng duyệt: xếp tổng lực chiến Thần Vực, tối đa11 tài khoản thật/nhóm; không phải thuật toán ghép server gốc.', points: 'LOCAL được người dùng duyệt: điểm thắng lấy combat_int theo ngưỡng lực chiến đối thủ. Bảng8–18 khác hướng dẫn cũ5–10; chưa xác minh công thức server gốc.', lateEntries: 'LOCAL: tài khoản đủ điều kiện vào sau được nối cuối nhóm gần lực chiến còn chỗ; vị trí đối thủ cũ không đổi trong kỳ.', combat: 'Tái sử dụng engine LOCAL hiện có, ba trận độc lập theo notice167 và consumer kết quả; không giả thắng theo lực chiến.' };
export class GodfieldLeagueService {
    db;
    realNow;
    seed;
    constructor(db, realNow = Date.now, seed = () => randomBytes(4).readUInt32LE()) {
        this.db = db;
        this.realNow = realNow;
        this.seed = seed;
    }
    now() { const q = this.db.prepare("SELECT starts_at FROM local_activity_settings WHERE activity_id='than-vuc:clock' AND enabled=1").get(); return process.env.APP_ENV !== 'online' && q ? Number(q.starts_at) : this.realNow(); }
    clock() { const now = this.now(), p = calendarParts(now), stamp = new Date(now + 7 * 3600000), seconds = stamp.getUTCHours() * 3600 + stamp.getUTCMinutes() * 60 + stamp.getUTCSeconds(), cfg = godfieldConfig('god_field_time')['1']; const sec = (s) => s.split(':').map(Number).reduce((n, v, i) => n + v * [3600, 60, 1][i], 0), start = sec(cfg.start_time), end = sec(cfg.end_time), boundaries = [cfg.start_time, cfg.refresh_time1, cfg.refresh_time2].map(sec).sort((a, b) => a - b), window = boundaries.filter(x => x <= seconds).at(-1) ?? start, next = boundaries.find(x => x > seconds) ?? end, week = new Date(p.date + 'T00:00:00Z'); week.setUTCDate(week.getUTCDate() - (p.weekday - 1)); return { now, day: p.date, weekday: p.weekday, week: week.toISOString().slice(0, 10), phase: p.weekday <= 5 ? 1 : p.weekday === 6 ? 2 : 3, open: p.weekday <= 5 && seconds >= start && seconds < end, window: p.date + '@' + window, nextRefresh: Math.max(0, next - seconds), timezone: calendarZone, simulated: process.env.APP_ENV !== 'online' && !!this.db.prepare("SELECT 1 FROM local_activity_settings WHERE activity_id='than-vuc:clock' AND enabled=1").get() }; }
    state(id, mode, period, defaults = {}) { const r = this.db.prepare('SELECT state FROM godfield_mode_state WHERE user_id=? AND mode=? AND period=?').get(id, mode, period); return r ? JSON.parse(String(r.state)) : structuredClone(defaults); }
    put(id, mode, period, state) { this.db.prepare('INSERT INTO godfield_mode_state VALUES(?,?,?,?,?) ON CONFLICT(user_id,mode,period) DO UPDATE SET state=excluded.state,updated_at=excluded.updated_at').run(id, mode, period, JSON.stringify(state), this.realNow()); }
    balance(id) { const c = this.clock(), d = this.state(id, 'league', c.day, { integration: 0 }), w = this.state(id, 'league-week', c.week, { god_integration: 0, ticket: false }); return { integration: Number(d.integration ?? 0), god_integration: Number(w.god_integration ?? 0), ticket: w.ticket === true }; }
    ready(id) { new GodfieldService(this.db).assertUnlocked(id); if (!new GodfieldService(this.db).packet(id).is_formation)
        fail('Hãy lưu tướng chính cho đủ ba đội Thần Vực trước.'); }
    pool() { return this.db.prepare('SELECT g.user_id,p.game_uid,p.role,s.profile FROM godfield_formations g JOIN player_profiles p ON p.user_id=g.user_id JOIN player_state s ON s.user_id=g.user_id').all().flatMap(r => { const p = JSON.parse(String(r.profile)); if ((p.level ?? 1) < 100)
        return []; const god = new GodfieldService(this.db).packet(Number(r.user_id)); return god.is_formation ? [{ id: Number(r.user_id), uid: String(r.game_uid), name: p.show_name ?? '', role: Number(r.role), level: p.level ?? 1, combat: god.god_combat }] : []; }).sort((a, b) => b.combat - a.combat || a.id - b.id); }
    group(id) {
        const run = () => {
            const period = this.clock().window, pool = this.pool(), groups = this.db.prepare('SELECT group_id,members FROM godfield_competition_groups WHERE period=? ORDER BY group_id').all(period).map(r => ({ id: Number(r.group_id), members: JSON.parse(String(r.members)) })), assigned = new Set(groups.flatMap(g => g.members));
            for (const p of pool)
                if (!assigned.has(p.id)) {
                    let g = groups.filter(g => g.members.length < 11).sort((a, b) => Math.abs((pool.find(p => p.id === a.members[0])?.combat ?? 0) - p.combat) - Math.abs((pool.find(p => p.id === b.members[0])?.combat ?? 0) - p.combat) || a.id - b.id)[0];
                    if (!g) {
                        g = { id: (groups.at(-1)?.id ?? 0) + 1, members: [] };
                        groups.push(g);
                    }
                    g.members.push(p.id);
                    assigned.add(p.id);
                    this.db.prepare('INSERT INTO godfield_competition_groups VALUES(?,?,?,?) ON CONFLICT(period,group_id) DO UPDATE SET members=excluded.members').run(period, g.id, JSON.stringify(g.members), this.realNow());
                }
            const own = groups.find(g => g.members.includes(id));
            return { period, id: own?.id ?? 0, members: own?.members ?? [], opponents: (own?.members ?? []).filter(n => n !== id) };
        };
        if (this.db.isTransaction)
            return run();
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const r = run();
            this.db.exec('COMMIT');
            return r;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    index(id, online = false) { const c = { ...this.clock(), open: online || process.env.APP_ENV === 'online' ? false : this.clock().open }, god = new GodfieldService(this.db).index(id), balance = this.balance(id), g = god.is_formation && c.open ? this.group(id) : { opponents: [], period: c.window, id: 0, members: [] }, wins = this.db.prepare("SELECT target_user_id,metadata FROM godfield_matches WHERE user_id=? AND mode='league' AND period=?").all(id, g.period).filter(r => JSON.parse(String(r.metadata)).won), out = { ...god, status: c.open ? 1 : 0, weekday: c.phase, is_enter: balance.ticket, score: balance.integration, win_sort: g.opponents.flatMap((n, i) => wins.some(w => Number(w.target_user_id) === n) ? [i] : []), alignment: god.god_field_ids, time_count_down: c.open ? c.nextRefresh : 0, formation_battle_order: this.state(id, 'league-settings', 'permanent', { order: [1, 2, 3] }).order, local_schedule: { ...c, weekendBlocker: 'Vòng loại/thể thức tự động32 người cuối tuần đang đối chiếu; chưa mở hoặc cấp thưởng giả.' } }; for (let i = 0; i < 10; i++)
        out['enemy_' + i] = g.opponents[i] !== undefined && wins.some(w => Number(w.target_user_id) === g.opponents[i]) ? 0 : -1; return out; }
    target(id, p) { const text = p.get('sort') ?? '', sort = Number(text); if (!/^[0-9]$/.test(text))
        fail('Ô đối thủ không hợp lệ.'); const g = this.group(id), other = g.opponents[sort]; if (!other)
        fail('Ô này chưa có đối thủ thật đủ ba đội; không tạo tài khoản giả.'); if (other === id)
        fail('Không thể tự khiêu chiến.'); this.ready(other); return { sort, other, group: g }; }
    visible(id) { const r = this.db.prepare('SELECT p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?').get(id); if (!r)
        fail('Đối thủ không tồn tại.'); const p = JSON.parse(String(r.profile)); return { uid: String(r.game_uid), role: Number(r.role), name: p.show_name ?? '', level: p.level ?? 1, server_name: 'SAHHT LOCAL' }; }
    alignment(id) { const cards = new PlayerService(this.db).cards({ user_id: id }), state = godfieldState(this.db, id); return Object.fromEntries([1, 2, 3].map(t => [t, state.god_field_ids[t].filter((n) => !['0', '-1'].includes(n)).map((n) => cards.cards[n])])); }
    pointPreview(target) { const power = new GodfieldService(this.db).packet(target).god_combat, row = Object.entries(godfieldConfig('god_field_team')).find(([, r]) => r.combat_down <= power && power <= r.combat_up); if (!row)
        fail('Không có combat_int cho ngưỡng lực chiến đối thủ; chưa cộng điểm.'); return { tier: row[0], power, points: Number(row[1].combat_int), evidence: godfieldLeagueAdapters.points }; }
    enemy(id, p) { this.ready(id); if (!this.clock().open)
        fail('Đấu Tranh Bá tích điểm chỉ mở thứ2–6 theo giờ nguồn.'); const { other, group } = this.target(id, p), own = new GodfieldService(this.db).packet(id), enemy = new GodfieldService(this.db).packet(other), history = this.db.prepare("SELECT metadata FROM godfield_matches WHERE user_id=? AND target_user_id=? AND mode='league'").all(id, other), won = history.filter(r => JSON.parse(String(r.metadata)).won).length; return { ...this.visible(other), ...own, match_period: group.period, combat: enemy.god_combat, enemy_god_combat_1: enemy.god_combat_1, enemy_god_combat_2: enemy.god_combat_2, enemy_god_combat_3: enemy.god_combat_3, alignment: own.god_field_ids, alignment_info: this.alignment(other), formation_battle_order: this.state(id, 'league-settings', 'permanent', { order: [1, 2, 3] }).order, score: this.pointPreview(other).points, win_per: history.length ? won / history.length : 0 }; }
    execute(s, method, p, run) { return contentReceipt(this.db, s.user_id, method, p.get('request_id'), clean(p), () => { this.ready(s.user_id); const result = run(); audit(this.db, null, method, s.user_id, 'Thần Vực: lịch nguồn, transaction/nonce; adapter LOCAL ghi rõ', null, { requestId: p.get('request_id') }); return result; }, old => ({ ...old, replayed: true, reward: [], _client_cache_update: undefined })); }
    order(s, p) { return this.execute(s, 'god_field.update_battle_order', p, () => { const v = p.getAll('formation').flatMap(v => v.split('_')).map(Number); if (v.length !== 3 || v.slice().sort().join(',') !== '1,2,3')
        fail('Thứ tự đội phải gồm1,2,3 mỗi số một lần.'); this.put(s.user_id, 'league-settings', 'permanent', { order: v }); return { formation_battle_order: v }; }); }
    battle(s, p) {
        return this.execute(s, 'god_field.god_field_battle', p, () => {
            const c = this.clock();
            if (!c.open)
                fail('Ngoài giờ Đấu Tranh Bá tích điểm; chưa tiêu lượt hoặc tài nguyên.');
            const { other, group } = this.target(s.user_id, p);
            if (p.get('group_period') !== group.period || p.get('target_uid') !== this.visible(other).uid)
                fail('Nhóm/đối thủ đã đổi; mở lại khung đối thủ trước khi đánh.');
            if (this.db.prepare("SELECT 1 FROM godfield_matches WHERE user_id=? AND target_user_id=? AND mode='league' AND period=? AND json_extract(metadata,'$.won')=1").get(s.user_id, other, group.period))
                fail('Đã thắng đối thủ trong lượt ghép này; chờ làm mới theo lịch nguồn.');
            const point = this.pointPreview(other), seed = this.seed(), order = this.state(s.user_id, 'league-settings', 'permanent', { order: [1, 2, 3] }).order, sim = godfieldThreeRounds(this.db, s.user_id, other, order, seed), a = this.visible(s.user_id), d = this.visible(other), id = 'godmatch-' + randomUUID(), delta = sim.won ? point.points : -2, state = this.state(s.user_id, 'league', c.day, { integration: 0 });
            state.integration = Number(state.integration ?? 0) + delta;
            this.put(s.user_id, 'league', c.day, state);
            const logs = sim.rounds.map((r, i) => ({ attacker: a.name, defender: d.name, attacker_role: a.role, defender_role: d.role, is_win: r.winner === 0 ? 1 : 0, battle_log: id + ':' + i, attack_team: r.attackTeam, defend_team: r.defendTeam })), packet = { log_dict: { log_list: logs, final_win: sim.won ? 1 : 0 }, reward: [], alignment_info: this.alignment(other), god_field_ids: godfieldState(this.db, s.user_id).god_field_ids, score: state.integration, score_change: delta, match_id: id }, metadata = { won: sim.won, wins: sim.wins, seed, order, point, adapters: godfieldLeagueAdapters, rounds: sim.rounds.map(r => ({ winner: r.winner, rounds: r.rounds, aPower: r.aPower, dPower: r.dPower, lifeEvents: r.lifeEvents, diagnostics: r.diagnostics })), replays: sim.rounds.map(r => ({ battle: r.battle, reward: {}, battle_rewards: { reward_exp_player: [], reward_exp_character: {}, reward_character: {}, reward_item: {} } })) };
            this.db.prepare('INSERT INTO godfield_matches VALUES(?,?,?,?,?,?,?,?,?)').run(id, s.user_id, other, 'league', group.period, p.get('request_id'), JSON.stringify(packet), JSON.stringify(metadata), this.realNow());
            return packet;
        });
    }
    replay(id, key) { if (typeof key !== 'string' || !/^godmatch-[a-f0-9-]+:[012]$/.test(key))
        fail('Mã xem lại trận không hợp lệ.'); const [match, n] = String(key).split(':'), row = this.db.prepare('SELECT metadata FROM godfield_matches WHERE id=? AND (user_id=? OR target_user_id=?)').get(match, id, id); if (!row)
        fail('Không có quyền xem trận này.'); return JSON.parse(String(row.metadata)).replays[Number(n)]; }
    ticket(s, p) { return this.execute(s, 'god_field.buy_ship_ticket', p, () => { const c = this.clock(); if (!c.open)
        fail('Vé được mua trong giờ tích điểm thứ2–6.'); const week = this.state(s.user_id, 'league-week', c.week, { god_integration: 0, ticket: false }); if (week.ticket)
        fail('Đã mua vé cho tuần này.'); const day = this.state(s.user_id, 'league', c.day, { integration: 0 }), price = Number(godfieldConfig('god_field_time')['1'].cost); if (day.integration < price)
        fail('Không đủ điểm Thần Vực mua vé.'); day.integration -= price; week.ticket = true; this.put(s.user_id, 'league', c.day, day); this.put(s.user_id, 'league-week', c.week, week); return { is_enter: true, score: day.integration, price }; }); }
    shopPeriod(refresh) { const c = this.clock(); if (refresh === 1)
        return c.day; if (refresh === 2)
        return c.week; if (refresh === 3)
        return c.day.slice(0, 7); return fail('Chưa có quy tắc reset cửa hàng #' + refresh); }
    shop(id) { const balance = this.balance(id), exchange_reward = {}; for (const [k, r] of Object.entries(godfieldConfig('god_field_exchange')))
        exchange_reward[k] = this.state(id, 'league-shop', this.shopPeriod(r.refresh), {})[k] ?? 0; return { ...balance, cur_score: balance.integration, exchange_reward }; }
    exchange(s, p) {
        return this.execute(s, 'god_field.exchange', p, () => {
            const key = p.get('exchange_id') ?? '', row = godfieldConfig('god_field_exchange')[key];
            if (!row)
                fail('Mặt hàng Thần Vực không có trong nguồn.');
            const profile = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile));
            if (profile.level < row.show_level[0] || profile.level > row.show_level[1])
                fail('Chưa đủ cấp đổi vật phẩm.');
            const c = this.clock(), period = this.shopPeriod(row.refresh), bought = this.state(s.user_id, 'league-shop', period, {}), n = Number(bought[key] ?? 0);
            if (row.times !== -1 && n >= row.times)
                fail('Đã hết lượt đổi trong kỳ.');
            const day = this.state(s.user_id, 'league', c.day, { integration: 0 }), week = this.state(s.user_id, 'league-week', c.week, { god_integration: 0, ticket: false });
            if ((row.cost2 > 0 && day.integration < row.cost2) || (row.cost1 > 0 && week.god_integration < row.cost1))
                fail('Không đủ điểm/Xu Thần Vực theo giá nguồn.');
            const rewards = grantGodfieldReward(this.db, s, row.reward);
            day.integration -= row.cost2;
            week.god_integration -= row.cost1;
            bought[key] = n + 1;
            this.put(s.user_id, 'league', c.day, day);
            this.put(s.user_id, 'league-week', c.week, week);
            this.put(s.user_id, 'league-shop', period, bought);
            return { ...rewards, ...this.shop(s.user_id), exchange_id: key, period };
        });
    }
    top() { const c = this.clock(), rows = this.db.prepare("SELECT m.user_id,m.state,p.game_uid,p.role,s.profile FROM godfield_mode_state m JOIN player_profiles p ON p.user_id=m.user_id JOIN player_state s ON s.user_id=m.user_id WHERE m.mode='league' AND m.period=?").all(c.day).map(r => { const p = JSON.parse(String(r.profile)); return { userId: Number(r.user_id), uid: String(r.game_uid), name: p.show_name, level: p.level, role: Number(r.role), server_name: 'SAHHT LOCAL', score: Number(JSON.parse(String(r.state)).integration ?? 0) }; }).sort((a, b) => b.score - a.score || a.userId - b.userId); return { god_integration_rank: Object.fromEntries(rows.map(({ userId, ...r }, i) => [i + 1, r])) }; }
    history(id) { return this.db.prepare("SELECT id,created_at,packet,metadata FROM godfield_matches WHERE (user_id=? OR target_user_id=?) AND mode='league' ORDER BY created_at DESC LIMIT 30").all(id, id).map(r => ({ id: r.id, created_at: r.created_at, ...JSON.parse(String(r.packet)), diagnostics: JSON.parse(String(r.metadata)).rounds })); }
    catalog() { const heroes = readConfigSync('character_detail'), items = readConfigSync('item'); return Object.entries(godfieldConfig('god_field_exchange')).map(([id, r]) => ({ id, costPoints: r.cost2, costCoins: r.cost1, limit: r.times, refresh: r.refresh, level: r.show_level, rewards: r.reward.map(([type, configId, quantity]) => ({ type, configId, quantity, name: type === 5 ? heroes[configId]?.name : type === 6 ? items[configId]?.name : type === 43 ? 'Đá Vận Mệnh Siêu Cấp' : 'Tài nguyên #' + type, icon: type === 5 || type === 6 ? `/admin/api/than-vuc/icon/${type}/${configId}` : null, attachment: type === 5 ? { kind: 'hero', configId, quantity } : type === 6 ? { kind: 'item', configId, quantity } : type === 43 ? { kind: 'currency', currency: 'max_fate_stone', quantity } : null })) })); }
    diagnostics(id) { return { clock: this.clock(), balance: this.balance(id), shop: this.shop(id), catalog: this.catalog(), history: this.history(id), groups: this.db.prepare('SELECT period,group_id,members FROM godfield_competition_groups ORDER BY created_at DESC LIMIT 20').all(), adapters: godfieldLeagueAdapters, blocked: ['Vòng loại thứ7/ngoại vực chủ nhật và phát thưởng top32 chưa có kết toán tự động đã xác minh.', 'Không đổi/ngầm reset Arena, Main formation, tài nguyên hoặc ngân sách Hồi Sinh sở hữu.'] }; }
    setQaClock(adminId, at) { if (process.env.APP_ENV === 'online')
        fail('Không cho phép mô phỏng thời gian trên ONLINE.'); if (at !== null && (!Number.isSafeInteger(at) || at < Date.UTC(2020, 0, 1) || at > Date.UTC(2100, 0, 1)))
        fail('Mốc thời gian QA không hợp lệ.'); const before = this.clock(); this.db.exec('BEGIN IMMEDIATE'); try {
        if (at === null)
            this.db.prepare("DELETE FROM local_activity_settings WHERE activity_id='than-vuc:clock'").run();
        else
            this.db.prepare("INSERT INTO local_activity_settings VALUES('than-vuc:clock',1,?,?) ON CONFLICT(activity_id) DO UPDATE SET enabled=1,starts_at=excluded.starts_at,ends_at=excluded.ends_at").run(at, at + 1);
        audit(this.db, adminId, 'godfield.qa.clock', null, 'LOCAL QA: khóa thời gian riêng Đấu Tranh Bá; không đổi đồng hồ hay lịch hệ khác', before, { at });
        this.db.exec('COMMIT');
        return this.clock();
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    prepareQa(adminId, id, key, integration, godIntegration) { if (process.env.APP_ENV === 'online')
        fail('Không cấp tài nguyên QA Thần Vực trên ONLINE.'); new GodfieldService(this.db).assertUnlocked(id); if ([integration, godIntegration].some(n => !Number.isSafeInteger(n) || n < 0 || n > 10000))
        fail('Mỗi loại tài nguyên QA tối đa10.000.'); return contentReceipt(this.db, id, 'godfield.qa.resources', key, { integration, godIntegration }, () => { const c = this.clock(), before = this.balance(id), d = this.state(id, 'league', c.day, { integration: 0 }), w = this.state(id, 'league-week', c.week, { god_integration: 0, ticket: false }); d.integration += integration; w.god_integration += godIntegration; this.put(id, 'league', c.day, d); this.put(id, 'league-week', c.week, w); audit(this.db, adminId, 'godfield.qa.resources', id, 'LOCAL QA: cộng điểm/Xu thật vào state chế độ để kiểm chi phí; không cấp tự động', before, this.balance(id)); return this.balance(id); }, () => ({ ...this.balance(id), replayed: true })); }
}
