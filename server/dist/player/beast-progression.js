import { beastConfig } from './beast-source.js';
import { abilityFields } from './progression-economy.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export function beastQualityBonus(beast, quality) {
    const rows = beastConfig('combiner_advanced'), stage = quality - beast * 100, result = {};
    if (!Number.isInteger(stage) || stage < 1 || !rows[quality] || rows[quality].quality !== stage)
        fail('Bậc Thần Thú không hợp lệ.');
    // Popup advancement.createInformation hiển thị nature của bậc HIỆN TẠI cho lần chuyển bậc.
    // nature_show không được consumer này dùng. Không cộng đồng thời hai bảng.
    for (let i = 1; i < stage; i++)
        for (const [kind, value] of rows[beast * 100 + i].nature) {
            const field = abilityFields[kind];
            if (!field || !Number.isSafeInteger(value) || value < 0)
                fail('Thiếu nguồn chỉ số tiến cấp.');
            result[field] = (result[field] ?? 0) + value;
        }
    return result;
}
export function beastAdvancement(beast, state) {
    const cfg = beastConfig('combiner')[beast], rows = beastConfig('combiner_advanced'), current = rows[state.quality], next = rows[state.quality + 1];
    beastQualityBonus(beast, state.quality);
    if (!next || Math.floor((state.quality + 1) / 100) !== beast)
        return { max: true, ready: false, current: state.quality, next: null, requirements: [], skills: current.skill };
    const label = String(current.des1).match(/nguyên liệu (Lam|Tím|Cam|Đỏ|Kim) hoặc cao hơn/iu)?.[1], colors = { lam: 2, 'tím': 3, cam: 4, 'đỏ': 5, kim: 6 }, required = label ? colors[label.toLocaleLowerCase('vi')] : undefined;
    if (!required)
        fail('Chưa xác minh phẩm nguyên liệu tiến cấp.');
    const requirements = cfg.combine_card.map((row) => { const id = row[1], god = state.beast_gods[id], evo = god && beastConfig('combiner_evo')[god.quality_config], quality = evo?.quality ?? 0; if (!evo)
        fail('Thiếu trạng thái thẻ dung hợp #' + id); return { id, quality, required, met: quality >= required }; });
    const materialCosts = new Map();
    let requiredBeastLevel = 1;
    for (const requirement of requirements) {
        let row = state.beast_gods[requirement.id]?.quality_config;
        while (row && beastConfig('combiner_evo')[row]?.quality < required) {
            const cost = beastConfig('combiner_evo')[row];
            requiredBeastLevel = Math.max(requiredBeastLevel, cost.level);
            for (const tuple of [...cost.need, ...cost.advanced_item, [5, requirement.id, cost.advanced]]) {
                if (tuple[2] <= 0)
                    continue;
                const key = tuple[0] + ':' + tuple[1], total = materialCosts.get(key) ?? [tuple[0], tuple[1], 0];
                total[2] += tuple[2];
                materialCosts.set(key, total);
            }
            row++;
        }
    }
    return { max: false, current: state.quality, next: state.quality + 1, requiredQuality: required, requiredLabel: label, ready: requirements.every((r) => r.met), requirements, materialCosts: [...materialCosts.values()], requiredBeastLevel, skills: next.skill, bonus: current.nature, additionalCost: [], source: 'combiner_advanced.des1/skill/nature; game_combiner_advancement.createInformation/onMainBtnClick', attributePolicy: 'Cộng nature của từng bậc đã chuyển theo popup gốc; không cộng nature_show. Chưa có packet server gốc để xác nhận tuyệt đối.' };
}
