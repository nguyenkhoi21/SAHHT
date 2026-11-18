import { battleSkillConfig } from './battle-skill-registry.js';
const normalize = (s) => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/đ/g, 'd');
const identity = (s) => normalize(s).replace(/^ct\s*-\s*/, '').replace(/kakalot/g, 'kakarot').replace(/[^a-z0-9]/g, '');
// Danh sách phe có tên rõ trong tooltip, không suy “race” thành phe chiến đấu.
export function dragonBallContext(owner, party) {
    if (!party)
        return null;
    const row = battleSkillConfig('skill_detail')[77020], text = normalize(String(row?.skill_story ?? '')), list = text.match(/phe ngoc rong bao gom:\s*([^()]+)/)?.[1];
    if (!list)
        return null;
    const names = new Set(list.split('/').map(identity));
    const defs = battleSkillConfig('character_detail'), count = party.filter(e => e.hp > 0 && e.index % 100 < 5 && (e.index < 100) === (owner.index < 100) && names.has(identity(String(defs[e.originConfigId ?? e.card.card_id]?.name ?? '')))).length;
    return { count, source: 'skill_detail#77020: danh sách phe Ngọc Rồng' };
}
