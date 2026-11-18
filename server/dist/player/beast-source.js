import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const root = new URL('../../../', import.meta.url), cache = new Map();
let source;
export function beastSource() {
    source ??= JSON.parse(readFileSync(new URL('tools/runtime/beast-recovery-source.json', root), 'utf8'));
    if (source.revision !== 'phase36-beasts-vn-runtime-v1' || source.sourceFingerprint !== '00d83b786d933a14a7de9e5bacf9c555a62ae722a19fe57ca51446ef1d26194f')
        throw Error('Sai nguồn runtime Thần Thú Việt Nam.');
    return source;
}
export function beastConfig(name) {
    const row = beastSource().configs[name];
    if (!row || !/^com\.kaiqigu\.cjyxyn\.kvsdk\/files\/config\/combiner[a-z_]*\.config$/.test(row.path))
        throw Error('Bảng Thần Thú chưa được xác minh.');
    if (!cache.has(name)) {
        const raw = readFileSync(new URL(row.path, root));
        if (createHash('sha256').update(raw).digest('hex') !== row.sha256)
            throw Error('Hash nguồn Thần Thú đã đổi: ' + name);
        cache.set(name, JSON.parse(raw.toString('utf8')));
    }
    return cache.get(name);
}
export function beastExpMaterial(base) {
    const entry = beastSource().expMaterial;
    if (!entry || entry.key !== '56' || entry.path !== 'com.kaiqigu.cjyxyn.kvsdk/files/config/character_detail.config')
        throw Error('Chưa đóng nguồn thẻ EXP Thần Thú.');
    if (!cache.has('expMaterial')) {
        const raw = readFileSync(new URL(entry.path, root));
        if (createHash('sha256').update(raw).digest('hex') !== entry.sha256)
            throw Error('Nguồn thẻ EXP Thần Thú đã đổi.');
        cache.set('expMaterial', JSON.parse(raw.toString('utf8'))['56']);
    }
    const row = cache.get('expMaterial'), fields = ['name', 'story', 'short_story'], gameplay = (v) => JSON.stringify(Object.fromEntries(Object.entries(v).filter(([key]) => !fields.includes(key)).sort(([a], [b]) => a.localeCompare(b))));
    if (gameplay(base) !== gameplay(row) || row.call_price !== 1280 || row.skill_num !== 0 || fields.some(f => base[f] !== entry.baselineText[f] && base[f] !== row[f]))
        throw Error('Thẻ56 khác mapping gameplay; không ghi đè.');
    return { ...base, ...Object.fromEntries(fields.map(f => [f, row[f]])) };
}
