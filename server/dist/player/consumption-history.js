import { createHash } from 'node:crypto';
import { readConfigSync as cfg } from './local-content.js';
export const progressFields = ['lv', 'exp', 'evo', 'step', 'bre', 'super_step', 'super_quality_1', 'super_soul', 'element_break', 'hp_crystal', 'patk_crystal', 'matk_crystal', 'def_crystal', 'speed_crystal'];
const signature = (h) => Object.fromEntries(progressFields.filter(k => !['lv', 'exp'].includes(k)).map(k => [k, h[k] ?? (k === 'super_soul' ? [] : 0)]));
export const historyHash = (value) => createHash('sha256').update(JSON.stringify(value)).digest('hex');
export function initialProgress(h) { return (h.evo ?? 0) === 0 && (h.bre ?? 0) === 0 && !(h.super_step ?? 0) && !h.element_break && ['hp', 'patk', 'matk', 'def', 'speed'].every(f => !h[f + '_crystal']) && !h._local_transformation; }
export function recordConsumption(before, after, method, costs) {
    const prior = before._local_consumption_history;
    const continuous = prior?.version === 1 && prior.signature === historyHash(signature(before));
    const history = continuous ? structuredClone(prior) : { version: 1, complete: initialProgress(before), baseline: signature(before), entries: [] };
    history.entries.push({ method, costs, at: Date.now() });
    history.signature = historyHash(signature(after));
    return { ...after, _local_consumption_history: history };
}
export function historyOf(h) { const p = h._local_consumption_history; return p?.version === 1 && p.signature === historyHash(signature(h)) ? p : null; }
export function sourceResetRules() { const text = cfg('notice_active')[133]?.word ?? ''; if (!text.includes('không trả về tài nguyên chuyển sinh') || !text.includes('lịch sử tiến hóa'))
    throw Error('Quy tắc Tái Sinh nguồn đã đổi.'); return { source: 'notice_active[133] / ui_chongsheng_scene.step>=4', sha256: historyHash(text), text }; }
