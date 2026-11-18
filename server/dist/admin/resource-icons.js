import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { readConfigSync } from '../player/local-content.js';
import { petProof } from '../player/pet-source.js';
const root = new URL('../../../', import.meta.url);
let proof, staged;
function stagedIcon(name) { try {
    staged ??= JSON.parse(readFileSync(new URL('work/admin-vnext/icons/index.json', root), 'utf8'));
}
catch {
    return null;
} const p = staged.files[name]; if (!p)
    return null; const raw = readFileSync(new URL(p.path, root)); if (createHash('sha256').update(raw).digest('hex') !== p.sha256)
    throw Error('Icon staged không khớp hash VN.'); return raw; }
const tables = { 5: 'character_detail', 6: 'item', 7: 'equip', 25: 'pet_detail', 50: 'equip_gem_fate', 108: 'equip_gem_fate_stone', 109: 'equip_gem_fate_word' };
export function resourceIcon(type, id) {
    if (!/^\d{1,8}$/.test(id))
        return null;
    if (id === '0')
        return stagedIcon('currency-' + type + '.png');
    if (!tables[type])
        return null;
    if (type === 25) {
        const p = petProof().adminIcons[id];
        if (p) {
            const raw = readFileSync(new URL(p.path, root));
            if (createHash('sha256').update(raw).digest('hex') !== p.sha256)
                throw Error('Ảnh PET sai hash nguồn.');
            return raw;
        }
    }
    const cfg = readConfigSync(tables[type])[id];
    let icon = cfg?.icon ?? cfg?.img ?? cfg?.image;
    if (typeof icon !== 'string' || !/^[-a-zA-Z0-9_]+(?:\.png)?$/.test(icon))
        return null;
    if (!icon.endsWith('.png'))
        icon += '.png';
    const stagedFile = stagedIcon(icon);
    if (stagedFile)
        return stagedFile;
    proof ??= JSON.parse(readFileSync(new URL('tools/runtime/hot-source.json', root), 'utf8'));
    const asset = proof.assets['assets/iphonehd/icon/' + icon];
    if (asset) {
        const raw = readFileSync(new URL(asset.servedPath, root));
        if (createHash('sha256').update(raw).digest('hex') !== asset.sha256)
            throw Error('Ảnh thưởng sai hash nguồn.');
        return raw;
    }
    // Chỉ các cây tài nguyên Việt Nam đã dùng trong pipeline, không tìm fallback China.
    for (const prefix of ['work/apk/assets/iphonehd/icon/', 'com.kaiqigu.cjyxyn.kvsdk/files/Resources/iphonehd/icon/'])
        try {
            return readFileSync(new URL(prefix + icon, root));
        }
        catch { }
    return null;
}
