import { campaignRows, campaignState, rowProblem, hotTabs } from './hot-campaigns.js';
import { hotConfig, hotDay, hotFail, hotPolicy, hotStamp } from './hot-source.js';
import { contentReceipt } from './content-receipt.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { readConfigSync } from './local-content.js';
import { WelfareService } from './welfare.service.js';
import { ExchangeService } from './exchange.service.js';
import { audit } from '../admin/admin.audit.js';
export class HotService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    profile(user) { const r = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(user); if (!r)
        hotFail('Nhân vật chưa vào game.'); return JSON.parse(String(r.profile)); }
    period(c, at = this.now()) { return c.reset === 'daily' ? hotDay(at) : String(c.starts); }
    window(c, at = this.now()) { return { start: c.reset === 'daily' ? Math.max(c.starts, hotStamp(hotDay(at) + 'T00:00')) : c.starts, end: Math.min(c.ends, at) }; }
    wireId(c, row, index) { return c.source ? Number(row.wireId) : 200000000 + Number(c.dbId) * 1000 + index + 1; }
    active(user, at = this.now()) { const p = this.profile(user); return campaignRows(this.db).filter(c => campaignState(c, at) === 'active' && c.realm === 'local-1' && p.level >= c.level[0] && p.level <= c.level[1]).sort((a, b) => a.order - b.order || a.starts - b.starts); }
    used(user, c, row, at = this.now()) { return Number(this.db.prepare('SELECT count(*) n FROM hot_claims WHERE user_id=? AND campaign=? AND row_key=? AND period=?').get(user, c.id, row.key, this.period(c, at)).n); }
    progress(user, c, row, at = this.now()) {
        const w = this.window(c, at);
        if (c.kind === 'exchange')
            return 0;
        if (c.kind === 'spend') {
            if (!c.spendKinds.length)
                return 0;
            const sums = this.db.prepare('SELECT kind,SUM(amount) amount FROM hot_spending WHERE user_id=? AND realm=? AND created_at>=? AND created_at<=? GROUP BY kind').all(user, c.realm, w.start, w.end);
            return sums.reduce((n, s) => n + (c.spendKinds.includes(String(s.kind)) ? Number(s.amount) : 0), 0);
        }
        const rows = this.db.prepare('SELECT * FROM hot_recharges WHERE user_id=? AND realm=? AND created_at>=? AND created_at<=?').all(user, c.realm, w.start, w.end);
        if (c.kind === 'total')
            return rows.reduce((n, r) => n + Number(r.event_amount), 0);
        // Nguồn charge_id phân biệt gói: nhiều gói nhỏ không ghép thành một lần.
        return rows.filter(r => row.packageId ? Number(r.package_id) === row.packageId : Number(r.price) / 100 >= row.threshold).length;
    }
    entries(user, at = this.now()) { return this.active(user, at).flatMap(c => c.rows.map((row, index) => { const used = this.used(user, c, row, at), progress = this.progress(user, c, row, at), problem = rowProblem(row, c.kind), enough = c.kind === 'exchange' ? this.affordable(user, row.inputs) : c.kind === 'single' ? progress > used : progress >= row.threshold * (row.limit === 0 ? used + 1 : 1), limit = row.limit ?? 1; return { campaign: c, row, wireId: this.wireId(c, row, index), used, progress, problem, flag: limit && used >= limit ? 2 : problem || !enough ? 1 : 0 }; })); }
    affordable(user, inputs) { const p = this.profile(user), fields = { 1: 'food', 2: 'metal', 4: 'crystal', 9: 'coin', 10: 'dirt_silver', 11: 'dirt_gold', 15: 'silver', 17: 'grace', 18: 'grace_high', 20: 'adv_crystal', 23: 'refine_stone', 33: 'small_forge_stone', 34: 'middle_forge_stone', 35: 'high_forge_stone', 40: 'super_crystal', 41: 'min_fate_stone', 42: 'mid_fate_stone', 43: 'max_fate_stone' }; return inputs.every(([t, id, n]) => t === 6 ? Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(user, id)?.quantity ?? 0) >= n : fields[t] && Number(p[fields[t]] ?? 0) >= n); }
    index(s, at = this.now()) {
        const show = {}, configs = { active_show: {}, active_recharge: {}, active_consume: {}, omni_exchange: {} }, entries = this.entries(s.user_id, at);
        for (const [id, source] of Object.entries(hotConfig('active_show'))) {
            configs.active_show[id] = source;
            show[id] = { flag: 0, active_time: 0, context: {} };
        }
        for (const { campaign: c, row, wireId, used, progress, problem, flag } of entries) {
            const tab = hotTabs[c.kind], remaining = Math.max(0, Math.floor((c.ends - at) / 1000));
            show[tab].flag = 1;
            show[tab].active_time = Math.max(show[tab].active_time, remaining);
            show[tab].context[wireId] = { flag, now_value: progress, claimed: used, reason: problem ?? '' };
            const time = (stamp) => new Date(stamp + 7 * 3600000).toISOString().slice(0, 16).replace('T', ' '), base = { ...row.source, des: row.name, show_time: time(c.starts) + ' -- ' + time(c.ends - 1), reward: row.rewards, show_id: row.order, num: row.threshold, repeat: row.limit === 1 ? 0 : 1 };
            if (c.kind === 'single' || c.kind === 'total')
                configs.active_recharge[wireId] = { ...base, charge_type: c.kind === 'single' ? 1 : 2, charge_id: row.packageId };
            else if (c.kind === 'spend')
                configs.active_consume[wireId] = { ...base, consume_type: 2 };
            else
                configs.omni_exchange[wireId] = { ...(row.source ?? {}), show_id: wireId, type: 1, exchange_type: row.limit ? 1 : 0, exchange_num: row.limit, exchange_time: 1, start_time: Math.floor(c.starts / 1000), end_time: Math.ceil(c.ends / 1000), need_item: row.inputs, out_item1: row.rewards, out_item2: [], out_item3: [], out_item4: [], out_item5: [], step: 0, break: 0, material_type: 0, strengthen: 0, equip_st: 0 };
        }
        const unlimited = new ExchangeService(this.db, this.now);
        const legacy = unlimited.show();
        for (const [id, row] of Object.entries(hotConfig('active_show')))
            if (row.sort === 5)
                show[id] = legacy.show[id] ?? { flag: 0, active_time: 0, context: {} };
        const exchangeLog = Object.fromEntries(entries.filter(e => e.campaign.kind === 'exchange').map(e => [e.wireId, e.used]));
        return { show, hot_configs: configs, exchange_log: exchangeLog, policy: hotPolicy, server_time: Math.floor(at / 1000) };
    }
    claim(s, kind, p) {
        const id = Number(p.get(kind === 'exchange' ? 'id' : 'active_id'));
        return contentReceipt(this.db, s.user_id, 'hot.' + kind, p.get('request_id'), { id }, () => {
            const at = this.now(), entry = this.entries(s.user_id, at).find(e => e.wireId === id && (kind === 'exchange' ? e.campaign.kind === 'exchange' : kind === 'consume' ? e.campaign.kind === 'spend' : ['single', 'total'].includes(e.campaign.kind)));
            if (!entry)
                hotFail('Chiến dịch hết hạn hoặc không thuộc realm/cấp hiện tại.');
            const { campaign: c, row } = entry;
            if (entry.problem)
                hotFail(entry.problem);
            if (row.limit && entry.used >= row.limit)
                hotFail('Bạn đã nhận hết hạn mức mốc này.');
            if (entry.flag !== 0)
                hotFail('Chưa đủ điều kiện nhận thưởng/trao đổi.');
            const economy = new ProgressionEconomyService(this.db, this.now);
            if (kind === 'exchange')
                economy.cost(s, row.inputs, p);
            const result = new WelfareService(this.db, this.now).applyInTransaction(s, row.rewards, { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') });
            this.db.prepare('INSERT INTO hot_claims VALUES(?,?,?,?,?,?,?)').run(s.user_id, c.id, row.key, this.period(c, at), entry.used + 1, JSON.stringify(row.rewards), at);
            audit(this.db, null, 'hot.' + kind, s.user_id, 'Thưởng HOT theo snapshot chiến dịch/realm; nguyên tử', null, { campaign: c.id, row: row.key, rewards: row.rewards, inputs: row.inputs, period: this.period(c, at) });
            const allItems = Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id).map(r => [r.config_id, [r.quantity]]));
            return { ...this.index(s, at), ...result, _client_cache_update: { ...result._client_cache_update, item: { items: { update: allItems, remove: [] } } } };
        }, () => ({ ...this.index(s), reward: [], replayed: true, _client_cache_update: { item: { items: { update: Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id).map(r => [r.config_id, [r.quantity]])), remove: [] } } } }));
    }
    history(user, q = {}) { const page = Math.max(1, Number(q.page) || 1), offset = (page - 1) * 30; return { page, recharges: this.db.prepare('SELECT * FROM hot_recharges WHERE user_id=? ORDER BY created_at DESC LIMIT 30 OFFSET ?').all(user, offset), claims: this.db.prepare('SELECT * FROM hot_claims WHERE user_id=? ORDER BY created_at DESC LIMIT 30 OFFSET ?').all(user, offset), spending: this.db.prepare('SELECT * FROM hot_spending WHERE user_id=? ORDER BY created_at DESC LIMIT 30 OFFSET ?').all(user, offset), profile: this.profile(user), progress: this.entries(user).map(e => ({ campaign: e.campaign.id, row: e.row.key, kind: e.campaign.kind, progress: e.progress, threshold: e.row.threshold, claimed: e.used, flag: e.flag, problem: e.problem })), policy: hotPolicy }; }
}
