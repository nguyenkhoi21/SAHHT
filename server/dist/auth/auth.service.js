import { checkRegistrationAccountCapacity, registrationAccountCapacityReady } from './registration-account-capacity.js';
import { checkRegistrationSlot, consumeRegistrationSlot, registrationRateLimitReady, RegistrationRateLimitError, recordRegistrationDenial } from './registration-rate-limit.js';
import { createHash, randomBytes } from 'node:crypto';
import { openDatabase } from '../db/database.js';
import { hashPassword, verifyPassword } from './password.js';
export class AuthError extends Error {
    status;
    code;
    constructor(status, code, message) {
        super(message);
        this.status = status;
        this.code = code;
    }
}
export const hashToken = (value) => createHash('sha256').update(value).digest('hex');
export const localUserId = (id) => `local_user_${id}`;
export const localAccount = (id) => `kvgames_${localUserId(id)}`;
export class AuthService {
    now;
    db;
    dummyHash;
    constructor(path, now = Date.now) {
        this.now = now;
        this.db = openDatabase(path);
        this.dummyHash = hashPassword(randomBytes(24).toString('hex'));
    }
    normalizeUsername(value) {
        if (typeof value !== 'string')
            throw new AuthError(400, 'INVALID_USERNAME', 'Vui lòng nhập đầy đủ thông tin.');
        const name = value.trim().toLowerCase();
        if (!/^[a-z0-9_]{3,24}$/.test(name))
            throw new AuthError(400, 'INVALID_USERNAME', 'Tài khoản gồm 3–24 chữ thường, số hoặc dấu gạch dưới.');
        return name;
    }
    password(value) {
        if (typeof value !== 'string' || [...value].length < 8 || [...value].length > 64)
            throw new AuthError(400, 'INVALID_PASSWORD', 'Mật khẩu cần từ 8 đến 64 ký tự.');
        return value;
    }
    registrationHashing = 0;
    async register(username, password, registrationIp) {
        const name = this.normalizeUsername(username), secret = this.password(password);
        const limited = registrationIp !== undefined && registrationRateLimitReady(this.db);
        if (registrationIp !== undefined && !limited)
            throw new AuthError(503, 'REGISTRATION_UNAVAILABLE', 'Đăng ký đang tạm bảo trì.');
        if (registrationIp !== undefined && !registrationAccountCapacityReady(this.db))
            throw new AuthError(503, 'REGISTRATION_UNAVAILABLE', 'Đăng ký đang tạm bảo trì.');
        if (this.db.prepare('SELECT id FROM users WHERE username=?').get(name))
            throw new AuthError(409, 'USERNAME_EXISTS', 'Tài khoản đã tồn tại.');
        try {
            checkRegistrationAccountCapacity(this.db);
            if (limited)
                checkRegistrationSlot(this.db, registrationIp, this.now());
            if (registrationIp !== undefined && this.registrationHashing >= 4)
                throw new AuthError(429, 'REGISTRATION_BUSY', 'Có nhiều yêu cầu đăng ký cùng lúc. Vui lòng thử lại sau vài giây.');
            this.registrationHashing++;
            let encoded;
            try {
                encoded = await hashPassword(secret);
            }
            finally {
                this.registrationHashing--;
            }
            const timestamp = this.now();
            this.db.exec('BEGIN IMMEDIATE');
            try {
                checkRegistrationAccountCapacity(this.db);
                if (limited)
                    consumeRegistrationSlot(this.db, registrationIp, timestamp);
                const result = this.db.prepare('INSERT INTO users(username,password_hash,created_at,updated_at) VALUES(?,?,?,?)').run(name, encoded, timestamp, timestamp);
                const id = Number(result.lastInsertRowid);
                this.db.prepare('INSERT INTO player_profiles(user_id,game_uid,role,created_at) VALUES(?,?,?,?)').run(id, `local_player_${id}`, '1', timestamp);
                this.db.exec('COMMIT');
                return { id, username: name };
            }
            catch (error) {
                if (this.db.isTransaction)
                    this.db.exec('ROLLBACK');
                if (this.db.prepare('SELECT id FROM users WHERE username=?').get(name))
                    throw new AuthError(409, 'USERNAME_EXISTS', 'Tài khoản đã tồn tại.');
                throw error;
            }
        }
        catch (error) {
            if (limited && error instanceof RegistrationRateLimitError)
                recordRegistrationDenial(this.db, registrationIp, error, this.now());
            throw error;
        }
    }
    async login(username, password) {
        const name = this.normalizeUsername(username);
        const secret = this.password(password);
        const row = this.db.prepare('SELECT id,username,password_hash FROM users WHERE username=?').get(name);
        const valid = await verifyPassword(secret, row?.password_hash ?? await this.dummyHash);
        if (!row || !valid || (this.db.prepare('SELECT password_hash FROM users WHERE id=?').get(row.id)?.password_hash !== row.password_hash))
            throw new AuthError(401, 'INVALID_CREDENTIALS', 'Tài khoản hoặc mật khẩu không đúng.');
        const sessionToken = 'local_' + randomBytes(32).toString('hex');
        const created = this.now();
        const expires = created + 24 * 60 * 60 * 1000;
        this.db.prepare('INSERT INTO sessions(user_id,token_hash,created_at,expires_at) VALUES(?,?,?,?)').run(row.id, hashToken(sessionToken), created, expires);
        return {
            user: { id: row.id, username: row.username }, sessionToken, expiresAt: new Date(expires).toISOString(),
            authResult: { result: true, platform: 'kvgames', needverify: true, userID: localUserId(row.id), session_id: sessionToken },
        };
    }
    session(token) {
        if (typeof token !== 'string' || !/^local_[a-f0-9]{64}$/.test(token))
            return;
        return this.db.prepare(`SELECT s.id,s.user_id,s.expires_at,s.game_token_hash,u.username,p.game_uid,p.role
      FROM sessions s JOIN users u ON u.id=s.user_id JOIN player_profiles p ON p.user_id=u.id
      WHERE s.token_hash=? AND s.expires_at>?`).get(hashToken(token), this.now());
    }
    logout(token) { this.db.prepare('DELETE FROM sessions WHERE token_hash=?').run(hashToken(token)); }
    remember(current) {
        if (!this.db.prepare('SELECT 1 FROM sessions WHERE id=? AND expires_at>?').get(current.id, this.now()))
            throw new AuthError(401, 'SESSION_EXPIRED', 'Hãy đăng nhập lại.');
        return this.newRemembered(current.user_id);
    }
    newRemembered(userId, family = randomBytes(24).toString('hex')) {
        const credential = 'remember_' + randomBytes(32).toString('hex'), at = this.now(), expires = at + 30 * 86400000;
        this.db.prepare('INSERT INTO auth_remembered(user_id,token_hash,family,created_at,expires_at) VALUES(?,?,?,?,?)').run(userId, hashToken(credential), family, at, expires);
        return { credential, expiresAt: new Date(expires).toISOString() };
    }
    refreshRemembered(username, value) {
        const name = this.normalizeUsername(username);
        if (typeof value !== 'string' || !/^remember_[a-f0-9]{64}$/.test(value))
            throw new AuthError(401, 'REMEMBER_EXPIRED', 'Phiên ghi nhớ đã hết hạn. Hãy nhập mật khẩu.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const row = this.db.prepare('SELECT r.*,u.username FROM auth_remembered r JOIN users u ON u.id=r.user_id WHERE token_hash=?').get(hashToken(value));
            if (!row || row.username !== name || row.revoked_at || Number(row.expires_at) <= this.now())
                throw new AuthError(401, 'REMEMBER_EXPIRED', 'Phiên ghi nhớ đã hết hạn. Hãy nhập mật khẩu.');
            if (row.used_at) {
                this.db.prepare('UPDATE auth_remembered SET revoked_at=? WHERE family=?').run(this.now(), row.family);
                this.db.prepare('DELETE FROM sessions WHERE id IN(SELECT session_id FROM auth_remembered_sessions WHERE family=?)').run(row.family);
                this.db.exec('COMMIT');
                throw new AuthError(401, 'REMEMBER_REUSED', 'Phiên ghi nhớ đã được thay thế. Hãy đăng nhập bằng mật khẩu.');
            }
            this.db.prepare('UPDATE auth_remembered SET used_at=? WHERE id=? AND used_at IS NULL').run(this.now(), row.id);
            const rotated = this.newRemembered(Number(row.user_id), String(row.family));
            const sessionToken = 'local_' + randomBytes(32).toString('hex'), at = this.now();
            const issued = this.db.prepare('INSERT INTO sessions(user_id,token_hash,created_at,expires_at) VALUES(?,?,?,?)').run(row.user_id, hashToken(sessionToken), at, at + 86400000);
            this.db.prepare('INSERT INTO auth_remembered_sessions VALUES(?,?)').run(issued.lastInsertRowid, row.family);
            this.db.exec('COMMIT');
            return { ok: true, user: { id: row.user_id, username: name }, sessionToken, remembered: rotated, authResult: { result: true, platform: 'kvgames', needverify: true, userID: localUserId(Number(row.user_id)), session_id: sessionToken } };
        }
        catch (e) {
            if (this.db.isTransaction)
                this.db.exec('ROLLBACK');
            throw e;
        }
    }
    forgetRemembered(value) {
        if (typeof value !== 'string' || !/^remember_[a-f0-9]{64}$/.test(value))
            return;
        const r = this.db.prepare('SELECT family FROM auth_remembered WHERE token_hash=?').get(hashToken(value));
        if (r) {
            this.db.exec('BEGIN IMMEDIATE');
            try {
                this.db.prepare('UPDATE auth_remembered SET revoked_at=? WHERE family=?').run(this.now(), r.family);
                this.db.prepare('DELETE FROM sessions WHERE id IN(SELECT session_id FROM auth_remembered_sessions WHERE family=?)').run(r.family);
                this.db.exec('COMMIT');
            }
            catch (e) {
                this.db.exec('ROLLBACK');
                throw e;
            }
        }
    }
    async changePassword(current, oldValue, newValue, confirm) {
        const oldPassword = this.password(oldValue), newPassword = this.password(newValue);
        if (newPassword !== confirm)
            throw new AuthError(400, 'PASSWORD_MISMATCH', 'Xác nhận mật khẩu không khớp.');
        if (oldPassword === newPassword)
            throw new AuthError(400, 'PASSWORD_UNCHANGED', 'Mật khẩu mới phải khác mật khẩu hiện tại.');
        const limited = () => Number(this.db.prepare('SELECT COUNT(*) n FROM auth_password_attempts WHERE user_id=? AND created_at>? AND success=0').get(current.user_id, this.now() - 900000).n) >= 5;
        if (limited())
            throw new AuthError(429, 'PASSWORD_RATE_LIMIT', 'Đã thử sai quá nhiều lần. Vui lòng thử lại sau 15 phút.');
        const row = this.db.prepare('SELECT password_hash FROM users WHERE id=?').get(current.user_id);
        const valid = await verifyPassword(oldPassword, String(row.password_hash));
        if (!valid) {
            this.db.prepare('INSERT INTO auth_password_attempts VALUES(?,?,0)').run(current.user_id, this.now());
            throw new AuthError(401, 'WRONG_PASSWORD', 'Mật khẩu hiện tại không đúng.');
        }
        const encoded = await hashPassword(newPassword);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (limited())
                throw new AuthError(429, 'PASSWORD_RATE_LIMIT', 'Vui lòng thử lại sau 15 phút.');
            if (!this.db.prepare('SELECT 1 FROM sessions WHERE id=? AND user_id=? AND expires_at>?').get(current.id, current.user_id, this.now()))
                throw new AuthError(401, 'SESSION_EXPIRED', 'Phiên đăng nhập đã hết hạn.');
            const changed = this.db.prepare('UPDATE users SET password_hash=?,updated_at=? WHERE id=? AND password_hash=?').run(encoded, this.now(), current.user_id, row.password_hash);
            if (changed.changes !== 1)
                throw new AuthError(409, 'PASSWORD_CHANGED', 'Mật khẩu vừa thay đổi. Hãy đăng nhập lại.');
            this.db.prepare('DELETE FROM sessions WHERE user_id=?').run(current.user_id);
            this.db.prepare('UPDATE auth_remembered SET revoked_at=? WHERE user_id=?').run(this.now(), current.user_id);
            this.db.prepare('INSERT INTO auth_password_attempts VALUES(?,?,1)').run(current.user_id, this.now());
            this.db.prepare("INSERT INTO admin_audit(admin_id,action,target_user_id,created_at,summary) VALUES(NULL,'account.password_changed',?,?,?)").run(current.user_id, this.now(), 'Đổi mật khẩu local, thu hồi toàn bộ phiên');
            this.db.exec('COMMIT');
            return { ok: true, message: 'Đã đổi mật khẩu. Vui lòng đăng nhập lại trên các thiết bị.' };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    issueGameToken(session) {
        const mk = 'local_mk_' + randomBytes(24).toString('hex');
        this.db.prepare('UPDATE sessions SET game_token_hash=? WHERE id=?').run(hashToken(mk), session.id);
        return mk;
    }
    validGameToken(session, value) {
        return typeof value === 'string' && session.game_token_hash === hashToken(value);
    }
    close() { this.db.close(); }
}
