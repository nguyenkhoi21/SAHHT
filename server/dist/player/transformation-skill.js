import { existsSync } from 'node:fs';
import { readConfigSync } from './local-content.js';
import { vnRuntimeContent } from './vn-runtime-content.js';
import { transformationGraph } from './transformation-graph.js';
const targets = new Set(transformationGraph.map(e => e.targetId));
let definitions, skills;
const resolutions = new Map();
// Một số form VN có sprite_py giữ tên cũ nhưng script cùng model dùng tên mới.
// Không đổi skill ID/công thức; chỉ chọn file đúng model và đúng slot nguồn.
export function transformationSkillScript(configId, model, skillId, sprite) {
    const key = [configId, model, skillId, sprite].join(':');
    if (resolutions.has(key))
        return resolutions.get(key);
    const found = resolveScript(configId, model, skillId, sprite);
    resolutions.set(key, found);
    return found;
}
function resolveScript(configId, model, skillId, sprite) {
    const exists = (name) => /^[\w-]+$/.test(name) && /^[\w-]+$/.test(model) && (existsSync(new URL('../../../work/decrypted/lua/skill_effect/' + model + '/' + name + '.lua', import.meta.url)) || !!vnRuntimeContent()?.files['assets/lua/skill_effect/' + model + '/' + name + '.lua']);
    for (const name of [sprite, sprite.replace(/_\d+$/, '')])
        if (exists(name))
            return { name, status: 'EXACT_SCRIPT' };
    // Config đời đầu còn tên script Python kèm cấp (andy_defend1.py),
    // APK Lua lưu andy_defend.lua trong CHÍNH model đó. Không đổi ID/slot/model.
    const luaName = sprite.replace(/\.py$/, '');
    for (const name of [luaName, luaName.replace(/_\d+$/, ''), luaName.replace(/\d+$/, '')])
        if (exists(name))
            return { name, status: 'SOURCE_SUFFIX_ADAPTER' };
    if (!targets.has(configId))
        return null;
    definitions ??= readConfigSync('character_detail');
    skills ??= readConfigSync('skill_detail');
    const cfg = definitions[configId], slots = [];
    for (let slot = 1; slot <= 7; slot++)
        for (const [initial] of cfg?.['skill_' + slot + '_source'] ?? []) {
            let id = initial;
            const seen = new Set();
            while (id && !seen.has(id) && seen.size < 70) {
                if (id === skillId) {
                    slots.push(slot);
                    break;
                }
                seen.add(id);
                id = skills[id]?.is_evolution;
            }
        }
    if (new Set(slots).size !== 1)
        return null;
    const slot = slots[0];
    for (const name of [model + '_s' + slot, model + 's' + slot])
        if (exists(name))
            return { name, status: 'MODEL_SLOT_ADAPTER', slot };
    return null;
}
