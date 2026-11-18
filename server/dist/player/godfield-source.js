import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { calendarParts, calendarZone } from './event-calendar.js';
const root = new URL('../../../', import.meta.url), cache = new Map();
export function godfieldSource() { return JSON.parse(readFileSync(new URL('tools/runtime/than-vuc-source.json', root), 'utf8')); }
export function godfieldConfig(name) {
    if (cache.has(name))
        return cache.get(name);
    const entry = godfieldSource().tables[name] ?? JSON.parse(readFileSync(new URL('tools/runtime/than-vuc-league-source.json', root), 'utf8')).tables[name] ?? JSON.parse(readFileSync(new URL('tools/runtime/than-vuc-zodiac-source.json', root), 'utf8')).tables[name];
    if (entry?.status !== 'SOURCE VERIFIED')
        throw Error('Thiếu nguồn Thần Vực: ' + name);
    const sha = (b) => createHash('sha256').update(b).digest('hex'), raw = readFileSync(new URL(entry.path, root)), parsed = readFileSync(new URL(entry.parsedPath, root));
    if (sha(raw) !== entry.sha256 || sha(parsed) !== entry.parsedSha256)
        throw Error('Nguồn Thần Vực thay đổi: ' + name);
    const d = JSON.parse(parsed.toString());
    cache.set(name, d);
    return d;
}
const stamp = (s) => Date.parse(s.replaceAll('/', '-').replace(' ', 'T') + '+07:00');
export function godfieldSchedules(now = Date.now()) {
    const p = calendarParts(now), clock = new Date(now + 7 * 3600000).toISOString().slice(11, 19), windows = (name, start, end) => Object.entries(godfieldConfig(name)).flatMap(([id, r]) => { const a = stamp(r[start]), b = stamp(r[end]); return Number.isFinite(a) && Number.isFinite(b) && a <= b ? [{ id, start: r[start], end: r[end], active: now >= a && now <= b }] : []; });
    const highway = Object.values(godfieldConfig('highway_time')), towerStart = highway.map(r => r.ready_time).sort()[0], towerEnd = highway.map(r => r.end_time).sort().at(-1);
    const zodiac = godfieldConfig('constellation_detail')['1'];
    return { timezone: calendarZone, timezoneEvidence: 'Múi giờ cấu hình LOCAL hiện có; nguồn client không ghi UTC offset server gốc.', at: now, day: p.date, modes: [
            { id: 'god_field', name: 'Đấu Tranh Bá', source: 'god_field_time', schedule: godfieldConfig('god_field_time'), status: 'IMPLEMENTED_WEEKDAY_LOCAL', blocker: 'Tích điểm ba trận thật; chia nhóm và combat_int dùng adapter LOCAL đã duyệt. Vòng loại/giải tự động cuối tuần chưa mở.' },
            { id: 'universe_arena', name: 'Thần Điện', source: 'game_godfield_mainBig btn103 → universe_arena.index', windows: windows('universe_arena', 'start_time', 'end_time'), status: 'IMPLEMENTED_FORMATION_SHOP_LOCAL', blocker: 'Đội riêng/khóa tướng/1600điểm ban đầu/cửa hàng/mốc thưởng đã nối; trận xếp hạng thiếu công thức điểm và khoảng ghép chính xác, chưa phát thưởng mùa.' },
            { id: 'highway', name: 'Tháp Hoang Tinh Tế', source: 'highway_time', start: towerStart, end: towerEnd, withinWindow: clock >= towerStart && clock <= towerEnd, status: 'IMPLEMENTED_ECONOMY_LOCAL', blocker: 'Danh sách chuyển đổi LOCAL được duyệt; cửa hàng1/3 nguồn đã nối. Đua/đặt cược/cửa hàng2/reset chưa đủ quy tắc, giữ khóa.' },
            { id: 'cosmic_war', name: 'Chiến Trường Thứ Nguyên', source: 'cosmic_war', windows: windows('cosmic_war', 'register_start_time', 'active_end_time'), status: 'IMPLEMENTATION_PENDING' },
            { id: 'guild_high_war', name: 'Chiến Trường Aether', source: 'guild_high_war_base', windows: windows('guild_high_war_base', 'start_time', 'end_time'), status: 'IMPLEMENTATION_PENDING' },
            { id: 'zodiac', name: 'Thần Vực 12 Cung', source: 'constellation_detail', start: zodiac.active_start, end: zodiac.active_end, withinWindow: clock >= zodiac.active_start + ':00' && clock < zodiac.active_end + ':00', palaces: Object.keys(godfieldConfig('constellation_detail')).length, status: 'IMPLEMENTATION_PENDING' }
        ] };
}
