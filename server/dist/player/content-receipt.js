import { createHash } from 'node:crypto';
import { beginHotSpend, endHotSpend } from './hot-spending.js';
// Dùng chung ledger migration17; callback chỉ ghi trong transaction này.
export function contentReceipt(db, userId, method, key, body, run, replay) {
    if (typeof key !== 'string' || !/^[A-Za-z0-9_.:-]{8,160}$/.test(key))
        throw Object.assign(new Error('Thiếu mã thao tác duy nhất; hãy dùng client test mới.'), { statusCode: 422 });
    const hash = createHash('sha256').update(JSON.stringify(body)).digest('hex');
    db.exec('BEGIN IMMEDIATE');
    try {
        const old = db.prepare('SELECT method,fingerprint,result FROM player_content_operations WHERE user_id=? AND request_key=?').get(userId, key);
        if (old) {
            if (old.method !== method || old.fingerprint !== hash)
                throw Object.assign(new Error('Mã thao tác đã được dùng cho nội dung khác.'), { statusCode: 422 });
            const result = replay(JSON.parse(String(old.result)));
            db.exec('COMMIT');
            return result;
        }
        beginHotSpend(db, userId, method, key);
        const result = run();
        endHotSpend(db, userId);
        db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(userId, key, method, hash, JSON.stringify(result), Date.now());
        db.exec('COMMIT');
        return result;
    }
    catch (e) {
        db.exec('ROLLBACK');
        throw e;
    }
}
