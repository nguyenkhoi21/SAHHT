import { hotConfig, hotDay, hotFail, hotStamp } from './hot-source.js';
import { readConfigSync as loadConfig } from './local-content.js';
// Catalog nguồn không đổi trong vòng đời tiến trình; lịch/claim vẫn đọc DB mỗi yêu cầu.
const definitions = new Map();
function readConfigSync(name) { if (!definitions.has(name))
    definitions.set(name, loadConfig(name)); return definitions.get(name); }
import { audit } from '../admin/admin.audit.js';
export const hotTabs = { single: 1, total: 2, exchange: 3, spend: 5 };
const defaultSpend = ['shop.buy', 'shop.vip_buy', 'shop.vip_store_buy', 'gacha.get_gacha', 'arena.purchase', 'cards.inherit', 'cards.element_break', 'gringotts.refresh'];
let sourceCache;
export function sourceCampaigns() {
    if (sourceCache)
        return sourceCache;
    const groups = new Map();
    for (const [table, kind] of [['active_recharge', 'recharge'], ['active_consume', 'spend'], ['omni_exchange', 'exchange']])
        for (const [id, row] of Object.entries(hotConfig(table))) {
            const k = kind === 'recharge' ? (row.charge_type === 1 ? 'single' : 'total') : kind;
            if (kind === 'recharge' && (![1, 2].includes(row.charge_type) || row.num_type !== 0) || kind === 'spend' && row.consume_type !== 2)
                continue;
            let starts, ends;
            try {
                starts = hotStamp(row.start_time);
                ends = hotStamp(row.end_time, typeof row.end_time === 'string');
            }
            catch {
                continue;
            }
            if (ends <= starts)
                continue;
            const key = `vn-${k}-${starts}-${ends}`;
            let group = groups.get(key);
            if (!group) {
                group = { id: key, name: ({ single: 'Hoạt động nạp thẻ', total: 'Tổng nạp', spend: 'Tích lũy tiêu Xu', exchange: 'Đổi tính giờ' })[k] + ' · ' + hotDay(starts), kind: k, starts, ends, realm: 'local-1', reset: 'campaign', order: hotTabs[k], rows: [], spendKinds: defaultSpend, level: row.level ?? [1, 300], source: true, status: 'published' };
                groups.set(key, group);
            }
            const rewards = k === 'exchange' ? [1, 2, 3, 4, 5].flatMap(n => row['out_item' + n] ?? []) : row.reward;
            group.rows.push({ key: id, wireId: Number(id), name: row.des ?? 'Trao đổi #' + id, threshold: row.num ?? 0, packageId: row.charge_id ?? 0, limit: k === 'exchange' ? (row.exchange_type === 0 ? 0 : row.exchange_num) : row.repeat === 0 ? 1 : 0, repeat: row.repeat ?? 0, inputs: k === 'exchange' ? row.need_item : [], rewards, order: row.show_id ?? Number(id), source: row, blocked: k === 'exchange' && (row.step || row.break || row.material_type || row.strengthen || row.equip_st) ? 'Nguồn yêu cầu trạng thái thẻ/trang bị; chưa hỗ trợ chọn vật liệu nâng sẵn.' : undefined });
        }
    sourceCache = [...groups.values()].map(c => ({ ...c, rows: c.rows.sort((a, b) => a.order - b.order) }));
    return sourceCache;
}
export function campaignRows(db) { const local = db.prepare('SELECT * FROM hot_campaigns ORDER BY id').all().map((r) => ({ ...JSON.parse(r.definition), id: r.source_key ?? 'admin-' + r.id, dbId: r.id, revision: r.revision, status: r.status, source: !!r.source_key, sourceKey: r.source_key })); const replacements = new Set(local.filter(c => c.sourceKey).map(c => c.sourceKey)); return [...sourceCampaigns().filter(c => !replacements.has(c.id)), ...local]; }
export function rewardProblem(rows, cost = false) {
    if (!Array.isArray(rows) || rows.length > 10 || (!cost && !rows.length))
        return 'Chọn1–10dòng phần thưởng.';
    const currencies = [1, 2, 4, 9, 10, 11, 15, 16, 17, 18, 20, 23, 24, 26, 27, 33, 34, 35, 40, 41, 42, 43, 47, 106];
    for (const row of rows) {
        if (!Array.isArray(row) || row.length !== 3 || !row.every(Number.isSafeInteger) || row[2] < 1 || row[2] > 100000000)
            return 'Dòng tài nguyên cần loại/ID/số lượng nguyên dương.';
        const [type, id, count] = row;
        if (currencies.includes(type)) {
            if (type === 106 && count > 1000000)
                return 'Vé S tối đa1.000.000mỗi dòng.';
            if (id !== 0 || cost && ![1, 2, 9, 10, 11, 17, 18, 20, 23, 33, 34, 35, 40, 41, 42, 43].includes(type))
                return 'Tiền tệ/chi phí chưa hỗ trợ.';
        }
        else if (type === 6) {
            if (!readConfigSync('item')[id]?.name || count > 1000000)
                return 'Thiếu vật phẩm nguồn #' + id;
        }
        else if (type === 5 && !cost) {
            if (!readConfigSync('character_detail')[id] || count > 5)
                return 'Thiếu tướng nguồn/số lượng không hợp lệ.';
        }
        else if (type === 7 && !cost) {
            if (!readConfigSync('equip')[id] || count > 5)
                return 'Thiếu trang bị nguồn/số lượng không hợp lệ.';
        }
        else if ([108, 109].includes(type) && !cost) {
            if (!readConfigSync(type === 108 ? 'equip_gem_fate_stone' : 'equip_gem_fate_word')[id] || count > 1000000)
                return 'Thiếu nguyên liệu Ban Sức nguồn.';
        }
        else if (type === 25 && !cost) {
            if (!readConfigSync('pet_detail')[id] || count > 5)
                return 'Thiếu PET nguồn/số lượng không hợp lệ.';
        }
        else if (type === 50 && !cost) {
            if (!readConfigSync('equip_gem_fate')[id])
                return 'Thiếu đá Vận Mệnh nguồn.';
        }
        else
            return 'Loại thưởng/chi phí chưa đủ hợp đồng: ' + type;
    }
    return '';
}
export function rowProblem(row, kind) { return (row.blocked ?? rewardProblem(row.rewards)) || (kind === 'exchange' ? rewardProblem(row.inputs, true) || (!row.inputs?.length ? 'Thiếu chi phí trao đổi.' : '') : ''); }
export function campaignState(c, at) { return c.status === 'draft' ? 'draft' : c.status === 'disabled' ? 'disabled' : at < c.starts ? 'scheduled' : at >= c.ends ? 'expired' : 'active'; }
export class HotCampaignAdmin {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    list(q = {}) { const month = String(q.month ?? hotDay(this.now()).slice(0, 7)); if (!/^\d{4}-\d{2}$/.test(month))
        hotFail('Tháng cầnYYYY-MM.'); const start = hotStamp(month + '-01T00:00'), next = new Date(start + 7 * 3600000); next.setUTCMonth(next.getUTCMonth() + 1); const end = next.getTime() - 7 * 3600000, all = campaignRows(this.db).filter(c => c.starts < end && c.ends > start && (!q.kind || c.kind === q.kind) && (!q.q || (c.name + ' ' + c.id).toLocaleLowerCase().includes(String(q.q).toLocaleLowerCase()))), page = Math.max(1, Math.min(1000, Number(q.page) || 1)); return { month, timezone: 'Asia/Ho_Chi_Minh', realm: 'local-1', realms: [{ id: 'local-1', name: 'LOCAL hiện tại' }], dayCounts: Object.fromEntries(Array.from({ length: 31 }, (_, i) => { const day = month + '-' + String(i + 1).padStart(2, '0'); let n = 0; try {
            const a = hotStamp(day + 'T00:00');
            n = all.filter(c => c.starts < a + 86400000 && c.ends > a).length;
        }
        catch { } return [day, n]; })), total: all.length, page, campaigns: all.slice((page - 1) * 40, page * 40).map(c => ({ ...c, state: campaignState(c, this.now()), blockers: c.rows.map(r => rowProblem(r, c.kind)).filter(Boolean) })) }; }
    validate(raw) {
        const kind = raw.kind;
        if (!Object.hasOwn(hotTabs, kind))
            hotFail('Loại chiến dịch không hợp lệ.');
        const starts = hotStamp(raw.starts), ends = hotStamp(raw.ends);
        if (ends <= starts || ends - starts > 366 * 86400000)
            hotFail('Lịch cần kết thúc sau bắt đầu, tối đa366ngày.');
        if (raw.realm !== 'local-1')
            hotFail('Chỉ realmLOCAL hiện tại được ghi, không truy cậpONLINE hoặc DBrealm khác.');
        if (!['daily', 'campaign'].includes(raw.reset))
            hotFail('Phạm vi tích lũy không hợp lệ.');
        if (typeof raw.name !== 'string' || !raw.name.trim() || raw.name.length > 120 || !Array.isArray(raw.rows) || !raw.rows.length || raw.rows.length > 80)
            hotFail('Tên/mốc chiến dịch không hợp lệ.');
        const seen = new Set();
        const rows = raw.rows.map((r, i) => { const key = String(r.key ?? i + 1); if (!/^[A-Za-z0-9-]{1,24}$/.test(key) || seen.has(key))
            hotFail('Mã mốc cần duy nhất và ổn định.'); seen.add(key); const row = { key, name: String(r.name ?? raw.name).slice(0, 160), threshold: Number(r.threshold ?? 0), packageId: Number(r.packageId ?? 0), limit: Number(r.limit ?? 1), inputs: r.inputs ?? [], rewards: r.rewards, order: i + 1 }; if (![row.threshold, row.packageId, row.limit].every(Number.isSafeInteger) || row.threshold < 0 || row.limit < 0 || row.limit > 100000)
            hotFail('Ngưỡng/hạn mức không hợp lệ.'); if (kind !== 'exchange' && row.threshold < 1)
            hotFail('Ngưỡng phải dương.'); if (kind === 'single' && row.packageId && !hotConfig('charge')[row.packageId])
            hotFail('Gói nạp không tồn tại.'); if (kind === 'exchange' && row.inputs.length + row.rewards.length > 5 || kind !== 'exchange' && row.rewards.length > 5)
            hotFail('Giao diện HOT gốc hỗ trợ tối đa5ô trên một dòng (nguyên liệu + quà với trao đổi).'); const problem = rowProblem(row, kind); if (problem)
            hotFail(problem); return row; });
        const spendKinds = raw.spendKinds ?? defaultSpend;
        if (!Array.isArray(spendKinds) || spendKinds.length > 50 || spendKinds.some((s) => typeof s !== 'string' || !/^(?:shop\.|gacha\.|cards\.|equip\.|gem\.|gem_fate\.|soul\.|medal\.|talisman\.|laboratory\.|factory\.|arena\.purchase|homeland\.|gringotts\.refresh$)[\w.]*$/.test(s)))
            hotFail('Loại tiêu Xu cần nghiệp vụ game, không Admin/nạp/hoàn tiền.');
        return { name: raw.name.trim(), kind, starts, ends, realm: 'local-1', reset: raw.reset, rows, order: Number(raw.order ?? hotTabs[kind]), spendKinds, level: [1, 300], source: false };
    }
    save(admin, body) { if (body.confirmed !== true)
        hotFail('Cần xác nhận thay đổi.'); if (body.sourceKey)
        hotFail('Không ghi đè nguồn từ form; chỉ bật/tắt nguồn bằng thao tác riêng.'); if (body.id && !Number.isSafeInteger(Number(body.id)))
        hotFail('Mã chiến dịch không hợp lệ.'); const draft = this.validate(body.definition); this.db.exec('SAVEPOINT hot_campaign_mutation'); try {
        const before = body.id ? this.db.prepare('SELECT * FROM hot_campaigns WHERE id=?').get(Number(body.id)) : undefined;
        if (body.id && !before)
            hotFail('Chiến dịch không tồn tại.');
        if (before && (before.status !== 'draft' || Number(body.revision) !== before.revision))
            hotFail('Bản đã publish bất biến; hãy nhân bản để thay lịch/thưởng.');
        const id = before ? Number(body.id) : Number(this.db.prepare("INSERT INTO hot_campaigns(source_key,status,definition,created_at,updated_at) VALUES(?,'draft',?,?,?)").run(body.sourceKey ?? null, JSON.stringify(draft), this.now(), this.now()).lastInsertRowid);
        if (before)
            this.db.prepare('UPDATE hot_campaigns SET definition=?,revision=revision+1,updated_at=? WHERE id=?').run(JSON.stringify(draft), this.now(), id);
        audit(this.db, admin, 'hot.campaign.save', null, 'Lưu bản nháp sự kiện LOCAL; không đổi claim/tài nguyên', before, { id, definition: draft });
        this.db.exec('RELEASE hot_campaign_mutation');
        return { id };
    }
    catch (e) {
        this.db.exec('ROLLBACK TO hot_campaign_mutation;RELEASE hot_campaign_mutation');
        throw e;
    } }
    publish(admin, id, revision, disable = false) { if (!Number.isSafeInteger(id) || id < 1 || !Number.isSafeInteger(revision) || revision < 1)
        hotFail('Mã/phiên bản chiến dịch không hợp lệ.'); this.db.exec('SAVEPOINT hot_campaign_mutation'); try {
        const old = this.db.prepare('SELECT * FROM hot_campaigns WHERE id=?').get(id);
        if (!old || Number(old.revision) !== revision)
            hotFail('Chiến dịch đã đổi, tải lại.');
        if (!disable && old.status !== 'draft')
            hotFail('Chỉ publish bản nháp mới.');
        const d = JSON.parse(String(old.definition));
        this.validate(d);
        this.db.prepare('UPDATE hot_campaigns SET status=?,revision=revision+1,updated_at=? WHERE id=?').run(disable ? 'disabled' : 'published', this.now(), id);
        audit(this.db, admin, disable ? 'hot.campaign.disable' : 'hot.campaign.publish', null, 'Phạm viLOCAL; lịch tự kích hoạt không restart', old, { id });
        this.db.exec('RELEASE hot_campaign_mutation');
        return { id };
    }
    catch (e) {
        this.db.exec('ROLLBACK TO hot_campaign_mutation;RELEASE hot_campaign_mutation');
        throw e;
    } }
    toggleSource(admin, id, enabled) {
        const source = sourceCampaigns().find(c => c.id === id);
        if (!source)
            hotFail('Không có chiến dịch nguồn.');
        this.db.exec('SAVEPOINT hot_source_toggle');
        try {
            const before = this.db.prepare('SELECT * FROM hot_campaigns WHERE source_key=?').get(id);
            this.db.prepare("INSERT INTO hot_campaigns(source_key,status,definition,created_at,updated_at) VALUES(?,?,?,?,?) ON CONFLICT(source_key) DO UPDATE SET status=excluded.status,revision=hot_campaigns.revision+1,updated_at=excluded.updated_at").run(id, enabled ? 'published' : 'disabled', JSON.stringify(source), this.now(), this.now());
            audit(this.db, admin, 'hot.campaign.source_toggle', null, 'Bật/tắt lịch nguồn LOCAL, giữ nguyên ID và claim', before, { source: id, enabled });
            this.db.exec('RELEASE hot_source_toggle');
            return { id };
        }
        catch (e) {
            this.db.exec('ROLLBACK TO hot_source_toggle;RELEASE hot_source_toggle');
            throw e;
        }
    }
    duplicate(admin, id, date) { const original = campaignRows(this.db).find(c => c.id === id); if (!original)
        hotFail('Không thấy chiến dịch để sao chép.'); const starts = hotStamp(date + 'T00:00'), offset = original.starts - hotStamp(hotDay(original.starts) + 'T00:00'); return this.save(admin, { confirmed: true, definition: { ...original, name: original.name + ' · bản sao', starts: starts + offset, ends: starts + offset + original.ends - original.starts, rows: original.rows.map(r => ({ ...r, key: r.key.slice(0, 24) })) } }); }
}
