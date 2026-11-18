import { readFileSync } from 'node:fs';
import { battleSkillConfig, sourceSkillChain } from './battle-skill-registry.js';
const source = JSON.parse(readFileSync(new URL('../../../tools/runtime/phase31-source.json', import.meta.url), 'utf8'));
export function skillVisualTransition(e, s) {
    const c = battleSkillConfig('character_detail')[e.originConfigId ?? e.card.card_id];
    if (!c)
        return null;
    return source.visualTransitions.find((v) => e.skinActive && v.heroId === (e.originConfigId ?? e.card.card_id) && v.skinId === e.card.card_id && c.is_skin === v.skinId && e.card.animation === v.model && v.scripts.includes(s.animationName ?? s.cfg?.sprite_py) && sourceSkillChain(c, v.sourceSlot, battleSkillConfig('skill_detail')).includes(s.id) && Number(e.record.super_step ?? 0) >= Number(battleSkillConfig('super_evolution')[c.super_evo]?.['skill' + v.sourceSlot + '_open'] ?? Infinity)) ?? null;
}
