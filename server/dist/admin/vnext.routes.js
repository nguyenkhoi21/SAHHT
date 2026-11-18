import { RestoredEvents } from '../player/restored-events.js';
import { restoredDefault, restoredKinds } from '../player/restored-event-source.js';
import { PlayerNotices } from '../player/player-notices.js';
import { TreasureEvents, treasureProblems } from '../player/treasure-events.js';
import { ClientPresentation } from '../player/client-presentation.js';
import { InviteCodeService } from '../player/invite-code.service.js';
import { InviteRewards } from '../player/invite-rewards.js';
import { defaultTreasure, treasureKinds } from '../player/treasure-source.js';
import { EventPlanner } from '../player/event-planner.js';
import { skyRows } from '../player/event-source.js';
import { createBaseHero } from '../player/definitions.js';
import { statistics } from './statistics.js';
import { readConfigSync } from '../player/local-content.js';
import { ExchangeService } from '../player/exchange.service.js';
import { NewstarService } from '../player/newstar.service.js';
import { NewstarConfig } from '../player/newstar-config.js';
import { HotCampaignAdmin, campaignRows, campaignState, rewardProblem } from '../player/hot-campaigns.js';
import { hotDay } from '../player/hot-source.js';
import { audit, adminError } from './admin.audit.js';
export function registerVnext(admin, db, service, online) {
    const local = () => { if (online)
        adminError('Không gian Admin vNext mới chỉ mở LOCAL.', 403); };
    admin.get('/api/client-presentation', async () => { local(); return new ClientPresentation(db).admin(); });
    admin.post('/api/client-presentation', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'revision', 'definition'], properties: { confirmed: { const: true }, revision: { type: 'integer', minimum: 0 }, definition: { type: 'object' } } } } }, async (r) => { local(); const b = r.body; return new ClientPresentation(db).save(r.adminIdentity.id, b.revision, b.definition); });
    admin.get('/api/invite-codes', async (r) => { local(); return new InviteCodeService(db).admin(r.query); });
    const restoredKind = (v) => { if (typeof v !== 'string' || !Object.hasOwn(restoredKinds, v))
        adminError('Loại sự kiện không hợp lệ.'); return v; };
    admin.get('/api/restored-events/:kind', async (r) => { local(); const kind = restoredKind(r.params.kind), q = r.query; return { ...new RestoredEvents(db).admin(kind), ...(+q.version ? { prototype: restoredDefault(kind, +q.version) } : {}) }; });
    admin.post('/api/restored-events/save', { config: { adminPermission: 'owner' } }, async (r) => { local(); const b = r.body; if (b.confirmed !== true)
        adminError('Cần xác nhận lưu.'); return new RestoredEvents(db).save(r.adminIdentity.id, b); });
    admin.post('/api/restored-events/publish', { config: { adminPermission: 'owner' } }, async (r) => { local(); const b = r.body; if (b.confirmed !== true)
        adminError('Cần xác nhận công bố.'); return new RestoredEvents(db).publish(r.adminIdentity.id, b); });
    admin.get('/api/restored-events/:kind/history', async (r) => { local(); return new RestoredEvents(db).history(restoredKind(r.params.kind), Number(r.query.page)); });
    admin.get('/api/notices', async (r) => { local(); const svc = new PlayerNotices(db), user = Number(r.query.user); return { ...svc.settings(), ...(Number.isSafeInteger(user) && user > 0 ? { player: svc.inspect(user) } : {}) }; });
    admin.post('/api/notices', { config: { adminPermission: 'owner' } }, async (r) => { local(); const b = r.body; if (b.confirmed !== true || !Number.isSafeInteger(b.revision) || b.revision < 0)
        adminError('Cần xác nhận và revision.'); return new PlayerNotices(db).save(r.adminIdentity.id, b.revision, b.definition); });
    admin.get('/api/invite-rewards', async () => { local(); return new InviteRewards(db).admin(); });
    admin.post('/api/invite-rewards', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'revision', 'definition'], properties: { confirmed: { const: true }, revision: { type: 'integer', minimum: 0 }, definition: { type: 'object' } } } } }, async (r) => { local(); const b = r.body; return new InviteRewards(db).save(r.adminIdentity.id, b.revision, b.definition); });
    admin.get('/api/players/:id/statistics', async (r) => { local(); return statistics(db, Number(r.params.id), Number(r.query.team ?? 0)); });
    admin.get('/api/vnext/overview', async () => { local(); const now = Date.now(), rows = campaignRows(db); return { at: now, timezone: 'Asia/Ho_Chi_Minh', active: rows.filter(c => campaignState(c, now) === 'active').length, upcoming: rows.filter(c => c.status !== 'disabled' && c.status !== 'draft' && c.starts > now && c.starts < now + 7 * 86400000).sort((a, b) => a.starts - b.starts).slice(0, 6).map(c => ({ id: c.id, name: c.name, starts: c.starts, kind: c.kind })), recent: db.prepare("SELECT id,action,summary,created_at,target_user_id FROM admin_audit WHERE action LIKE 'hot.%' OR action LIKE 'event.newstar.%' OR action LIKE '%mail%' ORDER BY id DESC LIMIT 8").all() }; });
    const definition = { type: 'object', additionalProperties: false, required: ['confirmed', 'definition'], properties: { confirmed: { const: true }, id: { type: 'integer', minimum: 1 }, revision: { type: 'integer', minimum: 1 }, definition: { type: 'object' } } };
    admin.post('/api/events/newstar/rewards', { config: { adminPermission: 'owner' }, bodyLimit: 32768, schema: { body: definition } }, async (r) => { local(); return new NewstarConfig(db).save(r.adminIdentity.id, r.body); });
    admin.post('/api/events/newstar/publish', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'id', 'revision'], properties: { confirmed: { const: true }, id: { type: 'integer', minimum: 1 }, revision: { type: 'integer', minimum: 1 } } } } }, async (r) => { local(); return new NewstarConfig(db).publish(r.adminIdentity.id, r.body); });
    admin.post('/api/events/newstar/scope', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'serverFrom', 'serverTo'], properties: { confirmed: { const: true }, serverFrom: { type: 'integer', minimum: 1, maximum: 1000000 }, serverTo: { type: 'integer', minimum: 1, maximum: 1000000 } } } } }, async (r) => { local(); return new NewstarService(db).setScope(r.adminIdentity.id, r.body); });
    const eventKind = (value) => { if (typeof value !== 'string' || !Object.hasOwn(treasureKinds, value))
        adminError('Loại sự kiện không hợp lệ.'); return value; };
    admin.get('/api/treasure-events/:kind', async (r) => { local(); return new TreasureEvents(db).admin(eventKind(r.params.kind)); });
    admin.get('/api/treasure-events/:kind/preset', async (r) => { local(); const kind = eventKind(r.params.kind), version = Number(r.query.version); if (!Number.isSafeInteger(version) || !new TreasureEvents(db).admin(kind).presets.some(p => p.version === version))
        adminError('Phiên bản nguồn không tồn tại.'); const definition = defaultTreasure(kind, version); return { definition, problems: treasureProblems(definition) }; });
    admin.post('/api/treasure-events/configs', { config: { adminPermission: 'owner' }, bodyLimit: 262144, schema: { body: definition } }, async (r) => { local(); return new TreasureEvents(db).save(r.adminIdentity.id, r.body); });
    admin.post('/api/treasure-events/publish', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'id', 'revision'], properties: { confirmed: { const: true }, id: { type: 'integer', minimum: 1 }, revision: { type: 'integer', minimum: 1 } } } } }, async (r) => { local(); return new TreasureEvents(db).publish(r.adminIdentity.id, r.body); });
    admin.get('/api/treasure-events/:kind/history', async (r) => { local(); const kind = eventKind(r.params.kind), q = r.query, page = Math.max(1, Math.min(100000, Math.floor(Number(q.page) || 1))), user = Number.isSafeInteger(Number(q.user)) && Number(q.user) > 0 ? Number(q.user) : 0; return { page, items: db.prepare(`SELECT r.request_id,r.occurrence_id,r.action,r.created_at,json_extract(r.result,'$.cost') cost,json_extract(r.result,'$.reward_tuples') rewards,p.game_uid FROM treasure_event_receipts r JOIN player_profiles p ON p.user_id=r.user_id WHERE r.kind=? AND (?=0 OR r.user_id=?) ORDER BY r.created_at DESC,r.rowid DESC LIMIT 30 OFFSET ?`).all(kind, user, user, (page - 1) * 30).map(r => ({ ...r, cost: JSON.parse(String(r.cost ?? '[]')), rewards: JSON.parse(String(r.rewards ?? '[]')) })), runs: db.prepare('SELECT r.config_id,r.occurrence_id,r.revision,r.updated_at,r.state,p.game_uid FROM treasure_event_runs r JOIN player_profiles p ON p.user_id=r.user_id WHERE r.kind=? AND (?=0 OR r.user_id=?) ORDER BY r.updated_at DESC LIMIT 30').all(kind, user, user).map(r => ({ ...r, state: JSON.parse(String(r.state)) })) }; });
    admin.get('/api/event-planner', async (r) => { local(); const q = r.query; return new EventPlanner(db).info(String(q.month ?? new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 7))); });
    admin.get('/api/event-planner/sky-preview', async (r) => { local(); const q = r.query, target = String(q.target ?? 'main.506'); if (!['main.506', 'server.905'].includes(target))
        adminError('Chọn đúng bảng Xu đầy trời.'); return { rows: skyRows(target, Number(q.version)), policy: 'LOCAL_APPROVED_WEIGHTED_UNIFORM', notice: 'Chi phí/tỷ trọng theo nguồn Việt; cách bốc số đều trong khoảng được chủ dự án duyệt riêng LOCAL.' }; });
    admin.post('/api/event-planner/rules', { config: { adminPermission: 'owner' }, bodyLimit: 32768, schema: { body: definition } }, async (r) => { local(); return new EventPlanner(db).save(r.adminIdentity.id, r.body); });
    admin.post('/api/event-planner/action', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'action', 'id', 'revision'], properties: { confirmed: { const: true }, action: { enum: ['publish', 'disable', 'delete', 'restore'] }, id: { type: 'integer', minimum: 1 }, revision: { type: 'integer', minimum: 1 } } } } }, async (r) => { local(); return new EventPlanner(db).action(r.adminIdentity.id, r.body); });
    admin.post('/api/event-planner/opening', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'openedAt'], properties: { confirmed: { const: true }, openedAt: { type: 'string', maxLength: 40 } } } } }, async (r) => { local(); return new EventPlanner(db).setOpening(r.adminIdentity.id, r.body); });
    admin.get('/api/event-planner/history', async (r) => { local(); const q = r.query, page = Math.max(1, Math.floor(Number(q.page) || 1)); return { page, items: db.prepare('SELECT d.user_id,d.occurrence_id,d.step,d.cost,d.reward,d.created_at,p.game_uid FROM sky_star_draws d JOIN player_profiles p ON p.user_id=d.user_id ORDER BY d.created_at DESC,d.rowid DESC LIMIT 40 OFFSET ?').all((page - 1) * 40), total: db.prepare('SELECT count(*) n FROM sky_star_draws').get().n, audit: db.prepare("SELECT action,summary,created_at FROM admin_audit WHERE action LIKE 'calendar.plan.%' OR action='calendar.opening' ORDER BY id DESC LIMIT 30").all() }; });
    admin.get('/api/reward-templates', async () => { local(); return { items: db.prepare('SELECT * FROM admin_reward_templates ORDER BY updated_at DESC LIMIT 100').all().map(r => ({ ...r, rewards: JSON.parse(String(r.rewards)) })) }; });
    admin.post('/api/reward-templates', { config: { adminPermission: 'owner' }, bodyLimit: 16384 }, async (r) => { local(); const b = r.body; if (!b || b.confirmed !== true || typeof b.name !== 'string' || b.name.trim().length < 1 || b.name.length > 80 || rewardProblem(b.rewards))
        adminError('Mẫu thưởng cần tên1–80ký tự và gói thưởng hợp lệ.'); db.exec('BEGIN IMMEDIATE'); try {
        const id = Number(db.prepare('INSERT INTO admin_reward_templates(name,rewards,updated_at) VALUES(?,?,?)').run(b.name.trim(), JSON.stringify(b.rewards), Date.now()).lastInsertRowid);
        audit(db, r.adminIdentity.id, 'reward.template.save', null, 'Lưu mẫu thưởng', null, { id, name: b.name, rewards: b.rewards });
        db.exec('COMMIT');
        return { id };
    }
    catch (e) {
        db.exec('ROLLBACK');
        throw e;
    } });
    admin.get('/api/catalog/hero-grant-preview', async (r) => { local(); const id = Number(r.query.configId), list = await service.catalog('heroes', { q: String(id), pageSize: 100, scope: 'playable' }), hero = list.items.find(h => h.configId === id); if (!hero)
        adminError('Không phải tướng chơi được trong danh mục nguồn.'); return { configId: id, name: hero.name, mode: 'BASE_MAIL', state: createBaseHero('preview', id, readConfigSync('character_detail')[id]), delivery: 'MAIL', notice: 'Chỉ cấp khi nhận Thư, không thay tướng hoặc đội hình cũ.' }; });
    admin.get('/api/catalog/playable-heroes', async (r) => { local(); return service.catalog('heroes', { ...r.query, scope: 'playable' }); });
    admin.get('/api/hot/preview-unlimited', async () => { local(); return { rows: new ExchangeService(db).catalog({ user_id: 0 }).recipes.filter(r => r.unlimited).map(r => ({ id: r.id, cost: r.need_item, reward: r.rewards, active: r.active, blockedReason: r.blockedReason })) }; });
    admin.get('/api/hot/day', async (r) => { local(); const q = r.query, date = String(q.date ?? hotDay(Date.now())); if (!/^\d{4}-\d{2}-\d{2}$/.test(date))
        adminError('Ngày cần YYYY-MM-DD.'); const list = new HotCampaignAdmin(db).list({ month: date.slice(0, 7), kind: q.kind }); const start = Date.parse(date + 'T00:00:00+07:00'); if (!Number.isFinite(start) || hotDay(start) !== date)
        adminError('Ngày lịch không tồn tại.'); const rows = campaignRows(db).filter(c => c.starts < start + 86400000 && c.ends > start && (!q.kind || c.kind === q.kind) && (!q.q || (c.name + ' ' + c.id).toLocaleLowerCase().includes(String(q.q).toLocaleLowerCase()))); const page = Math.max(1, Math.floor(Number(q.page) || 1)); return { ...list, date, page, total: rows.length, campaigns: rows.slice((page - 1) * 40, page * 40).map(c => ({ ...c, state: campaignState(c, Date.now()), blockers: c.rows.map(row => rewardProblem(row.rewards)).filter(Boolean) })) }; });
}
