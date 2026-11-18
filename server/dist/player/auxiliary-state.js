import { capacityFields } from './inventory-capacity.js';
import { readFileSync } from 'node:fs';
import { createHash, randomUUID } from 'node:crypto';
export const auxFail = (m) => { throw Object.assign(Error(m), { statusCode: 422 }); };
const memo = new Map();
export function auxiliaryConfig(name) {
    if (!memo.has(name)) {
        const root = new URL('../../../', import.meta.url), manifest = JSON.parse(readFileSync(new URL('tools/runtime/phase29-source.json', root), 'utf8')), entry = manifest.tables[name];
        if (!entry)
            auxFail('Thiếu bảng nguồn Pha29: ' + name);
        const raw = readFileSync(new URL(entry.path, root));
        if (createHash('sha256').update(raw).digest('hex') !== entry.sha256)
            auxFail('Hash nguồn Việt Nam thay đổi: ' + name);
        memo.set(name, JSON.parse(raw.toString()));
    }
    return memo.get(name);
}
export const auxKinds = { talisman: { type: 49, table: 'talisman', slots: 4, label: 'Pháp Bảo' }, gem: { type: 19, table: 'gem', slots: 4, label: 'Đá Quý' }, soul: { type: 36, table: 'soul_detail', slots: 6, label: 'Anh Hồn' }, god_stone: { type: 46, table: 'god_stone', slots: 5, label: 'Đá Thánh' }, medal: { type: 30, table: 'medal', slots: 6, label: 'Huy Chương' }, material: { type: 29, table: 'material', slots: 0, label: 'Nguyên liệu Huy Chương' } };
export const auxRewardKind = (type) => Object.keys(auxKinds).find(k => auxKinds[k].type === type);
export function auxiliaryCatalog() { return Object.fromEntries(Object.entries(auxKinds).map(([kind, meta]) => [kind, { ...meta, entries: Object.entries(auxiliaryConfig(meta.table)).map(([id, c]) => ({ configId: Number(id), name: c.talisman_name ?? c.name ?? c.first_name + ' ' + c.last_name, ...c, maxLevel: kind === 'talisman' ? Math.min(30, auxiliaryConfig('talisman_break')[id]?.talisman_level ?? 30) : kind === 'soul' ? c.max_level : 0, forgingPool: kind === 'talisman' && c.talisman_forging?.length ? auxiliaryConfig('talisman_forging_list') : null })) }])); }
export function auxiliaryDefinition(kind, id) { const key = kind === 'gem' ? String(id).split('-').at(-1) : String(id), d = auxiliaryConfig(auxKinds[kind]?.table)[key]; if (!d)
    auxFail('Không có định nghĩa ' + kind + ' #' + id); return d; }
export function auxInventory(db, userId) { const all = Object.fromEntries(Object.keys(auxKinds).map(k => [k, {}])); for (const r of db.prepare('SELECT kind,id,state FROM player_auxiliary WHERE user_id=?').all(userId))
    all[String(r.kind)][String(r.id)] = JSON.parse(String(r.state)); return all; }
