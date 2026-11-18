import { PlayerService, staticConfig } from './player.service.js';
import { MapAccessService } from './map-access.js';
import { localCombatRules, serializeEntity, combatSkillDiagnostics } from './local-combat.js';
import { battleAppearance } from './appearance-state.js';
import { CombatPowerService } from './combat-power.js';
// Chẩn đoán chỉ đọc, không phải battle-start và không cấp thắng/thưởng.
export async function battlePreflight(db, userId, q) {
    const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
    if (!Number.isSafeInteger(userId) || userId < 1)
        fail('Tài khoản không hợp lệ.');
    const target = db.prepare('SELECT user_id,game_uid,role FROM player_profiles WHERE user_id=?').get(userId);
    if (!target || !db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(userId))
        fail('Tài khoản chưa có trạng thái game.');
    const city = String(q.city ?? ''), building = String(q.building ?? ''), step = Number(q.step ?? 0);
    if (!/^\d{1,6}$/.test(city) || !/^\d{1,10}$/.test(building) || !Number.isInteger(step) || step < 0 || step > 100)
        fail('City/building/step không hợp lệ.');
    const access = new MapAccessService(db), enemies = await access.enemies(userId, city, building), title = (await staticConfig('map_title_detail'))[building];
    const tuple = title.fight_list[step];
    if (!tuple)
        fail('Step chưa có trong fight_list của công trình.');
    const fightId = String(tuple[1]), fight = enemies.map_fight[fightId];
    if (!fight)
        fail('Thiếu config trận.');
    const players = new PlayerService(db), cards = players.cards(target), profile = players.profile(target, {}), ids = cards.alignment.flat().filter((id) => id !== '-1' && id !== '0');
    const canonical = new Map(new CombatPowerService(db).calculate(userId).heroes.map(h => [h.id, h.attributes])), defs = await staticConfig('character_detail'), skills = await staticConfig('skill_detail');
    const combatants = ids.map((id, index) => { const h = cards.cards[id]; if (!h)
        fail('Trận hình có tướng không thuộc tài khoản.'); const attrs = canonical.get(id), appearance = battleAppearance(db, userId, h, defs, skills), entity = serializeEntity(index, id, appearance.configId, { ...h, ...attrs }, appearance.cfg, appearance.skills); return { id, configId: h.c_id, appearanceConfigId: appearance.configId, level: h.lv, stats: attrs, registration: appearance.registration, skillDiagnostics: combatSkillDiagnostics(entity), skills: Object.fromEntries(Object.entries(h).filter(([k]) => /^s_[1-7]$/.test(k))) }; });
    return { evidence: 'SERVER VERIFIED', status: ids.length ? 'LOCAL_SIMULATOR_READY' : 'BLOCKED', rules: localCombatRules, city, building, step, fightId, formation: cards.alignment, combatants, equipment: cards.equip_pos,
        enemies, actionPoint: profile.action_point ?? 0, configuredCost: title.action_point ?? null, fightConfig: fight,
        blockers: ids.length ? [] : ['Đội hình trống.'],
        notice: 'Tiền kiểm chỉ đọc. Recapture dùng simulator LOCAL có công thức riêng; không phải engine production. Preview không trừ thể lực hoặc cấp thưởng.' };
}
