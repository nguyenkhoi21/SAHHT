import { databaseSchemaVersion } from '../db/database.js';
import { AetherEconomy, aetherItems } from '../player/aether-economy.js';
import { issueAetherMail } from '../player/aether-mail.js';
import { simEnabled, simPolicy, simGet, simPut } from '../player/aether-sim-policy.js';
import { aetherSettlementPreview } from '../player/aether-settlement.js';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync, realpathSync, existsSync } from 'node:fs';
import { resolve, relative, isAbsolute } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash, randomUUID } from 'node:crypto';
import { AetherService, aetherMissing } from '../player/aether.service.js';
import { aetherConfig, aetherPhase, aetherStamp } from '../player/aether-source.js';
import { audit, adminError } from './admin.audit.js';
const root = fileURLToPath(new URL('../../../', import.meta.url));
// Registry ở máy LOCAL, không nhận đường dẫn DB/URL từ request hoặc frontend.
export function localRealmRegistry() {
    const path = resolve(root, 'work/realms/registry.json');
    if (!existsSync(path))
        return [];
    const entries = JSON.parse(readFileSync(path, 'utf8'));
    if (!Array.isArray(entries) || entries.length > 20)
        throw Error('Registry realm LOCAL không hợp lệ.');
    return entries.map((r) => {
        if (!/^[a-z0-9-]{1,40}$/.test(r.id) || typeof r.name !== 'string' || r.name.length > 80 || typeof r.path !== 'string')
            throw Error('Realm không hợp lệ.');
        const real = realpathSync(resolve(root, 'work/realms', r.path)), part = relative(realpathSync(resolve(root, 'work/realms')), real);
        if (isAbsolute(part) || part.startsWith('..') || !real.endsWith('.sqlite'))
            throw Error('Chỉ chấp nhận fixture .sqlite trong work/realms.');
        return { id: r.id, name: r.name, path: real };
    });
}
export class AllianceCenter {
    db;
    sources;
    now;
    constructor(db, sources = localRealmRegistry(), now = () => Date.now()) {
        this.db = db;
        this.sources = sources;
        this.now = now;
        if (new Set(['local-1', ...sources.map(r => r.id)]).size !== sources.length + 1)
            throw Error('Trùng định danh realm.');
    }
    realms() { return [{ id: 'local-1', name: 'Phòng thử nghiệm cục bộ', readOnly: false }, ...this.sources.map(({ id, name }) => ({ id, name, readOnly: true }))]; }
    scoped(id, run) {
        if (id === 'local-1')
            return run(this.db);
        const realm = this.sources.find(r => r.id === id);
        if (!realm)
            adminError('Realm chưa đăng ký LOCAL.', 404);
        const db = new DatabaseSync(realm.path, { readOnly: true });
        try {
            db.exec('PRAGMA query_only=ON;PRAGMA busy_timeout=3000;');
            if (Number(db.prepare('PRAGMA user_version').get().user_version) !== 30 && Number(db.prepare('PRAGMA user_version').get().user_version) !== 31 && Number(db.prepare('PRAGMA user_version').get().user_version) !== databaseSchemaVersion)
                adminError('Realm chưa đúng schema đã kiểm; không chạy migration qua aggregator.', 409);
            return run(db);
        }
        finally {
            db.close();
        }
    }
    directory(query) {
        const realm = String(query.realm ?? 'local-1'), page = Number(query.page ?? 1), size = 20, q = String(query.q ?? '').trim(), leader = String(query.leader ?? '').trim(), participation = String(query.participation ?? 'all'), version = Number(query.version ?? 0), level = Number(query.level ?? 0), minMembers = Number(query.minMembers ?? 0), sort = String(query.sort ?? 'id');
        if (!Number.isInteger(page) || page < 1 || page > 10000 || q.length > 80 || leader.length > 80 || !['all', 'registered', 'unregistered'].includes(participation) || !Number.isSafeInteger(version) || version < 0 || !Number.isInteger(level) || level < 0 || !Number.isInteger(minMembers) || minMembers < 0)
            adminError('Bộ lọc Liên Minh không hợp lệ.');
        const order = { id: 'a.id DESC', name: 'a.name COLLATE NOCASE,a.id', level: 'a.level DESC,a.id', members: 'members DESC,a.id' }[sort];
        if (!order)
            adminError('Kiểu sắp xếp không hợp lệ.');
        const ids = realm === 'all' ? this.realms().map(r => r.id) : [realm], part = ids.map(id => this.scoped(id, db => {
            const escaped = (s) => '%' + s.replace(/[\\%_]/g, '\\$&') + '%', term = escaped(q), leaderTerm = escaped(leader), enrolled = `EXISTS(SELECT 1 FROM aether_guilds ag JOIN aether_events ae ON ae.id=ag.event_id WHERE ag.guild_id=a.id AND (?=0 OR ae.version=?) AND (ae.qa=0 OR ae.qa_active=1))`;
            const filter = `a.closed_at IS NULL AND a.level>=? AND (a.name LIKE ? ESCAPE '\\' OR CAST(a.id AS TEXT)=? OR u.username LIKE ? ESCAPE '\\') AND (SELECT count(*) FROM alliance_members mm WHERE mm.alliance_id=a.id)>=? AND (?='' OR CAST(m.user_id AS TEXT)=? OR u.username LIKE ? ESCAPE '\\' OR EXISTS(SELECT 1 FROM player_profiles pp LEFT JOIN player_state ps ON ps.user_id=pp.user_id WHERE pp.user_id=m.user_id AND (pp.game_uid=? OR json_extract(ps.profile,'$.show_name') LIKE ? ESCAPE '\\'))) AND (?='all' OR (?='registered' AND ${enrolled}) OR (?='unregistered' AND NOT ${enrolled}))`, params = [level, term, q, term, minMembers, leader, leader, leaderTerm, leader, leaderTerm, participation, participation, version, version, participation, version, version];
            const from = " FROM alliances a LEFT JOIN alliance_members m ON m.alliance_id=a.id AND m.role='owner' LEFT JOIN users u ON u.id=m.user_id";
            const total = Number(db.prepare('SELECT count(*) n' + from + ' WHERE ' + filter).get(...params).n);
            const items = db.prepare(`SELECT a.id,a.name,a.level,a.shop_level,a.goods,a.war_flag,a.created_at,m.user_id leaderId,u.username leader,(SELECT count(*) FROM alliance_members mm WHERE mm.alliance_id=a.id) members,(SELECT count(*) FROM alliance_applications x WHERE x.alliance_id=a.id) applications` + from + ' WHERE ' + filter + ' ORDER BY ' + order + ' LIMIT ? OFFSET ?').all(...params, size, (page - 1) * size).map(r => ({ ...r, realm: id, key: id + ':' + r.id, aether: db.prepare('SELECT g.event_id,g.group_id,g.science_level,g.science_exp,e.version FROM aether_guilds g JOIN aether_events e ON e.id=g.event_id WHERE g.guild_id=? AND (?=0 OR e.version=?) AND (e.qa=0 OR e.qa_active=1) ORDER BY e.start_at DESC,e.rowid DESC LIMIT 1').get(r.id, version, version) ?? null, lastActivity: db.prepare("SELECT max(created_at) at FROM admin_audit WHERE target_user_id IN(SELECT user_id FROM alliance_members WHERE alliance_id=?) AND (action LIKE 'association.%' OR action LIKE 'aether.%')").get(r.id)?.at ?? null }));
            return { realm: id, total, items };
        }));
        // Mỗi realm có trang riêng: không giả xếp hạng toàn cầu từ các trang con.
        return { realms: this.realms(), page, size, groups: part, total: part.reduce((n, r) => n + r.total, 0), pagination: 'Theo từng realm, không trộn thứ tự giữa DB.', sourceLimits: aetherMissing() };
    }
    detail(realm, gid) {
        if (!Number.isSafeInteger(gid) || gid < 1)
            adminError('ID Liên Minh không hợp lệ.');
        return this.scoped(realm, db => {
            const guild = db.prepare('SELECT id,name,level,notice,goods,war_flag,shop_level,created_at FROM alliances WHERE id=? AND closed_at IS NULL').get(gid);
            if (!guild)
                adminError('Không có Liên Minh tại realm này.', 404);
            const members = db.prepare("SELECT m.user_id,m.role,m.dedication,m.joined_at,u.username,p.game_uid,json_extract(s.profile,'$.show_name') name,json_extract(s.profile,'$.level') level FROM alliance_members m JOIN users u ON u.id=m.user_id JOIN player_profiles p ON p.user_id=m.user_id JOIN player_state s ON s.user_id=m.user_id WHERE m.alliance_id=? ORDER BY m.role,m.user_id").all(gid);
            return { realm, key: realm + ':' + gid, guild, members, applications: db.prepare('SELECT a.user_id,u.username,a.created_at FROM alliance_applications a JOIN users u ON u.id=a.user_id WHERE a.alliance_id=? ORDER BY a.created_at LIMIT 100').all(gid), aether: db.prepare('SELECT * FROM aether_guilds WHERE guild_id=? ORDER BY event_id DESC LIMIT 20').all(gid), mercenaries: db.prepare('SELECT event_id,user_id,guild_id,origin_guild,status,updated_at FROM aether_mercenaries WHERE guild_id=? ORDER BY updated_at DESC LIMIT 100').all(gid), audit: db.prepare("SELECT action,summary,created_at FROM admin_audit WHERE target_user_id IN(SELECT user_id FROM alliance_members WHERE alliance_id=?) AND (action LIKE 'association.%' OR action LIKE 'aether.%') ORDER BY id DESC LIMIT 100").all(gid), readOnly: realm !== 'local-1' };
        });
    }
    dashboard(query = {}) {
        const realm = String(query.realm ?? 'local-1'), requested = String(query.event ?? ''), page = Number(query.page ?? 1), size = 50;
        if (requested.length > 160 || !Number.isSafeInteger(page) || page < 1 || page > 10000)
            adminError('Bộ lọc mùa/trang không hợp lệ.');
        return this.scoped(realm, db => {
            const svc = new AetherService(db, this.now, realm), events = db.prepare('SELECT id,version,start_at,end_at,qa,qa_active,managed FROM aether_events WHERE realm_id=? ORDER BY start_at DESC,rowid DESC LIMIT 100').all(realm);
            let current;
            try {
                current = svc.event();
            }
            catch {
                const [version, base] = Object.entries(aetherConfig('base')).sort(([a], [b]) => Number(b) - Number(a))[0];
                current = { id: realm + '-' + version, realm_id: realm, version: Number(version), start_at: aetherStamp(base.start_time), end_at: aetherStamp(base.end_time), qa: 0, managed: 0 };
            }
            const e = requested ? (db.prepare('SELECT * FROM aether_events WHERE id=? AND realm_id=?').get(requested, realm) ?? (requested === current.id ? current : undefined)) : current;
            if (!e)
                adminError('Mùa không thuộc realm đã chọn.', 404);
            const selected = e, args = [selected.id], offset = (page - 1) * size;
            const list = (table, fields, order) => db.prepare(`SELECT ${fields} FROM ${table} WHERE event_id=? ORDER BY ${order} LIMIT ? OFFSET ?`).all(...args, size, offset);
            const total = (table) => Number(db.prepare(`SELECT count(*) n FROM ${table} WHERE event_id=?`).get(...args).n);
            const cities = db.prepare('SELECT * FROM aether_cities WHERE event_id=? ORDER BY group_id,city_id').all(...args);
            const participants = db.prepare('SELECT g.*,a.name FROM aether_guilds g JOIN alliances a ON a.id=g.guild_id WHERE event_id=? ORDER BY group_id,slot').all(...args).map(g => ({ ...g, cityScore: cities.filter(c => c.owner_id === g.guild_id).reduce((n, c) => n + Number(aetherConfig('build')[c.city_id]?.score ?? 0), 0) }));
            const totals = { ...Object.fromEntries(['aether_wars', 'aether_battles', 'aether_scores', 'aether_score_awards', 'aether_claims', 'aether_deployments', 'aether_formations', 'aether_mercenaries'].map(t => [t, total(t)])), scienceContributions: Number(db.prepare("SELECT count(*) n FROM aether_claims WHERE event_id=? AND kind='science-contribution'").get(selected.id).n) };
            return { realm, readOnly: realm !== 'local-1', isCurrent: selected.id === current.id, events: [...events, ...events.some(r => r.id === current.id) ? [] : [current]], page, pageSize: size,
                totals, qaParticipants: simEnabled(db, selected) ? db.prepare("SELECT m.user_id,m.role,a.name guild_name,json_extract(p.profile,'$.show_name') name FROM alliance_members m JOIN alliances a ON a.id=m.alliance_id JOIN aether_guilds g ON g.guild_id=a.id JOIN player_state p ON p.user_id=m.user_id WHERE g.event_id=? ORDER BY m.user_id LIMIT 100").all(selected.id).map(u => ({ ...u, credit: simGet(db, selected.id, Number(u.user_id), 'science-credit', new Date(svc.time(selected) + 7 * 3600000).toISOString().slice(0, 10), { credits: 0, used: 0 }) })) : [], simulation: simEnabled(db, selected) ? { ...simPolicy, states: db.prepare('SELECT user_id,kind,scope,state,updated_at FROM aether_sim_state WHERE event_id=? ORDER BY updated_at DESC LIMIT 100').all(selected.id) } : null, settlement: aetherSettlementPreview(db, selected, svc.time(selected)),
                scienceContributions: db.prepare("SELECT user_id,claim_key,created_at,json_extract(reward,'$.guildId') guildId,json_extract(reward,'$.basePoints') basePoints,json_extract(reward,'$.points') points,json_extract(reward,'$.doubled') doubled,json_extract(reward,'$.total') total,json_extract(reward,'$.level') level,json_extract(reward,'$.costs') costs FROM aether_claims WHERE event_id=? AND kind='science-contribution' ORDER BY rowid DESC LIMIT ? OFFSET ?").all(selected.id, size, offset),
                seasonMails: db.prepare("SELECT c.user_id,c.claim_key mail_id,c.created_at,json_extract(c.reward,'$.expiresAt') expires_at,json_extract(c.reward,'$.rewards') rewards,m.read_at FROM aether_claims c JOIN player_mail m ON m.user_id=c.user_id AND m.id=c.claim_key WHERE c.event_id=? AND c.kind='season-mail' ORDER BY c.rowid DESC LIMIT ? OFFSET ?").all(selected.id, size, offset).map(m => ({ ...m, status: m.read_at !== null ? 'CLAIMED' : (!selected.qa || selected.qa_active) && svc.time(selected) <= Number(m.expires_at) ? 'PENDING' : 'EXPIRED' })),
                wars: list('aether_wars', "id,group_id,city_id,day,status,error,updated_at,json_array_length(state,'$.attack') attackRemaining,json_array_length(state,'$.defend') defendRemaining,json_extract(state,'$.duels') duels,json_extract(state,'$.snapshotVerified') snapshotVerified", 'day DESC,group_id,city_id'),
                scores: list('aether_scores', 'user_id,blood,reached_order', 'blood DESC,reached_order'), awards: list('aether_score_awards', 'battle_id,user_id,group_id,city_id,day,team,wins,total,delta', 'rowid DESC'),
                towns: Object.entries(aetherConfig('build')).filter(([, c]) => c.sort === 1 && c.city_level === 1).map(([id, c]) => ({ id: Number(id), name: c.city_name })),
                cities: cities.map(c => ({ ...c, name: aetherConfig('build')[c.city_id]?.city_name, sort: aetherConfig('build')[c.city_id]?.sort })),
                formations: list('aether_formations', 'user_id,state,updated_at', 'updated_at DESC'), materials: Object.entries(aetherItems()).map(([id, c]) => ({ id: Number(id), name: c.name, icon: c.icon, stack: c.stack })),
                versions: Object.keys(aetherConfig('base')).map(Number).sort((a, b) => b - a), phaseOptions: Object.values(aetherConfig('open')).map((r) => ({ step: r.sort, days: r.show_day, label: r.open_des, timing: r.timing })), event: { ...selected, phase: svc.phase(selected) },
                groups: svc.groups(selected).map(g => ({ id: g.group_id, hireLimit: g.hire_limit, registered: participants.filter(r => r.group_id === g.group_id).length })), participants,
                mercenaries: list('aether_mercenaries', 'user_id,guild_id,origin_guild,status,updated_at', 'updated_at DESC'), deployments: list('aether_deployments', '*', 'city_id,priority,rowid'),
                battles: list('aether_battles', 'id,group_id,city_id,metadata,created_at', 'rowid DESC'), claims: list('aether_claims', 'user_id,kind,claim_key,reward,created_at', 'created_at DESC,rowid DESC'),
                audit: db.prepare("SELECT id,action,summary,created_at FROM admin_audit WHERE action LIKE 'aether.%' AND (json_extract(after_state,'$.event')=? OR json_extract(after_state,'$.id')=?) ORDER BY id DESC LIMIT 50").all(selected.id, selected.id),
                blockers: aetherMissing(), qaEnabled: realm === 'local-1' && selected.id === current.id };
        });
    }
    battle(realm, id) {
        if (!id || id.length > 300)
            adminError('Mã biên bản không hợp lệ.');
        return this.scoped(realm, db => {
            const row = db.prepare('SELECT b.id,b.event_id,b.group_id,b.city_id,b.packet,b.metadata,b.created_at FROM aether_battles b JOIN aether_events e ON e.id=b.event_id WHERE b.id=? AND e.realm_id=?').get(id, realm);
            if (!row)
                adminError('Không có biên bản trong realm này.', 404);
            return { ...row, packet: JSON.parse(String(row.packet)), metadata: JSON.parse(String(row.metadata)), realm, readOnly: true };
        });
    }
    qa(admin, b) { return this.operation(admin, b, true); }
    organize(admin, b) { return this.operation(admin, b, false); }
    operation(admin, b, qaOnly) {
        if (b.confirmed !== true || typeof b.requestId !== 'string' || !/^[-a-zA-Z0-9_:]{8,120}$/.test(b.requestId))
            adminError('Cần xác nhận và mã thao tác QA.');
        const fingerprint = createHash('sha256').update(JSON.stringify({ qaOnly, b })).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT * FROM aether_admin_operations WHERE admin_id=? AND request_key=?').get(admin, b.requestId);
            if (old) {
                if (old.fingerprint !== fingerprint)
                    adminError('Mã QA đã dùng cho nội dung khác.');
                this.db.exec('COMMIT');
                return { ...JSON.parse(String(old.result)), replayed: true };
            }
            const svc = new AetherService(this.db, this.now);
            let out;
            if (b.action === 'create') {
                const row = aetherConfig('base')[b.version];
                if (!row)
                    adminError('Mùa không có trong nguồn VN.');
                let start = aetherStamp(row.start_time), end = aetherStamp(row.end_time);
                const id = (qaOnly ? 'qa-' : 'managed-') + randomUUID();
                if (!qaOnly) {
                    if (typeof b.startDate !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(b.startDate))
                        adminError('Ngày bắt đầu cần YYYY-MM-DD.');
                    start = Date.parse(b.startDate + 'T00:00:00+07:00');
                    if (!Number.isFinite(start) || new Date(start + 7 * 3600000).toISOString().slice(0, 10) !== b.startDate || start < Math.floor((this.now() + 7 * 3600000) / 86400000) * 86400000 - 7 * 3600000)
                        adminError('Chọn ngày hợp lệ từ hôm nay trở đi.');
                    const days = Math.max(...Object.values(aetherConfig('open')).flatMap((r) => r.show_day));
                    end = start + days * 86400000 - 1;
                    if (this.db.prepare('SELECT 1 FROM aether_events WHERE managed=1 AND realm_id=? AND start_at<=? AND end_at>=?').get('local-1', end, start))
                        adminError('Mùa được đặt lịch trùng với một mùa đã có.');
                }
                this.db.prepare('UPDATE aether_events SET qa_active=0 WHERE qa=1').run();
                this.db.prepare('INSERT INTO aether_events(id,realm_id,version,start_at,end_at,qa,qa_time,qa_updated,managed) VALUES(?,?,?,?,?,?,?,?,?)').run(id, 'local-1', Number(b.version), start, end, qaOnly ? 1 : 0, qaOnly ? start : null, qaOnly ? this.now() : null, qaOnly ? 0 : 1);
                out = { id, qa: qaOnly, start_at: start, end_at: end, policy: qaOnly ? 'Lịch QA riêng' : 'Chủ dự án đặt lịch và chia hội thủ công; không giả bốc thăm gốc.' };
            }
            else {
                const e = svc.event();
                if (qaOnly ? !e.qa : (!e.managed || e.qa))
                    adminError(qaOnly ? 'Chỉ sửa sự kiện QA đã tạo rõ ràng.' : 'Chọn mùa do chủ dự án đặt lịch, không sửa mùa tự động.');
                if (b.action === 'close') {
                    if (!qaOnly)
                        adminError('Không đóng mùa thật bằng thao tác QA.');
                    this.db.prepare('UPDATE aether_events SET qa_active=0 WHERE id=?').run(e.id);
                    out = { id: e.id, closed: true };
                }
                else if (b.action === 'phase') {
                    if (!qaOnly)
                        adminError('Lịch mùa do server chạy theo giờ thật.');
                    const midnight = Math.floor((e.start_at + 7 * 3600000) / 86400000) * 86400000 - 7 * 3600000, r = Object.values(aetherConfig('open')).find((r) => r.sort === Number(b.step) && r.show_day.includes(Number(b.day)));
                    if (!r)
                        adminError('Pha/ngày không có trong bảng nguồn.');
                    const [h, m, s] = r.timing.split('-')[0].split(':').map(Number), time = midnight + (Number(b.day) - 1) * 86400000 + ((h * 60 + m) * 60 + s) * 1000 + 1000;
                    if (time < svc.time(e) || time > e.end_at)
                        adminError('Không tua ngược hoặc ra ngoài mùa QA; hãy tạo sự kiện mới.');
                    this.db.prepare('UPDATE aether_events SET qa_time=?,qa_updated=? WHERE id=?').run(time, this.now(), e.id);
                    out = { id: e.id, phase: aetherPhase(e.start_at, e.end_at, time) };
                }
                else if (b.action === 'enroll') {
                    if (svc.phase(e).step !== 1 && !(e.managed && this.now() < e.start_at))
                        adminError('Chỉ chia hội trước khi bắt đầu hoặc trong Dự Cáo.');
                    const gid = Number(b.guildId), group = Number(b.groupId), slot = Number(b.slot);
                    if (!svc.groups(e).some(g => g.group_id === group) || !Number.isInteger(slot) || slot < 1 || slot > 12)
                        adminError('Nhóm/vị trí không hợp lệ.');
                    if (Number(this.db.prepare('SELECT count(*) n FROM alliance_members WHERE alliance_id=?').get(gid).n) <= 10)
                        adminError('Nguồn yêu cầu hơn10 thành viên; không bỏ kiểm tra cho hội thật.');
                    if (!this.db.prepare('SELECT 1 FROM alliances WHERE id=? AND closed_at IS NULL').get(gid))
                        adminError('Hội không tồn tại.');
                    if (this.db.prepare('SELECT 1 FROM aether_guilds WHERE event_id=? AND (guild_id=? OR group_id=? AND slot=?)').get(e.id, gid, group, slot))
                        adminError('Hội đã được chọn hoặc vị trí nhóm đã có hội.');
                    this.db.prepare('INSERT INTO aether_guilds(event_id,guild_id,group_id,slot) VALUES(?,?,?,?)').run(e.id, gid, group, slot);
                    out = { event: e.id, guildId: gid, groupId: group, slot, matchingPolicy: qaOnly ? 'QA: chủ động gán' : 'Chủ quản phân chia thủ công theo phê duyệt.' };
                }
                else if (b.action === 'sim_credit') {
                    if (!qaOnly || !simEnabled(this.db, e))
                        adminError('Tín dụng mô phỏng chỉ trong DB QA đã được cho phép.');
                    const user = Number(b.userId), amount = Number(b.quantity);
                    svc.science(user, e);
                    if (!Number.isInteger(amount) || amount < 1 || amount > 3)
                        adminError('Chỉ thêm1–3tín dụng QA.');
                    const day = new Date(svc.time(e) + 7 * 3600000).toISOString().slice(0, 10), state = simGet(this.db, e.id, user, 'science-credit', day, { credits: 0, used: 0 });
                    if (state.credits + amount > 3)
                        adminError('Tối đa3tín dụng nạp QA mỗi ngày.');
                    state.credits += amount;
                    simPut(this.db, e.id, user, 'science-credit', day, state, this.now());
                    out = { event: e.id, userId: user, day, credits: state.credits, used: state.used, simulation: true };
                }
                else if (b.action === 'retry_war') {
                    if (!qaOnly)
                        adminError('Chỉ tiếp tục job trên mùa QA riêng.');
                    const id = String(b.warId ?? '');
                    if (!id || id.length > 300)
                        adminError('Mã job không hợp lệ.');
                    const war = this.db.prepare("SELECT * FROM aether_wars WHERE event_id=? AND id=? AND status='blocked'").get(e.id, id);
                    if (!war)
                        adminError('Không có job bị gián đoạn thuộc mùa QA này.');
                    const state = JSON.parse(String(war.state));
                    if (state.snapshotVerified !== true || (!state.defender && !(state.simulation && simEnabled(this.db, e))) || !state.attack?.length || !state.defend?.length)
                        adminError('Job thiếu snapshot chiến đấu đã xác minh; không ép mở trận thiếu nguồn.');
                    const recorded = Number(this.db.prepare("SELECT count(*) n FROM aether_battles WHERE event_id=? AND substr(id,1,length(?)+1)=?||':'").get(e.id, id, id).n);
                    if (recorded !== state.duels)
                        adminError('Snapshot và biên bản không khớp; giữ nguyên để kiểm tra.');
                    this.db.prepare("UPDATE aether_wars SET status='ready',error=NULL,updated_at=? WHERE id=? AND event_id=?").run(this.now(), id, e.id);
                    out = { event: e.id, id, policy: 'Tiếp tục snapshot đã khóa; giữ biên bản/điểm/biên nhận, không chạy lại trận đã kết toán.' };
                }
                else if (b.action === 'material' || b.action === 'material_mail') {
                    if (!qaOnly)
                        adminError('Không cấp vật liệu QA vào mùa thật.');
                    if (svc.phase(e).ended || svc.phase(e).step === 0)
                        adminError('Mùa QA đã đóng; chưa cấp vật liệu.');
                    const user = Number(b.userId), cid = Number(b.configId), quantity = Number(b.quantity);
                    if (!aetherItems()[cid] || !Number.isSafeInteger(quantity) || quantity < 1 || quantity > 1000 || !this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(user))
                        adminError('Tài khoản/vật liệu/số lượng QA không hợp lệ.');
                    const economy = new AetherEconomy(this.db, e.id);
                    if (b.action === 'material_mail')
                        out = { userId: user, ...issueAetherMail(this.db, e, user, [[6, cid, quantity]], b.requestId, this.now()) };
                    else {
                        economy.grant({ user_id: user }, [[6, cid, quantity]]);
                        out = { event: e.id, userId: user, configId: cid, quantity, inventory: economy.inventory(user) };
                    }
                }
                else if (b.action === 'city') {
                    if (svc.phase(e).step !== 1 && !(e.managed && this.now() < e.start_at))
                        adminError('Chỉ đặt điểm xuất phát trước khi bắt đầu hoặc trong Dự Cáo.');
                    const gid = Number(b.guildId), group = Number(b.groupId), city = Number(b.cityId), town = aetherConfig('build')[city];
                    if (!town || town.sort !== 1 || town.city_level !== 1)
                        adminError('Chỉ gán thành cấp1 có trong nguồn để chuẩn bị QA.');
                    if (!this.db.prepare('SELECT 1 FROM aether_guilds WHERE event_id=? AND guild_id=? AND group_id=?').get(e.id, gid, group))
                        adminError('Hội chưa ở nhóm QA này.');
                    if (this.db.prepare('SELECT 1 FROM aether_cities WHERE event_id=? AND group_id=? AND city_id=?').get(e.id, group, city))
                        adminError('Thành QA đã có trạng thái; không ghi đè.');
                    this.db.prepare('INSERT INTO aether_cities(event_id,group_id,city_id,owner_id) VALUES(?,?,?,?)').run(e.id, group, city, gid);
                    out = { event: e.id, guildId: gid, cityId: city, groupId: group, policy: qaOnly ? 'Điểm xuất phát do OWNER gán riêng QA.' : 'Điểm xuất phát do chủ quản chỉ định.' };
                }
                else
                    adminError('Hành động QA chưa hỗ trợ.');
            }
            audit(this.db, admin, (qaOnly ? 'aether.qa.' : 'aether.manage.') + b.action, null, qaOnly ? 'LOCAL QA Aether; không đổi đồng hồ server hoặc hội gốc' : 'Chủ quản đặt lịch/chia hội Aether theo phê duyệt; không đổi hội gốc', null, { ...out, requestId: b.requestId });
            this.db.prepare('INSERT INTO aether_admin_operations VALUES(?,?,?,?)').run(admin, b.requestId, fingerprint, JSON.stringify(out));
            this.db.exec('COMMIT');
            return out;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
