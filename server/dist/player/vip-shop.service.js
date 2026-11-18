import { beginHotSpend, endHotSpend } from './hot-spending.js';
import { staticConfig } from './player.service.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
export class VipShopService {
    db;
    constructor(db) {
        this.db = db;
    }
    bought(s) { return Object.fromEntries(this.db.prepare("SELECT claim_key FROM player_claims WHERE user_id=? AND system='vip_shop' AND period='once'").all(s.user_id).map(r => [r.claim_key, 1])); }
    step(s) { return { step: this.bought(s), double_pay: [], month_award: 2, week_award: 2, quarter_award: 2, quarter_version: 1 }; }
    async buy(s, value) {
        if (typeof value !== 'string' || !/^\d{1,3}$/.test(value))
            fail('Mã gói VIP không hợp lệ.');
        const cfg = (await staticConfig('vip_shop'))[value];
        if (!cfg || !Number.isSafeInteger(cfg.need_coin) || cfg.need_coin < 0 || !Number.isSafeInteger(cfg.need_vip))
            fail('Không có gói VIP trong config gốc.');
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') };
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (this.bought(s)[value])
                fail('Gói VIP này đã mua rồi.');
            const profile = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile);
            if ((profile.vip ?? 0) < cfg.need_vip)
                fail('Chưa đủ cấp VIP để mua gói.');
            beginHotSpend(this.db, s.user_id, 'shop.vip_buy', 'legacy-' + Date.now());
            const balance = profile.coin ?? 0;
            if (!Number.isSafeInteger(balance) || balance < cfg.need_coin)
                fail('Không đủ Xu để mua gói VIP.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, coin: balance - cfg.need_coin }), s.user_id);
            const applied = new WelfareService(this.db).applyInTransaction(s, cfg.reward, defs);
            this.db.prepare("INSERT INTO player_claims VALUES(?,'vip_shop','once',?,?)").run(s.user_id, value, Date.now());
            audit(this.db, null, 'shop.vip_buy', s.user_id, 'Mua gói VIP theo config, một lần/account', { coin: balance }, { shopId: value, coin: balance - cfg.need_coin, reward: cfg.reward });
            endHotSpend(this.db, s.user_id);
            this.db.exec('COMMIT');
            return { ...applied, vip_bought: this.bought(s) };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
