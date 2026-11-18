import { transformationGraph } from '../player/transformation-graph.js';
import { petConfig } from '../player/pet-source.js';
import { mailRewardItem } from '../player/inventory-items.js';
import { transformedMailPreset } from '../player/transformed-mail.js';
import { auxiliaryPreset } from '../player/auxiliary-state.js';
import { PlayerVitalsService } from '../player/player-vitals.js';
import { fatePreset } from '../player/fate-empowerment.js';
import { compileSkill } from '../player/skill-effects.js';
import { runtimeHeroVerification } from '../player/runtime-content-index.js';
import { HeroSkillService } from '../player/hero-skill.service.js';
import { localContent, readConfigSync } from '../player/local-content.js';
import { recoveredHeroSources, recoveredHeroCatalog } from '../player/recovered-source-index.js';
import { DatabaseSync, backup } from 'node:sqlite';
import { randomUUID, createHash } from 'node:crypto';
import { mkdir, stat, open, readFile } from 'node:fs/promises';
import { dirname, join, basename } from 'node:path';
import { PlayerService, staticConfig } from '../player/player.service.js';
import { createBaseHero, createBaseEquipment, characterName, hasOnlyInitialHeroSkills } from '../player/definitions.js';
import { contentIndex, contentDiagnostics, heroCandidates, heroRegistry } from '../player/content-index.js';
import { audit, adminError } from './admin.audit.js';
import { pageQuery } from './admin.schemas.js';
import { levelState, vipState } from '../player/progression.js';
import { heroResources } from '../player/hero-index.js';
import { WelfareService } from '../player/welfare.service.js';
import { EquipmentDestinyService } from '../player/equipment-destiny.js';
import { GachaService } from '../player/gacha.service.js';
import { ShopService } from '../player/shop.service.js';
import { CombatPowerService } from '../player/combat-power.js';
import { heroSkillIndex } from '../player/skill-index.js';
import { battleEvidence } from './battle-evidence.js';
import { endpointEvidence } from '../runtime/endpoint-evidence.js';
import { ActivityService } from '../player/activity.service.js';
import { heroProgression, runtimeAssetStatus } from '../player/hero-progression.js';
import { qaHeroPlan } from '../player/qa-hero.js';
import { MapAccessService } from '../player/map-access.js';
import { ProgressionService, stageGraph } from '../player/progression.service.js';
export class AdminService {
    db;
    dbPath;
    journalPath;
    players;
    started = Date.now();
    constructor(db, dbPath, journalPath) {
        this.db = db;
        this.dbPath = dbPath;
        this.journalPath = journalPath;
        this.players = new PlayerService(db);
    }
    target(id, requireState = true) {
        const row = this.db.prepare('SELECT u.id AS user_id,u.username,p.game_uid,p.role FROM users u JOIN player_profiles p ON p.user_id=u.id WHERE u.id=?').get(id);
        if (!row)
            adminError('Không tìm thấy tài khoản local.', 404);
        if (requireState && !this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(id))
            adminError('Tài khoản chưa vào game để tạo player state.', 409);
        return row;
    }
    change(admin, action, id, apply) {
        if (admin.role === 'VIEWER')
            adminError('Tài khoản chỉ có quyền xem.', 403);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const result = apply(this.target(id));
            audit(this.db, admin.id, action, id, `${action} — người chơi #${id}`, result.before, result.after);
            this.db.exec('COMMIT');
            return result.result;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    listPlayers(query) {
        const { q, page, pageSize } = pageQuery(query), search = `%${q}%`;
        const where = ' WHERE (u.username LIKE ? OR p.game_uid LIKE ? OR json_extract(s.profile,\'$.show_name\') LIKE ?)' + (query.status === 'ready' ? ' AND s.user_id IS NOT NULL' : query.status === 'pending' ? ' AND s.user_id IS NULL' : '');
        const from = ' FROM users u JOIN player_profiles p ON p.user_id=u.id LEFT JOIN player_state s ON s.user_id=u.id';
        const total = this.db.prepare('SELECT COUNT(*) AS n' + from + where).get(search, search, search).n;
        const sort = query.sort === 'username' ? 'u.username' : query.sort === 'created' ? 'u.created_at' : 'u.id';
        const direction = query.direction === 'asc' ? 'ASC' : 'DESC';
        const rows = this.db.prepare(`SELECT u.id,u.username,p.game_uid,u.created_at,s.profile,(SELECT MAX(created_at) FROM sessions WHERE user_id=u.id) AS last_login_at${from}${where} ORDER BY ${sort} ${direction} LIMIT ? OFFSET ?`).all(search, search, search, pageSize, (page - 1) * pageSize);
        return { total, page, pageSize, items: rows.map(({ profile, ...r }) => ({ ...r, ready: !!profile, show_name: profile ? JSON.parse(profile).show_name : null, level: profile ? (JSON.parse(profile).level ?? 1) : null })) };
    }
    async detail(id) {
        const target = this.target(id, false), ready = !!this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(id);
        if (!ready)
            return { id, username: target.username, game_uid: target.game_uid, ready: false };
        const cards = this.players.cards(target), heroes = await staticConfig('character_detail'), items = await staticConfig('item'), equip = await staticConfig('equip');
        const profile = this.players.profile(target, { level: 1, exp: 0, exp_max: 0, coin: 0, food: 0, action_point: 0, action_point_max: 0, vip: 0 });
        const owned = Object.values(cards.cards).map((c) => ({ ...c, name: heroes[String(c.c_id)]?.name ?? String(c.c_id), animation: heroes[String(c.c_id)]?.animation }));
        const archivedHeroes = this.db.prepare('SELECT id,config_id,archived_at FROM player_hero_archive WHERE user_id=? ORDER BY archived_at DESC').all(id).map(row => ({ ...row, name: heroes[String(row.config_id)]?.name ?? 'Nguồn đã cách ly', restorable: !!heroes[String(row.config_id)] }));
        const equipment = Object.values(cards.equip).map((e) => ({ ...e, name: equip[String(e.c_id)]?.name ?? String(e.c_id) }));
        const inventory = Object.entries(cards.items).map(([configId, value]) => ({ configId: Number(configId), quantity: value[0], name: items[configId]?.name ?? configId }));
        const mail = this.db.prepare('SELECT id,content,read_at,attachments FROM player_mail WHERE user_id=? ORDER BY rowid DESC').all(id).map(row => ({ ...row, attachments: JSON.parse(String(row.attachments)), claimStatus: row.read_at === null ? 'UNCLAIMED' : 'CLAIMED' }));
        const preview = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile)._local_mission_preview === true;
        return { id, username: target.username, game_uid: target.game_uid, ready: true, vitals: new PlayerVitalsService(this.db).diagnostics(id), profile, heroes: owned, archivedHeroes, equipment, inventory, formation: { alignment: cards.alignment, equip_pos: cards.equip_pos, formation: cards.formation, battle_card_num: cards.battle_card_num }, mail, missions: { preview, mode: 'READ_ONLY', ...(preview ? await this.players.missions(target) : {}) }, refresh: { owned: 'Cần đăng nhập lại để đồng bộ tướng, vật phẩm và trang bị.', currency: 'Cập nhật sau request gameplay tiếp theo; đăng nhập lại để bảo đảm.', mail: 'Mở lại Xã giao → Tin tức.' } };
    }
    async catalog(kind, query) {
        const { q, page, pageSize } = pageQuery(query), search = q.toLocaleLowerCase('vi');
        const cfg = await staticConfig(kind === 'heroes' ? 'character_detail' : kind === 'items' ? 'item' : 'equip');
        const fragmentRecipes = kind === 'items' ? await staticConfig('exchange') : {};
        const runtimeQa = kind === 'heroes' ? await runtimeHeroVerification() : {};
        const resources = kind === 'heroes' ? await heroResources() : new Map();
        const skillIndex = kind === 'heroes' ? await heroSkillIndex() : undefined;
        const heroIndex = kind === 'heroes' ? new Map((await contentIndex('hero_catalog')).map(r => [r.configId, r])) : new Map();
        const equipmentIndex = kind === 'equipment' ? new Map((await contentIndex('equipment_catalog')).map(r => [r.configId, r])) : new Map();
        const owned = query.userId ? Object.values(this.players.cards(this.target(Number(query.userId))).equip).map((e) => e.c_id) : [];
        const entries = Object.entries(cfg).filter(([id, c]) => !q || id.includes(q) || String(c.name ?? '').toLocaleLowerCase('vi').includes(search) || (kind === 'heroes' && [c.animation, heroIndex.get(Number(id))?.sourceDefinition?.source, ...(skillIndex?.heroByConfigId[id]?.skills ?? []).map((v) => v.skillId)].some(v => String(v ?? '').toLocaleLowerCase('vi').includes(search))) || (kind === 'heroes' && (heroIndex.get(Number(id))?.aliases ?? []).some((a) => a.toLocaleLowerCase('vi').includes(search))))
            .filter(([, c]) => !query.quality || Number(query.quality) === c.quality)
            .filter(([, c]) => !query.type || Number(query.type) === c.type)
            .filter(([, c]) => !query.race || Number(query.race) === c.race)
            .filter(([, c]) => kind !== 'equipment' || !query.slot || Number(query.slot) === c.sort)
            .filter(([id]) => kind !== 'equipment' || !query.resource || equipmentIndex.get(Number(id))?.resourceStatus === query.resource)
            .filter(([id]) => kind !== 'heroes' || !query.resource || runtimeAssetStatus(resources.get(Number(id))) === query.resource)
            .filter(([id]) => kind !== 'heroes' || !query.progression || (query.progression === 'SUPPORTED' ? heroIndex.get(Number(id))?.qaSupport?.supported === true : heroIndex.get(Number(id))?.qaSupport?.supported !== true))
            .filter(([id]) => { if (kind !== 'heroes' || !query.runtime)
            return true; const verified = !!runtimeQa[id]?.roster || battleEvidence.heroes.some(h => h.configId === Number(id)); return query.runtime === 'ANDROID VERIFIED' ? verified : !verified; })
            .map(([id, c]) => {
            let grantable = true;
            if (kind === 'heroes') {
                try {
                    createBaseHero('preview', Number(id), c);
                }
                catch {
                    grantable = false;
                }
                if (resources.get(Number(id))?.assetStatus !== 'FULL ASSETS' || skillIndex.heroByConfigId[id].skills.some((s) => s.slot === 1 && !s.exists))
                    grantable = false;
            }
            if (kind === 'equipment') {
                try {
                    createBaseEquipment('preview', Number(id), c);
                    grantable = equipmentIndex.get(Number(id))?.grantable === true;
                }
                catch {
                    grantable = false;
                }
            }
            if (kind === 'items')
                grantable = mailRewardItem(Number(id), c, fragmentRecipes[String(c.sort)]);
            return { configId: Number(id), name: c.name ?? id, quality: c.quality ?? null, animation: kind === 'heroes' ? c.animation : undefined, sort: c.sort ?? null, stack: c.stack ?? null, grantable, ...(kind === 'equipment' ? { ...equipmentIndex.get(Number(id)), owned: owned.filter(x => x === Number(id)).length } : {}), ...(kind === 'heroes' ? { localDefinition: heroIndex.get(Number(id))?.localDefinition, sourceDefinition: heroIndex.get(Number(id))?.sourceDefinition, qaSupport: heroIndex.get(Number(id))?.qaSupport, aliases: heroIndex.get(Number(id))?.aliases, classification: heroIndex.get(Number(id))?.classification, progression: heroIndex.get(Number(id))?.superEvolution, type: c.type, race: c.race, career: c.career, character_ID: c.character_ID, resources: resources.get(Number(id)) ?? { assetStatus: 'UNKNOWN' }, initialStats: Object.fromEntries(['base_hp', 'base_patk', 'base_matk', 'base_def', 'base_speed'].map(k => [k, c[k]])), skills: Object.fromEntries(Object.entries(c).filter(([k]) => /^skill_[1-7]_source$/.test(k))), star: c.star, star_max: c.star_max, is_skin: c.is_skin } : {}) };
        }).filter(item => kind !== 'heroes' || query.scope !== 'playable' || (item.grantable && !['MATERIAL CARD', 'SKIN / TRANSFORMATION', 'CONFIG HERO MISSING ASSET'].includes(item.classification ?? '') && Number(cfg[item.configId].character_ID) !== 999 && cfg[item.configId].skill_num > 0 && cfg[item.configId].is_evo === 1 && cfg[item.configId].star === 0))
            .filter(item => kind !== 'heroes' || !query.category || (query.category === 'transformed' ? transformationGraph.some(e => e.targetId === item.configId) : query.category === 'base' ? !transformationGraph.some(e => e.targetId === item.configId) : true))
            .sort((a, b) => query.sort === 'name' ? String(a.name).localeCompare(String(b.name), 'vi') : a.configId - b.configId);
        return { total: entries.length, page, pageSize, items: entries.slice((page - 1) * pageSize, page * pageSize).map(item => ({ ...item, ...(kind === 'heroes' ? { sourceForm: transformationGraph.some(e => e.targetId === item.configId) ? 'transformed' : 'base', runtimeAssetStatus: runtimeAssetStatus(resources.get(item.configId)), skillSummary: skillIndex.heroByConfigId[String(item.configId)].skills, runtime: runtimeQa[String(item.configId)] ?? battleEvidence.heroes.find(h => h.configId === item.configId) ?? { evidence: 'UNKNOWN', battle: 'Chưa kiểm chứng Android' } } : {}) })) };
    }
    async heroInspector(configId) {
        const index = await heroSkillIndex(), hero = index.heroByConfigId[String(configId)];
        if (!hero)
            adminError('Không có hero config này.', 404);
        return { ...hero, content: (await contentIndex('hero_catalog')).find(r => r.configId === configId), progression: await heroProgression(configId), skillDetails: hero.skills.map((s) => ({ ...s, definition: index.skillById[String(s.skillId)] ?? null })), runtime: battleEvidence.heroes.find(h => h.configId === configId) ?? { evidence: 'UNKNOWN' } };
    }
    async heroResourceCatalog(query) {
        const { q, page, pageSize } = pageQuery(query), term = q.toLocaleLowerCase('vi');
        const [groups, catalog] = await Promise.all([heroCandidates(), contentIndex('hero_catalog')]);
        const byId = new Map(catalog.map(h => [h.configId, h]));
        const items = groups.map(group => ({ ...group, variants: group.configIds.map((id) => { const h = byId.get(id); return h ? { configId: id, name: h.displayName, quality: h.quality, type: h.type, classification: h.classification, grantable: h.baseGrantableByServer === true, qaSupport: h.qaSupport, skillCount: h.skillIds.length, skillIds: h.skillIds, skin: h.skin, localDefinition: h.localDefinition, sourceDefinition: h.sourceDefinition, runtime: battleEvidence.heroes.find(v => v.configId === id) ?? { evidence: 'UNKNOWN', battle: 'Chưa kiểm chứng Android' }, aliases: h.aliases } : null; }).filter(Boolean) }));
        const filtered = items.filter(g => (!q || [g.internalName, ...(g.aliases ?? []), ...g.variants.flatMap((h) => [String(h.configId), h.name, ...(h.aliases ?? [])])].some(v => String(v).toLocaleLowerCase('vi').includes(term))) && (!query.classification || g.classification === query.classification) && (!query.grantable || g.variants.some((h) => h.grantable) === (query.grantable === 'yes')));
        const coverage = JSON.parse(await readFile(new URL('../../../work/generated/iphonehd_coverage.json', import.meta.url), 'utf8'));
        return { total: filtered.length, page, pageSize, items: filtered.slice((page - 1) * pageSize, page * pageSize), coverage: { ...coverage, baselineConfigRows: coverage.configRows, configRows: catalog.length, modelGroups: groups.length, grantCompatible: catalog.filter(h => h.baseGrantableByServer === true).length, qaCompatible: catalog.filter(h => h.qaSupport?.supported).length }, localExtension: { enabled: !!localContent(), revision: localContent()?.revision, definitions: (localContent()?.definitions ?? []).filter((d) => d.mode === 'LOCAL TEST IMPLEMENTATION'), recoveredBatches: localContent()?.batches ?? [] }, classes: [...new Set(groups.map(g => g.classification))].sort(), notice: 'Model và config gốc giữ provenance. LOCAL TEST HERO dùng ID và định nghĩa riêng từ template; không phải ID gốc được phục hồi.' };
    }
    async unlinkedHeroes(query) {
        const registry = await heroRegistry(), { q, page, pageSize } = pageQuery(query), term = q.toLocaleLowerCase('vi');
        const recovered = await recoveredHeroSources(), sourceById = new Map((recovered?.heroCandidates ?? []).map((r) => [r.configId, r]));
        const rows = [...registry.unlinkedModels.map((g) => ({ ...g, kind: 'model', name: g.internalName, localPrototypeIds: (localContent()?.heroCatalog ?? []).filter((h) => h.internalName === g.internalName).map((h) => h.configId) })), ...registry.missingModels.map((g) => ({ ...g, kind: 'config', internalName: g.modelId })), ...registry.danglingReferences.map((g) => ({ ...g, recoveredDefinition: sourceById.get(g.configId) }))];
        const selected = rows.filter(g => !(g.kind === 'model' && (localContent()?.heroCatalog ?? []).some((h) => h.internalName === g.internalName))).filter(g => (!query.kind || g.kind === query.kind) && (!q || [g.name, g.internalName, String(g.configId ?? ''), ...(g.aliases ?? [])].some(v => String(v).toLocaleLowerCase('vi').includes(term))));
        return { summary: registry.summary, sourceVersion: registry.sourceVersion, recoveredSource: recovered?.summary, total: selected.length, page, pageSize, items: selected.slice((page - 1) * pageSize, page * pageSize), notice: registry.notice };
    }
    async recoveredHeroes(query) { return recoveredHeroCatalog(query, await recoveredHeroSources()); }
    contentDiagnostics() { return contentDiagnostics(); }
    async mapInfo(id) { this.target(id); return new MapAccessService(this.db).info(id); }
    async unlockMap(admin, id) {
        if (new ProgressionService(this.db).access(id)?.mode === 'LOCAL_GM_COMPLETE')
            adminError('Hãy dùng khôi phục tiến trình trước khi đổi quyền chọn GM.');
        // Chuẩn bị cache trước transaction đồng bộ của change().
        await contentIndex('stage_catalog');
        const service = new MapAccessService(this.db), info = await service.info(id);
        const target = this.target(id), level = this.players.profile(target, {}).level ?? 1;
        const needed = Math.max(...info.stages.map(s => Math.max(s.openLevel, s.chapterConfig?.open_level ?? Infinity)));
        if (level < needed || info.stages.some(s => !s.chapterConfig || !s.tmx.length))
            adminError(`Cần cấp${needed} và resource/chapter đầy đủ để mở quyền chọn.`);
        return this.change(admin, 'map.unlock_all', id, () => {
            const before = this.db.prepare('SELECT state FROM player_map_access WHERE user_id=?').get(id);
            const state = { storyIds: info.stages.map(s => s.storyId), cityIds: info.stages.map(s => s.cityId), completed: [], stars: {}, mode: 'LOCAL_GM_SELECT_ONLY' };
            this.db.prepare('INSERT INTO player_map_access VALUES(?,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state').run(id, JSON.stringify(state));
            return { before: before ? JSON.parse(before.state) : null, after: state, result: { ok: true, selectedCount: info.stages.length, battleReadyCount: 0, notice: info.notice } };
        });
    }
    resetMap(admin, id) { if (new ProgressionService(this.db).access(id)?.mode === 'LOCAL_GM_COMPLETE')
        adminError('Hãy dùng khôi phục tiến trình để giữ snapshot.'); return this.change(admin, 'map.reset_override', id, () => new MapAccessService(this.db).reset(id)); }
    async completeMap(admin, id, formationOverride, unlockFeatures = false) {
        this.target(id);
        if (admin.role === 'VIEWER')
            adminError('Tài khoản chỉ có quyền xem.', 403);
        await stageGraph();
        return new ProgressionService(this.db).completeAll(id, formationOverride, admin.id, unlockFeatures);
    }
    restoreMap(admin, id) { return this.change(admin, 'map.restore_completion', id, () => ({ before: new ProgressionService(this.db).access(id), after: null, result: new ProgressionService(this.db).restore(id) })); }
    removeHero(admin, id, heroId) {
        if (!/^[a-zA-Z0-9-]{1,80}$/.test(heroId))
            adminError('ID instance không hợp lệ.');
        return this.change(admin, 'hero.remove', id, target => {
            const cards = this.players.cards(target), raw = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(id, heroId), hero = raw ? JSON.parse(raw.state) : undefined;
            if (!hero)
                adminError('Hero không thuộc tài khoản.', 404);
            if ((hero.bind_equip ?? []).some((v) => v && String(v) !== '0'))
                adminError('Hãy mở ràng buộc Vận Mệnh trước khi lưu trữ tướng.');
            const contains = (value) => value === heroId || !!(value && typeof value === 'object' && Object.entries(value).some(([k, v]) => k === heroId || contains(v)));
            const row = this.db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(id);
            if (contains(JSON.parse(row.formation)) || contains(JSON.parse(row.profile)))
                adminError('Hãy gỡ hero khỏi đội hình/liên kết trước khi xóa.');
            if (hero.lv !== 1 || hero.exp !== 0 || hero.bre !== 0 || hero.step !== 0 || hero.lock || hero.super_step || hero.evo || Object.values(hero.remove_avail ?? {}).length || !hasOnlyInitialHeroSkills(hero))
                adminError('Chỉ gỡ instance base chưa khóa/chưa progression đã được hỗ trợ.');
            this.db.prepare('INSERT INTO player_hero_archive VALUES(?,?,?,?,?)').run(id, heroId, hero.c_id, JSON.stringify(hero), Date.now());
            this.db.prepare('DELETE FROM player_heroes WHERE user_id=? AND id=?').run(id, heroId);
            return { before: hero, after: { archived: true, heroId, configId: hero.c_id }, result: { ok: true, refresh: 'Đăng nhập lại để cập nhật roster; có thể khôi phục từ lưu trữ, không hoàn trả vật liệu.' } };
        });
    }
    restoreHero(admin, id, heroId) {
        return this.change(admin, 'hero.restore', id, target => {
            const row = this.db.prepare('SELECT config_id,state FROM player_hero_archive WHERE user_id=? AND id=?').get(id, heroId);
            if (!row)
                adminError('Không có hero lưu trữ của tài khoản này.', 404);
            if (!readConfigSync('character_detail')[String(row.config_id)])
                adminError('Định nghĩa hero đã cách ly hoặc chưa có nguồn Việt Nam tương thích; không thể khôi phục vào roster.');
            if (Object.keys(this.players.cards(target).cards).length >= this.players.profile(target, {}).card_max)
                adminError('Danh sách tướng không đủ chỗ.');
            this.db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(id, heroId, row.config_id, row.state);
            this.db.prepare('DELETE FROM player_hero_archive WHERE user_id=? AND id=?').run(id, heroId);
            return { before: { archived: true, heroId }, after: JSON.parse(row.state), result: { ok: true, refresh: 'Đăng nhập lại để cập nhật; không tự xếp đội hình.' } };
        });
    }
    async skillCatalog(query) {
        const index = await heroSkillIndex(), table = String(query.table ?? 'skill_detail');
        if (!Object.hasOwn(index.tables, table))
            adminError('Không có bảng skill này.', 400);
        const cfg = await staticConfig(table), { q, page, pageSize } = pageQuery(query), term = q.toLocaleLowerCase('vi');
        const entries = Object.entries(cfg).filter(([id, c]) => !q || id.includes(q) || String(c.skill_name ?? c.name ?? '').toLocaleLowerCase('vi').includes(term))
            .filter(([, c]) => !query.trigger || c.skill_type === query.trigger).sort((a, b) => Number(a[0]) - Number(b[0]));
        return { table, tables: index.tables, total: entries.length, page, pageSize, items: entries.slice((page - 1) * pageSize, page * pageSize).map(([id, c]) => ({ id, config: c, mapping: table === 'skill_detail' ? index.skillById[id] : null, combat: table === 'skill_detail' ? compileSkill(c, 1) : null, evidence: 'STATIC VERIFIED' })) };
    }
    activityInfo() { return { settings: new ActivityService(this.db).settings(), claims: this.db.prepare("SELECT c.user_id,u.username,c.period,c.claimed_at FROM player_claims c JOIN users u ON u.id=c.user_id WHERE c.system='activity_supplies' ORDER BY c.claimed_at DESC LIMIT 50").all() }; }
    setActivitySchedule(admin, input) {
        if (admin.role === 'VIEWER')
            adminError('Bạn chỉ có quyền xem.', 403);
        const start = Date.parse(input.startsAt), end = Date.parse(input.endsAt);
        if (!Number.isFinite(start) || !Number.isFinite(end) || end <= start || end - start > 31 * 24 * 3600_000)
            adminError('Lịch local cần thời điểm hợp lệ, kết thúc sau bắt đầu và tối đa31 ngày.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const before = new ActivityService(this.db).settings();
            this.db.prepare("UPDATE local_activity_settings SET enabled=?,starts_at=?,ends_at=? WHERE activity_id='10'").run(input.enabled ? 1 : 0, start, end);
            const after = new ActivityService(this.db).settings();
            audit(this.db, admin.id, 'activity.schedule.set', null, 'Lịch vật tư sinh tồn local; giữ nguyên claims', before, after);
            this.db.exec('COMMIT');
            return after;
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
    async grantPreset(admin, id, count, type) {
        const cfg = await staticConfig('character_detail'), resources = await heroResources(), skillIndex = await heroSkillIndex();
        const owned = new Set(Object.values(this.players.cards(this.target(id)).cards).map(h => h.c_id));
        const candidates = Object.entries(cfg).filter(([cid, c]) => !owned.has(Number(cid)) && (type === undefined || c.type === type) && resources.get(Number(cid))?.assetStatus === 'FULL ASSETS')
            .sort((a, b) => Number(a[0]) - Number(b[0])).filter(([cid, c]) => { try {
            createBaseHero('preview', Number(cid), c);
            return !skillIndex.heroByConfigId[cid].skills.some((s) => s.slot === 1 && !s.exists);
        }
        catch {
            return false;
        } }).slice(0, count);
        if (candidates.length !== count)
            adminError('Không đủ hero hợp lệ cho preset.');
        return this.change(admin, 'hero.preset', id, target => {
            const cards = this.players.cards(target), before = Object.keys(cards.cards).length;
            if (before + count > this.players.profile(target, {}).card_max)
                adminError('Danh sách tướng không đủ chỗ.');
            const result = candidates.map(([cid, c]) => { const uid = 'locala' + randomUUID().replaceAll('-', ''); const hero = createBaseHero(uid, Number(cid), c); this.db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(id, uid, Number(cid), JSON.stringify(hero)); return hero; });
            return { before: { count: before }, after: { count: before + count, configIds: result.map(h => h.c_id) }, result };
        });
    }
    updateProfile(admin, id, name) {
        const show_name = characterName(name);
        return this.change(admin, 'player.update', id, () => {
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id);
            const p = JSON.parse(row.profile);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, show_name }), id);
            return { before: { show_name: p.show_name }, after: { show_name }, result: { show_name } };
        });
    }
    setLevel(admin, id, value) {
        const state = levelState(value);
        return this.change(admin, 'player.level.set', id, () => {
            const old = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile);
            const { _local_mission_preview, ...profile } = old;
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, ...state }), id);
            return { before: { level: old.level ?? 1, exp: old.exp ?? 0, exp_max: old.exp_max ?? 0 }, after: state, result: state };
        });
    }
    async setVip(admin, id, value) {
        const state = await vipState(value);
        return this.change(admin, 'player.vip.set', id, () => {
            const old = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...old, ...state }), id);
            return { before: { vip: old.vip ?? 0, vip_exp: old.vip_exp ?? 0 }, after: state, result: state };
        });
    }
    currency(admin, id, action, amount) {
        return this.change(admin, 'currency.' + action.toLowerCase(), id, () => {
            if (!['ADD', 'SET', 'REMOVE'].includes(action) || !Number.isSafeInteger(amount) || amount < 0 || amount > 1_000_000_000)
                adminError('Số Xu hoặc thao tác không hợp lệ.');
            const p = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile), before = p.coin ?? 0;
            const coin = action === 'SET' ? amount : before + (action === 'ADD' ? amount : -amount);
            if (!Number.isSafeInteger(coin) || coin < 0 || coin > 1_000_000_000)
                adminError('Số dư Xu phải trong khoảng0–1.000.000.000.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, coin }), id);
            return { before: { coin: before }, after: { coin }, result: { coin } };
        });
    }
    async grantHero(admin, id, configId) {
        const cfg = (await staticConfig('character_detail'))[String(configId)], uid = `locala${id}-${randomUUID().replaceAll('-', '')}`;
        const hero = createBaseHero(uid, configId, cfg);
        if ((await heroSkillIndex()).heroByConfigId[String(configId)].skills.some((s) => s.slot === 1 && !s.exists))
            adminError('Skill chính của hero thiếu config; chưa thể cấp an toàn.');
        if ((await heroResources()).get(configId)?.assetStatus !== 'FULL ASSETS')
            adminError('Chưa có đủ bộ model/atlas/texture local để cấp hero an toàn.');
        return this.change(admin, 'hero.grant', id, target => {
            const cards = this.players.cards(target), count = Object.keys(cards.cards).length, capacity = this.players.profile(target, {}).card_max;
            if (count >= capacity)
                adminError('Danh sách tướng đã đầy.');
            this.db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(id, uid, configId, JSON.stringify(hero));
            return { before: { count }, after: { count: count + 1, hero }, result: hero };
        });
    }
    rosterCapacity(admin, id, capacity) {
        if (!Number.isSafeInteger(capacity) || capacity < 20 || capacity > 5000)
            adminError('Dung lượng roster QA phải từ20 đến5000. Đây là giới hạn thử nghiệm local.');
        return this.change(admin, 'hero.capacity.local_qa', id, target => {
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id), profile = JSON.parse(row.profile), count = Object.keys(this.players.cards(target).cards).length;
            if (capacity < count)
                adminError('Không thể giảm dung lượng xuống dưới số tướng đang sở hữu.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, card_max: capacity, _local_inventory_bonus: { ...profile._local_inventory_bonus, card_max: capacity - readConfigSync('role')[profile.level ?? 1].character_max } }), id);
            return { before: { card_max: profile.card_max, count }, after: { card_max: capacity, count }, result: { ok: true, card_max: capacity } };
        });
    }
    async qaHero(id, heroId, targetState) {
        const target = this.target(id), row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(id, heroId), hero = row ? { hp_crystal: 0, patk_crystal: 0, matk_crystal: 0, def_crystal: 0, speed_crystal: 0, ...JSON.parse(row.state) } : undefined;
        if (!hero)
            adminError('Hero không thuộc tài khoản.', 404);
        const level = Number(this.players.profile(target, {}).level ?? 1);
        const max = await qaHeroPlan(hero, level);
        return { ...(targetState ? await qaHeroPlan(hero, level, targetState) : max), sourceState: hero };
    }
    async applyQaHero(admin, id, heroId, targetState) {
        const plan = await this.qaHero(id, heroId, targetState);
        return this.change(admin, targetState ? 'hero.progression.set' : 'hero.qa.max', id, () => {
            const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(id, heroId);
            const defaults = { hp_crystal: 0, patk_crystal: 0, matk_crystal: 0, def_crystal: 0, speed_crystal: 0 };
            if (!row || JSON.stringify({ ...defaults, ...JSON.parse(row.state) }) !== JSON.stringify(plan.sourceState))
                adminError('Hero đã thay đổi; hãy tải lại.', 409);
            this.db.prepare('INSERT OR IGNORE INTO player_hero_qa_backup VALUES(?,?,?,?)').run(id, heroId, row.state, Date.now());
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(plan.state), id, heroId);
            return { before: JSON.parse(row.state), after: plan, result: plan };
        });
    }
    async setQaHeroField(admin, id, heroId, field, value) {
        if (!['level', 'evolution', 'superStep', 'rebirth', 'reform'].includes(field) || !Number.isInteger(value))
            adminError('Trường QA hoặc giá trị không hợp lệ.');
        const hero = this.players.cards(this.target(id)).cards[heroId];
        if (!hero)
            adminError('Hero không thuộc tài khoản.', 404);
        const target = { level: hero.lv, evolution: hero.evo ?? 0, superStep: hero.super_step ?? 0, rebirth: hero.bre ?? 0, reform: Object.fromEntries(['hp', 'patk', 'matk', 'def', 'speed'].map(k => [k, hero[k + '_crystal'] ?? 0])), [field]: value };
        return this.applyQaHero(admin, id, heroId, target);
    }
    restoreQaHero(admin, id, heroId) {
        return this.change(admin, 'hero.qa.restore', id, () => {
            const backup = this.db.prepare('SELECT state FROM player_hero_qa_backup WHERE user_id=? AND id=?').get(id, heroId);
            const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(id, heroId);
            if (!backup || !row)
                adminError('Không có snapshot QA của hero này.', 404);
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(backup.state, id, heroId);
            this.db.prepare('DELETE FROM player_hero_qa_backup WHERE user_id=? AND id=?').run(id, heroId);
            return { before: JSON.parse(row.state), after: JSON.parse(backup.state), result: JSON.parse(backup.state) };
        });
    }
    async prepareQaReform(admin, id, heroId) {
        const cfg = await staticConfig('character_strengthen');
        // Fixture QA có audit: lùi đúng một mức HP để thử nút Cải Tạo thật rồi trở lại MAX.
        return this.change(admin, 'hero.qa.prepare_reform', id, () => {
            const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(id, heroId);
            if (!row)
                adminError('Hero không thuộc tài khoản.', 404);
            const hero = JSON.parse(row.state), level = hero.hp_crystal, rule = cfg[String(level)], previous = cfg[String(level - 1)];
            if (hero.c_id !== 32600 || level !== Math.max(...Object.keys(cfg).map(Number)) || hero.lv < rule?.need_level || !previous)
                adminError('Chỉ chuẩn bị fixture Vehito QA ở Cải Tạo HP tối đa theo nguồn.');
            const [type, amount] = rule.need_crstal_hp, resource = { 1: 'crystal', 2: 'adv_crystal', 3: 'super_crystal' }[type];
            if (!resource)
                adminError('Chưa biết loại Năng Tinh.');
            const rowProfile = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id), profile = JSON.parse(rowProfile.profile);
            const updated = { ...hero, hp_crystal: level - 1, hp: hero.hp - (rule.add_hp - previous.add_hp) };
            const p = { ...profile, food: Math.max(profile.food ?? 0, rule.need_food), [resource]: Math.max(profile[resource] ?? 0, amount) };
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(updated), id, heroId);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
            return { before: { hero, profile }, after: { hero: updated, profile: p }, result: { hero: updated, cost: { food: rule.need_food, [resource]: amount } } };
        });
    }
    equipmentDestinyInfo(id) { const target = this.target(id), svc = new EquipmentDestinyService(this.db); return { ...svc.catalog(), gemsOwned: svc.gems(target), power: new CombatPowerService(this.db).calculate(id), profile: this.players.profile(target, {}), equipment: this.players.cards(target).equip, recruitment: new GachaService(this.db).diagnostics(target), shop: new ShopService(this.db).diagnostics(target) }; }
    equipmentDestinyAction(admin, id, body) {
        if (admin.role === 'VIEWER')
            adminError('Tài khoản chỉ có quyền xem.', 403);
        const s = this.target(id), p = new URLSearchParams({ request_id: body.requestId });
        const methods = { bind: 'equip.fate_equip_bind', unbind: 'equip.fate_equip_unbind', upgrade: 'equip.fate_equip_levelup', upgrade_ten: 'equip.auto_fate_equip_levelup', synthesize: 'gem_fate.synthesis_gem_fate', socket: 'gem_fate.using_gem_fate', grant_gem: 'admin.fate_grant', grant_stone: 'admin.fate_grant', grant_voucher: 'admin.fate_voucher_grant', grant_material: 'admin.fate_material_grant' };
        if (!methods[body.action])
            adminError('Thao tác Vận Mệnh không hợp lệ.');
        if (body.action === 'grant_gem' && (body.gemTeam !== undefined || body.gemLevel !== undefined)) {
            const match = new EquipmentDestinyService(this.db).catalog().gems.filter((g) => g.team === body.gemTeam && g.quality === body.gemLevel);
            if (match.length !== 1 || body.configId !== undefined && body.configId !== match[0].id)
                adminError('Loại/cấp đá không khớp registry; không cấp đá thay thế.');
            body = { ...body, configId: match[0].id };
        }
        if (body.action === 'grant_gem' || body.action === 'grant_stone') {
            p.set('type', body.action === 'grant_gem' ? '50' : String(body.resourceType));
            p.set('config_id', body.action === 'grant_gem' ? String(body.configId) : '0');
            p.set('quantity', String(body.quantity));
        }
        if (body.action === 'grant_voucher' || body.action === 'grant_material') {
            p.set('config_id', String(body.configId));
            p.set('quantity', String(body.quantity));
        }
        if (body.equipmentId) {
            p.set('equip_id', body.equipmentId);
            p.set('major', body.equipmentId);
        }
        if (body.heroId)
            p.set('card_id', body.heroId);
        if (body.sort !== undefined)
            p.set('sort', String(body.sort));
        if (body.configId !== undefined)
            p.set('gem_id', String(body.configId));
        if (body.quantity !== undefined)
            p.set('gem_num', String(body.quantity));
        if (body.gemIds)
            p.set('gem_fates', body.gemIds.join('_'));
        return new EquipmentDestinyService(this.db).execute(s, methods[body.action], p, admin.id);
    }
    async welfareInfo(id) {
        const target = this.target(id), service = new WelfareService(this.db);
        return { enabled: Object.fromEntries(['level', 'vip_daily', 'vip_sign'].map(k => [k, service.enabled(target, k)])), once: await service.onceIndex(target), vip: await service.vipIndex(target), vipDiagnostics: await service.vipDiagnostics(target), levelRewards: await staticConfig('reward_once'), vipRewards: await staticConfig('new_vip_reward'), activities: await staticConfig('active_show'), scope: 'LOCAL TEST IMPLEMENTATION', notice: 'Quà VIP lấy từ config: nhận trực tiếp khi đủ chỗ; kho đầy gửi trọn gói vào thư, chưa cộng inventory. Không reset lịch sử nhận.' };
    }
    setWelfareEnabled(admin, id, system, enabled) {
        if (!['level', 'vip_daily', 'vip_sign'].includes(system) || typeof enabled !== 'boolean')
            adminError('Hệ thống phúc lợi chưa hỗ trợ.');
        return this.change(admin, 'welfare.enabled.set', id, () => {
            const profile = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile), settings = profile._local_welfare_enabled ?? {};
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, _local_welfare_enabled: { ...settings, [system]: enabled } }), id);
            return { before: { system, enabled: settings[system] !== false }, after: { system, enabled }, result: { system, enabled } };
        });
    }
    async item(admin, id, configId, action, amount) {
        const cfg = (await staticConfig('item'))[String(configId)];
        if (!cfg || cfg.is_show !== 1 || !Number.isSafeInteger(cfg.stack) || cfg.stack < 1)
            adminError('Vật phẩm chưa nằm trong inventory schema đã hỗ trợ.');
        return this.change(admin, 'item.' + action.toLowerCase(), id, () => {
            if (!['ADD', 'SET', 'REMOVE'].includes(action) || !Number.isSafeInteger(amount) || amount < 0 || amount > 1_000_000)
                adminError('Số lượng không hợp lệ.');
            const before = this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(id, configId)?.quantity ?? 0;
            const quantity = action === 'SET' ? amount : before + (action === 'ADD' ? amount : -amount);
            if (!Number.isSafeInteger(quantity) || quantity < 0 || quantity > cfg.stack)
                adminError(`Số lượng phải từ0 đến${cfg.stack}.`);
            this.db.prepare('INSERT INTO player_items VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(id, configId, quantity);
            return { before: { configId, quantity: before }, after: { configId, quantity }, result: { configId, quantity } };
        });
    }
    async grantEquipment(admin, id, configId) {
        if (!(await contentIndex('equipment_catalog')).some(r => r.configId === configId && r.grantable))
            adminError('Trang bị thiếu định nghĩa hoặc icon đã xác minh.');
        const cfg = (await staticConfig('equip'))[String(configId)];
        if (!cfg)
            adminError('Không có định nghĩa trang bị.');
        const equipment = createBaseEquipment(`localae${id}-${randomUUID().replaceAll('-', '')}`, configId, cfg);
        return this.change(admin, 'equipment.grant', id, target => {
            const count = Object.keys(this.players.cards(target).equip).length;
            if (count >= this.players.profile(target, {}).equip_max)
                adminError('Kho trang bị đã đầy.');
            this.db.prepare('INSERT INTO player_equipment VALUES(?,?,?,?)').run(id, equipment.id, configId, JSON.stringify(equipment));
            return { before: { count }, after: equipment, result: equipment };
        });
    }
    async assignEquipment(admin, id, equipmentId, heroId) {
        if (admin.role === 'VIEWER')
            adminError('Tài khoản chỉ có quyền xem.', 403);
        const target = this.target(id), cards = this.players.cards(target), item = cards.equip[equipmentId];
        if (!item)
            adminError('Trang bị không thuộc tài khoản.', 404);
        const cfg = (await staticConfig('equip'))[String(item.c_id)];
        createBaseEquipment(equipmentId, item.c_id, cfg);
        const alignment = cards.alignment.flat(), positions = structuredClone(cards.equip_pos);
        if (heroId !== null) {
            if (!Object.hasOwn(cards.cards, heroId))
                adminError('Hero không thuộc tài khoản.', 404);
            const index = alignment.indexOf(heroId);
            if (index < 0)
                adminError('Hãy xếp hero vào trận hình trên Android trước.');
            const held = Object.entries(positions).find(([, items]) => items.includes(equipmentId));
            if (held && Number(held[0]) !== index)
                adminError('Trang bị đang gắn cho hero khác; hãy tháo trước.');
            positions[String(index)][cfg.sort - 1] = equipmentId;
        }
        else
            for (const items of Object.values(positions))
                for (let i = 0; i < items.length; i++)
                    if (items[i] === equipmentId)
                        items[i] = '0';
        const form = new URLSearchParams({ align_1: cards.alignment[0].join('_'), align_2: cards.alignment[1].join('_'), formation: String(cards.formation.current) });
        for (let i = 0; i < 10; i++)
            form.set('equip_' + (i < 5 ? `1${i + 1}` : `2${i - 4}`), positions[String(i)].join('_'));
        await this.players.saveFormation(target, form, (before, after) => {
            if (JSON.stringify(before) !== JSON.stringify({ alignment: cards.alignment, formation: cards.formation, equip_pos: cards.equip_pos }))
                adminError('Trận hình đã thay đổi trong lúc thao tác; hãy làm mới rồi thử lại.', 409);
            audit(this.db, admin.id, heroId === null ? 'equipment.unequip' : 'equipment.equip', id, 'Trang bị GM qua validator trận hình gốc', before, after);
        });
        return { ok: true, notice: 'Đã lưu trang bị. Đăng nhập lại Android để nạp state mới.', formation: this.players.cards(target).equip_pos };
    }
    heroSkills(id, heroId) { return new HeroSkillService(this.db).info(this.target(id), heroId); }
    unlockHeroSkill(admin, id, heroId, index) { return new HeroSkillService(this.db).unlock(this.target(id), heroId, index, admin); }
    selectHeroSkills(admin, id, heroId, slots) { return new HeroSkillService(this.db).select(this.target(id), heroId, slots, admin); }
    levelHeroSkill(admin, id, heroId, index, level) { return new HeroSkillService(this.db).setLevel(this.target(id), heroId, index, level, admin); }
    async setEquipmentLevel(admin, id, equipmentId, level) {
        const [levels, defs] = await Promise.all(['equip_strongthen', 'equip'].map(staticConfig));
        return this.change(admin, 'equipment.qa.level', id, target => {
            const before = this.players.cards(target).equip[equipmentId];
            if (!before)
                adminError('Trang bị không thuộc tài khoản.', 404);
            const cfg = defs[String(before.c_id)];
            createBaseEquipment(equipmentId, before.c_id, cfg);
            const playerLevel = this.players.profile(target, { level: 1 }).level, cap = Math.min(Object.keys(levels).length, playerLevel);
            if (!Number.isSafeInteger(playerLevel) || playerLevel < 1 || !Number.isSafeInteger(level) || level < 1 || level > cap || !levels[String(level)])
                adminError('Cấp QA vượt config/cấp người chơi.');
            const after = { ...before, lv: level };
            this.db.prepare('UPDATE player_equipment SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(after), id, equipmentId);
            return { before, after, result: { ok: true, mode: 'GM TEST ACTION', equipment: after, cap, notice: 'Chỉ đặt cấp QA. Giữ nguyên st_lv/tẩy luyện/rèn/ownership; không tiêu Sắt.' } };
        });
    }
    async sendMail(admin, id, title, body, attachments = [], requestId) {
        if (requestId !== undefined && !/^[A-Za-z0-9_.:-]{8,160}$/.test(requestId))
            adminError('Mã gửi thư không hợp lệ.');
        if (!title.trim() || title.trim().length > 80 || !body.trim() || body.trim().length > 4000)
            adminError('Tiêu đề/nội dung thư không hợp lệ.');
        if (!Array.isArray(attachments) || attachments.length > 3)
            adminError('Tối đa ba dòng đính kèm.');
        const rewards = [], descriptions = [];
        for (const a of attachments) {
            if (!a || !Number.isSafeInteger(a.quantity) || a.quantity < 1 || a.quantity > (a.kind === 'currency' ? 100_000_000 : 1_000_000))
                adminError('Số lượng đính kèm không hợp lệ: tài nguyên tối đa100.000.000, vật phẩm tối đa1.000.000 mỗi dòng.');
            if (a.kind === 'auxiliary') {
                const preset = auxiliaryPreset(a);
                rewards.push(preset);
                descriptions.push(preset);
            }
            else if (a.kind === 'empowered_gem') {
                fatePreset(a);
                if (a.quantity > 50)
                    adminError('Tối đa50 đá Ban Sức mỗi dòng.');
                rewards.push({ kind: 'empowered_gem', configId: a.configId, skillId: a.skillId, quantity: a.quantity });
                descriptions.push(a);
            }
            else if (a.kind === 'fate_word' || a.kind === 'fate_stone') {
                const name = a.kind === 'fate_word' ? 'equip_gem_fate_word' : 'equip_gem_fate_stone';
                if (!(await staticConfig(name))[a.configId])
                    adminError('Vật liệu Ban Sức thiếu config.');
                rewards.push([a.kind === 'fate_word' ? 109 : 108, a.configId, a.quantity]);
                descriptions.push(a);
            }
            else if (a.kind === 'transformed_hero') {
                if (a.quantity > 5)
                    adminError('Tối đa5tướng mỗi dòng.');
                const preset = await transformedMailPreset(a.configId, a.sourceId);
                rewards.push({ ...preset, quantity: a.quantity });
                descriptions.push(preset.preview);
            }
            else if (a.kind === 'hero') {
                if (a.quantity > 5)
                    adminError('Mỗi dòng tối đa năm tướng.');
                const cfg = (await staticConfig('character_detail'))[String(a.configId)];
                createBaseHero('mail-preview', a.configId, cfg);
                if ((await heroResources()).get(a.configId)?.assetStatus !== 'FULL ASSETS' || (await heroSkillIndex()).heroByConfigId[String(a.configId)].skills.some((s) => s.slot === 1 && !s.exists))
                    adminError('Hero đính kèm thiếu resource hoặc skill chính.');
                rewards.push([5, a.configId, a.quantity]);
                descriptions.push({ ...a, name: cfg.name });
            }
            else if (a.kind === 'pet') {
                const cfg = petConfig('pet_detail')[a.configId];
                if (!cfg || a.quantity !== 1)
                    adminError('Chọn đúng1PET trong catalog nguồn; loài duy nhất không nhận trùng.');
                rewards.push([25, a.configId, 1]);
                descriptions.push({ ...a, name: cfg.name });
            }
            else if (a.kind === 'equipment') {
                if (a.quantity > 5)
                    adminError('Mỗi dòng tối đa năm trang bị.');
                const cfg = (await staticConfig('equip'))[String(a.configId)];
                createBaseEquipment('mail-preview', a.configId, cfg);
                if (!(await contentIndex('equipment_catalog')).some(r => r.configId === a.configId && r.grantable))
                    adminError('Trang bị đính kèm thiếu icon/schema.');
                rewards.push([7, a.configId, a.quantity]);
                descriptions.push({ ...a, name: cfg.name });
            }
            else if (a.kind === 'item') {
                const cfg = (await staticConfig('item'))[String(a.configId)];
                if (!mailRewardItem(a.configId, cfg, (await staticConfig('exchange'))[String(cfg?.sort)]))
                    adminError('Vật phẩm đính kèm chưa có schema hoặc công thức mảnh hợp lệ.');
                if (a.quantity > cfg.stack)
                    adminError(`${cfg.name} #${a.configId}: số lượng ${a.quantity.toLocaleString('vi-VN')} vượt giới hạn ${cfg.stack.toLocaleString('vi-VN')} mỗi dòng theo config. Chưa tạo thư; hãy giảm số lượng.`);
                rewards.push([6, a.configId, a.quantity]);
                descriptions.push({ ...a, name: cfg.name });
            }
            else if (a.kind === 'currency') {
                if (a.currency === 'ticket') {
                    if (a.quantity > 9999)
                        adminError('Tối đa9999 vé vàng mỗi dòng.');
                    rewards.push([106, 0, a.quantity]);
                    descriptions.push({ ...a, name: 'Phiếu giảm giá · Vé vàng chữ S' });
                    continue;
                }
                const type = { coin: 9, food: 1, metal: 2, crystal: 4, silver: 15, pet_crystal: 24, pet_exp_ball: 26, pet_skill_stone: 27, grace: 17, grace_high: 18, adv_crystal: 20, super_crystal: 40, min_fate_stone: 41, mid_fate_stone: 42, max_fate_stone: 43 }[a.currency];
                if (!type)
                    adminError('Tài nguyên đính kèm chưa hỗ trợ.');
                rewards.push([type, 0, a.quantity]);
                descriptions.push(a);
            }
            else
                adminError('Loại đính kèm chưa hỗ trợ.');
        }
        // gift/reward dùng tuple gốc; tiêu đề vẫn là dòng đầu của content.
        const message = { id: 'localadmin-' + randomUUID(), content: title.trim() + '\n\n' + body.trim(), attachments: rewards };
        const requestKey = requestId ? `admin-mail:${admin.id}:${requestId}` : null;
        const fingerprint = createHash('sha256').update(JSON.stringify({ content: message.content, attachments: rewards })).digest('hex');
        return this.change(admin, 'mail.send', id, () => {
            if (requestKey) {
                const old = this.db.prepare('SELECT method,fingerprint,result FROM player_content_operations WHERE user_id=? AND request_key=?').get(id, requestKey);
                if (old) {
                    if (old.method !== 'admin.mail.send' || old.fingerprint !== fingerprint)
                        adminError('Mã gửi thư đã dùng cho nội dung khác.', 409);
                    const saved = JSON.parse(String(old.result));
                    return { before: { mailId: saved.id }, after: { mailId: saved.id, replayed: true }, result: { ...saved, replayed: true } };
                }
            }
            this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(id, message.id, message.content, JSON.stringify(rewards));
            if (requestKey)
                this.db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(id, requestKey, 'admin.mail.send', fingerprint, JSON.stringify(message), Date.now());
            return { before: null, after: { ...message, details: descriptions, claimStatus: 'UNCLAIMED' }, result: message };
        });
    }
    auditLog(query) {
        const { page, pageSize } = pageQuery(query), where = [], params = [];
        for (const [field, key] of [['a.admin_id', 'adminId'], ['a.target_user_id', 'userId'], ['a.action', 'action']])
            if (query[key]) {
                where.push(field + '=?');
                params.push(String(query[key]).slice(0, 80));
            }
        for (const [key, op] of [['from', '>='], ['to', '<=']])
            if (query[key]) {
                const t = Date.parse(String(query[key]));
                if (!Number.isFinite(t))
                    adminError('Ngày lọc không hợp lệ.');
                where.push('a.created_at' + op + '?');
                params.push(t);
            }
        const clause = where.length ? ' WHERE ' + where.join(' AND ') : '', from = ' FROM admin_audit a LEFT JOIN admin_users u ON u.id=a.admin_id';
        const total = this.db.prepare('SELECT COUNT(*) AS n' + from + clause).get(...params).n;
        return { total, page, pageSize, items: this.db.prepare('SELECT a.*,u.username AS admin_username' + from + clause + ' ORDER BY a.id DESC LIMIT ? OFFSET ?').all(...params, pageSize, (page - 1) * pageSize) };
    }
    async requests(queue = false) {
        if (!this.journalPath)
            return { items: [], scope: 'Chưa bật journal' };
        const tail = async (path) => { let file; try {
            file = await open(path, 'r');
            const size = (await file.stat()).size, start = Math.max(0, size - 1_048_576), buf = Buffer.alloc(size - start);
            await file.read(buf, 0, buf.length, start);
            const lines = buf.toString('utf8').split('\n');
            if (start)
                lines.shift();
            return lines.flatMap(line => { try {
                return [JSON.parse(line)];
            }
            catch {
                return [];
            } });
        }
        catch {
            return [];
        }
        finally {
            await file?.close();
        } };
        const recent = (await tail(this.journalPath)).sort((a, b) => String(a.completedAt ?? a.timestamp).localeCompare(String(b.completedAt ?? b.timestamp)));
        const safe = (r) => ({ timestamp: r.timestamp, userId: r.gameContext?.userId ?? null, method: r.method, path: r.path, rpc: r.query?.method ?? '', status: r.response?.statusCode, durationMs: r.durationMs });
        if (!queue)
            return { items: recent.filter(r => !r.path.startsWith('/admin')).slice(-150).reverse().map(safe), scope: 'Tối đa150 request cuối trong1MiB journal' };
        const groups = new Map();
        for (const r of await tail(join(dirname(this.journalPath), 'unimplemented.jsonl'))) {
            const key = r.httpMethod + ' ' + r.path + ' ' + r.method;
            const old = groups.get(key), known = endpointEvidence[r.method];
            groups.set(key, { method: r.method, path: r.path, count: (old?.count ?? 0) + 1, firstSeen: old?.firstSeen && old.firstSeen < r.timestamp ? old.firstSeen : r.timestamp, lastSeen: old?.lastSeen && old.lastSeen > r.timestamp ? old.lastSeen : r.timestamp, latestStatus: r.currentResponse?.statusCode, handler: known?.caller ?? r.caller ?? 'UNKNOWN', feature: known?.feature ?? 'UNKNOWN', screen: known?.screen ?? 'UNKNOWN', blocking: known?.blocking ?? 'UNKNOWN', schemaStatus: known?.schemaStatus ?? 'UNKNOWN', priority: r.method.startsWith('private_city.') ? 1 : known ? 2 : 9 });
        }
        for (const r of recent) {
            for (const g of groups.values())
                if (g.path === r.path && g.method === r.query?.method)
                    g.latestStatus = r.response?.statusCode;
        }
        return { items: [...groups.values()].sort((a, b) => a.priority - b.priority), scope: 'Lịch sử trong1MiB queue; latestStatus đối chiếu journal, không suy Android acceptance' };
    }
    async dashboard() {
        const n = (sql) => this.db.prepare(sql).get().n;
        let databaseBytes = 0;
        for (const path of [this.dbPath, this.dbPath + '-wal'])
            try {
                databaseBytes += (await stat(path)).size;
            }
            catch { }
        const requests = await this.requests(), queue = await this.requests(true);
        return { accounts: n('SELECT COUNT(*) AS n FROM users'), players: n('SELECT COUNT(*) AS n FROM player_state'), sessions: n('SELECT COUNT(*) AS n FROM sessions WHERE expires_at>' + Date.now()), heroes: n('SELECT COUNT(*) AS n FROM player_heroes'), items: n('SELECT COALESCE(SUM(quantity),0) AS n FROM player_items'), unreadMail: n('SELECT COUNT(*) AS n FROM player_mail WHERE read_at IS NULL'), uptimeSeconds: Math.floor((Date.now() - this.started) / 1000), databaseBytes, databaseVersion: this.db.prepare('PRAGMA user_version').get().user_version, recentRequests: requests.items.length, unimplemented: queue.items.filter((r) => r.latestStatus === 501).length, errors: requests.items.filter((r) => r.status >= 500).slice(0, 6), android: 'Chưa kiểm tra trong phiên web', environment: 'LOCAL TEST SERVER' };
    }
    async backup(admin) {
        if (admin.role !== 'OWNER')
            adminError('Chỉ OWNER được tạo bản sao lưu.', 403);
        const dir = join(dirname(this.dbPath), 'backups');
        await mkdir(dir, { recursive: true });
        const path = join(dir, 'admin-' + Date.now() + '-' + randomUUID() + '.db');
        await backup(this.db, path);
        const check = new DatabaseSync(path, { readOnly: true });
        try {
            if (Object.values(check.prepare('PRAGMA quick_check').get())[0] !== 'ok')
                throw new Error('Backup integrity');
        }
        finally {
            check.close();
        }
        audit(this.db, admin.id, 'database.backup', null, 'Tạo bản sao lưu SQLite', null, { file: basename(path) });
        return { file: basename(path), bytes: (await stat(path)).size };
    }
}
