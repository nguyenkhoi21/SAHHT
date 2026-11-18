import { petSkillsAtStar } from './pet-skill-tier.js';
import { randomUUID } from 'node:crypto';
import { petConfig, petFail } from './pet-source.js';
export const petFields = ['patk', 'matk', 'def', 'speed', 'hp'];
export function petAttributes(state) { const c = petConfig('pet_detail')[state.c_id]; if (!c)
    petFail('Thú nuôi không có trong nguồn VN.'); const stats = {}; for (const f of petFields) {
    let value = c['base_' + f] + (state.lv - 1) * c['growth_' + f];
    for (let star = c.star + 1; star <= state.star; star++)
        value += petConfig('pet_evolution')[star]['type' + c.type][petFields.indexOf(f)];
    value += petConfig('pet_strengthen')[state[f + '_crystal']]?.['add_' + f] ?? 0;
    stats[f] = Math.floor(value);
} return stats; }
export function createPet(cid) { const c = petConfig('pet_detail')[cid]; if (!c)
    petFail('ID PET không hợp lệ.'); const state = { id: 'pet-' + randomUUID().replaceAll('-', ''), c_id: cid, lv: 1, exp: 0, star: c.star, evo: 0, step: 0, refresh_num: 0, is_refresh: false, ...Object.fromEntries(petFields.map(f => [f + '_crystal', 0])) }; for (let n = 1; n <= 2; n++) {
    const sid = c['skill_' + n + '_source']?.[0]?.[0];
    if (!petConfig('pet_skill_detail')[sid])
        petFail('PET thiếu định nghĩa kỹ năng.');
    state['s_' + n] = { s: sid, lv: 1, exp: 0, avail: petConfig('pet_evolution')[state.star].skill[n - 1] > 0 ? 2 : 0, step: 1 };
} return petSkillsAtStar(state); }
export function projectPet(s) { const c = petConfig('pet_detail')[s.c_id], e = petConfig('pet_evolution')[s.star]; return { ...petSkillsAtStar(s), ...petAttributes(s), level_max: Math.max(c.level_max, e.maxlv), quality: c.quality }; }
export function petOwned(db, user) { return Object.fromEntries(db.prepare('SELECT id,state FROM player_pets WHERE user_id=? ORDER BY rowid').all(user).map(r => [String(r.id), projectPet(JSON.parse(String(r.state)))])); }
export function petFormation(db, user) { const r = db.prepare('SELECT state FROM player_pet_formation WHERE user_id=?').get(user); if (r)
    return JSON.parse(String(r.state)); const profile = JSON.parse(String(db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(user)?.profile ?? '{}')); return { pet_pos: Array.from({ length: 9 }, (_, i) => { const c = petConfig('pet_corral')[i + 1]; return c?.is_open && profile.level >= c.limit_lv ? '0' : '-1'; }), pet_follow_pos: Array(9).fill('-1') }; }
export function petWire(db, user) { return { pet: petOwned(db, user), ...petFormation(db, user) }; }
export function petCache(db, user) { const wire = petWire(db, user); return { pets: { pets: { update: wire.pet, remove: [] }, pet_pos: { update: wire.pet_pos }, pet_follow_pos: { update: wire.pet_follow_pos } } }; }
export function grantPets(db, user, cid, count) { if (!db.isTransaction)
    throw Error('Cấp PET cần transaction.'); const c = petConfig('pet_detail')[cid]; if (!c || !Number.isInteger(count) || count < 1 || count > 5)
    petFail('PET/số lượng không hợp lệ.'); const existing = Number(db.prepare('SELECT count(*) n FROM player_pets WHERE user_id=? AND config_id=?').get(user, cid).n); if (c.is_only && (existing || count > 1))
    petFail('Đã sở hữu thú nuôi duy nhất này; chưa nhận hoặc tiêu mảnh.'); const ids = []; for (let i = 0; i < count; i++) {
    const state = createPet(cid);
    db.prepare('INSERT INTO player_pets VALUES(?,?,?,?)').run(user, state.id, cid, JSON.stringify(state));
    ids.push(state.id);
} return ids; }
export function petBonuses(db, user) { const pets = petOwned(db, user), formation = petFormation(db, user), active = pets[formation.pet_pos[0]], deployed = Object.fromEntries(petFields.map(f => [f, active?.[f] ?? 0])), follow = Object.fromEntries(petFields.map(f => [f, 0])); for (const id of formation.pet_follow_pos) {
    const p = pets[id];
    if (!p)
        continue;
    for (const f of petFields)
        follow[f] += p[f] * (0.1 + Number(p.refresh_num ?? 0));
} return { deployed, follow, total: Object.fromEntries(petFields.map(f => [f, deployed[f] + follow[f]])), active }; }
