import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const root = new URL('../../../', import.meta.url);
let manifest;
const cache = new Map();
export function phase36Source() {
    manifest ??= JSON.parse(readFileSync(new URL('tools/runtime/phase36-source.json', root), 'utf8'));
    if (manifest.revision !== 'phase36-vn-v1' || manifest.apkSha256 !== 'c89140d7361562addc2b249e45d4d71ceea263cd9ee3e6fff042c8cd38057f70')
        throw Error('Sai nguồn Việt Nam Phase36.');
    return manifest;
}
export function phase36Config(name) {
    if (!/^[a-z_0-9]+$/.test(name))
        throw Error('Tên bảng nguồn không hợp lệ.');
    if (!cache.has(name)) {
        const entry = phase36Source().files['config/' + name + '.config'];
        if (!entry)
            throw Error('Chưa xác minh bảng nguồn: ' + name);
        const raw = readFileSync(new URL(entry.path, root));
        if (createHash('sha256').update(raw).digest('hex') !== entry.decodedSha256)
            throw Error('Hash nguồn thay đổi: ' + name);
        cache.set(name, JSON.parse(raw.toString('utf8')));
    }
    return cache.get(name);
}
