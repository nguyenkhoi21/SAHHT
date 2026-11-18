import { readFileSync } from 'node:fs';
import { godfieldConfig } from './godfield-source.js';
export const aetherSource = () => JSON.parse(readFileSync(new URL('../../../tools/runtime/aether-source.json', import.meta.url), 'utf8'));
export function aetherConfig(short) {
    const name = 'guild_high_war_' + short, entry = aetherSource().tables[name];
    if (!entry)
        throw Error('Thiếu nguồn Aether: ' + short);
    return godfieldConfig(name);
}
export const aetherStamp = (text) => Date.parse(text.replaceAll('/', '-').replace(' ', 'T') + '+07:00');
export function aetherEvent(db, now, realm = 'local-1') {
    const qa = db.prepare('SELECT * FROM aether_events WHERE realm_id=? AND qa=1 AND qa_active=1 ORDER BY rowid DESC LIMIT 1').get(realm);
    if (qa)
        return qa;
    const managed = db.prepare('SELECT * FROM aether_events WHERE realm_id=? AND managed=1 ORDER BY start_at DESC').all(realm);
    if (managed.length)
        return managed.find(e => now >= e.start_at && now <= e.end_at) ?? managed.filter(e => e.start_at > now).at(-1) ?? managed[0];
    const rows = Object.entries(aetherConfig('base')).map(([v, r]) => ({ id: realm + '-' + v, realm_id: realm, version: Number(v), start_at: aetherStamp(r.start_time), end_at: aetherStamp(r.end_time), qa: 0, managed: 0 }));
    const current = rows.find(e => now >= e.start_at && now <= e.end_at);
    if (!current)
        throw Object.assign(Error('Không có mùa Aether đang hiệu lực hoặc được đặt lịch.'), { statusCode: 422 });
    return current;
}
export function aetherPhase(start, end, now) {
    const midnight = Math.floor((start + 7 * 3600000) / 86400000) * 86400000 - 7 * 3600000, day = Math.floor((now - midnight) / 86400000) + 1;
    const ranges = Object.values(aetherConfig('open')).flatMap((r) => r.show_day.map((d) => {
        const [a, b] = r.timing.split('-').map((s) => s.split(':').reduce((n, v) => n * 60 + Number(v), 0));
        return { step: r.sort, label: r.open_des, start: Math.max(start, midnight + (d - 1) * 86400000 + a * 1000), end: Math.min(end + 1, midnight + (d - 1) * 86400000 + (b + 1) * 1000) };
    })).filter((r) => r.end > r.start).sort((a, b) => a.start - b.start);
    const current = ranges.find((r) => now >= r.start && now < r.end);
    return { step: current?.step ?? 0, label: current?.label ?? (now < start ? 'Chưa mở' : now > end ? 'Đã kết thúc' : 'Ngoài pha cấu hình nguồn'), day, next: current?.end ?? ranges.find((r) => r.start > now)?.start ?? Math.max(end + 1, now + 60000), ended: now > end, timezone: 'Asia/Ho_Chi_Minh', timezoneEvidence: 'Dùng cấu hình giờ Việt Nam hiện có; Lua không ghi UTC offset server gốc.' };
}