export function auxiliaryPreset(p) {
    if (!auxKinds[p.system] || p.kind !== 'auxiliary')
        auxFail('Hệ vật phẩm không hợp lệ.');
    if (!Number.isSafeInteger(p.configId) || !Number.isSafeInteger(p.quantity) || p.quantity < 1 || p.quantity > (['talisman', 'soul'].includes(p.system) ? 5 : 1000000))
        auxFail('Số lượng hoặc ID không hợp lệ.');
    const d = auxiliaryDefinition(p.system, p.configId), level = p.level ?? 0;
    if (!Number.isSafeInteger(level) || level < 0 || level > (p.system === 'talisman' ? 30 : p.system === 'soul' ? d.max_level : 0))
        auxFail('Cấp ngoài cấu hình nguồn.');
    if (p.system === 'talisman') {
        const gate = auxiliaryConfig('talisman_break')[p.configId];
        if (gate && level > gate.talisman_level)
            auxFail('Cấp Tu Luyện vượt mốc tiến sao của Pháp Bảo này.');
        if (p.forgingId !== undefined) {
            const f = auxiliaryConfig('talisman_forging_list')[p.forgingId];
            if (!d.talisman_forging?.length || !f || !Number.isSafeInteger(p.forgingEffect) || p.forgingEffect < f.effect[0] || p.forgingEffect > f.effect[1])
                auxFail('Thuộc tính Tôi Luyện ngoài dải nguồn.');
        }
    }
    else if (p.forgingId !== undefined || p.forgingEffect !== undefined)
        auxFail('Hệ này không có thuộc tính Tôi Luyện.');
    return { kind: 'auxiliary', system: p.system, configId: p.configId, quantity: p.quantity, level, ...(p.forgingId !== undefined ? { forgingId: p.forgingId, forgingEffect: p.forgingEffect } : {}) };
}
export function auxGrant(db, userId, p) { const v = auxiliaryPreset(p), kind = v.system, ids = []; if (kind === 'soul') {
    const profile = JSON.parse(String(db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(userId).profile)), capacity = capacityFields(profile).soul_max, used = Number(db.prepare("SELECT COUNT(*) n FROM player_auxiliary WHERE user_id=? AND kind='soul'").get(userId).n);
    if (used + v.quantity > capacity)
        auxFail('Kho Anh Hồn đã đầy; hãy mở rộng túi hoặc Thôn Phệ.');
} for (let i = 0; i < (['talisman', 'soul'].includes(kind) ? v.quantity : 1); i++) {
    const id = ['talisman', 'soul'].includes(kind) ? `locala${userId}-${randomUUID().replaceAll('-', '')}` : String(v.configId), old = db.prepare('SELECT state FROM player_auxiliary WHERE user_id=? AND kind=? AND id=?').get(userId, kind, id), state = kind === 'talisman' ? { id, c_id: v.configId, lv: v.level, is_forging: v.forgingId !== undefined, forging_attr: v.forgingId !== undefined ? { forging_id: v.forgingId, effect: v.forgingEffect } : {}, bind_card: '' } : kind === 'soul' ? { id, s_id: v.configId, lv: v.level, exp: 0, pre_exp: soulPreExp(v.configId, v.level) } : { quantity: Number(old ? JSON.parse(String(old.state)).quantity : 0) + v.quantity };
    if (state.quantity > 1000000)
        auxFail('Kho vượt giới hạn.');
    db.prepare('INSERT INTO player_auxiliary VALUES(?,?,?,?,?) ON CONFLICT(user_id,kind,id) DO UPDATE SET state=excluded.state').run(userId, kind, id, v.configId, JSON.stringify(state));
    ids.push(id);
} return ids; }
export function soulPreExp(cid, lv) { const c = auxiliaryDefinition('soul', cid), rows = auxiliaryConfig('soul_exp'); let n = 0; for (let i = 1; i <= lv; i++) {
    const q = rows[i]?.['need_exp_type' + c.exp_type];
    if (!Number.isFinite(q))
        auxFail('Thiếu EXP Anh Hồn.');
    n += q;
} return n; }
export const auxPreviewRewards = (rewards) => rewards.map(r => r?.kind === 'auxiliary' ? [auxKinds[r.system].type, r.configId, r.quantity] : r);
export function auxiliaryWire(db, userId) { const all = auxInventory(db, userId), out = {}; for (const [k, rows] of Object.entries(all))
    out[k] = ['talisman', 'soul'].includes(k) ? Object.fromEntries(Object.entries(rows).map(([id, v]) => [id, Object.fromEntries(Object.entries(v).filter(([key]) => !key.startsWith('_local_')))])) : Object.fromEntries(Object.entries(rows).filter(([, v]) => v.quantity > 0).map(([id, v]) => [id, v.quantity])); return out; }
