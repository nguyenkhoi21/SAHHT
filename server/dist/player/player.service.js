import {reconcileBoundEquipment} from "./offline-formation-equipment.mjs";
import { RestoredEventSettlement } from './restored-event-settlement.js';
import { PlayerNotices } from './player-notices.js';
import { EventPlanner } from './event-planner.js';
import { ClientPresentation } from './client-presentation.js';
import { InviteCodeService } from './invite-code.service.js';
import { HotCards } from './hot-cards.js';
import { petWire, petCache } from './pet-state.js';
import { fateClientSnapshot, fateCache, fateRewardPreview } from './fate-empowerment.js';
import { allianceIdentity } from './alliance.service.js';
import { godfieldState } from './godfield.service.js';
import { aetherMailPlan, receiveAetherMails } from './aether-mail.js';
import { auxiliaryWire, auxiliaryPositions, validateAuxiliaryFormation } from './auxiliary-state.js';
import { superSkillProjection, battleSkillConfig } from './battle-skill-registry.js';
import { createBaseHero, characterName, initialHeroSkills, equipmentClientState, heroBindingClientState } from './definitions.js';
import { transformationClientState } from './transformation-graph.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { readStaticConfigSync as readConfigSync } from './local-content.js';
import { ProgressionService } from './progression.service.js';
import { CombatPowerService } from './combat-power.js';
import { ArenaCombatService } from './arena-combat.js';
import { appearanceState } from './appearance-state.js';
import { EventCalendarService } from './event-calendar.js';
import { assistantEffectWire, slotState, FormationSystemsService, validateExtraAssignments } from './formation-systems.js';
import { projectedVitals, PlayerVitalsService, playerLevelFields } from './player-vitals.js';
const configs = new Map();
export function staticConfig(name) {
    if (!/^[a-z_0-9]+$/.test(name))
        throw new Error('Tên config không hợp lệ');
    if (!configs.has(name))
        configs.set(name, Promise.resolve(readConfigSync(name)));
    return configs.get(name);
}
export const emptySlots = (count) => Object.fromEntries(Array.from({ length: 10 }, (_, i) => [String(i), Array(count).fill('0')]));
export class PlayerService {
    db;
    constructor(db) {
        this.db = db;
    }
    async ensure(session) {
        const definitions = await staticConfig('character_detail');
        const legacy = this.db.prepare('SELECT id,state FROM player_heroes WHERE user_id=?').all(session.user_id).filter(r => { const h = JSON.parse(r.state); return [1, 2, 3, 4, 5].some(n => !h['s_' + n]); });
        if (legacy.length) {
            this.db.exec('BEGIN IMMEDIATE');
            try {
                for (const row of legacy) {
                    const h = JSON.parse(row.state);
                    if (h.evo && [1, 2, 3].some(n => !h['s_' + n]))
                        throw new Error('Hero tiến hóa thiếu skill, cần đối chiếu trước khi khởi tạo.');
                    const cfg = definitions[String(h.c_id)];
                    if (!cfg)
                        throw new Error('Thiếu config hero legacy.');
                    this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify({ ...initialHeroSkills(cfg), ...h }), session.user_id, row.id);
                }
                audit(this.db, null, 'hero.skill.schema_init', session.user_id, 'Bổ sung field skill thiếu cho hero Lv1/evo0; giữ giá trị đã có', { ids: legacy.map(r => r.id) }, { count: legacy.length });
                this.db.exec('COMMIT');
            }
            catch (e) {
                this.db.exec('ROLLBACK');
                throw e;
            }
        }
        if (this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(session.user_id))
            return;
        const equipDefinitions = await staticConfig('equip');
        // LOCAL TEST IMPLEMENTATION: hai hero có thật, cấp 1, chỉ số base; không mô phỏng tăng trưởng.
        const heroIds = [5300, 51200];
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(session.user_id)) {
                this.db.exec('COMMIT');
                return;
            }
            const formation = { alignment: [Array(5).fill('-1'), Array(5).fill('-1')], formation: { own: [1], current: 1 }, equip_pos: emptySlots(4) };
            this.db.prepare('INSERT INTO player_state VALUES(?,?,?)').run(session.user_id, JSON.stringify({ show_name: session.username }), JSON.stringify(formation));
            heroIds.forEach((cid, index) => {
                const cfg = definitions[String(cid)];
                if (!cfg)
                    throw new Error('Hero test không có trong config');
                const id = `localh${session.user_id}-${index + 1}`;
                const card = createBaseHero(id, cid, cfg);
                this.db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(session.user_id, id, cid, JSON.stringify(card));
            });
            if (!equipDefinitions['10101'])
                throw new Error('Equipment test không có trong config');
            const id = `locale${session.user_id}-1`;
            this.db.prepare('INSERT INTO player_equipment VALUES(?,?,?,?)').run(session.user_id, id, 10101, JSON.stringify({ id, c_id: 10101, lv: 1, st_lv: 0 }));
            // Thẻ đổi tên 208 có is_show=1; một thẻ local để thử mutation profile sau này.
            this.db.prepare('INSERT INTO player_items VALUES(?,?,?)').run(session.user_id, 208, 1);
            this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at) VALUES(?,?,?,NULL)').run(session.user_id, 'local-welcome', 'Chào mừng đến máy chủ thử nghiệm cục bộ.\nDữ liệu này chỉ dùng để kiểm thử local, không liên quan tài khoản dịch vụ chính thức.');
            this.db.exec('COMMIT');
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
    // Danh sách server chỉ cần cấp hiện tại: không tính combat/duyệt đội hình Arena.
    loginLevel(session) {
        const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
        if (!row)
            throw Object.assign(new Error('Chưa có nhân vật để đọc cấp.'), { statusCode: 422 });
        return playerLevelFields(JSON.parse(row.profile)).level;
    }
    profile(session, base) {
        const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
        const normalized = projectedVitals(JSON.parse(row.profile));
        const profile = Object.fromEntries(Object.entries(normalized).filter(([k]) => !k.startsWith('_local_')));
        // Preview nhiệm vụ không được ghi đè Player Level thật.
        const arena = new ArenaCombatService(this.db);
        if (!this.db.isTransaction)
            new RestoredEventSettlement(this.db).deliver(session.user_id);
        const notices = new PlayerNotices(this.db).wire(session.user_id);
        return { ...base, local_notices: notices, alerts: { ...base.alerts, notify: notices.mail }, level: 1, exp: 0, exp_max: 0, card_max: 20, equip_max: 20, min_fate_stone: 0, mid_fate_stone: 0, max_fate_stone: 0, ...profile, local_client_settings: new ClientPresentation(this.db).wire(profile.level ?? 1), local_event_visibility: { '905': !!new EventPlanner(this.db).resolveSky('server.905') }, local_main_events: new EventPlanner(this.db).visibility(profile.level ?? 1, profile.vip ?? 0), combat: new CombatPowerService(this.db).calculate(session.user_id).combat, arena_point: arena.status(session.user_id).points, arena_rank: arena.rank(session.user_id), ...new ProgressionService(this.db).profileFields(session.user_id, profile), tutorial_state: normalized._local_tutorial ? { phase: normalized._local_tutorial.phase, replay: normalized._local_tutorial.replay === true } : null, ...allianceIdentity(this.db, session.user_id), uid: session.game_uid, role: session.role, server_time: Math.floor(Date.now() / 1000) };
    }
    mainPage(session, base) {
        new PlayerVitalsService(this.db).sync(session.user_id);
        const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
        const profile = JSON.parse(row.profile);
        base = { ...base, active_switch: new EventCalendarService(this.db).mainSwitch(profile.level ?? 1, profile.vip ?? 0) };
        const arena = new ArenaCombatService(this.db), status = arena.status(session.user_id);
        // Refresh schema instance cũ khi trở về Main; Lua popup yêu cầu atts là table.
        const cache = base._client_cache_update ?? {};
        const inventory = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(session.user_id), gems = this.db.prepare('SELECT config_id,quantity FROM player_fate_gems WHERE user_id=?').all(session.user_id);
        const values = (rows) => ({ update: Object.fromEntries(rows.filter(r => Number(r.quantity) > 0).map(r => [String(r.config_id), Number(r.quantity)])), remove: rows.filter(r => Number(r.quantity) === 0).map(r => String(r.config_id)) });
        const slots = new ProgressionService(this.db).slots(session.user_id), itemCache = values(inventory), appearance = appearanceState(this.db, session.user_id);
        const notices = new PlayerNotices(this.db).wire(session.user_id);
        return { ...base, ...appearance, local_notices: notices, alerts: { ...base.alerts, notify: notices.mail }, _client_cache_update: { ...cache, ...petCache(this.db, session.user_id), cards: { ...cache.cards, skin: { update: appearance.skin }, used_skin: { update: appearance.used_skin }, position_num: { update: slots.position_num }, alternate_num: { update: slots.alternate_num } }, item: { items: { ...itemCache, update: Object.fromEntries(Object.entries(itemCache.update).map(([id, n]) => [id, [n]])) } }, gem_fate: { ...fateCache(this.db, session.user_id), _gem_fate: values(gems) }, equip: { ...cache.equip, _equip: { update: this.cards(session).equip, remove: [] } } }, combat: new CombatPowerService(this.db).calculate(session.user_id).combat, arena_point: status.points, arena_rank: arena.rank(session.user_id), ...(JSON.parse(row.profile)._local_mission_preview === true ? { alerts: { ...base.alerts, notify: notices.mail, reward: false, diary: 0 } } : {}) };
    }
    async missions(session) {
        const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
        if (JSON.parse(row.profile)._local_mission_preview !== true)
            throw Object.assign(new Error('Chỉ hỗ trợ preview nhiệm vụ local'), { statusCode: 422 });
        const cfg = await staticConfig('reward_diary');
        const ids = ['1', '2', '3', '4', '5'];
        if (ids.some(id => !cfg[id] || !(cfg[id].num > 0) || typeof cfg[id].story !== 'string'))
            throw new Error('Thiếu config nhiệm vụ preview');
        // LOCAL TEST IMPLEMENTATION: danh sách đọc, không có completion/claim/progression.
        return { diary: { result: Object.fromEntries(ids.map(id => [id, 0])) }, diary_done: {}, diaryscore: 0, diaryscore_done: [] };
    }
    cards(session, withAttributes = false) {
        const row = this.db.prepare('SELECT formation,profile FROM player_state WHERE user_id=?').get(session.user_id);
        const heroDefinitions = battleSkillConfig('character_detail');
        const levelProjection = withAttributes ? { heroes: heroDefinitions, levels: readConfigSync('character_base'), rates: readConfigSync('character_base_rate'), player: JSON.parse(row.profile).level ?? 1 } : null;
        const finalAttributes = withAttributes ? Object.fromEntries(new CombatPowerService(this.db).calculate(session.user_id, true).heroes.map(h => [h.id, h.attributes])) : undefined;
        const instances = (table) => Object.fromEntries(this.db.prepare(`SELECT id,state FROM ${table} WHERE user_id=?`).all(session.user_id).map(r => { const raw = JSON.parse(r.state), normalized = table === 'player_heroes' ? { ...raw, ...superSkillProjection(raw, heroDefinitions[raw.c_id] ?? {}) } : raw, projected = table === 'player_heroes' && withAttributes ? transformationClientState(normalized) : normalized; const state = Object.fromEntries(Object.entries(projected).filter(([key]) => !key.startsWith('_local_'))); return [r.id, table === 'player_equipment' ? equipmentClientState(state) : { hp_crystal: 0, patk_crystal: 0, matk_crystal: 0, def_crystal: 0, speed_crystal: 0, ...heroBindingClientState(state) }]; }));
        const items = Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=? AND quantity>0').all(session.user_id).map(r => [String(r.config_id), [r.quantity]]));
        // Projection chỉ xuất ở transport Android; không đưa vào snapshot domain/QA để lưu ngược DB.
        const cards = Object.fromEntries(Object.entries(instances('player_heroes')).map(([id, h]) => { if (!finalAttributes || !levelProjection)
            return [id, h]; const cfg = levelProjection.heroes[h.c_id]; let pre_exp = 0; for (let lv = 1; lv < h.lv; lv++)
            pre_exp += (levelProjection.levels[lv]?.exp ?? 0) * (levelProjection.rates[cfg.quality]?.exp_rate ?? 0); return [id, { ...h, pre_exp, level_max: Math.min(255, levelProjection.player + 5, cfg.level_max > 1 ? cfg.level_max : 255), element_break: h.element_break ?? 0, client_final_attributes: finalAttributes[id] }]; }));
        return { ...fateClientSnapshot(this.db, session.user_id), ...appearanceState(this.db, session.user_id), battle_card_num: new ProgressionService(this.db).slots(session.user_id), cards, equip: instances('player_equipment'), items, gem_fate: Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_fate_gems WHERE user_id=? AND quantity>0').all(session.user_id).map(r => [String(r.config_id), r.quantity])),
            ...JSON.parse(row.formation), formation_bonus_addition: JSON.parse(row.formation).formation_bonus_addition ?? {}, assistant_effect: assistantEffectWire(JSON.parse(row.formation)), ...slotState(JSON.parse(row.formation)), god_field_ids: { '1': [], '2': [], '3': [] },
            equip_pos_1: emptySlots(4), equip_pos_2: emptySlots(4), equip_pos_3: emptySlots(4),
            bonus_equip_pos: Object.fromEntries(Array.from({ length: 10 }, (_, i) => [String(i + 200), Array(4).fill('0')])),
            ass_equip_pos: Object.fromEntries(Array.from({ length: 10 }, (_, i) => [String(i + 100), Array(4).fill('0')])),
            ...auxiliaryWire(this.db, session.user_id), ...auxiliaryPositions(JSON.parse(row.formation)), ...godfieldState(this.db, session.user_id), ...petWire(this.db, session.user_id) };
    }
    async saveFormation(session, form, onSaved) {
        // Nạp config trước snapshot; từ snapshot đến COMMIT không nhường event loop.
        const [definitions, heroDefs, formationDefs] = await Promise.all(['equip', 'character_detail', 'formation'].map(staticConfig));
        const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
        const read = (key, count) => {
            const values = form.getAll(key);
            if (values.length !== 1)
                return fail(`Thiếu hoặc trùng ${key}`);
            const result = values[0].split('_');
            if (result.length !== count || result.some(v => !v))
                return fail(`Sai cấu trúc ${key}`);
            return result;
        };
        const cards = this.cards(session);
        const alignment = [read('align_1', 5), read('align_2', 5)];
        const heroes = alignment.flat().filter(id => id !== '-1');
        if (heroes.some(id => heroDefs[String(cards.cards[id]?.c_id)]?.skill_num === 0))
            fail('Thẻ nguyên liệu không thể ra trận.');
        if (new Set(heroes).size !== heroes.length || heroes.some(id => !Object.hasOwn(cards.cards, id)))
            fail('Hero không thuộc tài khoản hoặc bị trùng');
        // Slot theo quyền tiến trình/QA, độc lập với sơ đồ vị trí.
        if (alignment.flat().some((id, index) => id !== '-1' && (index < 5 ? index >= cards.battle_card_num.position_num : index - 5 >= cards.battle_card_num.alternate_num)))
            fail('Vị trí local chưa mở');
        // Lua setTeamFormationData tự chọn 1..6 theo ô trống của lưới sáu ô.
        // Chỉ nhận sơ đồ có hoán vị 0..5 được config gốc chứng minh.
        const formationKey = form.get('formation') ?? '', layout = formationDefs[formationKey], positions = ['a', 'b', 'c', 'd', 'e', 'f'].map(k => layout?.['position_' + k]);
        if (form.getAll('formation').length !== 1 || !/^\d+$/.test(formationKey) || !layout || positions.some(v => !Number.isInteger(v)) || positions.slice().sort((a, b) => a - b).join(',') !== '0,1,2,3,4,5')
            fail('Trận hình không có sơ đồ hợp lệ trong config.');
        const formation = { ...cards.formation, own: [...new Set([...(cards.formation.own ?? []), Number(formationKey)])], current: Number(formationKey) };
        const equipPos = {};
        const equipmentIds = [];
        for (let i = 0; i < 10; i++) {
            const suffix = i < 5 ? `1${i + 1}` : `2${i - 4}`;
            equipPos[String(i)] = read(`equip_${suffix}`, 4);
        }
        reconcileBoundEquipment(cards, alignment, equipPos, definitions);
        for (let i = 0; i < 10; i++) {
            const suffix = i < 5 ? `1${i + 1}` : `2${i - 4}`;

            for (let slot = 0; slot < 4; slot++) {
                const id = equipPos[String(i)][slot];
                if (id === '0')
                    continue;
                const item = cards.equip[id];
                if (!item || alignment.flat()[i] === '-1')
                    fail('Trang bị hoặc hero không hợp lệ');
                if (item.bind_card && item.bind_card !== alignment.flat()[i])
                    fail('Trang bị Vận Mệnh đang khóa với tướng khác.');
                // game_util.equipInEquipPos dùng sort 1..4 tương ứng slot của equip_pos.
                if (Number(definitions[String(item.c_id)]?.sort) !== slot + 1)
                    fail('Sai loại ô trang bị');
                equipmentIds.push(id);
            }
        }
        if (new Set(equipmentIds).size !== equipmentIds.length)
            fail('Trang bị không thể dùng hai lần');
        for (let i = 0; i < 10; i++) {
            const hero = cards.cards[alignment.flat()[i]];
            if (!hero)
                continue;
            for (const eid of hero.bind_equip ?? []) {
                if (eid && String(eid) !== '0') {
                    const item = cards.equip[String(eid)];
                    if (!item || item.bind_card !== hero.id || equipPos[String(i)][definitions[String(item.c_id)]?.sort - 1] !== String(eid))
                        fail('Cần mở khóa Vận Mệnh trước khi thay trang bị đã ràng buộc.');
                }
            }
        }
        for (const [key, value] of form) {
            if (/^(ass_talisman_|ass_equip_)/.test(key) && value.split('_').some(v => v !== '0'))
                fail('Trang bị Trợ Uy chưa được hỗ trợ');
        }
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const stored = JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(session.user_id).formation)), next = { ...stored, alignment, formation, equip_pos: equipPos };
            for (const system of ['assistant', 'destiny']) {
                if (form.getAll(system).length > 1)
                    fail('Trùng trường ô phụ.');
                if (form.has(system))
                    new FormationSystemsService(this.db).assign(next, system, form.get(system).split('_'));
            }
            // Người dùng cho phép tích hợp Pha29; kiểm bản sao trước khi nạp live.
            validateAuxiliaryFormation(this.db, session.user_id, next, form);
            validateExtraAssignments(this.db, session.user_id, next);
            this.db.prepare('UPDATE player_state SET formation=? WHERE user_id=?').run(JSON.stringify(next), session.user_id);
            onSaved?.({ alignment: cards.alignment, formation: cards.formation, equip_pos: cards.equip_pos }, { alignment, formation, equip_pos: equipPos });
            this.db.exec('COMMIT');
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
        const updated = this.cards(session, true);
        return { ...updated, magic_pos: updated.talisman_pos };
    }
    mail(session) {
        new InviteCodeService(this.db).syncVip(session.user_id);
        new HotCards(this.db).deliver(session.user_id);
        new RestoredEventSettlement(this.db).deliver(session.user_id);
        const messages = this.db.prepare('SELECT id,content,attachments FROM player_mail WHERE user_id=? AND read_at IS NULL ORDER BY id').all(session.user_id).map(({ attachments, ...row }) => ({ ...row, send_name: 'Phòng thử nghiệm local', gift: fateRewardPreview(JSON.parse(attachments)) }));
        return { messages };
    }
    async readMail(session, value, all = false) {
        if (typeof value !== 'string' || !value || value.length > 2000)
            throw Object.assign(new Error('ID thư không hợp lệ'), { statusCode: 422 });
        const ids = value.split('|');
        if (!all && ids.length !== 1)
            throw Object.assign(new Error('Cần một ID thư'), { statusCode: 422 });
        if (new Set(ids).size !== ids.length || ids.length > 50)
            throw Object.assign(new Error('Danh sách thư trùng hoặc quá dài'), { statusCode: 422 });
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') };
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const rewards = [], seasonPlans = [];
            for (const id of ids) {
                const mail = this.db.prepare('SELECT read_at,attachments FROM player_mail WHERE user_id=? AND id=?').get(session.user_id, id);
                if (!mail)
                    throw Object.assign(new Error('Không có thư này'), { statusCode: 404 });
                if (mail.read_at !== null)
                    throw Object.assign(new Error('Thư đã được nhận'), { statusCode: 422 });
                const attachments = JSON.parse(mail.attachments), season = aetherMailPlan(this.db, session.user_id, id, attachments, Date.now());
                if (season)
                    seasonPlans.push(season);
                else
                    rewards.push(...attachments);
                this.db.prepare('UPDATE player_mail SET read_at=COALESCE(read_at,?) WHERE user_id=? AND id=?').run(Date.now(), session.user_id, id);
            }
            const result = receiveAetherMails(this.db, session, seasonPlans, rewards.length ? new WelfareService(this.db).applyInTransaction(session, rewards, defs) : { reward: [] });
            if (rewards.length || seasonPlans.length)
                audit(this.db, null, 'mail.reward.claim', session.user_id, 'Nhận đính kèm thư local', null, { mailIds: ids, rewards, seasonPlans });
            this.db.exec('COMMIT');
            return { ...this.mail(session), ...result };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
    setHeroLock(session, value, locked) {
        if (typeof value !== 'string' || !/^[a-zA-Z0-9-]{1,80}$/.test(value))
            throw Object.assign(new Error('ID hero không hợp lệ.'), { statusCode: 422 });
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(session.user_id, value);
            if (!row)
                throw Object.assign(new Error('Hero không thuộc tài khoản.'), { statusCode: 404 });
            const before = JSON.parse(row.state), markers = before.remove_avail ?? [];
            if (!markers || typeof markers !== 'object' || Object.values(markers).some(x => typeof x !== 'string'))
                throw Object.assign(new Error('Trạng thái bảo vệ hero chưa được hỗ trợ.'), { statusCode: 422 });
            const remove_avail = Object.values(markers).filter(x => x !== 'user');
            if (locked)
                remove_avail.push('user');
            const hero = { ...before, remove_avail };
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(hero), session.user_id, value);
            audit(this.db, null, locked ? 'hero.lock' : 'hero.unlock', session.user_id, 'Khóa hero qua client local', { id: value, remove_avail: before.remove_avail ?? [] }, { id: value, remove_avail });
            this.db.exec('COMMIT');
            return { _client_cache_update: { cards: { cards: { update: { [value]: hero } } } } };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
    rename(session, value) {
        if (typeof value !== 'string' || !/^[\p{L}\p{N}_ ]{1,15}$/u.test(value.trim()))
            throw Object.assign(new Error('Tên nhân vật không hợp lệ'), { statusCode: 422 });
        const name = characterName(value);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const row = this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=208').get(session.user_id);
            if (!row || row.quantity < 1)
                throw Object.assign(new Error('Cần Thẻ Đổi Tên local'), { statusCode: 422 });
            const profile = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...JSON.parse(profile.profile), show_name: name }), session.user_id);
            this.db.prepare('UPDATE player_items SET quantity=quantity-1 WHERE user_id=? AND config_id=208').run(session.user_id);
            this.db.exec('COMMIT');
            return { _client_cache_update: { item: { items: { update: row.quantity > 1 ? { '208': [row.quantity - 1] } : {}, remove: row.quantity === 1 ? ['208'] : [] } } } };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
