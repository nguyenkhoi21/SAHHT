import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const root = new URL('../../../', import.meta.url), manifest = JSON.parse(readFileSync(new URL('tools/runtime/restored-events-source.json', root), 'utf8')), cache = new Map();
export function restoredSource(name) { if (!cache.has(name)) {
    const e = manifest.tables[name];
    if (!e)
        throw Error('Không có bảng Việt đã xác minh.');
    const raw = readFileSync(new URL(e.path, root));
    if (createHash('sha256').update(raw).digest('hex') !== e.sha256)
        throw Error('Hash nguồn không khớp: ' + name);
    cache.set(name, JSON.parse(raw.toString()));
} return cache.get(name); }
export const restoredKinds = { investment: { name: 'Cổ Linh Các', target: 'main.524' }, dispatch: { name: 'Xuất Chinh · Phái tướng 2 giờ', target: 'main.561' } };
export function restoredDefault(kind, version = 1) {
    if (kind === 'investment') {
        const row = restoredSource('gringotts')[version];
        if (!row)
            throw Error('Không có phiên bản Cổ Linh Các.');
        return structuredClone({ kind, name: 'Cổ Linh Các LOCAL', sourceVersion: version, policy: 'LOCAL_CONFIGURED', rule: row, vip: restoredSource('gringotts_VIP'), rates: Object.values(restoredSource('gringotts_rate')).filter(r => r.version === version).sort((a, b) => a.id - b.id), upWeight: 50, downWeight: 50, notice: 'LOCAL: bốc lên/xuống theo tỷ trọng Admin, chọn khoảng theo trọng số rồi lấy số nguyên đều; hệ số kỳ hạn theo bảng Việt. Gia tốc tính theo giờ dư làm tròn lên, giảm lợi nhuận tối đa 100%, giữ vốn.' });
    }
    const rule = restoredSource('chuzheng_version')[version];
    if (!rule)
        throw Error('Không có phiên bản Xuất Chinh.');
    return structuredClone({ kind, name: 'Xuất Chinh LOCAL', sourceVersion: version, policy: 'LOCAL_CONFIGURED', rule, tasks: Object.fromEntries(rule.task.map((id) => [id, restoredSource('chuzheng_task')[id]])), freeDaily: 6, tierWeights: [60, 30, 10], duration: 7200, notice: '6 lượt miễn phí mỗi ngày Việt Nam theo chủ dự án. Tỷ trọng S/SS/SSS LOCAL mặc định 60/30/10 có thể chỉnh; chọn4tướng không trùng từ danh sách nhiệm vụ. Tướng không bị tiêu hao, chỉ khóa sử dụng trùng trong các nhiệm vụ đang chờ. Quà theo snapshot lúc tham gia.' });
}
