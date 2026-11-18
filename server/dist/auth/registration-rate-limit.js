import { isIP } from 'node:net';
import { audit } from '../admin/admin.audit.js';
const fields = ['perHour', 'perDay', 'perWeek', 'perMonth'];
const offset = 7 * 3600000, day = 86400000;
const fail = (message, statusCode = 422) => { throw Object.assign(new Error(message), { statusCode }); };
export function normalizeRegistrationIp(value) {
    if (typeof value !== 'string' || value.length > 64 || value.includes('%') || !isIP(value.trim()))
        return fail('Nhập địa chỉ IPv4 hoặc IPv6 hợp lệ.');
    let ip = value.trim().toLowerCase();
    if (isIP(ip) === 6) {
        ip = new URL('http://[' + ip + ']/').hostname.slice(1, -1);
        const mapped = /^::ffff:([0-9a-f]{1,4}):([0-9a-f]{1,4})$/.exec(ip);
        if (mapped) {
            const n = parseInt(mapped[1], 16) * 65536 + parseInt(mapped[2], 16);
            ip = [n >>> 24, (n >>> 16) & 255, (n >>> 8) & 255, n & 255].join('.');
        }
    }
    return ip === '::1' ? '127.0.0.1' : ip;
}
export function registrationRateLimitReady(db) {
    return !!db.prepare("SELECT 1 FROM sqlite_master WHERE name='local_registration_security_schema' AND type='table'").get() && db.prepare('SELECT version FROM local_registration_security_schema').get()?.version === 1;
}
export function installRegistrationRateLimit(db) {
    if (registrationRateLimitReady(db))
        return;
    if (db.prepare('PRAGMA user_version').get()?.user_version !== 39)
        throw Error('Cần schema39 đã kiểm.');
    db.exec(`BEGIN IMMEDIATE;
 CREATE TABLE local_registration_security_schema(version INTEGER PRIMARY KEY CHECK(version=1));
 INSERT INTO local_registration_security_schema VALUES(1);
 CREATE TABLE local_registration_rules(ip TEXT PRIMARY KEY,enabled INTEGER NOT NULL CHECK(enabled IN(0,1)),per_hour INTEGER NOT NULL CHECK(per_hour BETWEEN 0 AND 1000000),per_day INTEGER NOT NULL CHECK(per_day BETWEEN 0 AND 1000000),per_week INTEGER NOT NULL CHECK(per_week BETWEEN 0 AND 1000000),per_month INTEGER NOT NULL CHECK(per_month BETWEEN 0 AND 1000000),revision INTEGER NOT NULL CHECK(revision>0),active INTEGER NOT NULL CHECK(active IN(0,1)),updated_at INTEGER NOT NULL,reason TEXT NOT NULL);
 INSERT INTO local_registration_rules VALUES('*',0,5,20,100,300,1,1,strftime('%s','now')*1000,'Cấu hình ban đầu; OWNER bật sau khi kiểm tra IP kết nối.');
 CREATE TABLE local_registration_ip_counters(ip TEXT NOT NULL,period TEXT NOT NULL CHECK(period IN('hour','day','week','month')),starts_at INTEGER NOT NULL,count INTEGER NOT NULL CHECK(count>0),updated_at INTEGER NOT NULL,PRIMARY KEY(ip,period,starts_at));
 CREATE INDEX registration_counter_recent ON local_registration_ip_counters(updated_at DESC,ip);
 CREATE TABLE local_registration_denials(ip TEXT PRIMARY KEY,count INTEGER NOT NULL CHECK(count>0),last_at INTEGER NOT NULL,period TEXT NOT NULL);
 CREATE INDEX registration_denials_recent ON local_registration_denials(last_at DESC);
 COMMIT;`);
}
function rule(db, ip) {
    const r = db.prepare('SELECT * FROM local_registration_rules WHERE ip=?').get(ip);
    return r ? { ip: String(r.ip), enabled: !!r.enabled, perHour: Number(r.per_hour), perDay: Number(r.per_day), perWeek: Number(r.per_week), perMonth: Number(r.per_month), revision: Number(r.revision), active: Number(r.active), updatedAt: Number(r.updated_at), reason: String(r.reason) } : null;
}
export function registrationWindows(now) {
    const d = new Date(now + offset), y = d.getUTCFullYear(), m = d.getUTCMonth(), date = d.getUTCDate(), today = Date.UTC(y, m, date) - offset, hour = Math.floor(now / 3600000) * 3600000, week = today - ((d.getUTCDay() + 6) % 7) * day;
    return [{ period: 'hour', start: hour, end: hour + 3600000 }, { period: 'day', start: today, end: today + day }, { period: 'week', start: week, end: week + 7 * day }, { period: 'month', start: Date.UTC(y, m, 1) - offset, end: Date.UTC(y, m + 1, 1) - offset }];
}
export class RegistrationRateLimitError extends Error {
    period;
    retryAt;
    limit;
    code = 'REGISTRATION_IP_LIMIT';
    constructor(period, retryAt, limit) {
        super('IP đã đạt giới hạn tạo tài khoản trong ' + ({ hour: 'giờ', day: 'ngày', week: 'tuần', month: 'tháng' }[period]) + ' hiện tại. Vui lòng thử lại sau.');
        this.period = period;
        this.retryAt = retryAt;
        this.limit = limit;
    }
}
export function inspectRegistrationIp(db, ipValue, now = Date.now()) {
    const ip = normalizeRegistrationIp(ipValue), global = rule(db, '*');
    if (!global)
        throw Error('Thiếu cấu hình bảo mật đăng ký.');
    const override = rule(db, ip), effective = override?.active ? override : global, enabled = global.enabled && effective.enabled;
    const counters = registrationWindows(now).map((w, i) => ({ ...w, limit: effective[fields[i]], count: Number(db.prepare('SELECT count FROM local_registration_ip_counters WHERE ip=? AND period=? AND starts_at=?').get(ip, w.period, w.start)?.count ?? 0) }));
    return { ip, source: override?.active ? 'override' : 'default', enabled, rule: effective, counters, blocked: enabled && counters.some(w => w.limit > 0 && w.count >= w.limit) };
}
export function checkRegistrationSlot(db, ip, now) {
    const state = inspectRegistrationIp(db, ip, now);
    if (!state.enabled)
        return;
    const blocked = state.counters.filter(w => w.limit > 0 && w.count >= w.limit).sort((a, b) => b.end - a.end)[0];
    if (blocked)
        throw new RegistrationRateLimitError(blocked.period, blocked.end, blocked.limit);
}
export function consumeRegistrationSlot(db, ipValue, now) {
    if (!db.isTransaction)
        throw Error('Quota đăng ký phải nằm trong transaction tạo tài khoản.');
    const ip = normalizeRegistrationIp(ipValue);
    checkRegistrationSlot(db, ip, now);
    for (const w of registrationWindows(now))
        db.prepare('INSERT INTO local_registration_ip_counters VALUES(?,?,?,?,?) ON CONFLICT(ip,period,starts_at) DO UPDATE SET count=count+1,updated_at=excluded.updated_at').run(ip, w.period, w.start, 1, now);
}
export function recordRegistrationDenial(db, ipValue, error, now = Date.now()) {
    db.prepare('INSERT INTO local_registration_denials VALUES(?,1,?,?) ON CONFLICT(ip) DO UPDATE SET count=count+1,last_at=excluded.last_at,period=excluded.period').run(normalizeRegistrationIp(ipValue), now, error.period);
}
export function saveRegistrationRule(db, admin, input) {
    const ip = input.ip === '*' ? '*' : normalizeRegistrationIp(input.ip);
    if (typeof input.enabled !== 'boolean' || !fields.every(f => Number.isSafeInteger(input[f]) && input[f] >= 0 && input[f] <= 1000000) || !Number.isSafeInteger(input.revision) || input.revision < 0 || typeof input.reason !== 'string' || input.reason.trim().length < 5 || input.reason.length > 300)
        fail('Kiểm tra hạn mức và nhập lý do từ 5–300 ký tự.');
    if (ip === '*' && input.remove)
        fail('Không thể xóa cấu hình mặc định.');
    db.exec('BEGIN IMMEDIATE');
    try {
        const before = rule(db, ip);
        if ((before?.revision ?? 0) !== input.revision)
            fail('Cấu hình vừa thay đổi; tải lại trước khi lưu.', 409);
        db.prepare('INSERT INTO local_registration_rules VALUES(?,?,?,?,?,?,1,?,?,?) ON CONFLICT(ip) DO UPDATE SET enabled=excluded.enabled,per_hour=excluded.per_hour,per_day=excluded.per_day,per_week=excluded.per_week,per_month=excluded.per_month,revision=revision+1,active=excluded.active,updated_at=excluded.updated_at,reason=excluded.reason').run(ip, Number(input.enabled), ...fields.map(f => input[f]), input.remove ? 0 : 1, Date.now(), input.reason.trim());
        const after = rule(db, ip);
        audit(db, admin, input.remove ? 'security.registration_rule_removed' : 'security.registration_rule_saved', null, input.reason.trim(), before, after);
        db.exec('COMMIT');
        return after;
    }
    catch (e) {
        if (db.isTransaction)
            db.exec('ROLLBACK');
        throw e;
    }
}
export function registrationOverview(db, q, now = Date.now()) {
    const global = rule(db, '*');
    if (!global)
        throw Error('Thiếu cấu hình bảo mật.');
    const page = Number(q.page ?? '1');
    if (!Number.isSafeInteger(page) || page < 1 || page > 10000)
        fail('Trang không hợp lệ.');
    const ip = q.ip ? normalizeRegistrationIp(q.ip) : undefined;
    const ips = ip ? [{ ip }] : db.prepare('SELECT ip,MAX(updated_at) latest FROM local_registration_ip_counters GROUP BY ip ORDER BY latest DESC LIMIT 25 OFFSET ?').all((page - 1) * 25);
    const states = ips.map(r => inspectRegistrationIp(db, r.ip, now));
    const overrides = db.prepare("SELECT ip FROM local_registration_rules WHERE ip<>'*' AND active=1 ORDER BY updated_at DESC LIMIT 200").all().map(r => rule(db, String(r.ip)));
    return { ready: true, global, overrides, inspectedOverride: ip ? rule(db, ip) : null, states, page, hasMore: !ip && ips.length === 25, denials: db.prepare('SELECT ip,count,last_at,period FROM local_registration_denials ORDER BY last_at DESC LIMIT 25').all(), now, timezone: 'Asia/Ho_Chi_Minh', notice: 'Tính số tài khoản tạo thành công từ khi bật extension, kể cả lúc tạm tắt chặn. 0 = không giới hạn. Giờ/ngày theo UTC+7; tuần bắt đầu thứ Hai; tháng theo lịch. Các hạn mức áp đồng thời. IP trong LOCAL/ADB có thể chung là 127.0.0.1.' };
}
