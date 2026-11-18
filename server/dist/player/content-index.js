import { readFile } from 'node:fs/promises';
import { localContent } from './local-content.js';
const cache = new Map();
export function contentIndex(name) {
    if (!cache.has(name))
        cache.set(name, readFile(new URL(`../../../work/generated/${name}.json`, import.meta.url), 'utf8').then(raw => {
            const base = JSON.parse(raw), runtime = localContent();
            if (name === 'hero_catalog')
                return [...base, ...runtime?.heroCatalog ?? []];
            if (name !== 'equipment_catalog')
                return base;
            const extra = Object.entries(runtime?.configs.equip ?? {}).filter(([id]) => !base.some((r) => String(r.configId) === id)).map(([id, value]) => { const r = value, icon = 'assets/iphonehd/icon/' + r.image + '.png', present = !!runtime?.files[icon]; return { configId: Number(id), name: r.name, slot: r.sort, quality: r.quality, baseStats: [[r.ability1, r.value1], [r.ability2, r.value2]], levelAdd: [r.level_add1, r.level_add2], suit: r.suit, occupation: r.occupation1, icon: present ? icon : null, resourceStatus: present ? 'ICON PRESENT' : 'MISSING ICON', grantable: present, classification: 'EQUIPMENT', confidence: 'CONFIRMED', sources: ['equip', 'VN runtime add-only'], compatibility: { occupation: r.occupation1, runtimeRule: 'Base/level/Vận Mệnh đã hỗ trợ; passive đặc biệt chưa mô phỏng.' } }; });
            return [...base, ...extra].sort((a, b) => a.configId - b.configId);
        }));
    return cache.get(name);
}
export function assetSummary() {
    if (!cache.has('summary'))
        cache.set('summary', readFile(new URL('../../../work/asset-index/summary.json', import.meta.url), 'utf8').then(JSON.parse));
    return cache.get('summary');
}
export function heroCandidates() {
    if (!cache.has('candidates'))
        cache.set('candidates', readFile(new URL('../../../work/asset-index/hero_resource_candidates.json', import.meta.url), 'utf8').then(raw => mergeHeroModelGroups(JSON.parse(raw), localContent())));
    return cache.get('candidates');
}
export function mergeHeroModelGroups(base, extension) {
    const heroes = extension?.heroCatalog ?? [], byModel = new Map();
    for (const h of heroes) {
        const group = byModel.get(h.internalName) ?? [];
        group.push(h);
        byModel.set(h.internalName, group);
    }
    const groups = base.map(g => {
        const additions = byModel.get(g.internalName) ?? [];
        if (!additions.length)
            return g;
        return { ...g, originalConfigIds: g.configIds, configIds: [...new Set([...g.configIds, ...additions.map(h => h.configId)])], classification: additions.some(h => h.sourceDefinition) ? 'RECOVERED SOURCE HERO' : 'LOCAL TEST HERO', resolution: 'Định nghĩa có provenance nguồn; giữ ID/model local cũ' };
    });
    const seen = new Set(groups.map(g => g.internalName));
    for (const resource of extension?.resources ?? []) {
        const additions = byModel.get(resource.animation) ?? [];
        if (seen.has(resource.animation) || !additions.length)
            continue;
        seen.add(resource.animation);
        groups.push({ internalName: resource.animation, model: resource.model, portrait: resource.portrait, sections: resource.sections ?? [], configIds: [...new Set(additions.map(h => h.configId))], classification: 'RECOVERED SOURCE HERO', resolution: 'Resource từ batch có provenance; chỉ xác nhận animation đã kiểm.', aliases: [...new Set(additions.flatMap(h => h.aliases ?? []))], source: resource.evidence });
    }
    return groups;
}
export function heroRegistry() {
    if (!cache.has('heroRegistry'))
        cache.set('heroRegistry', readFile(new URL('../../../work/generated/hero_registry.json', import.meta.url), 'utf8').then(JSON.parse));
    return cache.get('heroRegistry');
}
export async function contentDiagnostics() {
    const [summary, heroes, equipment, stages, candidates] = await Promise.all([assetSummary(), contentIndex('hero_catalog'), contentIndex('equipment_catalog'), contentIndex('stage_catalog'), heroCandidates()]);
    if (!cache.has('secondPass'))
        cache.set('secondPass', readFile(new URL('../../../work/asset-index/second_pass_relationships.json', import.meta.url), 'utf8').then(JSON.parse));
    const secondPass = await cache.get('secondPass');
    if (!cache.has('grantValidation'))
        cache.set('grantValidation', readFile(new URL('../../../work/generated/hero_grant_validation.json', import.meta.url), 'utf8').then(JSON.parse));
    const serverValidation = await cache.get('grantValidation');
    const matched = heroes.filter(x => x.resourceStatus === 'FULL ASSETS');
    const shared = candidates.filter(x => x.configIds.length > 1);
    return { summary, serverValidation, secondPass: secondPass.summary, evidence: 'STATIC VERIFIED', notice: 'Có file không đồng nghĩa hero playable. Nhóm không có config/skill không được cấp. Chỉ mục tạo trước, không quét APK mỗi request.', unresolved: candidates.filter((x) => !x.configIds.length).map((x) => ({ internalName: x.internalName, model: x.model, sections: x.sections, classification: x.classification, configReferences: x.configReferences, luaReferences: x.luaReferences })), heroesWithoutAssets: heroes.filter(x => x.resourceStatus !== 'FULL ASSETS').map(x => ({ configId: x.configId, name: x.displayName, resourceStatus: x.resourceStatus })), equipmentWithoutAssets: equipment.filter(x => !x.icon).map(x => ({ configId: x.configId, name: x.name })), fullyMatched: matched.map(x => ({ configId: x.configId, name: x.displayName, model: x.internalName })), sharedModelGroups: shared.map(x => ({ model: x.internalName, configIds: x.configIds, notice: 'Nhiều config dùng chung model; quan hệ skin/base chưa được suy tự động.' })), stageCount: stages.length };
}
