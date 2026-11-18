import { petBonuses } from './pet-state.js';
import { auxInventory, auxiliaryBonuses } from './auxiliary-state.js';
import { readStaticConfigSync as readConfigSync } from './local-content.js';
import { battleSkillRegistration } from './battle-skill-registry.js';
import { appearanceState } from './appearance-state.js';
import { transformationProvenance } from './transformation-graph.js';
import { formationBonuses } from './formation-systems.js';
import { fateLineEffects, fateGemDefinition } from './fate-empowerment.js';
const fields = ['patk', 'matk', 'def', 'speed', 'hp'];
const extra = ['fire', 'water', 'wind', 'earth', 'fire_dfs', 'water_dfs', 'wind_dfs', 'earth_dfs'];
export function canonicalHeroPower(attributes, hero, cfg, extraPower = 0, weighted) {
    const skills = combatConfig('skill_detail'), factors = combatConfig('combat_skill'), weights = combatConfig('combat_base');
    let factor = 1;
    for (const s of battleSkillRegistration(hero, cfg, skills).active)
        if (s.lv > 0 && skills[s.s])
            factor += Number(factors[s.lv]?.[skills[s.s].skill_quality] ?? 0);
    return { factor, power: fields.reduce((sum, f) => sum + (weighted ? weighted[f] : Math.floor(attributes[f] * weights[f])), 0) * factor + extraPower + extra.reduce((sum, f) => sum + Number(hero[f] ?? 0), 0) };
}
// Chỉ cache config bất biến theo chế độ nguồn; state người chơi luôn đọc mới.
const configCache = new Map();
const combatConfig = (name) => { const key = [process.env.LOCAL_HERO_EXTENSIONS, process.env.RECOVERED_HERO_BATCHES, process.env.VN_RUNTIME_CONTENT, name].join('|'); if (!configCache.has(key))
    configCache.set(key, readConfigSync(name)); return configCache.get(key); };
