import { hotFail } from './hot-source.js';
import { rewardProblem } from './hot-campaigns.js';
import { audit } from '../admin/admin.audit.js';
export class HotCards {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    settings() { return [1, 2].map(id => { const r = this.db.prepare('SELECT * FROM hot_card_settings WHERE package_id=?').get(id); return { packageId: id, revision: Number(r?.revision ?? 0), definition: r ? JSON.parse(String(r.definition)) : null, notice: id === 1 ? '20 ngày từ lúc mua; mỗi mốc24giờ gửi một thư, bù thư đã tới hạn khi vào game.' : 'Mua một lần gửi toàn bộ quà cấu hình vào Thư ngay.' }; }); }
    set(admin, id, revision, d) { if (![1, 2].includes(id) || !Array.isArray(d.rewards) || d.rewards.length !== (id === 1 ? 20 : 1))
        hotFail(id === 1 ? 'Thẻ tháng cần đúng20gói ngày.' : 'Thẻ tuần cần một gói toàn bộ.'); if (!Number.isSafeInteger(d.repeatAfterDays) || d.repeatAfterDays < (id === 1 ? 20 : 0) || d.repeatAfterDays > 366)
        hotFail('Số ngày trước lần mua lại không hợp lệ.'); for (const rewards of d.rewards) {
        const reason = rewardProblem(rewards);
        if (reason)
            hotFail(reason);
    } this.db.exec('SAVEPOINT hot_card_setting'); try {
        const old = this.db.prepare('SELECT * FROM hot_card_settings WHERE package_id=?').get(id);
        if (Number(old?.revision ?? 0) !== revision)
            hotFail('Cấu hình đã đổi.');
        this.db.prepare('INSERT INTO hot_card_settings VALUES(?,?,?) ON CONFLICT(package_id) DO UPDATE SET revision=excluded.revision,definition=excluded.definition').run(id, revision + 1, JSON.stringify({ rewards: d.rewards, days: id === 1 ? 20 : 1, repeatAfterDays: d.repeatAfterDays }));
        audit(this.db, admin, 'hot.card.settings', null, 'Chủ dự án xác nhận thời hạn; thưởng do AdminLOCAL cấu hình. Hợp đồng cũ giữ snapshot.', old, { id, revision: revision + 1, definition: d });
        this.db.exec('RELEASE hot_card_setting');
        return { packageId: id, revision: revision + 1 };
    }
    catch (e) {
        this.db.exec('ROLLBACK TO hot_card_setting;RELEASE hot_card_setting');
        throw e;
    } }
    available(user, id) { const setting = this.settings().find(s => s.packageId === id), active = this.db.prepare('SELECT id,ends_at FROM hot_card_contracts WHERE user_id=? AND package_id=? AND ends_at>?').get(user, id, this.now()); return { supported: !!setting?.definition && !active, blockedReason: !setting?.definition ? 'Admin chưa cấu hình phần thưởng thẻ.' : active ? 'Thẻ đang còn hiệu lực; chưa cho mua chồng thời hạn.' : '', setting: setting?.definition, active }; }
    purchase(user, id, transaction) { if (!this.db.isTransaction)
        throw Error('Kích hoạt thẻ cần transaction.'); const p = this.available(user, id); if (!p.supported)
        hotFail(p.blockedReason); const at = this.now(); this.db.prepare('INSERT INTO hot_card_contracts VALUES(?,?,?,?,?,?,?)').run(transaction, user, id, at, at + p.setting.repeatAfterDays * 86400000, JSON.stringify(p.setting), at); this.deliver(user); }
    deliver(user) { if (!this.db.prepare("SELECT 1 FROM sqlite_master WHERE name='hot_card_contracts'").get())
        return; this.db.exec('SAVEPOINT hot_card_delivery'); try {
        const at = this.now();
        for (const r of this.db.prepare('SELECT * FROM hot_card_contracts WHERE user_id=? AND starts_at<=?').all(user, at)) {
            const d = JSON.parse(String(r.definition)), count = r.package_id === 1 ? Math.min(20, Math.floor((at - Number(r.starts_at)) / 86400000) + 1) : 1;
            for (let day = 0; day < count; day++) {
                if (this.db.prepare('SELECT 1 FROM hot_card_deliveries WHERE contract_id=? AND day=?').get(r.id, day))
                    continue;
                const mailId = String(r.id) + '-day-' + day;
                this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(user, mailId, (r.package_id === 1 ? 'Thẻ tháng ngày' + (day + 1) + '/20' : 'Toàn bộ quà Thẻ tuần') + ' · LOCAL', JSON.stringify(d.rewards[day]));
                this.db.prepare('INSERT INTO hot_card_deliveries VALUES(?,?,?,?)').run(r.id, day, mailId, at);
                audit(this.db, null, 'hot.card.mail', user, 'Thư theo snapshot thẻ và thời điểm mua, không cộng trực tiếp', null, { contract: r.id, day, mailId });
            }
        }
        this.db.exec('RELEASE hot_card_delivery');
    }
    catch (e) {
        this.db.exec('ROLLBACK TO hot_card_delivery;RELEASE hot_card_delivery');
        throw e;
    } }
}
