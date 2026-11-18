import { registerRegistrationSecurityAdmin } from './registration-security.routes.js';
import { registerRechargeAdmin } from '../recharge/recharge.routes.js';
import { registerPlayerSystemsAdmin } from '../player-systems/player-systems.routes.js';
import { registerWelfareAdmin } from '../welfare/welfare.routes.js';
import { registerVnext } from './vnext.routes.js';
import { registerHotAdmin } from './hot.routes.js';
import { PetService } from '../player/pet.service.js';
import { petProof } from '../player/pet-source.js';
import { createHash } from 'node:crypto';
import { AllianceCenter } from './alliance-center.js';
import { inventoryCapacity } from '../player/inventory-capacity.js';
import { AllianceService } from '../player/alliance.service.js';
import { HomelandService } from '../player/homeland.service.js';
import { BeastService } from '../player/beast.service.js';
import { beastConfig } from '../player/beast-source.js';
import { GodfieldService } from '../player/godfield.service.js';
import { GodfieldLeagueService } from '../player/godfield-league.js';
import { GodfieldTempleService } from '../player/godfield-temple.js';
import { GodfieldZodiacService } from '../player/godfield-zodiac.js';
import { GodfieldHighwayService } from '../player/godfield-highway.js';
import { FriendsService } from '../player/friends.service.js';
import { ShopService } from '../player/shop.service.js';
import { TutorialService } from '../player/tutorial.js';
import { inheritancePreview } from '../player/inheritance.js';
import { BackupStore, persistentBackupFiles } from '../system/backup.js';
import { HeroResetService } from '../player/hero-reset.js';
import { AuxiliaryService } from '../player/auxiliary.service.js';
import { transformationGraph } from '../player/transformation-graph.js';
import { readConfigSync } from '../player/local-content.js';
import { transformedMailPreset, transformedRepairPreview } from '../player/transformed-mail.js';
import { FormationSystemsService } from '../player/formation-systems.js';
import { FateEmpowermentService } from '../player/fate-empowerment.js';
import { combatRegistryAudit, heroCombatDiagnostics } from '../player/combat-diagnostics.js';
import { vnSourceCatalog } from '../player/vn-source-index.js';
import { runtimeContentIndex } from '../player/runtime-content-index.js';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join, resolve, extname } from 'node:path';
import { AdminAuth, cookieToken, csrfFor, constantEqual } from './admin.auth.js';
import { AdminService } from './admin.service.js';
import { VipStoreService } from '../player/vip-store.service.js';
import { AppearanceService } from '../player/appearance.service.js';
import { ProgressionEconomyService } from '../player/progression-economy.js';
import { EventCalendarService } from '../player/event-calendar.js';
import { ExchangeService } from '../player/exchange.service.js';
import { RebirthShopService } from '../player/rebirth-shop.js';
import { EquipmentDestinyService } from '../player/equipment-destiny.js';
import { LocalRechargeService } from '../player/local-recharge.service.js';
import { adminError } from './admin.audit.js';
import { schemas } from './admin.schemas.js';
import { battleEvidence } from './battle-evidence.js';
import { ArenaCombatService, arenaPolicy } from '../player/arena-combat.js';
import { CombatPowerService } from '../player/combat-power.js';
import { progressionConfig } from '../player/progression.js';
import { staticConfig } from '../player/player.service.js';
import { ArenaService } from '../player/arena.service.js';
import { GiftcodeService } from '../player/giftcode.service.js';
import { NewstarService } from '../player/newstar.service.js';
import { battlePreflight } from '../player/battle-preflight.js';
export function registerAdmin(app, db, options) {
    const remoteAdmin = process.env.ALLOW_REMOTE_ADMIN === '1';
    const origin = new URL(options.origin ?? `http://127.0.0.1:${options.port}`);
    if (((options.online || remoteAdmin) ? origin.protocol !== 'https:' : !['127.0.0.1', 'localhost'].includes(origin.hostname)) || !['http:', 'https:'].includes(origin.protocol) || origin.username || origin.password || origin.pathname !== '/' || origin.search || origin.hash)
        throw new Error('ADMIN_ORIGIN cần origin hợp lệ; ONLINE bắt buộc HTTPS.');
    const origins = new Set([origin.origin, `http://localhost:${options.port}`, ...(options.dev ? ['http://127.0.0.1:5173', 'http://localhost:5173'] : [])]);
    const hosts = new Set([origin.host, `127.0.0.1:${options.port}`, `localhost:${options.port}`]);
    const auth = new AdminAuth(db), service = new AdminService(db, options.dbPath, options.journalPath);
    const backups = new BackupStore(db, { directory: options.backupDirectory ?? resolve(options.dbPath, '../backups-secure'), environment: options.online ? 'ONLINE' : 'LOCAL', dataFiles: persistentBackupFiles() });
    const webRoot = fileURLToPath(new URL('../../../admin/dist/', import.meta.url));
    const imageRoot = fileURLToPath(new URL('../../../admin/public/portraits/', import.meta.url));
    const cookie = (token, maxAge) => `sahht_admin=${token}; Path=/admin; HttpOnly; SameSite=Strict; Max-Age=${maxAge}${origin.protocol === 'https:' ? '; Secure' : ''}`;
    return app.register(async (admin) => {
        admin.addHook('onRoute', route => { route.bodyLimit ??= 16_384; });
        admin.setErrorHandler((error, _request, reply) => {
            const code = error.statusCode ?? 500;
            const invalidMail = _request.url.split('?')[0].endsWith('/mail') && error.validation;
            const invalidGiftcode = /^\/admin\/api\/giftcodes(?:\/batch)?$/.test(_request.url.split('?')[0]) && error.validation;
            reply.code(code >= 400 && code < 500 ? code : 503).send({ ok: false, message: code >= 500 ? 'Không thể thực hiện thao tác. Dữ liệu chưa được xác nhận thay đổi.' : invalidGiftcode ? 'Giftcode không hợp lệ: kiểm tra mã, thời gian và1–10 dòng thưởng; chọn tài nguyên đã hỗ trợ, số nguyên dương tối đa100.000.000 mỗi dòng; tướng/trang bị tối đa5.' : invalidMail ? 'Thư không hợp lệ: kiểm tra loại đính kèm và số nguyên dương; tài nguyên tối đa100.000.000, vật phẩm1.000.000, tướng/trang bị5 mỗi dòng.' : error.validation ? 'Yêu cầu không hợp lệ. Kiểm tra các giá trị đã nhập.' : error.message });
        });
        admin.addHook('onRequest', async (request, reply) => {
            reply.header('Cache-Control', 'no-store').header('X-Content-Type-Options', 'nosniff').header('Referrer-Policy', 'same-origin').header('X-Frame-Options', 'DENY')
                .header('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; object-src 'none'; base-uri 'none'; form-action 'self'");
            const peer = options.online ? request.raw.socket.remoteAddress : request.ip;
            if ((!remoteAdmin && !['127.0.0.1', '::1', '::ffff:127.0.0.1'].includes(peer ?? '')) || !hosts.has((request.headers.host ?? '').toLowerCase()))
                adminError('Nguồn truy cập quản trị không hợp lệ.', 403);
            const unsafe = !['GET', 'HEAD'].includes(request.method);
            if (unsafe && (!origins.has(String(request.headers.origin)) || String(request.headers['sec-fetch-site'] ?? '') === 'cross-site'))
                adminError('Nguồn yêu cầu không hợp lệ.', 403);
            if (unsafe && !String(request.headers['content-type']).startsWith('application/json'))
                adminError('Yêu cầu quản trị cần JSON.', 415);
            const path = request.url.split('?')[0];
            if (path.startsWith('/admin/api/') && path !== '/admin/api/login') {
                const secret = cookieToken(request.headers.cookie), current = auth.session(secret);
                if (!current)
                    adminError('Phiên quản trị đã hết hạn. Vui lòng đăng nhập.', 401);
                request.adminIdentity = current;
                if (unsafe && !constantEqual(String(request.headers['x-csrf-token'] ?? ''), csrfFor(secret)))
                    adminError('Phiên xác nhận không hợp lệ. Hãy tải lại trang.', 403);
            }
        });
        admin.addHook('preValidation', async (request) => {
            const body = request.body, schema = request.routeOptions.schema?.body;
            if (schema?.properties && body && typeof body === 'object' && !Array.isArray(body) && Object.keys(body).some(k => !Object.hasOwn(schema.properties, k)))
                adminError('Yêu cầu chứa trường chưa được hỗ trợ.', 400);
        });
        admin.addHook('preHandler', async (request) => {
            const required = request.routeOptions.config.adminPermission, current = request.adminIdentity;
            if (required && (!current || current.role === 'VIEWER' || (required === 'owner' && current.role !== 'OWNER')))
                adminError('Bạn không có quyền thực hiện thao tác này.', 403);
            if (options.online && !['GET', 'HEAD'].includes(request.method)) {
                const path = request.url.split('?')[0];
                // ONLINE dùng cùng API GM đã kiểm của LOCAL, chỉ OWNER/ADMIN có quyền ghi.
                // Endpoint ghi mới phải khai báo quyền rõ ràng; không mở ngầm cho VIEWER/người chơi.
                if (!['/admin/api/login', '/admin/api/logout'].includes(path) &&
                    (!required || !current || !['OWNER', 'ADMIN'].includes(current.role)))
                    adminError('Chỉ OWNER/ADMIN được thực hiện thao tác GM.', 403);
            }
        });
        admin.post('/api/login', { bodyLimit: 4096, schema: { body: schemas.login } }, async (request, reply) => {
            const b = request.body, result = await auth.login(b.username, b.password, request.ip);
            reply.header('Set-Cookie', cookie(result.secret, 8 * 60 * 60));
            return { ok: true, admin: result.admin, csrfToken: result.csrfToken, expiresAt: result.expiresAt };
        });
        registerHotAdmin(admin, db, !!options.online, !!options.onlineUnified);
        registerWelfareAdmin(admin, db, !!options.online, !!options.onlineUnified);
        registerPlayerSystemsAdmin(admin, db, !!options.online, !!options.onlineUnified);
        registerRechargeAdmin(admin, db, !!options.online, !!options.onlineUnified);
        registerRegistrationSecurityAdmin(admin, db, !!options.online && !options.onlineUnified);
        const allianceCenter = new AllianceCenter(db, options.online ? [] : undefined);
        admin.get('/api/alliance-center/realms', async () => { if (options.online && !options.onlineUnified)
            adminError('Trung tâm mới chỉ mở LOCAL.', 403); return { realms: allianceCenter.realms() }; });
        admin.get('/api/alliance-center/guilds', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Chỉ đọc registry LOCAL.', 403); return allianceCenter.directory(request.query); });
        admin.get('/api/alliance-center/guilds/:realm/:guild', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Chỉ mở LOCAL.', 403); const p = request.params; return allianceCenter.detail(p.realm, Number(p.guild)); });
        admin.get('/api/alliance-center/aether', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Aether chỉ mở LOCAL.', 403); return { ...allianceCenter.dashboard(request.query), ...(options.online ? { qaEnabled: false } : {}), scheduleEnabled: !options.online || options.onlineUnified === true }; });
        admin.get('/api/alliance-center/battles/:realm/:id', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Biên bản mới chỉ mở LOCAL.', 403); const p = request.params; return allianceCenter.battle(p.realm, p.id); });
        admin.post('/api/alliance-center/qa', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'action'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 120 }, action: { enum: ['create', 'phase', 'enroll', 'city', 'material', 'material_mail', 'retry_war', 'sim_credit', 'close'] }, warId: { type: 'string', minLength: 1, maxLength: 300 }, version: { type: 'integer' }, step: { type: 'integer' }, day: { type: 'integer' }, guildId: { type: 'integer' }, groupId: { type: 'integer' }, cityId: { type: 'integer' }, userId: { type: 'integer' }, configId: { type: 'integer' }, quantity: { type: 'integer' }, slot: { type: 'integer' } } } } }, async (request) => { if (options.online)
            adminError('Không cho QA trên ONLINE.', 403); return allianceCenter.qa(request.adminIdentity.id, request.body); });
        admin.post('/api/alliance-center/schedule', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'action'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 120 }, action: { enum: ['create', 'enroll', 'city'] }, version: { type: 'integer' }, startDate: { type: 'string', pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' }, guildId: { type: 'integer' }, groupId: { type: 'integer' }, slot: { type: 'integer' }, cityId: { type: 'integer' } } } } }, async (request) => { if (options.online && !options.onlineUnified)
            adminError('Chưa được phê duyệt quản lý Aether ONLINE.', 403); return allianceCenter.organize(request.adminIdentity.id, request.body); });
        admin.get('/api/session', async (request) => ({ ok: true, admin: request.adminIdentity, csrfToken: csrfFor(cookieToken(request.headers.cookie)) }));
        admin.post('/api/logout', { schema: { body: schemas.empty } }, async (request, reply) => { auth.logout(cookieToken(request.headers.cookie), request.adminIdentity); reply.header('Set-Cookie', cookie('', 0)); return { ok: true }; });
        registerVnext(admin, db, service, options.online === true);
        admin.get('/api/dashboard', async () => service.dashboard());
        const gifts = new GiftcodeService(db);
        admin.get('/api/giftcodes', async (r) => gifts.list(r.query));
        admin.get('/api/giftcodes/:id/history', async (r) => gifts.history(Number(r.params.id)));
        admin.post('/api/giftcodes', { config: { adminPermission: 'write' }, schema: { body: schemas.giftcode } }, async (r) => gifts.create(r.adminIdentity.id, r.body));
        admin.post('/api/giftcodes/batch', { config: { adminPermission: 'write' }, schema: { body: schemas.giftcodeBatch } }, async (r) => gifts.batch(r.adminIdentity.id, r.body));
        admin.post('/api/giftcodes/:id/status', { config: { adminPermission: 'write' }, schema: { body: schemas.giftcodeStatus } }, async (r) => gifts.toggle(r.adminIdentity.id, Number(r.params.id), r.body.enabled));
        admin.get('/api/battle-tests', async () => ({ ...battleEvidence, contract: await readFile(new URL('../../../work/generated/battle_contract.json', import.meta.url), 'utf8').then(JSON.parse).catch(error => { if (error.code === 'ENOENT')
                return { evidence: 'UNKNOWN', notice: 'Chạy tools/runtime/inspect_battle_contract.py để tạo chỉ mục.' }; throw error; }) }));
        admin.get('/api/progression', async () => progressionConfig());
        admin.post('/api/players/:id/roster-capacity', { config: { adminPermission: 'write' }, schema: { body: schemas.rosterCapacity } }, async (request) => service.rosterCapacity(request.adminIdentity, id(request), request.body.capacity));
        admin.get('/api/events/newstar', async () => new NewstarService(db).info());
        admin.post('/api/events/newstar/schedule', { config: { adminPermission: 'write' }, schema: { body: schemas.activitySchedule } }, async (request) => new NewstarService(db).schedule(request.adminIdentity.id, request.body));
        admin.get('/api/catalog/heroes/:id', async (request) => service.heroInspector(id(request)));
        admin.get('/api/content', async () => service.contentDiagnostics());
        admin.get('/api/players/:id/tutorial', async (r) => new TutorialService(db).diagnostics(id(r)));
        admin.post('/api/players/:id/tutorial/replay', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (r) => new TutorialService(db).reset(r.adminIdentity.id, id(r), r.body.confirmed));
        admin.get('/api/players/:id/inheritance-preview', async (r) => { const q = r.query; return inheritancePreview(db, id(r), String(q.sourceId ?? ''), String(q.targetId ?? ''), q.useOrb === '1'); });
        admin.get('/api/catalog/transformed-mail', async () => ({ relationships: transformationGraph.map(e => ({ sourceId: e.sourceId, targetId: e.targetId, sourceName: readConfigSync('character_detail')[e.sourceId]?.name, targetName: readConfigSync('character_detail')[e.targetId]?.name, coefficient: e.inheritance?.coefficient, hasFormula: !!e.inheritance })) }));
        admin.get('/api/players/:id/heroes/:heroId/transformation-repair-preview', async (r) => transformedRepairPreview(db, id(r), r.params.heroId, Number(r.query.sourceId)));
        admin.get('/api/players/:id/auxiliary', async (r) => new AuxiliaryService(db).diagnostics(id(r)));
        admin.get('/api/players/:id/heroes/:heroId/reset-preview', async (r) => new HeroResetService(db).preview(id(r), r.params.heroId));
        admin.get('/api/catalog/transformed-mail/:id', async (r) => transformedMailPreset(id(r), Number(r.query.sourceId)));
        admin.get('/api/players/:id/formation-systems', async (r) => new FormationSystemsService(db).diagnostics(id(r)));
        admin.post('/api/players/:id/formation-systems', { config: { adminPermission: 'write' }, schema: { body: schemas.formationSlots } }, async (r) => { const b = r.body; return new FormationSystemsService(db).qa(r.adminIdentity.id, id(r), b.systems, b.restore); });
        admin.get('/api/players/:id/map', async (request) => service.mapInfo(id(request)));
        admin.post('/api/players/:id/map/unlock', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.unlockMap(request.adminIdentity, id(request)));
        admin.post('/api/players/:id/map/reset', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.resetMap(request.adminIdentity, id(request)));
        admin.post('/api/players/:id/map/complete', { config: { adminPermission: 'write' }, schema: { body: schemas.mapCompletion } }, async (request) => service.completeMap(request.adminIdentity, id(request), request.body.formationOverride));
        admin.post('/api/players/:id/map/complete-features', { config: { adminPermission: 'write' }, schema: { body: schemas.mapCompletion } }, async (request) => service.completeMap(request.adminIdentity, id(request), request.body.formationOverride, true));
        admin.post('/api/players/:id/map/restore', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.restoreMap(request.adminIdentity, id(request)));
        admin.get('/api/catalog/hero-resources', async (request) => service.heroResourceCatalog(request.query));
        admin.get('/api/catalog/hero-unlinked', async (request) => service.unlinkedHeroes(request.query));
        admin.get('/api/catalog/vn-source', async (request) => vnSourceCatalog(request.query));
        admin.get('/api/catalog/hero-recovery', async (request) => service.recoveredHeroes(request.query));
        admin.get('/api/catalog/skills', async (request) => service.skillCatalog(request.query));
        admin.get('/api/combat-audit', async (request) => { const audit = await combatRegistryAudit(), q = String(request.query.q ?? '').toLocaleLowerCase('vi'), rows = audit.heroes.filter((h) => !q || String(h.configId).includes(q) || h.name.toLocaleLowerCase('vi').includes(q)); return { ...audit, heroes: rows.slice(0, 20), matchingHeroes: rows.length }; });
        admin.get('/api/players/:id/heroes/:heroId/combat', async (request) => heroCombatDiagnostics(db, id(request), request.params.heroId));
        admin.get('/api/activities', async () => ({ evidence: 'STATIC VERIFIED', status: 'PARTIAL', scope: 'Catalog combat chỉ đọc/0 lượt. Vật tư sinh tồn có claim50 thể lực theo lịch LOCAL TEST riêng; không thay lịch gốc.', ...service.activityInfo(), activities: await staticConfig('active'), chapters: await staticConfig('active_chapter'), historicalSchedules: await staticConfig('active_show') }));
        admin.post('/api/activities/10/settings', { config: { adminPermission: 'write' }, schema: { body: schemas.activitySchedule } }, async (request) => service.setActivitySchedule(request.adminIdentity, request.body));
        admin.get('/api/arena', async () => ({ evidence: 'LOCAL TEST IMPLEMENTATION', scope: arenaPolicy.notice, opponents: new ArenaService(db).pool().map(p => ({ ...p, ...new ArenaCombatService(db).status(p.userId) })), battleStatus: 'SERVER VERIFIED' }));
        admin.get('/api/runtime-content', async (r) => runtimeContentIndex(r.query));
        admin.get('/api/players/:id/arena', async (r) => ({ policy: arenaPolicy, status: new ArenaCombatService(db).status(id(r)), history: new ArenaCombatService(db).history(id(r)), power: new CombatPowerService(db).calculate(id(r)) }));
        admin.post('/api/players/:id/arena/reset', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (r) => new ArenaCombatService(db).reset(id(r), r.adminIdentity.id));
        admin.post('/api/players/:id/arena/exhaust', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (r) => new ArenaCombatService(db).reset(id(r), r.adminIdentity.id, true));
        admin.post('/api/players/:id/arena/restore', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (r) => new ArenaCombatService(db).restore(id(r), r.adminIdentity.id));
        admin.post('/api/players/:id/hero-preset', { config: { adminPermission: 'write' }, schema: { body: schemas.heroPreset } }, async (request) => { const b = request.body; return service.grantPreset(request.adminIdentity, id(request), b.count, b.type); });
        admin.post('/api/players/:id/level', { config: { adminPermission: 'write' }, schema: { body: schemas.level } }, async (request) => service.setLevel(request.adminIdentity, id(request), request.body.level));
        admin.post('/api/players/:id/vip', { config: { adminPermission: 'write' }, schema: { body: schemas.vip } }, async (request) => service.setVip(request.adminIdentity, id(request), request.body.vip));
        admin.get('/api/players', async (request) => service.listPlayers(request.query));
        const id = (r) => { const value = String(r.params.id); if (!/^[1-9][0-9]{0,9}$/.test(value))
            adminError('ID tài khoản không hợp lệ.'); return Number(value); };
        admin.get('/api/players/:id/vip-store', async (request) => new VipStoreService(db).diagnostics({ user_id: id(request) }));
        admin.get('/api/players/:id/appearance', async (request) => new AppearanceService(db).catalog({ user_id: id(request) }));
        admin.get('/api/players/:id/fate-empowerment', async (request) => new FateEmpowermentService(db).catalog(id(request)));
        admin.get('/api/players/:id/alliance', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Liên Minh mới chỉ đang kiểm LOCAL.', 403); return new AllianceService(db).diagnostics(id(request)); });
        admin.get('/api/players/:id/homeland', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Farm đang kiểm LOCAL.', 403); return { ...new HomelandService(db).diagnostics(id(request)), qaAllowed: !options.online }; });
        admin.get('/api/players/:id/pets', async (request) => { if (options.online && !options.onlineUnified)
            adminError('PET đang kiểm LOCAL.', 403); return new PetService(db).diagnostics(id(request)); });
        admin.get('/api/pets/:configId/icon', async (request, reply) => { if (options.online && !options.onlineUnified)
            adminError('PET đang kiểm LOCAL.', 403); const cid = String(request.params.configId); if (!/^\d{2,5}$/.test(cid))
            return reply.code(404).send(); const proof = petProof().adminIcons[cid]; if (!proof)
            return reply.code(404).send(); const raw = await readFile(new URL('../../../' + proof.path, import.meta.url)); if (createHash('sha256').update(raw).digest('hex') !== proof.sha256)
            throw Error('Biểu tượng PET không khớp nguồn VN.'); return reply.type('image/png').header('Cache-Control', 'private, max-age=3600').send(raw); });
        admin.get('/api/players/:id/beasts', async (request) => { if (options.online && !options.onlineUnified)
            adminError('Thần Thú đang kiểm LOCAL.', 403); return { ...new BeastService(db).diagnostics(id(request)), qaAllowed: !options.online }; });
        admin.post('/api/players/:id/beasts-material-mail', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'beast'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 150 }, beast: { type: 'integer', enum: [1, 2, 3, 4, 5, 6, 7] } } } } }, async (request) => {
            if (options.online)
                adminError('Không chuẩn bị nguyên liệu QA trên ONLINE.', 403);
            const b = request.body, c = beastConfig('combiner')[b.beast], attachments = c.combine_card.map((r, i) => ({ kind: 'hero', configId: r[1], quantity: i === 0 ? 3 : 1 }));
            attachments.push({ kind: 'item', configId: 262, quantity: 4 });
            const mails = [];
            // Giữ trần ba dòng/thư của hệ Mail hiện có. Mỗi phần có key ổn định để tiếp tục an toàn nếu kết nối mất giữa chừng.
            for (let i = 0; i < attachments.length; i += 3)
                mails.push(await service.sendMail(request.adminIdentity, id(request), `LOCAL QA · ${c.name} · ${i / 3 + 1}/2`, 'Bộ thẻ gốc để triệu hồi, 2 thẻ bổ sung để kiểm tăng cấp/nâng thẻ và 4 nguyên liệu #262. Chỉ cấp khi người chơi tự nhận thư; không tiêu hoặc nâng hộ.', attachments.slice(i, i + 3), b.requestId + ':' + i));
            return { ok: true, mails };
        });
        admin.post('/api/players/:id/beasts-advancement-mail', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'beast'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 150 }, beast: { type: 'integer', minimum: 1, maximum: 7 } } } } }, async (request) => {
            if (options.online)
                adminError('Không chuẩn bị tiến cấp trên ONLINE.', 403);
            const b = request.body, owned = new BeastService(db).index(id(request), false).fable_beasts[b.beast], plan = owned?.advancement;
            if (!owned?.is_open || !plan || plan.max || plan.ready)
                adminError('Thú chưa triệu hồi, đã tối đa hoặc đã đủ phẩm; không cần gửi thêm bộ này.');
            const attachments = [];
            for (const [kind, configId, quantity] of plan.materialCosts) {
                if (![1, 2, 5, 6].includes(kind))
                    adminError('Chi phí nguồn chưa có hợp đồng Mail.');
                let left = quantity;
                while (left > 0) {
                    const count = Math.min(left, kind === 5 ? 5 : kind === 6 ? 9999 : 100000000);
                    attachments.push(kind === 5 || kind === 6 ? { kind: kind === 5 ? 'hero' : 'item', configId, quantity: count } : { kind: 'currency', currency: kind === 1 ? 'food' : 'metal', quantity: count });
                    left -= count;
                }
            }
            const mails = [];
            for (let i = 0; i < attachments.length; i += 3)
                mails.push(await service.sendMail(request.adminIdentity, id(request), `LOCAL QA · Tiến cấp ${beastConfig('combiner')[b.beast].name}`, 'Nguyên liệu theo các mốc nâng năm thẻ hiện tại. Không trừ tài sản, nâng cấp hoặc đặt chỉ số hộ; người chơi tự nhận và nâng từng thẻ trong game.', attachments.slice(i, i + 3), b.requestId + ':' + i));
            return { ok: true, mails, plan };
        });
        admin.post('/api/players/:id/homeland-mature', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'plot'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, plot: { type: 'integer', minimum: 1, maximum: 4 } } } } }, async (request) => { if (options.online)
            adminError('Không làm chín QA trên ONLINE.', 403); const b = request.body; return new HomelandService(db).matureQa(request.adminIdentity.id, id(request), b.requestId, b.plot); });
        admin.get('/api/players/:id/than-vuc', async (request) => ({ ...new GodfieldService(db).diagnostics(id(request)), league: new GodfieldLeagueService(db).diagnostics(id(request)), temple: new GodfieldTempleService(db).diagnostics(id(request)), zodiac: new GodfieldZodiacService(db).diagnostics(id(request)), highway: new GodfieldHighwayService(db).diagnostics(id(request), !options.online), qaAllowed: !options.online }));
        admin.get('/api/players/:id/than-vuc/highway-level-preview', { schema: { querystring: { type: 'object', additionalProperties: false, required: ['total', 'added'], properties: { total: { type: 'integer', minimum: 0, maximum: Number.MAX_SAFE_INTEGER }, added: { type: 'integer', minimum: 0, maximum: Number.MAX_SAFE_INTEGER } } } } }, async (request) => { if (options.online)
            adminError('Không xem thử góp tàu QA trên ONLINE.', 403); const q = request.query; return new GodfieldHighwayService(db).levelPreview(id(request), q.total, q.added); });
        admin.post('/api/players/:id/than-vuc/highway-qa-contribution', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'area', 'ship', 'amount'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, area: { type: 'integer', minimum: 1, maximum: 6 }, ship: { type: 'integer', minimum: 1, maximum: 8 }, amount: { type: 'integer', minimum: 1, maximum: 140580 } } } } }, async (request) => { if (options.online)
            adminError('Không góp mô phỏng tàu trên ONLINE.', 403); const b = request.body; return new GodfieldHighwayService(db).prepareQaContribution(request.adminIdentity.id, id(request), b.requestId, b.area, b.ship, b.amount); });
        admin.get('/api/players/:id/than-vuc/highway-play', async (request) => { if (options.online)
            adminError('Chỉ xem vòng cược mô phỏng trên LOCAL.', 403); return new GodfieldHighwayService(db).play().diagnostics(id(request)); });
        admin.post('/api/players/:id/than-vuc/highway-play-resources', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 } } } } }, async (request) => { if (options.online)
            adminError('Không cấp tài nguyên đua QA trên ONLINE.', 403); const b = request.body; return new GodfieldHighwayService(db).play().prepareResources(request.adminIdentity.id, id(request), b.requestId); });
        admin.post('/api/players/:id/than-vuc/highway-play-round', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'rate'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, rate: { type: 'integer', enum: [1, 6] } } } } }, async (request) => { if (options.online)
            adminError('Không mở cược QA trên ONLINE.', 403); const b = request.body; return new GodfieldHighwayService(db).play().startQa(request.adminIdentity.id, id(request), b.requestId, b.rate); });
        admin.post('/api/players/:id/than-vuc/zodiac-income-qa', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'team'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, team: { type: 'integer', minimum: 1, maximum: 3 } } } } }, async (request) => { if (options.online)
            adminError('Không mô phỏng12Cung trên ONLINE.', 403); const b = request.body; return new GodfieldZodiacService(db).prepareQaIncome(request.adminIdentity.id, id(request), b.requestId, b.team); });
        admin.post('/api/players/:id/than-vuc/temple-honor', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'team', 'amount'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, team: { type: 'integer', minimum: 1, maximum: 3 }, amount: { type: 'integer', minimum: 0, maximum: 10000 } } } } }, async (request) => { if (options.online)
            adminError('Không cấp QA Thần Điện trên ONLINE.', 403); const b = request.body; return new GodfieldTempleService(db).prepareQa(request.adminIdentity.id, id(request), b.requestId, b.team, b.amount); });
        admin.get('/api/than-vuc/icon/:kind/:configId', async (request, reply) => { const p = request.params; if (!['5', '6'].includes(p.kind) || !/^\d{1,8}$/.test(p.configId))
            return reply.code(404).send({ error: 'Không có biểu tượng này.' }); const cfg = readConfigSync(p.kind === '5' ? 'character_detail' : 'item')[p.configId], name = cfg?.img ?? cfg?.icon; if (typeof name !== 'string' || !/^[-a-zA-Z0-9_]+\.png$/.test(name))
            return reply.code(404).send({ error: 'Thiếu tên biểu tượng nguồn.' }); for (const path of ['com.kaiqigu.cjyxyn.kvsdk/files/Resources/iphonehd/icon/', 'work/apk/assets/iphonehd/icon/'])
            try {
                const bytes = await readFile(new URL('../../../' + path + name, import.meta.url));
                return reply.type('image/png').header('Cache-Control', 'private, max-age=3600').send(bytes);
            }
            catch { } return reply.code(404).send({ error: 'Chưa có tệp biểu tượng trong nguồn LOCAL.' }); });
        admin.post('/api/than-vuc/clock', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'at'], properties: { confirmed: { const: true }, at: { type: ['integer', 'null'], minimum: 0 } } } } }, async (request) => { if (options.online)
            adminError('Không mô phỏng thời gian trên ONLINE.', 403); return new GodfieldLeagueService(db).setQaClock(request.adminIdentity.id, request.body.at); });
        admin.post('/api/players/:id/than-vuc/prepare', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'integration', 'godIntegration'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, integration: { type: 'integer', minimum: 0, maximum: 10000 }, godIntegration: { type: 'integer', minimum: 0, maximum: 10000 } } } } }, async (request) => { if (options.online)
            adminError('Không cấp tài nguyên QA trên ONLINE.', 403); const b = request.body; return new GodfieldLeagueService(db).prepareQa(request.adminIdentity.id, id(request), b.requestId, b.integration, b.godIntegration); });
        admin.get('/api/players/:id/phase30', async (request) => { const uid = id(request), s = { user_id: uid }, rebirth = new RebirthShopService(db), arena = new ArenaCombatService(db); return { capacities: inventoryCapacity(db, uid), shop: new ShopService(db).diagnostics(s), rebirth: rebirth.catalog(s), dependencies: rebirth.dependencies([44200, 84500]), arena: { rank: arena.rank(uid), candidates: arena.candidates(uid).map(r => ({ uid: r.game_uid, rank: r.rank })), history: arena.history(uid), policy: arenaPolicy.notice }, friends: new FriendsService(db).diagnostics(uid) }; });
        admin.get('/api/players/:id/economy', async (request) => { const s = { user_id: id(request) }, svc = new ProgressionEconomyService(db), items = await staticConfig('item'), boxes = new EquipmentDestinyService(db); return { progression: svc.catalog(s), calendar: new EventCalendarService(db).preview(svc.profile(s).level ?? 1, undefined, svc.profile(s).vip ?? 0), exchange: new ExchangeService(db).catalog(s), shop: new RebirthShopService(db).catalog(s), materials: Object.entries(items).filter(([, r]) => r.is_use === 19 || /chiến tranh|hủy thiên|siêu tiến hóa|đột phá/i.test(r.name)).map(([id, r]) => { let reward = null, blockedReason = ''; if (r.is_use !== 19)
                try {
                    reward = boxes.voucher(Number(id));
                }
                catch (e) {
                    blockedReason = e.message;
                } return { id: Number(id), name: r.name, icon: r.icon, exp: r.is_use === 19 ? r.use_effect[0] : null, reward, blockedReason }; }) }; });
        admin.post('/api/calendar/override', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'key', 'enabled', 'startsAt', 'endsAt'], properties: { confirmed: { const: true }, key: { type: 'string', maxLength: 50 }, enabled: { type: ['boolean', 'null'] }, startsAt: { type: 'integer', minimum: 0 }, endsAt: { type: 'integer', minimum: 0 } } } } }, async (request) => { const b = request.body; new EventCalendarService(db).setOverride(request.adminIdentity.id, b.key, b.enabled, b.startsAt, b.endsAt); return { ok: true }; });
        admin.post('/api/players/:id/appearance', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'action', 'heroId', 'requestId'], properties: { confirmed: { const: true }, action: { enum: ['prepare_qa', 'transform', 'restore_qa', 'grant_qa_materials', 'repair_inheritance'] }, heroId: { type: 'string', minLength: 1, maxLength: 80 }, targetId: { type: 'integer', minimum: 1, maximum: 9999999 }, requestId: { type: 'string', minLength: 8, maxLength: 160 } } } } }, async (request) => {
            const b = request.body, s = { user_id: id(request) }, service = new AppearanceService(db);
            return b.action === 'repair_inheritance' ? service.repairInheritance(s, b.heroId, request.adminIdentity.id, b.requestId) : b.action === 'grant_qa_materials' ? service.grantQaMaterials(s, b.heroId, request.adminIdentity.id, b.requestId) : b.action === 'prepare_qa' ? service.prepareQa(s, b.heroId, request.adminIdentity.id, b.requestId) : b.action === 'restore_qa' ? service.restoreQa(s, b.heroId, request.adminIdentity.id, b.requestId) : service.transform(s, b.heroId, b.targetId, b.requestId, request.adminIdentity.id);
        });
        admin.get('/api/players/:id/local-recharge', async (request) => new LocalRechargeService(db).info({ user_id: id(request) }));
        admin.post('/api/vip-store/:id/settings', { config: { adminPermission: 'write' }, schema: { body: { type: 'object', required: ['enabled', 'price', 'quota'], additionalProperties: false, properties: { enabled: { type: 'boolean' }, price: { type: 'integer', minimum: 1, maximum: 100000000 }, quota: { type: 'integer', minimum: 1, maximum: 9999 } } } } }, async (request) => new VipStoreService(db).settings(request.adminIdentity.id, String(request.params.id), request.body));
        admin.get('/api/players/:id/equipment-destiny', async (request) => service.equipmentDestinyInfo(id(request)));
        admin.post('/api/players/:id/equipment-destiny', { config: { adminPermission: 'write' }, schema: { body: schemas.equipmentDestiny } }, async (request) => service.equipmentDestinyAction(request.adminIdentity, id(request), request.body));
        admin.get('/api/players/:id', async (request) => service.detail(id(request)));
        admin.get('/api/players/:id/battle-preflight', async (request) => battlePreflight(db, id(request), request.query));
        admin.get('/api/players/:id/welfare', async (request) => service.welfareInfo(id(request)));
        admin.post('/api/players/:id/welfare', { config: { adminPermission: 'write' }, schema: { body: schemas.welfare } }, async (request) => { const b = request.body; return service.setWelfareEnabled(request.adminIdentity, id(request), b.system, b.enabled); });
        for (const kind of ['heroes', 'items', 'equipment'])
            admin.get(`/api/catalog/${kind}`, async (request) => service.catalog(kind, request.query));
        admin.patch('/api/players/:id/profile', { config: { adminPermission: 'write' }, schema: { body: schemas.profile } }, async (request) => service.updateProfile(request.adminIdentity, id(request), request.body.show_name));
        admin.post('/api/players/:id/currency', { config: { adminPermission: 'write' }, schema: { body: schemas.currency } }, async (request) => { const b = request.body; return service.currency(request.adminIdentity, id(request), b.action, b.amount); });
        admin.post('/api/players/:id/heroes', { config: { adminPermission: 'write' }, schema: { body: schemas.definition } }, async (request) => service.grantHero(request.adminIdentity, id(request), request.body.configId));
        admin.get('/api/players/:id/heroes/:heroId/skills', async (request) => service.heroSkills(id(request), request.params.heroId));
        admin.post('/api/players/:id/heroes/:heroId/skills/unlock', { config: { adminPermission: 'write' }, schema: { body: schemas.skillUnlock } }, async (request) => service.unlockHeroSkill(request.adminIdentity, id(request), request.params.heroId, request.body.index));
        admin.post('/api/players/:id/heroes/:heroId/skills/select', { config: { adminPermission: 'write' }, schema: { body: schemas.skillSelection } }, async (request) => service.selectHeroSkills(request.adminIdentity, id(request), request.params.heroId, request.body.slots));
        admin.post('/api/players/:id/heroes/:heroId/skills/level', { config: { adminPermission: 'write' }, schema: { body: schemas.skillLevel } }, async (request) => { const b = request.body; return service.levelHeroSkill(request.adminIdentity, id(request), request.params.heroId, b.index, b.level); });
        admin.get('/api/players/:id/heroes/:heroId/qa', async (request) => service.qaHero(id(request), request.params.heroId));
        admin.post('/api/players/:id/heroes/:heroId/qa', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.applyQaHero(request.adminIdentity, id(request), request.params.heroId));
        admin.post('/api/players/:id/heroes/:heroId/progression', { config: { adminPermission: 'write' }, schema: { body: schemas.heroProgression } }, async (request) => { const b = request.body; return service.setQaHeroField(request.adminIdentity, id(request), request.params.heroId, b.field, b.value); });
        admin.post('/api/players/:id/heroes/:heroId/qa/restore', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.restoreQaHero(request.adminIdentity, id(request), request.params.heroId));
        admin.post('/api/players/:id/heroes/:heroId/remove', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.removeHero(request.adminIdentity, id(request), request.params.heroId));
        admin.post('/api/players/:id/heroes/:heroId/restore', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.restoreHero(request.adminIdentity, id(request), request.params.heroId));
        admin.post('/api/players/:id/items', { config: { adminPermission: 'write' }, schema: { body: schemas.item } }, async (request) => { const b = request.body; return service.item(request.adminIdentity, id(request), b.configId, b.action, b.amount); });
        admin.post('/api/players/:id/equipment', { config: { adminPermission: 'write' }, schema: { body: schemas.definition } }, async (request) => service.grantEquipment(request.adminIdentity, id(request), request.body.configId));
        admin.post('/api/players/:id/equipment/:equipmentId/level', { config: { adminPermission: 'write' }, schema: { body: schemas.equipmentLevel } }, async (request) => service.setEquipmentLevel(request.adminIdentity, id(request), request.params.equipmentId, request.body.level));
        admin.post('/api/players/:id/equipment/:equipmentId/equip', { config: { adminPermission: 'write' }, schema: { body: schemas.equipmentAssign } }, async (request) => service.assignEquipment(request.adminIdentity, id(request), request.params.equipmentId, request.body.heroId));
        admin.post('/api/players/:id/equipment/:equipmentId/unequip', { config: { adminPermission: 'write' }, schema: { body: schemas.heroRemove } }, async (request) => service.assignEquipment(request.adminIdentity, id(request), request.params.equipmentId, null));
        admin.post('/api/players/:id/mail', { config: { adminPermission: 'write' }, schema: { body: schemas.mail } }, async (request) => { const b = request.body; return service.sendMail(request.adminIdentity, id(request), b.title, b.content, b.attachments, b.requestId); });
        admin.get('/api/requests', async () => service.requests());
        admin.get('/api/unimplemented', async () => service.requests(true));
        admin.get('/api/audit', async (request) => service.auditLog(request.query));
        const secretBody = { type: 'object', additionalProperties: false, required: ['passphrase'], properties: { passphrase: { type: 'string', minLength: 16, maxLength: 256 } } };
        admin.post('/api/backups/reauth', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['password'], properties: { password: { type: 'string', minLength: 1, maxLength: 128 } } } } }, async (r) => auth.reauthenticate(cookieToken(r.headers.cookie), r.body.password, r.ip));
        admin.get('/api/backups', { config: { adminPermission: 'owner' } }, async () => ({ environment: options.online ? 'ONLINE' : 'LOCAL', items: await backups.list(), retentionDays: 14, automatic: await backups.automaticStatus() }));
        admin.post('/api/backups', { config: { adminPermission: 'owner' }, schema: { body: secretBody } }, async (r) => { auth.requireRecent(cookieToken(r.headers.cookie)); const result = await backups.create(r.body.passphrase); auditBackup(r, 'backup.create', result.id); return result; });
        const backupId = (r) => r.params.backupId;
        const auditBackup = (r, action, id) => db.prepare('INSERT INTO admin_audit(admin_id,action,target_user_id,created_at,summary,after_state) VALUES(?,?,NULL,?,?,?)').run(r.adminIdentity.id, action, Date.now(), 'Thao tác sao lưu nhạy cảm', JSON.stringify({ backupId: id }));
        admin.get('/api/backups/:backupId/download', { config: { adminPermission: 'owner' } }, async (r, reply) => { auth.requireRecent(cookieToken(r.headers.cookie)); const id = backupId(r), file = await backups.download(id); auditBackup(r, 'backup.download', id); return reply.header('Content-Disposition', `attachment; filename="${file.name}"`).header('Content-Length', file.bytes).type('application/octet-stream').send(file.stream); });
        admin.post('/api/backups/:backupId/check', { config: { adminPermission: 'owner' }, schema: { body: secretBody } }, async (r) => { auth.requireRecent(cookieToken(r.headers.cookie)); const id = backupId(r), result = await backups.verify(id, r.body.passphrase); auditBackup(r, 'backup.verify', id); return result; });
        admin.post('/api/backups/:backupId/delete', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmation'], properties: { confirmation: { const: 'XÓA BẢN SAO LƯU' } } } } }, async (r) => { auth.requireRecent(cookieToken(r.headers.cookie)); const id = backupId(r), result = await backups.remove(id); auditBackup(r, 'backup.delete', id); return result; });
        admin.post('/api/backup', { config: { adminPermission: 'owner' }, schema: { body: schemas.empty } }, async () => adminError('Dùng Hệ thống → Sao lưu dữ liệu để tạo archive mã hóa và tải an toàn.', 410));
        admin.get('/portraits/:name', async (request, reply) => {
            const name = request.params.name;
            if (!/^[a-zA-Z0-9_-]{1,100}\.png$/.test(name))
                return reply.code(404).send();
            try {
                return reply.type('image/png').send(await readFile(join(imageRoot, name)));
            }
            catch {
                return reply.code(404).send();
            }
        });
        admin.get('/equipment-icons/:name', async (request, reply) => {
            const name = request.params.name;
            if (!/^[a-zA-Z0-9_-]{1,100}\.png$/.test(name))
                return reply.code(404).send();
            try {
                return reply.type('image/png').send(await readFile(join(webRoot, '../public/equipment', name)));
            }
            catch {
                return reply.code(404).send();
            }
        });
        admin.get('/', async (_request, reply) => { try {
            return reply.type('text/html; charset=utf-8').send(await readFile(join(webRoot, 'index.html')));
        }
        catch {
            return reply.code(503).send('Chưa build Admin UI. Chạy npm.cmd run build trong admin/.');
        } });
        admin.get('/assets/*', async (request, reply) => {
            const suffix = request.params['*'];
            if (!/^[a-zA-Z0-9_.\/-]+$/.test(suffix))
                return reply.code(404).send();
            const path = resolve(webRoot, 'assets', suffix), base = resolve(webRoot, 'assets');
            if (!path.startsWith(base + '\\') && !path.startsWith(base + '/'))
                return reply.code(404).send();
            try {
                return reply.type({ '.js': 'application/javascript', '.css': 'text/css', '.woff2': 'font/woff2' }[extname(path)] ?? 'application/octet-stream').send(await readFile(path));
            }
            catch {
                return reply.code(404).send();
            }
        });
    }, { prefix: '/admin' });
}
