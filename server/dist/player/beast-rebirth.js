import { createHash } from 'node:crypto';
import { beastConfig, beastSource } from './beast-source.js';
import { readConfigSync } from './local-content.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export function beastLevelInvestment(state) {
    const base = beastConfig('combiner_base'), cap = Math.max(...Object.keys(base).map(Number));
    if (!Number.isInteger(state.level) || state.level < 1 || state.level > cap || !Number.isSafeInteger(state.exp) || state.exp < 0)
        fail('Trạng thái EXP Thần Thú không hợp lệ.');
    if (state.level < cap && state.exp >= base[state.level].exp || state.level === cap && state.exp !== 0)
        fail('EXP Thần Thú vượt ngưỡng cấp hiện tại.');
    let stored = state.exp;
    for (let level = 1; level < state.level; level++) {
        const need = base[level]?.exp;
        if (!Number.isSafeInteger(need) || need <= 0)
            fail('Thiếu ngưỡng EXP Thần Thú.');
        stored += need;
    }
    if (!Number.isSafeInteger(stored))
        fail('EXP Thần Thú vượt giới hạn an toàn.');
    if (state.levelFeedExp !== undefined) {
        if (!Number.isSafeInteger(state.levelFeedExp) || state.levelFeedExp < stored || state.level < cap && state.levelFeedExp !== stored)
            fail('Lịch sử EXP Thần Thú không khớp; chưa Tái Sinh.');
        return state.levelFeedExp;
    }
    // Bản cũ bỏ EXP tràn khi đạt cap; không thể đoán phần nguyên liệu đã mất khỏi state.
    if (state.level === cap)
        fail('Thú tối đa cấp từ bản cũ thiếu ledger EXP tràn; cần đối chiếu lịch sử trước Tái Sinh.');
    return stored;
}
export function beastRebirthPlan(beast, state) {
    const rule = beastSource().userConfirmedRules, material = readConfigSync('character_detail')[56];
    if (!rule.rebirthLevelOnly || !rule.rebirthPreservesQuality || !rule.rebirthPreservesMaterialGods || rule.rebirthRefundCardId !== 56 || rule.rebirthRefundPercent !== 80 || rule.rebirthRounding !== 'floor' || material?.call_price !== 1280 || material.skill_num !== 0)
        fail('Chưa xác minh hợp đồng Tái Sinh Thần Thú.');
    const investedExp = beastLevelInvestment(state), divisor = 5n * BigInt(material.call_price), numerator = 4n * BigInt(investedExp), refundCount = Number(numerator / divisor);
    if (!Number.isSafeInteger(refundCount) || refundCount > 10000)
        fail('Số thẻ hoàn vượt hợp đồng phần thưởng; chưa Tái Sinh.');
    const key = createHash('sha256').update(JSON.stringify({ revision: 'beast-level-rebirth-v1', beast, state })).digest('hex');
    return { key, beast, fromLevel: state.level, toLevel: 1, investedExp, refundPercent: 80, refundCardId: 56, refundCardName: material.name, cardExp: material.call_price, refundCount, discardedRefundExp: Number(numerator % divisor) / 5, rounding: 'floor', canRebirth: investedExp > 0, keepQuality: state.quality, keepGods: true, keepSkills: true, keepDeployment: true, additionalCost: [], source: 'combiner_base + character_detail56; hoàn80%/làmtrònxuống/giữtiếncấp do người chơi xác nhận31/10/2026' };
}
