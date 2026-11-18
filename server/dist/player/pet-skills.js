import { petConfig } from './pet-source.js';
import { advancedPetFamily, petCombatRules } from './pet-advanced.js';
// Dữ liệu/nhánh VN, hiệu ứng thiếu server dùng policy LOCAL đã chốt.
export function petSkillPlan(id) {
    const cfg = petConfig('pet_skill_detail')[id];
    if (!cfg)
        return;
    const sprite = cfg.sprite_py, base = { id, cfg, coefficient: (lv) => (cfg.effect + cfg.effect_lvchange * lv) / 100 };
    const plans = { PetSkill_1_s1: { target: 'one', stat: 'matk', poison: { percent: 5, capPercent: 50, duration: 3 } }, PetSkill_2_s1: { target: 'row', stat: 'patk', stun: 1 }, PetSkill_3_s1: { target: 'all', stat: 'matk', slow: 20, duration: 2 }, PetSkill_4_s1: { target: 'column', stat: 'matk' }, PetSkill_5_s1: { target: 'all', stat: 'matk' }, PetSkill_6_s1: { target: 'front', stat: 'matk' }, PetSkill_1_s2: { modifiers: [['def', 'def', 1]] }, PetSkill_2_s2: { modifiers: [['patk', 'patk', 1]] }, PetSkill_3_s2: { modifiers: [['matk', 'matk', 1], ['def', 'def', 1]] }, PetSkill_4_s2: { modifiers: [['def', 'def', -1]] }, PetSkill_4_s3: { modifiers: [['def', 'def', -1]] }, PetSkill_5_s2: { modifiers: [['matk', 'matk', -1], ['def', 'def', -1]] }, PetSkill_6_s2: { modifiers: [['speed', 'speed', -1]] } };
    return plans[sprite] ? { ...base, ...plans[sprite] } : advancedPetFamily(sprite) ? { ...base, extension: true, family: sprite, rulesVersion: petCombatRules.version } : undefined;
}
export const petSkillSupported = (id) => !!petSkillPlan(id);
