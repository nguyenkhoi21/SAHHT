import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { readConfigSync } from './local-content.js';
import { contentReceipt } from './content-receipt.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { LocalRechargeService } from './local-recharge.service.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
const bytes = readFileSync(new URL('../../../work/runtime-content/configs/vip_store.json', import.meta.url));
if (createHash('sha256').update(bytes).digest('hex') !== '0f9930efef4db965aa8df4174dd6d1c9f695f72af6a6a516e2b9c95c3e41ba4b')
    throw new Error('Nguồn Shop VIP thay đổi; cần xác minh lại.');
export const vipStoreSource = JSON.parse(bytes.toString('utf8'));
const compatibility = JSON.parse(readFileSync(new URL('../../../tools/runtime/phase22-vip-store-compatibility.json', import.meta.url), 'utf8'));
export function vipMonth(now) { const d = new Date(now + 7 * 3600000); return { month: d.toISOString().slice(0, 7), nextReset: Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 1) - 7 * 3600000 }; }
export class VipStoreService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    profile(s) { const r = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id); if (!r)
        fail('Tài khoản chưa vào game.'); return JSON.parse(String(r.profile)); }
    used(s, id, period) { return Number(this.db.prepare("SELECT COUNT(*) n FROM player_claims WHERE user_id=? AND system='vip_store' AND period=? AND claim_key LIKE ?").get(s.user_id, period, id + ':%').n); }
    products(s, at = this.now()) {
        const items = readConfigSync('item'), p = this.profile(s), { month } = vipMonth(at);
        return Object.entries(vipStoreSource).map(([id, c]) => {
            const local = this.db.prepare('SELECT * FROM local_vip_store_settings WHERE product_id=?').get(id);
            const price = local?.price ?? c.need_value?.[0]?.[2], limit = local?.quota ?? c.sell_max;
            const missing = (c.shop_item ?? []).filter((r) => r[0] !== 6 || !items[r[1]]?.name || !Number.isSafeInteger(items[r[1]]?.stack));
            const supported = compatibility.supportedIds.includes(id) && c.sell_ref === 3 && c.need_value?.length === 1 && c.need_value[0][0] === 9 && c.need_value[0][1] === 0 && Number.isSafeInteger(price) && price > 0 && Number.isSafeInteger(limit) && limit > 0 && c.shop_item?.length > 0 && !missing.length;
            const bought = this.used(s, id, month), enabled = local?.enabled !== 0;
            // Lua JSON giữ null thành sentinel truthy; lý do trống phải được bỏ khỏi packet.
            return { id, name: (c.shop_item ?? []).map((r) => items[r[1]]?.name ?? 'Vật phẩm chờ xác minh #' + r[1]).join(' + '), requiredVip: c.show_vip, price, limit, rewards: c.shop_item, enabled, supported, bought, remaining: Math.max(0, limit - bought), eligible: p.vip >= c.show_vip, reason: !supported ? 'Thiếu định nghĩa/icon vật phẩm hoặc schema chưa hỗ trợ.' : !enabled ? 'Sản phẩm tạm tắt.' : p.vip < c.show_vip ? 'Chưa đủ cấp VIP.' : bought >= limit ? 'Đã hết hạn mức tháng.' : undefined, source: 'VN runtime · vip_store', localOverride: !!local };
        });
    }
    index(s, at = this.now()) { const { month, nextReset } = vipMonth(at), products = this.products(s, at); return { date: Object.fromEntries(products.map(p => [p.id, p.bought])), month, next_reset: nextReset, recharge_points: this.profile(s)._local_recharge_points ?? 0, reset_policy: 'Ngày 1, 00:00 Việt Nam; hạn mức lưu theo tháng, không xóa lịch sử.', products }; }
    buy(s, id, count, key) {
        if (typeof id !== 'string' || !/^\d{1,4}$/.test(id) || !/^\d{1,2}$/.test(String(count)) || Number(count) < 1)
            fail('Sản phẩm hoặc số lượng không hợp lệ.');
        const productId = id, n = Number(count), defs = { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') };
        return contentReceipt(this.db, s.user_id, 'shop.vip_store_buy', key, { id: productId, count: n }, () => {
            const at = this.now(), p = this.products(s, at).find(r => r.id === productId);
            if (!p?.supported)
                fail('Sản phẩm chưa đủ dữ liệu tương thích.');
            if (p.reason)
                fail(p.reason);
            if (n > p.remaining)
                fail('Vượt hạn mức mua trong tháng.');
            const state = this.profile(s), cost = p.price * n;
            if (!Number.isSafeInteger(cost) || !Number.isSafeInteger(state.coin) || state.coin < cost)
                fail('Không đủ Xu.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...state, coin: state.coin - cost }), s.user_id);
            const reward = p.rewards.map(([t, i, q]) => [t, i, q * n]);
            const applied = new WelfareService(this.db).applyInTransaction(s, reward, defs);
            const { month } = vipMonth(at);
            for (let k = 1; k <= n; k++)
                this.db.prepare("INSERT INTO player_claims VALUES(?,'vip_store',?,?,?)").run(s.user_id, month, productId + ':' + (p.bought + k), at);
            audit(this.db, null, 'shop.vip_store_buy', s.user_id, 'Mua Shop VIP theo tháng · LOCAL', { coin: state.coin }, { productId, count: n, cost, month, reward });
            return { ...this.index(s, at), ...applied };
        }, () => ({ ...this.index(s), replayed: true, reward: [], _client_cache_update: { item: { items: { update: Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=? AND quantity>0').all(s.user_id).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: [] } }, cards: { cards: { update: {}, remove: [] } } } }));
    }
    settings(adminId, id, b) {
        if (!vipStoreSource[id] || typeof b.enabled !== 'boolean' || !Number.isSafeInteger(b.price) || b.price < 1 || b.price > 100000000 || !Number.isSafeInteger(b.quota) || b.quota < 1 || b.quota > 9999)
            fail('Cấu hình Shop VIP local không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const before = this.db.prepare('SELECT * FROM local_vip_store_settings WHERE product_id=?').get(id);
            this.db.prepare('INSERT INTO local_vip_store_settings VALUES(?,?,?,?) ON CONFLICT(product_id) DO UPDATE SET enabled=excluded.enabled,price=excluded.price,quota=excluded.quota').run(id, Number(b.enabled), b.price, b.quota);
            audit(this.db, adminId, 'shop.vip_store_settings', null, 'Đổi giá/hạn mức LOCAL, giữ nguyên nguồn và lịch sử', before, b);
            this.db.exec('COMMIT');
            return { ok: true };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    diagnostics(s) { return { ...this.index(s), vip: this.profile(s).vip, vipExp: this.profile(s).vip_exp ?? 0, simulatedRechargePoints: this.profile(s)._local_recharge_points ?? 0, localRecharge: new LocalRechargeService(this.db).info(s), history: this.db.prepare("SELECT request_key,created_at,result FROM player_content_operations WHERE user_id=? AND method='shop.vip_store_buy' ORDER BY created_at DESC LIMIT 30").all(s.user_id).map(r => ({ requestId: r.request_key, createdAt: r.created_at, result: JSON.parse(String(r.result)) })) }; }
}
