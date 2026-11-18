import { readFile } from 'node:fs/promises';
import { pageQuery } from '../admin/admin.schemas.js';
import { contentSourcePolicy } from './source-policy.js';
import { contentIndex } from './content-index.js';
export async function vnSourceCatalog(query) {
    const { q, page, pageSize } = pageQuery(query);
    let report;
    try {
        report = JSON.parse(await readFile(new URL('../../../work/vn-source/audit.json', import.meta.url), 'utf8'));
    }
    catch (error) {
        if (error.code === 'ENOENT')
            return { available: false, total: 0, items: [], policy: contentSourcePolicy };
        throw error;
    }
    if (report.revision !== 'vn-source-audit-v1' || !Array.isArray(report.heroes))
        throw new Error('Chỉ mục nguồn Việt Nam không hợp lệ.');
    const indexed = new Map((await contentIndex('hero_catalog')).map((r) => [r.configId, r]));
    const text = q.toLocaleLowerCase('vi');
    const heroes = report.heroes.filter((r) => (query.status !== 'new' || !r.inLocal) &&
        (query.status !== 'blocked' || r.resourceStatus !== 'FULL ASSETS' || r.displayNameNeedsReview) &&
        (!q || [r.configId, r.displayName, r.model, ...r.skillIds, ...(indexed.get(r.configId)?.aliases ?? [])].some(v => String(v).toLocaleLowerCase('vi').includes(text))));
    return { available: true, sourceKey: report.sourceKey, metadata: report.metadata, sourceFingerprint: report.sourceFingerprint,
        summary: report.summary, policy: contentSourcePolicy, total: heroes.length, page, pageSize,
        items: heroes.slice((page - 1) * pageSize, page * pageSize).map((r) => ({ ...r, displayName: r.displayNameNeedsReview ? 'Chờ xác minh tên Việt' : r.displayName,
            aliases: indexed.get(r.configId)?.aliases ?? [], baseGrantableByServer: indexed.get(r.configId)?.baseGrantableByServer === true,
            status: !r.inLocal ? 'Ứng viên mới' : r.sameDefinition ? 'Đã có trong local, cùng định nghĩa' : 'Xung đột định nghĩa',
            notice: 'Kiểm config/resource; chưa xác nhận battle Android cho từng hero.' })),
        missingBookIds: report.missingBookIds, newOrChangedFileCount: report.newOrChangedFiles.length,
        notice: report.policy };
}
