import { petConfig, petFail } from './pet-source.js';
// pet_evolution.skill yêu cầu cấp nhánh, không phải nhảy theo một liên kết hỏng.
// VN2410/2510 trỏ thẳng skill cấp3 dù bảng còn cấp2 và evo_story3sao.
// Chỉ chọn khi cùng sprite + phẩm + mốc sao xác định được đúng một dòng nguồn.
export function petSkillTier(config, slot, tier) {
    const base = Number(config['skill_' + slot + '_source']?.[0]?.[0]), rows = petConfig('pet_skill_detail'), first = rows[base];
    if (!first || !Number.isInteger(tier) || tier < 0 || tier > 3)
        petFail('Thiếu cấp nhánh kỹ năng PET từ nguồn.');
    if (tier <= 1)
        return base;
    const star = slot === 1 ? (tier === 2 ? 3 : 5) : 4;
    const candidates = Object.entries(rows).filter(([, r]) => r.sprite_py === first.sprite_py && r.skill_quality === first.skill_quality + tier - 1 && new RegExp('\\b' + star + '\\s*Sao\\b', 'i').test(r.evo_story ?? ''));
    if (candidates.length !== 1)
        petFail('Nhánh kỹ năng PET không có một dòng nguồn duy nhất cho mốc sao.');
    return Number(candidates[0][0]);
}
export function petSkillsAtStar(state) {
    const cfg = petConfig('pet_detail')[state.c_id], tiers = petConfig('pet_evolution')[state.star]?.skill;
    if (!cfg || !tiers)
        petFail('PET có mốc sao không hợp lệ.');
    const copy = { ...state };
    for (const n of [1, 2])
        copy['s_' + n] = { ...state['s_' + n], s: petSkillTier(cfg, n, tiers[n - 1]), step: Math.max(1, tiers[n - 1]), avail: tiers[n - 1] ? 2 : 0 };
    return copy;
}
