import { battleSkillRegistration } from './battle-skill-registry.js';
export function appearanceState(db, userId) {
    const rows = db.prepare('SELECT skin_id,attribute,equipped FROM player_skins WHERE user_id=?').all(userId);
    return { skin: Object.fromEntries(rows.map(r => [String(r.skin_id), JSON.parse(String(r.attribute))])), used_skin: rows.filter(r => r.equipped === 1).map(r => Number(r.skin_id)) };
}
export function battleAppearance(db, userId, h, defs, skills) {
    const base = defs[h.c_id], state = appearanceState(db, userId), skinId = state.used_skin.find(id => id === base?.is_skin || !!defs[id] && String(defs[id].character_ID) === String(base?.character_ID)), skin = skinId ? defs[skinId] : null, cfg = skin ?? base;
    // Transport cards ẩn _local_*; đọc bank/selection đúng owner thay vì suy đoán
    // s1 tương ứng source1 (sai khi người chơi chọn2–4–5).
    const saved = h.id ? db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(userId, h.id) : undefined;
    const registration = battleSkillRegistration(saved ? JSON.parse(String(saved.state)) : h, base, skills);
    const active = registration.active.map(s => {
        const meta = { runtimeSlot: s.runtimeSlot, sourceSlot: s.sourceSlot, origin: s.origin, requiredStage: s.requiredStage, skinActive: !!skin };
        if (!skin)
            return { id: s.s, lv: s.lv, cfg: skills[s.s], ...meta };
        let mapped = 0;
        for (let slot = 1; slot <= 7 && !mapped; slot++) {
            let old = base['skill_' + slot + '_source']?.[0]?.[0], next = skin['skill_' + slot + '_source']?.[0]?.[0];
            for (let depth = 0; old && next && depth < 70; depth++) {
                if (old === s.s) {
                    mapped = next;
                    break;
                }
                old = skills[old]?.is_evolution;
                next = skills[next]?.is_evolution;
            }
        }
        if (!mapped || !skills[mapped])
            throw Object.assign(new Error('Skin thiếu mapping skill tương ứng.'), { statusCode: 422 });
        return { id: mapped, lv: Math.min(s.lv, skills[mapped].max_lv), cfg: skills[mapped], ...meta };
    });
    return { configId: skin ? skinId : h.c_id, cfg, skills: active, registration };
}
