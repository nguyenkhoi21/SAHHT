import { audit } from '../admin/admin.audit.js';
const SERVER_ID = 'local-1';
const fail = (message, statusCode = 422) => { throw Object.assign(new Error(message), { statusCode }); };
export function registrationAccountCapacityReady(db) {
    return !!db.prepare("SELECT 1 FROM sqlite_master WHERE name='local_registration_account_limits' AND type='table'").get();
}
export function installRegistrationAccountCapacity(db) {
    if (registrationAccountCapacityReady(db))
        return;
    if (db.prepare('PRAGMA user_version').get()?.user_version !== 39)
        throw Error('Cần schema39 đã kiểm.');
    db.exec(`BEGIN IMMEDIATE;
 CREATE TABLE local_registration_account_limits(server_id TEXT PRIMARY KEY CHECK(server_id='${SERVER_ID}'),max_accounts INTEGER NOT NULL CHECK(max_accounts BETWEEN 0 AND 100000000),revision INTEGER NOT NULL CHECK(revision>0),updated_at INTEGER NOT NULL,reason TEXT NOT NULL);
 INSERT INTO local_registration_account_limits VALUES('${SERVER_ID}',0,1,strftime('%s','now')*1000,'Mặc định không giới hạn; OWNER cấu hình khi cần.');
 COMMIT;`);
}
function row(db) {
    const r = db.prepare('SELECT * FROM local_registration_account_limits WHERE server_id=?').get(SERVER_ID);
    if (!r)
        throw Error('Thiếu cấu hình giới hạn tài khoản máy chủ.');
    return { serverId: String(r.server_id), maxAccounts: Number(r.max_accounts), revision: Number(r.revision), updatedAt: Number(r.updated_at), reason: String(r.reason) };
}
export function inspectRegistrationAccountCapacity(db) {
    const config = row(db), currentAccounts = Number(db.prepare('SELECT COUNT(*) n FROM users').get().n);
    return { ...config, currentAccounts, available: config.maxAccounts === 0 ? null : Math.max(0, config.maxAccounts - currentAccounts), blocked: config.maxAccounts > 0 && currentAccounts >= config.maxAccounts };
}
export class RegistrationAccountCapacityError extends Error {
    code = 'SERVER_ACCOUNT_LIMIT';
    statusCode = 409;
    constructor() { super('Số lượng tài khoản của máy chủ đạt giới hạn'); }
}
export function checkRegistrationAccountCapacity(db) {
    if (!registrationAccountCapacityReady(db))
        return;
    const state = inspectRegistrationAccountCapacity(db);
    if (state.blocked)
        throw new RegistrationAccountCapacityError();
}
export function saveRegistrationAccountCapacity(db, admin, input) {
    if (!Number.isSafeInteger(input.maxAccounts) || input.maxAccounts < 0 || input.maxAccounts > 100000000 || !Number.isSafeInteger(input.revision) || input.revision < 0 || typeof input.reason !== 'string' || input.reason.trim().length < 5 || input.reason.length > 300)
        fail('Nhập số lượng tài khoản từ 0 đến 100.000.000 và lý do từ 5–300 ký tự.');
    if (!registrationAccountCapacityReady(db))
        throw Object.assign(Error('Chưa áp extension giới hạn tài khoản.'), { statusCode: 409 });
    db.exec('BEGIN IMMEDIATE');
    try {
        const before = row(db);
        if (before.revision !== input.revision)
            fail('Cấu hình vừa thay đổi; tải lại trước khi lưu.', 409);
        db.prepare('UPDATE local_registration_account_limits SET max_accounts=?,revision=revision+1,updated_at=?,reason=? WHERE server_id=?').run(input.maxAccounts, Date.now(), input.reason.trim(), SERVER_ID);
        const after = row(db);
        audit(db, admin, 'security.registration_account_capacity_saved', null, input.reason.trim(), before, after);
        db.exec('COMMIT');
        return after;
    }
    catch (e) {
        if (db.isTransaction)
            db.exec('ROLLBACK');
        throw e;
    }
}
