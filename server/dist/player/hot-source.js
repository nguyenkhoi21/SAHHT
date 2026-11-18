import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const proof = JSON.parse(readFileSync(new URL('../../../tools/runtime/hot-source.json', import.meta.url), 'utf8'));
const cache = new Map();
export function hotConfig(name) { if (cache.has(name))
    return cache.get(name); const row = proof.tables[name]; if (!row)
    throw Error('Thiếu bảng HOT đã xác minh.'); const bytes = readFileSync(new URL('../../../' + row.path, import.meta.url)); if (createHash('sha256').update(bytes).digest('hex') !== row.sha256)
    throw Error('Nguồn HOT không khớp hash: ' + name); const result = JSON.parse(bytes.toString()); cache.set(name, result); return result; }
export const hotFail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export const hotDay = (at) => new Date(at + 7 * 3600000).toISOString().slice(0, 10);
export function hotStamp(value, endMinute = false) { if (typeof value === 'number' && Number.isFinite(value))
    return value < 1e11 ? value * 1000 : value; const s = String(value ?? ''); if (!/^\d{4}[-/]\d\d[-/]\d\d[,T ]\d\d:\d\d(?::\d\d)?(?:\+07:00|Z)?$/.test(s))
    hotFail('Ngày giờ cần định dạng YYYY-MM-DDTHH:mm, giờ Việt Nam.'); const normalized = s.replaceAll('/', '-').replace(/[, ]/, 'T'), n = Date.parse(normalized + (/[Z]|[+]07:00$/.test(normalized) ? '' : '+07:00')); const local = new Date(n + (normalized.endsWith('Z') ? 0 : 7 * 3600000)); if (!Number.isFinite(n) || local.toISOString().slice(0, 16) !== normalized.slice(0, 16))
    hotFail('Ngày không hợp lệ.'); return n + (endMinute ? 60000 : 0); }
export const hotPolicy = { version: 'hot-local-v1', timezone: 'Asia/Ho_Chi_Minh', singleBasis: 'package_id_or_price_vnd_div100', totalBasis: 'vip_exp', ticketVnd: 10000, firstDouble: 'base_coin_extra_once', spending: 'explicit_transaction_scope', notice: 'LOCAL sandbox: gói/giá/Xu/VIP EXP và mốc nguồn Việt Nam. Nạp đơn dùng charge_id/giáVND÷100; tổng nạp dùng VIP EXP gói, không tính Xu tặng. Chủ dự án xác nhận gói20.000→đơn200/tổng220,2Vé S trả toàn bộ. Phạm vi tiêu Xu do chiến dịch cấu hình theo loại giao dịch; không phải công thức server gốc đã xác minh. Không thanh toán thật.' };
