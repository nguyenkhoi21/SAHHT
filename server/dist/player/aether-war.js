import { createHash } from 'node:crypto';
import { aetherConfig, aetherEvent, aetherPhase } from './aether-source.js';
import { godfieldCombatTeam } from './godfield-battle.js';
import { godfieldState } from './godfield.service.js';
import { simulateBattle, serializeEntity } from './local-combat.js';
import { awardAetherVictory, closeAetherStreak, aetherGroupScores } from './aether-score.js';
import { readConfigSync } from './local-content.js';
import { inventoryRewardItem } from './inventory-items.js';
import { aetherScienceCombat } from './aether-science.js';
import { audit } from '../admin/admin.audit.js';
import { simEnabled, simPolicy } from './aether-sim-policy.js';
import { AetherService } from './aether.service.js';
export const aetherDay = (at) => new Date(at + 7 * 3600000).toISOString().slice(0, 10);
export function aetherPollution(entities, wins, rate) {
    if (!Number.isInteger(wins) || wins < 0 || !Number.isFinite(rate) || rate < 0 || rate > 100)
        throw Error('Ô Nhiễm Aether ngoài giới hạn nguồn.');
    const percent = Math.min(100, wins * rate);
    return entities.map(e => ({ ...structuredClone(e), hp: Math.floor(e.hp * (100 - percent) / 100) })).filter(e => e.hp > 0);
}
function buffCity(squad, town) {
    for (const entity of squad.entities)
        for (const [type, percent] of town.buff1) {
            if (![1, 2, 5].includes(type) || !Number.isFinite(percent) || percent < 0)
                throw Error('Buff thành trì chưa có handler nguồn.');
            const factor = 1 + percent / 100;
            if (type === 5) {
                entity.hp = Math.floor(entity.hp * factor);
                entity.maxHp = Math.floor(entity.maxHp * factor);
                entity.card.hp = entity.maxHp;
            }
            else
                entity.card[type === 1 ? 'phsc' : 'mgc'] = Math.floor(entity.card[type === 1 ? 'phsc' : 'mgc'] * factor);
            entity.attack = Math.max(entity.card.phsc, entity.card.mgc);
        }
}
export class AetherWarService {
    db;
    now;
    constructor(db, now = () => Date.now()) {
        this.db = db;
        this.now = now;
    }
    settlePersonal(e) {
        const groups = this.db.prepare('SELECT DISTINCT group_id FROM aether_guilds WHERE event_id=?').all(e.id);
        for (const group of groups) {
            if (this.db.prepare("SELECT 1 FROM aether_wars WHERE event_id=? AND group_id=? AND status<>'done'").get(e.id, group.group_id) || this.db.prepare('SELECT 1 FROM aether_cities WHERE event_id=? AND group_id=? AND attacker_id IS NOT NULL').get(e.id, group.group_id))
                continue;
            // Chốt nguyên nhóm trong một transaction để một thư/audit lỗi không
            // phát nửa bảng thưởng. Biên nhận đã có vẫn phải khớp rank/score cũ.
            this.db.exec('BEGIN IMMEDIATE');
            try {
                const scores = aetherGroupScores(this.db, e.id, Number(group.group_id)), key = String(group.group_id);
                const digest = createHash('sha256').update(JSON.stringify(scores)).digest('hex');
                let delivered = 0;
                const previous = this.db.prepare("SELECT user_id,reward FROM aether_claims WHERE event_id=? AND kind='personal-final' AND claim_key=?").all(e.id, key);
                if (previous.some(row => !scores.some(s => s.user_id === row.user_id)))
                    throw Error('Sổ người nhận thưởng đã thay đổi; giữ biên nhận cũ để kiểm tra.');
                for (const [index, row] of scores.entries()) {
                    const reward = Object.values(aetherConfig('reward_person')).find((r) => index + 1 >= r.rank[0] && index + 1 <= r.rank[1]);
                    if (!reward)
                        continue;
                    const old = previous.find(p => p.user_id === row.user_id);
                    if (old) {
                        const saved = JSON.parse(String(old.reward));
                        if (saved.rank !== index + 1 || saved.score !== row.blood || saved.ledgerDigest && saved.ledgerDigest !== digest)
                            throw Error('Thứ hạng hoặc sổ điểm khác snapshot thưởng cũ; chưa phát lại.');
                        continue;
                    }
                    if (!reward.reward.every(([t, id, n]) => Number.isSafeInteger(n) && n > 0 && (t === 6 && inventoryRewardItem(readConfigSync('item')[id]) || t === 108 && readConfigSync('equip_gem_fate_stone')[id])))
                        throw Error('Thưởng Huyết Tinh có dependency chưa xác minh; chưa gửi một phần.');
                    const mail = 'aether-final-' + createHash('sha256').update(e.id + ':' + group.group_id + ':' + row.user_id).digest('hex').slice(0, 32);
                    this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(row.user_id, mail, `Thưởng Huyết Tinh Aether · mùa ${e.version}\nChiến trường ${group.group_id}, hạng ${index + 1}, ${row.blood} điểm.`, JSON.stringify(reward.reward));
                    this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'personal-final',?,?,?)").run(e.id, row.user_id, key, JSON.stringify({ event: e.id, groupId: group.group_id, rank: index + 1, score: row.blood, mail, rewards: reward.reward, ledgerDigest: digest, eligibility: 'SEASON_BATTLE_AWARDS' }), this.now());
                    delivered++;
                }
                if (delivered)
                    audit(this.db, null, 'aether.settlement.personal', null, 'Kết toán Huyết Tinh theo biên nhận chiến trường của mùa, không theo thành viên hiện tại', null, { event: e.id, groupId: group.group_id, ledgerDigest: digest, recipients: scores.length, delivered });
                this.db.exec('COMMIT');
            }
            catch (cause) {
                this.db.exec('ROLLBACK');
                throw cause;
            }
        }
    }
    squad(user, team, guild, event, offset) {
        const row = this.db.prepare('SELECT state FROM aether_formations WHERE event_id=? AND user_id=?').get(event.id, user), state = row ? JSON.parse(String(row.state)) : godfieldState(this.db, user), x = godfieldCombatTeam(this.db, user, team, offset, state);
        return { user, team, guild, entities: x.entities, formation: x.formation, equipment: x.equipment, profile: x.profile, role: String(x.session.role) };
    }
    freeze(e, time) {
        const p = aetherPhase(e.start_at, e.end_at, time);
        if (![10, 9].includes(p.step))
            return;
        const day = aetherDay(time), cities = this.db.prepare('SELECT * FROM aether_cities WHERE event_id=? AND attacker_id IS NOT NULL ORDER BY group_id,city_id').all(e.id);
        for (const c of cities) {
            if (this.db.prepare('SELECT 1 FROM aether_wars WHERE event_id=? AND group_id=? AND city_id=? AND day=?').get(e.id, c.group_id, c.city_id, day))
                continue;
            this.db.exec('BEGIN IMMEDIATE');
            try {
                const queues = (guild, kind, offset) => this.db.prepare(`SELECT d.user_id,d.team FROM aether_deployments d WHERE d.event_id=? AND d.city_id=? AND d.kind=? AND (EXISTS(SELECT 1 FROM alliance_members m WHERE m.user_id=d.user_id AND m.alliance_id=?) OR EXISTS(SELECT 1 FROM aether_mercenaries m WHERE m.event_id=d.event_id AND m.user_id=d.user_id AND m.guild_id=? AND m.status='active')) ORDER BY d.priority,d.rowid`).all(e.id, c.city_id, kind, guild, guild).map(r => this.squad(Number(r.user_id), Number(r.team), guild, e, offset));
                let state = { attacker: Number(c.attacker_id), defender: Number(c.owner_id ?? 0), attack: [], defend: [], duels: 0 };
                let error = null;
                try {
                    state.attack = queues(state.attacker, 'attack', 0);
                    state.defend = queues(state.defender, 'defend', 100);
                    const scienceLevel = (gid) => Number(this.db.prepare('SELECT science_level FROM aether_guilds WHERE event_id=? AND guild_id=?').get(e.id, gid)?.science_level ?? 0);
                    for (const squad of [...state.attack, ...state.defend]) {
                        const modifiers = aetherScienceCombat(scienceLevel(squad.guild), squad.guild === state.defender ? aetherConfig('build')[c.city_id].buff1 : []);
                        buffCity(squad, { buff1: modifiers.buffs });
                        squad.pollutionReduction = modifiers.pollutionReduction;
                    }
                    if (!c.owner_id) {
                        if (simEnabled(this.db, e)) {
                            const cfg = readConfigSync('enemy_detail')[79001];
                            if (!cfg)
                                throw Error('Thiếu NPC79001 nguồn VN.');
                            state.simulation = simPolicy.version;
                            state.defend = [{ user: 0, team: 1, guild: 0, entities: [serializeEntity(100, 'qa-neutral-79001', 79001, cfg, cfg, [])], formation: { formation: { current: 1 }, equip_pos: {} }, equipment: {}, profile: { show_name: 'Quân trung lập · mô phỏng LOCAL', level: cfg.lv }, role: '1' }];
                        }
                        else
                            error = 'Quân trung lập battle_id79001 có skill69010/69020 nhưng handler/đội hình server chưa đủ nguồn; chưa tự xử thắng.';
                    }
                    if (!error)
                        state.snapshotVerified = true;
                }
                catch (cause) {
                    error = cause instanceof Error ? cause.message : 'Không thể chụp đội hình hợp lệ.';
                }
                this.db.prepare('INSERT INTO aether_wars VALUES(?,?,?,?,?,?,?,?,?,?)').run(`${e.id}:${day}:${c.group_id}:${c.city_id}`, e.id, c.group_id, c.city_id, day, error ? 'blocked' : 'ready', JSON.stringify(state), error, this.now(), this.now());
                this.db.exec('COMMIT');
            }
            catch (cause) {
                this.db.exec('ROLLBACK');
                throw cause;
            }
        }
    }
    tick() {
        if (this.db.isTransaction)
            throw Error('Worker Aether không được chạy lồng giao dịch.');
        let current;
        try {
            current = aetherEvent(this.db, this.now());
        }
        catch { /* Vẫn kiểm mùa lịch sử đã lưu khi không có mùa mới. */ }
        if (current && simEnabled(this.db, current) && !aetherPhase(current.start_at, current.end_at, Number(current.qa_time) + this.now() - Number(current.qa_updated)).ended)
            new AetherService(this.db, this.now).simulation(current).objectives.tick();
        const result = current ? this.advance(current) : { processed: 0 };
        if (current && simEnabled(this.db, current))
            new AetherService(this.db, this.now).simulation(current).core.guildFinal();
        // Một job/mùa cũ mỗi tick, chỉ LOCAL realm này và mùa thường đã hết hạn.
        // Không tự mở lại mùa QA đã đóng hay lấy đội hình hiện tại cho trận cũ.
        const previous = this.db.prepare(`SELECT e.* FROM aether_events e WHERE e.realm_id='local-1' AND e.qa=0 AND e.end_at<? AND e.id<>? AND (
   EXISTS(SELECT 1 FROM aether_wars w WHERE w.event_id=e.id AND w.status IN('ready','running')) OR
   EXISTS(SELECT 1 FROM aether_score_awards a WHERE a.event_id=e.id AND NOT EXISTS(SELECT 1 FROM aether_claims c WHERE c.event_id=a.event_id AND c.user_id=a.user_id AND c.kind='personal-final' AND c.claim_key=CAST(a.group_id AS TEXT))
    AND NOT EXISTS(SELECT 1 FROM aether_wars w WHERE w.event_id=e.id AND w.group_id=a.group_id AND w.status<>'done')
    AND NOT EXISTS(SELECT 1 FROM aether_cities c WHERE c.event_id=e.id AND c.group_id=a.group_id AND c.attacker_id IS NOT NULL))) ORDER BY e.end_at,e.id LIMIT 1`).get(this.now(), current?.id ?? '');
        if (previous) {
            const old = this.advance(previous);
            return { ...result, historical: previous.id, historicalProcessed: old.processed };
        }
        return result;
    }
    advance(event) {
        const time = event.qa ? Number(event.qa_time) + this.now() - Number(event.qa_updated) : this.now();
        this.freeze(event, time);
        // Sau downtime có thể đã qua cửa sổ kết toán: tiếp tục job đã khóa,
        // không tạo trận mới từ đội hình hiện tại hoặc phát thưởng cho nhóm bị blocked.
        const phase = aetherPhase(event.start_at, event.end_at, time);
        if (![9, 8, 3, 7].includes(phase.step) && !phase.ended)
            return { processed: 0 };
        const war = this.db.prepare("SELECT * FROM aether_wars WHERE event_id=? AND status IN('ready','running') ORDER BY day,group_id,city_id LIMIT 1").get(event.id);
        if (!war) {
            if (phase.step === 7 || phase.ended)
                this.settlePersonal(event);
            return { processed: 0 };
        }
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const state = JSON.parse(war.state), a = state.attack[0], d = state.defend[0];
            let lastWinner;
            if (a && d) {
                const id = war.id + ':' + state.duels, seed = createHash('sha256').update(id).digest().readUInt32LE(), sim = simulateBattle([...a.entities, ...d.entities], seed, { carry: true });
                const winner = sim.winner === 0 ? a : d, loser = sim.winner === 0 ? d : a, won = sim.winner === 0;
                const packet = { battle: { ...sim.battle, init: { ...sim.battle.init, atk_name: a.profile.show_name, dfd_name: d.profile.show_name, atk_lv: a.profile.level, dfd_lv: d.profile.level, atk_role: a.role, dfd_role: d.role, aform: a.formation.formation.current, dform: d.formation.formation.current, equip_att: a.equipment, equip_def: d.equipment, equip_pos_att: a.formation.equip_pos, equip_pos_def: d.formation.equip_pos } } };
                const uid = (id) => id ? String(this.db.prepare('SELECT game_uid FROM player_profiles WHERE user_id=?').get(id).game_uid) : 'QA-NPC:79001', guild = (id) => id ? String(this.db.prepare('SELECT name FROM alliances WHERE id=?').get(id).name) : 'Trung lập · mô phỏng LOCAL';
                const meta = { city: String(war.city_id), att_uid: uid(a.user), def_uid: uid(d.user), att_guild_name: guild(a.guild), def_guild_name: guild(d.guild), att_team: a.team, def_team: d.team, is_win: won ? 1 : 0, des: `${a.profile.show_name} ${won ? 'chiến thắng' : 'thất bại trước'} ${d.profile.show_name}`, seed, rounds: sim.rounds, lifeEvents: sim.lifeEvents, remaining: sim.remaining, ...(state.simulation ? { simulation: state.simulation } : {}) };
                this.db.prepare('INSERT INTO aether_battles VALUES(?,?,?,?,?,?,?)').run(id, event.id, war.group_id, war.city_id, JSON.stringify(packet), JSON.stringify(meta), this.now());
                const award = winner.user ? awardAetherVictory(this.db, { event: event.id, group: war.group_id, city: war.city_id, day: war.day, user: winner.user, team: winner.team, battle: id }, this.now()) : { wins: 0, total: 0, delta: 0, replayed: false };
                if (loser.user)
                    closeAetherStreak(this.db, event.id, war.group_id, war.city_id, war.day, loser.user, loser.team);
                if (winner.user)
                    meta.blood = { user: winner.user, ...award };
                winner.entities = (sim.carry ?? []).filter(x => (x.index < 100) === won);
                lastWinner = winner.guild;
                state[won ? 'defend' : 'attack'].shift();
                state.duels++;
                // Ô nhiễm tăng theo số lần đánh liên tiếp; áp lên HP còn lại trước đối thủ
                // kế tiếp. Ngân sách hồi sinh/cooldown không mang sang simulateBattle mới.
                if (state[won ? 'defend' : 'attack'].length) {
                    const base = Number(aetherConfig('build')[war.city_id].radiation), reduction = Number(winner.pollutionReduction ?? 0), effective = Math.max(0, base - reduction), before = winner.entities.map(x => ({ hero: x.card.id, hp: x.hp }));
                    winner.entities = aetherPollution(winner.entities, Number(award.wins), effective);
                    meta.pollution = { base, reduction, effective, consecutiveWins: award.wins, accumulated: Math.min(100, Number(award.wins) * effective), before, after: winner.entities.map(x => ({ hero: x.card.id, hp: x.hp })) };
                    if (!winner.entities.some(x => x.index % 100 < 5)) {
                        if (winner.user)
                            closeAetherStreak(this.db, event.id, war.group_id, war.city_id, war.day, winner.user, winner.team);
                        state[won ? 'attack' : 'defend'].shift();
                    }
                }
                this.db.prepare('UPDATE aether_battles SET metadata=? WHERE id=?').run(JSON.stringify(meta), id);
            }
            const finished = !state.attack.length || !state.defend.length;
            if (finished) {
                const owner = state.attack.length ? state.attacker : state.defend.length ? state.defender : lastWinner ?? state.defender;
                this.db.prepare('UPDATE aether_cities SET owner_id=?,attacker_id=NULL WHERE event_id=? AND group_id=? AND city_id=?').run(owner || null, event.id, war.group_id, war.city_id);
                this.db.prepare("DELETE FROM aether_deployments WHERE event_id=? AND city_id=? AND kind IN('attack','defend') AND user_id IN(SELECT user_id FROM alliance_members WHERE alliance_id IN(?,?) UNION SELECT user_id FROM aether_mercenaries WHERE event_id=? AND guild_id IN(?,?) AND status='active')").run(event.id, war.city_id, state.attacker, state.defender, event.id, state.attacker, state.defender);
                state.owner = owner;
            }
            this.db.prepare('UPDATE aether_wars SET state=?,status=?,updated_at=? WHERE id=?').run(JSON.stringify(state), finished ? 'done' : 'running', this.now(), war.id);
            this.db.exec('COMMIT');
            return { processed: 1, finished, id: war.id };
        }
        catch (cause) {
            this.db.exec('ROLLBACK');
            this.db.prepare("UPDATE aether_wars SET status='blocked',error=?,updated_at=? WHERE id=?").run(cause instanceof Error ? cause.message : 'Engine Aether chưa kết toán.', this.now(), war.id);
            return { processed: 0, blocked: war.id };
        }
    }
}
