import { readFileSync, realpathSync } from 'node:fs';
import { resolve, relative, dirname, basename, isAbsolute } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
export const simPolicy = { version: 'aether-qa-sim-v1', label: 'MÔ PHỎNG LOCAL · chỉ DB QA cô lập', rules: [
        'Chỉ bật khi fixture.json được chủ dự án cho phép; event QA và DB isolated.sqlite trong work/phase37/qa-realm-*; không bật qua HTTP hoặc trên LOCAL chính/ONLINE.',
        'Trung lập: một NPC79001 dùng chỉ số/model enemy_detail nguồn; chỉ đánh thường. Không giả đã phục hồi skill69010/69020. Trận kỳ ngộ thiếu đội server dùng cùng NPC này và ghi rõ biên bản.',
        'Thưởng: mỗi tuple thứ4 là % độc lập; bốc số nguyên0–99 một lần/tuple; nếu vượt get_max thì xếp hạng băm rồi lấy đủ trần. Kết quả cố định theo hạt SHA256 event/ngày/request; lưu receipt, không bốc lại khi retry. Đây là lựa chọn mô phỏng, không phải thuật toán gốc.',
        'Rương:63ô/chiến trường/ngày, phân loại1–4 theo mức băm đều;1lượt/người/ngày. Không giả xác suất theo số thành. Mọi quà/cap lấy config, không thêm ID.',
        'Kỳ ngộ: chọn một dòng cùngcity/sort theo trọng số fate_num;1lượt/đội/ngày, kết quả nhận từ0h hôm sau. Type2/3 không thưởng, không tự thêm mức phạt chưa có nguồn.',
        'Tài nguyên: số ô/cấp/thuế theo bảng product. Đăng ký tranh ô trong dàn trận, giải quyết1vs1 khi chiến đấu; HP không mang giữa các trận tài nguyên. Rút ô thì bên khiêu chiến nhập trú. Sản lượng1lần/ngày qua Mail mùa, %tuple theo quy tắc LOCAL trên.',
        'Sản lượng thành: chụp người nhận thật cuối ngày quan sát, mỗi thành gửi một gói/người qua Mail vào ngày kế; không dựng các ngày downtime. Thuế tài nguyên là điểm KHKT cố định theo product × (100 + buff2 loại2 cộng dồn)/100, làm tròn xuống; không trừ quà của người khai thác. Chưa mô phỏng hệ số Ngày Thu Hoạch/buff rương vì thiếu phép ghép chính xác.',
        'Mật Lệnh: một ngày có hoạt động Aether thành công tính1ngày, tối đa30. Kích hoạt/tặng bằng nút QA giả lập giao dịch, không thu tiền thật; phần thưởng/send_num vẫn theo card của mùa.',
        'Hạn Mua Chiến Trường: mô phỏng hạn chung theo event/group/offer cho cả mùa. Hạn Cá Nhân giữ theo user/event; loại3 mô phỏng hạn user/ngày. Catalog biến động hiển thị toàn bộ hàng đủ KHKT, không giả đã phục hồi bước chọn hàng gốc.',
        'Điểm hội: điểm thành hiện giữ + tổng buff2 loại5 đã mở; chỉ dùng mô phỏng. Thưởng hội theo mốc need cao nhất đã đạt, Mail thường một lần/người đã có hoạt động trong sổ mùa, không lấy người mới từ membership hiện tại.',
        'KHKT trả phí: nút QA ghi tín dụng nạp mô phỏng500Xu/lượt, tối đa3tín dụng/ngày; không trừ tiền thật. Tổng cống tối đa4lượt/ngày, chi phí vật liệu thật trong DB QA.'
    ] };
const root = fileURLToPath(new URL('../../../', import.meta.url));
export function simEnabled(db, event) {
    if (process.env.APP_ENV === 'online')
        return false;
    if (event && (!event.qa || !event.qa_active))
        return false;
    try {
        const row = db.prepare('PRAGMA database_list').all().find(r => r.name === 'main');
        if (!row?.file)
            return false;
        const path = realpathSync(String(row.file)), base = realpathSync(resolve(root, 'work/phase37')), part = relative(base, path);
        if (isAbsolute(part) || part.startsWith('..') || basename(path) !== 'isolated.sqlite' || !/^qa-realm-[\w-]+$/.test(basename(dirname(path))))
            return false;
        const meta = JSON.parse(readFileSync(resolve(dirname(path), 'fixture.json'), 'utf8'));
        return meta.marker === 'sahht-aether-isolated-qa-v1' && meta.environment === 'QA_ISOLATED' && meta.primaryDatabaseRead === false && meta.simulation?.enabled === true && meta.simulation?.policyVersion === simPolicy.version;
    }
    catch {
        return false;
    }
}
export function simAssert(db, event) { if (!simEnabled(db, event))
    throw Object.assign(Error('Mô phỏng Aether chỉ được bật trong fixture QA đã cho phép; chưa tiêu tài nguyên.'), { statusCode: 422 }); }
export function simGet(db, event, user, kind, scope, fallback = {}) { const row = db.prepare('SELECT state FROM aether_sim_state WHERE event_id=? AND user_id=? AND kind=? AND scope=?').get(event, user, kind, scope); return row ? JSON.parse(String(row.state)) : structuredClone(fallback); }
export function simPut(db, event, user, kind, scope, state, at) { if (!db.isTransaction)
    throw Error('State mô phỏng cần transaction.'); db.prepare('INSERT INTO aether_sim_state VALUES(?,?,?,?,?,?) ON CONFLICT(event_id,user_id,kind,scope) DO UPDATE SET state=excluded.state,updated_at=excluded.updated_at').run(event, user, kind, scope, JSON.stringify(state), at); }
export function simRoll(key, index = 0, max = 100) { if (!Number.isSafeInteger(max) || max < 1)
    throw Error('Giới hạn bốc số không hợp lệ.'); return createHash('sha256').update(key + ':' + index).digest().readUInt32BE() % max; }
export function simRewards(rows, key, maxDrops = 10000) { const out = []; for (const [i, row] of rows.entries()) {
    if (!Array.isArray(row) || row.length < 3)
        continue;
    const [kind, id, n, chance = 100] = row;
    if (!Number.isSafeInteger(n) || n < 1 || !Number.isInteger(chance) || chance < 0 || chance > 100)
        throw Error('Tuple quà mô phỏng không hợp lệ.');
    if (simRoll(key, i) < chance)
        out.push([kind, id, n]);
} if (!Number.isSafeInteger(maxDrops) || maxDrops < 0)
    throw Error('Trần thưởng không hợp lệ.'); return out.map((row, index) => ({ row, order: simRoll(key + ':select', index, 2147483647) })).sort((a, b) => a.order - b.order).slice(0, maxDrops).map(v => v.row); }
