import { mainEventIcons } from './main-event-icons.js';
import { audit } from '../admin/admin.audit.js';
import { readConfigSync } from './local-content.js';
import { eventSource, skyPresets, skyRows } from './event-source.js';
export const eventZone = 'Asia/Ho_Chi_Minh';
const dayMs = 86400000, offset = 7 * 3600000;
export const eventDay = (now) => new Date(now + offset).toISOString().slice(0, 10);
export function dayStamp(date) { const n = Date.parse(date + 'T00:00:00+07:00'); if (!/^\d{4}-\d{2}-\d{2}$/.test(date) || !Number.isFinite(n) || eventDay(n) !== date)
    eventFail('Ngày lịch không tồn tại.'); return n; }
export function eventFail(message) { throw Object.assign(Error(message), { statusCode: 422 }); }
export class EventPlanner {
    db;
    now;
    server;
    loaded;
    constructor(db, now = Date.now, server = Number(process.env.GAME_SERVER_NUMBER ?? 1)) {
        this.db = db;
        this.now = now;
        this.server = server;
        if (!Number.isSafeInteger(server) || server < 1)
            throw Error('GAME_SERVER_NUMBER không hợp lệ.');
    }
    settings() { const r = this.db.prepare('SELECT opened_at FROM event_calendar_settings WHERE id=1').get(); return { openedAt: r ? Number(r.opened_at) : null, serverNumber: this.server, realm: 'local-1', timezone: eventZone }; }
    catalog() {
        return [
            ...mainEventIcons.map(icon => {
                const [kind, id] = icon.target.split('.'), row = kind === 'main' ? eventSource('active_inreview')[id] : kind === 'server' ? eventSource('server_inreview')[id] : null;
                return { ...icon, level: row?.show_lv ?? 0, vip: row?.VIP_limit ?? 0, ready: ['main.506', 'server.905', 'main.509', 'main.540', 'main.521', 'main.524', 'main.561'].includes(icon.target), schedulable: true, source: kind === 'main' ? 'active_inreview' : kind === 'server' ? 'server_inreview' : 'Main button tag' };
            }),
            // Giữ cả nháp cũ chưa có callsite icon, không làm mất cấu hình đã lưu.
            ...['main', 'server'].flatMap(kind => Object.entries(eventSource(kind === 'main' ? 'active_inreview' : 'server_inreview')).filter(([id]) => !mainEventIcons.some(c => c.target === kind + '.' + id)).map(([id, r]) => ({ target: kind + '.' + id, name: 'Sự kiện ' + kind + ' #' + id, level: r.show_lv ?? 0, vip: r.VIP_limit ?? 0, ready: false, schedulable: false, icons: [], source: kind === 'main' ? 'active_inreview' : 'server_inreview' }))),
            ...Object.entries(readConfigSync('active_chapter')).map(([id, r]) => ({ target: 'chapter.' + id, name: r.name ?? r.title ?? 'Hoạt động #' + id, level: r.level?.[0] ?? 1, vip: 0, ready: false, schedulable: false, icons: [], source: 'active_chapter' }))
        ];
    }
    // Allowlist hiển thị, không tự cấp quyền giao dịch hay thay dữ liệu người chơi.
    visibility(level, vip, at = this.now()) {
        const entries = {};
        for (const c of this.catalog().filter(c => c.schedulable && level >= c.level && vip >= c.vip)) {
            const o = this.selection(c.target, at).occurrence;
            if (o)
                entries[c.target] = { starts: Math.floor(o.starts / 1000), ends: Math.floor(o.ends / 1000), name: c.name };
        }
        return { schema: 1, policy: 'PUBLISHED_ONLY', generated_at: Math.floor(at / 1000), entries };
    }
    rules(includeDeleted = false) {
        const rows = this.loaded ??= this.db.prepare('SELECT * FROM event_calendar_rules ORDER BY id DESC').all().map(r => { const definition = JSON.parse(String(r.definition)); return { ...r, definition, deletedAt: definition._deletedAt ?? null }; });
        return includeDeleted ? rows : rows.filter(r => r.deletedAt === null);
    }
    window(rule, date, openedAt) {
        const d = rule.definition, stamp = dayStamp(date);
        if (this.server < d.serverFrom || this.server > d.serverTo)
            return null;
        let matches = false;
        if (d.kind === 'opening' && openedAt !== null) {
            const day = 1 + Math.floor((stamp - dayStamp(eventDay(openedAt))) / dayMs);
            matches = d.days.includes(day);
        }
        if (d.kind === 'weekly') {
            const weekday = new Date(stamp + offset).getUTCDay() || 7;
            matches = d.weekdays.includes(weekday) && date >= d.fromDate && (!d.toDate || date <= d.toDate);
        }
        if (d.kind === 'special')
            matches = d.dates.includes(date);
        if (!matches)
            return null;
        let starts = Math.max(stamp + d.startMinute * 60000, d.kind === 'opening' ? openedAt : stamp), ends = stamp + d.endMinute * 60000;
        // Ngày mở server liền nhau 00–24h là một cửa sổ liên tục: countdown
        // phải tới hết cả đợt, không báo kết thúc giả ở nửa đêm đầu tiên.
        if (d.kind === 'opening' && d.startMinute === 0 && d.endMinute === 1440) {
            const base = dayStamp(eventDay(openedAt)), current = 1 + Math.floor((stamp - base) / dayMs);
            let a = current, b = current;
            while (d.days.includes(a - 1))
                a--;
            while (d.days.includes(b + 1))
                b++;
            starts = Math.max(base + (a - 1) * dayMs, openedAt);
            ends = base + b * dayMs;
        }
        if (ends <= starts)
            return null;
        return { id: d.kind === 'opening' ? `calendar:${rule.id}:opening:${eventDay(openedAt)}` : `calendar:${rule.id}:${date}`, ruleId: Number(rule.id), target: d.target, name: rule.name, starts, ends, version: d.version, kind: d.kind };
    }
    selection(target, at = this.now()) {
        const managed = this.rules().filter(r => r.target === target && r.status !== 'draft');
        const opened = this.settings().openedAt;
        const current = managed.filter(r => r.status === 'published').map(r => this.window(r, eventDay(at), opened)).filter((o) => !!o && at >= o.starts && at < o.ends);
        // Cùng một event trùng giờ chỉ chọn một lượt: đặc biệt > mở server > tuần.
        const priority = { special: 3, opening: 2, weekly: 1 };
        current.sort((a, b) => priority[b.kind] - priority[a.kind] || Number(a.ruleId) - Number(b.ruleId));
        return { managed: managed.length > 0, occurrence: current[0] ?? null, overlaps: current.slice(1) };
    }
    resolveSky(target, at = this.now()) {
        return this.selection(target, at).occurrence;
    }
    validate(raw) {
        if (!raw || typeof raw.name !== 'string' || raw.name.trim().length < 1 || raw.name.length > 80 || !['opening', 'weekly', 'special'].includes(raw.kind))
            eventFail('Cần tên sự kiện và nhóm lịch hợp lệ.');
        if (!this.catalog().some(c => c.target === raw.target))
            eventFail('Sự kiện không có trong catalog nguồn.');
        if (!Number.isSafeInteger(raw.startMinute) || !Number.isSafeInteger(raw.endMinute) || raw.startMinute < 0 || raw.startMinute >= 1440 || raw.endMinute <= raw.startMinute || raw.endMinute > 1440)
            eventFail('Khung giờ phải trong ngày, giờ kết thúc lớn hơn giờ bắt đầu.');
        if (!Number.isSafeInteger(raw.serverFrom) || !Number.isSafeInteger(raw.serverTo) || raw.serverFrom < 1 || raw.serverTo < raw.serverFrom || raw.serverTo > 1000000)
            eventFail('Khoảng server không hợp lệ.');
        const ints = (value, max) => { if (!Array.isArray(value) || !value.length || value.length > max || value.some(v => !Number.isSafeInteger(v) || v < 1 || v > max) || new Set(value).size !== value.length)
            eventFail('Chọn ngày không trùng trong phạm vi1–' + max + '.'); return [...value].sort((a, b) => a - b); };
        const d = { name: raw.name.trim(), target: raw.target, kind: raw.kind, startMinute: raw.startMinute, endMinute: raw.endMinute, serverFrom: raw.serverFrom, serverTo: raw.serverTo, version: 0 };
        if (d.kind === 'opening')
            d.days = ints(raw.days, 7);
        if (d.kind === 'weekly') {
            d.weekdays = ints(raw.weekdays, 7);
            dayStamp(raw.fromDate);
            if (raw.toDate) {
                dayStamp(raw.toDate);
                if (raw.toDate < raw.fromDate)
                    eventFail('Ngày kết thúc trước ngày bắt đầu.');
            }
            d.fromDate = raw.fromDate;
            d.toDate = raw.toDate || null;
        }
        if (d.kind === 'special') {
            if (!Array.isArray(raw.dates) || !raw.dates.length || raw.dates.length > 366 || new Set(raw.dates).size !== raw.dates.length)
                eventFail('Chọn1–366ngày đặc biệt không trùng.');
            raw.dates.forEach(dayStamp);
            d.dates = [...raw.dates].sort();
        }
        if (raw.contentId != null) {
            const kinds = { 'main.509': 'treasure', 'main.540': 'labyrinth', 'main.521': 'pantheon', 'main.524': 'investment', 'main.561': 'dispatch' }, kind = kinds[d.target], profile = this.db.prepare('SELECT kind,status FROM ' + (['main.524', 'main.561'].includes(d.target) ? 'restored_event_configs' : 'treasure_event_configs') + ' WHERE id=?').get(Number(raw.contentId));
            if (!kind || !Number.isSafeInteger(raw.contentId) || !profile || profile.status !== 'published' || profile.kind !== kind)
                eventFail('Chọn cấu hình quà đã công bố đúng sự kiện.');
            d.contentId = raw.contentId;
        }
        if (['main.506', 'server.905'].includes(d.target)) {
            d.version = d.target === 'server.905' ? 0 : raw.version;
            skyRows(d.target, d.version);
        }
        return d;
    }
    save(admin, b) {
        const d = this.validate(b.definition);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            let id = b.id, revision = 1;
            if (id) {
                const old = this.db.prepare('SELECT * FROM event_calendar_rules WHERE id=?').get(id);
                if (!old || old.status !== 'draft' || JSON.parse(String(old.definition))._deletedAt != null || old.revision !== b.revision)
                    eventFail('Nháp đã thay đổi, đã xóa hoặc đã công bố; tải lại.');
                revision = Number(old.revision) + 1;
                this.db.prepare('UPDATE event_calendar_rules SET name=?,target=?,definition=?,revision=? WHERE id=?').run(d.name, d.target, JSON.stringify(d), revision, id);
            }
            else
                id = Number(this.db.prepare("INSERT INTO event_calendar_rules(name,target,definition,status,created_at) VALUES(?,?,?,'draft',?)").run(d.name, d.target, JSON.stringify(d), this.now()).lastInsertRowid);
            audit(this.db, admin, 'calendar.plan.save', null, 'Lưu nháp lịch sự kiện', null, { id, revision, definition: d });
            this.db.exec('COMMIT');
            this.loaded = undefined;
            return { id, revision };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    action(admin, b) {
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const r = this.db.prepare('SELECT * FROM event_calendar_rules WHERE id=?').get(b.id);
            if (!r || r.revision !== b.revision)
                eventFail('Phiên bản lịch không còn khớp; tải lại danh sách.');
            if (!['publish', 'disable', 'delete', 'restore'].includes(b.action))
                eventFail('Thao tác lịch không hợp lệ.');
            const definition = JSON.parse(String(r.definition)), deleted = definition._deletedAt != null, at = this.now();
            let status = 'disabled', publishedAt = r.published_at;
            if (b.action === 'delete') {
                if (deleted) {
                    this.db.exec('COMMIT');
                    return { ok: true, replayed: true };
                }
                // Tombstone trong JSON hiện có: không xóa ID/định nghĩa/receipt, không migration.
                definition._deletedAt = at;
            }
            else if (b.action === 'restore') {
                if (!deleted)
                    eventFail('Lịch này chưa bị xóa.');
                delete definition._deletedAt;
                // Khôi phục ở trạng thái tắt, không tự bật lại sự kiện hoặc reset lượt.
            }
            else {
                if (deleted)
                    eventFail('Lịch đã xóa; khôi phục trước khi thao tác.');
                status = b.action === 'publish' ? 'published' : 'disabled';
                if (r.status === status) {
                    this.db.exec('COMMIT');
                    return { ok: true, replayed: true };
                }
                if (b.action === 'publish') {
                    if (r.status !== 'draft')
                        eventFail('Lịch đã tắt không được công bố lại; giữ lịch sử, hãy nhân bản lịch mới.');
                    const d = this.validate(definition);
                    if (!this.catalog().find(c => c.target === d.target)?.schedulable)
                        eventFail('Module chưa có ánh xạ icon Main; chỉ lưu nháp.');
                    if (d.kind === 'opening' && this.settings().openedAt === null)
                        eventFail('Cần đặt thời điểm mở server trước.');
                    publishedAt ??= at;
                }
            }
            this.db.prepare('UPDATE event_calendar_rules SET status=?,definition=?,revision=revision+1,published_at=? WHERE id=?').run(status, JSON.stringify(definition), publishedAt, b.id);
            const summary = b.action === 'delete' ? 'Xóa lịch khỏi danh sách; giữ lịch sử/lượt/quà' : b.action === 'restore' ? 'Khôi phục lịch ở trạng thái tắt' : 'Đổi trạng thái lịch; giữ tiến độ/lượt cũ';
            audit(this.db, admin, 'calendar.plan.' + b.action, null, summary + ' · #' + b.id + ' ' + r.name, r, { id: b.id, status, deletedAt: definition._deletedAt ?? null });
            this.db.exec('COMMIT');
            this.loaded = undefined;
            return { ok: true };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    setOpening(admin, b) {
        const at = Date.parse(b.openedAt);
        if (!Number.isSafeInteger(at))
            eventFail('Thời điểm mở server không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const before = this.settings();
            if (before.openedAt !== null && before.openedAt !== at && this.db.prepare("SELECT 1 FROM event_calendar_rules WHERE published_at IS NOT NULL AND json_extract(definition,'$.kind')='opening'").get())
                eventFail('Đã công bố lịch mở server; không đổi mốc làm lệch lượt/ngày.');
            this.db.prepare('INSERT INTO event_calendar_settings VALUES(1,?,?) ON CONFLICT(id) DO UPDATE SET opened_at=excluded.opened_at,updated_at=excluded.updated_at').run(at, this.now());
            audit(this.db, admin, 'calendar.opening', null, 'Đặt thời điểm mở server LOCAL', before, { openedAt: at });
            this.db.exec('COMMIT');
            return this.settings();
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    info(month) {
        if (!/^\d{4}-\d{2}$/.test(month))
            eventFail('Tháng cần YYYY-MM.');
        const first = dayStamp(month + '-01'), days = new Date(first + offset);
        days.setUTCMonth(days.getUTCMonth() + 1);
        const end = days.getTime() - offset, opened = this.settings().openedAt, rules = this.rules();
        return { settings: this.settings(), visibility: this.visibility(1000000, 1000000), catalog: this.catalog(), presets: skyPresets(), contentProfiles: [...this.db.prepare("SELECT id,kind,name FROM treasure_event_configs WHERE status='published' ORDER BY id DESC").all(), ...this.db.prepare("SELECT id,kind,name FROM restored_event_configs WHERE status='published' ORDER BY id DESC").all()], rules, deletedRules: this.rules(true).filter(r => r.deletedAt !== null), month, days: Array.from({ length: Math.round((end - first) / dayMs) }, (_, i) => { const date = eventDay(first + i * dayMs); return { date, events: rules.filter(r => r.status !== 'disabled').flatMap(r => { const occurrence = this.window(r, date, opened); return occurrence ? [{ ...occurrence, status: r.status }] : []; }) }; }), policy: 'Lịch GM LOCAL rõ ràng, không suy từ lịch lịch sử. Lịch đặc biệt có thể bổ sung sự kiện; trùng cùng sự kiện/giờ chọn đặc biệt > mở server > tuần. Mỗi đợt/ngày có mã riêng, mở lại không reset lượt. Icon Main chỉ hiện khi có lịch đã công bố, đúng giờ/server/cấp/VIP; ngoài lịch hoặc chưa cấu hình đều ẩn. Lịch hiển thị không tự phục hồi gameplay hay sinh thưởng/trận. Các chức năng thường trực và lịch chương hoạt động giữ nguyên.' };
    }
}
