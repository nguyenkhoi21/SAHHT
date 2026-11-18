import { beastConfig } from './beast-source.js';
// Chỉ mô tả phần có bằng chứng; không suy thời hạn/burn từ tên kỹ năng.
export function beastSkillPlan(id) {
    const cfg = beastConfig('combiner_skill_detail')[id];
    if (!cfg)
        return { supported: false, status: 'SOURCE_BLOCKED', blockers: ['Không có ID trong nguồn Việt Nam.'] };
    const base = id - id % 10, blockers = [], plan = { id, cfg, phase: cfg.skill_type, stat: 'patk', target: 'single' };
    if (base === 110) {
        Object.assign(plan, { damage: true, stat: 'matk' });
        blockers.push('Siêu Nhiên có Choáng nhưng thiếu số hiệp; chỉ nối sát thương, chưa tự gán thời hạn.');
    }
    else if (base === 120)
        Object.assign(plan, { healBalls: 7, target: 'allies', hpThreshold: cfg.trigger_parameter[0] });
    else if (base === 210)
        Object.assign(plan, { damage: true, target: 'allEnemies', stun: 1, roundRange: cfg.trigger_parameter });
    else if (base === 310) {
        Object.assign(plan, { damage: true, stat: 'matk', target: 'allEnemies', firstRound: cfg.trigger_parameter[0] });
        blockers.push('Đốt dãy sau thiếu tỷ lệ HP/số hiệp; chỉ nối sát thương AOE, chưa tạo burn giả.');
    }
    else if (base === 410)
        Object.assign(plan, { damage: true });
    else if ([510, 610, 710].includes(base))
        Object.assign(plan, { damage: true, stat: 'partyHp', target: 'allEnemies', firstRound: 1, killChance: base === 510 ? 50 : 0, guardChance: base === 510 ? 0 : 50 });
    else if (base === 520)
        Object.assign(plan, { killChance: id % 10 === 1 ? 100 : 90, target: 'randomEnemy' });
    else if (base === 620)
        Object.assign(plan, { guardChance: id % 10 === 1 ? 100 : 90, target: 'randomAlly' });
    else if (base === 220)
        Object.assign(plan, { modifiers: [{ stat: 'speed', frame: 'buff_speed', percent: cfg.effect }], target: 'allies', deathCondition: { camp: 'enemy', mode: 'percent', threshold: cfg.trigger_parameter[0] } });
    else if (base === 320)
        Object.assign(plan, { modifiers: [{ stat: 'patk', frame: 'buff_phsc', percent: cfg.effect }, { stat: 'matk', frame: 'buff_mgc', percent: cfg.effect }], target: 'allies', deathCondition: { camp: 'ally', mode: 'moreThanCount', threshold: cfg.trigger_parameter[0] } });
    else if (base === 420) {
        Object.assign(plan, { modifiers: [{ stat: 'def', frame: 'buff_dfs', percent: 0, flat: cfg.effect }], target: 'allies', deathCondition: { camp: 'ally', mode: 'percent', threshold: cfg.trigger_parameter[0] } });
        blockers.push('Mô tả không có dấu %: chỉ cộng effect điểm phòng ngự, chưa có bằng chứng đổi thành effect%.');
    }
    else if (base === 720)
        Object.assign(plan, { triggerLock: 'KBEATTACK', lockChance: id % 10 === 1 ? 100 : 90, target: 'allEnemies' });
    else
        blockers.push('Chưa có handler nguồn.');
    const supported = !!(plan.damage || plan.healBalls || plan.killChance || plan.guardChance || plan.modifiers || plan.triggerLock);
    return { ...plan, supported, status: !supported ? 'SOURCE_BLOCKED' : blockers.length ? 'PARTIAL' : 'IMPLEMENTED', blockers, timingPolicy: cfg.skill_type === 'KBEFOREROUND' ? 'Notice176: mỗi phe một chiêu Thần Thú/hiệp. Adapter LOCAL duyệt thứ tự đội/kỹ năng đã lưu, trước KBEFOREROUND của tướng; ưu tiên server gốc chưa có nguồn. Không chạy khi trận đã kết thúc ở tiền chiến.' : null, coefficientPolicy: 'Dùng effect cơ sở; chưa có mapping cấp Thần Thú→cấp kỹ năng để dùng effect_lvchange.', targetPolicy: plan.target === 'single' ? 'Mục tiêu đầu sân theo engine LOCAL hiện có; chưa có thuật toán chọn server gốc.' : null };
}
export const beastCombatSupported = (id) => beastSkillPlan(id).supported === true;
