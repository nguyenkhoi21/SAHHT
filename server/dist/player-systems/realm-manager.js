import { existsSync, readFileSync, mkdirSync } from 'node:fs';
import { resolve, dirname, join } from 'node:path';
import { AuthService, hashToken, localAccount } from '../auth/auth.service.js';
import { TutorialService } from '../player/tutorial.js';
import { PlayerService } from '../player/player.service.js';
import { installWelfareSchema } from '../welfare/welfare-migration.js';
import { installRechargeSettings } from '../recharge/recharge-settings.js';
import { installPlayerSystems, playerSystemsReady } from './player-systems-migration.js';
import { systemsFail } from './player-systems.service.js';
import { audit } from '../admin/admin.audit.js';
const managers = new WeakMap();
export const realmManager = (db) => managers.get(db);
export class RealmManager {
    auth;
    options;
    factory;
    children = new Map();
    constructor(auth, options, factory) {
        this.auth = auth;
        this.options = options;
        this.factory = factory;
        managers.set(auth.db, this);
    }
    list() { return this.auth.db.prepare('SELECT * FROM legacy_server_realms ORDER BY created_at,id').all(); }
    row(id) { return this.auth.db.prepare('SELECT * FROM legacy_server_realms WHERE id=?').get(id); }
    async adminDatabase(realm, adminId) {
        const child = await this.child(realm), db = child.auth.db;
        if (adminId && db !== this.auth.db) {
            const a = this.auth.db.prepare('SELECT role,created_at FROM admin_users WHERE id=?').get(adminId);
            if (!a)
                systemsFail('Phiên quản trị không hợp lệ.', 403);
            db.prepare('INSERT OR IGNORE INTO admin_users(id,username,password_hash,role,created_at) VALUES(?,?,?,?,?)').run(adminId, 'realm_disabled_' + adminId, '!disabled', a.role, a.created_at);
        }
        return db;
    }
    async child(id) {
        if (id === 'local-1')
            return { auth: this.auth, app: null };
        if (!this.row(id))
            systemsFail('Không có server này.', 404);
        if (!this.children.has(id))
            this.children.set(id, (async () => {
                const dir = join(dirname(resolve(this.options.accountDb)), 'realms', id);
                mkdirSync(dir, { recursive: true });
                const path = join(dir, 'game.db'), fresh = !existsSync(path), auth = new AuthService(path);
                try {
                    if (fresh) {
                        installWelfareSchema(auth.db);
                        installRechargeSettings(auth.db);
                        installPlayerSystems(auth.db);
                    }
                    else if (!playerSystemsReady(auth.db))
                        systemsFail('DB server cần migration được duyệt trước khi mở.', 409);
                    const app = await this.factory({ ...this.options, accountDb: path, realmChild: true, publicOrigin: (this.options.publicOrigin ?? 'http://127.0.0.1:' + (this.options.port ?? 8787)) + '/realm/' + id, journalPath: undefined, backupDirectory: join(dir, 'backups') });
                    return { auth, app };
                }
                catch (e) {
                    auth.close();
                    throw e;
                }
            })().catch(e => { this.children.delete(id); throw e; }));
        return this.children.get(id);
    }
    async close() { for (const item of this.children.values()) {
        try {
            const c = await item;
            await c.app.close();
            c.auth.close();
        }
        catch { }
    } this.children.clear(); }
    async serverList(s) {
        const fixture = JSON.parse(readFileSync(new URL('../../data/server-list.json', import.meta.url), 'utf8')), origin = this.options.publicOrigin ?? 'http://127.0.0.1:' + (this.options.port ?? 8787), rows = [];
        for (const row of this.list()) {
            if (row.status !== 'open')
                continue;
            const id = String(row.id), { auth } = await this.child(id), profile = auth.db.prepare('SELECT game_uid FROM player_profiles WHERE user_id=?').get(s.user_id), created = !!profile && new TutorialService(auth.db).exists(s.user_id), entry = { ...fixture.server_list[0] };
            const base = origin + (id === 'local-1' ? '' : '/realm/' + id);
            for (const f of ['master_url', 'domain', 'dataosha_url'])
                entry[f] = base + '/pub_abroad_vr';
            for (const f of ['lua_url', 'lua_ver_url'])
                entry[f] = origin + (f === 'lua_url' ? '/resources' : '/versions');
            rows.push({ ...entry, server: id, server_name: row.name, uid: created ? profile.game_uid : '', level: created ? new PlayerService(auth.db).loginLevel({ user_id: s.user_id }) : 0, sort_id: rows.length, kind: row.kind });
        }
        return { ...fixture, current_server: rows.some(r => r.server === 'local-1') ? 'local-1' : rows[0]?.server ?? '', server_list: rows };
    }
    syncSession(target, s, token) {
        const owner = this.auth.db.prepare('SELECT * FROM users WHERE id=?').get(s.user_id);
        target.db.exec('BEGIN IMMEDIATE');
        try {
            target.db.prepare('INSERT INTO users(id,username,password_hash,created_at,updated_at) VALUES(?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET password_hash=excluded.password_hash,updated_at=excluded.updated_at').run(owner.id, owner.username, owner.password_hash, owner.created_at, owner.updated_at);
            target.db.prepare('INSERT OR IGNORE INTO player_profiles(user_id,game_uid,role,created_at) VALUES(?,?,?,?)').run(s.user_id, 'local_player_' + s.user_id, '1', Date.now());
            target.db.prepare('INSERT INTO sessions(user_id,token_hash,created_at,expires_at) VALUES(?,?,?,?) ON CONFLICT(token_hash) DO UPDATE SET expires_at=excluded.expires_at').run(s.user_id, hashToken(token), Date.now(), s.expires_at);
            target.db.exec('COMMIT');
        }
        catch (e) {
            target.db.exec('ROLLBACK');
            throw e;
        }
    }
    syncGiftcodes(target, realm) {
        const kind = this.row(realm).kind;
        target.db.exec('BEGIN IMMEDIATE');
        try {
            for (const g of this.auth.db.prepare('SELECT * FROM giftcodes').all()) {
                const scope = this.auth.db.prepare('SELECT * FROM legacy_giftcode_scopes WHERE giftcode_id=?').get(g.id), allowed = scope ? (scope.scope === 'all' || scope.scope === kind) && (!JSON.parse(String(scope.realm_ids)).length || JSON.parse(String(scope.realm_ids)).includes(realm)) : realm === 'local-1';
                const a = this.auth.db.prepare('SELECT username,role,created_at FROM admin_users WHERE id=?').get(g.created_by);
                target.db.prepare('INSERT OR IGNORE INTO admin_users(id,username,password_hash,role,created_at) VALUES(?,?,?,?,?)').run(g.created_by, 'realm_disabled_' + g.created_by, '!disabled', a.role, a.created_at);
                const cols = Object.keys(g), values = cols.map(k => k === 'enabled' ? Number(!!g.enabled && allowed) : g[k]);
                target.db.prepare(`INSERT INTO giftcodes(${cols.join(',')}) VALUES(${cols.map(() => '?').join(',')}) ON CONFLICT(id) DO UPDATE SET ${cols.filter(k => k !== 'id').map(k => k + '=excluded.' + k).join(',')}`).run(...values);
            }
            target.db.exec('COMMIT');
        }
        catch (e) {
            target.db.exec('ROLLBACK');
            throw e;
        }
    }
    save(admin, b) {
        if (!/^local-[1-9][0-9]{0,3}$/.test(b.id) || typeof b.name !== 'string' || b.name.trim().length < 1 || b.name.length > 80 || !['test', 'official'].includes(b.kind) || !['open', 'closed'].includes(b.status))
            systemsFail('Thông tin server không hợp lệ.');
        this.auth.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.row(b.id);
            if (old && old.revision !== b.revision)
                systemsFail('Server đã được thay đổi; tải lại trước khi lưu.', 409);
            if (old)
                this.auth.db.prepare('UPDATE legacy_server_realms SET name=?,kind=?,status=?,revision=revision+1 WHERE id=?').run(b.name.trim(), b.kind, b.status, b.id);
            else
                this.auth.db.prepare('INSERT INTO legacy_server_realms VALUES(?,?,?,?,1,?)').run(b.id, b.name.trim(), b.kind, b.status, Date.now());
            audit(this.auth.db, admin, 'server.save', null, 'Quản lý server LOCAL với DB riêng', old ?? null, { id: b.id, name: b.name, kind: b.kind, status: b.status });
            this.auth.db.exec('COMMIT');
            return { ok: true };
        }
        catch (e) {
            this.auth.db.exec('ROLLBACK');
            throw e;
        }
    }
    scope(admin, id, b) { if (!['all', 'test', 'official'].includes(b.scope) || !Array.isArray(b.realmIds) || b.realmIds.length > 100 || new Set(b.realmIds).size !== b.realmIds.length || b.realmIds.some((id) => typeof id !== 'string' || !this.row(id)))
        systemsFail('Phạm vi Giftcode không hợp lệ.'); this.auth.db.exec('BEGIN IMMEDIATE'); try {
        const old = this.auth.db.prepare('SELECT * FROM legacy_giftcode_scopes WHERE giftcode_id=?').get(id);
        if ((old?.revision ?? 0) !== b.revision)
            systemsFail('Phạm vi vừa đổi; hãy tải lại.', 409);
        this.auth.db.prepare('INSERT INTO legacy_giftcode_scopes VALUES(?,?,?,1) ON CONFLICT(giftcode_id) DO UPDATE SET scope=excluded.scope,realm_ids=excluded.realm_ids,revision=revision+1').run(id, b.scope, JSON.stringify(b.realmIds));
        audit(this.auth.db, admin, 'giftcode.scope', null, 'Đổi phạm vi Giftcode LOCAL; quota độc lập mỗi server', old ?? null, { id, scope: b.scope, realmIds: b.realmIds });
        this.auth.db.exec('COMMIT');
        return { ok: true };
    }
    catch (e) {
        this.auth.db.exec('ROLLBACK');
        throw e;
    } }
}
export function registerRealmGateway(app, auth, options, factory) {
    if (options.online || options.realmChild)
        return;
    const manager = new RealmManager(auth, options, factory);
    app.addHook('onClose', async () => manager.close());
    app.addHook('preHandler', async (r, reply) => {
        const parsed = new URL(r.url, 'http://localhost'), match = /^\/realm\/(local-[1-9][0-9]{0,3})(\/.*)$/.exec(parsed.pathname);
        if (!match)
            return;
        if (!playerSystemsReady(auth.db))
            return reply.code(409).send({ error: 'Chưa áp extension LOCAL.' });
        const [, realm, path] = match, row = manager.row(realm), token = parsed.searchParams.get('rans'), s = auth.session(token);
        if (!row || row.status !== 'open' || realm === 'local-1')
            return reply.code(403).send({ error: 'Server chưa mở.' });
        if (!s || !['/api/', '/pub_abroad_vr/api/', '/login/', '/pub_abroad_vr/login/'].includes(path))
            return reply.code(403).send({ error: 'Phiên LOCAL/đường dẫn server không hợp lệ.' });
        const child = await manager.child(realm);
        manager.syncSession(child.auth, s, String(token));
        if (parsed.searchParams.get('method') === 'new_user') {
            if (parsed.searchParams.get('server_name') !== realm)
                return reply.code(403).send({ error: 'Sai server.' });
            parsed.searchParams.set('server_name', 'local-1');
        }
        if (parsed.searchParams.get('method')?.startsWith('code.'))
            manager.syncGiftcodes(child.auth, realm);
        const response = await child.app.inject({ method: r.method, url: path + parsed.search, headers: { host: '127.0.0.1:' + (options.port ?? 8787) }, ...(r.body ? { payload: r.body } : {}) });
        reply.code(response.statusCode).type(response.headers['content-type'] ?? 'application/json').send(response.rawPayload);
    });
    app.addHook('preHandler', async (r, reply) => {
        if (!playerSystemsReady(auth.db))
            return;
        const q = r.query, path = r.url.split('?')[0];
        if (!['/login/', '/pub_abroad_vr/login/', '/api/', '/pub_abroad_vr/api/'].includes(path))
            return;
        const s = auth.session(q.rans);
        if (!s)
            return;
        if (q.method === 'get_user_server_list') {
            if (q.account !== localAccount(s.user_id))
                return reply.code(403).send({ error: 'Account không khớp.' });
            return reply.send({ status: '0', data: await manager.serverList(s) });
        }
        if (!['get_user_server_list', 'platform_access'].includes(q.method) && manager.row('local-1')?.status !== 'open')
            return reply.code(403).send({ error: 'Server đang đóng.' });
        if (q.method === 'code.use_code') {
            const g = auth.db.prepare('SELECT id FROM giftcodes WHERE code=? COLLATE NOCASE').get(String(q.code ?? '').trim()), scope = g ? auth.db.prepare('SELECT * FROM legacy_giftcode_scopes WHERE giftcode_id=?').get(g.id) : undefined;
            if (scope && (!['all', manager.row('local-1').kind].includes(String(scope.scope)) || JSON.parse(String(scope.realm_ids)).length && !JSON.parse(String(scope.realm_ids)).includes('local-1')))
                return reply.send({ status: 'LOCAL_CODE_SCOPE', msg: 'Giftcode không áp dụng cho server này.' });
        }
    });
}
