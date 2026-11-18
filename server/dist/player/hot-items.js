import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
// Chỉ ID phụ thuộc trực tiếp HOT Việt Nam, không ghi đè catalog/bản vá cũ.
const cache = new Map();
export function hotSupplement(name) {
    if (cache.has(name))
        return cache.get(name);
    const root = new URL('../../../', import.meta.url), proof = JSON.parse(readFileSync(new URL('tools/runtime/hot-source.json', root), 'utf8'));
    const r = proof.tables[name], raw = readFileSync(new URL(r.path, root));
    if (createHash('sha256').update(raw).digest('hex') !== r.sha256)
        throw Error('Nguồn vật phẩm HOT khác hash.');
    const table = JSON.parse(raw.toString()), ids = name === 'item' ? proof.supplementalItems : proof.supplementalExchangeIds;
    const rows = Object.fromEntries(ids.map((id) => { if (!table[id])
        throw Error('Thiếu định nghĩa HOT Việt Nam #' + id); return [String(id), table[id]]; }));
    cache.set(name, rows);
    return rows;
}
