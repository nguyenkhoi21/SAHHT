import { staticConfig } from './player.service.js';
import { createBaseHero } from './definitions.js';
import { heroResources } from './hero-index.js';
const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
const attributes = ['patk', 'matk', 'def', 'speed', 'hp'];
// Chỉ nhận prefix stage có toàn bộ chuỗi skill tồn tại; không thay skill hoặc nhảy qua stage lỗi.
export function qaEvolutionLimit(cfg, evolution, skills) {
    const configCap = Math.min(60, Math.max(...Object.keys(evolution).map(Number)));
    let cap = -1, issue = null;
    for (let stage = 0; stage <= configCap; stage++) {
        const row = evolution[String(stage)];
        if (!row) {
            issue = { stage, reason: 'MISSING EVOLUTION ROW' };
            break;
        }
        for (let slot = 1; slot <= 3; slot++) {
            const source = cfg[`skill_${slot}_source`];
            if (Array.isArray(source) && !source.length)
                continue;
            if (!Array.isArray(source) || source.length !== 1) {
                issue = { stage, slot, reason: 'AMBIGUOUS SKILL SOURCE' };
                break;
            }
            let sid = Number(source[0][0]);
            const seen = new Set([sid]);
            for (let step = 1; step < (row.skill[slot - 1] ?? 0); step++) {
                const next = Number(skills[String(sid)]?.is_evolution);
                if (!next || !skills[String(next)] || seen.has(next)) {
                    issue = { stage, slot, skillId: sid, nextId: next, reason: 'MISSING OR CYCLIC SKILL LINK' };
                    break;
                }
                seen.add(next);
                sid = next;
            }
            if (issue)
                break;
            if (!skills[String(sid)] || !Number.isInteger(skills[String(sid)].max_lv) || skills[String(sid)].max_lv < 1) {
                issue = { stage, slot, skillId: sid, reason: 'MISSING SKILL LIMIT' };
                break;
            }
        }
        if (issue)
            break;
        cap = stage;
    }
    return { cap, configCap, issue };
}
// GM TEST ACTION: snapshot phục vụ QA theo phép tính client; không phải nâng cấp/thu phí gốc.
// game_util.getAssistantCardAttrValue:5900–6014 và game_config.HERO_QUALITY_COLOR_TABLE_2.
export async function qaHeroPlan(hero, playerLevel, target = {}) {
    const [heroes, levels, superTable, teams, breaks, control, reform, skills] = await Promise.all(['character_detail', 'character_base', 'super_evolution', 'super_evo_team', 'character_break_new', 'break_control', 'character_strengthen', 'skill_detail'].map(staticConfig));
    const cfg = heroes[String(hero.c_id)];
    createBaseHero('qa-preview', Number(hero.c_id), cfg);
    if (!Number.isInteger(cfg.evo_kind) || cfg.evo_kind < 1 || cfg.is_evo !== 1 || cfg.skill_num === 0 || !Number.isInteger(playerLevel) || playerLevel < 1)
        fail('QA progression chỉ dành cho hero có bảng tiến hóa và cấp người chơi hợp lệ; không áp dụng thẻ nguyên liệu/tutorial.');
    // Cùng mapping với game_data.getEvolutionCfgByQuality, không ép mọi hero dùng evolution_5.
    const evolutionName = cfg.evo_kind < 3 ? 'evolution' : cfg.evo_kind === 3 ? 'evolution_3' : cfg.evo_kind === 4 ? 'evolution_4' : 'evolution_5', evolution = await staticConfig(evolutionName);
    const evolutionLimit = qaEvolutionLimit(cfg, evolution, skills), maxEvolution = evolutionLimit.cap;
    if (maxEvolution < 0)
        fail('Không có stage cơ sở với nguồn/giới hạn skill đầy đủ.');
    if (target.evolution === undefined && (hero.evo ?? 0) > maxEvolution)
        fail('MAX QA không tự hạ tiến hóa đang lưu xuống cap chuỗi skill; cần kiểm tra state trước.');
    const maxRebirth = Math.min(7, Number(breaks[String(hero.c_id)]?.high_break ?? 0));
    const superCfg = superTable[String(cfg.super_evo)];
    if (cfg.super_evo && !superCfg)
        fail('Thiếu bảng siêu tiến hóa của hero.');
    const maxSuper = superCfg ? 8 : 0;
    if ((await heroResources()).get(Number(hero.c_id))?.assetStatus !== 'FULL ASSETS')
        fail('Thiếu bộ model/atlas/texture cho QA.');
    // Tooltip21: hero không hơn người chơi quá5 cấp; row255 tồn tại. Không coi300 là MAX backend.
    const level = target.level ?? Math.min(255, playerLevel + 5), evo = target.evolution ?? maxEvolution, bre = target.rebirth ?? maxRebirth, superStep = target.superStep ?? maxSuper;
    if (!Number.isInteger(level) || level < 1 || level > Math.min(255, playerLevel + 5) || !levels[String(level)])
        fail('Cấp QA không nằm trong config/giới hạn người chơi.');
    if (!Number.isInteger(evo) || evo < 0 || evo > maxEvolution || !evolution[String(evo)] || level < evolution[String(evo)].need_level || !Number.isInteger(bre) || bre < 0 || bre > maxRebirth || (bre > 0 && (!control[String(bre)] || level < control[String(bre)].need_level)))
        fail('Không đủ config/điều kiện cho preset QA.');
    if (!Number.isInteger(superStep) || superStep < 0 || superStep > maxSuper)
        fail('Stage siêu tiến hóa vượt config của hero.');
    const cap = Math.max(0, ...Object.keys(reform).map(Number).filter(n => reform[String(n)].need_level <= level));
    const reformLevels = Object.fromEntries(attributes.map(k => [k, typeof target.reform === 'object' ? target.reform[k] : target.reform ?? cap]));
    for (const value of Object.values(reformLevels))
        if (!Number.isInteger(value) || value < 0 || value > cap || (value > 0 && !reform[String(value)]))
            fail('Cải Tạo vượt config/cấp hero.');
    if (superCfg && superCfg.level_9_need.length !== 0)
        fail('Chưa xác minh được chuỗi siêu tiến hóa.');
    const additions = Object.fromEntries([...attributes, 'fire_dfs'].map(k => [k, 0]));
    const add = (effects) => {
        for (const [type, value] of effects) {
            const key = type === 501 ? 'fire_dfs' : attributes[type - 1];
            if (!key || !Number.isFinite(value))
                fail('Có loại bonus siêu tiến hóa chưa tái dựng.');
            additions[key] += value;
        }
    };
    for (let stage = 1; stage <= superStep; stage++) {
        const needs = superCfg[`level_${stage}_need`];
        if (!Array.isArray(needs) || needs.length !== 4)
            fail('Thiếu bốn ô đúc hồn config.');
        add(superCfg[`level_${stage}_add`]);
        for (const id of needs) {
            if (!teams[String(id)])
                fail('Thiếu config đúc hồn.');
            add(teams[String(id)].ability_add);
        }
    }
    const result = { ...hero, lv: level, level_max: level, exp: 0, evo, step: evolution[String(evo)].step, bre,
        super_step: superStep, super_quality_1: superStep, super_soul: [], fire_dfs: additions.fire_dfs };
    const row = evolution[String(evo)], stats = row[`type${cfg.race}`];
    if (!Array.isArray(stats) || stats.length !== 5)
        fail('Thiếu vector thuộc tính chủng tộc.');
    for (const [index, key] of attributes.entries()) {
        const hpBonus = key === 'hp' ? (control[String(bre)]?.hp_add ?? 0) : 0;
        // Giữ phép tính float của Lua, không tự thêm rounding hoặc hệ số sức mạnh.
        const crystal = reformLevels[key];
        result[key] = (cfg[`base_${key}`] + Math.floor(stats[index]) + additions[key] + cfg[`growth_${key}`] * (level - 1)) * (1 + row.all + hpBonus) + Math.floor(reform[String(crystal)]?.[`add_${key}`] ?? 0) + Number(hero._local_transformation?.inherited?.[key] ?? 0);
        result[`${key}_crystal`] = crystal;
        if (!Number.isFinite(result[key]) || result[key] <= 0)
            fail('Chỉ số QA không hợp lệ.');
    }
    for (let slot = 1; slot <= 5; slot++) {
        const source = cfg[`skill_${slot}_source`];
        if ((slot > 3 && !superCfg) || (Array.isArray(source) && source.length === 0)) {
            result[`s_${slot}`] = { s: 0, avail: 0, lv: 1, exp: 0 };
            continue;
        }
        if (!Array.isArray(source) || source.length !== 1)
            fail('Skill có nhiều variant chưa được preset hỗ trợ.');
        let sid = Number(source[0][0]);
        const degree = slot <= 3 ? row.skill[slot - 1] : 1;
        for (let i = 1; i < degree; i++) {
            const next = Number(skills[String(sid)]?.is_evolution);
            if (!next || !skills[String(next)])
                fail('Thiếu chuỗi tiến hóa skill, không thay bằng skill khác.');
            sid = next;
        }
        const skill = skills[String(sid)];
        if (!skill || !Number.isInteger(skill.max_lv) || skill.max_lv < 1)
            fail('Chưa có giới hạn skill.');
        // Kích hoạt bằng quyền GM riêng; không suy initial availability của account thường.
        const available = slot <= 3 ? degree > 0 : !!superCfg && superStep >= superCfg[`skill${slot}_open`];
        result[`s_${slot}`] = { s: sid, avail: available ? 2 : 0, lv: skill.max_lv, exp: 0 };
    }
    if (cfg.skill_num === 5 || hero._local_skill_bank) {
        const bank = [result.s_1, result.s_2, result.s_3].map(v => ({ ...v }));
        for (const slot of cfg.skill_num === 5 ? [6, 7] : []) {
            const source = cfg[`skill_${slot}_source`];
            if (source?.length !== 1)
                fail('Thiếu nguồn skill thường bổ sung.');
            const sid = Number(source[0][0]), skill = skills[String(sid)];
            if (!skill || !Number.isInteger(skill.max_lv) || skill.max_lv < 1)
                fail('Thiếu config skill bổ sung.');
            bank.push({ s: sid, lv: skill.max_lv, exp: 0, avail: 2 });
        }
        result._local_skill_bank = bank;
        result._local_skill_selection = hero._local_skill_selection ?? [1, 2, 3];
        result._local_skill_selection.forEach((n, i) => result[`s_${i + 1}`] = { ...bank[n - 1] });
    }
    return { mode: 'GM TEST ACTION', state: result,
        requested: Object.keys(target).length ? target : { level: 255, evolution: 60, superLabel: 'Vàng++', rebirth: 7, reform: 60 },
        applied: { level, evolution: evo, superStep, superLabel: !superCfg ? 'Không có siêu tiến hóa' : superStep === 8 ? 'Vàng++' : `Stage${superStep}`, rebirth: bre, reform: Object.values(reformLevels).every(v => v === reformLevels.hp) ? reformLevels.hp : reformLevels },
        limits: { evolutionTable: evolutionName, evolution: maxEvolution, configEvolution: evolutionLimit.configCap, skillChainLimited: maxEvolution < evolutionLimit.configCap, skillChainIssue: evolutionLimit.issue, rebirth: maxRebirth, superStep: maxSuper, reform: cap },
        limitations: [...(maxEvolution < evolutionLimit.configCap ? [`Chuỗi skill chỉ đủ tới +${maxEvolution}; bảng tiến hóa có tới +${evolutionLimit.configCap}. Không mở stage thiếu skill.`] : []), `Cải Tạo theo bảng nguồn đang nạp, tối đa${cap} cấp ở cấp tướng này.`, 'Phép tính snapshot từ consumer client, chưa phải backend progression/battle gốc.', 'Không thu phí, tiêu vật liệu, hoàn thành ải hoặc cấp kết quả trận.', 'Hero5skill thường dùng pool1/2/3/6/7; MAX QA mở pool bằng quyền GM, không phải mua tự nhiên.'] };
}
