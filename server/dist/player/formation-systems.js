import { readStaticConfigSync as cfg } from './local-content.js';
import { progressionBasis } from './natural-progression.js';
import { audit } from '../admin/admin.audit.js';
import { contentReceipt } from './content-receipt.js';
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
export const slotSystems = { assistant: { table: 'assistant', name: 'Trợ Uy' }, destiny: { table: 'destiny', name: 'Vận Mệnh' }, formation_bonus: { table: 'formation_bonus', name: 'Trận Pháp' } };
export function assistantEffectWire(form) { return Array.from({ length: 9 }, (_, i) => form.assistant_effect?.[i] ?? { active_status: '-1', ass_random_id: 0, two_switch: 0, two_value: 0, limit_character_id: 0 }); }
export function slotState(form) { return Object.fromEntries(Object.keys(slotSystems).map(k => [k, Array.from({ length: Object.keys(cfg(slotSystems[k].table)).length }, (_, i) => String(form[k]?.[i] ?? '-1'))])); }
export function validateExtraAssignments(db, userId, form) {
    const fields = [...(form.alignment ?? []).flat(), ...Object.values(slotState(form)).flat(), ...Object.values(form.formation_bonus_addition ?? {}).flat()].map(String).filter(v => !['0', '-1'].includes(v));
    if (new Set(fields).size !== fields.length)
        fail('Một tướng không thể đồng thời dùng ở nhiều ô chiến đấu/Trợ Uy/Vận Mệnh/Trận Pháp.');
    for (const id of fields)
        if (!db.prepare('SELECT 1 FROM player_heroes WHERE user_id=? AND id=?').get(userId, id))
            fail('Tướng trong ô phụ không thuộc tài khoản.');
}
export class FormationSystemsService {
    db;
    constructor(db) {
        this.db = db;
    }
    row(id) { const row = this.db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(id); if (!row)
        fail('Chưa có hồ sơ.'); return { profile: JSON.parse(String(row.profile)), form: JSON.parse(String(row.formation)) }; }
    save(id, form) { this.db.prepare('UPDATE player_state SET formation=? WHERE user_id=?').run(JSON.stringify(form), id); }
    diagnostics(id) { const { profile, form } = this.row(id), state = slotState(form); return { systems: Object.entries(slotSystems).map(([key, s]) => ({ key, name: s.name, qa: !!form._local_slot_qa?.[key], slots: Object.entries(cfg(s.table)).map(([sid, c]) => ({ index: Number(sid) - 1, configId: Number(sid), state: state[key][Number(sid) - 1], unlocked: state[key][Number(sid) - 1] !== '-1', requirement: { level: c.limit_lv ?? c.actlv ?? 1, currency: c.sort === 1 ? 'dirt_silver' : 'dirt_gold', quantity: c.price }, levelEligible: (profile.level ?? 1) >= (c.limit_lv ?? c.actlv ?? 1), config: c })) })), notice: 'Ô gốc9mỗi hệ. -1 khóa /0 trống. Trợ Uy kích hoạt thuộc tính riêng bằng nguyên liệu; Trận Pháp dùng tối đa8thẻ phụ từ danh sách nguồn. Không tự gắn tướng.' }; }
    qa(adminId, id, systems, restore = false) {
        if (!systems.length || new Set(systems).size !== systems.length || systems.some(s => !slotSystems[s]))
            fail('Hệ ô QA không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const { form } = this.row(id), before = structuredClone(form), state = slotState(form);
            form._local_slot_qa ??= {};
            for (const system of systems) {
                const snapshot = form._local_slot_qa[system];
                if (restore) {
                    if (system === 'formation_bonus' && Object.values(form.formation_bonus_addition ?? {}).flat().some(v => !['0', 0, '-1'].includes(v)))
                        fail('Hãy tháo thẻ phụ Trận Pháp trước khi khôi phục ô QA.');
                    if (!snapshot)
                        fail('Hệ này chưa có snapshot QA.');
                    for (let i = 0; i < snapshot.length; i++)
                        if (snapshot[i] === '-1' && state[system][i] !== '0' && state[system][i] !== '-1')
                            fail('Hãy tháo tướng khỏi ô QA trước khi khôi phục.');
                    form[system] = state[system].map((v, i) => snapshot[i] === '-1' ? '-1' : v);
                    delete form._local_slot_qa[system];
                }
                else if (!snapshot) {
                    form._local_slot_qa[system] = state[system];
                    form[system] = state[system].map((v) => v === '-1' ? '0' : v);
                }
            }
            this.save(id, form);
            audit(this.db, adminId, restore ? 'formation.slots.restore' : 'formation.slots.qa', id, 'QA riêng theo ô nguồn; không xếp tướng hoặc thêm thuộc tính', before, form);
            this.db.exec('COMMIT');
            return this.diagnostics(id);
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    packet(id) { const { form } = this.row(id), state = slotState(form); return { ...state, assistant_effect: assistantEffectWire(form), formation_bonus_addition: form.formation_bonus_addition ?? {}, _client_cache_update: { cards: Object.fromEntries([...Object.entries(state), ['assistant_effect', assistantEffectWire(form)], ['formation_bonus_addition', form.formation_bonus_addition ?? {}]].map(([k, v]) => [k, { update: v }])) } }; }
    execute(id, method, p, key) {
        return contentReceipt(this.db, id, method, key, [...p].filter(([k]) => !['rans', 'mk', 'user_token', 'request_id'].includes(k)), () => {
            const { profile, form } = this.row(id);
            Object.assign(form, slotState(form));
            const system = method === 'cards.activate_assistant' ? 'assistant' : method === 'cards.activate_destiny' ? 'destiny' : 'formation_bonus';
            if (method.startsWith('cards.activate_') && method !== 'cards.activate_assistant_effect') {
                const position = p.get(system === 'formation_bonus' ? 'pos' : 'position'), n = Number(position), rule = cfg(slotSystems[system].table)[n + 1];
                if (position === null || !Number.isInteger(n) || !rule)
                    fail('Ô không có trong nguồn.');
                if (form[system][n] !== '-1')
                    fail('Ô đã mở.');
                if ((profile.level ?? 1) < (rule.limit_lv ?? rule.actlv ?? 1))
                    fail('Chưa đủ cấp mở ô.');
                for (let i = 0; i < n; i++)
                    if (cfg(slotSystems[system].table)[i + 1]?.sort === rule.sort && form[system][i] === '-1')
                        fail('Mở ô theo thứ tự cùng loại nguồn.');
                const currency = rule.sort === 1 ? 'dirt_silver' : 'dirt_gold';
                if ((profile[currency] ?? 0) < rule.price)
                    fail('Không đủ bụi mở ô.');
                profile[currency] -= rule.price;
                form[system][n] = '0';
                this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), id);
            }
            else if (method === 'cards.set_bonus_formation') {
                const values = (p.get('formation') ?? '').split('_');
                this.assign(form, 'formation_bonus', values);
                for (const [k, v] of p)
                    if (/^(bonus_equip|bonus_talisman)_/.test(k) && v.split('_').some(x => x !== '0'))
                        fail('Trang bị/Pháp Bảo ô Trận Pháp chưa có consumer server hoàn chỉnh; không lưu thiếu bonus.');
            }
            else if (method === 'cards.set_formation_bonus_addition') {
                if (!p.has('pos') || !/^\d+$/.test(p.get('pos')))
                    fail('Thiếu vị trí Trận Pháp hợp lệ.');
                const pos = Number(p.get('pos')), values = (p.get('cards') ?? '').split('_'), holder = form.formation_bonus[pos];
                if (!Number.isInteger(pos) || !holder || ['-1', '0'].includes(holder) || values.length !== 8)
                    fail('Chọn tướng chủ Trận Pháp và8ô phụ hợp lệ.');
                for (let i = 0; i < values.length; i++) {
                    const v = values[i];
                    if (v === '0')
                        continue;
                    if (i && values[i - 1] === '0')
                        fail('Thẻ Trận Pháp phải gắn liên tục theo thứ tự.');
                    const h = this.db.prepare('SELECT config_id FROM player_heroes WHERE user_id=? AND id=?').get(id, v);
                    if (!h || !cfg('formation_bonus')[i + 1]?.card.includes(Number(h.config_id)))
                        fail('Thẻ không thuộc danh sách Trận Pháp nguồn.');
                }
                form.formation_bonus_addition ??= {};
                form.formation_bonus_addition[String(pos)] = values;
            }
            else if (method === 'cards.activate_assistant_effect') {
                if (!p.has('position') || !/^\d+$/.test(p.get('position')))
                    fail('Thiếu vị trí Trợ Uy hợp lệ.');
                const pos = Number(p.get('position')), rule = cfg('assistant')[pos + 1];
                if (!rule || !form.assistant[pos] || ['-1', '0'].includes(form.assistant[pos]))
                    fail('Hãy gắn tướng Trợ Uy trước.');
                if (!this.db.prepare('SELECT 1 FROM player_heroes WHERE user_id=? AND id=?').get(id, form.assistant[pos]))
                    fail('Tướng Trợ Uy không thuộc tài khoản.');
                form.assistant_effect ??= assistantEffectWire(form);
                if (form.assistant_effect[pos]?.active_status !== '-1' && form.assistant_effect[pos]?.active_status !== undefined)
                    fail('Thuộc tính đã kích hoạt.');
                for (const [t, c, n] of rule.activation ?? []) {
                    if (t !== 6)
                        fail('Nguyên liệu kích hoạt chưa hỗ trợ.');
                    const r = this.db.prepare('UPDATE player_items SET quantity=quantity-? WHERE user_id=? AND config_id=? AND quantity>=?').run(n, id, c, n);
                    if (r.changes !== 1)
                        fail('Thiếu nguyên liệu kích hoạt Trợ Uy.');
                }
                form.assistant_effect[pos] = { active_status: '0', ass_random_id: 0, two_switch: 0, two_value: 0, limit_character_id: 0 };
            }
            else
                fail('Thao tác hệ ô chưa hỗ trợ.');
            validateExtraAssignments(this.db, id, form);
            this.save(id, form);
            audit(this.db, null, method, id, 'Thao tác hệ ô theo nguồn VN', null, { method });
            return this.packet(id);
        }, () => this.packet(id));
    }
    assign(form, system, values) { const old = slotState(form)[system]; if (values.length !== old.length)
        fail('Sai số ô ' + slotSystems[system].name); for (let i = 0; i < old.length; i++) {
        if (old[i] === '-1' && values[i] !== '-1')
            fail('Ô phụ chưa mở.');
        if (old[i] !== '-1' && values[i] === '-1')
            fail('Không thể khóa ô đã mở bằng lưu đội hình.');
    } form[system] = values; }
}
// Phạm vi không trang bị/Pháp Bảo phụ: lấy stat progression đã lưu, không lấy
// canonical của tướng chính để tránh vòng lặp/cộng lại đồ và Skin.
export function formationBonuses(db, id, form, heroes) {
    const fields = ['patk', 'matk', 'def', 'speed', 'hp'], bonus = Object.fromEntries(fields.map(f => [f, 0])), byPosition = {}, details = [], layout = cfg('formation')[form.formation?.current ?? 1], positions = new Set();
    let mainIndex = 0;
    for (let i = 0; i < 6; i++)
        if (layout?.['position_' + String.fromCharCode(97 + i)] !== 0) {
            if (!['-1', '0', undefined].includes(form.alignment?.[0]?.[mainIndex++]))
                positions.add(i);
        }
    for (let i = 0; i < 3; i++)
        if (!['-1', '0', undefined].includes(form.alignment?.[1]?.[i]))
            positions.add(i + 6);
    const teamIds = [...(form.alignment ?? []).flat(), ...(form.assistant ?? []), ...(form.destiny ?? []), ...(form.formation_bonus ?? [])];
    const chainPercent = (hero, field) => { const defs = cfg('character_detail'), identities = new Set(teamIds.filter(v => heroes[v]).map(v => defs[heroes[v].c_id]?.character_ID)); let percent = 0; for (const cid of defs[hero.c_id]?.chain ?? []) {
        const c = cfg('chain')[cid];
        if (Number(c?.condition_sort) === 0 && c.data.every((n) => identities.has(defs[n]?.character_ID)))
            for (const [t, p] of c.effect)
                if (fields[t] === field)
                    percent += p * .001;
    } return percent; };
    for (let i = 0; i < 9; i++) {
        const h = heroes[form.assistant?.[i]], effect = form.assistant_effect?.[i], r = cfg('assistant')[i + 1];
        if (h && r && effect && effect.active_status !== '-1' && Number(effect.ass_random_id ?? 0) === 0 && Number(effect.two_switch ?? 0) === 0 && Number(effect.limit_character_id ?? 0) === 0) {
            const field = fields[r.att_type - 1], capped = (h.evo ?? 0) > r.cardlimit ? progressionBasis({ ...h, evo: r.cardlimit })[field] + Number(h._local_transformation?.inherited?.[field] ?? 0) : h[field], value = capped * (1 + chainPercent(h, field)) * r.att_value / 100;
            bonus[field] += value;
            details.push({ system: 'assistant', slot: i, hero: h.id, field, value });
        }
        const owner = heroes[form.formation_bonus?.[i]], cards = form.formation_bonus_addition?.[String(i)] ?? [];
        if (owner && positions.has(i)) {
            let percent = 0;
            for (let j = 0; j < Math.min(8, cards.length); j++) {
                const h = heroes[cards[j]], r = cfg('formation_bonus')[j + 1];
                if (h && r?.card.includes(h.c_id))
                    percent += r.add_ability;
            }
            // getFormationBonusAllData: floor phần chain trước, cộng raw rồi floor tỷ lệ thẻ.
            byPosition[i] = Object.fromEntries(fields.map(field => [field, Math.floor((owner[field] + Math.floor(owner[field] * chainPercent(owner, field))) * percent / 100)]));
            for (const field of fields)
                bonus[field] += byPosition[i][field];
            if (percent)
                details.push({ system: 'formation_bonus', slot: i, hero: owner.id, percent });
        }
    }
    return { attributes: bonus, byPosition, details, notice: 'Trợ Uy cơ bản và Trận Pháp không trang bị phụ theo consumer VN; nâng/tẩy thuộc tính và trang bị phụ chưa hỗ trợ.' };
}
