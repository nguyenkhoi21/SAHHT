import { registerRealmGateway } from './player-systems/realm-manager.js';
import { registerPlayerSystemsGame } from './player-systems/player-systems.routes.js';
import { registerWelfareGame } from './welfare/welfare.routes.js';
import { RestoredEventSettlement } from './player/restored-event-settlement.js';
import { RestoredEvents } from './player/restored-events.js';
import { PlayerNotices } from './player/player-notices.js';
import { TreasureEvents } from './player/treasure-events.js';
import { InviteCodeService } from './player/invite-code.service.js';
import { InviteRewards } from './player/invite-rewards.js';
import { SkyStarService } from './player/sky-star.service.js';
import { NewstarConfig } from './player/newstar-config.js';
import { HotService } from './player/hot.service.js';
import { HotRechargeService } from './player/hot-recharge.js';
import { databaseSchemaVersion } from './db/database.js';
import { PetService } from './player/pet.service.js';
import { petBoxItem, petRecipes } from './player/pet-source.js';
import { AetherService } from './player/aether.service.js';
import { AetherWarService } from './player/aether-war.js';
import { FriendsService } from './player/friends.service.js';
import { AllianceService } from './player/alliance.service.js';
import { HomelandService } from './player/homeland.service.js';
import { BeastService } from './player/beast.service.js';
import { GodfieldService } from './player/godfield.service.js';
import { GodfieldLeagueService } from './player/godfield-league.js';
import { GodfieldTempleService } from './player/godfield-temple.js';
import { GodfieldZodiacService } from './player/godfield-zodiac.js';
import { GodfieldHighwayService } from './player/godfield-highway.js';
import { inheritancePreview } from './player/inheritance.js';
import { AuxiliaryService } from './player/auxiliary.service.js';
import { TutorialService } from './player/tutorial.js';
import { HeroResetService } from './player/hero-reset.js';
import { FormationSystemsService } from './player/formation-systems.js';
import { VipShopService } from './player/vip-shop.service.js';
import { VipStoreService } from './player/vip-store.service.js';
import { LocalRechargeService } from './player/local-recharge.service.js';
import { AppearanceService, transformationSource } from './player/appearance.service.js';
import { HeroSkillService } from './player/hero-skill.service.js';
import Fastify, { LogController } from 'fastify';
import { readFile } from 'node:fs/promises';
import { registerJournal } from './runtime/journal.js';
import { registerApkDownload } from './system/apk-download.js';
import { localAuthIdentity } from './protocol/local-auth.js';
import { AuthService, localAccount, localUserId } from './auth/auth.service.js';
import { registerAuthRoutes } from './auth/auth.routes.js';
import { PlayerService, staticConfig } from './player/player.service.js';
import { localHeroesEnabled, localContent } from './player/local-content.js';
import { ShopService } from './player/shop.service.js';
import { GachaService } from './player/gacha.service.js';
import { registerAdmin } from './admin/admin.routes.js';
import { WelfareService } from './player/welfare.service.js';
import { ActivityService, dispatchIndex } from './player/activity.service.js';
import { ArenaService } from './player/arena.service.js';
import { ArenaCombatService } from './player/arena-combat.js';
import { ReformService } from './player/reform.service.js';
import { MapAccessService } from './player/map-access.js';
import { ItemService } from './player/item.service.js';
import { EquipmentService } from './player/equipment.service.js';
import { GiftcodeService } from './player/giftcode.service.js';
import { BattleService } from './player/battle.service.js';
import { ProgressionService } from './player/progression.service.js';
import { NewstarService } from './player/newstar.service.js';
import { EquipmentDestinyService } from './player/equipment-destiny.js';
import { ProgressionEconomyService } from './player/progression-economy.js';
import { ExchangeService } from './player/exchange.service.js';
import { RebirthShopService } from './player/rebirth-shop.js';
import { NaturalProgressionService } from './player/natural-progression.js';
export async function buildApp(options = {}) {
    const unifiedOnline = options.online === true && options.onlineUnified === true;
    if (options.accountDb && !options.localAuth)
        throw new Error('accountDb cần LOCAL_AUTH_MODE để có fixture profile hợp lệ');
    if (options.online && (!options.publicOrigin?.startsWith('https://') || !options.accountDb || options.allowSynthetic || options.adminDev))
        throw Error('ONLINE cần HTTPS/database riêng, không cho dev/synthetic.');
    const app = Fastify({ bodyLimit: 65536, requestTimeout: 30000, trustProxy: options.online ? ['127.0.0.1', '::1'] : false, logger: options.logger ? { level: 'info' } : false, logController: new LogController({ disableRequestLogging: true }) });
    if (options.online)
        app.addHook('onRequest', async (r, reply) => {
            const path = r.url.split('?')[0];
            // API quản trị được bảo vệ bởi cookie/CSRF/quyền trong registerAdmin, không chặn GM hợp lệ tại router chung.
            if (path.startsWith('/debug/') || path.startsWith('/local-content/') || String(r.query.method).startsWith('local.'))
                return reply.code(403).send({ error: 'Chức năng QA không mở trên ONLINE.' });
        });
    if (options.journalPath)
        await registerJournal(app, options.journalPath, options.runId ?? 'unclassified');
    if (options.online)
        registerApkDownload(app);
    app.addContentTypeParser('application/x-www-form-urlencoded', { parseAs: 'string' }, (_request, body, done) => done(null, body));
    const accounts = options.accountDb ? new AuthService(options.accountDb) : undefined;
    if (accounts && !localHeroesEnabled() && accounts.db.prepare('SELECT 1 FROM player_heroes WHERE config_id>=9000000 AND config_id<10000000 LIMIT 1').get()) {
        accounts.close();
        throw new Error('Có hero local đang sở hữu. Bật LOCAL_HERO_EXTENSIONS=1 với APK phù hợp, hoặc lưu trữ hero local trước khi tắt.');
    }
    if (accounts)
        registerRealmGateway(app, accounts, options, buildApp);
    const players = accounts ? new PlayerService(accounts.db) : undefined;
    if (accounts && players && (!options.online || unifiedOnline))
        app.addHook('preSerialization', async (request, _reply, payload) => {
            // Chỉ projection transport: không lưu chỉ số dẫn xuất trở lại hero base.
            if (payload?.status !== '0' || !payload.data || !request.gameContext || !payload.user_status)
                return payload;
            const cache = payload.data._client_cache_update, method = String(request.query.method ?? '');
            if (cache && (cache.cards || cache.equip || cache.gem_fate || cache.pet || /^(cards\.|pet\.|gem\.|talisman\.|god_stone\.|soul\.|medal\.)/.test(method))) {
                const session = accounts.session(request.query.rans);
                if (session)
                    cache.cards = { ...cache.cards, cards: { ...cache.cards?.cards, update: players.cards(session, true).cards, remove: cache.cards?.cards?.remove ?? [] } };
            }
            return payload;
        });
    if (accounts) {
        LocalRechargeService.separateLegacyCoupons(accounts.db);
        const definitions = await staticConfig('character_detail');
        const missing = accounts.db.prepare('SELECT DISTINCT config_id FROM player_heroes').all().some(r => !definitions[String(r.config_id)]);
        if (missing) {
            accounts.close();
            throw new Error('Có hero đang sở hữu nhưng config batch đã tắt. Bật đúng batch/client trước khi khởi động.');
        }
    }
    const shop = accounts ? new ShopService(accounts.db) : undefined;
    const gacha = accounts ? new GachaService(accounts.db) : undefined;
    const welfare = accounts ? new WelfareService(accounts.db) : undefined;
    const arena = accounts ? new ArenaService(accounts.db) : undefined;
    const activities = accounts ? new ActivityService(accounts.db) : undefined;
    if (accounts) {
        if (!options.online && process.env.APP_ENV !== 'online') {
            let timer;
            app.addHook('onReady', async () => { timer = setInterval(() => { try {
                new RestoredEventSettlement(accounts.db).deliver();
            }
            catch (error) {
                app.log.error({ err: error }, 'Tất toán sự kiện LOCAL chưa hoàn tất; sẽ thử lại.');
            } }, 30000); timer.unref(); });
            app.addHook('onClose', async () => { if (timer)
                clearInterval(timer); });
        }
        if (!options.online || unifiedOnline) {
            let timer;
            app.addHook('onReady', async () => { timer = setInterval(() => { try {
                new AetherWarService(accounts.db).tick();
            }
            catch (error) {
                app.log.error({ err: error }, 'Worker Aether chưa kết toán; giữ nguyên dữ liệu.');
            } }, 15000); timer.unref(); });
            app.addHook('onClose', async () => { if (timer)
                clearInterval(timer); });
        }
        registerAdmin(app, accounts.db, { dbPath: options.accountDb, port: options.port ?? 8787, journalPath: options.journalPath, dev: options.adminDev, origin: options.adminOrigin, online: options.online, onlineUnified: unifiedOnline, backupDirectory: options.backupDirectory });
        registerWelfareGame(app, accounts, !!options.online, unifiedOnline);
        registerPlayerSystemsGame(app, accounts, !!options.online, unifiedOnline);
        registerAuthRoutes(app, accounts);
        app.addHook('preHandler', async (request) => {
            const current = accounts.session(request.query.rans);
            if (current)
                request.gameContext = { userId: current.user_id, gameUid: current.game_uid };
        });
        app.addHook('onClose', async () => accounts.close());
        app.setErrorHandler((error, request, reply) => {
            if (request.url.startsWith('/local-auth/')) {
                request.localAuthAudit = { event: 'request', result: 'INVALID_REQUEST' };
                const status = error.statusCode;
                return reply.code(status && status < 500 ? status : 503).send({ ok: false, message: 'Yêu cầu không hợp lệ. Vui lòng thử lại.' });
            }
            return reply.send(error);
        });
    }
    const synthetic = options.localAuth && (!accounts || options.allowSynthetic === true);
    const fixture = JSON.parse(await readFile(new URL('../data/server-list.json', import.meta.url), 'utf8'));
    const localOrigin = options.publicOrigin ?? `http://127.0.0.1:${options.port ?? 8787}`;
    for (const entry of fixture.server_list) {
        for (const field of ['master_url', 'domain', 'lua_url', 'lua_ver_url', 'dataosha_url']) {
            const url = new URL(entry[field]);
            entry[field] = localOrigin + url.pathname;
        }
    }
    const counts = {};
    let localRole;
    const roleDefinitions = options.localAuth ? JSON.parse(await readFile(new URL('../../work/extracted-data/configs/role_detail.json', import.meta.url), 'utf8')) : {};
    const localPlayer = options.localAuth ? JSON.parse(await readFile(new URL('../data/local-player.json', import.meta.url), 'utf8')) : null;
    const localMainPage = options.localAuth ? JSON.parse(await readFile(new URL('../data/local-main-page.json', import.meta.url), 'utf8')) : null;
    const localCardsOpen = options.localAuth ? JSON.parse(await readFile(new URL('../data/local-cards-open.json', import.meta.url), 'utf8')) : null;
    if (localPlayer && localPlayer.uid !== localAuthIdentity.playerUid)
        throw new Error('Fixture UID local không khớp provider');
    const configVersions = JSON.parse(await readFile(new URL('../../work/extracted-data/configs/game_config_version.json', import.meta.url), 'utf8'));
    app.get('/health', async () => ({ ok: true, scope: options.online ? 'online' : 'local-research', evidence: 'HARNESS VERIFIED', androidMilestone: null, ...(unifiedOnline ? { release: process.env.RELEASE_ID ?? 'workspace', schema: databaseSchemaVersion, protocol: 'sahht-unified-v12' } : {}) }));
    app.get('/local-content/manifest', async () => ({ enabled: !!localContent(), revision: localContent()?.revision ?? null, definitions: localContent()?.definitions ?? [], clientConfigHashes: localContent()?.clientConfigHashes ?? {} }));
    app.get('/debug/state', async () => ({ counts, localAuthEnabled: options.localAuth === true, implemented: [...(options.localAuth ? ['platform_access', 'new_user', 'mark_user_login', 'cards.open'] : []), 'get_user_server_list', 'new_account', 'loading', 'all_config', 'versions/nx1.8.5.json'] }));
    const loginHandler = async (request, reply) => {
        const query = request.query;
        const method = typeof query.method === 'string' ? query.method : '';
        counts[method] = (counts[method] ?? 0) + 1;
        // Chỉ log tên method; không log account, password, token hay query đầy đủ.
        request.log.info({ method }, 'Request nghiên cứu cục bộ');
        const session = accounts?.session(query.rans);
        if (accounts && method === 'platform_access' && query.channel === 'kvgames') {
            const auth = accounts.session(query.session_id);
            if (auth && query.user_id === localUserId(auth.user_id))
                return { status: '0', data: { openid: localUserId(auth.user_id), rand_str: query.session_id } };
            if (!synthetic)
                return reply.code(403).send({ error: 'Phiên local không hợp lệ' });
        }
        if (accounts && session && method === 'get_user_server_list') {
            if (query.account !== localAccount(session.user_id))
                return reply.code(403).send({ error: 'Account không khớp phiên local' });
            const data = structuredClone(fixture);
            const created = new TutorialService(accounts.db).exists(session.user_id);
            Object.assign(data.server_list[0], { uid: created ? session.game_uid : '', level: created ? players.loginLevel(session) : 0 });
            return { status: '0', data };
        }
        if (accounts && session && method === 'new_user') {
            if (query.account !== localAccount(session.user_id) || query.server_name !== fixture.current_server || typeof query.role !== 'string' || !Object.hasOwn(roleDefinitions, query.role))
                return reply.code(403).send({ error: 'Role hoặc account local không hợp lệ.' });
            new TutorialService(accounts.db).create(session.user_id, session.username, query.role);
            return { status: '0', data: { uid: session.game_uid } };
        }
        if (accounts && session && method === 'mark_user_login') {
            if (query.user_token !== session.game_uid || !new TutorialService(accounts.db).exists(session.user_id))
                return reply.code(403).send({ error: 'UID không khớp phiên hoặc chưa tạo nhân vật local' });
            return { status: '0', data: { mk: accounts.issueGameToken(session) } };
        }
        if (accounts && !synthetic && ['platform_access', 'get_user_server_list', 'new_user', 'mark_user_login'].includes(method))
            return reply.code(403).send({ error: 'Cần đăng nhập tài khoản local' });
        if (method === 'platform_access' && options.localAuth) {
            if (query.session_id !== localAuthIdentity.session_id || query.user_id !== localAuthIdentity.userID || query.channel !== localAuthIdentity.platform) {
                return reply.code(403).send({ error: 'Chỉ nhận identity tổng hợp của local test' });
            }
            // Consumer gốc dereference data.openid; các field optional không cần tạo.
            return { status: '0', data: { openid: localAuthIdentity.openid } };
        }
        if (method === 'get_user_server_list') {
            if (typeof query.account !== 'string' || !query.account)
                return reply.code(400).send({ error: 'Thiếu account cho phép thử' });
            if (options.localAuth && query.account !== localAuthIdentity.account)
                return reply.code(403).send({ error: 'Account không thuộc local test' });
            const data = structuredClone(fixture);
            if (options.localAuth && localRole)
                data.server_list[0].uid = localAuthIdentity.playerUid;
            return { status: '0', data };
        }
        if (method === 'new_user' && options.localAuth) {
            if (query.account !== localAuthIdentity.account || query.server_name !== fixture.current_server || typeof query.role !== 'string' || !Object.hasOwn(roleDefinitions, query.role)) {
                return reply.code(403).send({ error: 'Chỉ tạo role local từ role_detail đã có' });
            }
            if (localRole && localRole !== query.role)
                return reply.code(409).send({ error: 'Role local đã được chọn trong phiên này' });
            localRole = query.role;
            // create_role_scene responseMethod chỉ đọc data.uid rồi gọi mark_user_login.
            return { status: '0', data: { uid: localAuthIdentity.playerUid } };
        }
        if (method === 'mark_user_login' && options.localAuth) {
            if (!localRole || query.user_token !== localAuthIdentity.playerUid)
                return reply.code(403).send({ error: 'Chưa có role local hợp lệ' });
            // Consumer data.mk gốc khởi động cards.open; không tự tạo profile ở đây.
            return { status: '0', data: { mk: localAuthIdentity.mk } };
        }
        if (method === 'new_account') {
            if (options.localAuth)
                return reply.code(501).send({ error: 'Local auth giữ nguyên đường platform_access, không tạo account khác' });
            return { status: '0', data: { fake_account: 'local_research_guest', server_list: structuredClone(fixture.server_list) } };
        }
        if (method === 'loading') {
            // game_resources_download2.startCfg đọc game_config_version ở root.
            return { status: '0', data: {}, game_config_version: configVersions };
        }
        request.log.warn({ method }, 'Method chưa triển khai');
        return reply.code(501).send({ error: 'Method chưa được triển khai', method });
    };
    for (const path of ['/pub_abroad_vr/login/', '/login/'])
        app.get(path, loginHandler);
    const configHandler = async (request, reply) => {
        const query = request.query;
        if (query.method !== 'all_config') {
            request.log.warn({ method: typeof query.method === 'string' ? query.method : '' }, 'Method config chưa triển khai');
            return reply.code(501).send({ error: 'Method chưa được triển khai' });
        }
        // Chỉ phục vụ từng bảng có thật. Hợp đồng trả toàn bộ bảng chưa được kiểm chứng.
        if (typeof query.config_name !== 'string' || !/^[a-z_0-9]+$/.test(query.config_name))
            return reply.code(400).send({ error: 'Cần config_name hợp lệ' });
        try {
            const data = query.config_name === 'afterlife' ? transformationSource : await staticConfig(query.config_name);
            return { status: '0', data: { [query.config_name]: data } };
        }
        catch (error) {
            if (error.code === 'ENOENT')
                return reply.code(404).send({ error: 'Không có bảng này' });
            throw error;
        }
    };
    for (const path of ['/pub_abroad_vr/config/', '/config/'])
        app.get(path, configHandler);
    const giftAttempts = new Map();
    for (const path of ['/pub_abroad_vr/api/', '/api/'])
        app.get(path, async (request, reply) => {
            const query = request.query;
            const session = accounts?.session(query.rans);
            if (accounts && /^(talisman\.|gem\.|god_stone\.|soul\.|medal\.)/.test(String(query.method))) {
                // game_gem_advancedUp gửi lại uid trong params dù URL đã có user_token.
                // Chỉ nhận đúng hai giá trị giống UID của phiên; không lấy tùy tiện phần
                // tử đầu/cuối và vẫn bắt buộc rans + mk hợp lệ như các thao tác khác.
                const uidMatches = session && (query.user_token === session.game_uid || (query.method === 'gem.evolution' && Array.isArray(query.user_token) && query.user_token.length === 2 && query.user_token.every(v => v === session.game_uid)));
                if (!session || !uidMatches || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const data = new AuxiliaryService(accounts.db).execute(session.user_id, String(query.method), new URL(request.url, 'http://127.0.0.1').searchParams);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_AUXILIARY_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['cards.card_rebirth', 'cards.card_rebirth_preview'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                const svc = new HeroResetService(accounts.db);
                if (query.method === 'cards.card_rebirth_preview')
                    return { status: '0', data: svc.preview(session.user_id, String(query.card_id ?? '')) };
                try {
                    return { status: '0', data: svc.execute(session.user_id, String(query.card_id ?? ''), String(query.request_id ?? ''), String(query.preview_hash ?? '')), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    return { status: 'LOCAL_RESET_BLOCKED', msg: e.message, data: {} };
                }
            }
            if (accounts && ['cards.activate_assistant', 'cards.activate_destiny', 'cards.activate_bonus_formation', 'cards.activate_assistant_effect', 'cards.set_bonus_formation', 'cards.set_formation_bonus_addition'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                try {
                    const params = new URL(request.url, 'http://127.0.0.1').searchParams;
                    return { status: '0', data: new FormationSystemsService(accounts.db).execute(session.user_id, String(query.method), params, query.request_id), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    return { status: 'LOCAL_FORMATION_ERROR', msg: e.message, data: {} };
                }
            }
            if (accounts && ['cards.card_evolution', 'cards.card_break', 'cards.make_soul', 'cards.super_evolution'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const data = new NaturalProgressionService(accounts.db).execute(session, String(query.method), new URL(request.url, 'http://127.0.0.1').searchParams);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_PROGRESSION_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('highway.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                await players.ensure(session);
                const svc = new GodfieldHighwayService(accounts.db), p = new URL(request.url, 'http://127.0.0.1').searchParams;
                if ((options.online || process.env.APP_ENV === 'online') && ['highway.trans', 'highway.trans_index'].includes(String(query.method)))
                    return { status: 'SOURCE_BLOCKED', msg: 'Chuyển đổi nguyên liệu dùng danh sách mô phỏng LOCAL; chưa mở trên ONLINE, không tiêu vật phẩm.', data: {} };
                try {
                    let data;
                    if (p.get('local_play') === 'pool-v1') {
                        if (options.online || process.env.APP_ENV === 'online')
                            return { status: 'SOURCE_BLOCKED', msg: 'Luồng cược mô phỏng chỉ dành LOCAL.', data: {} };
                        const play = svc.play();
                        switch (query.method) {
                            case 'highway.index':
                            case 'highway.all_area_index':
                                data = play.index(session.user_id);
                                break;
                            case 'highway.area_index':
                                data = play.area(session.user_id, query.area_id);
                                break;
                            case 'highway.betting':
                                data = play.bet(session, p);
                                break;
                            case 'highway.add_power':
                                data = play.contribute(session, p);
                                break;
                            case 'highway.add_buff':
                                data = play.buff(session, p);
                                break;
                        }
                    }
                    if (data === undefined)
                        switch (query.method) {
                            case 'highway.index':
                                data = svc.index(session.user_id);
                                break;
                            case 'highway.trans_index':
                                data = svc.conversion(session.user_id);
                                break;
                            case 'highway.shop_index':
                                data = svc.shop(session.user_id, query.sort ?? '1');
                                break;
                            case 'highway.trans':
                                data = svc.convert(session, p);
                                break;
                            case 'highway.buy':
                                data = svc.buy(session, p);
                                break;
                            case 'highway.all_area_index':
                            case 'highway.area_index':
                                if (options.online || process.env.APP_ENV === 'online' || p.get('local_qa') !== 'race-v1')
                                    return { status: 'SOURCE_BLOCKED', msg: 'Chỉ bản QA LOCAL được mở đua mô phỏng; không cược/tiêu tài nguyên/phát thưởng.', data: {} };
                                data = query.method === 'highway.area_index' ? svc.qaArea(session.user_id, query.area_id) : svc.qaAllAreas(session.user_id);
                                break;
                            default: return { status: 'SOURCE_BLOCKED', msg: 'Phần đua/đặt cược/làm mới cửa hàng chưa đủ quy tắc nguồn; không tiêu tài nguyên.', data: {} };
                        }
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'HIGHWAY_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('zodiac.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                await players.ensure(session);
                const svc = new GodfieldZodiacService(accounts.db), p = new URL(request.url, 'http://127.0.0.1').searchParams;
                try {
                    let data;
                    switch (query.method) {
                        case 'zodiac.index':
                            data = svc.index(session.user_id);
                            break;
                        case 'zodiac.go_fight':
                            data = svc.palace(session.user_id, query.floor);
                            break;
                        case 'zodiac.god_field_ids':
                        case 'zodiac.upload_god_formation':
                            data = svc.formation(session.user_id);
                            break;
                        case 'zodiac.user_info':
                            data = svc.userInfo(session.user_id, p);
                            break;
                        case 'zodiac.zodiac_battle':
                            data = svc.battle(session, p);
                            break;
                        case 'zodiac.remove_floor_pos':
                        case 'zodiac.remove_floor_pos2':
                            data = svc.withdraw(session, p);
                            break;
                        case 'zodiac.zodiac_battle_log':
                            data = { log: svc.history(session.user_id) };
                            break;
                        case 'zodiac.zodiac_battle_replay':
                            data = svc.replay(session.user_id, query.key);
                            break;
                        default: return { status: 'SOURCE_BLOCKED', msg: 'Boss, ô may mắn và truy nã 12 Cung còn thiếu quy tắc nguồn; chưa thay dữ liệu.', data: {} };
                    }
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'ZODIAC_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('universe_arena.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                await players.ensure(session);
                const svc = new GodfieldTempleService(accounts.db), p = new URL(request.url, 'http://127.0.0.1').searchParams;
                try {
                    let data;
                    switch (query.method) {
                        case 'universe_arena.index':
                            data = svc.index(session.user_id);
                            break;
                        case 'universe_arena.team_index':
                            data = svc.teamIndex(session.user_id, query.team_id);
                            break;
                        case 'universe_arena.upload_god_formation':
                            data = svc.formation(session.user_id);
                            break;
                        case 'universe_arena.shop_index':
                            data = svc.shop(session.user_id);
                            break;
                        case 'universe_arena.buy_goods':
                            data = svc.buy(session, p);
                            break;
                        case 'universe_arena.secore_reward_index':
                            data = svc.rewards(session.user_id);
                            break;
                        case 'universe_arena.get_reward':
                            data = svc.claim(session, p);
                            break;
                        case 'universe_arena.get_rank_info':
                            data = svc.ranks(session.user_id);
                            break;
                        case 'universe_arena.get_battle_tips':
                            data = svc.logs(session.user_id, query.team_id);
                            break;
                        case 'universe_arena.hero_rank':
                            data = svc.heroes();
                            break;
                        case 'universe_arena.universe_arena_battle':
                            data = svc.battle(session, p);
                            break;
                        default: return { status: 'SOURCE_BLOCKED', msg: 'Thao tác Thần Điện đang khôi phục từ nguồn; chưa thay dữ liệu.', data: {} };
                    }
                    return { status: '0', data };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'TEMPLE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && query.method === 'item.exchange') {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                if (!unifiedOnline && (options.online || process.env.APP_ENV === 'online') && petRecipes()[String(query.change_id)])
                    return { status: 'PET_LOCAL_ONLY', msg: 'Ghép PET đang kiểm LOCAL; chưa mở ONLINE.', data: {} };
                await players.ensure(session);
                try {
                    return { status: '0', data: new ItemService(accounts.db).exchange(session, new URL(request.url, 'http://127.0.0.1').searchParams), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_FRAGMENT_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['god_field.index', 'god_field.upload_god_formation', 'god_field.get_combat_rank', 'god_field.get_combat_rank_guild', 'god_field.see_enemy_info', 'god_field.god_field_battle', 'god_field.update_battle_order', 'god_field.exchange_index', 'god_field.exchange', 'god_field.buy_ship_ticket', 'god_field.back_battle', 'god_field.get_own_logs', 'god_field.god_integration_rank', 'god_field.see_final_log', 'god_field.see_god_field_log', 'god_field.final_battle_log'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                await players.ensure(session);
                const svc = new GodfieldService(accounts.db), league = new GodfieldLeagueService(accounts.db), p = new URL(request.url, 'http://127.0.0.1').searchParams;
                if ((options.online || process.env.APP_ENV === 'online') && ['god_field.see_enemy_info', 'god_field.god_field_battle', 'god_field.buy_ship_ticket'].includes(String(query.method)))
                    return { status: 'SOURCE_BLOCKED', msg: 'Ghép nhóm và tính điểm Đấu Tranh Bá đang dùng mô phỏng LOCAL; chưa mở trận hoặc mua vé trên ONLINE.', data: {} };
                try {
                    svc.assertUnlocked(session.user_id);
                    let data;
                    switch (query.method) {
                        case 'god_field.get_combat_rank_guild': return { status: 'GODFIELD_UNAVAILABLE', msg: 'Xếp hạng liên minh Thần Vực đang khôi phục cùng hệ liên minh; hiện chưa mở.', data: {} };
                        case 'god_field.index':
                            data = league.index(session.user_id, options.online);
                            break;
                        case 'god_field.upload_god_formation':
                            data = svc.packet(session.user_id);
                            break;
                        case 'god_field.get_combat_rank':
                            data = svc.ranking(query.page);
                            break;
                        case 'god_field.see_enemy_info':
                            data = league.enemy(session.user_id, p);
                            break;
                        case 'god_field.god_field_battle':
                            data = league.battle(session, p);
                            break;
                        case 'god_field.update_battle_order':
                            data = league.order(session, p);
                            break;
                        case 'god_field.exchange_index':
                            data = league.shop(session.user_id);
                            break;
                        case 'god_field.exchange':
                            data = league.exchange(session, p);
                            break;
                        case 'god_field.buy_ship_ticket':
                            data = league.ticket(session, p);
                            break;
                        case 'god_field.back_battle':
                            data = league.replay(session.user_id, query.battle_log);
                            break;
                        case 'god_field.get_own_logs':
                            data = { logs: league.history(session.user_id).map(r => `${r.log_dict.final_win === 1 ? 'Bên khiêu chiến thắng' : 'Bên phòng thủ thắng'} · ${r.log_dict.log_list[0].attacker} - ${r.log_dict.log_list[0].defender}`) };
                            break;
                        case 'god_field.god_integration_rank':
                            data = league.top();
                            break;
                        default: return { status: 'GODFIELD_UNAVAILABLE', msg: 'Kết toán vòng loại/top32 cuối tuần đang đối chiếu nguồn; chưa tự tạo kết quả hoặc phát thưởng.', data: {} };
                    }
                    return { status: '0', data };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'GODFIELD_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['sacrifice.open_shop', 'sacrifice.grace_exchange'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const svc = new RebirthShopService(accounts.db), data = query.method === 'sacrifice.open_shop' ? svc.index(session, query.client_content === 'phase30-v1') : svc.buy(session, new URL(request.url, 'http://127.0.0.1').searchParams, query.client_content === 'phase30-v1');
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_REBIRTH_SHOP_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['active.active_show', 'active.active_recharge_receive', 'active.active_consume_receive', 'omni_exchange.show_omni_exchange_options', 'omni_exchange.omni_exchange', 'hot.recharge_info', 'hot.recharge_buy', 'payment.use_ticket'].includes(String(query.method)) && (!options.online || unifiedOnline)) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay LOCAL không hợp lệ' });
                await players.ensure(session);
                try {
                    const hot = new HotService(accounts.db), recharge = new HotRechargeService(accounts.db, Date.now, !!options.online), p = new URL(request.url, 'http://127.0.0.1').searchParams, m = String(query.method);
                    if (m === 'payment.use_ticket')
                        throw Object.assign(new Error('Cần chọn gói và xác nhận sandbox LOCAL; cpOrderId không phải bằng chứng thanh toán.'), { statusCode: 422 });
                    const data = m === 'active.active_show' || m === 'omni_exchange.show_omni_exchange_options' ? hot.index(session) : m === 'hot.recharge_info' ? recharge.info(session) : m === 'hot.recharge_buy' ? recharge.buy(session, p) : m === 'payment.use_ticket' ? { blocked: true, msg: 'Cần tạo giao dịch từ gói gốc bằng hợp đồng sandbox; không tin cpOrderId do client tự gửi.' } : hot.claim(session, m === 'active.active_recharge_receive' ? 'recharge' : m === 'active.active_consume_receive' ? 'consume' : 'exchange', p);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'HOT_LOCAL_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && options.online && !unifiedOnline && ['active.active_recharge_receive', 'active.active_consume_receive', 'omni_exchange.show_omni_exchange_options', 'omni_exchange.omni_exchange', 'hot.recharge_info', 'hot.recharge_buy', 'payment.use_ticket'].includes(String(query.method)))
                return { status: 'HOT_LOCAL_ONLY', msg: 'Hợp đồng HOT mới chỉ mở sandbox LOCAL; chưa được phát hành ONLINE.', data: {} };
            if (accounts && ['active.active_show', 'normal_exchange.index', 'normal_exchange.normal_exchange'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const svc = new ExchangeService(accounts.db), data = query.method === 'active.active_show' ? svc.show() : query.method === 'normal_exchange.index' ? svc.index(session) : svc.exchange(session, new URL(request.url, 'http://127.0.0.1').searchParams);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_EXCHANGE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['cards.inherit', 'cards.element_break', 'cards.element_query'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const svc = new ProgressionEconomyService(accounts.db), data = query.method === 'cards.element_query' ? svc.query(session, query.card_id) : svc.execute(session, String(query.method), new URL(request.url, 'http://127.0.0.1').searchParams);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_PROGRESSION_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['cards.buy_skin', 'cards.use_skin', 'cards.new_card_world'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const service = new AppearanceService(accounts.db);
                    const data = query.method === 'cards.buy_skin' ? await service.buySkin(session, query.skin_id, query.request_id) : query.method === 'cards.use_skin' ? service.useSkin(session, query.skin_ids ?? '', query.request_id) : await service.transform(session, query.major, query.afterlife_id, query.request_id);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_APPEARANCE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('guild_high_war.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên Aether không hợp lệ' });
                if (!unifiedOnline && (options.online || process.env.APP_ENV === 'online'))
                    return { status: 'AETHER_LOCAL_ONLY', msg: 'Aether đang khôi phục LOCAL; chưa mở ONLINE.', data: {} };
                await players.ensure(session);
                const p = new URL(request.url, 'http://127.0.0.1').searchParams, m = String(query.method).slice(15), svc = new AetherService(accounts.db);
                const reads = ['index', 'map_index', 'alignment_info', 'upload_formation', 'employ_index', 'employ_guild_index', 'shop_index', 'get_rank', 'city_info', 'get_guild_record', 'get_city_record', 'record', 'science_index', 'science_rank', 'box_index', 'war_index', 'player_index', 'explore_index'];
                try {
                    const data = reads.includes(m) ? svc.read(session.user_id, m, p) : svc.execute(session, m, p), user_status = players.profile(session, localPlayer);
                    return { status: '0', data, user_status };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'AETHER_SOURCE_OR_RULE_BLOCKED', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('pets.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên PET không hợp lệ' });
                if (!unifiedOnline && (options.online || process.env.APP_ENV === 'online'))
                    return { status: 'PET_LOCAL_ONLY', msg: 'PET đang khôi phục LOCAL; chưa mở ONLINE.', data: {} };
                await players.ensure(session);
                const svc = new PetService(accounts.db), method = String(query.method).slice(5), params = new URL(request.url, 'http://127.0.0.1').searchParams;
                try {
                    return { status: '0', data: method === 'index' ? svc.index(session.user_id) : svc.execute(session, method, params), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'PET_RULE_BLOCKED', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && /^(homeland|fable_beast)\./.test(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ' });
                if (options.online && !unifiedOnline)
                    return { status: 'LOCAL_PHASE36_CLOSED', msg: 'Farm/Thần Thú đang kiểm LOCAL; chưa mở ONLINE.', data: {} };
                await players.ensure(session);
                const m = String(query.method), p = new URL(request.url, 'http://127.0.0.1').searchParams;
                try {
                    const data = m.startsWith('homeland.') ? (['homeland.index', 'homeland.store_index', 'homeland.visit', 'homeland.friends'].includes(m) ? new HomelandService(accounts.db).read(session.user_id, m, p) : new HomelandService(accounts.db).execute(session, m, p)) : m === 'fable_beast.index' ? new BeastService(accounts.db).index(session.user_id) : m === 'fable_beast.rebirth_preview' ? { rebirth_preview: new BeastService(accounts.db).rebirthPreview(session.user_id, Number(p.get('beast'))) } : new BeastService(accounts.db).execute(session, m, p);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_PHASE36_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('association.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ' });
                if (options.online && !unifiedOnline)
                    return { status: 'LOCAL_ALLIANCE_CLOSED', msg: 'Liên Minh mới đang được kiểm thử LOCAL; chưa mở trên ONLINE.', data: {} };
                await players.ensure(session);
                const svc = new AllianceService(accounts.db), m = String(query.method), params = new URL(request.url, 'http://127.0.0.1').searchParams;
                try {
                    const data = ['association.guild_all', 'association.guild_search', 'association.guild_detail', 'association.guild_one', 'association.shop', 'association.flush_msg'].includes(m) ? svc.read(session.user_id, m, params) : svc.execute(session, m, params);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_ALLIANCE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && String(query.method).startsWith('friend.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ' });
                await players.ensure(session);
                const svc = new FriendsService(accounts.db), m = String(query.method);
                try {
                    const data = m === 'friend.friends' ? svc.list(session.user_id) : m === 'friend.messages' ? svc.messages(session.user_id) : m === 'friend.search' ? svc.search(session.user_id, query.target_id) : svc.execute(session, m, new URL(request.url, 'http://127.0.0.1').searchParams);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_FRIEND_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['shop.open', 'shop.buy', 'gacha.get_all_gacha', 'gacha.get_gacha'].includes(String(query.method)) && (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk)))
                return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
            if (accounts && ['local.recharge_info', 'local.redeem_ticket'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                if (query.method === 'local.redeem_ticket')
                    return { status: 'LOCAL_RECHARGE_RETIRED', msg: 'Lối tắt vé cũ đã ngừng. Hãy chọn gói trong màn Nạp thẻ.', data: {} };
                try {
                    const service = new LocalRechargeService(accounts.db);
                    return { status: '0', data: service.info(session), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_RECHARGE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['shop.vip_store_index', 'shop.vip_store_buy'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const store = new VipStoreService(accounts.db), data = query.method === 'shop.vip_store_index' ? store.index(session) : store.buy(session, query.shop_id, query.count ?? '1', query.request_id);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_VIP_SHOP_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['equip_gacha.get_all_gacha', 'equip_gacha.get_gacha'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                return { status: 'LOCAL_GACHA_SOURCE_BLOCKED', msg: 'Bách Bảo chưa đủ dữ liệu pool và quy tắc bảo hiểm. Chưa trừ tiền hoặc phát thưởng.', data: {} };
            }
            if (accounts && query.method === 'item.use' && petBoxItem(Number(query.item_id))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên PET không hợp lệ' });
                if (!unifiedOnline && (options.online || process.env.APP_ENV === 'online'))
                    return { status: 'PET_LOCAL_ONLY', msg: 'Vật liệu PET mới chỉ kiểm LOCAL.', data: {} };
                try {
                    return { status: '0', data: new PetService(accounts.db).useItem(session, new URL(request.url, 'http://127.0.0.1').searchParams), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'PET_RULE_BLOCKED', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && (String(query.method).startsWith('equip.fate_') || query.method === 'equip.auto_fate_equip_levelup' || String(query.method).startsWith('gem_fate.') || query.method === 'item.use' && !['3', '4', '5', '6'].includes(String(query.item_id)))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                try {
                    const data = new EquipmentDestinyService(accounts.db).execute(session, String(query.method), new URL(request.url, 'http://127.0.0.1').searchParams);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (error) {
                    if (error.statusCode === 422)
                        return { status: 'LOCAL_EQUIPMENT_ERROR', msg: error.message, data: {} };
                    throw error;
                }
            }
            if (accounts && !options.online && (/^(gringotts|limit_time_war)\./.test(String(query.method)) || query.method === 'local_notice.seen')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay LOCAL không hợp lệ.' });
                try {
                    const p = new URL(request.url, 'http://127.0.0.1').searchParams;
                    let data;
                    if (query.method === 'local_notice.seen')
                        data = new PlayerNotices(accounts.db).acknowledge(session.user_id, String(query.kind), JSON.parse(String(query.ids ?? '[]')));
                    else {
                        if (query.restored_schema !== '1')
                            throw Object.assign(Error('Cần APK LOCAL khôi phục Cổ Linh Các / Xuất Chinh để đồng bộ giao dịch.'), { statusCode: 422 });
                        const [prefix, action] = String(query.method).split('.'), kind = prefix === 'gringotts' ? 'investment' : 'dispatch', svc = new RestoredEvents(accounts.db);
                        data = action === 'index' ? svc.index(session, kind) : svc.execute(session, kind, action, p);
                    }
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e instanceof SyntaxError || e.statusCode === 422)
                        return { status: 'LOCAL_RESTORED_EVENT_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && !options.online && String(query.method).startsWith('invite_code.')) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay LOCAL không hợp lệ' });
                try {
                    const svc = new InviteCodeService(accounts.db), method = String(query.method), p = new URL(request.url, 'http://127.0.0.1').searchParams;
                    let data;
                    if (method === 'invite_code.index') {
                        if (new InviteRewards(accounts.db).settings().revision > 0 && query.invite_schema !== '2')
                            throw Object.assign(Error('Cần APK LOCAL v6 để xem đúng quà Mã mời đã tùy chỉnh.'), { statusCode: 422 });
                        data = svc.index(session);
                    }
                    else if (method === 'invite_code.add_invite_code') {
                        if (!['1', '2'].includes(String(query.invite_schema)))
                            throw Object.assign(Error('Cần APK LOCAL mới để nhập Mã mời an toàn.'), { statusCode: 422 });
                        data = svc.bind(session, p);
                    }
                    else
                        throw Object.assign(Error('Thao tác Mã mời không hợp lệ.'), { statusCode: 422 });
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_INVITE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && !options.online && /^(one_piece|new_roulette|clone_lane)\./.test(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay LOCAL không hợp lệ' });
                try {
                    if (query.event_schema !== '1')
                        throw Object.assign(Error('Cần APK LOCAL khôi phục Kho báu/Mê cung/Chúng thần điện để đồng bộ quà và chống trùng lượt.'), { statusCode: 422 });
                    const [prefix, method] = String(query.method).split('.'), kind = prefix === 'one_piece' ? 'treasure' : prefix === 'new_roulette' ? 'labyrinth' : 'pantheon', svc = new TreasureEvents(accounts.db);
                    const data = ['index', 'info', 'exchange_index', 'get_notice'].includes(method) ? svc.index(session, kind, Number(query.type ?? 1), method === 'get_notice') : svc.action(session, kind, method, query);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_EVENT_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && !options.online && ['bandit.index', 'bandit.get_reward', 'server_bandit.index', 'server_bandit.get_reward'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay LOCAL không hợp lệ' });
                try {
                    if (query.sky_schema !== '1')
                        throw Object.assign(Error('Cần APK LOCAL lịch sự kiện để đồng bộ đúng bảng Xu đầy trời.'), { statusCode: 422 });
                    const svc = new SkyStarService(accounts.db), target = String(query.method).startsWith('server_') ? 'server.905' : 'main.506', data = String(query.method).endsWith('.index') ? svc.index(session, target) : svc.draw(session, target, query);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_EVENT_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (accounts && ['newstar.index', 'newstar.get_login_reward', 'newstar.get_task_reward'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                const events = new NewstarService(accounts.db);
                try {
                    const cfg = new NewstarConfig(accounts.db), active = await cfg.current();
                    if (!['1', '2'].includes(String(query.newstar_schema)) && active.id !== null)
                        throw Object.assign(Error('Cần APK LOCAL có hỗ trợ quà Tân Tinh động.'), { statusCode: 422 });
                    if (query.newstar_schema !== '2' && JSON.stringify(active.definition.tasks) !== JSON.stringify((await cfg.baseline()).tasks))
                        throw Object.assign(Error('Cần APK Tân Tinh LOCAL v2 để hiển thị đúng quà nhiệm vụ đã cấu hình.'), { statusCode: 422 });
                    const data = query.method === 'newstar.index' ? await events.state(session, true) : await events.claim(session, query.method === 'newstar.get_login_reward' ? 'sign' : 'task', query.method === 'newstar.get_login_reward' ? query.days : query.task_id);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (error) {
                    if (error.statusCode === 422)
                        return { status: 'LOCAL_EVENT_ERROR', msg: error.message, data: {} };
                    throw error;
                }
            }
            if (accounts && ['arena.battle', 'arena.buy_count', 'arena.replay', 'arena.log'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                const service = new ArenaCombatService(accounts.db), data = query.method === 'arena.battle' ? service.battle(session, query) : query.method === 'arena.buy_count' ? service.purchase(session, query) : query.method === 'arena.replay' ? service.replay(session.user_id, query.key) : { log: service.clientHistory(session.user_id) };
                return { status: '0', data, user_status: players.profile(session, localPlayer) };
            }
            if (accounts && query.method === 'cards.inherit_preview') {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                try {
                    return { status: '0', data: inheritancePreview(accounts.db, session.user_id, String(query.master ?? ''), String(query.student ?? ''), String(query.use_exp_ball) === '1') };
                }
                catch (e) {
                    return { status: 'LOCAL_INHERITANCE_ERROR', msg: e.message, data: {} };
                }
            }
            if (accounts && ['user.rename', 'user.add_step'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                const tutorial = new TutorialService(accounts.db);
                return { status: '0', data: query.method === 'user.rename' ? tutorial.rename(session.user_id, query.show_name) : tutorial.statistic(session.user_id, query.step), user_status: players.profile(session, localPlayer) };
            }
            if (accounts && query.method === 'tutorial.opening_complete') {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay không hợp lệ.' });
                return { status: '0', data: new TutorialService(accounts.db).opening(session.user_id, String(query.request_id ?? '')), user_status: players.profile(session, localPlayer) };
            }
            if (accounts && query.method === 'user.guide') {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                return { status: '0', data: new ProgressionService(accounts.db).updateGuide(session.user_id, query.guide_team, query.guide_id), user_status: players.profile(session, localPlayer) };
            }
            if (accounts && ['private_city.recapture', 'private_city.hard_recapture', 'private_city.auto_recapture'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                try {
                    if (query.method === 'private_city.hard_recapture')
                        await new MapAccessService(accounts.db).hardOpen(session.user_id, query.city, query.chapter);
                    const battles = new BattleService(accounts.db);
                    const data = query.method === 'private_city.auto_recapture' ? await battles.sweep(session, query) : await battles.start(session, query);
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (error) {
                    if (error?.statusCode !== 422)
                        throw error;
                    // HTTP 200 + status lỗi: client hiện đúng lý do thay vì "Mạng xin thất bại".
                    request.log.warn({ method: String(query.method), reason: error.message }, 'Gameplay bị từ chối');
                    return { status: error.clientStatus ?? 'error_local', data: { message: error.message } };
                }
            }
            if (accounts && query.method === 'private_city.hard_open') {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                return { status: '0', data: await new MapAccessService(accounts.db).hardOpen(session.user_id, query.city, query.chapter), user_status: players.profile(session, localPlayer) };
            }
            if (accounts && ['code.index', 'code.use_code'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                const gifts = new GiftcodeService(accounts.db);
                if (query.method === 'code.index')
                    return { status: '0', data: gifts.index(session), user_status: players.profile(session, localPlayer) };
                const old = giftAttempts.get(session.user_id), attempt = old && Date.now() - old.at < 60_000 ? old : { at: Date.now(), count: 0 };
                giftAttempts.set(session.user_id, attempt);
                if (++attempt.count > 12)
                    return { status: 'LOCAL_CODE_LIMIT', msg: 'Bạn thao tác quá nhanh. Vui lòng thử lại sau một phút.', data: {} };
                try {
                    const data = gifts.redeem(session, query.code, query.request_id);
                    request.log.info({ event: 'giftcode.redeem', userId: session.user_id, result: data.replayed ? 'REPLAY' : 'MAILED' }, 'Đổi mã quà tặng local');
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                catch (error) {
                    if (error.statusCode === 422) {
                        request.log.info({ event: 'giftcode.redeem', userId: session.user_id, result: 'REJECTED' }, 'Mã quà tặng bị từ chối');
                        return { status: 'LOCAL_CODE_ERROR', msg: error.message, data: {} };
                    }
                    throw error;
                }
            }
            if (accounts && (session || !synthetic) && ['cards.open', 'cards.select_skill_index', 'cards.card_skill_levelup', 'cards.unlock_skill', 'cards.set_battle_skill', 'cards.lock_card', 'cards.release_card', 'user.main_page', 'notify.messages', 'notify.read', 'notify.auto_read', 'private_city.world_map', 'private_city.open', 'private_city.map_fight_and_enemy', 'active.index', 'offline_dispatch.index', 'reward.gift_award', 'arena.index', 'arena.top', 'user.info', 'user.top_level', 'user.top_combat', 'laboratory.level_up', 'factory.equip_levelup', 'user.change_name', 'item.use', 'item.view', 'shop.open', 'shop.buy', 'shop.vip_buy_step', 'shop.vip_buy', 'gacha.get_all_gacha', 'gacha.get_gacha', 'reward.diary_index', 'reward.once_index', 'reward.once_award', 'vip_reward.sign_index', 'vip_reward.every_day', 'vip_reward.vip_sign'].includes(String(query.method))) {
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
                await players.ensure(session);
                if (['reward.once_index', 'reward.once_award', 'vip_reward.sign_index', 'vip_reward.every_day', 'vip_reward.vip_sign'].includes(String(query.method))) {
                    try {
                        const data = query.method === 'reward.once_index' ? await welfare.onceIndex(session) : query.method === 'reward.once_award' ? await welfare.claimLevel(session, query.award_id) : query.method === 'vip_reward.sign_index' ? await welfare.vipIndex(session) : query.method === 'vip_reward.every_day' ? await welfare.claimVipDaily(session) : await welfare.claimVipSign(session, query.vip);
                        return { status: '0', data, user_status: players.profile(session, localPlayer) };
                    }
                    catch (error) {
                        if (error.statusCode === 422)
                            return { status: 'LOCAL_WELFARE_ERROR', msg: error.message, data: {} };
                        throw error;
                    }
                }
                if (query.method === 'reward.diary_index')
                    return { status: '0', data: await players.missions(session), user_status: players.profile(session, localPlayer) };
                // game_gacha_scene.init/refreshUi đọc gacha_all và energy_slot không có nil guard.
                if (query.method === 'gacha.get_all_gacha' || query.method === 'gacha.get_gacha') {
                    try {
                        return { status: '0', data: query.method === 'gacha.get_all_gacha' ? gacha.open(session) : await gacha.draw(session, query.gacha_type, query.request_id), user_status: players.profile(session, localPlayer) };
                    }
                    catch (error) {
                        if (error.statusCode === 422)
                            return { status: 'LOCAL_GACHA_ERROR', msg: error.message, data: {} };
                        throw error;
                    }
                }
                if (query.method === 'shop.vip_buy_step' || query.method === 'shop.vip_buy') {
                    let data = query.method === 'shop.vip_buy_step' ? new VipShopService(accounts.db).step(session) : await new VipShopService(accounts.db).buy(session, query.shop_id);
                    if ((!options.online || unifiedOnline) && query.method === 'shop.vip_buy_step')
                        data = { ...data, ...new HotRechargeService(accounts.db, Date.now, !!options.online).info(session).step };
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                if (query.method === 'shop.open' || query.method === 'shop.buy') {
                    try {
                        return { status: '0', data: query.method === 'shop.open' ? await shop.open(session, query.client_content === 'phase30-v1') : await shop.buy(session, query.shop_id, query.count, query.request_id, query.client_content === 'phase30-v1'), user_status: players.profile(session, localPlayer) };
                    }
                    catch (error) {
                        if (error.statusCode === 422)
                            return { status: 'LOCAL_SHOP_ERROR', msg: error.message, data: {} };
                        throw error;
                    }
                }
                if (query.method === 'user.change_name')
                    return { status: '0', data: players.rename(session, query.name), user_status: players.profile(session, localPlayer) };
                if (query.method === 'cards.card_skill_levelup')
                    return { status: '0', data: await new HeroSkillService(accounts.db).upgrade(session, String(query.major ?? ''), Number(query.pos), new URL(request.url, 'http://127.0.0.1').searchParams.getAll('metal')), user_status: players.profile(session, localPlayer) };
                if (['cards.select_skill_index', 'cards.card_skill_levelup', 'cards.unlock_skill', 'cards.set_battle_skill'].includes(String(query.method))) {
                    const service = new HeroSkillService(accounts.db), id = String(query.card_id ?? '');
                    const data = query.method === 'cards.select_skill_index' ? await service.info(session, id) : query.method === 'cards.unlock_skill' ? await service.unlock(session, id, Number(query.skill_id)) : await service.select(session, id, String(query.skill_ids ?? '').split('_').filter(Boolean).map(Number));
                    return { status: '0', data, user_status: players.profile(session, localPlayer) };
                }
                if (query.method === 'item.view')
                    return { status: '0', data: new ItemService(accounts.db).view(session), user_status: players.profile(session, localPlayer) };
                if (query.method === 'item.use')
                    return { status: '0', data: await new ItemService(accounts.db).use(session, query.item_id, query.num, query.request_id ?? ''), user_status: players.profile(session, localPlayer) };
                if (query.method === 'cards.lock_card' || query.method === 'cards.release_card')
                    return { status: '0', data: players.setHeroLock(session, query.card_id, query.method === 'cards.lock_card') };
                if (query.method === 'factory.equip_levelup')
                    return { status: '0', data: await new EquipmentService(accounts.db).levelUp(session, query.magor, query.lvs, query.request_id), user_status: players.profile(session, localPlayer) };
                if (query.method === 'active.index')
                    return { status: '0', data: await activities.open(session), user_status: players.profile(session, localPlayer) };
                if (query.method === 'offline_dispatch.index')
                    return { status: '0', data: await dispatchIndex(), user_status: players.profile(session, localPlayer) };
                if (query.method === 'reward.gift_award')
                    return { status: '0', data: activities.claim(session, query.award_id), user_status: players.profile(session, localPlayer) };
                if (query.method === 'arena.index' || query.method === 'arena.top')
                    return { status: '0', data: query.method === 'arena.index' ? arena.open(session) : arena.top(query.page), user_status: players.profile(session, localPlayer) };
                if (query.method === 'user.info')
                    return { status: '0', data: arena.publicProfile(query.uid), user_status: players.profile(session, localPlayer) };
                if (query.method === 'laboratory.level_up') {
                    try {
                        return { status: '0', data: await new ReformService(accounts.db).upgrade(session, query.card_id, new URL(request.url, 'http://127.0.0.1').searchParams.getAll('type'), query.request_id), user_status: players.profile(session, localPlayer) };
                    }
                    catch (e) {
                        if (e.statusCode === 422)
                            return { status: 'LOCAL_REFORM_ERROR', msg: e.message, data: {}, user_status: players.profile(session, localPlayer) };
                        throw e;
                    }
                }
                if (query.method === 'user.top_level' || query.method === 'user.top_combat')
                    return { status: '0', data: arena.playerRanking(query.method === 'user.top_level' ? 'level' : 'combat', query.page, session.game_uid), user_status: players.profile(session, localPlayer) };
                if (query.method === 'private_city.open')
                    return { status: '0', data: await new MapAccessService(accounts.db).open(session.user_id, query.city, query.chapter), user_status: players.profile(session, localPlayer) };
                if (query.method === 'private_city.map_fight_and_enemy')
                    return { status: '0', data: await new MapAccessService(accounts.db).enemies(session.user_id, query.city, query.building), user_status: players.profile(session, localPlayer) };
                if (query.method === 'private_city.world_map')
                    return { status: '0', data: await new MapAccessService(accounts.db).world(session.user_id), user_status: players.profile(session, localPlayer) };
                if (query.method === 'notify.messages' || query.method === 'notify.read' || query.method === 'notify.auto_read') {
                    try {
                        const data = query.method === 'notify.messages' ? players.mail(session) : await players.readMail(session, query.message_id, query.method === 'notify.auto_read');
                        return { status: '0', data, user_status: players.profile(session, localPlayer) };
                    }
                    catch (error) {
                        if (error.statusCode === 422)
                            return { status: 'LOCAL_MAIL_ERROR', msg: error.message, data: {} };
                        throw error;
                    }
                }
                return { status: '0', data: query.method === 'user.main_page' ? { ...players.mainPage(session, localMainPage), shop: await shop.bootstrap(session, query.client_content === 'phase30-v1') } : players.cards(session, true), user_status: players.profile(session, localPlayer) };
            }
            if (options.localAuth && query.method === 'cards.open') {
                if (!localRole || query.user_token !== localAuthIdentity.playerUid || query.mk !== localAuthIdentity.mk)
                    return reply.code(403).send({ error: 'Thiếu session tổng hợp local' });
                // responseGameData đọc user_status ở ROOT; cards setters có nil guard.
                return { status: '0', data: {}, user_status: { ...localPlayer, role: localRole, server_time: Math.floor(Date.now() / 1000) } };
            }
            request.log.warn({ method: typeof query.method === 'string' ? query.method : '' }, 'Gameplay method chưa triển khai');
            return reply.code(501).send({ error: 'Gameplay method chưa được triển khai' });
        });
    // Chỉ hỗ trợ phiên bản có thật trong game_version_config.lua.
    for (const path of ['/pub_abroad_vr/api/', '/api/'])
        app.post(path, async (request, reply) => {
            const query = request.query;
            if (String(query.method).startsWith('pets.')) {
                const session = accounts?.session(query.rans);
                if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                    return reply.code(403).send({ error: 'Phiên PET không hợp lệ' });
                if (!unifiedOnline && (options.online || process.env.APP_ENV === 'online'))
                    return { status: 'PET_LOCAL_ONLY', msg: 'PET chỉ dành LOCAL.', data: {} };
                const method = String(query.method).slice(5), params = new URLSearchParams(typeof request.body === 'string' ? request.body : request.body);
                if (!['set_pet_formation', 'set_pet_follow_formation'].includes(method))
                    return { status: 'PET_RULE_BLOCKED', msg: 'Thao tác PET này không có hợp đồng POST.', data: {} };
                try {
                    return { status: '0', data: new PetService(accounts.db).execute(session, method, params), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'PET_RULE_BLOCKED', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (String(query.method).startsWith('guild_high_war.') && query.method !== 'guild_high_war.set_formation') {
                const s = accounts?.session(query.rans);
                if (!s || query.user_token !== s.game_uid || !accounts?.validGameToken(s, query.mk))
                    return reply.code(403).send({ error: 'Phiên Aether không hợp lệ' });
                return { status: options.online ? 'AETHER_LOCAL_ONLY' : 'AETHER_SOURCE_OR_RULE_BLOCKED', msg: 'Không có hợp đồng POST cho thao tác Aether này; chưa thay dữ liệu.', data: {} };
            }
            if (!['cards.set_alignment', 'soul.sell_soul', 'talisman.sell', 'god_stone.set_alignment', 'god_field.set_god_field', 'guild_high_war.set_formation', 'universe_arena.set_god_field', 'zodiac.update_field'].includes(String(query.method)) || !accounts || !players)
                return reply.code(501).send({ error: 'Gameplay method chưa được triển khai' });
            const session = accounts.session(query.rans);
            if (!session || query.user_token !== session.game_uid || !accounts.validGameToken(session, query.mk))
                return reply.code(403).send({ error: 'Phiên gameplay local không hợp lệ' });
            if (typeof request.body !== 'string')
                return reply.code(400).send({ error: 'Cần form-urlencoded' });
            await players.ensure(session);
            if (query.method === 'guild_high_war.set_formation') {
                if (!unifiedOnline && (options.online || process.env.APP_ENV === 'online'))
                    return { status: 'AETHER_LOCAL_ONLY', msg: 'Aether chỉ mở LOCAL.', data: {} };
                const p = new URLSearchParams(request.body);
                p.set('request_id', String(query.request_id ?? p.get('request_id') ?? ''));
                try {
                    return { status: '0', data: new AetherService(accounts.db).execute(session, 'set_formation', p), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'AETHER_SOURCE_OR_RULE_BLOCKED', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (query.method === 'zodiac.update_field') {
                const p = new URLSearchParams(request.body);
                p.set('request_id', String(query.request_id ?? p.get('request_id') ?? ''));
                try {
                    return { status: '0', data: new GodfieldZodiacService(accounts.db).save(session, p) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'ZODIAC_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (query.method === 'universe_arena.set_god_field') {
                const p = new URLSearchParams(request.body);
                p.set('request_id', String(query.request_id ?? p.get('request_id') ?? ''));
                try {
                    return { status: '0', data: new GodfieldTempleService(accounts.db).save(session, p) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'TEMPLE_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (query.method === 'god_field.set_god_field') {
                const p = new URLSearchParams(request.body);
                p.set('request_id', String(query.request_id ?? p.get('request_id') ?? ''));
                try {
                    return { status: '0', data: new GodfieldService(accounts.db).save(session, p) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'GODFIELD_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (query.method === 'god_stone.set_alignment') {
                const p = new URLSearchParams(request.body);
                p.set('request_id', String(query.request_id ?? p.get('request_id') ?? ''));
                try {
                    return { status: '0', data: new AuxiliaryService(accounts.db).saveSacred(session.user_id, p), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_AUXILIARY_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            if (query.method === 'soul.sell_soul' || query.method === 'talisman.sell') {
                const p = new URLSearchParams(request.body);
                p.set('request_id', String(query.request_id ?? p.get('request_id') ?? ''));
                try {
                    return { status: '0', data: new AuxiliaryService(accounts.db).execute(session.user_id, String(query.method), p), user_status: players.profile(session, localPlayer) };
                }
                catch (e) {
                    if (e.statusCode === 422)
                        return { status: 'LOCAL_AUXILIARY_ERROR', msg: e.message, data: {} };
                    throw e;
                }
            }
            try {
                return { status: '0', data: await players.saveFormation(session, new URLSearchParams(request.body)), user_status: players.profile(session, localPlayer) };
            }
            catch (e) {
                if (e?.statusCode !== 422)
                    throw e;
                // Trả HTTP 200 + msg để game hiện đúng lý do lưu đội hình thất bại.
                request.log.warn({ method: 'cards.set_alignment', reason: e.message }, 'Lưu đội hình bị từ chối');
                return { status: 'LOCAL_FORMATION_ERROR', msg: e.message, data: {} };
            }
        });
    app.get('/versions/nx1.8.5.json', async () => ({ data: { current_version: 'nx1.8.5', different_files: [] } }));
    app.setNotFoundHandler(async (request, reply) => {
        request.log.warn({ path: request.url.split('?')[0] }, 'Route chưa được triển khai');
        return reply.code(404).send({ error: 'Route chưa được triển khai' });
    });
    return app;
}
