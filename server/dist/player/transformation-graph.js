import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { readConfigSync } from './local-content.js';
export const inheritedFields = ['patk', 'matk', 'def', 'speed', 'hp'];
const raw = readFileSync(new URL('../../../work/runtime-content/configs/afterlife.json', import.meta.url));
export const transformationSource = JSON.parse(raw.toString('utf8'));
export const transformationSourceHash = createHash('sha256').update(raw).digest('hex');
const pin = JSON.parse(readFileSync(new URL('../../../tools/runtime/phase23-source.json', import.meta.url), 'utf8'));
if (pin.files['work/runtime-content/configs/afterlife.json'] !== transformationSourceHash)
    throw new Error('Nguồn Chuyển Thế đã đổi; cần xác minh lại.');
// Không suy công thức từ tên/ID. Mô tả khác schema đã biết phải được xác minh lại.
export function inheritanceRule(description) {
    const match = description?.match(/Thuộc tính cơ bản của thẻ mới\s*\+\s*(\d+(?:[.,]\d+)?)% thuộc tính của thẻ cũ/);
    if (!match || !description.includes('Lv1') || !description.includes('còn 0'))
        return null;
    const coefficient = Number(match[1].replace(',', '.')) / 100;
    if (!Number.isFinite(coefficient) || coefficient <= 0 || coefficient > 1)
        return null;
    return { coefficient, fields: [...inheritedFields], scope: 'PRE_EQUIPMENT_PROGRESSION', rounding: 'PRESERVE_FRACTION', reset: { level: 1, evolution: 0, rebirth: 0, superStep: 0 }, evidence: description.trim(), roundingNotice: 'Nguồn không chỉ rõ làm tròn; LOCAL giữ phần lẻ ở stat thô, canonical làm tròn ở bước vốn có.' };
}
export function parseTransformationGraph(source) {
    const edges = Object.entries(source).flatMap(([id, c]) => (c.afterlife_id ?? []).map((targetId) => {
        if (!Number.isSafeInteger(Number(id)) || !Number.isSafeInteger(targetId) || targetId === Number(id))
            throw new Error('Quan hệ Chuyển Thế không hợp lệ.');
        return { sourceId: Number(id), targetId, minimumEvolution: Number(c.limit_evo), minimumRebirth: 7, requiredTaskStep: 3, energy: Number(c.afterlife_point), cost: c.afterlife_material, inheritance: inheritanceRule(c.des2), missions: [c.mission1, c.mission2, c.mission3], sourceHash: transformationSourceHash };
    }));
    if (new Set(edges.map(e => e.sourceId + ':' + e.targetId)).size !== edges.length)
        throw new Error('Quan hệ Chuyển Thế bị trùng.');
    const outgoing = new Map();
    for (const e of edges)
        outgoing.set(e.sourceId, [...(outgoing.get(e.sourceId) ?? []), e]);
    const visit = (id, path) => { if (path.has(id))
        throw new Error('Đồ thị Chuyển Thế có chu trình.'); for (const e of outgoing.get(id) ?? [])
        visit(e.targetId, new Set([...path, id])); };
    for (const id of outgoing.keys())
        visit(id, new Set());
    return edges;
}
export const transformationGraph = parseTransformationGraph(transformationSource);
const incoming = new Map();
for (const e of transformationGraph)
    incoming.set(e.targetId, [...(incoming.get(e.targetId) ?? []), e]);
const skinIds = new Set(Object.keys(readConfigSync('character_skin')).map(Number));
const gacha = readConfigSync('gacha');
export function transformationClass(configId) {
    if (skinIds.has(configId))
        return { kind: 'SKIN_ONLY', sources: [], targets: [], standaloneEvidence: [] };
    const sources = (incoming.get(configId) ?? []).map(e => e.sourceId), targets = transformationGraph.filter(e => e.sourceId === configId).map(e => e.targetId);
    // good_item của gacha dùng [ID,loại,số lượng/trọng số]; loại5 là thẻ tướng.
    const standaloneEvidence = Object.entries(gacha).filter(([, r]) => (r.good_item ?? []).some((x) => x[0] === configId && x[1] === 5)).map(([id]) => 'gacha.good_item:' + id);
    return { kind: sources.length ? (standaloneEvidence.length ? 'STANDALONE_TRANSFORMATION' : 'TRANSFORMATION_TARGET') : 'NORMAL_HERO', sources, targets, standaloneEvidence };
}
export function transformationProvenance(hero) {
    const parents = incoming.get(Number(hero.c_id)) ?? [], saved = hero._local_transformation;
    if (!parents.length)
        return { status: 'NOT_TRANSFORMED', sourceIds: [], effect: null };
    const edge = parents.find(e => e.sourceId === saved?.sourceId);
    const verified = !!edge && !!saved.inherited && inheritedFields.every(f => Number.isFinite(saved.inherited[f]) && saved.inherited[f] >= 0);
    return { status: verified ? 'SNAPSHOT_VERIFIED' : 'SOURCE_MISSING', sourceIds: parents.map(e => e.sourceId), sourceId: verified ? saved.sourceId : null, targetId: Number(hero.c_id), effect: 'anim_zhuanshi', needsQaResolution: !verified, notice: verified ? 'Có số kế thừa lưu cùng instance.' : 'Hình thái đích đã xác minh, thiếu snapshot tướng nguồn; giữ nguyên stat/progression, không tự dựng kế thừa.' };
}
// Projection chỉ cho wire/UI; không ghi is_world vào instance nhập cũ hoặc đổi stat.
export function transformationClientState(hero) {
    const metadata = transformationProvenance(hero);
    return metadata.effect ? { ...hero, is_world: true, client_transformation: metadata } : hero;
}
export function inheritedAttributes(source, rule) {
    return Object.fromEntries(rule.fields.map(f => {
        if (!Number.isFinite(source[f]) || source[f] <= 0)
            throw Object.assign(new Error('Chỉ số nguồn không hợp lệ.'), { statusCode: 422 });
        return [f, source[f] * rule.coefficient];
    }));
}
