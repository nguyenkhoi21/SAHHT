import { CombatPowerService } from './combat-power.js';
import { randomInt } from 'node:crypto';
import { auxiliaryConfig as cfg, auxiliaryCatalog, validateAuxiliaryFormation, auxKinds, auxiliaryDefinition, auxInventory, auxiliaryWire, auxiliaryCache, auxiliaryPositions, auxEquippedCount, auxGrant, auxFail as fail, soulPreExp } from './auxiliary-state.js';
import { readConfigSync } from './local-content.js';
import { contentReceipt } from './content-receipt.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { PlayerService } from './player.service.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
const integer = (n, min = 1, max = 1000000) => { const v = Number(n); if (!Number.isSafeInteger(v) || v < min || v > max)
    fail('Số lượng/cấp không hợp lệ.'); return v; };
export class AuxiliaryService {
    db;
    random;
    constructor(db, random = () => randomInt(0, 0x1000000) / 0x1000000) {
        this.db = db;
        this.random = random;
    }
    form(uid) { return JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(uid).formation)); }
    state(uid, kind, id) { const h = auxInventory(this.db, uid)[kind]?.[id]; if (!h)
        fail('Vật phẩm không thuộc tài khoản.'); return h; }
    save(uid, kind, id, h) { this.db.prepare('UPDATE player_auxiliary SET state=? WHERE user_id=? AND kind=? AND id=?').run(JSON.stringify(h), uid, kind, id); }
    count(uid, kind, id) { return Number(auxInventory(this.db, uid)[kind]?.[id]?.quantity ?? 0); }
    consume(uid, kind, id, n) { integer(n); const own = this.count(uid, kind, id), free = own - auxEquippedCount(this.form(uid), kind, id); if (n > free)
        fail('Thiếu vật phẩm chưa gắn: ' + kind + ' #' + id); this.save(uid, kind, id, { quantity: own - n }); }
    cost(uid, rows) { return new ProgressionEconomyService(this.db).cost({ user_id: uid }, rows); }
    grant(uid, kind, cid, n, level = 0) { return auxGrant(this.db, uid, { kind: 'auxiliary', system: kind, configId: cid, quantity: n, level }); }
    sample(max) { const r = this.random(); if (!Number.isFinite(r) || r < 0 || r >= 1 || !Number.isSafeInteger(max) || max < 1)
        fail('RNG ngoài giới hạn.'); return Math.floor(r * max); }
    forging(uid, method, p) {
        const id = p.get('talisman_id') ?? '', h = this.state(uid, 'talisman', id), d = auxiliaryDefinition('talisman', h.c_id), pool = cfg('talisman_forging_list');
        if (!d.talisman_forging?.length)
            fail('Pháp Bảo chưa đạt phẩm chất hỗ trợ Tôi Luyện.');
        if (method === 'talisman.talisman_skill_save') {
            const n = integer(p.get('num'), 1, 5), pending = h._local_forging_pending;
            if (!pending?.[n - 1])
                fail('Không có kết quả Tôi Luyện đang chờ.');
            h.forging_attr = pending[n - 1];
            h.is_forging = true;
            delete h._local_forging_pending;
            this.save(uid, 'talisman', id, h);
            return { reward: [], forging_attr: h.forging_attr };
        }
        const effectOnly = method === 'talisman.talisman_forging_effect', five = integer(p.get('five_times') ?? 0, 0, 1) === 1;
        if (effectOnly && !h.is_forging)
            fail('Cần Tôi Luyện skill trước khi Tôi Luyện hiệu quả.');
        const rows = effectOnly ? (five ? d.talisman_forging3 : d.talisman_forging2) : (five ? d.talisman_forging1 : d.talisman_forging);
        if (!Array.isArray(rows) || !rows.length)
            fail('Thiếu chi phí Tôi Luyện.');
        const candidates = Object.entries(pool).filter(([, v]) => v.rate > 0), sum = candidates.reduce((n, [, v]) => n + v.rate, 0), list = [];
        for (let i = 0; i < (five ? 5 : 1); i++) {
            let fid = Number(h.forging_attr?.forging_id);
            if (!effectOnly) {
                let x = this.sample(sum);
                fid = Number(candidates.find(([, v]) => { x -= v.rate; return x < 0; })?.[0]);
            }
            const row = pool[fid];
            if (!row || !Array.isArray(row.effect) || row.effect.length !== 2)
                fail('Thiếu dải Tôi Luyện.');
            list.push({ forging_id: fid, effect: row.effect[0] + this.sample(row.effect[1] - row.effect[0] + 1) });
        }
        this.cost(uid, rows);
        if (five)
            h._local_forging_pending = list;
        else {
            h.forging_attr = list[0];
            h.is_forging = true;
            delete h._local_forging_pending;
        }
        this.save(uid, 'talisman', id, h);
        return { reward: [], list_forging: list, rngPolicy: 'LOCAL_RANGE_UNIFORM · người dùng đồng ý28/10/2026; họ/trọng số/dải lấy nguồn Việt Nam, không tuyên bố phân bố trị số của server gốc.' };
    }
    soulIncrease(uid) { const core = new ProgressionEconomyService(this.db), s = { user_id: uid }, p = core.profile(s), times = p._local_soul_times ?? 0, cost = readConfigSync('pay')[40]?.coin; if (!Array.isArray(cost) || !cost.length)
        fail('Thiếu phí đồng bộ tím pay40.'); this.cost(uid, [[9, 0, cost[Math.min(times, cost.length - 1)]]]); const after = core.profile(s); after._local_soul_rate = 4; after._local_soul_times = times + 1; core.saveProfile(s, after); return { reward: [], ...this.soulIndex(uid) }; }
    medalExchange(uid, p) { const target = integer(p.get('exchange_id')), source = integer(p.get('material_id')), n = integer(p.get('num') ?? 1, 1, 1000), mode = integer(p.get('sort'), 1, 2), d = auxiliaryDefinition('material', target), m = auxiliaryDefinition('material', source); if (d.price !== m.price || d.material.length || !Number.isSafeInteger(d.exchange_coin) || d.exchange_coin <= 0)
        fail('Chỉ đổi nguyên liệu thô đồng giá theo bảng gốc.'); if (mode !== 2)
        fail('Đổi thường thiếu bảng exchange_rate server gốc; chưa tiêu nguyên liệu. Hãy chọn Đổi Xu100%.'); this.consume(uid, 'material', String(source), n); this.cost(uid, [[9, 0, d.exchange_coin * n]]); this.grant(uid, 'material', target, n); return { reward: [[29, target, n]], exchange_result: true }; }
    saveSacred(uid, p) { const form = this.form(uid); for (let i = 0; i < 2; i++)
        if (p.get('align_' + (i + 1)) !== form.alignment[i].join('_'))
            fail('Đội hình đã đổi; mở lại Đá Thánh trước khi lưu.'); return contentReceipt(this.db, uid, 'god_stone.set_alignment', p.get('request_id'), Object.fromEntries(p), () => { validateAuxiliaryFormation(this.db, uid, form, p); this.db.prepare('UPDATE player_state SET formation=? WHERE user_id=?').run(JSON.stringify(form), uid); audit(this.db, null, 'god_stone.set_alignment', uid, 'Lưu ô Đá Thánh, giữ tướng và trang bị', null, form.god_stone_pos); return { god_stone_pos: form.god_stone_pos }; }, () => ({ god_stone_pos: this.form(uid).god_stone_pos, replayed: true })); }
    packet(uid, r) { const s = { user_id: uid }, wire = auxiliaryWire(this.db, uid), cache = auxiliaryCache(this.db, uid); for (const [k, ids] of Object.entries(r.removedAuxiliary ?? {})) {
        const entry = cache[k][k === 'soul' ? '_souls' : '_' + k];
        entry.remove = [...new Set([...entry.remove, ...ids])].filter(id => !Object.hasOwn(entry.update, id));
    } return { ...wire, ...auxiliaryPositions(this.form(uid)), ...this.soulIndex(uid), ...this.medalIndex(uid), ...r, _client_cache_update: { ...cache, ...(r._client_cache_update ?? {}), item: { items: { update: Object.fromEntries(this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=? AND quantity>0').all(uid).map(v => [String(v.config_id), [v.quantity]])), remove: this.db.prepare('SELECT config_id FROM player_items WHERE user_id=? AND quantity=0').all(uid).map(v => String(v.config_id)) } }, cards: { cards: { update: new PlayerService(this.db).cards(s, true).cards, remove: [] } } } }; }
    soulIndex(uid) { const p = new ProgressionEconomyService(this.db).profile({ user_id: uid }); return { soul_rate: p._local_soul_rate ?? 1, soul_times: p._local_soul_times ?? 0, statue: 1, soul_book: [...new Set(Object.values(auxInventory(this.db, uid).soul).map((v) => v.s_id))], all_soul: auxiliaryWire(this.db, uid).soul }; }
    medalIndex(uid) { const wire = auxiliaryWire(this.db, uid); return { medal: wire.medal, _medal: wire.medal, material: wire.material, train: Object.fromEntries(Array.from({ length: 4 }, (_, i) => [i + 1, { material_id: '' }])), pos_count_down: { 1: 0, 2: 0, 3: 0, 4: 0 }, free_times: 0, quick_train_times: 0, max_quick_train_times: 0, first_player: {}, first_receive_uids: {} }; }
    index(uid) { return this.packet(uid, { reward: [] }); }
    execute(uid, method, p) { if (['soul.soul_index', 'soul.all_soul', 'soul.soul_book', 'medal.index'].includes(method))
        return this.index(uid); const body = Object.fromEntries([...p].filter(([k]) => !['user_token', 'account', 'server', 'rans', 'mk', 'method', 'request_id'].includes(k))); const result = contentReceipt(this.db, uid, method, p.get('request_id'), [body, [...p].filter(([k]) => ['metal', 'element_id'].includes(k))], () => { const before = auxInventory(this.db, uid); let r = {}; if (['talisman.talisman_forging', 'talisman.talisman_forging_effect', 'talisman.talisman_skill_save'].includes(method))
        r = this.forging(uid, method, p);
    else if (method === 'soul.increase_rate')
        r = this.soulIncrease(uid);
    else if (method === 'talisman.sell')
        r = this.sellTalismans(uid, p);
    else if (method === 'talisman.level_up_talisman' || method === 'talisman.talisman_break')
        r = this.talisman(uid, method, p);
    else if (method === 'gem.synthesis' || method === 'god_stone.synthesis')
        r = this.synthesis(uid, method.startsWith('gem.') ? 'gem' : 'god_stone', p);
    else if (method === 'gem.evolution')
        r = this.gemEvolution(uid, p);
    else if (method === 'soul.eat_soul' || method === 'soul.sell_soul')
        r = this.soulConsume(uid, method, p);
    else if (method === 'soul.soul_gacha' || method === 'soul.soul_gacha10')
        r = this.soulGacha(uid, method === 'soul.soul_gacha10' ? 10 : 1);
    else if (method === 'medal.exchange_material')
        r = this.medalExchange(uid, p);
    else if (method === 'medal.synthesis_material' || method === 'medal.synthesis_medal')
        r = this.medalCraft(uid, method, p);
    else
        fail('Chưa đủ quy tắc nguồn cho thao tác này; chưa tiêu tài nguyên.'); audit(this.db, null, method, uid, 'Pha29: giao dịch nguyên tử theo bảng Việt Nam', null, r); const after = auxInventory(this.db, uid); r.removedAuxiliary = Object.fromEntries(Object.keys(auxKinds).map(k => [k, Object.keys(before[k]).filter(id => !after[k][id])])); return r; }, old => ({ ...old, reward: method === 'soul.soul_gacha' || method === 'soul.soul_gacha10' ? old.reward : [], replayed: true })); return this.packet(uid, result); }
    sellTalismans(uid, p) { const ids = p.has('talismans') ? p.getAll('talismans') : [p.get('talisman_id') ?? '']; if (!ids.length || ids.length > 50 || new Set(ids).size !== ids.length)
        fail('Chọn1–50 Pháp Bảo khác nhau.'); let total = 0; for (const id of ids) {
        const h = this.state(uid, 'talisman', id), d = auxiliaryDefinition('talisman', h.c_id);
        if (h.lv || h.is_forging || auxEquippedCount(this.form(uid), 'talisman', id))
            fail('Chỉ bán Pháp Bảo chưa nâng, chưa Tôi Luyện và chưa gắn.');
        total += integer(d.sell_metal);
    } for (const id of ids)
        this.db.prepare('DELETE FROM player_auxiliary WHERE user_id=? AND kind=? AND id=?').run(uid, 'talisman', id); return { ...new WelfareService(this.db).applyInTransaction({ user_id: uid }, [[6, 264, total]], { heroes: readConfigSync('character_detail'), items: readConfigSync('item') }), sell_metal: total }; }
    talisman(uid, method, p) {
        const id = p.get('talisman_id') ?? '', h = this.state(uid, 'talisman', id), d = auxiliaryDefinition('talisman', h.c_id), gate = cfg('talisman_break')[h.c_id];
        if (method === 'talisman.level_up_talisman') {
            const row = cfg('talisman_level')[h.lv + 1];
            if (!row || h.lv >= 30)
                fail('Tu Luyện đã đạt giới hạn nguồn30.');
            if (gate && h.lv >= gate.talisman_level)
                fail('Cần tiến sao trước khi tiếp tục Tu Luyện.');
            const cost = structuredClone(row.exp);
            if (cost.length !== 1 || cost[0][0] !== 6 || cost[0][1] !== 265)
                fail('Bảng Tu Luyện khác schema đã xác minh.');
            const available = Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=265').get(uid)?.quantity ?? 0), need = cost[0][2], use = Math.min(available, need);
            if (use < need && p.get('is_buy') !== '1')
                fail('Thiếu TH-Đá Lò; xác nhận mua phần thiếu bằng Xu.');
            this.cost(uid, [...(use ? [[6, 265, use]] : []), ...(use < need ? [[9, 0, (need - use) * row.exp_price]] : [])]);
            h.lv++;
            this.save(uid, 'talisman', id, h);
            return { reward: [], talisman_id: id, level: h.lv };
        }
        if (method === 'talisman.talisman_break') {
            if (!gate || h.lv !== gate.talisman_level || !d.talisman_break)
                fail('Chưa đúng mốc tiến sao.');
            const cost = [...(gate.talisman_material_1 ?? []), ...(gate.talisman_material_2 ?? []), ...(gate.talisman_material_3 ?? [])];
            for (const [t, c, n] of cost) {
                if (t === 49) {
                    const mid = p.get('tali_material') ?? '', m = this.state(uid, 'talisman', mid);
                    if (n !== 1 || mid === id || m.c_id !== c || m.lv !== 0 || auxEquippedCount(this.form(uid), 'talisman', mid))
                        fail('Pháp Bảo nguyên liệu phải đúng loại, chưa nâng và chưa gắn.');
                    this.db.prepare('DELETE FROM player_auxiliary WHERE user_id=? AND kind=? AND id=?').run(uid, 'talisman', mid);
                }
                else
                    this.cost(uid, [[t, c, n]]);
            }
            h.c_id = d.talisman_break;
            this.db.prepare('UPDATE player_auxiliary SET config_id=?,state=? WHERE user_id=? AND kind=? AND id=?').run(h.c_id, JSON.stringify(h), uid, 'talisman', id);
            return { reward: [], talisman_id: id };
        }
        if (h.lv || auxEquippedCount(this.form(uid), 'talisman', id))
            fail('Chỉ bán Pháp Bảo chưa nâng và chưa gắn để tránh mất tài nguyên.');
        this.db.prepare('DELETE FROM player_auxiliary WHERE user_id=? AND kind=? AND id=?').run(uid, 'talisman', id);
        const delivery = new WelfareService(this.db).applyInTransaction({ user_id: uid }, [[6, 264, d.sell_metal]], { heroes: readConfigSync('character_detail'), items: readConfigSync('item') });
        return delivery;
    }
    synthesis(uid, kind, p) { const cid = integer(p.get('gem_id') ?? p.get('god_stone_id')), n = integer(p.get('gem_num') ?? p.get('god_stone_num') ?? p.get('num') ?? 1, 1, 1000), d = auxiliaryDefinition(kind, cid); if (!d.need_gem || !d.gem_num)
        fail('Không có công thức ghép cho cấp đầu.'); this.consume(uid, kind, String(d.need_gem), d.gem_num * n); this.cost(uid, [[2, 0, d.iron * n], ...d.need_item.map(([t, i, q]) => [t, i, q * n])]); this.grant(uid, kind, cid, n); return { reward: [[auxKinds[kind].type, cid, n]] }; }
    gemEvolution(uid, p) { const id = p.get('gem_id') ?? '', parts = id.split('-'), oldLv = parts.length === 2 ? integer(parts[0], 0, 10) : 0, cid = integer(parts.at(-1)), d = auxiliaryDefinition('gem', cid), row = cfg('gem_evolution')[oldLv + 1]; if (!row || oldLv >= d.evo_max)
        fail('Đá Quý đã đạt giới hạn Tiến Cấp.'); const superEvo = integer(p.get('super_evo') ?? 0, 0, 1); if (superEvo)
        fail('Chưa có bảng xác suất/giá siêu tiến cấp đầy đủ; chưa tiêu tài nguyên.'); const x = this.random(); if (!Number.isFinite(x) || x < 0 || x >= 1)
        fail('RNG ngoài giới hạn.'); this.consume(uid, 'gem', id, 1); this.cost(uid, [[2, 0, row.metal], ...row.gem_material]); const success = x * 100 < row.rate, next = success ? oldLv + 1 : row.false_back; const nextId = next ? next + '-' + cid : String(cid); const old = this.count(uid, 'gem', nextId); this.db.prepare('INSERT INTO player_auxiliary VALUES(?,?,?,?,?) ON CONFLICT(user_id,kind,id) DO UPDATE SET state=excluded.state').run(uid, 'gem', nextId, cid, JSON.stringify({ quantity: old + 1 })); return { reward: [[19, nextId, 1]], success, got_gem: nextId, gem_id: nextId }; }
    soulConsume(uid, method, p) {
        const ids = p.getAll('metal');
        if (!ids.length || ids.length > 50 || new Set(ids).size !== ids.length)
            fail('Chọn1–50 Anh Hồn khác nhau.');
        const target = method === 'soul.eat_soul' ? this.state(uid, 'soul', p.get('major') ?? '') : null, d = target ? auxiliaryDefinition('soul', target.s_id) : null;
        let gain = 0, food = 0;
        for (const id of ids) {
            if (id === target?.id || auxEquippedCount(this.form(uid), 'soul', id))
                fail('Không dùng Anh Hồn đang gắn hoặc chính nó làm nguyên liệu.');
            const h = this.state(uid, 'soul', id), c = auxiliaryDefinition('soul', h.s_id);
            gain += c.exp + soulPreExp(h.s_id, h.lv) + (h.exp ?? 0);
            food += c.sell_food;
        }
        if (target) {
            if (target.lv >= d.max_level)
                fail('Anh Hồn đã đạt cấp tối đa.');
            let exp = target.exp + gain;
            while (target.lv < d.max_level) {
                const need = cfg('soul_exp')[target.lv + 1]?.['need_exp_type' + d.exp_type];
                if (!need)
                    fail('Thiếu bảng EXP Anh Hồn.');
                if (exp < need)
                    break;
                exp -= need;
                target.lv++;
            }
            if (target.lv === d.max_level && exp > 0)
                fail('EXP vượt trần; chọn ít nguyên liệu hơn để tránh mất EXP.');
            target.exp = exp;
            target.pre_exp = soulPreExp(target.s_id, target.lv);
            this.save(uid, 'soul', target.id, target);
        }
        for (const id of ids)
            this.db.prepare('DELETE FROM player_auxiliary WHERE user_id=? AND kind=? AND id=?').run(uid, 'soul', id);
        if (!target)
            return { ...new WelfareService(this.db).applyInTransaction({ user_id: uid }, [[1, 0, food]], { heroes: readConfigSync('character_detail'), items: readConfigSync('item') }), food };
        return { reward: [], soul_id: target.id, exp_added: gain };
    }
    soulGacha(uid, n) { const core = new ProgressionEconomyService(this.db), s = { user_id: uid }, reward = [], ids = []; let rate = core.profile(s)._local_soul_rate ?? 1; for (let i = 0; i < n; i++) {
        const row = cfg('soul_gacha')['10' + rate];
        if (!row || row.add_rate + row.back_rate !== 100)
            fail('Thiếu quy tắc Chiêu Hồn.');
        this.cost(uid, [[1, 0, row.need_meet]]);
        const total = row.soul_box.reduce((v, r) => v + r[3], 0);
        let draw = this.random() * total;
        const chosen = row.soul_box.find((r) => { draw -= r[3]; return draw < 0; });
        if (!chosen)
            fail('RNG không hợp lệ.');
        ids.push(...this.grant(uid, 'soul', chosen[1], chosen[2]));
        reward.push(chosen.slice(0, 3));
        rate = this.random() * 100 < row.add_rate ? Math.min(5, rate + 1) : 1;
    } const profile = core.profile(s); profile._local_soul_rate = rate; core.saveProfile(s, profile); return { reward: { soul: ids }, reward_tuples: reward, ...this.soulIndex(uid) }; }
    medalCraft(uid, method, p) { const kind = method === 'medal.synthesis_medal' ? 'medal' : 'material', cid = integer(p.get(kind === 'medal' ? 'medal_id' : 'material_id')), n = integer(p.get('num') ?? 1, 1, 1000), d = auxiliaryDefinition(kind, cid); if (!d.material?.length)
        fail('Nguyên liệu này không có công thức ghép.'); for (const id of d.material)
        this.consume(uid, 'material', String(id), n); this.grant(uid, kind, cid, n); return { reward: [[auxKinds[kind].type, cid, n]], ...this.medalIndex(uid) }; }
    diagnostics(uid) { const all = auxInventory(this.db, uid), items = readConfigSync('item'); return { catalog: auxiliaryCatalog(), combat: new CombatPowerService(this.db).calculate(uid), owned: all, positions: auxiliaryPositions(this.form(uid)), materials: Object.entries(items).filter(([, v]) => /Pháp Bảo|Đá Lò|Anh Hồn|Đá Thánh|Huy Chương|Đá Quý/.test(v.name)).map(([id, v]) => ({ configId: Number(id), ...v })), history: this.db.prepare("SELECT method,request_key,created_at,result FROM player_content_operations WHERE user_id=? AND (method LIKE 'talisman.%' OR method LIKE 'gem.%' OR method LIKE 'soul.%' OR method LIKE 'medal.%' OR method LIKE 'god_stone.%') ORDER BY created_at DESC LIMIT 30").all(uid), blockers: ['Tôi Luyện dùng LOCAL_RANGE_UNIFORM theo chấp thuận người dùng; không tuyên bố phân bố trị số server gốc.', 'Người dùng xác nhận ghép Huy Chương nhận ngay; huấn luyện nguyên liệu riêng chưa có thời gian/phí đủ nguồn.', 'Sát thương nguyên tố chưa có công thức server nguồn; Đá Thánh601/701 là loot, chưa có công thức phân bổ. Giảm thương/hút HP Pháp Bảo đã nối; các họ special còn lại có chẩn đoán riêng.', 'Người dùng xác nhận hai vật liệu là TH-Đá Lò265 và TH-Pháp Bảo264; không tạo thêm ID.'] }; }
}
