import { PetService } from './pet.service.js';
import { randomUUID, randomBytes } from 'node:crypto';
import { PlayerService, staticConfig } from './player.service.js';
import { MapAccessService } from './map-access.js';
import { ProgressionService, stageGraph, progressionError } from './progression.service.js';
import { serializeEntity, simulateBattle, localCombatRules, localPlayerExperience } from './local-combat.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { heroBattleExperience } from './battle-experience.js';
import { CombatPowerService } from './combat-power.js';
import { battleAppearance } from './appearance-state.js';
import { PlayerVitalsService } from './player-vitals.js';
import { BeastService } from './beast.service.js';
export class BattleService {
    db;
    constructor(db) {
        this.db = db;
    }
    async start(s, q) {
        const city = String(q.city ?? ''), building = String(q.building ?? ''), step = Number(q.step_n ?? 0), key = String(q.request_id ?? ('legacy:' + city + ':' + building + ':' + step + ':' + String(q.rand ?? '')));
        if (!/^\d{1,6}$/.test(city) || !/^\d{1,10}$/.test(building) || !Number.isInteger(step) || step < 0 || step > 100 || !key.trim() || key.length > 160)
            progressionError('Đầu vào trận đấu không hợp lệ.');
        const previous = this.db.prepare('SELECT city,building,step,packet FROM local_battles WHERE user_id=? AND request_key=?').get(s.user_id, key);
        if (previous) {
            if (previous.city !== city || previous.building !== building || previous.step !== step)
                progressionError('Mã trận đã dùng cho ải khác.');
            return JSON.parse(previous.packet);
        }
        const graph = await stageGraph(), stage = graph.stages.find((x) => x.city === city && x.building === building && x.step === step);
        if (!stage)
            progressionError('Ải chưa có config/địa hình hợp lệ.');
        const access = new MapAccessService(this.db), enemyData = await access.enemies(s.user_id, city, building), fight = enemyData.map_fight[stage.fightId];
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') }, skillDefs = await staticConfig('skill_detail'), title = (await staticConfig('map_title_detail'))[building];
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const duplicate = this.db.prepare('SELECT city,building,step,packet FROM local_battles WHERE user_id=? AND request_key=?').get(s.user_id, key);
            if (duplicate) {
                if (duplicate.city !== city || duplicate.building !== building || duplicate.step !== step)
                    progressionError('Mã trận đã dùng cho ải khác.');
                this.db.exec('COMMIT');
                return JSON.parse(duplicate.packet);
            }
            const progress = new ProgressionService(this.db), natural = progress.completed(s.user_id), gm = progress.access(s.user_id), full = gm?.mode === 'LOCAL_GM_COMPLETE';
            if (stage.previous && !natural.has(stage.previous) && !full)
                progressionError('Cần hoàn thành bước trước của công trình.');
            const players = new PlayerService(this.db), cards = players.cards(s), profile = new PlayerVitalsService(this.db).sync(s.user_id), formation = cards.alignment;
            const cityDefinition = graph.cities.find((c) => c.city === city);
            if ((profile.level ?? 1) < cityDefinition.openLevel)
                progressionError('Chưa đủ cấp vào city.');
            if ([1, 2].includes(cityDefinition.difficulty) && !full)
                progressionError('Tinh anh hiện chỉ hỗ trợ 100% MAP QA; chưa mô phỏng hạn lượt tự nhiên.');
            const canonical = new Map(new CombatPowerService(this.db).calculate(s.user_id).heroes.map(h => [h.id, h]));
            const entities = [];
            for (let slot = 0; slot < 8; slot++) {
                const id = formation[slot < 5 ? 0 : 1][slot % 5];
                if (id === '-1')
                    continue;
                const h = cards.cards[id], cfg = defs.heroes[String(h?.c_id)];
                if (!cfg || cfg.skill_num === 0)
                    progressionError('Đội hình có tướng không hợp lệ.');
                const attrs = canonical.get(id);
                if (!attrs)
                    progressionError('Thiếu chỉ số đội hình canonical.');
                const state = { ...h, ...attrs.attributes, combat_empowerment: attrs.breakdown.empowerLines, combat_auxiliary: attrs.breakdown.auxiliary.effects };
                const appearance = battleAppearance(this.db, s.user_id, h, defs.heroes, skillDefs);
                entities.push(serializeEntity(slot, id, appearance.configId, state, appearance.cfg, appearance.skills));
            }
            for (let slot = 0; slot < 5; slot++) {
                const ids = fight['position' + (slot + 1)];
                if (!ids?.length)
                    continue;
                const cfg = enemyData.enemy_detail[String(ids[0])];
                if (!cfg)
                    progressionError('Thiếu đối thủ.');
                const skills = [1, 2, 3].map(n => cfg['skill' + n]).filter(x => x?.length && skillDefs[String(x[0])]).map(x => ({ id: x[0], lv: x[1], cfg: skillDefs[String(x[0])] }));
                entities.push(serializeEntity(100 + slot, 'local-enemy-' + ids[0] + '-' + slot, Number(ids[0]), cfg, cfg, skills));
            }
            if (!entities.some(e => e.index < 5))
                progressionError('Đội hình trống.');
            const cost = title.action_point;
            if (!Number.isSafeInteger(cost) || cost < 0)
                progressionError('Thiếu chi phí thể lực hợp lệ.');
            const ap = profile.action_point ?? 0;
            if (!Number.isSafeInteger(ap) || ap < cost)
                progressionError('Không đủ thể lực.');
            const pet = new PetService(this.db).combat(s.user_id);
            if (pet)
                entities[0].pet = pet;
            const beasts = new BeastService(this.db).combat(s.user_id);
            if (beasts.length)
                entities[0].beasts = beasts;
            const seed = randomBytes(4).readUInt32LE(), simulation = simulateBattle(entities, seed), id = 'localbattle-' + randomUUID(), won = simulation.winner === 0;
            const experience = localPlayerExperience(profile, won ? Number(fight.reward_exp_role ?? 0) : 0);
            Object.assign(profile, experience.profile);
            profile.action_point = experience.profile.action_point - cost;
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), s.user_id);
            const first = won && !natural.has(stage.key) && !full;
            // Replay có thưởng sweep_base trong config, nhưng tuyệt đối không phát lại first_base.
            const rewards = won && step === title.fight_list.length - 1 ? (first ? title.reward_first_base ?? [] : title.reward_sweep_base ?? []) : [];
            let delivery = {};
            if (rewards.length)
                delivery = new WelfareService(this.db).applyInTransaction(s, rewards, defs);
            const heroExp = {}, heroUpdates = {};
            if (won)
                for (const heroId of formation.flat().filter((id) => id !== '-1')) {
                    const raw = JSON.parse(this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, heroId).state), earned = heroBattleExperience(raw, profile.level ?? 1, Number(fight.reward_exp_character ?? 0));
                    heroExp[heroId] = earned.displayTuple;
                    if (earned.tuple) {
                        heroExp[heroId] = earned.tuple;
                        this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(earned.state), s.user_id, heroId);
                        heroUpdates[heroId] = Object.fromEntries(Object.entries(earned.state).filter(([k]) => !k.startsWith('_local_')));
                    }
                }
            if (Object.keys(heroUpdates).length) {
                delivery._client_cache_update ??= {};
                delivery._client_cache_update.cards ??= { cards: { update: {}, remove: [] } };
                Object.assign(delivery._client_cache_update.cards.cards.update, heroUpdates);
            }
            if (won)
                this.db.prepare('INSERT OR IGNORE INTO player_stage_steps VALUES(?,?,?,?,?,?)').run(s.user_id, city, building, step, id, Date.now());
            const last = step + 1 >= title.fight_list.length;
            if (won)
                natural.add(stage.key);
            const citySteps = graph.stages.filter((x) => x.city === city), percent = full ? 100 : Math.floor(citySteps.filter((x) => natural.has(x.key)).length * 100 / citySteps.length);
            const rewardSummary = {};
            for (const [type, , amount] of rewards) {
                const field = { 1: 'reward_food', 2: 'reward_metal', 4: 'reward_crystal' }[type];
                if (field)
                    rewardSummary[field] = (rewardSummary[field] ?? 0) + amount;
            }
            const data = { has_battled: 1, city, building, next_step: won ? (last ? -1 : step + 1) : step, battle: { ...simulation.battle, init: { ...simulation.battle.init, aform: cards.formation.current, dform: fight.formation_id, equip_att: cards.equip, equip_pos_att: cards.equip_pos, atk_name: profile.show_name ?? s.username, atk_lv: profile.level ?? 1 } }, is_recaptured: won && last, curt_regain: percent, curt_gift: [], new_gift: false, old_gift: [], extra_rewards: {}, rewards: rewardSummary, battle_rewards: { reward_exp_player: experience.gain ? [experience.gain, experience.old, experience.path] : [], reward_exp_character: heroExp, reward_character: {}, reward_item: {} }, ...delivery };
            this.db.prepare('INSERT INTO local_battles VALUES(?,?,?,?,?,?,?,?,?,?)').run(id, s.user_id, key, city, building, step, seed, JSON.stringify({ winner: simulation.winner, rounds: simulation.rounds, rules: localCombatRules.version, skillDiagnostics: simulation.diagnostics, beastDiagnostics: simulation.beastDiagnostics, petDiagnostics: simulation.petDiagnostics, lifeEvents: simulation.lifeEvents, empowermentDiagnostics: simulation.empowerment, first, rewards, remaining: simulation.remaining, ...(simulation.trace ? { trace: simulation.trace } : {}), expPending: { player: fight.reward_exp_role, hero: fight.reward_exp_character } }), JSON.stringify(data), Date.now());
            audit(this.db, null, 'battle.local.settle', s.user_id, 'Combat LOCAL; EXP/thể lực lên cấp từ bảng role VN', { city, building, step }, { id, winner: simulation.winner, cost, first, rewards, playerExp: experience.gain });
            this.db.exec('COMMIT');
            return data;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }

    // Càn quét (private_city.auto_recapture): client gửi city + building, nhận data.reward.
    // Chỉ cho công trình đã thắng đủ mọi bước; trừ thể lực = action_point * số bước (khớp need_action_point của client).
    async sweep(s, q) {
        const city = String(q.city ?? ''), building = String(q.building ?? '');
        if (!/^\d{1,6}$/.test(city) || !/^\d{1,10}$/.test(building))
            progressionError('Đầu vào càn quét không hợp lệ.');
        const graph = await stageGraph(), stages = graph.stages.filter((x) => x.city === city && x.building === building);
        if (!stages.length)
            progressionError('Ải chưa có config/địa hình hợp lệ.');
        const cityDefinition = graph.cities.find((c) => c.city === city), title = (await staticConfig('map_title_detail'))[building];
        if (!cityDefinition || !title || !Array.isArray(title.fight_list))
            progressionError('Công trình chưa có config hợp lệ.');
        const enemyData = await new MapAccessService(this.db).enemies(s.user_id, city, building);
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') };
        let expRole = 0, expHero = 0;
        for (const stage of stages) {
            const fight = enemyData.map_fight[stage.fightId];
            expRole += Number(fight?.reward_exp_role ?? 0);
            expHero += Number(fight?.reward_exp_character ?? 0);
        }
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const progress = new ProgressionService(this.db), natural = progress.completed(s.user_id), gm = progress.access(s.user_id), full = gm?.mode === 'LOCAL_GM_COMPLETE';
            if (!full && !stages.every((x) => natural.has(x.key)))
                progressionError('Cần thắng đủ mọi bước của công trình trước khi càn quét.');
            if ([1, 2].includes(cityDefinition.difficulty) && !full)
                progressionError('Tinh anh hiện chỉ hỗ trợ 100% MAP QA; chưa mô phỏng hạn lượt tự nhiên.');
            const players = new PlayerService(this.db), cards = players.cards(s), profile = new PlayerVitalsService(this.db).sync(s.user_id), formation = cards.alignment;
            if ((profile.level ?? 1) < cityDefinition.openLevel)
                progressionError('Chưa đủ cấp vào city.');
            const heroIds = formation.flat().filter((id) => id !== '-1');
            if (!heroIds.length)
                progressionError('Đội hình trống.');
            const cost = Number(title.action_point) * title.fight_list.length;
            if (!Number.isSafeInteger(cost) || cost < 0)
                progressionError('Thiếu chi phí thể lực hợp lệ.');
            const ap = profile.action_point ?? 0;
            if (!Number.isSafeInteger(ap) || ap < cost)
                throw Object.assign(new Error('Không đủ thể lực để càn quét.'), { statusCode: 422, clientStatus: 'error_3' });
            const experience = localPlayerExperience(profile, expRole);
            Object.assign(profile, experience.profile);
            profile.action_point = experience.profile.action_point - cost;
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), s.user_id);
            const rewards = title.reward_sweep_base ?? [];
            let delivery = {};
            if (rewards.length)
                delivery = new WelfareService(this.db).applyInTransaction(s, rewards, defs);
            const heroExp = {}, heroUpdates = {};
            for (const heroId of heroIds) {
                const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, heroId);
                if (!row)
                    continue;
                const earned = heroBattleExperience(JSON.parse(row.state), profile.level ?? 1, expHero);
                heroExp[heroId] = earned.displayTuple;
                if (earned.tuple) {
                    heroExp[heroId] = earned.tuple;
                    this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(earned.state), s.user_id, heroId);
                    heroUpdates[heroId] = Object.fromEntries(Object.entries(earned.state).filter(([k]) => !k.startsWith('_local_')));
                }
            }
            if (Object.keys(heroUpdates).length) {
                delivery._client_cache_update ??= {};
                delivery._client_cache_update.cards ??= { cards: { update: {}, remove: [] } };
                Object.assign(delivery._client_cache_update.cards.cards.update, heroUpdates);
            }
            const rewardSummary = {};
            for (const [type, , amount] of rewards) {
                const field = { 1: 'reward_food', 2: 'reward_metal', 4: 'reward_crystal' }[type];
                if (field)
                    rewardSummary[field] = (rewardSummary[field] ?? 0) + amount;
            }
            const data = { reward: [], has_battled: 1, city, building, curt_gift: [], new_gift: false, old_gift: [], extra_rewards: {}, rewards: rewardSummary, battle_rewards: { reward_exp_player: experience.gain ? [experience.gain, experience.old, experience.path] : [], reward_exp_character: heroExp, reward_character: {}, reward_item: {} }, ...delivery };
            audit(this.db, null, 'battle.local.sweep', s.user_id, 'Càn quét LOCAL: thưởng reward_sweep_base, trừ thể lực theo số bước', { city, building }, { cost, rewards, playerExp: experience.gain });
            this.db.exec('COMMIT');
            return data;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
