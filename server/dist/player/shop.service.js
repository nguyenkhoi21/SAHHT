import { beginHotSpend, endHotSpend } from './hot-spending.js';
import { inventoryRewardItem } from './inventory-items.js';
import { previewInventoryExpansion, inventoryBags } from './inventory-capacity.js';
import { VipShopService } from './vip-shop.service.js';
import { staticConfig } from './player.service.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { readConfigSync, readBaselineConfigSync } from './local-content.js';
import { contentReceipt } from './content-receipt.js';
import { serverDay } from './welfare.service.js';
// Catalog Việt Nam; lượt cũ518/1001 khôi phục theo audit đúng kỳ, không mất lịch sử.
const supportedOffer = '518';
const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
// Chủ dự án yêu cầu mua túi vào kho rồi tự dùng. Giữ im_use nguồn trong config;
// chỉ đổi cờ điều khiển UI cho đúng ba túi, không sửa vật phẩm dùng ngay khác.
function clientUseMode(c) { return c.shop_reward?.length === 1 && c.shop_reward[0][0] === 6 && Object.hasOwn(inventoryBags, c.shop_reward[0][1]) ? 0 : c.im_use; }
export class ShopService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    extraOffers() { const items = readConfigSync('item'), heroes = readConfigSync('character_detail'); return Object.fromEntries(Object.entries(readConfigSync('shop')).filter(([id, c]) => !['518', '1001'].includes(id) && c.need_sort === 1 && [0, 1].includes(c.im_use) && c.server_sell_time === '' && [0, 1, 2].includes(c.sell_sort) && Number.isSafeInteger(c.sell_max) && c.sell_max >= 0 && c.need_value.length > 0 && c.need_value.every((v) => Number.isSafeInteger(v) && Number(v) > 0) && c.shop_reward.length > 0 && c.shop_reward.every((r) => r.length === 3 && r.every(Number.isSafeInteger) && r[2] > 0 && (r[0] === 6 && inventoryRewardItem(items[r[1]]) || r[0] === 5 && !!heroes[r[1]] || [1, 2, 4, 9, 10, 11, 15, 17, 18, 20, 23, 33, 34, 35, 40, 41, 42, 43].includes(r[0]) && r[1] === 0)) && (c.im_use === 0 || c.shop_reward.length === 1 && c.shop_reward[0][0] === 6 && Object.hasOwn(inventoryBags, c.shop_reward[0][1])))); }
    period(c) { const day = serverDay(this.now()); if (c.sell_sort === 1)
        return day; if (c.sell_sort === 2) {
        const date = new Date(day + 'T00:00:00Z');
        date.setUTCDate(date.getUTCDate() - (date.getUTCDay() + 6) % 7);
        return date.toISOString().slice(0, 10);
    } return 'once'; }
    extraBought(s, id, c) { if (['518', '1001'].includes(id)) {
        return this.db.prepare("SELECT after_state,created_at FROM admin_audit WHERE target_user_id=? AND action=?").all(s.user_id, id === '1001' ? 'shop.buy.metal' : 'shop.buy.item').reduce((n, r) => { const data = JSON.parse(String(r.after_state ?? '{}')), matches = String(data.shopId ?? (id === '1001' ? '1001' : '518')) === id, day = serverDay(Number(r.created_at)), period = this.period(c), inPeriod = c.sell_sort === 0 || c.sell_sort === 1 && day === period || c.sell_sort === 2 && day >= period && day < new Date(Date.parse(period + 'T00:00:00Z') + 7 * 86400000).toISOString().slice(0, 10), goods = data.goods ?? [], reward = c.shop_reward[0], quantity = goods.filter((g) => g[0] === reward[0] && g[1] === reward[1]).reduce((a, g) => a + g[2], 0) / reward[2]; return n + (matches && inPeriod && Number.isSafeInteger(quantity) && quantity > 0 ? quantity : 0); }, 0);
    } return Number(this.db.prepare("SELECT COUNT(*) n FROM player_claims WHERE user_id=? AND system='shop_quantity' AND period=? AND claim_key LIKE ?").get(s.user_id, this.period(c), id + ':%').n); }
    diagnostics(s) { const items = readConfigSync('item'), offers = this.extraOffers(); return { blockedOffers: Object.entries(readConfigSync('shop')).filter(([id]) => !['518', '1001'].includes(id) && !offers[id]).map(([id, c]) => ({ id, ...c, reason: 'Chưa có adapter dùng/cấp loại thưởng hoặc điều kiện bán đã xác minh.' })), offers: Object.entries(offers).map(([id, c]) => ({ id, ...c, source_im_use: c.im_use, im_use: clientUseMode(c), bought: this.extraBought(s, id, c), period: this.period(c), name: c.shop_reward.map((r) => r[0] === 6 ? items[r[1]].name : 'Tài nguyên loại ' + r[0]).join(' + ') })), history: this.db.prepare("SELECT method,result,created_at FROM player_content_operations WHERE user_id=? AND (method='shop.buy' OR method='item.use' AND json_extract(result,'$.capacity') IS NOT NULL) ORDER BY created_at DESC LIMIT 50").all(s.user_id).map(r => ({ ...r, result: JSON.parse(String(r.result)) })), notice: 'Giá/gói theo shop.config, giới hạn ngày/tuần UTC+7. Ba túi mở rộng mua vào kho rồi tự dùng theo yêu cầu chủ dự án; im_use nguồn vẫn được giữ để đối chiếu. Các lượt mua cũ giữ nguyên.' }; }
    async bootstrap(session, fullContent = true) {
        const config = await staticConfig('shop');
        const ledger = new Map(this.db.prepare('SELECT shop_id,bought FROM player_shop WHERE user_id=?').all(session.user_id).map(r => [r.shop_id, r.bought]));
        // game_data.setMainPageData3609 và normal_tips.getNeedDimond698 đọc giá/counter
        // trước khi mở shop. Đây là catalog; buy vẫn chỉ nhận518/1001 đã triển khai.
        const extra = this.extraOffers();
        return { items: Object.fromEntries(Object.entries(config).filter(([id]) => fullContent || Object.hasOwn(readBaselineConfigSync('shop'), id)).map(([id, c]) => [id, { ...c, im_use: clientUseMode(c), bought: extra[id] || ['518', '1001'].includes(id) ? this.extraBought(session, id, c) : ledger.get(id) ?? 0 }])) };
    }
    bought(userId, offer = supportedOffer) {
        return this.db.prepare('SELECT bought FROM player_shop WHERE user_id=? AND shop_id=?').get(userId, offer)?.bought ?? 0;
    }
    async open(session, fullContent = true) {
        const cfg = (await staticConfig('shop'))[supportedOffer];
        return { vip_bought: new VipShopService(this.db).bought(session), items: { [supportedOffer]: { bought: this.extraBought(session, supportedOffer, cfg), im_use: cfg.im_use, shop_reward: cfg.shop_reward }, ...Object.fromEntries(Object.entries(this.extraOffers()).filter(([id]) => fullContent || Object.hasOwn(readBaselineConfigSync('shop'), id)).map(([id, c]) => [id, { bought: this.extraBought(session, id, c), im_use: clientUseMode(c), shop_reward: c.shop_reward }])) } };
    }
    async buy(session, id, countValue, requestId, fullContent = true) {
        if (!fullContent && !Object.hasOwn(readBaselineConfigSync('shop'), String(id)))
            fail('Mặt hàng cần bản client Pha30; hãy cập nhật APK.');
        if (typeof id === 'string' && ['518', '1001'].includes(id) && requestId !== undefined)
            return this.buyConfigured(session, id, countValue, requestId);
        if (typeof id === 'string' && this.extraOffers()[id])
            return this.buyConfigured(session, id, countValue, requestId);
        if (id === '1001')
            return this.buyMetal(session, countValue);
        if (id !== supportedOffer || typeof countValue !== 'string' || !/^[1-9][0-9]?$/.test(countValue))
            fail('Mặt hàng hoặc số lượng chưa hỗ trợ');
        const count = Number(countValue), cfg = (await staticConfig('shop'))[supportedOffer];
        if (cfg.need_sort !== 1 || cfg.im_use !== 0 || cfg.shop_reward.length !== 1 || cfg.shop_reward[0][0] !== 6 || cfg.show_level[0] > 1)
            fail('Config shop ngoài phạm vi đã kiểm chứng');
        const [, cid, each] = cfg.shop_reward[0];
        const definition = (await staticConfig('item'))[String(cid)];
        if (!definition || !Number.isSafeInteger(each) || each < 1)
            fail('Item config không hợp lệ');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const bought = this.bought(session.user_id);
            if (bought + count > cfg.sell_max)
                fail('Đã hết số lượng local');
            let cost = 0;
            for (let i = 0; i < count; i++)
                cost += cfg.need_value[Math.min(bought + i, cfg.need_value.length - 1)];
            if (!Number.isSafeInteger(cost) || cost < 0)
                fail('Giá config không hợp lệ');
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id);
            const profile = JSON.parse(row.profile), balance = profile.coin ?? 0;
            if (!Number.isSafeInteger(balance) || balance < cost)
                fail('Không đủ Xu local');
            const previous = this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(session.user_id, cid)?.quantity ?? 0;
            const quantity = previous + each * count;
            if (!Number.isSafeInteger(quantity) || quantity > definition.stack)
                fail('Vượt sức chứa stack đã hỗ trợ');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, coin: balance - cost }), session.user_id);
            this.db.prepare('INSERT INTO player_items VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(session.user_id, cid, quantity);
            this.db.prepare('INSERT INTO player_shop VALUES(?,?,?) ON CONFLICT(user_id,shop_id) DO UPDATE SET bought=excluded.bought').run(session.user_id, supportedOffer, bought + count);
            audit(this.db, null, 'shop.buy.item', session.user_id, 'Mua vật phẩm theo shop518', { bought, coin: balance }, { bought: bought + count, cost, goods: [[6, cid, each * count]] });
            this.db.exec('COMMIT');
            return { bought: bought + count, goods: [[6, cid, each * count]], _client_cache_update: { item: { items: { update: { [String(cid)]: [quantity] }, remove: [] } } } };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
    buyConfigured(s, id, value, key) {
        if (typeof value !== 'string' || !/^\d{1,2}$/.test(value) || Number(value) < 1)
            fail('Số lượng mua không hợp lệ.');
        const count = Number(value), legacy = ['518', '1001'].includes(id), c = legacy ? readConfigSync('shop')[id] : this.extraOffers()[id], defs = { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') }, boughtNow = () => this.extraBought(s, id, c);
        return contentReceipt(this.db, s.user_id, 'shop.buy', key, { id, count }, () => {
            const p = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile)), bought = boughtNow(), period = this.period(c);
            const range = /^(\d{4})\/(\d{2})\/(\d{2})\s+(\d{2}:\d{2}:\d{2})-(\d{4})\/(\d{2})\/(\d{2})\s+(\d{2}:\d{2}:\d{2})$/.exec(c.sell_time);
            if (!range)
                fail('Lịch bán chưa có định dạng được xác minh.');
            const start = Date.parse(`${range[1]}-${range[2]}-${range[3]}T${range[4]}+07:00`), end = Date.parse(`${range[5]}-${range[6]}-${range[7]}T${range[8]}+07:00`);
            if (!Number.isFinite(start) || !Number.isFinite(end) || this.now() < start || this.now() > end)
                fail('Mặt hàng ngoài thời gian bán.');
            if ((p.level ?? 1) < c.show_level[0] || (p.level ?? 1) > c.show_level[1])
                fail('Cấp người chơi chưa phù hợp mặt hàng.');
            if (c.sell_max > 0 && bought + count > c.sell_max)
                fail('Đã hết số lượng trong kỳ bán.');
            // Mua cấp túi thật; UI nhận im_use=0 để chờ người chơi dùng trong túi đồ.
            if (c.im_use === 1) {
                const [, bag, each] = c.shop_reward[0], pending = Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, bag)?.quantity ?? 0);
                previewInventoryExpansion(this.db, s.user_id, bag, pending + each * count, defs.items[bag]);
            }
            let cost = 0;
            for (let i = 0; i < count; i++)
                cost += c.need_value[Math.min(bought + i, c.need_value.length - 1)];
            if (!Number.isSafeInteger(cost) || cost <= 0 || !Number.isSafeInteger(p.coin) || p.coin < cost)
                fail('Không đủ Xu để mua.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, coin: p.coin - cost }), s.user_id);
            const goods = c.shop_reward.map(([t, cid, q]) => [t, cid, q * count]), applied = new WelfareService(this.db).applyInTransaction(s, goods, defs);
            if (legacy)
                this.db.prepare('INSERT INTO player_shop VALUES(?,?,?) ON CONFLICT(user_id,shop_id) DO UPDATE SET bought=excluded.bought').run(s.user_id, id, bought + count);
            else
                for (let i = 0; i < count; i++)
                    this.db.prepare("INSERT INTO player_claims VALUES(?,'shop_quantity',?,?,?)").run(s.user_id, period, id + ':' + (bought + i + 1), this.now());
            audit(this.db, null, id === '1001' ? 'shop.buy.metal' : 'shop.buy.item', s.user_id, 'Mua theo shop.config, receipt và giới hạn kỳ', { coin: p.coin, bought }, { shopId: id, cost, goods, bought: bought + count }, this.now());
            return { ...applied, goods, bought: bought + count, cost, shop_id: id, period };
        }, old => ({ ...old, goods: [], reward: [], replayed: true, bought: boughtNow(), _client_cache_update: { item: { items: { update: Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: [] } } } }));
    }
    async buyMetal(session, countValue) {
        if (typeof countValue !== 'string' || !/^\d{1,2}$/.test(countValue) || Number(countValue) < 1)
            fail('Số lượng mua không hợp lệ.');
        const count = Number(countValue), cfg = (await staticConfig('shop'))['1001'];
        if (cfg.need_sort !== 1 || cfg.im_use !== 0 || cfg.shop_reward.length !== 1 || cfg.shop_reward[0][0] !== 2 || cfg.shop_reward[0][1] !== 0 || !Number.isSafeInteger(cfg.shop_reward[0][2]) || cfg.shop_reward[0][2] < 1)
            fail('Config mua Kim loại không khớp evidence.');
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item') };
        this.db.exec('BEGIN IMMEDIATE');
        try {
            beginHotSpend(this.db, session.user_id, 'shop.buy', 'legacy-' + Date.now());
            const bought = this.bought(session.user_id, '1001');
            if (bought + count > cfg.sell_max)
                fail('Đã hết lượt mua Kim loại local.');
            const profile = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(session.user_id).profile);
            if (profile.level < cfg.show_level[0] || profile.level > cfg.show_level[1])
                fail('Cấp người chơi chưa phù hợp mặt hàng.');
            let cost = 0;
            for (let i = 0; i < count; i++)
                cost += cfg.need_value[Math.min(bought + i, cfg.need_value.length - 1)];
            if (!Number.isSafeInteger(cost) || cost < 0 || !Number.isSafeInteger(profile.coin) || profile.coin < cost)
                fail('Không đủ Xu local.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, coin: profile.coin - cost }), session.user_id);
            const goods = [[2, 0, cfg.shop_reward[0][2] * count]];
            const applied = new WelfareService(this.db).applyInTransaction(session, goods, defs);
            this.db.prepare('INSERT INTO player_shop VALUES(?,?,?) ON CONFLICT(user_id,shop_id) DO UPDATE SET bought=excluded.bought').run(session.user_id, '1001', bought + count);
            audit(this.db, null, 'shop.buy.metal', session.user_id, 'Mua Kim loại theo shop1001', { bought, coin: profile.coin, metal: profile.metal ?? 0 }, { bought: bought + count, cost, goods });
            endHotSpend(this.db, session.user_id);
            this.db.exec('COMMIT');
            return { ...applied, bought: bought + count, goods };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
