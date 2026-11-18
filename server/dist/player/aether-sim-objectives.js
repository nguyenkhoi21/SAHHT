import { createHash } from 'node:crypto';
import { aetherConfig } from './aether-source.js';
import { AetherEconomy } from './aether-economy.js';
import { AetherSimulation } from './aether-simulation.js';
import { simAssert, simGet, simPut, simRoll, simRewards, simPolicy } from './aether-sim-policy.js';
import { godfieldCombatTeam } from './godfield-battle.js';
import { readConfigSync } from './local-content.js';
import { serializeEntity, simulateBattle } from './local-combat.js';
import { awardAetherVictory } from './aether-score.js';
import { AetherSimProduction } from './aether-sim-production.js';
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
export class AetherSimObjectives {
    db;
    event;
    host;
    now;
    constructor(db, event, host, now = () => Date.now()) {
        this.db = db;
        this.event = event;
        this.host = host;
        this.now = now;
        simAssert(db, event);
    }
    core() { return new AetherSimulation(this.db, this.event, this.host, this.now); }
    get(id, kind, scope, fallback = {}) { return simGet(this.db, this.event.id, id, kind, scope, fallback); }
    put(id, kind, scope, state) { simPut(this.db, this.event.id, id, kind, scope, state, this.now()); }
    resourceConfig(city) { const town = aetherConfig('build')[city]; if (town?.sort !== 3)
        fail('Địa điểm không phải vùng tài nguyên.'); const cfg = Object.values(aetherConfig('product')).find(r => r.build_sort === 3 && r.bulid_level === town.city_level); if (!cfg)
        fail('Thiếu bảng vị trí tài nguyên.'); return { town, cfg }; }
    positions(city) { return this.resourceConfig(city).cfg.place_num.flatMap((count, type) => Array(count).fill(type + 1)); }
    resourceKey(group, city, block) { return group + ':' + city + ':' + block; }
    userInfo(user, team) { const person = this.host.person(user), x = godfieldCombatTeam(this.db, user, team, 0, this.host.state(user)); return { ...person, icon: person.role, alignment: team, alignment_cards: this.host.state(user).god_field_ids[team], alignment_info: Object.fromEntries(x.entities.map(e => [e.record.id.replace(/^local_/, ''), e.record])) }; }
    city(id, city, group) {
        const info = {};
        for (let block = 1; block <= this.positions(city).length; block++) {
            const s = this.get(0, 'resource', this.resourceKey(group, city, block)), def = s.def?.user ? this.userInfo(s.def.user, s.def.team) : null, att = s.att?.user ? this.userInfo(s.att.user, s.att.team) : null;
            info[block] = { def_guild: def ? String(this.host.group(s.def.user).guild_id) : '', att_guild: att ? String(this.host.group(s.att.user).guild_id) : '', def_info: def ? [def] : [], att_info: att ? [att] : [] };
        }
        return this.core().packet(id, { ...this.host.index(id), city_id: city, info });
    }
    exploreIndex(id, city = 0) {
        const records = this.db.prepare("SELECT scope,state FROM aether_sim_state WHERE event_id=? AND user_id=? AND kind='explore'").all(this.event.id, id), info = {};
        for (const r of records) {
            const state = JSON.parse(String(r.state));
            if (state.team)
                info[String(r.scope)] = state;
        }
        const group = this.host.group(id), owned = this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND owner_id=?').all(this.event.id, group.guild_id), max = Math.max(1, ...owned.map(r => Number(aetherConfig('build')[Number(r.city_id)]?.city_level ?? 1)));
        const actual = Number(this.db.prepare("SELECT count(*) n FROM aether_claims WHERE event_id=? AND user_id=? AND kind='sim-explore' AND claim_key LIKE ?").get(this.event.id, id, this.host.day() + ':%').n);
        const unlocked = max >= 2 || this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND group_id=? AND owner_id IS NOT NULL').all(this.event.id, group.group_id).some(r => aetherConfig('build')[Number(r.city_id)]?.city_level === 3);
        return this.core().packet(id, { version: this.event.version, info, unlocked, server_time: Math.floor(this.host.time() / 1000), max_city_lv: max, max_times: 3 + Number(aetherConfig('science')[Number(group.science_level)]?.buff6 ?? 0), times: actual, got_reward: !!info[city]?.claimed });
    }
    reserve(id, team, city, kind, block = 0) {
        if (![1, 2, 3].includes(team))
            fail('Đội không hợp lệ.');
        const entities = godfieldCombatTeam(this.db, id, team, 0, this.host.state(id)).entities;
        if (!entities.some(e => e.index < 5))
            fail('Đội cần ít nhất một Anh Hùng chính.');
        const old = this.db.prepare('SELECT * FROM aether_deployments WHERE event_id=? AND user_id=? AND team=?').get(this.event.id, id, team);
        if (old && !(old.city_id === city && old.kind === kind && old.block_id === block))
            fail('Đội đang làm nhiệm vụ khác; rút đúng nhiệm vụ trước.');
        this.db.prepare('INSERT INTO aether_formations VALUES(?,?,?,?) ON CONFLICT(event_id,user_id) DO NOTHING').run(this.event.id, id, JSON.stringify(this.host.state(id)), this.now());
        this.db.prepare('INSERT INTO aether_deployments(event_id,user_id,team,city_id,kind,block_id) VALUES(?,?,?,?,?,?) ON CONFLICT(event_id,user_id,team) DO UPDATE SET city_id=excluded.city_id,kind=excluded.kind,block_id=excluded.block_id').run(this.event.id, id, team, city, kind, block);
    }
    execute(s, method, p) {
        const id = s.user_id, group = this.host.group(id), city = Number(p.get('city_id')), team = Number(p.get('alignment')), phase = this.host.phase(), day = this.host.day();
        let out;
        if (['stationed_source', 'declare_war_source', 'down_alignment_source'].includes(method)) {
            if (![4, 5].includes(phase.step))
                fail('Chỉ bố trí tài nguyên trong Dàn Trận/Thu Hoạch.');
            const { town } = this.resourceConfig(city), block = Number(p.get('block_id'));
            if (!Number.isInteger(block) || block < 1 || block > this.positions(city).length)
                fail('Vị trí tài nguyên không hợp lệ.');
            const maxOwn = Math.max(0, ...this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND owner_id=?').all(this.event.id, group.guild_id).map(r => Number(aetherConfig('build')[Number(r.city_id)]?.city_level ?? 0))), hasTop = this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND group_id=? AND owner_id IS NOT NULL').all(this.event.id, group.group_id).some(r => aetherConfig('build')[Number(r.city_id)]?.city_level === 3);
            if (town.city_level >= 2 && maxOwn < 2 && !hasTop)
                fail('Vùng tài nguyên cao cấp chưa mở theo thành đang giữ.');
            const key = this.resourceKey(group.group_id, city, block), state = this.get(0, 'resource', key);
            const existing = this.db.prepare("SELECT * FROM aether_deployments WHERE event_id=? AND user_id=? AND city_id=? AND kind='resource'").get(this.event.id, id, city);
            if (method === 'down_alignment_source') {
                if (!existing || existing.team !== team || existing.block_id !== block)
                    fail('Đội không giữ vị trí tài nguyên này.');
                if (state.def?.user === id) {
                    state.def = state.att ?? null;
                    state.att = null;
                }
                else if (state.att?.user === id)
                    state.att = null;
                else
                    fail('Vị trí đã thay đổi.');
                this.db.prepare('DELETE FROM aether_deployments WHERE event_id=? AND user_id=? AND team=?').run(this.event.id, id, team);
            }
            else {
                if (existing)
                    fail('Đã cử đội vào vùng tài nguyên này.');
                if (method === 'stationed_source' && state.def)
                    fail('Vị trí đã có người, hãy khiêu chiến.');
                if (method === 'declare_war_source' && !state.def)
                    fail('Vị trí đang trống, hãy nhập trú.');
                if (state.def?.user === id)
                    fail('Không khiêu chiến chính mình.');
                if (state.att) {
                    const oldPower = godfieldCombatTeam(this.db, state.att.user, state.att.team, 0, this.host.state(state.att.user)).power, newPower = godfieldCombatTeam(this.db, id, team, 0, this.host.state(id)).power;
                    if (newPower <= oldPower)
                        fail('Đội khiêu chiến trước có lực chiến cao hơn hoặc bằng.');
                    this.db.prepare('DELETE FROM aether_deployments WHERE event_id=? AND user_id=? AND team=?').run(this.event.id, state.att.user, state.att.team);
                    this.db.prepare("INSERT INTO player_mail VALUES(?,?,?,NULL,'[]')").run(state.att.user, 'aether-resource-replaced:' + p.get('request_id'), 'Đội khiêu chiến tài nguyên đã bị thay bởi đội lực chiến cao hơn · mô phỏng LOCAL.');
                }
                this.reserve(id, team, city, 'resource', block);
                state[method === 'stationed_source' ? 'def' : 'att'] = { user: id, team, since: day };
            }
            this.put(0, 'resource', key, state);
            out = this.city(id, city, group.group_id);
        }
        else if (method === 'stationed_fate' || method === 'down_alignment_fate') {
            if (![4, 5].includes(phase.step) || aetherConfig('build')[city]?.sort !== 2)
                fail('Chưa mở bố trí thám hiểm.');
            const state = this.get(id, 'explore', String(city));
            if (method === 'stationed_fate' && !this.exploreIndex(id).unlocked)
                fail('Cần hội giữ thành cấp2 hoặc chiến trường đã có thành cấp3 được chiếm.');
            if (state.time && !state.claimed)
                fail('Thám hiểm đang chờ nhận kết quả, không rút/đổi đội.');
            if (method === 'down_alignment_fate') {
                if (!state.team || state.team !== team)
                    fail('Đội không ở điểm này.');
                this.db.prepare('DELETE FROM aether_deployments WHERE event_id=? AND user_id=? AND team=?').run(this.event.id, id, team);
                this.put(id, 'explore', String(city), {});
            }
            else {
                this.reserve(id, team, city, 'explore');
                this.put(id, 'explore', String(city), { city, team, sort: 0, position_id: 0, time: 0 });
            }
            out = this.exploreIndex(id, city);
        }
        else if (method === 'explore') {
            if (![4, 5].includes(phase.step))
                fail('Chỉ thám hiểm trong Dàn Trận/Thu Hoạch.');
            const state = this.get(id, 'explore', String(city)), sort = Number(p.get('sort_id')), position = Number(p.get('position_id')), status = this.exploreIndex(id);
            if (!status.unlocked)
                fail('Chưa đủ điều kiện thành trì để thám hiểm.');
            if (!state.team || state.time && !state.claimed)
                fail('Cần đội đã cử và không còn kết quả chờ nhận.');
            if (![1, 2, 3].includes(sort) || sort > status.max_city_lv || !Number.isInteger(position) || position < 1 || position > 5)
                fail('Tầng/vị trí thám hiểm chưa mở.');
            if (status.times >= status.max_times)
                fail('Hết lượt thám hiểm hôm nay.');
            if (this.db.prepare("SELECT 1 FROM aether_claims WHERE event_id=? AND user_id=? AND kind='sim-explore' AND claim_key=?").get(this.event.id, id, day + ':' + state.team))
                fail('Đội đã thám hiểm hôm nay.');
            const rows = Object.entries(aetherConfig('fate')).filter(([, r]) => r.fate_id === city && r.sort === sort);
            if (!rows.length)
                fail('Thiếu bảng kỳ ngộ.');
            const key = this.event.id + ':' + id + ':' + day + ':' + p.get('request_id'), sum = rows.reduce((n, [, r]) => n + r.fate_num, 0);
            let roll = simRoll(key, 0, sum), selected = rows[0];
            for (const row of rows) {
                roll -= row[1].fate_num;
                if (roll < 0) {
                    selected = row;
                    break;
                }
            }
            const [fid, cfg] = selected;
            new AetherEconomy(this.db, this.event.id).cost(s, cfg.need);
            let gift = simRewards(cfg.reward, key, cfg.get_max), won = true, battleId;
            if ([1, 5].includes(cfg.type)) {
                const a = godfieldCombatTeam(this.db, id, state.team, 0, this.host.state(id)), npc = readConfigSync('enemy_detail')[79001];
                if (!npc)
                    fail('Thiếu NPC nguồn để mô phỏng kỳ ngộ.');
                const battle = simulateBattle([...a.entities, serializeEntity(100, 'qa-fate-79001', 79001, npc, npc, [])], simRoll(key, 1, 2147483647));
                won = battle.winner === 0;
                battleId = 'aether-fate-' + createHash('sha256').update(key).digest('hex').slice(0, 32);
                this.db.prepare('INSERT INTO aether_battles VALUES(?,?,?,?,?,?,?)').run(battleId, this.event.id, group.group_id, city, JSON.stringify({ battle: battle.battle }), JSON.stringify({ city: String(city), att_uid: s.game_uid, def_uid: 'QA-NPC:79001', is_win: won ? 1 : 0, simulation: true, kind: 'explore', des: 'Kỳ ngộ · mô phỏng LOCAL bằng NPC79001' }), this.now());
                if (!won)
                    gift = [];
            }
            if ([2, 3].includes(cfg.type))
                gift = [];
            this.put(id, 'explore', String(city), { ...state, city, sort, position_id: position, time: Math.floor(this.host.time() / 1000), ready_at: Math.floor((Date.parse(day + 'T00:00:00+07:00') + 86400000) / 1000), day, fate_id: Number(fid), gift, is_win: won, claimed: false, battleId });
            this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'sim-explore',?,?,?)").run(this.event.id, id, day + ':' + state.team, JSON.stringify({ city, sort, fateId: fid, policy: simPolicy.version }), this.now());
            out = this.exploreIndex(id, city);
        }
        else if (method === 'get_fate_reward') {
            const state = this.get(id, 'explore', String(city));
            if (!state.time || state.claimed)
                fail('Không có kết quả thám hiểm chưa nhận.');
            if (state.day >= day)
                fail('Kết quả nhận từ0h ngày hôm sau theo lịch QA.');
            const delivery = state.gift.length ? new AetherEconomy(this.db, this.event.id).grant(s, state.gift) : { reward: {} };
            state.claimed = true;
            this.put(id, 'explore', String(city), state);
            out = { ...this.exploreIndex(id, city), ...delivery };
        }
        else
            fail('Chưa có handler mục tiêu.');
        this.core().activity(id, method);
        return this.core().packet(id, out);
    }
    tick() {
        const phase = this.host.phase(), day = this.host.day(), e = this.event.id;
        let count = 0;
        new AetherSimProduction(this.db, this.event, this.now).tick(day);
        for (const row of this.db.prepare("SELECT scope,state FROM aether_sim_state WHERE event_id=? AND user_id=0 AND kind='resource'").all(e)) {
            const [group, city, block] = String(row.scope).split(':').map(Number), state = JSON.parse(String(row.state));
            if (!state.def)
                continue;
            this.db.exec('BEGIN IMMEDIATE');
            try {
                const rewardDay = state.def.since;
                if (rewardDay && rewardDay < day && !state.paidDays?.includes(rewardDay)) {
                    const type = this.positions(city)[block - 1], cfg = this.resourceConfig(city).cfg, rewards = simRewards(cfg['product' + type], e + ':production:' + row.scope + ':' + rewardDay);
                    if (rewards.length)
                        new AetherSimProduction(this.db, this.event, this.now).mail(state.def.user, rewards, 'resource:' + row.scope + ':' + rewardDay);
                    new AetherSimProduction(this.db, this.event, this.now).tax(group, city, type, String(row.scope) + ':' + rewardDay);
                    state.paidDays ??= [];
                    state.paidDays.push(rewardDay);
                    state.def.since = new Date(Date.parse(rewardDay + 'T00:00:00+07:00') + 86400000 + 7 * 3600000).toISOString().slice(0, 10);
                }
                if (state.att && [9, 8, 3, 7].includes(phase.step) && state.battleDay !== day) {
                    const a = godfieldCombatTeam(this.db, state.att.user, state.att.team, 0, this.host.state(state.att.user)), d = godfieldCombatTeam(this.db, state.def.user, state.def.team, 100, this.host.state(state.def.user)), key = e + ':' + day + ':resource:' + row.scope, id = 'aether-resource-' + createHash('sha256').update(key).digest('hex').slice(0, 32), battle = simulateBattle([...a.entities, ...d.entities], simRoll(key, 0, 2147483647)), won = battle.winner === 0, winner = won ? state.att : state.def, loser = won ? state.def : state.att;
                    this.db.prepare('INSERT INTO aether_battles VALUES(?,?,?,?,?,?,?)').run(id, e, group, city, JSON.stringify({ battle: { ...battle.battle, init: { ...battle.battle.init, atk_name: a.profile.show_name, dfd_name: d.profile.show_name, atk_role: a.session.role, dfd_role: d.session.role, aform: a.formation.formation.current, dform: d.formation.formation.current, equip_att: a.equipment, equip_def: d.equipment, equip_pos_att: a.formation.equip_pos, equip_pos_def: d.formation.equip_pos } } }), JSON.stringify({ city: String(city), att_uid: a.session.game_uid, def_uid: d.session.game_uid, is_win: won ? 1 : 0, simulation: true, kind: 'resource', des: 'Tranh tài nguyên · mô phỏng LOCAL', block }), this.now());
                    awardAetherVictory(this.db, { event: e, group, city, day: day + ':resource:' + block, user: winner.user, team: winner.team, battle: id }, this.now());
                    this.db.prepare('DELETE FROM aether_deployments WHERE event_id=? AND user_id=? AND team=?').run(e, loser.user, loser.team);
                    state.def = { ...winner, since: day };
                    state.att = null;
                    state.battleDay = day;
                }
                if (JSON.stringify(state) !== String(row.state)) {
                    this.put(0, 'resource', String(row.scope), state);
                    count++;
                }
                this.db.exec('COMMIT');
            }
            catch (error) {
                this.db.exec('ROLLBACK');
                throw error;
            }
        }
        return count;
    }
}
