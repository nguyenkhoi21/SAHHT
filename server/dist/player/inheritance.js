import { aetherEntityInUse } from './aether-lock.js';
import { readConfigSync as cfg } from './local-content.js';
import { progressionBasis } from './natural-progression.js';
import { recordConsumption, historyOf } from './consumption-history.js';
import { historyHash } from './consumption-history.js';
import { ProgressionEconomyService, heroStoredExp, heroExpThreshold, economyConfig } from './progression-economy.js';
const fields = ['patk', 'matk', 'def', 'speed', 'hp'];
const fail = (m) => { throw Object.assign(Error(m), { statusCode: 422 }); };
export function progressionChange(h, patch) { const before = progressionBasis(h), next = { ...h, ...patch }, after = progressionBasis(next); for (const f of fields) {
    next[f] = h[f] + after[f] - before[f];
    if (!Number.isFinite(next[f]) || next[f] <= 0)
        fail('Thuộc tính sau Kế Thừa không hợp lệ.');
} return next; }
function rootSkill(id) { const defs = cfg('skill_detail'), seen = new Set(); let current = id; while (current && defs[current] && !seen.has(current)) {
    seen.add(current);
    const parents = Object.entries(defs).filter(([, v]) => Number(v.is_evolution) === current).map(([k]) => Number(k));
    if (!parents.length)
        return current;
    if (parents.length !== 1)
        return id;
    current = parents[0];
} return id; }
function skillEntries(h) { const bank = h._local_skill_bank ? structuredClone(h._local_skill_bank) : [1, 2, 3].map(n => ({ ...h['s_' + n] })); return { bank, all: [...bank, h.s_4 ? { ...h.s_4 } : null, h.s_5 ? { ...h.s_5 } : null] }; }
function saveSkills(h, bank, super4, super5) { if (h._local_skill_bank) {
    h._local_skill_bank = bank;
    (h._local_skill_selection ?? [1, 2, 3]).forEach((n, i) => h['s_' + (i + 1)] = { ...bank[n - 1] });
}
else
    bank.forEach((v, i) => h['s_' + (i + 1)] = v); if (super4)
    h.s_4 = super4; if (super5)
    h.s_5 = super5; return h; }
export function inheritedProgress(source, target) {
    const reform = Object.fromEntries(fields.map(f => [f + '_crystal', Math.max(source[f + '_crystal'] ?? 0, target[f + '_crystal'] ?? 0)])), zero = Object.fromEntries(fields.map(f => [f + '_crystal', 0]));
    let receiver = progressionChange(target, reform), donor = progressionChange(source, { lv: 1, exp: 0, bre: 0, ...zero });
    const ss = skillEntries(source), ts = skillEntries(target), transfers = [];
    for (const t of ts.all) {
        if (!t?.s || t.avail !== 2)
            continue;
        const cap = cfg('skill_detail')[t.s]?.max_lv;
        if (!Number.isSafeInteger(cap))
            fail('Thiếu giới hạn skill đích.');
        const matches = ss.all.filter(s => s?.s && s.avail === 2 && rootSkill(Number(s.s)) === rootSkill(Number(t.s)));
        const best = matches.sort((a, b) => b.lv - a.lv || Number(b.exp ?? 0) - Number(a.exp ?? 0))[0];
        if (best && (best.lv > t.lv || best.lv === t.lv && (best.exp ?? 0) > (t.exp ?? 0))) {
            const before = { ...t };
            t.lv = Math.min(cap, best.lv);
            t.exp = t.lv === cap ? 0 : Number(best.exp ?? 0);
            transfers.push({ sourceSkillId: best.s, targetSkillId: t.s, before, after: { ...t }, compatibility: 'skill_detail.is_evolution hoặc cùng ID' });
        }
    }
    for (const s of ss.all)
        if (s) {
            s.lv = 1;
            s.exp = 0;
        }
    receiver = saveSkills(receiver, ts.bank, ts.all[ts.bank.length], ts.all[ts.bank.length + 1]);
    donor = saveSkills(donor, ss.bank, ss.all[ss.bank.length], ss.all[ss.bank.length + 1]);
    // Kế Thừa chuyển mức, không tạo ledger giả cho nguyên liệu chưa từng trả ở đích.
    if (Object.keys(reform).some(k => reform[k] !== target[k]))
        delete receiver._local_consumption_history;
    const history = historyOf(source);
    if (history) {
        donor = recordConsumption(source, donor, 'cards.inherit.reset', []);
        donor._local_consumption_history.entries = donor._local_consumption_history.entries.filter((e) => !['cards.card_break', 'laboratory.level_up'].includes(e.method));
    }
    return { receiver, donor, transfers, reform, policy: 'Giữ mức cao hơn; xác nhận người dùng27/10/2026. Giữ tiến hóa/siêu tiến hóa/quyền mua skill; donor Lv1, bre0, Cải Tạo0, cấp skill1.' };
}
export function rebirthRefund(db, userId, h) {
    if (!h.bre)
        return { rewards: [], evidence: 'Không có Chuyển Sinh.' };
    if (db.prepare('SELECT 1 FROM player_hero_qa_backup WHERE user_id=? AND id=?').get(userId, h.id))
        fail('Tướng có snapshot MAX/QA; không hoàn nguyên liệu Chuyển Sinh đã được cấp miễn phí.');
    const history = historyOf(h), entries = history?.entries.filter((e) => e.method === 'cards.card_break') ?? [];
    if (entries.length === h.bre)
        return { rewards: entries.flatMap((e) => e.costs.flatMap((c) => c.rewards)), evidence: 'Ledger tiêu hao thật, hoàn riêng theo Kế Thừa đã được người dùng xác nhận.' };
    // Chỉ tái dựng bảng chi phí khi ledger giao dịch tự nhiên đã ghi đủ từng cấp.
    const rows = db.prepare("SELECT result FROM player_content_operations WHERE user_id=? AND method='cards.card_break'").all(userId), levels = new Set(rows.map(r => JSON.parse(String(r.result))).filter(r => r.hero_id === h.id).map(r => r.progression?.bre));
    if (db.prepare('SELECT 1 FROM player_hero_qa_backup WHERE user_id=? AND id=?').get(userId, h.id) || Array.from({ length: h.bre }, (_, i) => i + 1).some(l => !levels.has(l)))
        fail('Thiếu lịch sử Chuyển Sinh tự nhiên để hoàn nguyên liệu; không hoàn tài nguyên của preset QA hoặc đoán chi phí.');
    const table = economyConfig('character_break_new')[h.c_id], rewards = Array.from({ length: h.bre }, (_, i) => table?.['material' + (i + 1)]).flat();
    if (!rewards.every(r => Array.isArray(r) && r.length === 3))
        fail('Thiếu bảng hoàn nguyên liệu Chuyển Sinh.');
    return { rewards, evidence: 'Tái dựng theo đủ receipt Chuyển Sinh tự nhiên + character_break_new; không suy từ bre đơn lẻ.' };
}
export function assertDonorAvailable(db, userId, h) { if (aetherEntityInUse(db, userId, h.id))
    fail('Tướng đang thuộc đội Aether, chưa được kế thừa.'); const row = db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(userId), contains = (v) => v === h.id || !!(v && typeof v === 'object' && Object.entries(v).some(([k, x]) => k === h.id || contains(x))); if (h.lv <= 1 || h.lock || h.remove_avail?.length || contains(JSON.parse(String(row.formation))) || h.bind_equip?.some((v) => v && String(v) !== '0') || db.prepare("SELECT 1 FROM player_equipment WHERE user_id=? AND json_extract(state,'$.bind_card')=?").get(userId, h.id))
    fail('Tướng cho phải trênLv1, đã tháo khỏi đội/ô phụ, không khóa hoặc ràng buộc Vận Mệnh.'); }
