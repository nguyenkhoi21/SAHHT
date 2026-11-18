import { createHash } from 'node:crypto';
import { staticConfig } from './player.service.js';
import { PlayerVitalsService } from './player-vitals.js';
import { audit } from '../admin/admin.audit.js';
import { readConfigSync } from './local-content.js';
import { contentReceipt } from './content-receipt.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { petCache } from './pet-state.js';
const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
export class ItemService {
    db;
    constructor(db) {
        this.db = db;
    }
    view(session) {
        // game_exchange_scene.backData cộng từng phần tử items[id] và đọc số lần ghép.
        const rows = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=? AND quantity>0 ORDER BY config_id').all(session.user_id);
        const exchange_log = {};
        for (const r of this.db.prepare("SELECT result FROM player_content_operations WHERE user_id=? AND method='item.exchange'").all(session.user_id)) {
            const id = String(JSON.parse(String(r.result)).exchange_id);
            exchange_log[id] = (exchange_log[id] ?? 0) + 1;
        }
        return { items: Object.fromEntries(rows.map(r => [String(r.config_id), [r.quantity]])), exchange_log };
    }
    exchange(session, p) {
        const key = p.get('change_id') ?? '';
        return contentReceipt(this.db, session.user_id, 'item.exchange', p.get('request_id'), { change_id: key }, () => {
            const row = readConfigSync('exchange')[key], isPet = row?.change_sort === 4 && row.change_id?.length === 1 && row.change_id[0][0] === 25, defs = readConfigSync('character_detail');
            if (!isPet && (!row || row.change_sort !== 1 || row.change_id?.length !== 1 || row.change_id[0][0] !== 5 || defs[row.change_id[0][1]]?.skill_num !== 0))
                fail('Công thức ghép mảnh này chưa được khôi phục; chưa tiêu vật phẩm.');
            const used = this.view(session).exchange_log[key] ?? 0, costs = row.need_num;
            if (!Array.isArray(costs) || !costs.length || costs.some((n) => !Number.isSafeInteger(n) || n <= 0) || !Number.isSafeInteger(row.change_time) || row.change_time <= 0 || ![row.need_food, row.need_metal].every(n => Number.isSafeInteger(n) && n >= 0))
                fail('Chi phí công thức mảnh chưa hợp lệ.');
            if (used >= row.change_time)
                fail('Đã hết lượt ghép theo công thức.');
            const count = costs[Math.min(used, costs.length - 1)];
            const removed = new ProgressionEconomyService(this.db).cost(session, [[6, row.need_item, count], [1, 0, row.need_food], [2, 0, row.need_metal]]), reward = grantGodfieldReward(this.db, session, row.change_id), view = this.view(session);
            view.exchange_log[key] = used + 1;
            reward._client_cache_update.item.items.update[String(row.need_item)] = [view.items[String(row.need_item)]?.[0] ?? 0];
            audit(this.db, null, 'item.fragment.exchange', session.user_id, 'Ghép thẻ nguyên liệu bằng công thức Việt Nam; không tự dùng thẻ sau ghép', null, { exchangeId: key, count, requestId: p.get('request_id') });
            return { ...reward, ...view, exchange_id: key, removed };
        }, old => { const view = this.view(session), pet = readConfigSync('exchange')[key]?.change_sort === 4; return { ...old, ...view, replayed: true, reward: {}, _client_cache_update: pet ? { ...petCache(this.db, session.user_id), item: { items: { update: { ...view.items, [readConfigSync('exchange')[key].need_item]: [view.items[String(readConfigSync('exchange')[key].need_item)]?.[0] ?? 0] }, remove: [] } } } : undefined }; });
    }
    async use(session, itemId, num, requestId) {
        if (requestId !== undefined && (typeof requestId !== 'string' || !/^[A-Za-z0-9_.:-]{8,160}$/.test(requestId)))
            fail('Mã dùng thuốc không hợp lệ.');
        if (typeof itemId !== 'string' || !['3', '4', '5', '6'].includes(itemId) || typeof num !== 'string' || !/^\d{1,4}$/.test(num) || Number(num) < 1)
            fail('Chỉ hỗ trợ thuốc thể lực3–6 và số lượng nguyên dương.');
        const id = Number(itemId), count = Number(num), cfg = (await staticConfig('item'))[String(id)];
        if (cfg.is_use !== 2 || cfg.daily_use !== 0 || cfg.use_num !== 1 || cfg.use_effect.length !== 1 || !Number.isSafeInteger(cfg.use_effect[0]) || cfg.use_effect[0] <= 0)
            fail('Config thuốc ngoài schema đã xác minh.');
        const fingerprint = createHash('sha256').update(JSON.stringify({ id, count })).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (requestId) {
                const old = this.db.prepare('SELECT method,fingerprint,result FROM player_content_operations WHERE user_id=? AND request_key=?').get(session.user_id, requestId);
                if (old) {
                    if (old.method !== 'item.use.stamina' || old.fingerprint !== fingerprint)
                        fail('Mã dùng thuốc đã được dùng cho nội dung khác.');
                    const quantity = Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(session.user_id, id)?.quantity ?? 0), result = JSON.parse(String(old.result));
                    result._client_cache_update.item.items = { update: quantity > 0 ? { [id]: [quantity] } : {}, remove: quantity === 0 ? [String(id)] : [] };
                    this.db.exec('COMMIT');
                    return result;
                }
            }
            const row = this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(session.user_id, id);
            if (!row || row.quantity < count)
                return fail('Không đủ thuốc thể lực.');
            const p = new PlayerVitalsService(this.db).sync(session.user_id), before = p.action_point ?? 0;
            const points = before + cfg.use_effect[0] * count;
            if (!Number.isSafeInteger(points) || points > 1_000_000_000)
                fail('Thể lực vượt giới hạn dữ liệu local.');
            this.db.prepare('UPDATE player_items SET quantity=quantity-? WHERE user_id=? AND config_id=?').run(count, session.user_id, id);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, action_point: points }), session.user_id);
            audit(this.db, null, 'item.use', session.user_id, 'Dùng thuốc thể lực theo config', { itemId: id, quantity: row.quantity, action_point: before }, { quantity: row.quantity - count, action_point: points });
            const result = { effect: [], _client_cache_update: { item: { items: { update: row.quantity > count ? { [id]: [row.quantity - count] } : {}, remove: row.quantity === count ? [String(id)] : [] } } } };
            if (requestId)
                this.db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(session.user_id, requestId, 'item.use.stamina', fingerprint, JSON.stringify(result), Date.now());
            this.db.exec('COMMIT');
            // item_info_pop350: effect có0 reward → hiện tips dùng thành công; AP cập nhật qua root user_status.
            return result;
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
