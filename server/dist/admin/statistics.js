import { CombatPowerService } from '../player/combat-power.js';
import { godfieldState, godfieldTeam } from '../player/godfield.service.js';
import { readConfigSync } from '../player/local-content.js';
import { adminError } from './admin.audit.js';
export function statistics(db, userId, team = 0) {
    if (!Number.isSafeInteger(userId) || userId < 1 || !db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(userId))
        adminError('Không tìm thấy người chơi đã vào game.', 404);
    if (!Number.isInteger(team) || team < 0 || team > 3)
        adminError('Chọn Main hoặc một trong ba đội Thần Vực.');
    const service = new CombatPowerService(db), result = team ? service.calculate(userId, false, { formation: godfieldTeam(godfieldState(db, userId), team), scope: 'godfield' }) : service.calculate(userId, true), defs = readConfigSync('character_detail');
    return { ...result, heroes: result.heroes.map(h => ({ ...h, name: defs[h.configId]?.name ?? '#' + h.configId, sourceBase: Object.fromEntries(['hp', 'patk', 'matk', 'def', 'speed'].map(f => [f, Number(defs[h.configId]?.['base_' + f] ?? 0)])), progressionDelta: Object.fromEntries(['hp', 'patk', 'matk', 'def', 'speed'].map(f => [f, h.breakdown.base[f] - Number(defs[h.configId]?.['base_' + f] ?? 0)])) })), at: Date.now(), version: 'attributes-v2', team, weights: readConfigSync('combat_base'), notice: 'Chỉ đọc; chênh tiến trình là state đã lưu trừ nền config, gồm nâng cấp/kế thừa chứ không suy riêng một công thức. Đá và bind_data dùng %, chain dùng phần nghìn. Trigger PET/Thần Thú không cộng CP thường trực.', limitations: ['Các bộ xử lý combat LOCAL và giới hạn công thức vẫn theo checkpoint nguồn; không tuyên bố engine gốc 100%.', 'Đá chỉ hoạt động khi trang bị đang mặc, khóa hai chiều đúng tướng và đúng loại ô.', 'Hiệu ứng Rèn trừ địch và modifier thiếu handler không được biến thành bonus thường trực.'] };
}