export function inheritancePreview(db, userId, sourceId, targetId, useOrb) {
    const core = new ProgressionEconomyService(db), s = { user_id: userId }, target = core.hero(s, targetId), source = sourceId ? core.hero(s, sourceId) : null, p = core.profile(s);
    if (source?.id === target.id)
        fail('Tướng cho và nhận phải khác nhau.');
    if (source)
        assertDonorAvailable(db, userId, source);
    const change = source ? inheritedProgress(source, target) : null, refund = source ? rebirthRefund(db, userId, source) : { rewards: [], evidence: 'Không có tướng cho.' }, cap = Math.min(255, (p.level ?? 1) + 5, cfg('character_detail')[target.c_id].level_max > 1 ? cfg('character_detail')[target.c_id].level_max : 255), factor = (p.vip ?? 0) >= 1 ? 1 : .7, sourceExp = source ? Math.floor(heroStoredExp(source) * factor) : 0, orbFactor = source ? 1 : factor;
    let need = -Number(target.exp ?? 0);
    for (let lv = target.lv; lv < cap; lv++)
        need += heroExpThreshold(target, lv);
    need = Math.max(0, need);
    const fromSource = Math.min(need, sourceExp), fromOrb = useOrb ? Math.min(p.exp_ball ?? 0, Math.ceil(Math.max(0, need - fromSource) / orbFactor)) : 0;
    let lv = target.lv, exp = (target.exp ?? 0) + fromSource + Math.floor(fromOrb * orbFactor);
    while (lv < cap && exp >= heroExpThreshold(target, lv)) {
        exp -= heroExpThreshold(target, lv);
        lv++;
    }
    const result = progressionChange(change?.receiver ?? target, { lv }), ticket = source && Number(db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=24').get(userId)?.quantity ?? 0) > 0;
    return { sourceId, targetId, sourceProgress: source ? { lv: source.lv, bre: source.bre, reform: Object.fromEntries(fields.map(f => [f, source[f + '_crystal'] ?? 0])) } : null, targetLevel: lv, targetExp: lv === cap ? 0 : exp, targetAttributes: Object.fromEntries(fields.map(f => [f, result[f]])), reform: change?.reform ?? {}, skills: change?.transfers ?? [], donorReset: source ? { level: 1, rebirth: 0, reform: 0, skillLevel: 1, evolution: source.evo, superEvolution: source.super_step ?? 0 } : null, refund, cost: ticket ? [[6, 24, 1]] : [[9, 0, cfg('pay')[15].coin[0]]], orbConsumed: fromOrb, orbAfter: (p.exp_ball ?? 0) - fromOrb + Math.max(0, sourceExp - fromSource), fingerprint: historyHash({ source, target, orb: p.exp_ball ?? 0, level: p.level, vip: p.vip ?? 0, useOrb }), policy: change?.policy ?? 'EXP bóng theo tỷ lệVIP gốc; không có tướng cho thì không truyền Cải Tạo/skill.' };
}
