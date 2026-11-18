import { InviteRewards } from './invite-rewards.js';
import { randomInt, createHash } from 'node:crypto';
import { presentationSource, presentationFail as fail } from './client-presentation.js';
import { rewardProblem } from './hot-campaigns.js';
import { contentReceipt } from './content-receipt.js';
import { audit } from '../admin/admin.audit.js';
const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
export class InviteCodeService {
    db;
    now;
    rng;
    constructor(db, now = Date.now, rng = randomInt) {
        this.db = db;
        this.now = now;
        this.rng = rng;
    }
    rules() { return presentationSource('inviter_open')['1']; }
    code(user) {
        const old = this.db.prepare('SELECT code FROM invite_codes WHERE user_id=?').get(user);
        if (old)
            return String(old.code);
        for (let attempt = 0; attempt < 64; attempt++) {
            let value = '';
            for (let i = 0; i < 6; i++) {
                const n = this.rng(alphabet.length);
                if (!Number.isInteger(n) || n < 0 || n >= alphabet.length)
                    throw Error('RNG mã mời ngoài miền.');
                value += alphabet[n];
            }
            if (!/[A-Z]/.test(value) || !/[0-9]/.test(value))
                continue;
            if (this.db.prepare('INSERT OR IGNORE INTO invite_codes VALUES(?,?,?)').run(user, value, this.now()).changes)
                return value;
        }
        return fail('Chưa tạo được mã duy nhất, vui lòng thử lại.');
    }
    profile(user) { const r = this.db.prepare("SELECT p.game_uid,p.role,p.created_at,json_extract(s.profile,'$.show_name') name,COALESCE(json_extract(s.profile,'$.level'),1) level,COALESCE(json_extract(s.profile,'$.vip'),0) vip FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?").get(user); if (!r)
        fail('Nhân vật chưa vào game.'); return r; }
    queue(recipient, invitee, key, rewards, content, configRevision = 0) {
        if (this.db.prepare('SELECT 1 FROM invite_reward_mails WHERE recipient_id=? AND invitee_id=? AND reward_key=?').get(recipient, invitee, key))
            return;
        const error = rewardProblem(rewards);
        if (error)
            fail('Quà Mã mời chưa đủ nguồn: ' + error);
        const id = `localinvite-${invitee}-${key}`;
        this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(recipient, id, content, JSON.stringify(rewards));
        this.db.prepare('INSERT INTO invite_reward_mails VALUES(?,?,?,?,?,?)').run(recipient, invitee, key, id, JSON.stringify(rewards), this.now());
        audit(this.db, null, 'invite.reward.mail', recipient, 'Gửi quà Mã mời qua Thư, không tự nhận', null, { invitee, key, mailId: id, rewards, configRevision });
    }
    syncVip(user) {
        if (!this.db.prepare('SELECT 1 FROM invite_bindings WHERE invitee_id=? OR inviter_id=? LIMIT 1').get(user, user))
            return;
        this.db.exec('SAVEPOINT invite_vip');
        try {
            const rows = this.db.prepare('SELECT invitee_id,inviter_id FROM invite_bindings WHERE invitee_id=? OR inviter_id=?').all(user, user), rewards = new InviteRewards(this.db).configs(), tiers = Object.entries(rewards.reward_list).filter(([, r]) => r.sort === 2 && r.target1 === 1);
            for (const row of rows) {
                const p = this.profile(Number(row.invitee_id));
                for (const [key, t] of tiers)
                    if (Number(p.vip) >= t.target2)
                        this.queue(Number(row.inviter_id), Number(row.invitee_id), 'vip-' + key, t.reward, 'Quà Mã mời · VIP ' + t.target2 + '\n' + t.advertext.replace('%s', '1').replace('%s', String(t.target2)), rewards.revision);
            }
            this.db.exec('RELEASE invite_vip');
        }
        catch (e) {
            this.db.exec('ROLLBACK TO invite_vip;RELEASE invite_vip');
            throw e;
        }
    }
    state(s) { const p = this.profile(s.user_id), binding = this.db.prepare('SELECT code FROM invite_bindings b JOIN invite_codes c ON c.user_id=b.inviter_id WHERE b.invitee_id=?').get(s.user_id), r = this.rules(), rewards = new InviteRewards(this.db).configs(); return { invite_reward_revision: rewards.revision, invite_configs: { inviter_open: rewards.inviter_open, reward_list: rewards.reward_list }, invitecode: this.code(s.user_id), regist_time: Math.floor(Number(p.created_at) / 1000), acc_invitecode: binding?.code ?? '', can_bind: !binding && Number(p.level) < r.level && this.now() < Number(p.created_at) + r.lifetime * 3600000, invite_count: Number(this.db.prepare('SELECT count(*) n FROM invite_bindings WHERE inviter_id=?').get(s.user_id).n), local_notice: 'Mã6ký tự chữ hoa+số. Nhập mã một lần khi dưới cấp' + r.level + ', trong' + r.lifetime + 'giờ từ tạo nhân vật; quà gửi qua Thư. Giới hạn thiết bị LOCAL theo ID cài đặt, không phải xác thực phần cứng.' }; }
    index(s) { this.db.exec('SAVEPOINT invite_index'); try {
        this.syncVip(s.user_id);
        const result = this.state(s);
        this.db.exec('RELEASE invite_index');
        return result;
    }
    catch (e) {
        this.db.exec('ROLLBACK TO invite_index;RELEASE invite_index');
        throw e;
    } }
    bind(s, q) {
        const code = (q.get('invitecode') ?? '').trim().toUpperCase(), device = q.get('invite_device') ?? '';
        if (!/^[A-Z0-9]{6}$/.test(code) || !/[A-Z]/.test(code) || !/[0-9]/.test(code))
            fail('Mã mời gồm6ký tự chữ và số.');
        if (!/^[A-Za-z0-9-]{24,100}$/.test(device))
            fail('Cần APK LOCAL mới để xác nhận thiết bị Mã mời.');
        const hash = createHash('sha256').update(device).digest('hex');
        return contentReceipt(this.db, s.user_id, 'invite_code.bind', q.get('request_id'), { code, deviceHash: hash, ...(q.has('invite_reward_revision') ? { rewardRevision: q.get('invite_reward_revision') } : {}) }, () => {
            const old = this.db.prepare('SELECT inviter_id FROM invite_bindings WHERE invitee_id=?').get(s.user_id), owner = this.db.prepare('SELECT user_id FROM invite_codes WHERE code=?').get(code);
            if (old) {
                if (owner?.user_id !== old.inviter_id)
                    fail('Tài khoản đã nhập một Mã mời khác.');
                return { ...this.state(s), replayed: true };
            }
            const rewards = new InviteRewards(this.db).settings();
            if (rewards.revision > 0 || q.has('invite_reward_revision')) {
                if (q.get('invite_schema') !== '2')
                    fail('Cần APK LOCAL v6 để đồng bộ quà Mã mời đã tùy chỉnh.');
                if (q.get('invite_reward_revision') !== String(rewards.revision))
                    fail('Quà Mã mời đã đổi; hãy đóng/mở lại Mã mời trước khi nhập.');
            }
            if (!owner)
                fail('Mã mời không tồn tại trên máy chủ LOCAL này.');
            if (owner.user_id === s.user_id)
                fail('Không thể nhập mã của chính mình.');
            const p = this.profile(s.user_id), r = this.rules();
            if (Number(p.level) >= r.level || this.now() >= Number(p.created_at) + r.lifetime * 3600000)
                fail('Nhân vật không đạt điều kiện HĐ Mời: dưới cấp' + r.level + ' và trong' + r.lifetime + 'giờ.');
            if (this.db.prepare('SELECT 1 FROM invite_bindings WHERE device_hash=?').get(hash))
                fail('Thiết bị LOCAL này đã nhận quà Mã mời.');
            let ancestor = Number(owner.user_id);
            const seen = new Set();
            while (ancestor) {
                if (ancestor === s.user_id || seen.has(ancestor))
                    fail('Không tạo vòng mời qua lại.');
                seen.add(ancestor);
                const row = this.db.prepare('SELECT inviter_id FROM invite_bindings WHERE invitee_id=?').get(ancestor);
                ancestor = Number(row?.inviter_id ?? 0);
            }
            this.db.prepare('INSERT INTO invite_bindings VALUES(?,?,?,?)').run(s.user_id, owner.user_id, hash, this.now());
            const inviter = this.profile(Number(owner.user_id));
            this.queue(s.user_id, s.user_id, 'newcomer', rewards.definition.newcomer, 'Quà Khởi Hành · Mã mời\n' + r.des1.replace('%s', String(inviter.name ?? inviter.game_uid)), rewards.revision);
            const count = Number(this.db.prepare('SELECT count(*) n FROM invite_bindings WHERE inviter_id=?').get(owner.user_id).n);
            if (count <= r.maxtimes2)
                this.queue(Number(owner.user_id), s.user_id, 'base', rewards.definition.inviter, 'Quà mời người chơi mới\n' + r.des2.replace('%s', String(p.name ?? p.game_uid)), rewards.revision);
            this.syncVip(s.user_id);
            audit(this.db, null, 'invite.bind', s.user_id, 'Gắn Mã mời LOCAL; quà trong Thư', null, { inviter: Number(owner.user_id), code });
            return this.state(s);
        }, () => ({ ...this.state(s), replayed: true }));
    }
    admin(q = {}) { const page = Math.max(1, Math.min(10000, Math.floor(Number(q.page) || 1))), term = '%' + String(q.q ?? '').slice(0, 80) + '%', where = " WHERE (u.username LIKE ? OR c.code LIKE ? OR json_extract(s.profile,'$.show_name') LIKE ?)", from = ' FROM invite_codes c JOIN users u ON u.id=c.user_id JOIN player_state s ON s.user_id=c.user_id'; return { page, total: this.db.prepare('SELECT count(*) n' + from + where).get(term, term, term).n, items: this.db.prepare("SELECT u.id,u.username,c.code,json_extract(s.profile,'$.show_name') name,(SELECT count(*) FROM invite_bindings b WHERE b.inviter_id=u.id) invited,(SELECT count(*) FROM invite_reward_mails m WHERE m.recipient_id=u.id) reward_mails" + from + where + ' ORDER BY u.id LIMIT 30 OFFSET ?').all(term, term, term, (page - 1) * 30), rules: new InviteRewards(this.db).configs().inviter_open['1'], milestones: new InviteRewards(this.db).configs().reward_list, notice: 'Đối chiếu inviter_open:148giờ (khác câu mô tả1tuần), cấp dưới100, nhận một lần/tài khoản và ID cài đặt LOCAL; thưởng mời thường tối đa10, mốc VIP theo từng người được mời và từng mốc, không giới hạn tổng số người.' }; }
}
