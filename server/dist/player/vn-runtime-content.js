import { readFileSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('../../../', import.meta.url));
const sha = (b) => createHash('sha256').update(b).digest('hex');
let cache;
export function validateRuntimeBatch(batch) {
    if (batch.revision !== 'vn-runtime-batch-v1' || batch.sourcePackage !== 'com.kaiqigu.cjyxyn.kvsdk' || !/^vn-runtime-[a-f0-9]{16}$/.test(batch.sourceKey) || !batch.configs || !Array.isArray(batch.heroCatalog) || !Array.isArray(batch.resources))
        throw new Error('Nguồn runtime Việt Nam không hợp lệ.');
    const allowed = ['character_skin', 'character_detail', 'skill_detail', 'chain', 'super_evolution', 'super_evo_team', 'character_break_new', 'item', 'exchange', 'vip', 'new_vip_reward', 'newstar_seven', 'newstar_mission', 'newstar_time', 'box', 'equip', 'suit', 'character_strengthen'];
    for (const [name, rows] of Object.entries(batch.configs)) {
        if (!allowed.includes(name) || !rows || typeof rows !== 'object' || Array.isArray(rows))
            throw new Error('Bảng runtime chưa được hỗ trợ.');
        const path = resolve(root, 'work/extracted-data/configs', name + '.json'), base = existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : {};
        if (batch.baseConfigHashes?.[name] && sha(readFileSync(path)) !== batch.baseConfigHashes[name])
            throw new Error('Baseline đã đổi, cần kiểm lại batch.');
        for (const [key, row] of Object.entries(rows))
            if (!/^\d+$/.test(key) || Object.hasOwn(base, key))
                throw new Error('Batch cố ghi đè ID local: ' + name + ':' + key);
    }
    for (const hero of batch.heroCatalog) {
        if (!batch.configs.character_detail?.[hero.configId] || /[\u3400-\u9fff\u3040-\u30ff]/.test(hero.displayName) || hero.sourceDefinition?.source !== batch.sourceKey)
            throw new Error('Hero/source/tên Việt không đồng bộ.');
    }
    return batch;
}
export function vnRuntimeContent() {
    if (process.env.VN_RUNTIME_CONTENT === '0')
        return;
    if (cache)
        return cache;
    const statePath = resolve(root, 'work/vn-runtime-import/state.json');
    if (!existsSync(statePath))
        return;
    const state = JSON.parse(readFileSync(statePath, 'utf8'));
    if (state.revision !== 'vn-runtime-state-v1' || !Array.isArray(state.batches))
        throw new Error('Trạng thái batch VN không hợp lệ.');
    const result = { revision: 'vn-runtime-content-v1', configs: {}, heroCatalog: [], resources: [], definitions: [], files: {}, skillIndex: { heroByConfigId: {}, skillById: {} }, batches: [] };
    for (const row of state.batches.filter((b) => b.status === 'ACTIVE')) {
        const path = resolve(root, row.path), folder = resolve(root, 'work/vn-runtime-import/batches') + sep;
        if (!path.startsWith(folder))
            throw new Error('Batch path vượt vùng nội dung.');
        const raw = readFileSync(path);
        if (sha(raw) !== row.sha256)
            throw new Error('Batch hash không khớp.');
        const batch = validateRuntimeBatch(JSON.parse(raw.toString('utf8')));
        if (row.sourceKey !== batch.sourceKey || (result.sourceKey && result.sourceKey !== batch.sourceKey) || (result.sourceFingerprint && result.sourceFingerprint !== batch.sourceFingerprint))
            throw new Error('Các batch khác phiên bản nguồn; cần adapter riêng.');
        result.sourceKey = batch.sourceKey;
        result.sourceFingerprint = batch.sourceFingerprint;
        if (batch.heroCatalog.some((h) => result.heroCatalog.some((old) => old.configId === h.configId)))
            throw new Error('Hero đã thuộc batch ACTIVE khác.');
        for (const [name, file] of Object.entries(batch.files ?? {})) {
            const source = resolve(root, file.sourcePath), allowed = resolve(root, 'com.kaiqigu.cjyxyn.kvsdk/files') + sep;
            if (!/^assets\/(iphonehd|lua\/skill_effect|sound)\//.test(name) || name.includes('..') || !source.startsWith(allowed) || sha(readFileSync(source)) !== file.sha256)
                throw new Error('Resource batch đã đổi hoặc vượt phạm vi.');
            if (result.files[name] && result.files[name].sha256 !== file.sha256)
                throw new Error('Resource cùng đường dẫn khác hash giữa batch.');
            result.files[name] = file;
        }
        if (row.batch !== batch.batch || JSON.stringify([...row.ids].sort()) !== JSON.stringify(batch.heroCatalog.map((h) => h.configId).sort()))
            throw new Error('Ledger và hero batch không đồng bộ.');
        for (const [name, rows] of Object.entries(batch.configs)) {
            result.configs[name] ??= {};
            for (const [key, value] of Object.entries(rows)) {
                if (result.configs[name][key] && JSON.stringify(result.configs[name][key]) !== JSON.stringify(value))
                    throw new Error('Trùng dependency giữa batch.');
                result.configs[name][key] = value;
            }
        }
        result.heroCatalog.push(...batch.heroCatalog);
        result.resources.push(...batch.resources);
        result.batches.push(row);
        Object.assign(result.skillIndex.heroByConfigId, batch.skillIndex.heroByConfigId);
        Object.assign(result.skillIndex.skillById, batch.skillIndex.skillById);
    }
    if (!result.batches.length)
        return;
    cache = result;
    return result;
}
