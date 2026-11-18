import { inventoryRewardItem } from './inventory-items.js';
import { auxRewardKind, auxiliaryDefinition, auxiliaryCache } from './auxiliary-state.js';
import { randomInt, createHash } from 'node:crypto';
import { readConfigSync } from './local-content.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { equipmentClientState, heroBindingClientState } from './definitions.js';
import { PlayerService } from './player.service.js';
import { FateEmpowermentService, fateCache, fateGemDefinition } from './fate-empowerment.js';
import { expandInventory, inventoryBags } from './inventory-capacity.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
const configs = new Map();
const config = (name) => { if (!configs.has(name))
    configs.set(name, readConfigSync(name)); return configs.get(name); };
const integer = (v, min = 1, max = 99) => { const n = Number(v); if (typeof v !== 'string' && typeof v !== 'number' || !/^[0-9]+$/.test(String(v)) || !Number.isSafeInteger(n) || n < min || n > max)
    fail('Số lượng hoặc mã không hợp lệ.'); return n; };
export const destinyFields = ['patk', 'matk', 'def', 'speed', 'hp'];
export class EquipmentDestinyService {
    db;
    random;
    constructor(db, random = randomInt) {
        this.db = db;
        this.random = random;
    }
    profile(s) { return JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile)); }
    gems(s) { return Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_fate_gems WHERE user_id=? AND quantity>0').all(s.user_id).map(r => [String(r.config_id), Number(r.quantity)])); }
    snapshot(s) {
        const rows = (table) => Object.fromEntries(this.db.prepare(`SELECT id,state FROM ${table} WHERE user_id=?`).all(s.user_id).map(r => { const state = Object.fromEntries(Object.entries(JSON.parse(String(r.state))).filter(([key]) => !key.startsWith('_local_'))); return [String(r.id), table === 'player_equipment' ? equipmentClientState(state) : { hp_crystal: 0, patk_crystal: 0, matk_crystal: 0, def_crystal: 0, speed_crystal: 0, ...heroBindingClientState(state) }]; }));
        const items = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id), gems = this.gems(s);
        return { gem_all: gems, _client_cache_update: { ...auxiliaryCache(this.db, s.user_id), equip: { _equip: { update: rows('player_equipment'), remove: [] } }, cards: { cards: { update: new PlayerService(this.db).cards(s, true).cards, remove: [] } }, item: { items: { update: Object.fromEntries(items.filter(r => Number(r.quantity) > 0).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: items.filter(r => Number(r.quantity) === 0).map(r => String(r.config_id)) } }, gem_fate: { ...fateCache(this.db, s.user_id), _gem_fate: { update: gems, remove: this.db.prepare('SELECT config_id FROM player_fate_gems WHERE user_id=? AND quantity=0').all(s.user_id).map(r => String(r.config_id)) } } } };
    }
    equipment(s, value) {
        if (typeof value !== 'string' || !/^[-a-zA-Z0-9]{1,80}$/.test(value))
            fail('Mã trang bị không hợp lệ.');
        const row = this.db.prepare('SELECT state FROM player_equipment WHERE user_id=? AND id=?').get(s.user_id, value);
        if (!row)
            fail('Trang bị không thuộc tài khoản.');
        const item = equipmentClientState(JSON.parse(String(row.state))), cfg = config('equip')[String(item.c_id)];
        if (!cfg)
            fail('Thiếu config trang bị.');
        return { item, cfg };
    }
    saveEquipment(s, item) { this.db.prepare('UPDATE player_equipment SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(item), s.user_id, item.id); }
    cost(s, rewards) {
        const p = this.profile(s), items = {}, fields = { 9: 'coin', 2: 'metal', 41: 'min_fate_stone', 42: 'mid_fate_stone', 43: 'max_fate_stone' };
        for (const [type, id, n] of rewards) {
            if (!Number.isSafeInteger(n) || n < 0)
                fail('Chi phí ngoài schema đã xác minh.');
            if (!n)
                continue;
            if (type === 6) {
                const own = items[id] ?? Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0);
                if (own < n)
                    fail('Không đủ vật phẩm nguyên liệu.');
                items[id] = own - n;
            }
            else {
                const field = fields[type];
                if (!field || id !== 0)
                    fail('Loại chi phí chưa hỗ trợ.');
                const own = p[field] ?? 0;
                if (!Number.isSafeInteger(own) || own < n)
                    fail('Không đủ tài nguyên Vận Mệnh.');
                p[field] = own - n;
            }
        }
        for (const [id, n] of Object.entries(items))
            this.db.prepare('UPDATE player_items SET quantity=? WHERE user_id=? AND config_id=?').run(n, s.user_id, Number(id));
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), s.user_id);
    }
    gemDelta(s, id, delta) {
        if (!config('equip_gem_fate')[String(id)] || !Number.isSafeInteger(delta))
            fail('Đá Vận Mệnh không hợp lệ.');
        const own = Number(this.db.prepare('SELECT quantity FROM player_fate_gems WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0), next = own + delta;
        if (next < 0)
            fail('Không đủ đá Vận Mệnh.');
        if (next > 1_000_000)
            fail('Kho đá Vận Mệnh đã đầy.');
        this.db.prepare('INSERT INTO player_fate_gems VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(s.user_id, id, next);
    }
    supportedReward(r) {
        if (!Array.isArray(r) || r.length < 3 || !r.slice(0, 3).every(Number.isSafeInteger) || r[2] < 1 || r[2] > 1_000_000)
            return false;
        const [t, id] = r, aux = auxRewardKind(t);
        if (aux) {
            try {
                auxiliaryDefinition(aux, id);
                return !['talisman', 'soul'].includes(aux) || r[2] <= 5;
            }
            catch {
                return false;
            }
        }
        return t === 5 ? !!config('character_detail')[id] && config('character_detail')[id].skill_1_source !== undefined : t === 7 ? !!config('equip')[id] : t === 50 ? !!config('equip_gem_fate')[id] : t === 108 ? !!config('equip_gem_fate_stone')[id] : t === 109 ? !!config('equip_gem_fate_word')[id] : t === 6 ? inventoryRewardItem(config('item')[id]) : [1, 2, 4, 9, 10, 11, 15, 16, 17, 18, 20, 23, 33, 34, 35, 40, 41, 42, 43].includes(t) && id === 0;
    }
    voucher(id) {
        const item = config('item')[String(id)], pools = config('box')[String(item?.use_effect?.[0])];
        if (!item || ![1, 15].includes(item.is_use) || item.daily_use !== 0 || item.use_num !== 1 || !Array.isArray(pools))
            fail('Phiếu chưa có quy tắc mở được xác minh.');
        // Box có sáu ô cố định; một số phiếu VN để num=1 trên ô reward rỗng.
        // Ô không có reward không tạo kết quả; vẫn kiểm nghiêm mọi ô có nội dung.
        const active = pools.filter((p) => p.num > 0 && Array.isArray(p.reward) && p.reward.length > 0);
        if (!active.length || active.length > 6 || active.some((p) => !Number.isSafeInteger(p.num) || p.num < 1 || p.num > p.reward.length || p.reward.some((r) => !this.supportedReward(r))))
            fail('Gói có dependency chưa hỗ trợ; chưa tiêu phiếu.');
        if (item.is_use === 1 && active.some((p) => p.num !== p.reward.length && (p.num !== 1 || p.reward.some((r) => !Number.isSafeInteger(r[3]) || r[3] <= 0))))
            fail('Rương ngẫu nhiên thiếu trọng số/kỳ vọng chọn một; chưa tiêu vật phẩm.');
        return { id, name: item.name, icon: item.icon, isUse: item.is_use, pools: active };
    }
    catalog() {
        const vouchers = [], blockedVouchers = [];
        for (const [id, r] of Object.entries(config('item'))) {
            if (!/phiếu|vé|p\.đá|rương đá vận mệnh/i.test(r.name) || !r.is_use)
                continue;
            try {
                const v = this.voucher(Number(id));
                if (v.pools.some((p) => p.reward.some((reward) => reward[0] === 7 || reward[0] === 50 || reward[0] === 6 && /năm|trang bị/i.test(v.name))))
                    vouchers.push(v);
            }
            catch (error) {
                if (/năm|trang bị|vận mệnh/i.test(r.name))
                    blockedVouchers.push({ id: Number(id), name: r.name, boxId: r.use_effect?.[0] ?? null, reason: error instanceof Error ? error.message : 'Chưa đủ dữ liệu xác minh.' });
            }
        }
        return { vouchers, blockedVouchers, gems: Object.entries(config('equip_gem_fate')).map(([id, r]) => ({ ...r, id: Number(id), team: r.team })), fields: destinyFields, notice: 'Khóa Vận Mệnh là ràng buộc trang bị với tướng. Tăng % từ bảng equip_fate; không phải khóa dòng tẩy luyện. Ghép đá dùng need_gem/gem_num/need_item/iron, không có xác suất thất bại trong contract này.' };
    }
    // Mọi mutation có receipt cùng transaction; retry trả cache hiện tại, không phát animation thưởng lần hai.
    execute(s, method, params, adminId = null) {
        const key = params.get('request_id') ?? '';
        if (!/^[A-Za-z0-9_.:-]{8,160}$/.test(key))
            fail('Thiếu mã thao tác duy nhất; hãy dùng client test mới.');
        const fields = [...params].filter(([k]) => !['request_id', 'rans', 'user_token', 'mk', 'method'].includes(k)).sort(([a, av], [b, bv]) => a.localeCompare(b) || av.localeCompare(bv));
        const hash = createHash('sha256').update(JSON.stringify(fields)).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT method,fingerprint,result FROM player_content_operations WHERE user_id=? AND request_key=?').get(s.user_id, key);
            if (old) {
                if (old.method !== method || old.fingerprint !== hash)
                    fail('Mã thao tác đã được dùng cho nội dung khác.');
                const result = { ...JSON.parse(String(old.result)), reward: [], effect: [], replayed: true, ...this.snapshot(s) };
                if (method === 'gem_fate.using_gem_fate')
                    result.equip_info = this.equipment(s, params.get('major')).item;
                result._client_cache_update.gem_fate._gem_special.remove = result.removedSpecial ?? [];
                this.db.exec('COMMIT');
                return result;
            }
            let result = {};
            if (['gem_fate.empowering', 'gem_fate.printing', 'gem_fate.transfer'].includes(method))
                result = new FateEmpowermentService(this.db, this.random).execute(s.user_id, method, params);
            else if (method === 'item.use')
                result = this.redeem(s, params);
            else if (method === 'equip.fate_equip_bind')
                result = this.bind(s, params);
            else if (method === 'equip.fate_equip_unbind')
                result = this.unbind(s, params);
            else if (method === 'equip.fate_equip_levelup')
                result = this.upgrade(s, params);
            else if (method === 'equip.auto_fate_equip_levelup')
                result = this.upgradeTen(s, params);
            else if (method === 'gem_fate.synthesis_gem_fate')
                result = this.synthesize(s, params);
            else if (method === 'gem_fate.using_gem_fate')
                result = this.socket(s, params);
            else if (method === 'admin.fate_grant' && adminId !== null) {
                const type = integer(params.get('type'), 41, 50), id = integer(params.get('config_id'), 0, 999999), quantity = integer(params.get('quantity'), 1, 1000000);
                if (![41, 42, 43, 50].includes(type))
                    fail('Loại tài nguyên QA không hợp lệ.');
                result = new WelfareService(this.db).applyInTransaction(s, [[type, id, quantity]], { heroes: config('character_detail'), items: config('item'), equipment: config('equip') });
            }
            else if (method === 'admin.fate_voucher_grant' && adminId !== null) {
                const id = integer(params.get('config_id'), 1, 99999999), quantity = integer(params.get('quantity'), 1, 9999);
                this.voucher(id);
                result = new WelfareService(this.db).applyInTransaction(s, [[6, id, quantity]], { heroes: config('character_detail'), items: config('item'), equipment: config('equip') });
            }
            else if (method === 'admin.fate_material_grant' && adminId !== null) {
                const id = integer(params.get('config_id'), 1, 99999999), quantity = integer(params.get('quantity'), 1, 9999);
                if (!Object.values(config('equip_gem_fate')).some((g) => g.need_item.some((r) => r[0] === 6 && r[1] === id)))
                    fail('Vật phẩm không thuộc công thức ghép đá đã xác minh.');
                result = new WelfareService(this.db).applyInTransaction(s, [[6, id, quantity]], { heroes: config('character_detail'), items: config('item'), equipment: config('equip') });
            }
            else
                fail('Thao tác Vận Mệnh chưa được tái dựng.');
            audit(this.db, adminId, method, s.user_id, 'Pha20: mutation theo config Việt Nam, receipt nguyên tử', null, { key, params: Object.fromEntries(fields), result });
            this.db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(s.user_id, key, method, hash, JSON.stringify(result), Date.now());
            const packet = { ...result, ...this.snapshot(s) };
            packet._client_cache_update.gem_fate._gem_special.remove = result.removedSpecial ?? [];
            this.db.exec('COMMIT');
            return packet;
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
    redeem(s, p) {
        const id = integer(p.get('item_id'), 1, 99999999), item = config('item')[id];
        // Nút Dùng hàng loạt dùng stack nguồn; không dùng trần99 của các trường lựa chọn/tiến cấp.
        if (!Number.isSafeInteger(item?.stack) || item.stack < 1)
            fail('Vật phẩm chưa có giới hạn chồng hợp lệ.');
        const n = integer(p.get('num'), 1, item.stack);
        const owned = Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0);
        if (owned < n)
            fail('Không đủ vật phẩm nguyên liệu.'); // Kiểm trước khi bốc thưởng hàng loạt.
        const costs = [[6, id, n]];
        if (item.is_use === 1 && item.use_effect?.length === 2) {
            const partnerId = item.use_effect[1], partner = config('item')[partnerId];
            if (!partner || partner.is_use !== 1 || partner.use_effect?.[0] !== item.use_effect[0] || partner.use_effect?.[1] !== id || partnerId === id)
                fail('Cặp rương/chìa khóa chưa khớp cấu hình nguồn.');
            if (Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, partnerId)?.quantity ?? 0) < n)
                fail('Không đủ ' + partner.name + ' để mở; chưa tiêu vật phẩm.');
            costs.push([6, partnerId, n]);
        }
        if (Object.hasOwn(inventoryBags, id)) {
            this.cost(s, [[6, id, n]]);
            return { reward: [], effect: [], capacity: expandInventory(this.db, s.user_id, id, n, item) };
        }
        if (item?.is_use === 19) {
            const exp = item.use_effect?.[0];
            if (item.use_effect.length !== 1 || !Number.isSafeInteger(exp) || exp < 1)
                fail('Thiếu giá trị EXP vật phẩm.');
            this.cost(s, [[6, id, n]]);
            const profile = this.profile(s), next = Number(profile.exp_ball ?? 0) + exp * n;
            if (!Number.isSafeInteger(next) || next < 0)
                fail('EXP dự trữ vượt giới hạn an toàn.');
            profile.exp_ball = next;
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), s.user_id);
            return { reward: [], effect: [], exp_ball_added: exp * n, notice: 'Đã thêm EXP vào bóng truyền thừa, chưa cộng vào tướng.' };
        }
        const v = this.voucher(id), rewards = [];
        for (let g = 0; g < v.pools.length; g++) {
            const pool = v.pools[g];
            let chosen;
            if (v.isUse === 15)
                chosen = p.getAll(g === 0 ? 'type_list' : 'type_list_' + g).map(i => integer(i, 1, pool.reward.length));
            else if (pool.num === pool.reward.length)
                chosen = pool.reward.map((_, i) => i + 1);
            else {
                const counts = new Map();
                for (let opened = 0; opened < n; opened++) {
                    let pick = this.random(pool.reward.reduce((sum, r) => sum + r[3], 0)), index = 0;
                    for (; index < pool.reward.length - 1; index++) {
                        pick -= pool.reward[index][3];
                        if (pick < 0)
                            break;
                    }
                    counts.set(index, (counts.get(index) ?? 0) + 1);
                }
                for (const [index, count] of counts) {
                    const [t, cid, q] = pool.reward[index];
                    rewards.push([t, cid, q * count]);
                }
                continue;
            }
            if (chosen.length !== pool.num || new Set(chosen).size !== chosen.length)
                fail('Chọn đúng số phần thưởng riêng biệt theo phiếu.');
            for (const index of chosen) {
                const [t, cid, q] = pool.reward[index - 1];
                rewards.push([t, cid, q * n]);
            }
        }
        this.cost(s, costs);
        new WelfareService(this.db).applyInTransaction(s, rewards, { heroes: config('character_detail'), items: config('item'), equipment: config('equip') });
        return { effect: rewards, reward: rewards };
    }
    bind(s, p) {
        const { item, cfg } = this.equipment(s, p.get('equip_id')), heroId = p.get('card_id'), heroRow = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, heroId ?? '');
        if (!heroRow)
            fail('Tướng không thuộc tài khoản.');
        if (item.bind_card)
            fail('Trang bị đã khóa Vận Mệnh.');
        if (!Object.values(config('equip_fate')).some((r) => r.equip_quality === cfg.quality))
            fail('Phẩm chất trang bị không hỗ trợ Vận Mệnh.');
        const form = JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(s.user_id).formation)), index = form.alignment.flat().indexOf(heroId);
        if (index < 0 || form.equip_pos[String(index)]?.[cfg.sort - 1] !== item.id)
            fail('Phải trang bị đúng món này cho tướng trước khi khóa.');
        const hero = heroBindingClientState(JSON.parse(String(heroRow.state)));
        hero.bind_equip ??= Array(4).fill(0);
        if (String(hero.bind_equip[cfg.sort - 1] ?? '0') !== '0')
            fail('Tướng đã có trang bị ràng buộc ở ô này.');
        this.cost(s, [[41, 0, config('equip_fate')['1'].cost]]);
        item.bind_card = heroId;
        item.bind_data = Object.fromEntries([1, 2, 3, 4, 5].map(i => [String(i), 0]));
        item.gem_fate = [0, 0, 0, 0];
        hero.bind_equip[cfg.sort - 1] = item.id;
        this.saveEquipment(s, item);
        this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(hero), s.user_id, heroId);
        return { reward: [] };
    }
    unbind(s, p) {
        const { item, cfg } = this.equipment(s, p.get('equip_id'));
        if (!item.bind_card)
            fail('Trang bị chưa khóa Vận Mệnh.');
        const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, item.bind_card);
        if (!row)
            fail('Liên kết tướng bị thiếu.');
        const h = JSON.parse(String(row.state));
        if (String(h.bind_equip?.[cfg.sort - 1]) !== item.id)
            fail('Liên kết trang bị/tướng không đồng bộ.');
        for (const cid of item.gem_fate ?? [])
            if (cid && !(typeof cid === 'string' && cid.includes('-')))
                this.gemDelta(s, Number(cid), 1);
        h.bind_equip[cfg.sort - 1] = 0;
        item.bind_card = '';
        item.bind_data = {};
        item.gem_fate = [0, 0, 0, 0];
        this.saveEquipment(s, item);
        this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(h), s.user_id, h.id);
        return { reward: [], notice: 'Đã mở ràng buộc; trả đá gắn, không hoàn nguyên liệu đã nâng. Adapter local không thu thêm phí mở khóa chưa xác minh.' };
    }
    upgrade(s, p) {
        const { item, cfg } = this.equipment(s, p.get('equip_id')), sort = integer(p.get('sort'), 1, 3);
        if (!item.bind_card || !item.bind_data)
            fail('Phải khóa Vận Mệnh trước.');
        const tiers = Object.values(config('equip_fate')).filter(r => r.equip_quality === cfg.quality).sort((a, b) => a.id - b.id), delta = {}, ranges = {};
        let cost = 0, changed = false;
        if (!tiers.length)
            fail('Chưa có bảng Vận Mệnh cho phẩm chất này.');
        for (const n of [1, 2]) {
            const field = String(cfg['ability' + n]), current = Number(item.bind_data[field] ?? 0), cap = tiers.at(-1)['refresh_range' + n];
            if (current >= cap) {
                delta[field] = 0;
                ranges[field] = [0, 0];
                continue;
            }
            const tier = tiers.find(t => current <= t['refresh_range' + n]), pool = tier['refresh_equip_fate' + n]?.[sort - 1];
            if (!Array.isArray(pool) || !pool.length)
                fail('Thiếu pool tăng Vận Mệnh.');
            const total = pool.reduce((sum, r) => sum + r[2], 0);
            let pick = this.random(total), chosen = pool[0];
            for (const r of pool) {
                pick -= r[2];
                if (pick < 0) {
                    chosen = r;
                    break;
                }
            }
            const lo = Math.round(chosen[0] * 100), hi = Math.round(chosen[1] * 100);
            if (!Number.isSafeInteger(lo) || hi < lo)
                fail('Khoảng tăng Vận Mệnh không hợp lệ.');
            const next = Math.min(cap, Math.max(0, Math.round((current + (lo + this.random(hi - lo + 1)) / 100) * 100) / 100));
            delta[field] = Math.round((next - current) * 100) / 100;
            item.bind_data[field] = next;
            ranges[field] = tier.refresh_equip_fate_range[sort - 1];
            cost += tier.refresh[sort - 1];
            changed = true;
        }
        if (!changed)
            fail('Vận Mệnh đã đạt giới hạn config.');
        this.cost(s, [[[41, 42, 43][sort - 1], 0, cost]]);
        this.saveEquipment(s, item);
        return { bind_data_temp: delta, fate_range: ranges, leveup_times: 1, reward: [], scope: 'LOCAL TEST IMPLEMENTATION: trọng số/khoảng nguồn; lấy mẫu bước0,01%, không khẳng định RNG production.' };
    }
    upgradeTen(s, p) {
        // Lua tag102 gọi auto_fate_equip_levelup, áp dụng ngay, không gửi khóa dòng/chọn kết quả.
        // Mỗi lượt dùng lại ngưỡng và chi phí hiện tại; toàn bộ batch nằm trong receipt transaction.
        const { item, cfg } = this.equipment(s, p.get('equip_id')), before = { ...item.bind_data }, sort = integer(p.get('sort'), 1, 3), profile = this.profile(s), field = ['min_fate_stone', 'mid_fate_stone', 'max_fate_stone'][sort - 1];
        let times = 0, last = {};
        for (let i = 0; i < 10; i++) {
            const current = this.equipment(s, item.id).item, tiers = Object.values(config('equip_fate')).filter(r => r.equip_quality === cfg.quality).sort((a, b) => a.id - b.id);
            if (!current.bind_card || !tiers.length)
                fail('Phải khóa trang bị có cấu hình Vận Mệnh trước.');
            if ([1, 2].every(n => Number(current.bind_data[String(cfg['ability' + n])] ?? 0) >= tiers.at(-1)['refresh_range' + n]))
                break;
            last = this.upgrade(s, p);
            times++;
        }
        if (!times)
            fail('Vận Mệnh đã đạt giới hạn config.');
        const after = this.equipment(s, item.id).item.bind_data;
        return { ...last, leveup_times: times, bind_data_temp: Object.fromEntries(Object.keys(after).map(k => [k, Math.round((after[k] - (before[k] ?? 0)) * 100) / 100])), consumed: { type: [41, 42, 43][sort - 1], quantity: (profile[field] ?? 0) - (this.profile(s)[field] ?? 0) }, notice: 'Tạo mới tối đa 10 lượt liên tiếp; áp dụng ngay theo giao diện gốc, không phải tăng 10 cấp. Thiếu nguyên liệu: hoàn tác toàn bộ batch.' };
    }
    synthesize(s, p) {
        const id = integer(p.get('gem_id'), 1, 999999), n = integer(p.get('gem_num')), cfg = config('equip_gem_fate')[id], old = config('equip_gem_fate')[cfg?.need_gem];
        if (!cfg || !old || cfg.team !== old.team || cfg.quality !== old.quality + 1 || !Number.isSafeInteger(cfg.gem_num) || cfg.gem_num < 1)
            fail('Không có công thức ghép đá hợp lệ.');
        this.gemDelta(s, cfg.need_gem, -cfg.gem_num * n);
        this.cost(s, [...cfg.iron, ...cfg.need_item].map(([t, i, q]) => [t, i, q * n]));
        this.gemDelta(s, id, n);
        return { reward: [[50, id, n]] };
    }
    socket(s, p) {
        const { item, cfg } = this.equipment(s, p.get('major'));
        if (!item.bind_card)
            fail('Phải khóa Vận Mệnh trước khi gắn đá.');
        const text = p.get('gem_fates') ?? '';
        const tokens = text.split('_');
        if (tokens.length !== 4 || tokens.some(v => !/^\d+(?:-[a-f0-9-]+)?$/.test(v)))
            fail('Cần đúng bốn ô đá Vận Mệnh.');
        const next = tokens.map(v => v.includes('-') ? v : Number(v)), old = item.gem_fate ?? [0, 0, 0, 0], net = {}, special = new Set();
        for (let i = 0; i < 4; i++) {
            const id = next[i], gem = fateGemDefinition(id);
            if (id && (!gem || gem.team !== (i === 0 ? cfg.sort : 5)))
                fail('Loại đá không phù hợp ô: ô1 theo trang bị, ô2–4 HP.');
            if (typeof id === 'string') {
                if (special.has(id))
                    fail('Không thể gắn cùng một viên đá hai lần.');
                special.add(id);
                if (!this.db.prepare('SELECT 1 FROM player_fate_special WHERE user_id=? AND id=?').get(s.user_id, id))
                    fail('Đá Ban Sức không thuộc tài khoản.');
                if (this.db.prepare("SELECT 1 FROM player_equipment e,json_each(e.state,'$.gem_fate') g WHERE e.user_id=? AND e.id<>? AND CAST(g.value AS TEXT)=?").get(s.user_id, item.id, id))
                    fail('Đá Ban Sức đang gắn ở trang bị khác.');
            }
            else if (id)
                net[id] = (net[id] ?? 0) - 1;
            if (old[i] && !(typeof old[i] === 'string' && old[i].includes('-')))
                net[old[i]] = (net[old[i]] ?? 0) + 1;
        }
        for (const [cid, n] of Object.entries(net))
            this.gemDelta(s, Number(cid), Number(n));
        item.gem_fate = next;
        this.saveEquipment(s, item);
        return { reward: [], equip_info: item };
    }
}
