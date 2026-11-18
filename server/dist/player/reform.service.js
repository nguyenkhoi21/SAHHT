import { recordConsumption } from './consumption-history.js';
import { staticConfig, PlayerService } from './player.service.js';
import { createHash } from 'node:crypto';
import { audit } from '../admin/admin.audit.js';
const fields = ['hp', 'patk', 'matk', 'def', 'speed'];
const currency = { 1: 'crystal', 2: 'adv_crystal', 3: 'super_crystal' };
function fail(message) { throw Object.assign(new Error(message), { statusCode: 422 }); }
// game_hero_culture_scene:273–298,403–552: type lặp, chi phí từng hàng, bonus của hàng cuối.
export class ReformService {
    db;
    constructor(db) {
        this.db = db;
    }
    async upgrade(session, cardId, types, requestId) {
        if (typeof cardId !== 'string' || !cardId || types.length < 1 || !fields.includes(types[0]) || types.some(t => t !== types[0]))
            fail('Yêu cầu Cải Tạo không hợp lệ.');
        if (requestId !== undefined && (typeof requestId !== 'string' || !/^[A-Za-z0-9_.:-]{8,160}$/.test(requestId)))
            fail('Mã thao tác Cải Tạo không hợp lệ.');
        const cfg = await staticConfig('character_strengthen'), field = types[0], key = field + '_crystal', fingerprint = createHash('sha256').update(JSON.stringify({ cardId, types })).digest('hex');
        if (types.length > Math.max(...Object.keys(cfg).map(Number)))
            fail('Số cấp Cải Tạo vượt giới hạn cấu hình nguồn.');
        const packet = () => ({ replayed: false, _client_cache_update: { cards: { cards: { update: { [cardId]: new PlayerService(this.db).cards(session, true).cards[cardId] }, remove: [] } } } });
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (requestId) {
                const old = this.db.prepare('SELECT method,fingerprint FROM player_content_operations WHERE user_id=? AND request_key=?').get(session.user_id, requestId);
                if (old) {
                    if (old.method !== 'laboratory.level_up' || old.fingerprint !== fingerprint)
                        fail('Mã thao tác đã dùng cho nội dung khác.');
                    const result = { ...packet(), replayed: true };
                    this.db.exec('COMMIT');
                    return result;
                }
            }
            const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(session.user_id, cardId);
            if (!row)
                fail('Hero không thuộc tài khoản.');
            const hero = JSON.parse(row.state), before = hero[key] ?? 0, next = before + types.length;
            if (!Number.isInteger(before) || before < 0 || !Number.isFinite(hero[field]) || !cfg[String(next)])
                fail('Đã đạt giới hạn hoặc state Cải Tạo chưa hỗ trợ.');
            const state = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
            const profile = JSON.parse(state.profile), cost = {};
            for (let level = before + 1; level <= next; level++) {
                const rule = cfg[String(level)], crystal = rule?.['need_crstal_' + field];
                if (!rule || hero.lv < rule.need_level)
                    fail('Cấp đồng đội chưa đủ để Cải Tạo.');
                if (!Number.isSafeInteger(rule.need_food) || rule.need_food < 0 || !Array.isArray(crystal) || !currency[crystal[0]] || !Number.isSafeInteger(crystal[1]) || crystal[1] < 0)
                    fail('Config chi phí Cải Tạo chưa hỗ trợ.');
                cost.food = (cost.food ?? 0) + rule.need_food;
                const resource = currency[crystal[0]];
                cost[resource] = (cost[resource] ?? 0) + crystal[1];
            }
            for (const [resource, value] of Object.entries(cost)) {
                if (!Number.isSafeInteger(profile[resource] ?? 0) || (profile[resource] ?? 0) < value)
                    fail('Không đủ tài nguyên Cải Tạo.');
                profile[resource] = (profile[resource] ?? 0) - value;
            }
            const delta = cfg[String(next)]['add_' + field] - (cfg[String(before)]?.['add_' + field] ?? 0);
            if (!Number.isFinite(delta) || delta < 0)
                fail('Config bonus Cải Tạo không hợp lệ.');
            const resourceTypes = { food: 1, crystal: 4, adv_crystal: 20, super_crystal: 40 };
            const updated = recordConsumption(hero, { ...hero, [key]: next, [field]: hero[field] + delta }, 'laboratory.level_up', [{ rewards: Object.entries(cost).map(([f, n]) => [resourceTypes[f], 0, n]), heroes: [] }]);
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(updated), session.user_id, cardId);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), session.user_id);
            audit(this.db, null, 'hero.reform', session.user_id, 'Cải Tạo theo config client', { heroId: cardId, field, level: before }, { heroId: cardId, field, level: next, cost });
            if (requestId)
                this.db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(session.user_id, requestId, 'laboratory.level_up', fingerprint, JSON.stringify({ heroId: cardId, field, level: next, cost }), Date.now());
            const result = packet();
            this.db.exec('COMMIT');
            return result;
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
