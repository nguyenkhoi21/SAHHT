import { randomInt } from 'node:crypto';
import { phase36Config } from './phase36-source.js';
import { contentReceipt } from './content-receipt.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { ProgressionService } from './progression.service.js';
import { audit } from '../admin/admin.audit.js';
function fail(s) { throw Object.assign(Error(s), { statusCode: 422 }); }
const int = (s) => typeof s === 'string' && /^\d{1,8}$/.test(s) ? Number(s) : 0;
export class HomelandService {
    db;
    now;
    draw;
    constructor(db, now = () => Date.now(), draw = (max) => randomInt(max)) {
        this.db = db;
        this.now = now;
        this.draw = draw;
    }
    profile(id) { const row = this.db.prepare('SELECT p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?').get(id); if (!row)
        fail('Nhân vật chưa sẵn sàng.'); return { ...JSON.parse(String(row.profile)), uid: row.game_uid, role: row.role }; }
    eligible(id) { this.profile(id); const gate = new ProgressionService(this.db).featureGates(id).find(g => g.buttonId === 701); if (gate && !gate.prerequisiteMet)
        fail('Chưa đủ điều kiện mở Farm theo tiến trình gốc.'); }
    state(id) { const r = this.db.prepare('SELECT state FROM player_homeland WHERE user_id=?').get(id); return r ? JSON.parse(String(r.state)) : { level: 1, help_exp: 0, plots: {}, days: {}, store: {}, use_adorn: {} }; }
    save(id, s) { this.db.prepare('INSERT INTO player_homeland VALUES(?,?,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state,updated_at=excluded.updated_at').run(id, JSON.stringify(s), this.now()); }
    day() { return new Date(this.now() + 7 * 3600000).toISOString().slice(0, 10); }
    within(c) { const time = new Date(this.now() + 7 * 3600000).toISOString().slice(11, 19); return time >= c.start_time && time <= c.close_time; }
    target(uid) { const r = this.db.prepare('SELECT user_id FROM player_profiles WHERE game_uid=?').get(uid ?? ''); if (!r)
        fail('Chủ Farm không tồn tại.'); return Number(r.user_id); }
    index(id, visitor = id) {
        this.eligible(visitor);
        const s = this.state(id), p = this.profile(id), farm = {};
        for (let slot = 1; slot <= s.level + 1; slot++) {
            const crop = s.plots[slot];
            farm[slot] = crop ? { c_id: crop.cid, multiple: crop.multiple, matured: this.now() >= crop.readyAt ? 1 : 0, expire: Math.max(0, Math.ceil((crop.readyAt - this.now()) / 1000)), self_havest_times: 0, steal_uids: [], finger_result: {} } : {};
        }
        return { name: p.show_name, uid: p.uid, level: s.level, help_exp: s.help_exp, farm, use_adorn: s.use_adorn, store: s.store, reward_ids: {}, can_watering: [], reward: {}, fight_hero: 0, visit_log: [], source_status: 'Trồng/thu hoạch theo nguồn; EXP nâng Farm/tưới/trộm/rương/roulette chưa đủ công thức server.' };
    }
    read(id, method, p) {
        this.eligible(id);
        if (method === 'homeland.index')
            return this.index(id);
        if (method === 'homeland.store_index')
            return { store: this.state(id).store };
        if (method === 'homeland.visit')
            return this.index(this.target(p.get('friend_uid')), id);
        if (method === 'homeland.friends') {
            const others = this.db.prepare('SELECT CASE WHEN low_id=? THEN high_id ELSE low_id END id FROM friendships WHERE low_id=? OR high_id=?').all(id, id, id);
            return { friends: others.map(r => { const x = this.profile(Number(r.id)); return { uid: x.uid, name: x.show_name, role: x.role, level: x.level, can_steal: [], can_watering: [] }; }), steal_times: 0, max_steal_times: phase36Config('homeland_grow')['1'].all_steal_times };
        }
        fail('Mục Farm này thiếu quy tắc server gốc; chưa tiêu tài nguyên hoặc cấp thưởng.');
    }
    execute(s, method, p) {
        if (!['homeland.sowing', 'homeland.havest', 'homeland.auto_havest', 'homeland.shop_buy', 'homeland.use_adorn', 'homeland.cancel_adorn'].includes(method))
            fail('Farm chưa có công thức gốc cho thao tác này; chưa thay đổi tài nguyên.');
        const body = Object.fromEntries([...p].filter(([k]) => !['request_id', 'user_token', 'mk', 'rans', 'account'].includes(k)).sort(([a], [b]) => a.localeCompare(b)));
        return contentReceipt(this.db, s.user_id, method, p.get('request_id'), body, () => {
            this.eligible(s.user_id);
            const state = this.state(s.user_id);
            let delivery = {};
            if (method === 'homeland.sowing') {
                const plot = int(p.get('farm_id')), cid = int(p.get('c_id')), cfg = phase36Config('homeland_grow')[cid];
                if (plot < 1 || plot > state.level + 1 || !cfg)
                    fail('Ô đất hoặc cây trồng không hợp lệ.');
                if (plot % 2 === 0 ? cid !== 16 : cid === 16)
                    fail('Ô chẵn dành riêng Đá Fancy; ô lẻ dành sản phẩm khác.');
                if (state.plots[plot])
                    fail('Ô đất đã có cây, cần thu hoạch trước.');
                if (!this.within(cfg))
                    fail('Ngoài khung giờ trồng Farm nguồn.');
                const day = state.days[this.day()] ??= {}, history = day[plot] ?? [];
                const limit = plot % 2 === 0 ? cfg.item_grow_times : 3;
                if (history.length >= limit || history.filter((v) => v === cid).length >= cfg.item_grow_times)
                    fail('Đã hết lượt trồng ô/loại sản phẩm trong ngày.');
                const total = cfg.tree_rate.reduce((n, [w]) => n + w, 0);
                let ticket = this.draw(total), multiple = 0;
                for (const [w, m] of cfg.tree_rate) {
                    ticket -= w;
                    if (ticket < 0) {
                        multiple = m;
                        break;
                    }
                }
                if (![1, 2, 3, 5].includes(multiple))
                    fail('Tỷ lệ cây nguồn không hợp lệ.');
                state.plots[plot] = { cid, multiple, startedAt: this.now(), readyAt: this.now() + cfg.ripe_period * 60000 };
                history.push(cid);
                day[plot] = history;
                state.days[this.day()] = day;
            }
            else if (method === 'homeland.havest' || method === 'homeland.auto_havest') {
                const selected = method === 'homeland.havest' ? [int(p.get('farm_id'))] : Object.keys(state.plots).map(Number).filter(n => state.plots[n].readyAt <= this.now());
                if (!selected.length)
                    fail('Chưa có cây chín để thu hoạch.');
                const rewards = new Map();
                for (const slot of selected) {
                    const crop = state.plots[slot];
                    if (!crop || crop.readyAt > this.now())
                        fail('Cây chưa chín hoặc đã được thu hoạch.');
                    const cfg = phase36Config('homeland_grow')[crop.cid];
                    for (const [kind, cid, n] of cfg.item) {
                        const key = kind + ':' + cid, row = rewards.get(key) ?? [kind, cid, 0];
                        row[2] += n * crop.multiple;
                        rewards.set(key, row);
                    }
                    delete state.plots[slot];
                }
                delivery = grantGodfieldReward(this.db, s, [...rewards.values()]);
            }
            else if (method === 'homeland.shop_buy') {
                const offer = phase36Config('homeland_shop')[int(p.get('shop_id'))], profile = this.profile(s.user_id);
                if (!offer || !offer.show_level.some(([a, b]) => profile.level >= a && profile.level < b))
                    fail('Trang trí Farm không đủ điều kiện nguồn.');
                if (Number(state.store[offer.adorn_id] ?? 0) >= offer.sell_max)
                    fail('Đã sở hữu đủ trang trí này.');
                new ProgressionEconomyService(this.db).cost(s, offer.price);
                state.store[offer.adorn_id] = Number(state.store[offer.adorn_id] ?? 0) + 1;
                if (p.get('is_use') === '1')
                    state.use_adorn[String(offer.type)] = offer.adorn_id;
            }
            else {
                const cid = int(p.get('adorn_id')), adorn = phase36Config('homeland_adorn')[cid];
                if (!adorn || !state.store[cid])
                    fail('Trang trí Farm chưa thuộc tài khoản.');
                if (method === 'homeland.use_adorn')
                    state.use_adorn[String(adorn.type)] = cid;
                else if (state.use_adorn[String(adorn.type)] === cid)
                    delete state.use_adorn[String(adorn.type)];
                else
                    fail('Trang trí này chưa được sử dụng.');
            }
            this.save(s.user_id, state);
            audit(this.db, null, method, s.user_id, 'Farm nguồn Việt Nam · transaction/timer server', null, { requestKey: p.get('request_id'), plot: p.get('farm_id'), crop: p.get('c_id') });
            return { ...this.index(s.user_id), ...delivery };
        }, old => new ProgressionEconomyService(this.db).packet(s, { ...old, ...this.index(s.user_id), reward: {}, replayed: true }));
    }
    matureQa(admin, id, key, plot) {
        return contentReceipt(this.db, id, 'local.homeland.mature', key, { plot }, () => { const s = this.state(id), crop = s.plots[plot]; if (!crop)
            fail('Ô đất không có cây.'); const before = crop.readyAt; crop.readyAt = Math.min(this.now(), crop.readyAt); this.save(id, s); audit(this.db, admin, 'homeland.qa.mature', id, 'LOCAL QA: chỉ làm chín cây đang có; không cấp thưởng', { readyAt: before }, { plot, readyAt: crop.readyAt }); return { ok: true }; }, old => old);
    }
    diagnostics(id) { return { state: this.state(id), packet: this.index(id), crops: phase36Config('homeland_grow'), shop: phase36Config('homeland_shop'), history: this.db.prepare("SELECT action,summary,created_at FROM admin_audit WHERE target_user_id=? AND action LIKE 'homeland.%' ORDER BY id DESC LIMIT 60").all(id), limitations: ['Chưa có EXP/tưới/trộm/oẳn tù tì/rương/roulette server gốc; khóa các thao tác này.', 'Farm homeland khác Vùng Đất Vô Chủ/seed/farm_open; không gắn nhầm hạn cấp80.', 'Theo notice190: ô thường tối đa3 cây khác loại/ngày; ô Fancy theo config16 tối đa6.'] }; }
}
