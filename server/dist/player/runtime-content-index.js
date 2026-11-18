import { readFile } from 'node:fs/promises';
import { vnRuntimeContent } from './vn-runtime-content.js';
import { pageQuery } from '../admin/admin.schemas.js';
async function reportFile(name) { try {
    return JSON.parse(await readFile(new URL('../../../work/vn-runtime-import/' + name, import.meta.url), 'utf8'));
}
catch (e) {
    if (e.code === 'ENOENT')
        return;
    throw e;
} }
export async function runtimeHeroVerification() {
    const report = await reportFile('android-verification.json'), active = vnRuntimeContent();
    if (!report || report.revision !== 'vn-runtime-android-qa-v1' || !active?.batches.every((b) => b.sourceKey === report.sourceKey))
        return {};
    const allowed = new Set(active.heroCatalog.map((h) => String(h.configId)));
    return Object.fromEntries(Object.entries(report.heroes ?? {}).filter(([id]) => allowed.has(id)));
}
export async function runtimeContentIndex(query) {
    let report;
    try {
        report = JSON.parse(await readFile(new URL('../../../work/runtime-content/audit.json', import.meta.url), 'utf8'));
    }
    catch (e) {
        if (e.code === 'ENOENT')
            return { available: false };
        throw e;
    }
    if (report.revision !== 'vn-runtime-audit-v1')
        throw new Error('Chỉ mục runtime không hợp lệ.');
    const { q, page, pageSize } = pageQuery(query), active = vnRuntimeContent(), ids = new Set((active?.heroCatalog ?? []).map((h) => h.configId)), term = q.toLocaleLowerCase('vi');
    const validation = await reportFile('candidate-validation.json'), qa = await runtimeHeroVerification();
    const features = await reportFile('feature-diagnostics.json');
    const checks = new Map(validation && validation.sourceKey === report.sourceKey ? validation.candidates.map((r) => [r.configId, r]) : []);
    const category = String(query.category ?? 'heroes');
    const classify = (name) => /character|super_evo|break_control|chain/.test(name) ? 'heroes' : /skill/.test(name) ? 'skills' : /vip/.test(name) ? 'vip' : /equip|item|badge|refinement/.test(name) ? 'items' : /city|stage|map|chapter|enemy/.test(name) ? 'maps' : /active|reward|highway|gashapon|newstar|crowdfunding|collection/.test(name) ? 'events' : 'other';
    const rows = category === 'heroes' ? report.candidates.map((h) => ({ ...h, displayName: h.nameNeedsReview ? 'Chờ xác minh tên Việt' : h.displayName, status: ids.has(h.configId) ? 'Đã tích hợp server' : h.nameNeedsReview ? 'Chờ xác minh tên Việt' : checks.get(h.configId)?.validation ?? h.status, blocker: h.nameNeedsReview ? 'Chưa có danh tính/tên Việt đã xác minh' : checks.get(h.configId)?.reason, imported: ids.has(h.configId), verification: qa[String(h.configId)]?.evidence ?? (ids.has(h.configId) ? 'CONFIG VERIFIED / RESOURCE VERIFIED / SERVER VERIFIED' : 'RESOURCE DISCOVERED'), android: qa[String(h.configId)] ?? null })) :
        report.tables.filter((t) => category === 'all' || classify(t.path.split('/').at(-1).replace('.config', '')) === category).map((t) => ({ table: t.path.split('/').at(-1).replace('.config', ''), records: t.records, newIds: t.newIds?.length ?? t.records, conflicts: t.changedIds?.length ?? 0, newTable: t.newTable, sha256: t.sha256, version: t.version, parseStatus: t.parseStatus, importedRows: Object.keys(active?.configs[t.path.split('/').at(-1).replace('.config', '')] ?? {}).length }));
    const annotated = rows.map((r) => ({ ...r, ...(r.table ? { diagnostics: features?.sourceKey === report.sourceKey ? features?.tables.find((t) => t.table === r.table) : null } : {}) }));
    const filtered = annotated.filter((r) => !q || JSON.stringify(r).toLocaleLowerCase('vi').includes(term));
    return { available: true, sourceKey: report.sourceKey, sourceFingerprint: report.sourceFingerprint, versionEvidence: report.versionEvidence, summary: report.summary, validation: validation?.summary, androidCounts: { roster: Object.values(qa).filter((r) => r.roster).length, formation: Object.values(qa).filter((r) => r.formation).length, battleSmoke: Object.values(qa).filter((r) => r.battleSmoke).length }, importedHeroes: ids.size, batches: active?.batches ?? [], category, page, pageSize, total: filtered.length, items: filtered.slice((page - 1) * pageSize, page * pageSize), vip: { max: Math.max(...report.summary.vipTiers), rewardMax: Math.max(...report.summary.vipRewardTiers), notice: 'VIP17 có định nghĩa và đặc quyền; chưa có quà VIP17 trong nguồn. Không sao chép quà VIP16.' }, policy: 'Bổ sung theo batch có hash/dependency, giữ config Việt Nam cũ. Tách số đã nhập với kiểm chứng Android. Rollback từ chối khi còn ownership, thư/Giftcode, event hoặc batch phụ thuộc. Không nhập prefs/DB/session nguồn.' };
}
