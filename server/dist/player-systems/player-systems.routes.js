import { PlayerService } from '../player/player.service.js';
import { readStaticConfigSync as cfg } from '../player/local-content.js';
import { PlayerSystemsService, publicIdentity, titleState, systemsFail } from './player-systems.service.js';
import { playerSystemsReady } from './player-systems-migration.js';
import { realmManager } from './realm-manager.js';
import { readFileSync } from 'node:fs';
const methods = ['storehouse.index', 'user.title_index', 'user.use_title', ...['item', 'card', 'equip', 'talisman'].flatMap(k => ['store', 'del'].map(a => 'storehouse.' + a + '_' + k))];
export function registerPlayerSystemsGame(app, auth, online, released = false) {
    if (online && !released)
        return;
    const base = JSON.parse(readFileSync(new URL('../../data/local-player.json', import.meta.url), 'utf8'));
    app.addHook('preHandler', async (r, reply) => {
        const q = r.query, method = String(q.method ?? '');
        if (!['/api/', '/pub_abroad_vr/api/'].includes(r.url.split('?')[0]) || !methods.includes(method))
            return;
        const s = auth.session(q.rans);
        if (!s || q.user_token !== s.game_uid || !auth.validGameToken(s, q.mk))
            return reply.code(403).send({ msg: 'Phiên gameplay LOCAL không hợp lệ.' });
        if (!playerSystemsReady(auth.db))
            return reply.send({ status: 'LOCAL_SYSTEMS_NOT_READY', msg: 'Bản cập nhật đang chờ duyệt dữ liệu QA.' });
        const players = new PlayerService(auth.db);
        await players.ensure(s);
        const svc = new PlayerSystemsService(auth.db);
        try {
            const data = method === 'storehouse.index' ? { storehouse: svc.warehouse(s.user_id) } : method === 'user.title_index' ? svc.titles(s.user_id) : method === 'user.use_title' ? svc.useTitle(s, q.title_id, q.request_id) : svc.transfer(s, method, new URL(r.url, 'http://localhost').searchParams);
            return reply.send({ status: '0', data, user_status: players.profile(s, base) });
        }
        catch (e) {
            if (e.statusCode < 500)
                return reply.send({ status: 'LOCAL_PLAYER_SYSTEM_ERROR', msg: e.message });
            throw e;
        }
    });
    app.addHook('preSerialization', async (r, _reply, payload) => {
        if (payload?.status !== '0' || !playerSystemsReady(auth.db))
            return payload;
        const q = r.query, s = auth.session(q.rans);
        if (!s || !payload.user_status)
            return payload;
        payload.user_status = { ...payload.user_status, public_id: publicIdentity(auth.db, s.user_id)?.public_id, cur_title: titleState(auth.db, s.user_id).cur_title };
        if (q.method === 'user.main_page')
            Object.assign(payload.data, new PlayerSystemsService(auth.db).titles(s.user_id));
        if (q.method === 'cards.open')
            payload.data.storehouse = new PlayerSystemsService(auth.db).warehouse(s.user_id);
        const publicUser = (u) => { if (!u || !u.uid)
            return; const row = auth.db.prepare('SELECT user_id FROM player_profiles WHERE game_uid=?').get(u.uid); if (row) {
            u.public_id = publicIdentity(auth.db, Number(row.user_id))?.public_id;
            u.title = titleState(auth.db, Number(row.user_id)).cur_title;
        } };
        for (const u of payload.data?.top ?? [])
            publicUser(u);
        for (const u of payload.data?.front_user ?? [])
            publicUser(u);
        publicUser(payload.data?.new_data?.user);
        return payload;
    });
}
async function scopedDb(db, r) {
    const realm = String(r.query?.realm ?? 'local-1');
    if (!/^local-[1-9][0-9]{0,3}$/.test(realm))
        systemsFail('Server không hợp lệ.');
    if (!realmManager(db) && realm === 'local-1')
        return db;
    const manager = realmManager(db);
    if (!manager)
        systemsFail('Chưa có quản lý server LOCAL.', 409);
    return manager.adminDatabase(realm, r.adminIdentity?.id);
}
const base = { confirmed: { const: true }, requestId: { type: 'string', pattern: '^[a-zA-Z0-9:_-]{8,120}$' } };
export function registerPlayerSystemsAdmin(admin, db, online, released = false) {
    const svc = () => { if ((online && !released) || !playerSystemsReady(db))
        systemsFail('Chưa có extension LOCAL được duyệt.', 409); return new PlayerSystemsService(db); };
    admin.get('/api/player-systems/servers', async () => { svc(); return { items: realmManager(db)?.list() ?? db.prepare('SELECT * FROM legacy_server_realms ORDER BY id').all(), notice: 'Mỗi server có DB riêng. Chính thức là phân loại LOCAL, không phải VPS. Giftcode có hạn mức riêng mỗi server.' }; });
    admin.post('/api/player-systems/servers', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'id', 'name', 'kind', 'status'], properties: { confirmed: base.confirmed, id: { type: 'string', pattern: '^local-[1-9][0-9]{0,3}$' }, name: { type: 'string', minLength: 1, maxLength: 80 }, kind: { enum: ['test', 'official'] }, status: { enum: ['open', 'closed'] }, revision: { type: 'integer', minimum: 1 } } } } }, async (r) => { svc(); if (online)
        systemsFail('Mở thêm realm ONLINE cần quy trình triển khai/backup riêng.', 403); const b = r.body; return realmManager(db).save(r.adminIdentity.id, { confirmed: b.confirmed, id: b.id, name: b.name, kind: b.kind, status: b.status, revision: b.revision }); });
    admin.get('/api/player-systems/giftcode-scopes', async () => { svc(); return { items: db.prepare("SELECT g.id,g.code,g.campaign,COALESCE(s.scope,'test') scope,COALESCE(s.realm_ids,'[\"local-1\"]') realm_ids,COALESCE(s.revision,0) revision FROM giftcodes g LEFT JOIN legacy_giftcode_scopes s ON s.giftcode_id=g.id ORDER BY g.id DESC").all().map(r => ({ ...r, realmIds: JSON.parse(String(r.realm_ids)) })) }; });
    admin.post('/api/player-systems/giftcodes/:id/scope', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'scope', 'realmIds', 'revision'], properties: { confirmed: base.confirmed, scope: { enum: ['all', 'test', 'official'] }, realmIds: { type: 'array', maxItems: 100, uniqueItems: true, items: { type: 'string', pattern: '^local-[1-9][0-9]{0,3}$' } }, revision: { type: 'integer', minimum: 0 } } } } }, async (r) => { svc(); if (online)
        systemsFail('Đổi phạm vi nhiều realm ONLINE cần triển khai riêng.', 403); return realmManager(db).scope(r.adminIdentity.id, Number(r.params.id), r.body); });
    admin.get('/api/player-systems/players', async (r) => {
        svc();
        const target = await scopedDb(db, r), q = String(r.query.q ?? '').slice(0, 80).toLocaleLowerCase('vi');
        const items = target.prepare("SELECT u.id,u.username,p.game_uid,json_extract(s.profile,'$.show_name') show_name,i.public_id FROM users u JOIN player_profiles p ON p.user_id=u.id JOIN player_state s ON s.user_id=u.id LEFT JOIN legacy_public_ids i ON i.user_id=u.id ORDER BY u.id DESC").all().filter(p => [p.username, p.game_uid, p.show_name, p.public_id].join(' ').toLocaleLowerCase('vi').includes(q));
        return { items: items.slice(0, 100), total: items.length };
    });
    admin.get('/api/player-systems/titles', async () => { svc(); return { items: Object.entries(cfg('title_list')).map(([id, c]) => ({ id: Number(id), name: c.name, description: c.des1, requirement: c.des2, icon: c.icon })), notice: 'Đeo/hiển thị Danh Hiệu; buff và phát tài nguyên chưa kích hoạt.' }; });
    admin.get('/api/player-systems/players/:id', async (r) => { svc(); const target = await scopedDb(db, r), s = new PlayerSystemsService(target), id = Number(r.params.id); if (!target.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(id))
        systemsFail('Người chơi chưa khởi tạo.', 404); return { identity: publicIdentity(target, id), ...s.titles(id), storehouse: s.warehouse(id) }; });
    admin.post('/api/player-systems/players/:id/public-id', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'publicId', 'revision'], properties: { confirmed: base.confirmed, publicId: { type: 'string', pattern: '^vn[0-9]{8}$' }, revision: { type: 'integer', minimum: 1 } } } } }, async (r) => { const b = r.body; svc(); return new PlayerSystemsService(await scopedDb(db, r)).renameId(r.adminIdentity.id, Number(r.params.id), b.publicId, b.revision); });
    admin.post('/api/player-systems/players/:id/title', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'titleId', 'expiresAt', 'revoke'], properties: { confirmed: base.confirmed, titleId: { type: 'integer', minimum: 1 }, expiresAt: { type: 'integer', minimum: -1 }, revoke: { type: 'boolean' } } } } }, async (r) => { const b = r.body; svc(); return new PlayerSystemsService(await scopedDb(db, r)).grantTitle(r.adminIdentity.id, Number(r.params.id), b.titleId, b.expiresAt, b.revoke); });
}
