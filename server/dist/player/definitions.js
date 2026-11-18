import { readConfigSync } from './local-content.js';
// character_skin khóa theo configID của skin thật; is_skin trên hero là tham chiếu skin có thể mặc.
const skinDefinitionIds = new Set(Object.keys(readConfigSync('character_skin')));
const invalid = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
// Khởi tạo local Lv1/evo0: evolution.skill=[1,0,0]; super chưa mở.
export function initialHeroSkills(cfg) { return Object.fromEntries([1, 2, 3, 4, 5].map(n => ['s_' + n, { s: n > 3 && !cfg.super_evo ? 0 : Number(cfg['skill_' + n + '_source']?.[0]?.[0] ?? 0), lv: 1, exp: 0, avail: n === 1 && cfg.skill_num > 0 ? 2 : 0 }])); }
let heroDefinitions;
export function hasOnlyInitialHeroSkills(hero) {
    if (Object.keys(hero).some(k => k.startsWith('_local_skill_') || /^s_[67]$/.test(k)))
        return false;
    heroDefinitions ??= readConfigSync('character_detail');
    const cfg = heroDefinitions[String(hero.c_id)];
    if (!cfg)
        return false;
    const expected = initialHeroSkills(cfg);
    const matches = (actual, initial) => actual && typeof actual === 'object' && Object.keys(actual).length === 4 && Object.entries(initial).every(([field, value]) => actual[field] === value);
    return Object.entries(expected).every(([key, value]) => {
        if (hero[key] === undefined || matches(hero[key], value))
            return true;
        // Tương thích instance cũ: từng lưu ID super chưa mở dù hero không có super_evo.
        // Chỉ nhận đúng ID nguồn, lv1/exp0/avail0; không coi skill đã nâng là state base.
        return !cfg.super_evo && /^s_[45]$/.test(key) && matches(hero[key], { ...value, s: Number(cfg[`skill_${key.slice(2)}_source`]?.[0]?.[0] ?? 0) });
    });
}
// Cùng instance schema cấp1/base stats đã Android xác minh; không mô phỏng growth.
export function createBaseHero(id, cid, cfg) {
    if (!cfg || Number(cfg.character_ID) === 999 || skinDefinitionIds.has(String(cid)) || !Number.isInteger(cfg.quality) || cfg.quality < 0 || cfg.quality > 6 || !(cfg.skill_num > 0 || (cfg.skill_num === 0 && cfg.is_evo === 0 && cfg.level_max === 1)) || !Array.isArray(cfg.skill_1_source) || (cfg.skill_num > 0 && cfg.skill_1_source.length === 0) ||
        ['base_hp', 'base_patk', 'base_matk', 'base_def', 'base_speed'].some(k => !Number.isSafeInteger(cfg[k]) || cfg[k] < 0))
        invalid('Định nghĩa hero chưa nằm trong schema base-level đã hỗ trợ.');
    return { ...initialHeroSkills(cfg), id, c_id: cid, lv: 1, level_max: 1, exp: 0, bre: 0, step: 0, evo: 0, quality: cfg.quality,
        hp_crystal: 0, patk_crystal: 0, matk_crystal: 0, def_crystal: 0, speed_crystal: 0,
        hp: cfg.base_hp, patk: cfg.base_patk, matk: cfg.base_matk, def: cfg.base_def, speed: cfg.base_speed };
}
export function characterName(value) {
    const name = value.trim();
    if (!/^[\p{L}\p{N}_ ]{1,15}$/u.test(name))
        invalid('Tên nhân vật cần1–15 chữ, số, khoảng trắng hoặc _.');
    return name;
}
// game_util.getEquipAttributeValue:3532; equip_pos dùng sort1..4, lv1 không có bonus nâng.
// Popup trang bị gốc duyệt atts bằng pairs kể cả món chưa phụ ma.
// Chuẩn hóa khi serialize để instance cũ cũng mở được, không migration/ghi đè state.
export function equipmentClientState(state) { return { st_lv: 0, atts: {}, bind_card: '', ...state }; }
export function heroBindingClientState(state) {
    // Lua kiểm v ~= 0 trước khi ghép bind_equip vào vị trí đang mặc.
    // Chuỗi "0" sẽ ghi đè món chưa khóa ở ô khác, làm mất bonus trên client.
    const binding = Array.isArray(state.bind_equip) ? state.bind_equip.map((id) => String(id) === '0' ? 0 : id) : undefined;
    return { ...state, ...(binding ? { bind_equip: binding.some((id) => id !== 0) ? binding : [] } : {}) };
}
export function createBaseEquipment(id, cid, cfg) {
    if (!cfg || ![1, 2, 3, 4].includes(cfg.sort) || ![1, 2, 3, 4, 5].includes(cfg.ability1) || ![1, 2, 3, 4, 5].includes(cfg.ability2) ||
        ['value1', 'value2', 'level_add1', 'level_add2'].some(k => !Number.isSafeInteger(cfg[k]) || cfg[k] < 0))
        invalid('Định nghĩa trang bị ngoài schema base đã xác minh.');
    return equipmentClientState({ id, c_id: cid, lv: 1 });
}
