import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
export const petProof = () => JSON.parse(readFileSync(new URL('../../../tools/runtime/pet-source.json', import.meta.url), 'utf8'));
const cache = new Map();
export function petConfig(name) { if (cache.has(name))
    return cache.get(name); const proof = petProof().tables[name]; if (!proof)
    throw Error('Thiếu bảng PET đã xác minh: ' + name); const raw = readFileSync(new URL('../../../' + proof.path, import.meta.url)); if (createHash('sha256').update(raw).digest('hex') !== proof.sha256)
    throw Error('Nguồn PET Việt Nam đổi hash: ' + name); const data = JSON.parse(raw.toString()); cache.set(name, data); return data; }
export const petFail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export function petRecipes() { return Object.fromEntries(petProof().recipes.map((id) => [id, petConfig('exchange')[id]])); }
export function petItems() { const ids = new Set(Object.values(petRecipes()).map((r) => r.need_item)); for (const id of petProof().materialItems ?? [])
    ids.add(id); return Object.fromEntries([...ids].map(id => [id, petConfig('item')[id]]).filter(([, r]) => !!r)); }
let boxItems;
export function petBoxItem(id) { if (!boxItems) {
    boxItems = new Set(Object.entries(petConfig('item')).filter(([, i]) => (i.use_effect ?? []).some((key) => (petConfig('box')[key] ?? []).some((b) => (b.reward ?? []).some((r) => [24, 25, 26, 27].includes(r[0]))))).map(([id]) => Number(id)));
} return boxItems.has(id); }
