import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('../../../', import.meta.url));
let cached;
// Nguồn code8 đã cách ly theo yêu cầu pha15; flag cũ không được mở lại runtime.
export const recoveredHeroesEnabled = () => false;
export function validateRecoveredBatch(value) {
    if (value.revision !== 'recovered-heroes-v1' || !Array.isArray(value.heroCatalog) || !value.configs?.character_detail ||
        Object.keys(value.configs).some(k => !['character_detail', 'skill_detail'].includes(k)) ||
        Object.keys(value.configs.skill_detail ?? {}).some(k => !/^\d+$/.test(k) || Number(k) < 200000000 || Number(k) >= 210000000))
        throw new Error('Batch nguồn không hợp lệ hoặc cố ghi đè bảng skill/progression.');
    const ids = Object.keys(value.configs.character_detail).sort();
    if (!value.baseConfigHashes?.character_detail || !value.baseConfigHashes?.skill_detail || !Array.isArray(value.resources) || value.resources.length !== ids.length)
        throw new Error('Batch thiếu baseline hash hoặc resource.');
    if (new Set(value.heroCatalog.map((r) => String(r.configId))).size !== ids.length ||
        value.heroCatalog.some((r) => !ids.includes(String(r.configId)) || r.sourceDefinition?.batch !== value.batch))
        throw new Error('Catalog batch không đồng bộ với config.');
    return value;
}
export function recoveredContent() {
    if (!recoveredHeroesEnabled())
        return;
    if (cached)
        return cached;
    const state = JSON.parse(readFileSync(resolve(root, 'work/hero-import/state.json'), 'utf8'));
    if (state.revision !== 'hero-import-state-v1' || !Array.isArray(state.batches))
        throw new Error('Trạng thái import chưa được hỗ trợ.');
    const result = { revision: 'recovered-heroes-v1', configs: { character_detail: {}, skill_detail: {} }, resources: [], heroCatalog: [],
        skillIndex: { heroByConfigId: {}, skillById: {} }, definitions: [], batches: [] };
    for (const record of state.batches.filter((b) => b.status === 'ACTIVE')) {
        const path = resolve(root, record.path), base = resolve(root, 'work/hero-import/batches') + sep;
        if (!path.startsWith(base))
            throw new Error('Path batch vượt vùng import.');
        const raw = readFileSync(path), hash = createHash('sha256').update(raw).digest('hex');
        if (hash !== record.manifestSha256)
            throw new Error('Hash batch nguồn không khớp.');
        const batch = validateRecoveredBatch(JSON.parse(raw.toString('utf8')));
        if (batch.batch !== record.batch || JSON.stringify(Object.keys(batch.configs.character_detail).map(Number).sort((a, b) => a - b)) !== JSON.stringify([...record.ids].sort((a, b) => a - b)))
            throw new Error('ID hoặc tên batch không khớp ledger.');
        for (const [name, expected] of Object.entries(batch.baseConfigHashes ?? {})) {
            if (!/^[a-z_0-9]+$/.test(name))
                throw new Error('Tên bảng baseline không hợp lệ.');
            if (createHash('sha256').update(readFileSync(resolve(root, `work/extracted-data/configs/${name}.json`))).digest('hex') !== expected)
                throw new Error('Baseline đã đổi; cần kiểm tương thích lại: ' + name);
        }
        for (const id of record.ids) {
            if (Object.hasOwn(result.configs.character_detail, id))
                throw new Error('Trùng ID giữa các batch nguồn.');
            result.configs.character_detail[id] = batch.configs.character_detail[id];
        }
        for (const [id, row] of Object.entries(batch.configs.skill_detail ?? {})) {
            if (result.configs.skill_detail[id] && JSON.stringify(result.configs.skill_detail[id]) !== JSON.stringify(row))
                throw new Error('Trùng skill namespace khác nội dung.');
            result.configs.skill_detail[id] = row;
        }
        result.resources.push(...batch.resources);
        result.heroCatalog.push(...batch.heroCatalog.map((h) => ({ ...h,
            skillIds: [...new Set((batch.skillIndex.heroByConfigId[String(h.configId)]?.skills ?? []).map((s) => s.skillId))],
            baseGrantableByServer: false, skin: null })));
        for (const [id, hero] of Object.entries(batch.skillIndex.heroByConfigId)) {
            result.skillIndex.heroByConfigId[id] = { ...hero, skills: hero.skills.map((link) => ({ ...link, skillName: batch.configs.skill_detail[String(link.skillId)]?.skill_name ?? null })) };
        }
        Object.assign(result.skillIndex.skillById, batch.skillIndex.skillById);
        result.definitions.push(...batch.definitions);
        result.batches.push({ ...record, sourceApkSha256: batch.sourceApkSha256 });
    }
    try {
        const validation = JSON.parse(readFileSync(resolve(root, 'work/hero-import/validation.json'), 'utf8'));
        if (validation.revision !== 'hero-import-validation-v1')
            throw new Error('Phiên bản validation không hợp lệ.');
        for (const b of validation.batches ?? [])
            if (result.batches.some((r) => r.batch === b.batch && r.manifestSha256 === b.manifestSha256)) {
                for (const qa of b.heroes) {
                    const hero = result.heroCatalog.find((r) => r.configId === qa.configId && r.sourceDefinition.batch === b.batch);
                    if (hero) {
                        hero.qaSupport = qa;
                        hero.baseGrantableByServer = qa.supported === true;
                    }
                }
            }
    }
    catch (error) {
        if (error.code !== 'ENOENT')
            throw error;
    }
    cached = result;
    return result;
}
