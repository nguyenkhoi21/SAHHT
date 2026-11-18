import { readBaselineConfigSync } from './local-content.js';
import { economyConfig, economyFail, ProgressionEconomyService } from './progression-economy.js';
import { WelfareService, serverDay } from './welfare.service.js';
export class RebirthShopService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    period(sort) { const day = serverDay(this.now()); if (sort === 0)
        return 'once'; if (sort === 1)
        return day; if (sort === 2) {
        const d = new Date(day + 'T00:00:00Z');
        d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 6) % 7));
        return d.toISOString().slice(0, 10);
    } return economyFail('Kiểu reset cửa hàng chưa hỗ trợ.'); }
    bought(s, id, row) { const period = this.period(row.sell_sort); return this.db.prepare("SELECT result FROM player_content_operations WHERE user_id=? AND method='sacrifice.grace_exchange'").all(s.user_id).map(r => JSON.parse(String(r.result))).filter(r => r.shop_id === id && r.period === period).reduce((n, r) => n + r.count, 0); }
    reason(row) { if (![5, 6].includes(row.need_sort) || ![0, 1, 2].includes(row.sell_sort) || !row.need_value?.length || row.need_value.some((n) => !Number.isSafeInteger(n) || n <= 0))
        return 'Thiếu giá/currency/reset đã xác minh.'; for (const [t, id, n] of row.shop_reward) {
        if (n <= 0 || !Number.isSafeInteger(n))
            return 'Số lượng không hợp lệ.';
        if (t === 6 && !economyConfig('item')[id])
            return 'Thiếu vật phẩm #' + id;
        if (![6, 17, 18].includes(t))
            return 'Loại thưởng chưa hỗ trợ ' + t;
    } return ''; }
    dependencies(configIds) { const recipes = economyConfig('character_break_new'), items = economyConfig('item'), heroes = economyConfig('character_detail'), offers = economyConfig('tree_shop'); return configIds.map(configId => { const r = recipes[configId]; return { configId, name: heroes[configId]?.name, stages: r ? Array.from({ length: r.high_break }, (_, i) => ({ stage: i + 1, materials: (r['material' + (i + 1)] ?? []).map(([type, id, quantity]) => ({ type, id, quantity, name: type === 6 ? items[id]?.name : type === 5 ? heroes[id]?.name : 'Tài nguyên ' + type, exchanges: Object.entries(offers).filter(([, v]) => v.shop_reward.some((x) => x[0] === type && x[1] === id)).map(([shopId, v]) => ({ shopId, currency: v.need_sort === 5 ? 'grace' : 'grace_high', prices: v.need_value, reward: v.shop_reward, limit: v.sell_max })), dependency: type === 5 ? 'Tướng nguyên liệu; nhận/chiêu mộ theo nguồn tướng.' : Object.values(offers).some((v) => v.shop_reward.some((x) => x[0] === type && x[1] === id)) ? 'Đã có công thức đổi trong tree_shop.' : 'Không có công thức đổi trong tree_shop; không tự đặt giá.' })) })) : [] }; }); }
    index(s, fullContent = true) { const p = new ProgressionEconomyService(this.db).profile(s); return { items: Object.fromEntries(Object.entries(economyConfig('tree_shop')).filter(([id, r]) => (fullContent || Object.hasOwn(readBaselineConfigSync('tree_shop'), id)) && !this.reason(r) && (p.level ?? 1) >= r.show_level[0] && (p.level ?? 1) <= r.show_level[1]).map(([id, r]) => [id, { bought: this.bought(s, id, r) }])) }; }
    catalog(s) { return { source: 'VN tree_shop · Cửa hàng đổi Chuyển Sinh', products: Object.entries(economyConfig('tree_shop')).map(([id, r]) => ({ id, ...r, bought: this.bought(s, id, r), blockedReason: this.reason(r) })), balances: { grace: new ProgressionEconomyService(this.db).profile(s).grace ?? 0, grace_high: new ProgressionEconomyService(this.db).profile(s).grace_high ?? 0 } }; }
    buy(s, p, fullContent = true) { if (!fullContent && !Object.hasOwn(readBaselineConfigSync('tree_shop'), p.get('shop_id') ?? ''))
        economyFail('Mặt hàng cần client Pha30; hãy cập nhật APK.'); const svc = new ProgressionEconomyService(this.db, this.now); return svc.execute(s, 'sacrifice.grace_exchange', p, () => { const id = p.get('shop_id') ?? '', row = economyConfig('tree_shop')[id], text = p.get('count') ?? '1', n = Number(text); if (!row || !/^[1-9]\d{0,2}$/.test(text) || n > 99)
        economyFail('Sản phẩm/số lượng không hợp lệ.'); const reason = this.reason(row); if (reason)
        economyFail(reason); const profile = svc.profile(s); if ((profile.level ?? 1) < row.show_level[0] || (profile.level ?? 1) > row.show_level[1])
        economyFail('Chưa đủ cấp cửa hàng.'); const bought = this.bought(s, id, row); if (row.sell_max > 0 && bought + n > row.sell_max)
        economyFail('Đã hết lượt mua trong kỳ.'); let price = 0; for (let i = 0; i < n; i++)
        price += row.need_value[Math.min(bought + i, row.need_value.length - 1)]; svc.cost(s, [[row.need_sort === 5 ? 17 : 18, 0, price]]); const rewards = row.shop_reward.map(([t, i, q]) => [t, i, q * n]); new WelfareService(this.db).applyInTransaction(s, rewards, { heroes: economyConfig('character_detail'), items: economyConfig('item'), equipment: economyConfig('equip') }); return { reward: rewards, shop_id: id, count: n, period: this.period(row.sell_sort), bought: bought + n, price }; }); }
}