// game_util.getCombatValue:6285–6535; chỉ các domain đang được local lưu/cho phép.
// Progression đã được service nâng tướng cộng vào state, không cộng lần thứ hai.
export class CombatPowerService {
    db;
    constructor(db) {
        this.db = db;
    }
    calculate(userId, includeBench = false, context) {
        const row = this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(userId);
        if (!row)
            return { combat: 0, heroes: [], scope: 'formation-with-reserves-v1' };
        const appearance = appearanceState(this.db, userId), auxiliary = auxInventory(this.db, userId);
        const form = context?.formation ?? JSON.parse(row.formation), heroes = Object.fromEntries(this.db.prepare('SELECT id,state FROM player_heroes WHERE user_id=?').all(userId).map((h) => [h.id, JSON.parse(h.state)])), equipment = Object.fromEntries(this.db.prepare('SELECT id,state FROM player_equipment WHERE user_id=?').all(userId).map((e) => [e.id, JSON.parse(e.state)]));
        const defs = combatConfig('character_detail'), equips = combatConfig('equip'), chains = combatConfig('chain'), suits = combatConfig('suit'), weights = combatConfig('combat_base'), skills = combatConfig('skill_detail'), factors = combatConfig('combat_skill');
        // game_data.setTeamByJsonData: năm chính và ba dự bị cùng được tính lực chiến.
        const battleTeam = [...form.alignment[0], ...form.alignment[1].slice(0, 3)];
        const team = includeBench ? [...battleTeam, ...Object.keys(heroes).filter(id => !battleTeam.includes(id))] : battleTeam;
        // game_util.getCardAndEquipChainTab: cả đội chính/dự bị, Trợ Uy, Vận Mệnh
        // và tướng chủ Trận Pháp góp identity; thẻ phụ chỉ góp add_ability.
        const identities = new Set([...battleTeam, ...(form.assistant ?? []), ...(form.destiny ?? []), ...(form.formation_bonus ?? [])].filter(id => heroes[id] && defs[heroes[id].c_id]).map(id => String(defs[heroes[id].c_id].character_ID))), support = formationBonuses(this.db, userId, form, heroes);
        const deployedPetBonus = !context ? petBonuses(this.db, userId).total : Object.fromEntries(fields.map(f => [f, 0]));
        const seenHeroes = new Set(), seenEquipment = new Set(), seenSpecials = new Set();
        const result = team.flatMap((id, slot) => {
            const hero = heroes[id], cfg = defs[hero?.c_id];
            if (!hero || !cfg || seenHeroes.has(id))
                return [];
            seenHeroes.add(id);
            const worn = (slot < 8 ? form.equip_pos[String(slot)] ?? [] : []).map((eid, index) => { const e = equipment[eid]; if (!e || seenEquipment.has(eid) || equips[e.c_id]?.sort !== index + 1)
                return null; seenEquipment.add(eid); return e; }).filter(Boolean), equipmentChains = new Set(worn.map((e) => equips[e.c_id]?.chain_id ?? equips[e.c_id]?.equip_id));
            const bonus = fields.map(() => 0), chainDetails = [];
            for (const key of cfg.chain ?? []) {
                const chain = chains[key];
                if (!chain?.data?.length)
                    continue;
                // Config VN lưu condition_sort dưới dạng chuỗi; Lua dùng toInt().
                const condition = Number(chain.condition_sort);
                const required = chain.data.map((cid) => String(hero.fate_change?.chain_id) === String(key) && String(hero.fate_change?.c_id1) === String(cid) ? Number(hero.fate_change.c_id2) : cid);
                const active = condition === 0 ? required.every((cid) => identities.has(String(defs[cid]?.character_ID))) : condition === 1 && chain.data.every((cid) => equipmentChains.has(equips[cid]?.chain_id ?? equips[cid]?.equip_id) || equipmentChains.has(equips[cid]?.sort));
                chainDetails.push({ id: key, name: chain.name, condition, required, active, effects: chain.effect });
                const effects = String(hero.fate_change?.chain_id) === String(key) && Array.isArray(hero.fate_change?.effect) ? hero.fate_change.effect : chain.effect;
                if (active)
                    for (const [index, value] of effects ?? [])
                        if (index >= 0 && index < 5)
                            bonus[index] += value * .001;
            }
            const base = Object.fromEntries(fields.map(f => [f, Number(hero[f] ?? 0)])), equipmentBonus = Object.fromEntries(fields.map(f => [f, 0]));
            const attrs = Object.fromEntries(fields.map((f, i) => [f, base[f] * (1 + bonus[i])]));
            let extraPower = 0;
            const appliedSuits = new Set(), equipmentExtra = {}, suitBonus = Object.fromEntries(fields.map(f => [f, 0])), forgeBonus = { ...suitBonus };
            const elementByAbility = { 201: 'fire', 202: 'water', 203: 'wind', 204: 'earth', 301: 'fire_dfs', 302: 'water_dfs', 303: 'wind_dfs', 304: 'earth_dfs' };
            for (const item of worn) {
                const ec = equips[item.c_id];
                if (!ec)
                    continue;
                for (const n of [1, 2]) {
                    const field = fields[ec['ability' + n] - 1];
                    if (field) {
                        const value = Number(ec['value' + n] ?? 0) + Number(ec['level_add' + n] ?? 0) * Math.max(0, item.lv - 1) + Number(item.equip_refine?.[field] ?? 0);
                        attrs[field] += value;
                        equipmentBonus[field] += value;
                    }
                }
                if (item.is_enchant) {
                    extraPower += Object.values(item.atts ?? {}).reduce((s, v) => s + Number(v), 0);
                    for (const f of extra)
                        equipmentExtra[f] = (equipmentExtra[f] ?? 0) + Number(item.atts?.[f] ?? 0);
                }
                if (!context && item.is_equip_forge === true)
                    for (const [key, values] of Object.entries(item.equip_forge ?? {})) {
                        const rule = combatConfig('equip_set_random')[key], value = Object.values(values);
                        if (rule && fields[rule.sort - 1] && rule.enemy?.[0] !== -1 && value.length === 1 && Number.isFinite(value[0])) {
                            const f = fields[rule.sort - 1];
                            attrs[f] += Number(value[0]);
                            forgeBonus[f] += Number(value[0]);
                        }
                    }
                if (ec.suit && !appliedSuits.has(ec.suit)) {
                    appliedSuits.add(ec.suit);
                    const suit = suits[ec.suit];
                    if (suit) {
                        const count = suit.part.filter((part) => worn.some((e) => equips[e.c_id]?.equip_id === equips[part]?.equip_id && equips[e.c_id]?.sort === equips[part]?.sort)).length;
                        for (let n = 2; n <= count; n++)
                            for (const [kind, value] of suit['effect_' + n] ?? [])
                                if (fields[kind - 1]) {
                                    attrs[fields[kind - 1]] += value;
                                    suitBonus[fields[kind - 1]] += value;
                                }
                                else {
                                    extraPower += value;
                                    const f = elementByAbility[kind];
                                    if (f)
                                        equipmentExtra[f] = (equipmentExtra[f] ?? 0) + value;
                                }
                    }
                }
            }
            let factor = 1;
            for (const s of battleSkillRegistration(hero, cfg, skills).active)
                if (s.lv > 0 && skills[s.s])
                    factor += Number(factors[s.lv]?.[skills[s.s].skill_quality] ?? 0);
            // Danh tiếng được cộng sau Vận Mệnh theo getCombatValue, không nhân đá lần nữa.
            const destinyPercent = Object.fromEntries(fields.map(f => [f, 0])), stonePercent = { ...destinyPercent }, gems = combatConfig('equip_gem_fate');
            let hasBoundEquipment = false;
            const empowerLines = [], empowerPercent = Object.fromEntries(fields.map(f => [f, 0]));
            const usedBindings = new Set(), bindingDetails = [];
            for (const eid of hero.bind_equip ?? []) {
                if (!eid)
                    continue;
                const bound = equipment[String(eid)], active = !!bound && bound.bind_card === id && worn.includes(bound) && !usedBindings.has(String(eid));
                bindingDetails.push({ equipmentId: eid, active, reason: active ? 'Trang bị đang mặc và khóa đúng tướng' : 'Không mặc, sai liên kết hoặc tham chiếu trùng' });
                if (!active)
                    continue;
                usedBindings.add(String(eid));
                hasBoundEquipment = true;
                for (let n = 0; n < 5; n++)
                    destinyPercent[fields[n]] += Number(bound.bind_data?.[String(n + 1)] ?? 0);
                const lines = fateLineEffects(this.db, userId, bound);
                empowerLines.push({ equipmentId: eid, lines });
                const activeLine = lines.find(l => l.active && l.family === 6), increase = Number(activeLine?.effect?.[0]?.[1] ?? 0);
                // Tooltip Thần Thư (sort6) tăng thuộc tính đá; các họ combat khác không thành % thường trực.
                for (const [gemSlot, cid] of (bound.gem_fate ?? []).entries()) {
                    if (!cid)
                        continue;
                    const special = typeof cid === 'string' && cid.includes('-');
                    if (special && (seenSpecials.has(cid) || !this.db.prepare('SELECT 1 FROM player_fate_special WHERE user_id=? AND id=?').get(userId, cid)))
                        continue;
                    const gem = fateGemDefinition(cid);
                    if (gem?.team !== (gemSlot === 0 ? equips[bound.c_id].sort : 5))
                        continue;
                    if (special)
                        seenSpecials.add(cid);
                    if (gem && fields[gem.team - 1]) {
                        const field = fields[gem.team - 1], extra = Number(gem.value) * increase / 100;
                        stonePercent[field] += Number(gem.value) + extra;
                        empowerPercent[field] += extra;
                    }
                }
            }
            const aux = auxiliaryBonuses(auxiliary, form, slot, base);
            for (const f of fields)
                attrs[f] += aux.flat[f];
            const petBonus = deployedPetBonus;
            for (const f of fields)
                attrs[f] += Number(petBonus[f] ?? 0);
            const assistant = Object.fromEntries(fields.map(f => [f, slot < 8 ? support.details.filter((d) => d.system === 'assistant' && d.field === f).reduce((n, d) => n + Number(d.value), 0) : 0]));
            for (const f of fields)
                attrs[f] += assistant[f];
            const beforeDestiny = { ...attrs };
            for (const f of fields) {
                const percent = destinyPercent[f] + stonePercent[f];
                if (hasBoundEquipment)
                    attrs[f] = Math.floor(attrs[f] * (1 + percent / 100));
            }
            for (const f of fields)
                attrs[f] += aux.post[f];
            extraPower += Object.values(aux.extras).reduce((n, v) => n + Number(v), 0);
            // getGodCombatValue làm tròn sau khi NHÂN trọng số và Vận Mệnh; danh tiếng
            // cộng sau đó, Pháp Bảo nhân hệ số skill. Không mượn power/Trợ Uy Main.
            const godWeighted = {};
            for (const f of fields) {
                const percent = destinyPercent[f] + stonePercent[f], famous = context ? (hero.famous?.[f] ? Number(hero.famous?.[f + '_v'] ?? 0) : 0) : Number(hero.famous?.[f + '_v'] ?? 0), weighted = beforeDestiny[f] * weights[f];
                godWeighted[f] = (hasBoundEquipment ? Math.floor(weighted * (1 + percent / 100)) : weighted) + (aux.post[f] + famous) * weights[f];
                attrs[f] += famous;
            }
            const skinBonus = Object.fromEntries(fields.map(f => [f, 0]));
            if (appearance.used_skin.includes(cfg.is_skin)) {
                const entry = appearance.skin[cfg.is_skin], field = fields[entry?.[0] - 1];
                if (field) {
                    skinBonus[field] = entry[1];
                    attrs[field] += entry[1];
                }
            }
            const layout = combatConfig('formation')[form.formation?.current ?? 1], physical = slot < 5 ? [0, 1, 2, 3, 4, 5].filter(i => layout?.['position_' + String.fromCharCode(97 + i)] !== 0)[slot] : slot + 1, formationPost = slot < 8 ? support.byPosition[physical] ?? {} : {};
            for (const f of fields)
                attrs[f] += Number(formationPost[f] ?? 0);
            if (!context)
                for (const f of fields)
                    godWeighted[f] = Math.floor(godWeighted[f] + skinBonus[f]);
            const supportPower = !context ? fields.reduce((n, f) => n + Number(formationPost[f] ?? 0), 0) * factor : 0;
            const power = canonicalHeroPower(attrs, hero, cfg, extraPower, godWeighted).power + supportPower;
            if (!Number.isFinite(power) || power < 0 || power > Number.MAX_SAFE_INTEGER)
                throw new Error('Chỉ số lực chiến không hợp lệ.');
            return [{ id, configId: hero.c_id, slot, attributes: { ...attrs, ...Object.fromEntries(extra.map(f => [f, Number(hero[f] ?? 0) + Number(aux.extras[f] ?? 0) + Number(equipmentExtra[f] ?? 0)])) }, breakdown: { base, auxiliary: aux, support: slot < 8 ? { ...support, attributes: Object.fromEntries(fields.map(f => [f, assistant[f] + Number(formationPost[f] ?? 0)])), formationPost, supportPower } : null, transformation: hero._local_transformation ?? null, transformationProvenance: transformationProvenance(hero), skin: skinBonus, assistant, chainDetails, bindingDetails, weights, weighted: godWeighted, extraPower, chainPercent: Object.fromEntries(fields.map((f, i) => [f, bonus[i] * 100])), equipment: equipmentBonus, equipmentItems: worn.map((e) => ({ id: e.id, configId: e.c_id, level: e.lv, bindCard: e.bind_card, gems: (e.gem_fate ?? []).map((gem) => ({ id: gem, definition: fateGemDefinition(gem) })) })), suitBonus, forgeBonus, equipmentExtra, famous: Object.fromEntries(fields.map(f => [f, Number(hero.famous?.[f + '_v'] ?? 0)])), petBonus, beforeDestiny, destinyPercent, stonePercent, empowerPercent, empowerLines, final: attrs }, skillFactor: factor, power }];
        });
        return { combat: Math.floor(result.filter(h => h.slot < 8).reduce((sum, h) => sum + h.power, 0)), heroes: result, scope: context ? 'godfield-team-v1' : 'formation-with-reserves-v1' };
    }
}
