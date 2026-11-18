import { createHash } from 'node:crypto';
import { readConfigSync as cfg } from './local-content.js';
import { createBaseHero } from './definitions.js';
import { qaHeroPlan } from './qa-hero.js';
import { transformationGraph, transformationSourceHash, inheritedAttributes, inheritedFields } from './transformation-graph.js';
import { heroResources } from './hero-index.js';
import { canonicalHeroPower } from './combat-power.js';
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
const hash = (v) => createHash('sha256').update(JSON.stringify(v)).digest('hex');
export async function transformedMailPreset(targetId, sourceId) {
    const edge = transformationGraph.find(e => e.sourceId === sourceId && e.targetId === targetId);
    if (!edge?.inheritance)
        fail('Thiếu quan hệ/công thức kế thừa nguồn hợp lệ.');
    if (transformationGraph.some(e => e.targetId === sourceId))
        fail('Nguồn cũng là dạng Chuyển Thế: cần chọn toàn chuỗi nguồn, chưa có preset an toàn.');
    if ((await heroResources()).get(targetId)?.assetStatus !== 'FULL ASSETS')
        fail('Hình thái đích thiếu tài nguyên model/portrait.');
    const source = createBaseHero('qa-source-preview', sourceId, cfg('character_detail')[sourceId]), plan = await qaHeroPlan(source, 250), base = createBaseHero('qa-target-preview', targetId, cfg('character_detail')[targetId]);
    if (plan.state.evo < edge.minimumEvolution || plan.state.bre < edge.minimumRebirth)
        fail('MAX được hỗ trợ của nguồn chưa đạt điều kiện Chuyển Thế.');
    const inherited = inheritedAttributes(plan.state, edge.inheritance), baseline = { level: plan.state.lv, evolution: plan.state.evo, rebirth: plan.state.bre, superEvolution: plan.state.super_step, reform: Object.fromEntries(inheritedFields.map(f => [f, plan.state[f + '_crystal']])), stats: Object.fromEntries(inheritedFields.map(f => [f, plan.state[f]])) };
    const state = { ...base, is_world: true, _local_transformation: { sourceId, targetId, inherited, coefficient: edge.inheritance.coefficient, scope: 'PRE_EQUIPMENT_PROGRESSION', sourceHash: transformationSourceHash, sourceStats: baseline.stats, policy: 'QA_SYNTHETIC_MAX_SOURCE', baseline } };
    for (const f of inheritedFields)
        state[f] += inherited[f];
    const prepared = { state, baseline, sourceHash: transformationSourceHash };
    return { kind: 'transformed_hero', configId: targetId, sourceId, quantity: 1, prepared: { ...prepared, digest: hash(prepared) }, preview: { sourceName: cfg('character_detail')[sourceId].name, targetName: cfg('character_detail')[targetId].name, baseline, inherited, targetStats: Object.fromEntries(inheritedFields.map(f => [f, state[f]])), unmodifiedPower: canonicalHeroPower(state, state, cfg('character_detail')[targetId]).power, targetProgression: { level: 1, evolution: 0, rebirth: 0, superEvolution: 0 }, notice: 'QA riêng: tính nguồn MAX từ planner đã xác minh; tướng đích Lv1/+0 theo luật Chuyển Thế. Không cấp trang bị, Skin hoặc tự mở kỹ năng của tiến trình đích.' } };
}
export function storedTransformedHero(reward, id) {
    const p = reward.prepared, edge = transformationGraph.find(e => e.sourceId === reward.sourceId && e.targetId === reward.configId);
    if (!p || !edge?.inheritance || p.sourceHash !== transformationSourceHash || p.digest !== hash({ state: p.state, baseline: p.baseline, sourceHash: p.sourceHash }))
        fail('Preset kế thừa trong thư không còn khớp nguồn.');
    const h = structuredClone(p.state), base = createBaseHero(id, reward.configId, cfg('character_detail')[reward.configId]);
    if (h.c_id !== reward.configId || h.lv !== 1 || h.evo !== 0 || h.bre !== 0 || h._local_transformation?.sourceId !== reward.sourceId)
        fail('Metadata preset Chuyển Thế không hợp lệ.');
    for (const f of inheritedFields)
        if (h[f] !== base[f] + p.baseline.stats[f] * edge.inheritance.coefficient)
            fail('Chỉ số kế thừa preset không khớp.');
    return { ...h, id, _local_transformation: { ...h._local_transformation, createdAt: Date.now() } };
}
export async function transformedRepairPreview(db, userId, heroId, sourceId) {
    const r = db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(userId, heroId);
    if (!r)
        fail('Tướng không thuộc tài khoản.');
    const h = JSON.parse(String(r.state)), preset = await transformedMailPreset(h.c_id, sourceId);
    return { heroId, sourceId, targetId: h.c_id, currentProgression: { lv: h.lv, evo: h.evo, bre: h.bre, super_step: h.super_step }, currentStats: Object.fromEntries(inheritedFields.map(f => [f, h[f]])), savedInheritance: h._local_transformation ?? null, proposedSource: preset.preview, canApply: false, status: 'REVIEW_REQUIRED', notice: 'Dry-run chỉ đọc. Tướng cũ thiếu snapshot nguồn không thể xác định phần raw đã chứa bonus kế thừa nào. Không tự cộng chồng hoặc thay stat đang có; cấp một instance QA mới qua preset Mail để đối chiếu, giữ tướng cũ.' };
}
