import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
// Bổ sung chính xác tám ID mà bảng Aether VN tham chiếu. Không thay tên/ID
// hiện có, không bịa recipe và không đổi quyền dùng/giá/stack của bản gốc.
let cache;
export function aetherSupplementalItems() {
    if (cache)
        return cache;
    const proof = JSON.parse(readFileSync(new URL('../../../tools/runtime/aether-source.json', import.meta.url), 'utf8')).supplementalItems;
    if (!proof)
        return {};
    const raw = readFileSync(new URL('../../../' + proof.path, import.meta.url));
    if (createHash('sha256').update(raw).digest('hex') !== proof.sha256)
        throw Error('Nguồn vật phẩm phụ thuộc Aether đã đổi hash.');
    const source = JSON.parse(raw.toString()), rows = {};
    for (const id of proof.ids) {
        if (!source[id])
            throw Error('Vật phẩm phụ thuộc Aether không có trong nguồn VN.');
        rows[id] = source[id];
    }
    return cache = rows;
}
