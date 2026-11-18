import { randomBytes, createHash, timingSafeEqual } from 'node:crypto';
import { hashPassword, verifyPassword } from '../auth/password.js';
import { audit, adminError } from './admin.audit.js';
const digest = (s) => createHash('sha256').update(s).digest('hex');
export const csrfFor = (secret) => digest('sahht-admin-csrf:' + secret);
export const constantEqual = (a, b) => { const x = Buffer.from(a), y = Buffer.from(b); return x.length === y.length && timingSafeEqual(x, y); };
export const cookieToken = (cookie) => /(?:^|;\s*)sahht_admin=([a-f0-9]{64})(?:;|$)/.exec(cookie ?? '')?.[1] ?? '';
export class AdminAuth {
    db;
    now;
    dummy = hashPassword(randomBytes(32).toString('hex'));
    attempts = new Map();
    hashing = 0;
    reauthenticated = new Map();
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    async bootstrapLocal(password) {
        // Chỉ CLI local, ngoại lệ độ dài theo yêu cầu chủ workspace; không có API reset.
        if ([...password].length < 10 || [...password].length > 128)
            adminError('Mật khẩu bootstrap local cần10–128 ký tự.');
        const username = 'adminson123', hash = await hashPassword(password);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT id FROM admin_users WHERE username=?').get(username);
            this.db.prepare("INSERT INTO admin_users(username,password_hash,role,created_at) VALUES(?,?,'OWNER',?) ON CONFLICT(username) DO UPDATE SET password_hash=excluded.password_hash,role='OWNER'").run(username, hash, this.now());
            const id = this.db.prepare('SELECT id FROM admin_users WHERE username=?').get(username).id;
            this.db.prepare('DELETE FROM admin_sessions WHERE admin_id=?').run(id);
            audit(this.db, null, 'admin.local_bootstrap', null, 'Cấu hình OWNER cho môi trường GM local', old ? { id } : null, { id, username, role: 'OWNER' });
            this.db.exec('COMMIT');
            return { id, username, role: 'OWNER' };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    async create(username, password, role = 'OWNER') {
        const name = username.trim().toLowerCase();
        if (!/^[a-z0-9_]{3,32}$/.test(name) || [...password].length < 12 || [...password].length > 128 || !['OWNER', 'ADMIN', 'VIEWER'].includes(role))
            adminError('Admin cần tên3–32 ký tự a-z/0-9/_ và mật khẩu12–128 ký tự.');
        if (this.db.prepare('SELECT id FROM admin_users WHERE username=?').get(name))
            adminError('Admin đã tồn tại.', 409);
        const hash = await hashPassword(password);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const id = Number(this.db.prepare('INSERT INTO admin_users(username,password_hash,role,created_at) VALUES(?,?,?,?)').run(name, hash, role, this.now()).lastInsertRowid);
            audit(this.db, null, 'admin.create', null, 'Tạo quản trị viên local', null, { id, username: name, role });
            this.db.exec('COMMIT');
            return { id, username: name, role };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    async login(username, password, ip) {
        const now = this.now();
        for (const [key, value] of this.attempts)
            if (value.until <= now)
                this.attempts.delete(key);
        const attempt = this.attempts.get(ip) ?? { count: 0, until: now + 15 * 60_000 };
        if (attempt.count >= 10 || this.hashing >= 4)
            adminError('Đã thử quá nhiều lần. Vui lòng chờ rồi thử lại.', 429);
        attempt.count++;
        this.attempts.set(ip, attempt);
        this.hashing++;
        let row;
        let valid = false;
        try {
            row = this.db.prepare('SELECT id,username,role,password_hash FROM admin_users WHERE username=?').get(username.trim().toLowerCase());
            valid = await verifyPassword(password, row?.password_hash ?? await this.dummy);
        }
        finally {
            this.hashing--;
        }
        if (!row || !valid)
            adminError('Tài khoản quản trị hoặc mật khẩu không đúng.', 401);
        const secret = randomBytes(32).toString('hex'), expiresAt = now + 8 * 60 * 60_000;
        this.db.exec('BEGIN IMMEDIATE');
        try {
            this.db.prepare('DELETE FROM admin_sessions WHERE expires_at<=?').run(now);
            this.db.prepare('INSERT INTO admin_sessions(admin_id,token_hash,created_at,expires_at) VALUES(?,?,?,?)').run(row.id, digest(secret), now, expiresAt);
            this.db.prepare('UPDATE admin_users SET last_login_at=? WHERE id=?').run(now, row.id);
            audit(this.db, row.id, 'admin.login', null, 'Đăng nhập khu quản trị');
            this.db.exec('COMMIT');
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
        this.attempts.delete(ip);
        return { secret, expiresAt, admin: { id: row.id, username: row.username, role: row.role }, csrfToken: csrfFor(secret) };
    }
    session(secret) {
        if (!/^[a-f0-9]{64}$/.test(secret))
            return;
        return this.db.prepare('SELECT a.id,a.username,a.role FROM admin_sessions s JOIN admin_users a ON a.id=s.admin_id WHERE s.token_hash=? AND s.expires_at>?').get(digest(secret), this.now());
    }
    async reauthenticate(secret, password, ip) {
        const current = this.session(secret);
        if (!current || current.role !== 'OWNER')
            adminError('Chỉ OWNER được xác thực sao lưu.', 403);
        // Dùng cùng bộ giới hạn thử mật khẩu; không tạo một session đăng nhập mới.
        const now = this.now(), key = 'reauth:' + ip, attempt = this.attempts.get(key) ?? { count: 0, until: now + 15 * 60_000 };
        if (attempt.until <= now) {
            attempt.count = 0;
            attempt.until = now + 15 * 60_000;
        }
        if (attempt.count >= 5 || this.hashing >= 4)
            adminError('Thử xác thực quá nhiều lần. Chờ15 phút.', 429);
        attempt.count++;
        this.attempts.set(key, attempt);
        this.hashing++;
        try {
            const row = this.db.prepare('SELECT password_hash FROM admin_users WHERE id=?').get(current.id);
            if (!row || typeof password !== 'string' || !await verifyPassword(password, String(row.password_hash)))
                adminError('Mật khẩu xác thực không đúng.', 401);
        }
        finally {
            this.hashing--;
        }
        this.attempts.delete(key);
        for (const [k, v] of this.reauthenticated)
            if (v <= now)
                this.reauthenticated.delete(k);
        this.reauthenticated.set(digest(secret), now + 5 * 60_000);
        audit(this.db, current.id, 'admin.backup_reauth', null, 'Xác thực lại cho sao lưu trong5 phút');
        return { ok: true, expiresAt: now + 5 * 60_000 };
    }
    requireRecent(secret) { if (!this.session(secret) || Number(this.reauthenticated.get(digest(secret)) ?? 0) <= this.now())
        adminError('Hãy xác thực lại mật khẩu OWNER để thao tác sao lưu (hiệu lực5 phút).', 428); }
    logout(secret, admin) {
        this.reauthenticated.delete(digest(secret));
        this.db.exec('BEGIN IMMEDIATE');
        try {
            this.db.prepare('DELETE FROM admin_sessions WHERE token_hash=?').run(digest(secret));
            audit(this.db, admin.id, 'admin.logout', null, 'Đăng xuất khu quản trị');
            this.db.exec('COMMIT');
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
