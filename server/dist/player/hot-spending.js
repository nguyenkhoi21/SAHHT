const allowed = /^(?:shop\.|gacha\.|cards\.|equip\.|gem\.|gem_fate\.|soul\.|medal\.|talisman\.|laboratory\.|factory\.|arena\.purchase|homeland\.|gringotts\.refresh$)/;
// Scope được đặt bên trong transaction của nghiệp vụ. Trigger chỉ ghi giảm
// Xu thật trong scope; không nhìn chênh lệch số dư sau khi đã cộng thưởng.
export function beginHotSpend(db, user, kind, key, at = Date.now()) {
    if (!allowed.test(kind) || !db.prepare("SELECT 1 FROM sqlite_master WHERE name='hot_spend_context'").get())
        return;
    if (!db.isTransaction)
        throw Error('Theo dõi tiêu Xu cần transaction.');
    db.prepare('INSERT INTO hot_spend_context(user_id,kind,request_key,created_at) VALUES(?,?,?,?)').run(user, kind, key, at);
}
export function endHotSpend(db, user) { if (db.prepare("SELECT 1 FROM sqlite_master WHERE name='hot_spend_context'").get())
    db.prepare('DELETE FROM hot_spend_context WHERE user_id=?').run(user); }
