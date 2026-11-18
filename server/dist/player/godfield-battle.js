import { PlayerService } from './player.service.js';
import { CombatPowerService } from './combat-power.js';
import { godfieldState, godfieldTeam } from './godfield.service.js';
import { battleAppearance } from './appearance-state.js';
import { serializeEntity, simulateBattle } from './local-combat.js';
import { readConfigSync } from './local-content.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
// Adapter duy nhất từ đội Thần Vực sang engine hiện có; tuyệt đối không ghi
// tạm vào player_state. Dùng cả ba dự bị, đồ và bộ skill/Skin đang sở hữu.
export function godfieldCombatTeam(db, userId, team, offset, state) {
    if (![1, 2, 3].includes(team) || ![0, 100].includes(offset))
        fail('Đội chiến đấu Thần Vực không hợp lệ.');
    const row = db.prepare('SELECT p.user_id,p.game_uid,p.role,u.username,s.profile FROM player_profiles p JOIN users u ON u.id=p.user_id JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?').get(userId);
    if (!row)
        fail('Không có nhân vật tham chiến.');
    const session = row, cards = new PlayerService(db).cards(session), form = godfieldTeam(state ?? godfieldState(db, userId), team), defs = readConfigSync('character_detail'), skills = readConfigSync('skill_detail'), canonical = new CombatPowerService(db).calculate(userId, false, { formation: form, scope: 'godfield' });
    const entities = canonical.heroes.map(h => { const owned = cards.cards[h.id], state = { ...owned, ...h.attributes, combat_empowerment: h.breakdown.empowerLines, combat_auxiliary: h.breakdown.auxiliary.effects }, appearance = battleAppearance(db, userId, owned, defs, skills); return serializeEntity(offset + h.slot, h.id, appearance.configId, state, appearance.cfg, appearance.skills); });
    if (!entities.some(e => e.index % 100 < 5))
        fail('Đội ' + team + ' chưa có tướng chính.');
    const visible = new Set([...Object.values(form.equip_pos).flat(), ...canonical.heroes.flatMap(h => cards.cards[h.id]?.bind_equip ?? [])]);
    const equipment = Object.fromEntries(Object.entries(cards.equip).filter(([id]) => visible.has(id)));
    return { entities, formation: form, equipment, profile: JSON.parse(String(row.profile)), session, power: canonical.combat };
}
export function godfieldRound(db, attackerId, defenderId, attackTeam, defendTeam, seed) {
    if (attackerId === defenderId)
        fail('Không thể tự khiêu chiến.');
    const a = godfieldCombatTeam(db, attackerId, attackTeam, 0), d = godfieldCombatTeam(db, defenderId, defendTeam, 100), sim = simulateBattle([...a.entities, ...d.entities], seed);
    return { ...sim, battle: { ...sim.battle, init: { ...sim.battle.init, aform: a.formation.formation.current, dform: d.formation.formation.current, atk_name: a.profile.show_name, dfd_name: d.profile.show_name, atk_lv: a.profile.level, dfd_lv: d.profile.level, atk_role: a.session.role, dfd_role: d.session.role, equip_att: a.equipment, equip_def: d.equipment, equip_pos_att: a.formation.equip_pos, equip_pos_def: d.formation.equip_pos } }, attackTeam, defendTeam, aPower: a.power, dPower: d.power };
}
export function godfieldThreeRounds(db, attacker, defender, order, seed) {
    if (order.length !== 3 || order.slice().sort().join(',') !== '1,2,3')
        fail('Thứ tự ba đội phải là hoán vị1/2/3.');
    // notice_active167: ba trận thắng hai. Consumer battle_big/result yêu cầu đủ
    // ba log, nên chạy đủ ba trận độc lập; không giữ HP từ một đội sang đội khác.
    const rounds = order.map((team, i) => godfieldRound(db, attacker, defender, team, i + 1, (seed + i) >>> 0));
    return { rounds, wins: rounds.filter(r => r.winner === 0).length, won: rounds.filter(r => r.winner === 0).length >= 2 };
}