export function auxiliaryCache(db, userId) { const all = auxInventory(db, userId), wire = auxiliaryWire(db, userId), out = {}; for (const k of Object.keys(auxKinds)) {
    const name = k === 'soul' ? '_souls' : '_' + k;
    out[k] = { [name]: { update: wire[k], remove: Object.keys(all[k]).filter(id => !Object.hasOwn(wire[k], id)) } };
} return out; }
export function auxiliaryPositions(form) {
    const positions = Object.fromEntries(Object.entries(auxKinds).filter(([, v]) => v.slots).map(([kind, v]) => [kind + '_pos', Object.fromEntries(Array.from({ length: 10 }, (_, i) => [String(i), form[kind + '_pos']?.[i] ?? Array(v.slots).fill('0')]))]));
    // Lua magicInMagicPos/magicInBonus/godmagicInMagicPos luôn duyệt đủ các bảng,
    // kể cả tài khoản chưa gắn Pháp Bảo Trợ Uy/Trận Pháp/Thần Vực. Đây là
    // projection cấu trúc gốc, không mở ô hoặc ghi đè dữ liệu formation đã lưu.
    for (const [key, start] of [['ass_talisman_pos', 100], ['bonus_talisman_pos', 200], ['talisman_pos_1', 0], ['talisman_pos_2', 0], ['talisman_pos_3', 0]])
        positions[key] = Object.fromEntries(Array.from({ length: 10 }, (_, i) => [String(start + i), form[key]?.[start + i] ?? Array(4).fill('0')]));
    return positions;
}
// Đếm đồ đang gắn từ state formation, không tiêu hủy khi gắn/tháo.
export function auxEquippedCount(form, kind, id) { return Object.values(form[kind + '_pos'] ?? {}).flat().filter(x => String(x) === id).length; }
export function validateAuxiliaryFormation(db, userId, form, params) {
    const all = auxInventory(db, userId), positions = auxiliaryPositions(form);
    for (const [k, meta] of Object.entries(auxKinds)) {
        if (!meta.slots)
            continue;
        const pos = structuredClone(positions[k + '_pos']);
        for (let i = 0; i < 10; i++) {
            const key = k + '_' + (i < 5 ? '1' + (i + 1) : '2' + (i - 4));
            if (!params.has(key))
                continue;
            const values = params.getAll(key);
            if (values.length !== 1)
                auxFail('Trùng trường ' + key);
            const ids = values[0].split('_');
            if (ids.length !== meta.slots || ids.some(id => !/^([0-9]+(-[0-9]+)?|locala[0-9]+-[a-f0-9]+)$/.test(id)))
                auxFail('Sai cấu trúc ' + key);
            pos[i] = ids;
        }
        const used = {};
        for (const [i, ids] of Object.entries(pos)) {
            const categories = new Set();
            for (let n = 0; n < ids.length; n++) {
                const id = ids[n];
                if (id === '0')
                    continue;
                if (form.alignment[Number(i) < 5 ? 0 : 1][Number(i) % 5] === '-1')
                    auxFail('Ô đồ phụ cần tướng đang ra trận.');
                const state = all[k][id];
                if (!state)
                    auxFail('Không sở hữu ' + meta.label + ' #' + id);
                const d = auxiliaryDefinition(k, k === 'talisman' ? state.c_id : k === 'soul' ? state.s_id : id), category = k === 'gem' || k === 'god_stone' ? d.career : k === 'soul' ? d.sort : null;
                if (k === 'talisman' && d.talisman_type !== (n < 2 ? 1 : 0))
                    auxFail('Sai ô Pháp Bảo công/thủ.');
                if (k === 'gem' && d.career !== (n === 0 ? 1 : 2))
                    auxFail('Sai ô Đá Quý công/thủ.');
                if (k === 'talisman') {
                    if (categories.has(d.talisman_type_id))
                        auxFail('Không thể gắn hai Pháp Bảo cùng loại.');
                    categories.add(d.talisman_type_id);
                }
                if (k === 'god_stone') {
                    if (categories.has(d.team))
                        auxFail('Không thể gắn hai Đá Thánh cùng hệ.');
                    categories.add(d.team);
                }
                if (k === 'soul' && categories.has(category))
                    auxFail('Không thể gắn hai Anh Hồn cùng loại.');
                if (k === 'soul' && category !== null)
                    categories.add(category);
                used[id] = (used[id] ?? 0) + 1;
                if (used[id] > (['talisman', 'soul'].includes(k) ? 1 : state.quantity))
                    auxFail('Vật phẩm đã gắn ở ô khác hoặc thiếu số lượng.');
            }
        }
        form[k + '_pos'] = pos;
    }
    return form;
}
const flds = ['patk', 'matk', 'def', 'speed', 'hp'], element = { 201: 'fire', 202: 'water', 203: 'wind', 204: 'earth', 301: 'fire_dfs', 302: 'water_dfs', 303: 'wind_dfs', 304: 'earth_dfs' };
export function auxiliaryBonuses(all, form, slot, base) {
    const flat = Object.fromEntries(flds.map(f => [f, 0])), post = { ...flat }, percent = { ...flat }, extras = {}, effects = [], sacred = {};
    const add = (ability, value) => { if (flds[ability - 1])
        flat[flds[ability - 1]] += value;
    else if (ability > 100 && ability < 106)
        percent[flds[ability - 101]] += value;
    else if (element[ability])
        extras[element[ability]] = (extras[element[ability]] ?? 0) + value;
    else if (value)
        effects.push({ ability, value, status: 'BLOCKED_MISSING_BATTLE_HANDLER' }); };
    for (const kind of Object.keys(auxKinds)) {
        for (const id of form[kind + '_pos']?.[slot] ?? []) {
            if (id === '0')
                continue;
            const s = all[kind][id];
            if (!s)
                continue;
            const d = auxiliaryDefinition(kind, kind === 'soul' ? s.s_id : kind === 'talisman' ? s.c_id : id);
            if (kind === 'talisman') {
                for (const f of (d.talisman_type === 1 ? ['patk', 'matk'] : ['hp', 'def', 'speed']))
                    post[f] += d['base_' + f] + d['growth_' + f] * s.lv;
                effects.push({ kind, id, skill_type: d.skill_type, sprite: d.sprite_py, effect: d.effect, status: ['fb_dfs_jianshang', 'fb_hurt_addHp1'].includes(d.sprite_py) ? 'IMPLEMENTED_UNVERIFIED' : 'BLOCKED_MISSING_BATTLE_HANDLER' });
                if (s.is_forging && s.forging_attr?.forging_id) {
                    const fc = auxiliaryConfig('talisman_forging_list')[s.forging_attr.forging_id];
                    if (fc)
                        effects.push({ kind, id, skill_type: fc.skill_type, sprite: fc.sprite_py, effect: s.forging_attr.effect, forging: true, status: ['fb_dfs_jianshang', 'fb_hurt_addHp1'].includes(fc.sprite_py) ? 'IMPLEMENTED_UNVERIFIED' : 'BLOCKED_MISSING_BATTLE_HANDLER' });
                }
            }
            else if (kind === 'gem') {
                const lv = id.includes('-') ? Number(id.split('-')[0]) : 0, row = auxiliaryConfig('gem_evolution')[lv]?.ability?.find((r) => r[0] === d.ability);
                add(d.ability, d.value + (row?.[1] ?? 0));
                add(d.ability2, d.value2 + (row?.[2] ?? 0));
            }
            else if (kind === 'soul') {
                add(d.ability, Math.floor(d.value + d.level_add * s.lv));
                add(d.ability2, Math.floor(d.value2 + d.level_add2 * s.lv));
            }
            else if (kind === 'medal') {
                for (const [a, v] of d.effect)
                    add(a, v);
            }
            else if (kind === 'god_stone') {
                if (element[d.ability])
                    sacred[element[d.ability]] = (sacred[element[d.ability]] ?? 0) + d.value;
                else
                    effects.push({ kind, id, ability: d.ability, value: d.value, status: 'BLOCKED_MISSING_BATTLE_HANDLER' });
            }
        }
    }
    for (const f of flds)
        flat[f] += base[f] * percent[f] / 100;
    for (const f of Object.keys(sacred))
        extras[f] = Math.floor((extras[f] ?? 0) * (1 + sacred[f] / 100));
    return { flat, post, percent, extras, sacred, effects };
}
