import { EventPlanner } from './event-planner.js';
import { readConfigSync } from './local-content.js';
import { audit } from '../admin/admin.audit.js';
import { economyFail, economyConfig } from './progression-economy.js';
export const calendarZone = 'Asia/Ho_Chi_Minh';
export function calendarParts(now) { const d = new Date(now + 7 * 3600000); return { date: d.toISOString().slice(0, 10), hour: d.getUTCHours() + d.getUTCMinutes() / 60, weekday: d.getUTCDay() || 7, day: d.getUTCDate(), nextDay: Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate() + 1) - 7 * 3600000 }; }
// active_chapter: 1 = giờ/ngày, 2 = thứ (T2=1, CN=7), 0 = ngày/tháng.
// Kiểu4 chứa khoảng năm đảo chiều ở nguồn: giữ khóa, không suy lịch giả.
export function sourceSchedule(row, now) { const d = calendarParts(now), value = row.time_sort === 1 ? d.hour : row.time_sort === 2 ? d.weekday : row.time_sort === 0 ? d.day : null; return value !== null && Array.isArray(row.open) && row.open.some(([a, b]) => a <= b && value >= a && (row.time_sort === 1 ? value < b : value <= b)); }
// active_inreview.name chứa danh sách khoảng ngày thật, không phải lịch lặp vô hạn.
export function datedWindows(value) { return value.split(',').flatMap(part => { const m = part.trim().match(/^(\d{4}\/\d{2}\/\d{2})\s+(\d{2}:\d{2}:\d{2})\s*-\s*(\d{4}\/\d{2}\/\d{2})\s+(\d{2}:\d{2}:\d{2})$/); if (!m)
    return []; const start = Date.parse(m[1].replaceAll('/', '-') + 'T' + m[2] + '+07:00'), end = Date.parse(m[3].replaceAll('/', '-') + 'T' + m[4] + '+07:00'); return Number.isFinite(start) && Number.isFinite(end) && end >= start ? [{ start, end }] : []; }); }
export class EventCalendarService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    override(key, now = this.now()) { const r = this.db.prepare('SELECT * FROM local_activity_settings WHERE activity_id=?').get('phase24:' + key); return r && Number(r.starts_at) <= now && now < Number(r.ends_at) ? Number(r.enabled) === 1 : null; }
    mainEvents(level, vip, now = this.now()) { const planner = new EventPlanner(this.db, () => now); return Object.entries(economyConfig('active_inreview')).map(([id, row]) => { const windows = datedWindows(row.name ?? ''), current = windows.find(w => w.start <= now && now <= w.end), qaOverride = this.override('main.' + id, now), eligible = level >= row.show_lv && vip >= row.VIP_limit, originalActive = !!current, planned = planner.selection('main.' + id, now), active = eligible && !!planned.occurrence; return { id, source: 'VN runtime active_inreview', sourceSchedule: row.name, requiredLevel: row.show_lv, requiredVip: row.VIP_limit, eligible, originalActive, qaOverride, active, managed: planned.managed, endsAt: planned.occurrence?.ends ?? current?.end ?? null, nextStart: windows.find(w => w.start > now)?.start ?? null, blockedReason: !eligible ? 'Chưa đủ cấp/VIP.' : !active ? 'Ngoài lịch đang áp dụng.' : null }; }).sort((a, b) => Number(a.id) - Number(b.id)); }
    mainSwitch(level, vip) { return Object.fromEntries(this.mainEvents(level, vip).filter(r => r.active).map(r => [r.id, r.requiredLevel])); }
    setOverride(adminId, key, enabled, starts, ends) { if (!/^chapter\.\d+$|^exchange\.\d+$|^main\.\d+$|^hot_exchange$/.test(key))
        economyFail('Mã lịch QA không hợp lệ.'); if (key.startsWith('chapter.') && !readConfigSync('active_chapter')[key.split('.')[1]])
        economyFail('Chương sự kiện không tồn tại.'); if (key.startsWith("main.") && !economyConfig("active_inreview")[key.split(".")[1]])
        economyFail("Sự kiện Main không tồn tại."); if (key.startsWith("exchange.") && !Object.values(economyConfig("normal_exchange")).some(r => String(r.show_id) === key.split(".")[1]))
        economyFail("Công thức đổi không tồn tại."); if (enabled !== null && (!Number.isSafeInteger(starts) || !Number.isSafeInteger(ends) || ends <= starts || ends - starts > 7 * 86400000))
        economyFail('Lịch QA tối đa7 ngày.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const before = this.db.prepare('SELECT * FROM local_activity_settings WHERE activity_id=?').get('phase24:' + key);
        if (enabled === null)
            this.db.prepare('DELETE FROM local_activity_settings WHERE activity_id=?').run('phase24:' + key);
        else
            this.db.prepare('INSERT INTO local_activity_settings(activity_id,enabled,starts_at,ends_at) VALUES(?,?,?,?) ON CONFLICT(activity_id) DO UPDATE SET enabled=excluded.enabled,starts_at=excluded.starts_at,ends_at=excluded.ends_at').run('phase24:' + key, enabled ? 1 : 0, starts, ends);
        audit(this.db, adminId, 'calendar.qa_override', null, 'Lịch QA riêng, có hạn và có thể khôi phục', before, { key, enabled, starts, ends });
        this.db.exec('COMMIT');
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    chapters(level, now = this.now()) { const planner = new EventPlanner(this.db, () => now); return Object.entries(readConfigSync('active_chapter')).map(([id, c]) => { const original = sourceSchedule(c, now), override = this.override('chapter.' + id, now), eligible = level >= c.level[0] && level <= c.level[1], planned = planner.selection('chapter.' + id, now); return { id, ...c, source: 'VN active_chapter', timezone: calendarZone, originalActive: original, qaOverride: override, eligible, active: eligible && (planned.managed ? !!planned.occurrence : (override ?? original)), managed: planned.managed, blockedReason: c.time_sort === 4 ? 'Lịch nguồn không hợp lệ, chưa mở.' : !eligible ? 'Chưa đủ cấp.' : !(override ?? original) ? 'Ngoài lịch nguồn.' : null }; }).sort((a, b) => Number(a.id) - Number(b.id)); }
    preview(level, now = this.now(), vip = 0) { return { timezone: calendarZone, at: now, day: calendarParts(now).date, chapters: this.chapters(level, now), mainEvents: this.mainEvents(level, vip, now), hotSource: readConfigSync('active_show'), overrides: this.db.prepare("SELECT * FROM local_activity_settings WHERE activity_id LIKE 'phase24:%'").all(), notice: 'Main lấy khoảng ngày cụ thể từ VN runtime active_inreview; chương theo active_chapter. Không tự lặp lại sự kiện đã hết ngày, không suy lịch vô hạn từ tên thứ.' }; }
}
