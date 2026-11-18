import { ClientPresentation, presentationSource, presentationFail as fail } from './client-presentation.js';
import { readConfigSync } from './local-content.js';
import { rewardProblem } from './hot-campaigns.js';
import { audit } from '../admin/admin.audit.js';
// Namespace riêng trong JSON cấu hình hiện có; revision quà độc lập với màn tải/Discord.
export class InviteRewards {
    db;
    constructor(db) {
        this.db = db;
    }
    defaults() { const rules = presentationSource('inviter_open')['1'], tiers = presentationSource('reward_list'); return structuredClone({ newcomer: rules.reward1, inviter: rules.reward2, vip: Object.fromEntries(Object.values(tiers).filter(r => r.sort === 2).map(r => [r.target2, r.reward])) }); }
    settings() { const row = this.db.prepare('SELECT definition FROM client_presentation_settings WHERE id=1').get(), stored = row ? JSON.parse(String(row.definition)).inviteRewards : null; return stored ? { revision: stored.revision, definition: stored.definition } : { revision: 0, definition: this.defaults() }; }
    validate(d) {
        if (!d || !d.vip || typeof d.vip !== 'object' || Array.isArray(d.vip) || Object.keys(d).some(k => !['newcomer', 'inviter', 'vip'].includes(k)) || Object.keys(d.vip).length !== 15 || Array.from({ length: 15 }, (_, i) => String(i + 1)).some(k => !Object.hasOwn(d.vip, k)))
            fail('Cần đủ quà Khởi Hành, người mời và 15 mốc VIP nguồn.');
        for (const [label, rows] of [['Khởi Hành', d.newcomer], ['Người mời', d.inviter], ...Object.entries(d.vip).map(([k, v]) => ['VIP ' + k, v])]) {
            const problem = rewardProblem(rows);
            if (problem)
                fail(label + ': ' + problem);
            const totals = new Map();
            for (const [type, id, count] of rows)
                if (type === 6)
                    totals.set(id, (totals.get(id) ?? 0) + count);
            for (const [id, count] of totals) {
                const item = readConfigSync('item')[id];
                if (count > item.stack)
                    fail(label + ': tổng vật phẩm #' + id + ' vượt stack nguồn ' + item.stack + '.');
            }
        }
        return structuredClone({ newcomer: d.newcomer, inviter: d.inviter, vip: d.vip });
    }
    save(admin, revision, raw) {
        const definition = this.validate(raw);
        if (!Number.isSafeInteger(revision) || revision < 0)
            fail('Revision quà không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.settings();
            if (old.revision !== revision)
                fail('Quà Mã mời đã được người khác sửa; tải lại trước khi lưu.');
            const row = this.db.prepare('SELECT definition FROM client_presentation_settings WHERE id=1').get(), presentation = row ? JSON.parse(String(row.definition)) : new ClientPresentation(this.db).settings().definition, next = { revision: revision + 1, definition };
            presentation.inviteRewards = next;
            if (row)
                this.db.prepare('UPDATE client_presentation_settings SET definition=?,updated_at=? WHERE id=1').run(JSON.stringify(presentation), Date.now());
            else
                this.db.prepare('INSERT INTO client_presentation_settings VALUES(1,0,?,?)').run(JSON.stringify(presentation), Date.now());
            audit(this.db, admin, 'invite.rewards.save', null, 'Đổi quà Mã mời cho lần gửi tiếp theo; giữ thư/claim cũ', old, next);
            this.db.exec('COMMIT');
            return next;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    configs() { const s = this.settings(), rules = structuredClone(presentationSource('inviter_open')), tiers = structuredClone(presentationSource('reward_list')); rules['1'].reward1 = s.definition.newcomer; rules['1'].reward2 = s.definition.inviter; for (const r of Object.values(tiers))
        r.reward = r.sort === 1 ? s.definition.inviter : s.definition.vip[String(r.target2)]; return { revision: s.revision, inviter_open: rules, reward_list: tiers }; }
    admin() { return { ...this.settings(), defaults: this.defaults(), notice: 'Lưu chỉ thay quà cho lần gửi thưởng tiếp theo. Thư đã gửi, quà đã nhận và mốc đã gửi không bị sửa/cấp lại. Điều kiện 148 giờ/cấp 100/10 lần và mã cá nhân giữ nguyên. Sau tùy chỉnh cần APK LOCAL v6 để xem đúng quà trong game.' }; }
}
