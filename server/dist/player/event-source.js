import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const cache = new Map();
export function eventSource(name) {
    if (cache.has(name))
        return cache.get(name);
    const root = new URL('../../../', import.meta.url), manifest = JSON.parse(readFileSync(new URL('tools/runtime/event-planner-source.json', root), 'utf8')).tables[name];
    if (!manifest)
        throw Error('Bảng sự kiện chưa có chứng cứ nguồn: ' + name);
    const raw = readFileSync(new URL(manifest.sourcePath, root)), parsed = readFileSync(new URL(manifest.path, root)), sha = (b) => createHash('sha256').update(b).digest('hex');
    if (sha(raw) !== manifest.sourceSha256 || sha(parsed) !== manifest.sha256 || JSON.stringify(JSON.parse(raw.toString())) !== JSON.stringify(JSON.parse(parsed.toString())))
        throw Error('Hash nguồn sự kiện Việt Nam không khớp: ' + name);
    const data = JSON.parse(parsed.toString());
    cache.set(name, data);
    return data;
}
export function skyPresets() { return { regular: [...new Set(Object.values(eventSource('bandit')).map(r => Number(r.version)))].sort((a, b) => b - a), opening: [0] }; }
export function skyRows(target, version) {
    const data = eventSource(target === 'server.905' ? 'server_bandit' : 'bandit');
    const rows = Object.entries(data).filter(([, r]) => target === 'server.905' || r.version === version).map(([key, r]) => ({ ...r, key: Number(key) })).sort((a, b) => Number(a.id ?? a.key) - Number(b.id ?? b.key));
    if (rows.length !== 7)
        throw Error('Cần đủ bảy lượt Xu đầy trời từ cùng bảng nguồn.');
    for (const r of rows) {
        if (!Number.isSafeInteger(r.coin) || r.coin <= 0 || !Array.isArray(r.reward_coin) || r.reward_coin.some((v) => !Array.isArray(v) || v.length !== 3 || !v.every(Number.isSafeInteger) || v[0] < 0 || v[1] < v[0] || v[2] <= 0) || r.reward_coin.reduce((s, v) => s + v[2], 0) !== 100)
            throw Error('Bảng chi phí/tỷ trọng Xu đầy trời chưa hợp lệ.');
    }
    return rows;
}
