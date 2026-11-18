import { createHash } from 'node:crypto';
import { hotConfig, hotFail, hotPolicy } from '../player/hot-source.js';
import { audit } from '../admin/admin.audit.js';
export function installRechargeSettings(db) {
    if (db.prepare('PRAGMA user_version').get().user_version !== 39)
        throw Error('Cần baseline schema39.');
    db.exec(`CREATE TABLE IF NOT EXISTS local_recharge_prices(
    package_id INTEGER PRIMARY KEY,revision INTEGER NOT NULL CHECK(revision>0),
    tickets INTEGER NOT NULL CHECK(tickets BETWEEN 1 AND 1000000),
    enabled INTEGER NOT NULL CHECK(enabled IN(0,1)),updated_at INTEGER NOT NULL
  )`);
}
export class RechargeSettings {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    ready() { return !!this.db.prepare("SELECT 1 FROM sqlite_master WHERE type='table' AND name='local_recharge_prices'").get(); }
    get(packageId) {
        const row = this.ready() ? this.db.prepare('SELECT * FROM local_recharge_prices WHERE package_id=?').get(packageId) : undefined;
        const tickets = Number(row?.tickets ?? hotConfig('charge')[packageId]?.price / hotPolicy.ticketVnd);
        return { revision: Number(row?.revision ?? 0), tickets, enabled: row ? row.enabled === 1 : Number.isSafeInteger(tickets) && tickets > 0, custom: !!row };
    }
    list() {
        return { ready: this.ready(), packages: Object.entries(hotConfig('charge')).filter(([, c]) => c.is_show === 1).map(([id, c]) => ({
                packageId: Number(id), name: c.name, price: c.price, baseCoin: c.coin, vipExp: c.vip_exp, icon: c.icon, fixedTickets: c.price / hotPolicy.ticketVnd,
                ...this.get(Number(id)), supported: [1, 2, 13].includes(Number(id)) || (c.coin > 0 && c.open_gift === 0),
                benefit: Number(id) === 1 ? 'Phúc Lợi · Thẻ tháng 21 ngày' : Number(id) === 13 ? 'Phúc Lợi · Thẻ Mùa 90 ngày' : Number(id) === 2 ? 'Thẻ tuần · quà qua Thư' : 'Xu, VIP EXP và tiến độ nạp theo gói gốc'
            })) };
    }
    save(adminId, input) {
        const { packageId, revision, tickets, enabled, requestId } = input, c = hotConfig('charge')[packageId];
        if (!c || c.is_show !== 1 || (![1, 2, 13].includes(packageId) && !(c.coin > 0 && c.open_gift === 0)))
            hotFail('Gói chưa có cơ chế thưởng đã hỗ trợ.');
        if (!Number.isSafeInteger(tickets) || tickets < 1 || tickets > 1000000 || typeof enabled !== 'boolean' || !Number.isSafeInteger(revision) || revision < 0)
            hotFail('Giá Vé Vàng cần số nguyên từ 1 đến 1.000.000.');
        if (typeof requestId !== 'string' || !/^[A-Za-z0-9:_-]{8,120}$/.test(requestId))
            hotFail('Thiếu mã thao tác hợp lệ.');
        if (!this.ready())
            throw Object.assign(Error('Chưa áp extension giá vé theo quy trình duyệt/backup.'), { statusCode: 503 });
        const fingerprint = createHash('sha256').update(JSON.stringify({ packageId, revision, tickets, enabled })).digest('hex'), key = 'recharge-price:' + requestId;
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const replay = this.db.prepare('SELECT fingerprint,result FROM hot_admin_operations WHERE admin_id=? AND request_key=?').get(adminId, key);
            if (replay) {
                if (replay.fingerprint !== fingerprint)
                    throw Object.assign(Error('Mã thao tác đã dùng cho nội dung khác.'), { statusCode: 409 });
                this.db.exec('COMMIT');
                return { ...JSON.parse(String(replay.result)), replayed: true };
            }
            const before = this.get(packageId);
            if (before.revision !== revision)
                throw Object.assign(Error('Giá gói đã đổi. Làm mới để xem giá mới trước khi lưu.'), { statusCode: 409 });
            this.db.prepare('INSERT INTO local_recharge_prices VALUES(?,?,?,?,?) ON CONFLICT(package_id) DO UPDATE SET revision=excluded.revision,tickets=excluded.tickets,enabled=excluded.enabled,updated_at=excluded.updated_at').run(packageId, revision + 1, tickets, enabled ? 1 : 0, this.now());
            const result = { packageId, ...this.get(packageId) };
            audit(this.db, adminId, 'hot.recharge.price', null, 'Cập nhật giá Vé Vàng cho gói Nạp thẻ LOCAL', before, result, this.now());
            this.db.prepare('INSERT INTO hot_admin_operations VALUES(?,?,?,?)').run(adminId, key, fingerprint, JSON.stringify(result));
            this.db.exec('COMMIT');
            return result;
        }
        catch (error) {
            if (this.db.isTransaction)
                this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
