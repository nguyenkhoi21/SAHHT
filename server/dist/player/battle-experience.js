import { readConfigSync } from './local-content.js';
// EXP hero: game_hero_info_pop:675–680; delta stat từ game_util/qa-hero.
// LOCAL: mỗi tướng trong đội hình nhận reward_exp_character khi thắng, cap player+5/255.
export function heroBattleExperience(hero, playerLevel, gain) {
    if (!Number.isSafeInteger(gain) || gain < 0)
        throw new Error('EXP hero config không hợp lệ.');
    const cfg = readConfigSync('character_detail')[String(hero.c_id)], levels = readConfigSync('character_base'), rates = readConfigSync('character_base_rate');
    const max = Math.min(255, playerLevel + 5, cfg.level_max > 0 ? cfg.level_max : 255), threshold = (lv) => Math.floor(levels[String(lv)]?.exp * rates[String(cfg.type)]?.exp_rate);
    // battle_over_scene:1412 nối lv/maxExp trước cả nil-check: khi bảng không rỗng,
    // mọi actor phải có tuple kể cả hero cap nhận 0 EXP.
    if (hero.lv >= max || !gain) {
        const limit = threshold(hero.lv);
        if (!Number.isSafeInteger(limit) || limit <= 0)
            throw new Error('Thiếu ngưỡng hiển thị EXP hero.');
        return { state: hero, tuple: null, displayTuple: [0, hero.exp ?? 0, [[hero.lv, limit]]] };
    }
    let lv = hero.lv, exp = (hero.exp ?? 0) + gain;
    const old = hero.exp ?? 0, path = [];
    while (lv < max) {
        const needed = threshold(lv);
        if (!Number.isSafeInteger(needed) || needed <= 0)
            throw new Error('Thiếu ngưỡng EXP hero hợp lệ.');
        path.push([lv, needed]);
        if (exp < needed)
            break;
        exp -= needed;
        lv++;
    }
    if (lv === max) {
        exp = 0;
        path.push([lv, threshold(lv)]);
    }
    const state = { ...hero, lv, exp, level_max: Math.max(hero.level_max ?? 1, max) };
    if (lv !== hero.lv) {
        const table = cfg.evo_kind < 3 ? 'evolution' : cfg.evo_kind === 3 ? 'evolution_3' : cfg.evo_kind === 4 ? 'evolution_4' : 'evolution_5', evo = readConfigSync(table)[String(hero.evo ?? 0)], bre = readConfigSync('break_control')[String(hero.bre ?? 0)];
        if (!evo)
            throw new Error('Thiếu config tăng thuộc tính hero.');
        for (const field of ['hp', 'patk', 'matk', 'def', 'speed']) {
            state[field] += cfg['growth_' + field] * (lv - hero.lv) * (1 + evo.all + (field === 'hp' ? (bre?.hp_add ?? 0) : 0));
            if (!Number.isFinite(state[field]))
                throw new Error('Thuộc tính sau tăng cấp không hợp lệ.');
        }
    }
    return { state, tuple: [gain, old, path], displayTuple: [gain, old, path] };
}
