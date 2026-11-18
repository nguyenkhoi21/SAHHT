import { HotCards } from './hot-cards.js';
import { InviteCodeService } from './invite-code.service.js';
import { randomUUID } from 'node:crypto';
import { contentReceipt } from './content-receipt.js';
import { hotConfig, hotFail, hotPolicy } from './hot-source.js';
import { audit } from '../admin/admin.audit.js';
import { RechargeSettings } from '../recharge/recharge-settings.js';
import { WelfareLocalService } from '../welfare/welfare-local.service.js';
export class HotRechargeService {
    db;
    now;
    online;
    constructor(db, now = Date.now, online = false) {
        this.db = db;
        this.now = now;
        this.online = online;
    }
    profile(user) { const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(user); if (!row)
        hotFail('Nhân vật chưa vào game.'); return JSON.parse(String(row.profile)); }
    welfare() { return this.db.prepare("SELECT 1 FROM sqlite_master WHERE name='welfare_schema'").get() ? new WelfareLocalService(this.db, this.now, this.online) : null; }
    packages(user) {
        const p = this.profile(user), welfare = this.welfare(), settings = new RechargeSettings(this.db, this.now);
        return Object.entries(hotConfig('charge')).filter(([, c]) => c.is_show === 1).map(([id, c]) => {
            const packageId = Number(id), welfareKind = welfare && [1, 13].includes(packageId) ? (packageId === 1 ? 'month' : 'quarter') : null;
            const card = welfareKind ? welfare.purchaseAvailability(user, welfareKind) : [1, 2].includes(packageId) ? new HotCards(this.db, this.now).available(user, packageId) : null;
            const paid = Number(this.db.prepare('SELECT count(*) n FROM hot_recharges WHERE user_id=? AND package_id=?').get(user, packageId).n), price = settings.get(packageId);
            const supported = (card ? card.supported : c.coin > 0 && c.open_gift === 0) && Number.isSafeInteger(c.price) && Number.isSafeInteger(c.coin) && Number.isSafeInteger(c.vip_exp), bonus = c.gift_coin + (c.is_double === 1 && !paid ? c.coin : 0);
            return { id: packageId, name: c.name, price: c.price, baseCoin: c.coin, bonusCoin: bonus, vipExp: c.vip_exp, eventAmount: c.vip_exp, singleAmount: c.price / 100, isFirst: paid === 0, purchases: paid, tickets: price.tickets, ticketRevision: price.revision, ticketEnabled: price.enabled, ticketEligible: supported && price.enabled && Number.isSafeInteger(price.tickets) && price.tickets > 0, availableTickets: p.ticket ?? 0, supported, welfareKind, blockedReason: supported ? '' : card?.blockedReason ?? 'Gói entitlement chưa đủ hợp đồng; chưa tiêu vé.', policy: hotPolicy.version };
        });
    }
    info(s) {
        const cards = new HotCards(this.db, this.now);
        cards.deliver(s.user_id);
        const p = this.profile(s.user_id);
        const previews = Object.fromEntries(cards.settings().filter(c => c.definition).map(c => [c.packageId, c.definition]));
        const welfare = this.welfare();
        if (welfare)
            for (const [id, kind] of [[1, 'month'], [13, 'quarter']]) {
                const definition = welfare.purchaseAvailability(s.user_id, kind).definition;
                previews[id] = { rewards: definition.rows.map(r => r.rewards), days: definition.rows.length, destination: 'welfare' };
            }
        return { packages: this.packages(s.user_id), ticket: p.ticket ?? 0, vip: p.vip ?? 0, vip_exp: p.vip_exp ?? 0, policy: hotPolicy, cards: previews, step: { double_pay: this.db.prepare('SELECT DISTINCT package_id FROM hot_recharges WHERE user_id=?').all(s.user_id).map(r => Number(r.package_id)) } };
    }
    buy(s, p) {
        const packageId = Number(p.get('package_id')), method = p.get('payment_method'), expected = p.has('expected_tickets') ? Number(p.get('expected_tickets')) : undefined, revision = p.has('ticket_revision') ? Number(p.get('ticket_revision')) : undefined, priceMode = p.get('price_mode');
        if (this.online && method !== 'voucher')
            hotFail('ONLINE chỉ cho mua bằng Vé Vàng; không mở thanh toán giả lập.');
        if (priceMode !== null && priceMode !== 'fixed')
            hotFail('Chế độ giá vé không hợp lệ.');
        if (!['voucher', 'sandbox'].includes(String(method)) || p.get('sandbox_confirm') !== '1')
            hotFail('Chỉ chấp nhận xác nhận giao dịch sandbox LOCAL.');
        if ((expected !== undefined && (!Number.isSafeInteger(expected) || expected < 1)) || (revision !== undefined && (!Number.isSafeInteger(revision) || revision < 0)))
            hotFail('Giá vé xác nhận không hợp lệ.');
        return contentReceipt(this.db, s.user_id, 'hot.recharge', p.get('request_id'), { packageId, method, ...(expected === undefined ? {} : { expected }), ...(revision === undefined ? {} : { revision }), ...(priceMode === null ? {} : { priceMode }) }, () => {
            const row = this.packages(s.user_id).find(r => r.id === packageId);
            if (!row?.supported)
                hotFail(row?.blockedReason ?? 'Gói nạp chưa hỗ trợ.');
            const product = row, profile = this.profile(s.user_id), before = structuredClone(profile);
            if (priceMode === 'fixed') {
                const tickets = product.price / hotPolicy.ticketVnd;
                if (method !== 'voucher' || !Number.isSafeInteger(tickets) || tickets < 1 || expected !== tickets)
                    hotFail('Giá Vé Vàng cố định không khớp gói gốc; chưa trừ vé.');
                product.tickets = tickets;
            }
            if (method === 'voucher') {
                if (priceMode !== 'fixed' && product.ticketRevision > 0 && (expected === undefined || revision === undefined))
                    hotFail('Giá gói đã được Admin cấu hình. Cần APK LOCAL mới để xác nhận đúng giá Vé Vàng.');
                if (priceMode !== 'fixed' && ((expected !== undefined && expected !== product.tickets) || (revision !== undefined && revision !== product.ticketRevision)))
                    hotFail('Giá Vé Vàng đã thay đổi. Mở lại Nạp thẻ và xác nhận giá mới.');
                if (!product.ticketEligible || Number(profile.ticket ?? 0) < product.tickets)
                    hotFail('Không đủ Vé S (Vé Vàng) hoặc gói đã ngừng bán bằng vé.');
                profile.ticket -= product.tickets;
            }
            const added = product.baseCoin + product.bonusCoin;
            profile.coin = Number(profile.coin ?? 0) + added;
            profile.vip_exp = Number(profile.vip_exp ?? 0) + product.vipExp;
            if (!Number.isSafeInteger(profile.coin) || profile.coin > 1000000000 || !Number.isSafeInteger(profile.vip_exp))
                hotFail('Tài nguyên/VIP EXP vượt giới hạn.');
            let vip = Number(profile.vip ?? 0);
            while (vip < 17 && profile.vip_exp >= hotConfig('vip')[vip].need_exp)
                vip++;
            profile.vip = vip;
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), s.user_id);
            const id = 'hotcharge-' + randomUUID(), at = this.now(), meta = { policy: hotPolicy.version, source: 'charge.config', singleAmount: product.singleAmount, ticketRevision: product.ticketRevision, ticketPrice: product.tickets, before: { coin: before.coin, vip: before.vip, vipExp: before.vip_exp ?? 0, ticket: before.ticket ?? 0 }, after: { coin: profile.coin, vip: profile.vip, vipExp: profile.vip_exp, ticket: profile.ticket ?? 0 }, first: product.isFirst };
            this.db.prepare('INSERT INTO hot_recharges VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)').run(id, s.user_id, 'local-1', String(p.get('request_id')), packageId, method, product.price, product.baseCoin, product.bonusCoin, product.vipExp, product.eventAmount, method === 'voucher' ? product.tickets : 0, JSON.stringify(meta), at);
            if (product.welfareKind)
                this.welfare().purchaseInTransaction(s.user_id, product.welfareKind, id);
            else if ([1, 2].includes(packageId))
                new HotCards(this.db, this.now).purchase(s.user_id, packageId, id);
            new InviteCodeService(this.db, this.now).syncVip(s.user_id);
            audit(this.db, null, 'hot.recharge', s.user_id, 'Nạp LOCAL qua gói gốc; không thanh toán thật', meta.before, { ...meta.after, transaction: id, packageId, method });
            return { transaction_id: id, recharge: { packageId, price: product.price, baseCoin: product.baseCoin, bonusCoin: product.bonusCoin, vipExp: product.vipExp, eventAmount: product.eventAmount, singleAmount: product.singleAmount, consumedTickets: method === 'voucher' ? product.tickets : 0, method }, reward: { coin: added }, ...this.info(s) };
        }, old => ({ ...this.info(s), transaction_id: old.transaction_id, replayed: true, reward: {} }));
    }
}
