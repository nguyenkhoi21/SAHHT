import { AetherEconomy } from './aether-economy.js';
import { AetherScience } from './aether-science.js';
import { aetherGroupScores } from './aether-score.js';
import { simEnabled, simPolicy, simGet } from './aether-sim-policy.js';
import { AetherSimulation, simReads, simWrites } from './aether-simulation.js';
import { AetherSimObjectives } from './aether-sim-objectives.js';
import { aetherConfig, aetherPhase, aetherSource, aetherEvent } from './aether-source.js';
import { AllianceService } from './alliance.service.js';
import { GodfieldService, godfieldState, godfieldTeam } from './godfield.service.js';
import { PlayerService } from './player.service.js';
import { contentReceipt } from './content-receipt.js';
import { audit } from '../admin/admin.audit.js';
import { phase36Config } from './phase36-source.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export const aetherMissing = () => aetherSource().blockers;
export class AetherService {
    db;
    now;
    realm;
    constructor(db, now = () => Date.now(), realm = 'local-1') {
        this.db = db;
        this.now = now;
        this.realm = realm;
    }
    event() { return aetherEvent(this.db, this.now(), this.realm); }
    time(e) { return e.qa ? Number(e.qa_time) + (this.now() - Number(e.qa_updated)) : this.now(); }
    phase(e = this.event()) { return aetherPhase(e.start_at, e.end_at, this.time(e)); }
    groups(e = this.event()) { return Object.values(aetherConfig('group')).filter((r) => r.version === e.version); }
    simulation(e = this.event()) {
        const host = { index: (id) => this.index(id, e), group: (id) => this.participant(id, e), person: (id) => this.person(id, e), state: (id) => this.state(id, e), alignment: (id) => this.alignment(id, id, e), map: (id, g) => this.map(id, g, e), time: () => this.time(e), day: () => this.day(e), phase: () => this.phase(e) };
        return { core: new AetherSimulation(this.db, e, host, this.now), objectives: new AetherSimObjectives(this.db, e, host, this.now) };
    }
    member(id) { return new AllianceService(this.db).member(id) ?? fail('Bạn cần có Liên Minh để tham gia Aether.'); }
    guild(id) { return this.db.prepare('SELECT * FROM alliances WHERE id=? AND closed_at IS NULL').get(id) ?? fail('Liên Minh không tồn tại.'); }
    actor(id) { const m = this.member(id); if (!['owner', 'vp'].includes(m.role))
        fail('Chỉ Hội trưởng/Phó hội trưởng có quyền thao tác.'); return m; }
    ownGuild(id, e = this.event()) { const hired = this.db.prepare("SELECT guild_id FROM aether_mercenaries WHERE event_id=? AND user_id=? AND status='active'").get(e.id, id); return Number(hired?.guild_id ?? this.member(id).alliance_id); }
    enrollment(gid, e = this.event()) { return this.db.prepare('SELECT * FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, gid) ?? fail('Liên Minh chưa được chọn vào mùa này; không tự bốc thăm giả.'); }
    participant(id, e = this.event()) { const gid = this.ownGuild(id, e); return this.enrollment(gid, e); }
    profile(id) { const r = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id); return r ? JSON.parse(String(r.profile)) : fail('Nhân vật chưa vào game.'); }
    person(id, e = this.event()) { const p = this.profile(id), r = this.db.prepare('SELECT game_uid,role FROM player_profiles WHERE user_id=?').get(id); return { uid: r.game_uid, role: r.role, name: p.show_name, level: p.level, combat: new GodfieldService(this.db).packet(id, this.state(id, e)).god_combat }; }
    uid(raw) { const r = this.db.prepare('SELECT user_id FROM player_profiles WHERE game_uid=?').get(raw ?? ''); return r ? Number(r.user_id) : fail('Người chơi không thuộc máy chủ này.'); }
    capacity(gid, e) {
        const g = this.guild(gid), p = this.enrollment(gid, e), group = this.groups(e).find(r => r.group_id === p.group_id);
        const count = Number(this.db.prepare('SELECT count(*) n FROM alliance_members WHERE alliance_id=?').get(gid).n);
        // Trần hội nguồn và trần lính mùa độc lập, không thay membership gốc.
        const max = Number(phase36Config('guild_level')[g.level]?.member_num ?? count);
        return Math.max(0, Math.min(group.hire_limit, max - count));
    }
    employWindow(e) { const phase = this.phase(e); if (phase.step !== 1 || phase.next - this.time(e) <= 3600000)
        fail('Chỉ tuyển trong Dự Cáo, trước giờ chốt ít nhất một tiếng.'); }
    state(id, e = this.event()) { const row = this.db.prepare('SELECT state FROM aether_formations WHERE event_id=? AND user_id=?').get(e.id, id); const state = row ? JSON.parse(String(row.state)) : godfieldState(this.db, id), owned = new Set(this.db.prepare('SELECT id FROM player_heroes WHERE user_id=?').all(id).map(r => String(r.id))); for (const team of Object.values(state.god_field_ids))
        for (let n = 0; n < team.length; n++)
            if (!['0', '-1'].includes(team[n]) && !owned.has(team[n]))
                team[n] = '-1'; return state; }
    ensure(e) { this.db.prepare('INSERT OR IGNORE INTO aether_events(id,realm_id,version,start_at,end_at,qa) VALUES(?,?,?,?,?,?)').run(e.id, e.realm_id, e.version, e.start_at, e.end_at, e.qa); }
    army(gid, e) { const ids = this.db.prepare("SELECT user_id FROM alliance_members WHERE alliance_id=? UNION SELECT user_id FROM aether_mercenaries WHERE event_id=? AND guild_id=? AND status='active'").all(gid, e.id, gid); return ids.map(r => Number(r.user_id)); }
    guildScore(gid, e) { return this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND owner_id=?').all(e.id, gid).reduce((n, r) => n + Number(aetherConfig('build')[Number(r.city_id)]?.score ?? 0), 0); }
    warReport(row) { const s = JSON.parse(String(row.state)), a = this.guild(s.attacker), d = s.defender ? this.guild(s.defender) : null; return { city: String(row.city_id), record_id: row.id, day: row.day, is_win: Number(s.owner) === Number(s.attacker) ? 1 : 0, att_guild_name: a.name, att_guild_icon: a.icon, def_guild_name: d?.name ?? 'Quân phòng thủ', def_guild_icon: d?.icon ?? '', time: Math.floor(Number(row.updated_at) / 1000), duels: s.duels }; }
    day(e) { return new Date(this.time(e) + 7 * 3600000).toISOString().slice(0, 10); }
    likes(id, e) { return this.db.prepare("SELECT json_extract(reward,'$.targetUid') uid FROM aether_claims WHERE event_id=? AND user_id=? AND kind='daily-like' AND claim_key LIKE ? ORDER BY created_at,rowid").all(e.id, id, this.day(e) + ':%').map(r => String(r.uid)); }
    science(id, e = this.event()) {
        const main = this.index(id, e), g = this.participant(id, e);
        const science = new AetherScience(this.db, e.id, this.day(e), this.now()), credit = simEnabled(this.db, e) ? simGet(this.db, e.id, id, 'science-credit', this.day(e), { credits: 0, used: 0 }) : { credits: 0, used: 0 };
        return { ...main, name: main.ass_name, lv: Number(g.science_level), score: Number(g.science_exp), self_science_score: science.total(id), rank_info: { self_rank: 0 }, science_free: science.used(id), science_charge: credit.used, charge_times: credit.credits * 500, contribution_status: simEnabled(this.db, e) ? 'QA_SIMULATION' : 'FREE_VERIFIED_PAID_BLOCKED', ranking_status: 'LEDGER_ONLY', source_message: simEnabled(this.db, e) ? 'Mô phỏng LOCAL: 1 lượt miễn phí + tối đa3 lượt tín dụng QA; không thu tiền thật.' : 'Cống một lượt miễn phí/ngày, giữ tổng điểm tích lũy. Buff sao đã mở cộng dồn và giảm Ô Nhiễm; lượt nạp trả phí chưa có sổ xác minh.' };
    }
    scienceRank(id, e = this.event()) {
        const g = this.participant(id, e), science = new AetherScience(this.db, e.id, this.day(e), this.now()), rows = this.db.prepare("SELECT user_id,sum(json_extract(reward,'$.points')) points,min(rowid) first_order FROM aether_claims WHERE event_id=? AND kind='science-contribution' AND json_extract(reward,'$.guildId')=? GROUP BY user_id ORDER BY points DESC,first_order LIMIT 100").all(e.id, g.guild_id);
        return { version: e.version, rank_info: Object.fromEntries(rows.map((r, i) => [i + 1, { ...this.person(Number(r.user_id), e), score: r.points }])), self_score: science.total(id), got_sciencestar: science.milestones(id), ranking_status: 'LEDGER_ONLY', ranking_message: 'Sổ cống hiến thực của hội; thứ tự hiển thị không dùng để phát thưởng. Mốc thưởng theo tổng cá nhân, không theo vị trí.' };
    }
    index(id, e = this.event()) {
        new GodfieldService(this.db).assertUnlocked(id);
        const p = this.phase(e);
        if (p.step === 0)
            fail(p.label + '; không có pha giao diện hợp lệ trong nguồn.');
        const m = new AllianceService(this.db).member(id);
        let gid = Number(m?.alliance_id ?? 0);
        const hired = this.db.prepare("SELECT guild_id FROM aether_mercenaries WHERE event_id=? AND user_id=? AND status='active'").get(e.id, id);
        if (hired)
            gid = Number(hired.guild_id);
        const enrollment = this.db.prepare('SELECT * FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, gid), self = this.db.prepare('SELECT group_id FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, m?.alliance_id ?? 0);
        return { ...new AetherEconomy(this.db, e.id).packet({ user_id: id }, {}), event_id: e.id, version: e.version, simulation: simEnabled(this.db, e), simulation_label: simEnabled(this.db, e) ? simPolicy.label : undefined, step: p.step, next_step_time: Math.floor(p.next / 1000), end_time: Math.floor(e.end_at / 1000), server_time: Math.floor(this.time(e) / 1000), group_id: enrollment?.group_id ?? 0, group_id_self: self?.group_id ?? 0, ass_id: gid ? String(gid) : '', ass_name: gid ? this.guild(gid).name : '', icon: gid ? this.guild(gid).icon : '1', title: hired ? 'member' : m?.role ?? '', self_score: Number(this.db.prepare('SELECT blood FROM aether_scores WHERE event_id=? AND user_id=?').get(e.id, id)?.blood ?? 0), self_guild_score: gid ? (simEnabled(this.db, e) ? this.simulation(e).core.guildScore(gid) : this.guildScore(gid, e)) : 0, score_status: simEnabled(this.db, e) ? 'LOCAL_SIMULATION' : Number(enrollment?.science_level ?? 0) ? 'SOURCE_BLOCKED' : 'CITY_SCORE_VERIFIED', combat_status: 'PARTIAL', max_num: enrollment ? this.capacity(gid, e) : 0, all_group: Object.fromEntries(this.groups(e).map(r => [r.group_id, { name: r.group_id + ' Số Chiến Trường', group_id: r.group_id }])), qa: e.qa === 1, phase: p, source_blockers: aetherMissing() };
    }
    map(id, group, e = this.event()) {
        const main = this.index(id, e);
        if (!group)
            group = Number(main.group_id || this.groups(e)[0]?.group_id);
        if (!this.groups(e).some(r => r.group_id === group))
            fail('Chiến trường không có trong mùa nguồn.');
        if (main.step === 1)
            fail('Giai đoạn Dự Cáo chưa vào bản đồ.');
        const cities = this.db.prepare('SELECT * FROM aether_cities WHERE event_id=? AND group_id=?').all(e.id, group), map = {};
        for (const key of Object.keys(aetherConfig('build'))) {
            const c = cities.find(r => r.city_id === Number(key)), zone = aetherConfig('build')[key]?.sort === 3 ? cities.find(r => aetherConfig('build')[key].city_zone.includes(r.city_id)) : null, ownerId = c?.owner_id ?? zone?.owner_id, owner = ownerId ? this.guild(ownerId) : null, att = c?.attacker_id ? this.guild(c.attacker_id) : null;
            map[key] = { def_guild: owner ? String(owner.id) : '', def_name: owner?.name ?? '', def_icon: owner?.icon ?? '', def_guild_name: owner?.name ?? '', def_guild_icon: owner?.icon ?? '', att_guild: att ? String(att.id) : '', att_name: att?.name ?? '', att_icon: att?.icon ?? '', att_guild_name: att?.name ?? '', att_guild_icon: att?.icon ?? '', is_win: 0, att_info: [], def_info: [] };
        }
        const deployed = this.db.prepare('SELECT * FROM aether_deployments WHERE event_id=? ORDER BY priority,rowid').all(e.id);
        for (const d of deployed) {
            const g = this.participant(d.user_id, e);
            if (g.group_id !== group || !map[d.city_id] || !['attack', 'defend'].includes(d.kind))
                continue;
            const state = this.state(d.user_id, e), session = { user_id: d.user_id }, heroes = new PlayerService(this.db).cards(session).cards;
            map[d.city_id][d.kind === 'attack' ? 'att_info' : 'def_info'].push({ ...this.person(d.user_id), icon: this.person(d.user_id).role, alignment: d.team, alignment_cards: state.god_field_ids[d.team], alignment_info: heroes });
        }
        const power = main.ass_id ? this.army(Number(main.ass_id), e).reduce((sum, id) => sum + this.person(id).combat, 0) : 0;
        const reports = this.db.prepare("SELECT * FROM aether_wars WHERE event_id=? AND group_id=? AND day=? AND status='done' ORDER BY city_id").all(e.id, group, this.day(e));
        return { ...main, self_group_id: main.group_id, group_id: group, map, info: reports.map(r => this.warReport(r)), city: Object.fromEntries(Object.keys(map).filter(k => map[k].def_guild === main.ass_id && main.ass_id !== '').map(k => [k, 1])), science_lv: Number(this.db.prepare('SELECT science_level FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, Number(main.ass_id) || 0)?.science_level ?? 0), combat: power };
    }
    alignment(id, target, e = this.event()) {
        const own = this.participant(id, e), other = this.participant(target, e);
        if (own.group_id !== other.group_id)
            fail('Không xem đội hình ở chiến trường khác.');
        const state = this.state(target, e), session = this.db.prepare('SELECT user_id,game_uid,role FROM player_profiles WHERE user_id=?').get(target), heroes = new PlayerService(this.db).cards(session).cards;
        const status = Object.fromEntries(this.db.prepare('SELECT team,city_id FROM aether_deployments WHERE event_id=? AND user_id=?').all(e.id, target).map(r => [String(r.team), { city: String(r.city_id) }]));
        return { ...this.person(target, e), icon: session.role, server: this.realm, guild_name: this.guild(other.guild_id).name, step: this.phase(e).step, alignments: state.god_field_ids, alignment_info: heroes, alignment_status: status, ...new GodfieldService(this.db).packet(target, state) };
    }
    employ(id, group, e = this.event(), leader = false) {
        const main = this.index(id, e);
        if (!group)
            group = Number(main.group_id || this.groups(e)[0]?.group_id);
        if (!this.groups(e).some(r => r.group_id === group))
            fail('Nhóm không hợp lệ.');
        const guilds = this.db.prepare('SELECT guild_id FROM aether_guilds WHERE event_id=? AND group_id=? ORDER BY slot').all(e.id, group);
        const data = (gid) => { const contracts = this.db.prepare('SELECT * FROM aether_mercenaries WHERE event_id=? AND guild_id=? ORDER BY updated_at,user_id').all(e.id, gid); const list = (state) => contracts.filter(c => c.status === state).map(c => ({ ...this.person(c.user_id), association_name: this.guild(c.origin_guild).name })); return { guild_id: String(gid), name: this.guild(gid).name, player_num: this.army(gid, e).length, combat: this.army(gid, e).reduce((n, u) => n + this.person(u).combat, 0), employ_waiter: list('pending'), employ_list: list('active'), employ_black: list('left').map(p => p.uid), max_num: this.capacity(gid, e) }; };
        if (leader) {
            const actor = this.actor(id);
            this.enrollment(actor.alliance_id, e);
            return { ...main, ...data(actor.alliance_id) };
        }
        const active = this.db.prepare("SELECT guild_id FROM aether_mercenaries WHERE event_id=? AND user_id=? AND status='active'").get(e.id, id);
        return { ...main, group_id: group, groups: main.all_group, employ_guild: active ? String(active.guild_id) : '', rank: Object.fromEntries(guilds.map((r, i) => { const g = data(Number(r.guild_id)); return [i + 1, { ...g, employ_waiter: g.employ_waiter.map((p) => p.uid), employ_list: g.employ_list.map((p) => p.uid) }]; })) };
    }
    shop(id, e = this.event()) {
        const g = this.participant(id, e), goods = {}, blocked_offers = {};
        // buy_limit[1]=2 dùng nhãn gốc xiangou_icon01 “Hạn Mua Cá Nhân”.
        const personal = (c) => c.buy_limit.length === 2 && (c.buy_limit[0] === 2 || simEnabled(this.db, e) && [1, 3].includes(c.buy_limit[0])) && Number.isSafeInteger(c.buy_limit[1]) && c.buy_limit[1] > 0;
        for (const [k, c] of Object.entries(aetherConfig('shop')))
            if ((c.show_time === -1 || simEnabled(this.db, e) && [1, 2].includes(c.show_time)) && (!c.buy_limit.length || personal(c)) && c.show_level <= Number(g.science_level))
                goods[k] = Number(c.buy_limit[0] === 1 && simEnabled(this.db, e) ? this.db.prepare('SELECT sum(quantity) n FROM aether_purchases WHERE event_id=? AND period=? AND offer_id=?').get(e.id, 'group:' + g.group_id, Number(k))?.n ?? 0 : this.db.prepare('SELECT sum(quantity) n FROM aether_purchases WHERE event_id=? AND user_id=? AND offer_id=? AND (? IS NULL OR period=?)').get(e.id, id, Number(k), c.buy_limit[0] === 3 ? this.day(e) : null, this.day(e))?.n ?? 0);
        for (const [k, c] of Object.entries(aetherConfig('shop')))
            if (!Object.hasOwn(goods, k))
                blocked_offers[k] = c.show_time !== -1 ? 'Chưa có thuật toán chọn hàng theo ngày.' : c.buy_limit.length && !personal(c) ? 'Hạn Mua Chiến Trường chưa chốt phạm vi dùng chung.' : 'Cấp KHKT chưa mở.';
        return { ...new AetherEconomy(this.db, e.id).packet({ user_id: id }, {}), goods, blocked_offers, version: e.version, simulation: simEnabled(this.db, e), source_status: simEnabled(this.db, e) ? 'Mô phỏng LOCAL: hiện toàn bộ catalog đủ KHKT, Hạn Mua Chiến Trường dùng chung cả mùa; loại3 mô phỏng theo ngày.' : 'Giá cố định và Hạn Mua Cá Nhân theo mùa; hàng ngẫu nhiên và Hạn Mua Chiến Trường chưa chốt giữ khóa riêng.' };
    }
    rank(id, group, type, e = this.event()) {
        if (![0, 1].includes(type))
            return fail('Kiểu BXH không hợp lệ.');
        this.index(id, e);
        if (!this.groups(e).some(g => g.group_id === group))
            fail('Chiến trường không có trong mùa nguồn.');
        const entries = this.db.prepare('SELECT * FROM aether_guilds WHERE event_id=? AND group_id=? ORDER BY slot').all(e.id, group);
        const scopedScores = type === 0 ? aetherGroupScores(this.db, e.id, group) : [], rows = scopedScores.slice(0, 100);
        const own = this.index(id, e);
        return { version: e.version, rank: Object.fromEntries(rows.map((r, i) => [i + 1, { ...this.person(Number(r.user_id), e), icon: this.person(Number(r.user_id), e).role, score: r.blood, like: Number(this.db.prepare("SELECT count(*) n FROM aether_claims WHERE event_id=? AND kind='daily-like' AND json_extract(reward,'$.target')=?").get(e.id, r.user_id).n) }])), self_score: type === 0 ? Number(scopedScores.find(r => Number(r.user_id) === id)?.blood ?? 0) : own.self_guild_score, self_rank: type === 0 ? Math.max(0, scopedScores.findIndex(r => Number(r.user_id) === id) + 1) : 0, icon: own.icon, like_log: this.likes(id, e), participants: entries.map(r => ({ guild_id: String(r.guild_id), name: this.guild(r.guild_id).name, city_score: this.guildScore(r.guild_id, e), science_level: r.science_level })), ranking_status: type === 0 ? 'USER_RULE_VERIFIED' : 'SOURCE_BLOCKED', ranking_message: type === 0 ? 'Huyết Tinh theo chuỗi đội/thành/ngày; bằng điểm xếp theo thời điểm đạt.' : 'Điểm thành trì đã tính; hệ số KHKT và xử lý đồng hạng thưởng liên minh còn thiếu nguồn.' };
    }
    read(id, method, p) {
        const e = this.event(), group = Number(p.get('group_id') ?? 0);
        if (!Number.isInteger(group))
            fail('Nhóm không hợp lệ.');
        if (simEnabled(this.db, e) && simReads.includes(method)) {
            const x = this.simulation(e);
            this.participant(id, e);
            if (method === 'box_index')
                return x.core.boxes(id);
            if (method === 'war_index')
                return x.core.war(id);
            if (method === 'player_index')
                return x.core.players(id);
            if (method === 'explore_index')
                return x.objectives.exploreIndex(id, Number(p.get('city_id')));
        }
        if (simEnabled(this.db, e) && method === 'city_info' && aetherConfig('build')[Number(p.get('city_id'))]?.sort === 3) {
            this.map(id, group, e);
            return this.simulation(e).objectives.city(id, Number(p.get('city_id')), group || this.participant(id, e).group_id);
        }
        if (method === 'index')
            return this.index(id, e);
        if (method === 'map_index')
            return this.map(id, group, e);
        if (method === 'alignment_info')
            return this.alignment(id, p.get('t_uid') ? this.uid(p.get('t_uid')) : id, e);
        if (method === 'upload_formation') {
            this.participant(id, e);
            return new GodfieldService(this.db).packet(id, this.state(id, e));
        }
        if (method === 'employ_index' || method === 'employ_guild_index')
            return this.employ(id, group, e, method === 'employ_guild_index');
        if (simEnabled(this.db, e) && method === 'get_rank' && Number(p.get('rank_type') ?? 1) === 1)
            return this.simulation(e).core.guildRank(id, group || this.participant(id, e).group_id);
        if (method === 'shop_index')
            return this.shop(id, e);
        if (method === 'get_rank')
            return this.rank(id, group || Number(this.index(id, e).group_id), Number(p.get('rank_type') ?? 1), e);
        if (method === 'science_index')
            return this.science(id, e);
        if (method === 'science_rank')
            return this.scienceRank(id, e);
        if (method === 'record') {
            this.map(id, group, e);
            const record = p.get('record_id') ?? '';
            if (record.length > 300)
                fail('Mã biên bản không hợp lệ.');
            const row = this.db.prepare("SELECT packet FROM aether_battles WHERE event_id=? AND group_id=? AND city_id=? AND json_extract(metadata,'$.att_uid')=? AND json_extract(metadata,'$.def_uid')=? AND (?='' OR id=?) ORDER BY rowid DESC LIMIT 1").get(e.id, group, Number(p.get('city_id')), p.get('att_uid'), p.get('def_uid'), record, record);
            if (!row)
                fail('Không tìm thấy biên bản trận trong chiến trường này.');
            return JSON.parse(String(row.packet));
        }
        if (method === 'city_info') {
            const map = this.map(id, group, e), city = p.get('city_id') ?? '';
            if (!map.map[city])
                fail('Địa điểm không hợp lệ.');
            return { ...map, info: map.map[city], city_id: city };
        }
        if (method === 'get_guild_record') {
            this.map(id, group, e);
            return { info: this.db.prepare("SELECT * FROM aether_wars WHERE event_id=? AND group_id=? AND status='done' ORDER BY updated_at DESC,rowid DESC LIMIT 100").all(e.id, group).map(r => this.warReport(r)) };
        }
        if (method === 'get_city_record') {
            const map = this.map(id, group, e), city = Number(p.get('city_id'));
            if (!map.map[city])
                fail('Thành trì không hợp lệ.');
            return { info: this.db.prepare('SELECT id,city_id,metadata,created_at FROM aether_battles WHERE event_id=? AND group_id=? AND city_id=? ORDER BY rowid DESC LIMIT 100').all(e.id, group, city).map(r => ({ ...JSON.parse(String(r.metadata)), record_id: r.id, time: Math.floor(Number(r.created_at) / 1000) })) };
        }
        return fail('Chức năng Aether còn thiếu hợp đồng nguồn; chưa tiêu hoặc phát tài nguyên.');
    }
    execute(s, method, p) {
        if (!simWrites.includes(method) && !['employ_join', 'employ_agree', 'employ_refuse', 'employ_quit', 'employ_remove', 'set_formation', 'stationed', 'set_fight_alignment', 'declare_war', 'set_first_alignment', 'buy', 'dolike', 'contribute', 'get_science_star'].includes(method))
            return fail('Thao tác ' + method + ' còn thiếu thuật toán nguồn; chưa tiêu vật phẩm hoặc phát thưởng.');
        const e = this.event(), body = { event: e.id, args: [...p].filter(([k]) => !['request_id', 'mk', 'rans', 'user_token'].includes(k)).sort(([a], [b]) => a.localeCompare(b)) };
        return contentReceipt(this.db, s.user_id, 'guild_high_war.' + method, p.get('request_id'), body, () => {
            const phase = this.phase(e);
            new GodfieldService(this.db).assertUnlocked(s.user_id);
            if (phase.ended || phase.step === 0)
                fail('Ngoài thời gian Aether.');
            this.ensure(e);
            let out = {};
            if (simWrites.includes(method)) {
                const sim = this.simulation(e);
                if (['stationed_source', 'declare_war_source', 'down_alignment_source', 'stationed_fate', 'down_alignment_fate', 'explore', 'get_fate_reward'].includes(method))
                    out = sim.objectives.execute(s, method, p);
                else
                    out = sim.core.execute(s, method, p);
            }
            else if (method === 'contribute' || method === 'get_science_star') {
                const guild = this.participant(s.user_id, e);
                if (phase.step === 1)
                    fail('KHKT chưa mở trong Dự Cáo.');
                const science = new AetherScience(this.db, e.id, this.day(e), this.now());
                if (method === 'contribute') {
                    const receipt = science.contribute(s, guild, Number(p.get('contribute_type')));
                    out = new AetherEconomy(this.db, e.id).packet(s, { ...this.science(s.user_id, e), contribution: receipt });
                }
                else {
                    const delivery = science.claim(s, Number(p.get('score')));
                    out = new AetherEconomy(this.db, e.id).packet(s, { ...this.scienceRank(s.user_id, e), ...delivery });
                }
            }
            else if (method === 'dolike') {
                const group = Number(p.get('group_id')), target = this.uid(p.get('t_uid')), rank = this.rank(s.user_id, group, 0, e), uid = String(p.get('t_uid')), cfg = aetherConfig('base')[e.version];
                if (!Object.values(rank.rank).some((r) => r.uid === uid))
                    fail('Người chơi không thuộc BXH Huyết Tinh của chiến trường này.');
                const limit = Number(cfg.daily_num);
                if (!Number.isSafeInteger(limit) || limit < 0)
                    fail('Thiếu trần Like của mùa.');
                if (rank.like_log.includes(uid) || rank.like_log.length >= limit)
                    fail('Đã Like người chơi này hoặc hết lượt hôm nay.');
                const delivery = new AetherEconomy(this.db, e.id).grant(s, cfg.money), claimKey = this.day(e) + ':' + uid;
                this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'daily-like',?,?,?)").run(e.id, s.user_id, claimKey, JSON.stringify({ target, targetUid: uid, rewards: cfg.money }), this.now());
                out = new AetherEconomy(this.db, e.id).packet(s, { ...this.rank(s.user_id, group, 0, e), ...delivery });
            }
            else if (method.startsWith('employ_')) {
                this.employWindow(e);
                const m = this.member(s.user_id), gid = Number(p.get('guild_id'));
                let target = s.user_id, host = gid;
                if (['employ_agree', 'employ_refuse', 'employ_remove'].includes(method)) {
                    host = this.actor(s.user_id).alliance_id;
                    target = this.uid(p.get('t_uid'));
                }
                const enrolled = this.enrollment(host, e);
                if (method === 'employ_join') {
                    if (this.db.prepare('SELECT 1 FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, m.alliance_id))
                        fail('Hội gốc đã tham chiến, không được làm lính đánh thuê.');
                    if (this.db.prepare("SELECT 1 FROM aether_mercenaries WHERE event_id=? AND user_id=? AND (status='active' OR guild_id=? AND status IN('pending','left'))").get(e.id, target, host))
                        fail('Đã được thuê/đã xin hoặc đã rời hội này trong mùa.');
                    const group = this.groups(e).find(r => r.group_id === enrolled.group_id);
                    const apps = this.db.prepare('SELECT DISTINCT g.group_id FROM aether_mercenaries m JOIN aether_guilds g ON g.event_id=m.event_id AND g.guild_id=m.guild_id WHERE m.event_id=? AND m.user_id=?').all(e.id, target);
                    if (apps.length >= 3 && !apps.some(r => r.group_id === group.group_id))
                        fail('Chỉ được xem/xin tối đa3 chiến trường theo quy tắc nguồn.');
                    this.db.prepare("INSERT INTO aether_mercenaries VALUES(?,?,?,?,'pending',?) ON CONFLICT(event_id,user_id,guild_id) DO UPDATE SET status='pending',updated_at=excluded.updated_at").run(e.id, target, host, m.alliance_id, this.now());
                }
                else {
                    const contract = this.db.prepare('SELECT * FROM aether_mercenaries WHERE event_id=? AND user_id=? AND guild_id=?').get(e.id, target, host);
                    if (!contract)
                        return fail('Không có hợp đồng thuộc Liên Minh này.');
                    if (method === 'employ_agree') {
                        if (contract.status !== 'pending')
                            fail('Đơn không còn chờ duyệt.');
                        if (this.member(target).alliance_id !== contract.origin_guild || this.db.prepare('SELECT 1 FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, contract.origin_guild))
                            fail('Hội gốc không còn đủ điều kiện.');
                        const count = Number(this.db.prepare("SELECT count(*) n FROM aether_mercenaries WHERE event_id=? AND guild_id=? AND status='active'").get(e.id, host).n);
                        if (count >= this.capacity(host, e))
                            fail('Hết chỗ thuê theo trần nguồn.');
                        const powers = this.db.prepare('SELECT user_id FROM alliance_members WHERE alliance_id=?').all(host).map(r => this.person(Number(r.user_id)).combat);
                        if (this.person(target).combat < Math.min(...powers))
                            fail('Ba đội thấp hơn thành viên có lực chiến trung bình thấp nhất.');
                        if (this.db.prepare("SELECT 1 FROM aether_mercenaries WHERE event_id=? AND user_id=? AND status='active'").get(e.id, target))
                            fail('Người chơi đã được hội khác thuê.');
                    }
                    else if (method === 'employ_refuse') {
                        if (contract.status !== 'pending')
                            fail('Đơn không còn chờ duyệt.');
                    }
                    else if (!['employ_quit', 'employ_remove'].includes(method) || contract.status !== 'active')
                        fail('Không thể rời/hủy hợp đồng này.');
                    const status = method === 'employ_agree' ? 'active' : method === 'employ_refuse' ? 'refused' : 'left';
                    this.db.prepare('UPDATE aether_mercenaries SET status=?,updated_at=? WHERE event_id=? AND user_id=? AND guild_id=?').run(status, this.now(), e.id, target, host);
                }
                out = this.employ(s.user_id, enrolled.group_id, e, ['employ_agree', 'employ_refuse', 'employ_remove'].includes(method));
            }
            else if (method === 'set_formation') {
                this.participant(s.user_id, e);
                if (phase.step !== 4)
                    fail('Chỉ chỉnh đội Aether trong Dàn Trận.');
                if (this.db.prepare('SELECT 1 FROM aether_deployments WHERE event_id=? AND user_id=?').get(e.id, s.user_id))
                    fail('Đội đã cử đi; rút đội trước khi sửa.');
                const state = new GodfieldService(this.db).updatedState(s, p, this.state(s.user_id, e));
                this.db.prepare('INSERT INTO aether_formations VALUES(?,?,?,?) ON CONFLICT(event_id,user_id) DO UPDATE SET state=excluded.state,updated_at=excluded.updated_at').run(e.id, s.user_id, JSON.stringify(state), this.now());
                out = new GodfieldService(this.db).packet(s.user_id, state);
            }
            else if (method === 'declare_war') {
                const actor = this.actor(s.user_id), g = this.participant(s.user_id, e), city = Number(p.get('city_id')), town = aetherConfig('build')[city];
                if (actor.alliance_id !== g.guild_id || phase.step !== 3)
                    fail('Chỉ Hội trưởng/Phó hội trưởng của hội tham chiến được tuyên chiến đúng pha.');
                if (!town || town.sort !== 1)
                    fail('Không tuyên chiến trực tiếp vùng tài nguyên/kỳ ngộ.');
                const owned = this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND group_id=? AND owner_id=?').all(e.id, g.group_id, g.guild_id).map(r => Number(r.city_id)), cities = aetherConfig('build');
                if (!owned.some(c => cities[c].attack_point.includes(city) && Math.abs(cities[c].city_level - town.city_level) <= 1))
                    fail('Thành không kề điểm đang giữ hoặc vượt quy tắc cấp thành.');
                const current = this.db.prepare('SELECT * FROM aether_cities WHERE event_id=? AND group_id=? AND city_id=?').get(e.id, g.group_id, city);
                if (current?.owner_id === g.guild_id || current?.attacker_id === g.guild_id)
                    fail('Đã giữ hoặc đã tuyên chiến thành này.');
                const max = Math.max(1, ...owned.map(c => cities[c].city_level)), used = Number(this.db.prepare('SELECT count(*) n FROM aether_cities WHERE event_id=? AND group_id=? AND attacker_id=?').get(e.id, g.group_id, g.guild_id).n);
                if (used >= max)
                    fail('Đã hết số lần tuyên chiến theo cấp thành đang giữ.');
                if (current?.attacker_id) {
                    const total = (gid) => this.army(gid, e).reduce((n, id) => n + this.person(id).combat, 0);
                    if (total(g.guild_id) <= total(Number(current.attacker_id)))
                        fail('Hội tuyên chiến trước có lực chiến cao hơn hoặc bằng.');
                }
                if (current?.attacker_id) {
                    for (const id of this.army(Number(current.attacker_id), e))
                        this.db.prepare('INSERT OR IGNORE INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(id, 'aether-declare:' + e.id + ':' + city + ':' + p.get('request_id'), 'Aether: tuyên chiến thành ' + town.city_name + ' đã được hội có lực chiến cao hơn thay thế. Không trừ vật phẩm hoặc phát thưởng.', '[]');
                }
                this.db.prepare('INSERT INTO aether_cities(event_id,group_id,city_id,attacker_id) VALUES(?,?,?,?) ON CONFLICT(event_id,group_id,city_id) DO UPDATE SET attacker_id=excluded.attacker_id').run(e.id, g.group_id, city, g.guild_id);
                out = { ...this.map(s.user_id, g.group_id, e), info: { ...this.map(s.user_id, g.group_id, e).map[String(city)] }, change: 1 };
            }
            else if (method === 'set_first_alignment') {
                const actor = this.actor(s.user_id), g = this.participant(s.user_id, e), city = Number(p.get('city_id')), target = this.uid(p.get('t_uid')), kind = p.get('set_type') === '0' ? 'defend' : p.get('set_type') === '1' ? 'attack' : fail('Phe ghim không hợp lệ.');
                if (phase.step !== 4 || actor.alliance_id !== g.guild_id || this.participant(target, e).guild_id !== g.guild_id)
                    fail('Chỉ chỉ huy đúng hội được ghim đội trong Dàn Trận.');
                const row = this.db.prepare('SELECT team FROM aether_deployments WHERE event_id=? AND user_id=? AND city_id=? AND kind=?').get(e.id, target, city, kind);
                if (!row)
                    return fail('Đội không đóng ở thành/phe này.');
                const min = Number(this.db.prepare('SELECT min(priority) n FROM aether_deployments WHERE event_id=? AND city_id=? AND kind=?').get(e.id, city, kind).n ?? 0);
                if (!Number.isSafeInteger(min - 1))
                    fail('Thứ tự đội vượt giới hạn.');
                this.db.prepare('UPDATE aether_deployments SET priority=? WHERE event_id=? AND user_id=? AND team=?').run(min - 1, e.id, target, row.team);
                out = this.map(s.user_id, g.group_id, e);
            }
            else if (method === 'stationed' || method === 'set_fight_alignment') {
                const g = this.participant(s.user_id, e), city = Number(p.get('city_id')), team = Number(p.get('alignment'));
                if (phase.step !== 4)
                    fail('Chưa đến giai đoạn Dàn Trận.');
                if (![1, 2, 3].includes(team) || aetherConfig('build')[city]?.sort !== 1)
                    fail('Đội/thành trì không hợp lệ.');
                const c = this.db.prepare('SELECT * FROM aether_cities WHERE event_id=? AND group_id=? AND city_id=?').get(e.id, g.group_id, city);
                const side = method === 'stationed' ? 'owner_id' : 'attacker_id';
                if (Number(c?.[side]) !== Number(g.guild_id))
                    fail('Liên Minh không thuộc phe của thành trì này.');
                const oldDeployment = this.db.prepare('SELECT kind FROM aether_deployments WHERE event_id=? AND user_id=? AND team=?').get(e.id, s.user_id, team);
                if (oldDeployment && ['resource', 'explore'].includes(String(oldDeployment.kind)))
                    fail('Đội đang khai thác/thám hiểm; rút đúng nhiệm vụ trước khi công/thủ thành.');
                const state = this.state(s.user_id, e);
                if (!godfieldTeam(state, team).alignment[0].some((v) => !['0', '-1'].includes(v)))
                    fail('Đội cần ít nhất1 Anh Hùng chính.');
                if (this.db.prepare("SELECT 1 FROM aether_deployments WHERE event_id=? AND user_id=? AND team<>? AND kind IN('attack','defend')").get(e.id, s.user_id, team))
                    fail('Mỗi người chỉ cử1 đội công/thủ thành.');
                this.db.prepare('INSERT INTO aether_formations VALUES(?,?,?,?) ON CONFLICT(event_id,user_id) DO NOTHING').run(e.id, s.user_id, JSON.stringify(state), this.now());
                this.db.prepare('INSERT INTO aether_deployments(event_id,user_id,team,city_id,kind,block_id) VALUES(?,?,?,?,?,0) ON CONFLICT(event_id,user_id,team) DO UPDATE SET city_id=excluded.city_id,kind=excluded.kind,block_id=0,priority=0').run(e.id, s.user_id, team, city, method === 'stationed' ? 'defend' : 'attack');
                out = this.alignment(s.user_id, s.user_id, e);
            }
            else if (method === 'buy') {
                this.participant(s.user_id, e);
                if (![2, 3, 4, 5, 6, 7, 8, 9, 10, 11].includes(phase.step))
                    fail('Chưa mở cửa hàng.');
                const offer = Number(p.get('goods_id')), row = aetherConfig('shop')[offer];
                if (!row || !Object.hasOwn(this.shop(s.user_id, e).goods, offer))
                    fail('Món hàng thiếu quy tắc/lịch giới hạn hoặc KHKT chưa mở.');
                if (row.buy_limit.length && Number(this.shop(s.user_id, e).goods[offer]) >= row.buy_limit[1])
                    fail('Đã hết Hạn Mua của món này trong mùa Aether.');
                const economy = new AetherEconomy(this.db, e.id);
                if (![1, 2].includes(row.need_sort))
                    fail('Chưa xác minh tiền tệ cửa hàng.');
                economy.cost(s, [[row.need_sort === 1 ? 6 : 9, row.need_sort === 1 ? 9100986 : 0, row.need_value]]);
                out = economy.grant(s, row.shop_reward);
                this.db.prepare('INSERT INTO aether_purchases VALUES(?,?,?,?,1) ON CONFLICT(event_id,user_id,offer_id,period) DO UPDATE SET quantity=quantity+1').run(e.id, s.user_id, offer, row.buy_limit[0] === 1 && simEnabled(this.db, e) ? 'group:' + this.participant(s.user_id, e).group_id : row.buy_limit[0] === 3 ? this.day(e) : 'season');
                out = economy.packet(s, { ...out, ...this.shop(s.user_id, e) });
            }
            else
                fail('Thao tác còn thiếu thuật toán nguồn; chưa tuyên chiến/kết toán/tiêu vật phẩm giả.');
            if (simEnabled(this.db, e) && !simWrites.includes(method) && !method.startsWith('employ_'))
                this.simulation(e).core.activity(s.user_id, method);
            audit(this.db, null, 'aether.' + method, s.user_id, 'Aether nguồn Việt Nam; không đổi hội gốc/đội thường', null, { event: e.id, requestId: p.get('request_id') });
            return out;
        }, old => { if (simWrites.includes(method)) {
            const sim = this.simulation(e);
            const fresh = method === 'select_reward' ? sim.core.boxes(s.user_id) : ['get_war_reward', 'auto_get_war_reward'].includes(method) ? sim.core.war(s.user_id) : ['simulate_purchase', 'send_war_card'].includes(method) ? sim.core.players(s.user_id) : ['explore', 'get_fate_reward', 'stationed_fate', 'down_alignment_fate'].includes(method) ? sim.objectives.exploreIndex(s.user_id, Number(p.get('city_id'))) : sim.objectives.city(s.user_id, Number(p.get('city_id')), this.participant(s.user_id, e).group_id);
            return { ...fresh, reward: {}, reward_tuples: [], replayed: true };
        } const latest = method === 'contribute' ? new AetherEconomy(this.db, e.id).packet(s, this.science(s.user_id, e)) : method === 'get_science_star' ? new AetherEconomy(this.db, e.id).packet(s, this.scienceRank(s.user_id, e)) : method === 'dolike' ? new AetherEconomy(this.db, e.id).packet(s, this.rank(s.user_id, Number(p.get('group_id')), 0, e)) : method === 'buy' ? new AetherEconomy(this.db, e.id).packet(s, this.shop(s.user_id, e)) : method === 'set_first_alignment' ? this.map(s.user_id, Number(old.group_id), e) : method === 'declare_war' ? { ...this.map(s.user_id, Number(old.group_id), e), info: this.map(s.user_id, Number(old.group_id), e).map[p.get('city_id') ?? ''], change: 0 } : method === 'set_formation' ? new GodfieldService(this.db).packet(s.user_id, this.state(s.user_id, e)) : method.startsWith('employ_') ? this.employ(s.user_id, Number(old.group_id || 0), e, ['employ_agree', 'employ_refuse', 'employ_remove'].includes(method)) : this.alignment(s.user_id, s.user_id, e); return { ...latest, reward: {}, reward_tuples: [], replayed: true }; });
    }
}
