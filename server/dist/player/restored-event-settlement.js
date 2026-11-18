import { createHash } from 'node:crypto';
import { audit } from '../admin/admin.audit.js';
/** Quy tắc chủ dự án duyệt: hết lịch, khoản/nhiệm vụ đến hạn gửi qua Thư.
 * Không trả lãi sớm, không tự nhận Thư, không tiêu/đổi tướng hay sửa lịch cũ.
 */
export class RestoredEventSettlement {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    deliver(user) {
        const at = this.now();
        let sent = 0;
        this.db.exec('SAVEPOINT restored_delivery');
        try {
            const rows = this.db.prepare("SELECT * FROM restored_event_runs WHERE CAST(json_extract(snapshot,'$.ends') AS INTEGER)<=? AND json_extract(state,'$.settledAt') IS NULL AND COALESCE(json_extract(state,'$.settleAfter'),0)<=?" + (user === undefined ? '' : ' AND user_id=?') + ' ORDER BY updated_at LIMIT 100').all(...(user === undefined ? [at, at] : [at, at, user]));
            for (const row of rows) {
                const c = JSON.parse(String(row.snapshot)), t = JSON.parse(String(row.state));
                let next = Infinity, changed = false;
                const mail = (slot, rewards, description) => {
                    const key = createHash('sha256').update(row.kind + ':' + row.occurrence_id + ':' + slot).digest('hex'), id = 'restored-' + key;
                    // Mail và trạng thái quyết toán cùng transaction, retry/restart không gửi lại.
                    this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(row.user_id, id, description + '\nTất toán sau khi kết thúc lịch · LOCAL', JSON.stringify(rewards));
                    this.db.prepare('INSERT INTO restored_event_ops VALUES(?,?,?,?,?,?,?,?)').run(row.user_id, 'auto-mail-' + key, key, row.occurrence_id, row.kind, 'settlement_mail', JSON.stringify({ mailId: id, reward: rewards, slot }), at);
                    audit(this.db, null, 'restored.settlement.mail', Number(row.user_id), description, null, { mailId: id, occurrence: row.occurrence_id, rewards, slot });
                    t.mailReceipts ??= [];
                    t.mailReceipts.push({ mailId: id, slot, rewards, at });
                    sent++;
                    changed = true;
                };
                if (row.kind === 'investment') {
                    for (const [slot, v] of Object.entries(t.investments)) {
                        if (!v.time_long || v.flag)
                            continue;
                        if (v.end > at) {
                            next = Math.min(next, v.end);
                            continue;
                        }
                        const amount = v.coin + v.profit;
                        mail('investment-' + slot, [[9, 0, amount]], 'Cổ Linh Các · vốn và lãi lượt ' + slot);
                        v.flag = 1;
                        v.paid = amount;
                    }
                    const total = Number(this.db.prepare("SELECT COALESCE(sum(CAST(json_extract(state,'$.total') AS INTEGER)),0) n FROM restored_event_runs WHERE occurrence_id=? AND kind='investment'").get(row.occurrence_id).n);
                    if (t.used && !t.big && total >= c.rule.max_coin) {
                        mail('global', c.rule.charge_reward, 'Cổ Linh Các · quà mốc toàn server');
                        t.big = true;
                    }
                }
                else {
                    for (const [id, v] of Object.entries(t.tasks)) {
                        if (v.status !== 1)
                            continue;
                        if (v.end > at) {
                            next = Math.min(next, v.end);
                            continue;
                        }
                        mail('task-' + id, c.tasks[id]['reward_' + v.level], 'Xuất Chinh · ' + c.tasks[id].name + ' · ' + v.level.toUpperCase());
                        t.score += c.rule['score_' + v.level];
                        t.scoreAt = at;
                        delete t.tasks[id];
                    }
                }
                if (Number.isFinite(next))
                    t.settleAfter = next;
                else
                    t.settledAt = at;
                this.db.prepare('UPDATE restored_event_runs SET state=?,revision=revision+?,updated_at=? WHERE user_id=? AND occurrence_id=? AND kind=?').run(JSON.stringify(t), changed ? 1 : 0, at, row.user_id, row.occurrence_id, row.kind);
            }
            this.db.exec('RELEASE restored_delivery');
            return { sent };
        }
        catch (e) {
            this.db.exec('ROLLBACK TO restored_delivery;RELEASE restored_delivery');
            throw e;
        }
    }
}
