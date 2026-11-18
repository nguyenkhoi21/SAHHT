import { superSkillProjection } from './battle-skill-registry.js';
import { recordConsumption } from './consumption-history.js';
import { economyConfig as cfg, economyFail as fail, ProgressionEconomyService } from './progression-economy.js';
const attrs = ['patk', 'matk', 'def', 'speed', 'hp'];
function evolution(h) { const c = cfg('character_detail')[h.c_id]; return cfg(c.evo_kind < 3 ? 'evolution' : c.evo_kind === 3 ? 'evolution_3' : c.evo_kind === 4 ? 'evolution_4' : 'evolution_5'); }
// game_util.getAssistantCardAttrValue: nền tiến trình, chưa trang bị/Skin.
// Dùng hiệu hai cấu hình để giữ nguyên provenance, Đột Phá và bonus đang lưu.
export function progressionBasis(h) {
    const c = cfg('character_detail')[h.c_id], e = evolution(h)[h.evo ?? 0], bre = cfg('break_control')[h.bre ?? 0], superCfg = cfg('super_evolution')[c.super_evo], add = Object.fromEntries(attrs.map(f => [f, 0]));
    const apply = (values) => { for (const [t, n] of values) {
        if (t >= 1 && t <= 5)
            add[attrs[t - 1]] += n;
        else if (t !== 501)
            fail('Bonus siêu tiến hóa chưa hỗ trợ #' + t);
    } };
    for (let lv = 1; lv <= (h.super_step ?? 0); lv++)
        apply(superCfg['level_' + lv + '_add']);
    if (superCfg)
        for (let stage = 1; stage <= (h.super_step ?? 0) + 1; stage++) {
            const needs = superCfg['level_' + stage + '_need'] ?? [];
            for (let i = 0; i < needs.length; i++)
                if (stage <= (h.super_step ?? 0) || h.super_soul?.[i] === 1) {
                    const team = cfg('super_evo_team')[needs[i]];
                    if (!team)
                        fail('Thiếu cấu hình đúc hồn #' + needs[i]);
                    apply(team.ability_add);
                }
        }
    return Object.fromEntries(attrs.map((f, i) => [f, (c['base_' + f] + Math.floor(e['type' + c.race][i]) + add[f] + c['growth_' + f] * (h.lv - 1)) * (1 + e.all + (f === 'hp' ? (bre?.hp_add ?? 0) : 0)) + Math.floor(cfg('character_strengthen')[h[f + '_crystal'] ?? 0]?.['add_' + f] ?? 0)]));
}
function change(h, patch) { const before = progressionBasis(h), next = { ...h, ...patch }, after = progressionBasis(next); for (const f of attrs) {
    next[f] += after[f] - before[f];
    if (!Number.isFinite(next[f]) || next[f] <= 0)
        fail('Chỉ số sau nâng cấp không hợp lệ.');
} return next; }
export class NaturalProgressionService {
    db;
    core;
    constructor(db) {
        this.db = db;
        this.core = new ProgressionEconomyService(db);
    }
    consume(s, ids, major) { const p = new URLSearchParams(); const rewards = []; for (const id of ids) {
        p.append('card', id);
        rewards.push([5, this.core.hero(s, id).c_id, 1]);
    } return this.core.cost(s, rewards, p, major); }
    execute(s, method, p) {
        return this.core.execute(s, method, p, () => {
            const h = this.core.hero(s, p.get(method === 'cards.card_break' ? 'card_id' : 'major')), c = cfg('character_detail')[h.c_id];
            let next = h, removed = [];
            if (method === 'cards.card_break') {
                const table = cfg('character_break_new')[h.c_id], lv = (h.bre ?? 0) + 1, rule = cfg('break_control')[lv];
                if (!table || lv > table.high_break || !rule)
                    fail('Chuyển Sinh đã đạt giới hạn hoặc thiếu bảng.');
                if (h.lv < rule.need_level)
                    fail('Chưa đủ cấp Chuyển Sinh.');
                const cost = table['material' + lv];
                if (!Array.isArray(cost) || !cost.length)
                    fail('Thiếu nguyên liệu Chuyển Sinh đã xác minh.');
                removed = this.core.cost(s, cost, this.core.selectMaterials(s, cost, h.id), h.id);
                next = change(h, { bre: lv });
            }
            else if (method === 'cards.card_evolution') {
                const table = evolution(h), row = table[(h.evo ?? 0) + 1], profile = this.core.profile(s);
                if (!row || !c.is_evo)
                    fail('Tiến hóa đã đạt giới hạn nguồn.');
                if (h.lv < row.need_level || profile.level < row.player_level)
                    fail('Chưa đủ cấp tiến hóa.');
                if (row.level_off)
                    fail('Nhánh tiến hóa hạ cấp chưa xác minh chi tiết; chưa tiêu tài nguyên.');
                const ids = p.getAll('metal'), count = Math.min(Math.floor(row.exp / 10), 6);
                if (ids.length !== count || new Set(ids).size !== count)
                    fail('Chọn đúng ' + count + ' thẻ tiến hóa khác nhau.');
                for (const id of ids) {
                    const m = this.core.hero(s, id), d = cfg('character_detail')[m.c_id], step = h.step ?? h.evo ?? 0;
                    const compatible = step < 23 ? (m.c_id === h.c_id || (c.quality <= 3 && (String(d.character_ID) === '1001' || String(d.character_ID) === '1000' && step < 4)) || (c.quality === 4 && String(d.character_ID) === (step < 4 ? '1001' : '1002')) || (step >= 7 && step < 14 && String(d.character_ID) === String(c.character_ID) && d.quality >= c.quality)) : step < 30 ? (m.c_id === h.c_id || String(d.character_ID) === '1003' && c.quality >= 4) : String(d.character_ID) === (step < 40 ? '1003' : step < 50 ? '1004' : '1005') && c.quality >= 4;
                    if (!compatible)
                        fail('Thẻ nguyên liệu không phù hợp giai đoạn tiến hóa.');
                }
                next = change(h, { evo: h.evo + 1, step: row.step });
                // Chuỗi skill mới được kiểm toàn bộ trước khi tiêu thẻ, không gán kỹ năng khác.
                const bank = h._local_skill_bank ? structuredClone(h._local_skill_bank) : [h.s_1, h.s_2, h.s_3].map(v => ({ ...v }));
                for (let slot = 0; slot < 3; slot++) {
                    let sid = Number(c['skill_' + (slot + 1) + '_source']?.[0]?.[0] ?? 0);
                    for (let d = 1; d < row.skill[slot]; d++) {
                        sid = Number(cfg('skill_detail')[sid]?.is_evolution);
                        if (!sid || !cfg('skill_detail')[sid])
                            fail('Thiếu chuỗi kỹ năng tiến hóa.');
                    }
                    if (sid) {
                        const skill = cfg('skill_detail')[sid];
                        if (!skill)
                            fail('Thiếu kỹ năng #' + sid);
                        bank[slot] = { ...bank[slot], s: sid, lv: Math.min(bank[slot]?.lv ?? 1, skill.max_lv), avail: row.skill[slot] > 0 ? 2 : 0 };
                    }
                }
                if (h._local_skill_bank) {
                    next._local_skill_bank = bank;
                    (h._local_skill_selection ?? [1, 2, 3]).forEach((n, i) => next['s_' + (i + 1)] = { ...bank[n - 1] });
                }
                else
                    bank.forEach((v, i) => next['s_' + (i + 1)] = v);
                removed = this.consume(s, ids, h.id);
                this.core.cost(s, [[1, 0, c.evo_food]]);
            }
            else if (method === 'cards.make_soul' || method === 'cards.super_evolution') {
                const table = cfg('super_evolution')[c.super_evo], stage = (h.super_step ?? 0) + 1, needs = table?.['level_' + stage + '_need'];
                if (!needs?.length)
                    fail('Siêu tiến hóa đạt giới hạn hoặc thiếu bảng.');
                const ids = (p.get('metal') ?? '').split('_');
                if (ids.length !== 4)
                    fail('Cần đúng bốn ô đúc hồn.');
                const soul = Array.from({ length: 4 }, (_, i) => h.super_soul?.[i] ?? 0), used = [];
                for (let i = 0; i < 4; i++) {
                    if (ids[i] === '-3')
                        continue;
                    if (soul[i] === 1 || used.includes(ids[i]))
                        fail('Ô đúc hồn đã dùng hoặc thẻ trùng.');
                    const m = this.core.hero(s, ids[i]), d = cfg('character_detail')[m.c_id], need = cfg('super_evo_team')[needs[i]]?.card_need;
                    const valid = need === -1 ? m.c_id === h.c_id && !(m.super_step ?? 0) : need === -2 ? m.c_id === h.c_id && (m.super_step ?? 0) === (h.super_step ?? 0) : m.c_id === need;
                    if (!valid)
                        fail('Sai thẻ đúc hồn ô' + (i + 1));
                    used.push(ids[i]);
                    soul[i] = 1;
                }
                if (method === 'cards.super_evolution' && soul.filter(v => v === 1).length !== 4)
                    fail('Chưa đủ bốn ô đúc hồn.');
                if (method === 'cards.make_soul' && !used.length)
                    fail('Chưa chọn thẻ đúc hồn.');
                removed = this.consume(s, used, h.id);
                next = change(h, method === 'cards.super_evolution' ? { super_step: stage, super_quality_1: stage, super_soul: [] } : { super_soul: soul });
                if (method === 'cards.super_evolution')
                    for (const [t, n] of table['level_' + stage + '_add'])
                        if (t === 501)
                            next.fire_dfs = Number(next.fire_dfs ?? 0) + n;
                if (method === 'cards.super_evolution')
                    Object.assign(next, superSkillProjection(next, c));
            }
            else
                fail('Thao tác nâng cấp tự nhiên chưa hỗ trợ.');
            next = recordConsumption(h, next, method, this.core.costs);
            this.core.save(s, next);
            return { reward: [], removed, hero_id: h.id, progression: { lv: next.lv, evo: next.evo, bre: next.bre, super_step: next.super_step ?? 0 }, scope: 'Nâng từng bước qua API game; không gọi preset MAX QA. Công thức nền theo consumer Lua.' };
        });
    }
}
