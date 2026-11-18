import { readFile } from 'node:fs/promises';
import { pageQuery } from '../admin/admin.schemas.js';
import { recoveredHeroesEnabled } from './recovered-content.js';
// Nguồn khác nhánh chỉ phục vụ đối chiếu; không merge vào staticConfig hoặc cấp hero.
export async function recoveredHeroSources() {
    try {
        const report = JSON.parse(await readFile(new URL('../../../work/generated/recovered_hero_sources.json', import.meta.url), 'utf8'));
        if (report.revision !== 'public-hero-recovery-v1' || !Array.isArray(report.heroCandidates))
            throw new Error('Registry nguồn bổ sung không hợp lệ.');
        const optional = async (path) => { try {
            return JSON.parse(await readFile(new URL(path, import.meta.url), 'utf8'));
        }
        catch (error) {
            if (error.code === 'ENOENT')
                return;
            throw error;
        } };
        const [compatibility, state] = await Promise.all([optional('../../../work/hero-import/compatibility.json'), optional('../../../work/hero-import/state.json')]);
        const byId = new Map((compatibility?.heroes ?? []).map((r) => [r.configId, r]));
        report.heroCandidates = report.heroCandidates.map((r) => ({ ...r, compatibility: byId.get(r.configId)?.compatibility,
            compatibilityBlockers: byId.get(r.configId)?.blockers, registryKey: byId.get(r.configId)?.registryKey,
            importBatch: state?.batches?.find((b) => b.status === 'ACTIVE' && b.ids.includes(r.configId))?.batch }));
        report.importBatches = state?.batches ?? [];
        report.importEnabled = recoveredHeroesEnabled();
        report.compatibilitySummary = compatibility?.summary;
        return report;
    }
    catch (error) {
        if (error.code === 'ENOENT')
            return;
        throw error;
    }
}
export function recoveredHeroCatalog(query, report) {
    const { q, page, pageSize } = pageQuery(query), term = q.toLocaleLowerCase('vi');
    if (!report)
        return { available: false, total: 0, page, pageSize, items: [], notice: 'Chưa có nguồn resource bổ sung đã kiểm chứng.' };
    const rows = report.heroCandidates.filter((r) => (!query.kind || r.classification === query.kind) &&
        (!q || [r.configId, r.displayName, r.sourceName, r.internalName, report.sourcePackage, ...(r.skillIds ?? []), ...(r.aliases ?? []), ...r.relatedCurrentConfigIds].some(v => String(v).toLocaleLowerCase('vi').includes(term))));
    return { available: true, total: rows.length, page, pageSize, items: rows.slice((page - 1) * pageSize, page * pageSize).map((r) => ({ ...r, currentGrantable: false })),
        summary: report.summary, sourcePackage: report.sourcePackage, sourceMetadata: report.sourceMetadata, sourceApkSha256: report.sourceApkSha256,
        sourceModelCandidates: report.sourceModelCandidates ?? [], importBatches: report.importBatches ?? [], importEnabled: report.importEnabled ?? false, compatibilitySummary: report.compatibilitySummary,
        classifications: Object.keys(report.classificationCounts), painStatus: report.painStatus, notice: report.integrationNotice };
}
