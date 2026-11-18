import { economyConfig, economyFail, ProgressionEconomyService } from './progression-economy.js';
import { WelfareService } from './welfare.service.js';
import { EventCalendarService } from './event-calendar.js';
export class ExchangeService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    available() { const override = new EventCalendarService(this.db, this.now).override('hot_exchange'); if (override !== null)
        return override; const row = Object.values(economyConfig('active_show')).find((r) => r.sort === 5); if (!row)
        return false; const parse = (v) => Date.parse(v.replaceAll('/', '-').replace(/[, ]/, 'T') + ':00+07:00'); return parse(row.start_time) <= this.now() && this.now() <= parse(row.end_time); }
    rewards(c) { return [1, 2, 3, 4, 5].flatMap(n => c['out_item' + n] ?? []).map((r) => r.slice(0, 3)); }
    reason(c) { const items = economyConfig('item'), heroes = economyConfig('character_detail'), equip = economyConfig('equip'); for (const r of [...c.need_item, ...this.rewards(c)]) {
        const [t, id, n] = r;
        if (!Number.isSafeInteger(n) || n <= 0)
            return 'Số lượng nguồn không hợp lệ.';
        if (t === 6 && !items[id])
            return 'Thiếu vật phẩm #' + id;
        if (t === 5 && !heroes[id])
            return 'Thiếu thẻ #' + id;
        if (t === 7 && !equip[id])
            return 'Thiếu trang bị #' + id;
        if (![1, 2, 9, 10, 11, 17, 18, 20, 23, 33, 34, 35, 40, 41, 42, 43, 5, 6, 7].includes(t))
            return 'Chưa hỗ trợ loại phần thưởng/chi phí ' + t;
    } if (c.need_item.some((r) => r[0] === 7))
        return 'Chưa đủ quy tắc tiêu trang bị theo strengthen/equip_st.'; return this.rewards(c).length ? '' : 'Chưa có phần thưởng.'; }
    scheduled(c) { const override = new EventCalendarService(this.db, this.now).override('exchange.' + c.show_id); if (override !== null)
        return override; if (c.exchange_time === 0)
        return true; const parse = (v) => typeof v === 'number' ? v * 1000 : Date.parse(String(v).replaceAll('/', '-').replace(/[, ]/, 'T') + ':00+07:00'); return parse(c.start_time) <= this.now() && this.now() <= parse(c.end_time); }
    catalog(s) { return { source: 'VN runtime normal_exchange · hash được khóa', enabled: this.available(), recipes: Object.entries(economyConfig('normal_exchange')).map(([id, c]) => ({ id: Number(id), ...c, rewards: this.rewards(c), blockedReason: this.reason(c), active: this.available() && this.scheduled(c), unlimited: c.exchange_type === 0 })), history: this.db.prepare("SELECT request_key,result,created_at FROM player_content_operations WHERE user_id=? AND method='normal_exchange.normal_exchange' ORDER BY created_at DESC LIMIT 40").all(s.user_id) }; }
    index(s) { const records = this.db.prepare("SELECT result FROM player_content_operations WHERE user_id=? AND method='normal_exchange.normal_exchange'").all(s.user_id), exchange_log = {}; for (const r of records) {
        const v = JSON.parse(String(r.result));
        exchange_log[v.recipe_id] = (exchange_log[v.recipe_id] ?? 0) + 1;
    } const calendar = new EventCalendarService(this.db, this.now), entries = Object.entries(economyConfig("normal_exchange")); return { recipe_availability: Object.fromEntries(entries.map(([id, c]) => [id, this.available() && this.scheduled(c) && !this.reason(c) ? 1 : 0])), qa_overrides: Object.fromEntries(entries.filter(([, c]) => calendar.override("exchange." + c.show_id) !== null).map(([id, c]) => [id, calendar.override("exchange." + c.show_id) ? 1 : 0])), exchange_log, calendar_policy: 'SOURCE_UNLIMITED', active: this.available() }; }
    show() { const rows = economyConfig('active_show'); return { show: Object.fromEntries(Object.entries(rows).sort(([a], [b]) => Number(a) - Number(b)).map(([id, c]) => [id, { flag: c.sort === 5 && this.available() ? 1 : 0, active_time: 0 }])), calendar_policy: 'SOURCE_UNLIMITED' }; }
    exchange(s, p) { const svc = new ProgressionEconomyService(this.db, this.now); return svc.execute(s, 'normal_exchange.normal_exchange', p, () => { const matches = Object.values(economyConfig('normal_exchange')).filter((c) => String(c.show_id) === p.get('id')); if (matches.length !== 1)
        economyFail('Mã đổi không tồn tại hoặc không duy nhất.'); const c = matches[0], reason = this.reason(c); if (reason)
        economyFail(reason); if (!this.available() || !this.scheduled(c))
        economyFail('Ngoài lịch trao đổi.'); const used = this.index(s).exchange_log[c.show_id] ?? 0; if (c.exchange_type !== 0 && used >= c.exchange_num)
        economyFail('Đã hết số lượt trao đổi nguồn.'); if ((c.step || c.break || c.material_type) && c.need_item.some((r) => r[0] === 5))
        economyFail('Công thức yêu cầu trạng thái thẻ đặc biệt chưa tái dựng.'); const removed = svc.cost(s, c.need_item, p), rewards = this.rewards(c); new WelfareService(this.db).applyInTransaction(s, rewards, { heroes: economyConfig('character_detail'), items: economyConfig('item'), equipment: economyConfig('equip') }); return { reward: rewards, removed, recipe_id: c.show_id, exchange_log: { ...this.index(s).exchange_log, [c.show_id]: used + 1 } }; }); }
}
