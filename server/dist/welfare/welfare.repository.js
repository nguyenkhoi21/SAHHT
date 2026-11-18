import { createHash } from 'node:crypto';
import { welfareFail } from './welfare-contracts.js';
export class WelfareRepository {
    db;
    constructor(db) {
        this.db = db;
        if (!db.prepare("SELECT 1 FROM sqlite_master WHERE name='welfare_schema'").get() || db.prepare('SELECT version FROM welfare_schema').get()?.version !== 1)
            welfareFail('Extension Phúc Lợi chưa được áp theo quy trình backup/migration.', 503);
    }
    transaction(run) {
        if (this.db.isTransaction)
            throw new Error('Phúc Lợi cần transaction riêng.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const result = run();
            this.db.exec('COMMIT');
            return result;
        }
        catch (e) {
            if (this.db.isTransaction)
                this.db.exec('ROLLBACK');
            throw e;
        }
    }
    operation(actor, requestId, input, at, run) {
        if (typeof requestId !== 'string' || !/^[a-zA-Z0-9:_-]{8,120}$/.test(requestId))
            welfareFail('Thiếu mã thao tác hợp lệ; hãy tải lại và thử lại.');
        const hash = createHash('sha256').update(JSON.stringify(input)).digest('hex');
        return this.transaction(() => {
            const old = this.db.prepare('SELECT fingerprint,result FROM welfare_operations WHERE actor=? AND request_key=?').get(actor, requestId);
            if (old) {
                if (old.fingerprint !== hash)
                    welfareFail('Mã thao tác đã dùng cho nội dung khác.', 409);
                return { ...JSON.parse(String(old.result)), replayed: true };
            }
            const result = run();
            this.db.prepare('INSERT INTO welfare_operations VALUES(?,?,?,?,?)').run(actor, requestId, hash, JSON.stringify(result), at);
            return result;
        });
    }
}
