import { hotSupplement } from './hot-items.js';
import { aetherSupplementalItems } from './aether-content.js';
import { petConfig, petItems, petRecipes } from './pet-source.js';
import { readFileSync, existsSync } from 'node:fs';
import { auxiliaryConfig } from './auxiliary-state.js';
import { recoveredContent, recoveredHeroesEnabled } from './recovered-content.js';
import { vnRuntimeContent } from './vn-runtime-content.js';
import { beastExpMaterial } from './beast-source.js';
import { createHash } from 'node:crypto';
let extension;
const phase25Cache = new Map();
const immutableConfigs = new Map();
/** Chỉ dành consumer đọc: config nguồn bất biến theo chế độ, không cache state người chơi.
 * readConfigSync vẫn trả bản riêng cho importer/editor cần thay đổi dữ liệu.
 */
export function readStaticConfigSync(name) {
    const key = [process.env.LOCAL_HERO_EXTENSIONS, process.env.RECOVERED_HERO_BATCHES, process.env.VN_RUNTIME_CONTENT, name].join('|');
    if (!immutableConfigs.has(key)) {
        const freeze = (v) => { if (v && typeof v === 'object' && !Object.isFrozen(v)) {
            for (const child of Object.values(v))
                freeze(child);
            Object.freeze(v);
        } return v; };
        immutableConfigs.set(key, freeze(structuredClone(readConfigSync(name))));
    }
    return immutableConfigs.get(key);
}
export const localHeroesEnabled = () => process.env.LOCAL_HERO_EXTENSIONS === '1' || recoveredHeroesEnabled();
export function localContent() {
    const runtime = vnRuntimeContent();
    if (!localHeroesEnabled())
        return runtime;
    let original;
    if (process.env.LOCAL_HERO_EXTENSIONS === '1') {
        extension ??= JSON.parse(readFileSync(new URL('../../../work/local-content/extension.json', import.meta.url), 'utf8'));
        if (extension.revision !== 'local-heroes-v1')
            throw new Error('Revision config local chưa được hỗ trợ.');
        original = extension;
    }
    const recovered = recoveredContent();
    if (!recovered) {
        if (!original)
            return runtime;
        if (!runtime)
            return original;
        const configs = { ...original.configs };
        for (const [name, rows] of Object.entries(runtime.configs))
            configs[name] = mergeLocalConfig(configs[name] ?? {}, rows);
        return { ...original, configs, heroCatalog: [...original.heroCatalog, ...runtime.heroCatalog], resources: [...original.resources, ...runtime.resources], batches: runtime.batches, skillIndex: { heroByConfigId: { ...original.skillIndex.heroByConfigId, ...runtime.skillIndex.heroByConfigId }, skillById: { ...original.skillIndex.skillById, ...runtime.skillIndex.skillById } } };
    }
    if (!original)
        return recovered;
    return { ...original, configs: { ...original.configs, character_detail: mergeLocalConfig(original.configs.character_detail, recovered.configs.character_detail), skill_detail: mergeLocalConfig(original.configs.skill_detail, recovered.configs.skill_detail) },
        resources: [...original.resources, ...recovered.resources], heroCatalog: [...original.heroCatalog, ...recovered.heroCatalog],
        skillIndex: { heroByConfigId: { ...original.skillIndex.heroByConfigId, ...recovered.skillIndex.heroByConfigId }, skillById: { ...original.skillIndex.skillById, ...recovered.skillIndex.skillById } },
        definitions: [...original.definitions, ...recovered.definitions], batches: recovered.batches };
}
// Chỉ bổ sung key chưa có. Config gốc trên đĩa và các row gốc không bị thay đổi.
export function mergeLocalConfig(base, extra = {}) {
    if (!Object.keys(extra).length)
        return base;
    for (const key of Object.keys(extra))
        if (Object.hasOwn(base, key))
            throw new Error('Overlay local trùng ID gốc: ' + key);
    return { ...base, ...extra };
}
export function readConfigSync(name) {
    if (!/^[a-z_0-9]+$/.test(name))
        throw new Error('Tên config không hợp lệ');
    if (name.startsWith('pet_'))
        return petConfig(name);
    if (['shop', 'tree_shop'].includes(name)) {
        if (!phase25Cache.has(name)) {
            const root = new URL('../../../', import.meta.url), entry = JSON.parse(readFileSync(new URL('tools/runtime/phase30-source.json', root), 'utf8')).tables[name], raw = readFileSync(new URL(entry.path, root));
            if (createHash('sha256').update(raw).digest('hex') !== entry.sha256)
                throw Error('Nguồn cửa hàng Việt Nam thay đổi: ' + name);
            const data = JSON.parse(raw.toString());
            if (name === 'shop') {
                // Giữ adapter hạt giống 22→vật phẩm từ baseline đã dùng; không tạo ID cho seed mới.
                const baseline = JSON.parse(readFileSync(new URL('work/extracted-data/configs/shop.json', root), 'utf8'));
                for (const [id, row] of Object.entries(data))
                    if (row.shop_reward?.[0]?.[0] === 22 && baseline[id]?.shop_reward?.[0]?.[0] === 6 && baseline[id].shop_reward[0][1] === 1200000 + row.shop_reward[0][1])
                        row.shop_reward = baseline[id].shop_reward;
            }
            phase25Cache.set(name, data);
        }
        return phase25Cache.get(name);
    }
    if (['talisman', 'talisman_level', 'talisman_break', 'talisman_forging_list'].includes(name))
        return auxiliaryConfig(name);
    if (['equip_gem_fate_word', 'equip_gem_fate_skill', 'equip_gem_fate_txt'].includes(name)) {
        if (!phase25Cache.has(name)) {
            const root = new URL('../../../', import.meta.url), manifest = JSON.parse(readFileSync(new URL('tools/runtime/phase25-source.json', root), 'utf8')), source = manifest.tables[name];
            const raw = readFileSync(new URL(source.sourcePath, root)), parsed = readFileSync(new URL(`work/runtime-content/configs/${name}.json`, root)), sha = (b) => createHash('sha256').update(b).digest('hex');
            if (sha(raw) !== source.sourceHash || sha(parsed) !== source.parsedHash || JSON.stringify(JSON.parse(raw.toString())) !== JSON.stringify(JSON.parse(parsed.toString())))
                throw new Error('Nguồn Ban Sức Việt Nam không khớp: ' + name);
            phase25Cache.set(name, JSON.parse(parsed.toString()));
        }
        return phase25Cache.get(name);
    }
    const path = new URL(`../../../work/extracted-data/configs/${name}.json`, import.meta.url), extra = localContent()?.configs[name];
    if (!existsSync(path) && !extra)
        throw Object.assign(new Error('Chưa có config local đã xác minh: ' + name), { code: 'ENOENT' });
    const base = existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : {};
    let merged = mergeLocalConfig(base, extra);
    if (name === 'item')
        for (const [id, row] of Object.entries(aetherSupplementalItems())) {
            if (merged[id] && JSON.stringify(merged[id]) !== JSON.stringify(row))
                throw Error('Vật phẩm Aether trùng ID khác nguồn: ' + id);
            merged = { ...merged, [id]: row };
        }
    if (name === 'item')
        merged = { ...merged, ...petItems() };
    if (name === 'exchange')
        merged = { ...merged, ...petRecipes() };
    if (name === 'item' || name === 'exchange')
        for (const [id, row] of Object.entries(hotSupplement(name))) {
            if (merged[id] && JSON.stringify(merged[id]) !== JSON.stringify(row))
                throw Error('HOT không ghi đè ID khác nguồn: ' + name + ':' + id);
            merged[id] = row;
        }
    if (name === 'character_detail' && merged['56'])
        merged = { ...merged, '56': beastExpMaterial(merged['56']) };
    // Adapter VN: cùng Kakarot, chỉ mở liên kết skin đã xác minh; không đổi model/skill/stat gốc.
    // Offline bundle ships the verified skin row directly in the baseline
    // configs, so this link must not depend on VN_RUNTIME_CONTENT being on.
    if (name === 'character_detail') {
        const next = { ...merged };
        if (next['425000'] && next['81200']?.is_skin === 0)
            next['81200'] = { ...next['81200'], is_skin: 425000 };
        // The verified APK uses the compact 28410…28470 skill IDs for the
        // Inori skin.  Newer extracted metadata spells them as 2841000…;
        // normalize only this skin link so battle skill mapping resolves.
        if (next['428000']) {
            const skin = structuredClone(next['428000']);
            for (const slot of [1, 2, 3, 4, 5, 6, 7])
                skin['skill_' + slot + '_source'] = (skin['skill_' + slot + '_source'] ?? []).map(([id, lv]) => [id >= 2841000 && id % 1000 === 0 ? id / 100 : id, lv]);
            next['428000'] = skin;
        }
        return next;
    }
    return merged;
}
export function readBaselineConfigSync(name) { if (!/^[a-z_0-9]+$/.test(name))
    throw Error('Tên config không hợp lệ'); return JSON.parse(readFileSync(new URL(`../../../work/extracted-data/configs/${name}.json`, import.meta.url), 'utf8')); }
