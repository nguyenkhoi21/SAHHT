import { contentReceipt } from './content-receipt.js';
import { audit } from '../admin/admin.audit.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
// Vé chữ S là profile.ticket trong ui_vip, không có item ID. Loại thưởng106 xác minh từ game_util.lua, icon/public_ticket.png.
export class LocalRechargeService {
    db;
    constructor(db) {
        this.db = db;
    }
    static separateLegacyCoupons(db) {
        db.exec('BEGIN IMMEDIATE');
        try {
            for (const r of db.prepare("SELECT user_id,profile FROM player_state WHERE json_extract(profile,'$._local_recharge_points')>0").all()) {
                const p = JSON.parse(String(r.profile));
                if (db.prepare("SELECT 1 FROM player_claims WHERE user_id=? AND system='local_recharge_policy' AND period='ticket-v2'").get(r.user_id))
                    continue;
                const rows = db.prepare("SELECT result FROM player_content_operations WHERE user_id=? AND method='local.recharge'").all(r.user_id);
                if (!rows.length)
                    continue;
                if (db.prepare("SELECT 1 FROM player_content_operations WHERE user_id=? AND method='local.ticket_recharge'").get(r.user_id))
                    continue;
                const old = rows.reduce((n, x) => n + Number(JSON.parse(String(x.result)).local_recharge?.added ?? 0), 0);
                if (old !== p._local_recharge_points)
                    fail('Điểm thử phiếu hồng không khớp ledger; cần kiểm tra trước khi tách.');
                const next = { ...p, _local_coupon_recharge_points: (p._local_coupon_recharge_points ?? 0) + old, _local_recharge_points: 0 };
                db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(next), r.user_id);
                db.prepare("INSERT INTO player_claims VALUES(?,'local_recharge_policy','ticket-v2','separate-pink',?)").run(r.user_id, Date.now());
                audit(db, null, 'local.recharge_policy', Number(r.user_id), 'Tách điểm QA phiếu hồng, giữ nguyên vật phẩm và lịch sử', { points: old }, { couponPoints: next._local_coupon_recharge_points, ticketPoints: 0 });
            }
            db.exec('COMMIT');
        }
        catch (e) {
            db.exec('ROLLBACK');
            throw e;
        }
    }
    info(s) { const p = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id)?.profile ?? '{}')); return { points: p._local_recharge_points ?? 0, legacyCouponPoints: p._local_coupon_recharge_points ?? 0, availableTickets: p.ticket ?? 0, conversion: 100, notice: 'Vé vàng chữ S dùng số dư ticket trên màn VIP, không phải phiếu hồng trong Túi đồ. LOCAL: 1 vé = 100 điểm mô phỏng (quy ước 10.000 VNĐ). Không tự cộng Xu, VIP EXP hoặc nhận quà.', tickets: [{ id: 'ticket', name: 'Vé vàng chữ S', icon: 'public_ticket.png', quantity: p.ticket ?? 0 }], history: this.db.prepare("SELECT request_key,created_at,result FROM player_content_operations WHERE user_id=? AND method='local.ticket_recharge' ORDER BY created_at DESC LIMIT 30").all(s.user_id).map(r => ({ requestId: r.request_key, createdAt: r.created_at, ...JSON.parse(String(r.result)).local_recharge })) }; }
    redeem(s, quantity, key) {
        const count = Number(quantity);
        if (!/^\d{1,4}$/.test(String(quantity)) || !Number.isSafeInteger(count) || count < 1 || count > 9999)
            fail('Số vé dùng phải từ1 đến9999.');
        return contentReceipt(this.db, s.user_id, 'local.ticket_recharge', key, { count }, () => {
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id);
            if (!row)
                fail('Tài khoản chưa vào game.');
            const p = JSON.parse(String(row.profile)), available = p.ticket ?? 0, before = p._local_recharge_points ?? 0, total = before + 100 * count;
            if (!Number.isSafeInteger(available) || available < count)
                fail('Không đủ vé vàng chữ S.');
            if (!Number.isSafeInteger(before) || before < 0 || !Number.isSafeInteger(total) || total > 1000000000)
                fail('Điểm mô phỏng vượt giới hạn local.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, ticket: available - count, _local_recharge_points: total }), s.user_id);
            audit(this.db, null, 'local.ticket_recharge', s.user_id, 'Dùng vé chữ S theo quy tắc LOCAL; không thanh toán thật', { points: before, ticket: available }, { points: total, ticket: available - count, consumed: count });
            return { local_recharge: { points: total, added: 100 * count, consumed: count }, ticket: available - count };
        }, () => { const current = this.info(s); return { replayed: true, local_recharge: { points: current.points, added: 0, consumed: 0 }, ticket: current.availableTickets }; });
    }
}
