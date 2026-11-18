import { readConfigSync as cfg } from './local-content.js';
const configs = new Map();
export function battleSkillConfig(name) { const key = [process.env.LOCAL_HERO_EXTENSIONS, process.env.RECOVERED_HERO_BATCHES, process.env.VN_RUNTIME_CONTENT, name].join('|'); if (!configs.has(key))
    configs.set(key, cfg(name)); return configs.get(key); }
export const skillSourceSlots = (c) => Number(c.skill_num) === 5 ? [1, 2, 3, 6, 7] : [1, 2, 3];
export function sourceSkillChain(c, slot, skills) {
    const sources = c['skill_' + slot + '_source'];
    if (!Array.isArray(sources) || sources.length !== 1)
        return [];
    const result = [], seen = new Set();
    let id = Number(sources[0][0]);
    while (id && !seen.has(id) && result.length < 80 && skills[id]) {
        seen.add(id);
        result.push(id);
        id = Number(skills[id].is_evolution);
    }
    return result;
}
// Projection theo config, không ghi hero/không tự mua kỹ năng. Siêu skill chỉ mở
// khi đạt mốc của đúng hero; sửa cả bản lưu cũ có s4/s5 tồn tại nhưng avail=0.
export function superSkillProjection(h, c, skills = battleSkillConfig('skill_detail'), supers = battleSkillConfig('super_evolution')) {
    const result = {}, rule = supers[c.super_evo];
    for (const slot of [4, 5]) {
        const id = sourceSkillChain(c, slot, skills)[0] ?? 0, old = h['s_' + slot], gate = Number(rule?.['skill' + slot + '_open']), eligible = !!id && Number.isInteger(gate) && gate > 0 && Number(h.super_step ?? 0) >= gate;
        const valid = old && sourceSkillChain(c, slot, skills).includes(Number(old.s));
        result['s_' + slot] = { ...(valid ? old : {}), s: valid ? Number(old.s) : id, lv: Math.min(Math.max(1, Number(valid ? old.lv : 1) || 1), skills[valid ? old.s : id]?.max_lv ?? 1), exp: valid ? old.exp ?? 0 : 0, avail: eligible ? 2 : 0 };
    }
    return result;
}
export function battleSkillRegistration(h, c, skills = battleSkillConfig('skill_detail')) {
    const slots = skillSourceSlots(c), selection = h._local_skill_selection ?? [1, 2, 3], bank = h._local_skill_bank, issues = [], entries = [];
    const selected = Array.isArray(selection) && selection.length === 3 && new Set(selection).size === 3 && selection.every(n => Number.isInteger(n) && n >= 1 && n <= slots.length);
    if (!selected)
        issues.push('INVALID_SLOT_MAPPING: bộ chọn phải có ba vị trí khác nhau trong nguồn của hero.');
    if (selected)
        for (let i = 0; i < 3; i++) {
            const choice = selection[i], sourceSlot = slots[choice - 1], s = bank?.[choice - 1] ?? h['s_' + (i + 1)], chain = sourceSkillChain(c, sourceSlot, skills);
            const valid = !!s && chain.includes(Number(s.s)), available = valid && s.avail === 2;
            if (s?.s && !valid)
                issues.push('INVALID_SLOT_MAPPING: runtime' + (i + 1) + ' không thuộc source' + sourceSlot + '.');
            entries.push({ runtimeSlot: i + 1, selectionSlot: choice, sourceSlot, origin: sourceSlot >= 6 ? 'PURCHASED' : 'NATIVE', ...s, registered: available, reason: !valid ? 'INVALID_SLOT_MAPPING' : !available ? 'LOCKED' : 'REGISTERED' });
        }
    const projected = superSkillProjection(h, c, skills), rule = battleSkillConfig('super_evolution')[c.super_evo];
    for (const slot of [4, 5])
        entries.push({ runtimeSlot: slot, sourceSlot: slot, origin: 'SUPER_EVOLUTION', requiredStage: rule?.['skill' + slot + '_open'] ?? null, ...projected['s_' + slot], registered: projected['s_' + slot].avail === 2, reason: projected['s_' + slot].avail === 2 ? 'REGISTERED' : 'LOCKED' });
    const seen = new Set();
    return { entries, issues, active: entries.filter(e => { if (!e.registered || seen.has(e.s))
            return false; seen.add(e.s); return true; }) };
}
