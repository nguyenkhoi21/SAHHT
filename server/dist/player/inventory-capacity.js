import { readConfigSync } from './local-content.js';
// item.config: is_use 7/8/14, use_effect [5]. role.config: soul_max 52.
// Trần 5.000 là chính sách LOCAL được chủ dự án chốt, không nhận là trần bản gốc.
export const inventoryBags = {
    4001: { kind: 'hero', field: 'card_max', table: 'player_heroes', label: 'Tướng', initial: 40, use: 7, slots: 5 },
    5001: { kind: 'equipment', field: 'equip_max', table: 'player_equipment', label: 'Trang bị', initial: 30, use: 8, slots: 5 },
    4500: { kind: 'soul', field: 'soul_max', table: 'player_auxiliary', label: 'Anh Hồn', initial: 52, use: 14, slots: 5 },
};
export const inventoryCapacityLimit = 5000;
const fail = (m) => { throw Object.assign(Error(m), { statusCode: 422 }); };
export function capacityFields(p) {
    const row = readConfigSync('role')[p.level ?? 1];
    if (!row)
        fail('Thiếu dung lượng kho theo cấp nhân vật.');
    const bonuses = { ...p._local_inventory_bonus }, fields = {};
    for (const c of Object.values(inventoryBags)) {
        const base = Number(row[c.kind === 'hero' ? 'character_max' : c.field]);
        if (!Number.isSafeInteger(base) || base < 1)
            fail('Dung lượng nguồn không hợp lệ.');
        const bonus = bonuses[c.field] ?? Number(p[c.field] ?? base) - base;
        if (!Number.isSafeInteger(bonus) || base + bonus < 0)
            fail('Dung lượng mở rộng đã lưu không hợp lệ.');
        bonuses[c.field] = bonus;
        fields[c.field] = Math.max(Number(p[c.field] ?? 0), Math.min(inventoryCapacityLimit, base + bonus));
    }
    return { ...fields, _local_inventory_bonus: bonuses };
}
export function inventoryCapacity(db, uid) {
    const row = db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid);
    if (!row)
        fail('Không tìm thấy dữ liệu người chơi.');
    const raw = JSON.parse(String(row.profile)), p = { ...raw, ...capacityFields(raw) };
    return Object.entries(inventoryBags).map(([id, c]) => ({ itemId: Number(id), ...c,
        current: Number(p[c.field] ?? c.initial), maximum: inventoryCapacityLimit,
        used: Number(db.prepare(`SELECT COUNT(*) n FROM ${c.table} WHERE user_id=?${c.kind === 'soul' ? " AND kind='soul'" : ''}`).get(uid).n),
        owned: Number(db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(uid, Number(id))?.quantity ?? 0),
        limitSource: 'LOCAL_OWNER_5000', source: 'item.config: is_use/use_effect; role.config: soul_max' }));
}
// Xem trước không ghi; shop mua túi kiểm cả số túi đang chờ dùng trước khi thu tiền.
export function previewInventoryExpansion(db, uid, id, n, definition) {
    const c = inventoryBags[id];
    if (!c || definition.is_use !== c.use || definition.use_num !== 1 || definition.daily_use !== 0 || definition.use_effect?.length !== 1 || definition.use_effect[0] !== c.slots)
        fail('Quy tắc túi mở rộng không khớp nguồn.');
    if (!Number.isSafeInteger(n) || n < 1 || n > definition.stack)
        fail('Số túi mở rộng không hợp lệ.');
    const raw = JSON.parse(String(db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid).profile)), p = { ...raw, ...capacityFields(raw) }, before = p[c.field], after = before + c.slots * n;
    if (!Number.isSafeInteger(before) || before < 0 || !Number.isSafeInteger(after) || after > inventoryCapacityLimit)
        fail(`Kho ${c.label} tối đa ${inventoryCapacityLimit} ô; chưa tiêu túi hoặc tài nguyên.`);
    return { kind: c.kind, field: c.field, before, after, added: c.slots * n, maximum: inventoryCapacityLimit };
}
// Chỉ gọi trong transaction item.use; không tự commit.
export function expandInventory(db, uid, id, n, definition) {
    const change = previewInventoryExpansion(db, uid, id, n, definition), raw = JSON.parse(String(db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid).profile)), p = { ...raw, ...capacityFields(raw) };
    p[change.field] = change.after;
    p._local_inventory_bonus[change.field] += change.added;
    db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), uid);
    return change;
}
