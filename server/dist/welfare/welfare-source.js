import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { readStaticConfigSync } from '../player/local-content.js';
import { inventoryRewardItem } from '../player/inventory-items.js';
import { welfareFail, welfareLengths } from './welfare-contracts.js';
const proofPath = process.env.WELFARE_SOURCE_FILE ?? new URL('../../data/welfare-source.json', import.meta.url);
const proof = JSON.parse(readFileSync(proofPath, 'utf8'));
const cache = new Map();
export function welfareTicketIcon() {
    const entry = proof.assets.publicTicket;
    const raw = readFileSync(new URL('../../../' + entry.path, import.meta.url));
    if (createHash('sha256').update(raw).digest('hex') !== entry.sha256)
        throw new Error('Hash ảnh vé Phúc Lợi không khớp nguồn Việt Nam.');
    return raw;
}
export function welfareSource(name) {
    if (cache.has(name))
        return cache.get(name);
    const entry = proof.tables[name];
    if (!entry)
        throw new Error('Thiếu nguồn Phúc Lợi: ' + name);
    const raw = readFileSync(new URL('../../../' + entry.path, import.meta.url));
    if (createHash('sha256').update(raw).digest('hex') !== entry.sha256)
        throw new Error('Hash nguồn Phúc Lợi đã thay đổi: ' + name);
    const rows = JSON.parse(raw.toString());
    if (Object.keys(rows).length !== entry.count)
        throw new Error('Số dòng nguồn không khớp.');
    cache.set(name, rows);
    return rows;
}
export function sourceDefinition(kind, version = 1, loop = false) {
    const source = welfareSource(kind === 'daily' ? (loop ? 'daily_award_loop' : 'daily_award') : kind === 'month' ? 'month_award' : 'quarter_award');
    const values = Object.entries(source).filter(([, r]) => kind !== 'quarter' || r.version === version).sort(([a], [b]) => Number(a) - Number(b));
    return { kind, name: { daily: 'Điểm danh', month: 'Thẻ tháng', quarter: 'Thẻ Mùa' }[kind] + ' · nguồn gốc', realm: 'local-1', starts: 0, ends: 4102444800000, sourceVersion: version,
        rows: values.map(([, r], i) => ({ day: i + 1, rewards: structuredClone(r.award ?? r.reward) })) };
}
export function validateRewards(raw) {
    if (!Array.isArray(raw) || !raw.length || raw.length > 4)
        welfareFail('Chọn 1–4 dòng thưởng để phù hợp màn hình gốc.');
    const currencies = [1, 2, 4, 9, 10, 11, 14, 15, 16, 17, 18, 20, 23, 24, 26, 27, 33, 34, 35, 40, 41, 42, 43, 47, 106];
    for (const row of raw) {
        if (!Array.isArray(row) || row.length !== 3 || !row.every(Number.isSafeInteger) || row[2] < 1 || row[2] > 100000000)
            welfareFail('Phần thưởng cần loại, ID và số lượng nguyên hợp lệ.');
        const [type, id, count] = row;
        if (currencies.includes(type)) {
            if (id !== 0 || type === 106 && count > 1000000)
                welfareFail('Mã/số lượng tiền tệ không hợp lệ.');
            continue;
        }
        const table = { 5: 'character_detail', 6: 'item', 7: 'equip', 25: 'pet_detail', 50: 'equip_gem_fate', 108: 'equip_gem_fate_stone', 109: 'equip_gem_fate_word' }[type];
        const cfg = table && readStaticConfigSync(table)[id];
        if (!cfg || type === 6 && !inventoryRewardItem(cfg) || count > ([5, 7, 25].includes(type) ? 5 : 1000000))
            welfareFail('Tài nguyên chưa hỗ trợ hoặc thiếu catalog: ' + type + '/' + id);
    }
    return structuredClone(raw);
}
export function validateDefinition(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw) || Object.keys(raw).some(k => !['kind', 'name', 'realm', 'starts', 'ends', 'sourceVersion', 'rows'].includes(k)))
        welfareFail('Cấu hình chứa trường chưa hỗ trợ.');
    if (!Object.hasOwn(welfareLengths, raw.kind) || raw.realm !== 'local-1' || typeof raw.name !== 'string' || !raw.name.trim() || raw.name.length > 120)
        welfareFail('Tên, hệ thống hoặc máy chủ không hợp lệ.');
    if (![raw.starts, raw.ends].every(Number.isSafeInteger) || raw.starts < 0 || raw.ends <= raw.starts || raw.ends > 4102444800000)
        welfareFail('Lịch hiệu lực không hợp lệ.');
    if (!Number.isInteger(raw.sourceVersion) || ![1, 2, 3].includes(raw.sourceVersion) || raw.kind !== 'quarter' && raw.sourceVersion !== 1)
        welfareFail('Phiên bản nguồn không hợp lệ.');
    if (!Array.isArray(raw.rows) || raw.rows.length !== welfareLengths[raw.kind])
        welfareFail('Phải giữ số mốc gốc: 25 Điểm danh, 21 Thẻ tháng, 90 Thẻ Mùa.');
    return { kind: raw.kind, name: raw.name.trim(), realm: raw.realm, starts: raw.starts, ends: raw.ends, sourceVersion: raw.sourceVersion,
        rows: raw.rows.map((r, i) => { if (!r || r.day !== i + 1 || Object.keys(r).some(k => !['day', 'rewards'].includes(k)))
            welfareFail('Mốc thưởng phải liên tiếp và duy nhất.'); if (raw.kind === 'daily' && Array.isArray(r.rewards) && r.rewards.length > 2)
            welfareFail('Điểm danh hiển thị tối đa 2 phần thưởng mỗi ngày trong game.'); return { day: i + 1, rewards: validateRewards(r.rewards) }; }) };
}
