import { randomUUID, randomBytes } from 'node:crypto';
import { contentReceipt } from './content-receipt.js';
import { CombatPowerService } from './combat-power.js';
import { ArenaCombatService } from './arena-combat.js';
import { simulateBattle } from './local-combat.js';
import { audit } from '../admin/admin.audit.js';
const fail = (m) => { throw Object.assign(Error(m), { statusCode: 422 }); };
export class FriendsService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    target(value) { const text = String(value ?? '').trim(); if (!/^(local_player_[1-9]\d*|[1-9]\d{0,9})$/.test(text))
        fail('UID người chơi không hợp lệ.'); const row = this.db.prepare('SELECT p.user_id,p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.game_uid=?').get(text.startsWith('local_player_') ? text : 'local_player_' + text); if (!row)
        fail('Không tìm thấy UID người chơi.'); return row; }
    relation(a, b) { return this.db.prepare('SELECT 1 FROM friendships WHERE low_id=? AND high_id=?').get(Math.min(a, b), Math.max(a, b)); }
    count(uid) { return Number(this.db.prepare('SELECT COUNT(*) n FROM friendships WHERE low_id=? OR high_id=?').get(uid, uid).n); }
    limit(uid) { const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid); if (!row)
        fail('Người chơi chưa tạo nhân vật.'); const vip = Number(JSON.parse(String(row.profile)).vip ?? 0); if (!Number.isSafeInteger(vip) || vip < 0 || vip > 100)
        fail('VIP đã lưu không hợp lệ.'); return 50 + 5 * vip; }
    room(a, b) { for (const id of [a, b])
        if (this.count(id) >= this.limit(id))
            fail('Danh sách bạn bè của một bên đã đầy.'); }
    publicUser(uid) { const row = this.db.prepare('SELECT p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?').get(uid); if (!row)
        fail('Người chơi chưa tạo nhân vật.'); const p = JSON.parse(String(row.profile)); return { uid: String(row.game_uid), name: p.show_name ?? '', role: String(row.role), level: p.level ?? 1, combat: new CombatPowerService(this.db).calculate(uid).combat, association_name: '', association_id: 0, online: !!this.db.prepare('SELECT 1 FROM sessions WHERE user_id=? AND expires_at>? LIMIT 1').get(uid, this.now()), has_send_gift: false }; }
    list(uid) { const rows = this.db.prepare('SELECT CASE WHEN low_id=? THEN high_id ELSE low_id END other FROM friendships WHERE low_id=? OR high_id=? ORDER BY created_at,other').all(uid, uid, uid); return { friend_top: this.limit(uid), friend_len: rows.length, accept_action_point: 0, accept_action_point_top: 0, friends: rows.map(r => this.publicUser(Number(r.other))) }; }
    messages(uid) { return { ...this.list(uid), messages: this.db.prepare("SELECT id,sender_id,created_at FROM friend_requests WHERE recipient_id=? AND status='PENDING' ORDER BY created_at,id").all(uid).map(r => { const u = this.publicUser(Number(r.sender_id)); return { id: r.id, sort: 'add_friend', send_uid: u.uid, send_name: u.name, send_role: u.role, send_level: u.level, send_combat: u.combat, send_association_name: '', time: Math.floor(Number(r.created_at) / 1000) }; }) }; }
    search(uid, value) { const target = this.target(value), other = Number(target.user_id); return { ...this.list(uid), user: [{ ...this.publicUser(other), is_friend: !!this.relation(uid, other), is_self: uid === other, pending: !!this.db.prepare("SELECT 1 FROM friend_requests WHERE status='PENDING' AND ((sender_id=? AND recipient_id=?) OR (sender_id=? AND recipient_id=?))").get(uid, other, other, uid) }] }; }
    diagnostics(uid) { return { ...this.messages(uid), uid: this.publicUser(uid).uid, capacitySource: 'Chủ dự án xác nhận: 50 + 5 × VIP', onlineEvidence: 'Có phiên đăng nhập chưa hết hạn; không khẳng định kết nối thời gian thực.', outgoing: this.db.prepare('SELECT id,recipient_id,status,created_at,updated_at FROM friend_requests WHERE sender_id=? ORDER BY created_at DESC LIMIT 100').all(uid).map(r => ({ ...r, target: this.publicUser(Number(r.recipient_id)) })), battles: this.db.prepare("SELECT request_key,json_extract(result,'$.diagnostics') result,created_at FROM player_content_operations WHERE user_id=? AND method='friend.battle' ORDER BY created_at DESC LIMIT 30").all(uid).map(r => ({ ...r, result: JSON.parse(String(r.result)) })), blocked: ['Tặng thể lực: chưa có lượng quà/giới hạn nhận trong nguồn; chưa trừ/cấp thể lực.'] }; }
    execute(s, method, p) {
        const fields = [...p].filter(([k]) => !['request_id', 'rans', 'user_token', 'mk', 'method'].includes(k)).sort(([a], [b]) => a.localeCompare(b));
        return contentReceipt(this.db, s.user_id, method, p.get('request_id'), fields, () => {
            let result;
            if (method === 'friend.apply_friend') {
                const other = Number(this.target(p.get('target_id')).user_id);
                if (other === s.user_id)
                    fail('Không thể kết bạn với chính mình.');
                if (this.relation(s.user_id, other))
                    fail('Hai người đã là bạn bè.');
                this.room(s.user_id, other);
                if (this.db.prepare("SELECT 1 FROM friend_requests WHERE status='PENDING' AND ((sender_id=? AND recipient_id=?) OR (sender_id=? AND recipient_id=?))").get(s.user_id, other, other, s.user_id))
                    fail('Đã có lời mời giữa hai người; kiểm tra mục Thông Tin.');
                if (Number(this.db.prepare('SELECT COUNT(*) n FROM friend_requests WHERE sender_id=? AND created_at>?').get(s.user_id, this.now() - 60000).n) >= 20)
                    fail('Gửi lời mời quá nhanh; hãy đợi một phút.');
                const id = 'friend-' + randomUUID();
                this.db.prepare("INSERT INTO friend_requests VALUES(?,?,?,'PENDING',?,?)").run(id, s.user_id, other, this.now(), this.now());
                result = { ...this.messages(s.user_id), request_id: id };
            }
            else if (method === 'friend.read_message') {
                if (p.has('accept_all'))
                    fail('Nhận nhanh chỉ dành cho quà thể lực; chưa có công thức quà được xác minh.');
                const row = this.db.prepare('SELECT * FROM friend_requests WHERE id=? AND recipient_id=?').get(p.get('message_id') ?? '', s.user_id);
                if (!row)
                    fail('Lời mời không thuộc tài khoản.');
                if (row.status !== 'PENDING')
                    fail('Lời mời đã được xử lý.');
                const agree = p.get('agree_friend') ?? '0';
                if (!['0', '1'].includes(agree))
                    fail('Lựa chọn đồng ý/từ chối không hợp lệ.');
                if (agree === '1') {
                    this.room(Number(row.sender_id), s.user_id);
                    this.db.prepare('INSERT INTO friendships VALUES(?,?,?)').run(Math.min(s.user_id, Number(row.sender_id)), Math.max(s.user_id, Number(row.sender_id)), this.now());
                }
                this.db.prepare('UPDATE friend_requests SET status=?,updated_at=? WHERE id=?').run(agree === '1' ? 'ACCEPTED' : 'REJECTED', this.now(), row.id);
                result = { ...this.messages(s.user_id), reward: [] };
            }
            else if (method === 'friend.remove_friend') {
                const other = Number(this.target(p.get('target_id')).user_id);
                if (!this.relation(s.user_id, other))
                    fail('Người chơi không nằm trong danh sách bạn.');
                this.db.prepare('DELETE FROM friendships WHERE low_id=? AND high_id=?').run(Math.min(s.user_id, other), Math.max(s.user_id, other));
                result = this.messages(s.user_id);
            }
            else if (method === 'friend.battle') {
                const other = Number(this.target(p.get('target_id')).user_id);
                if (other === s.user_id || !this.relation(s.user_id, other))
                    fail('Chỉ có thể tỉ thí với bạn bè đã chấp nhận.');
                const combat = new ArenaCombatService(this.db), a = combat.team(s.user_id, 0), d = combat.team(other, 100), sim = simulateBattle([...a.entities, ...d.entities], randomBytes(4).readUInt32LE()), ap = this.publicUser(s.user_id), dp = this.publicUser(other);
                result = { battle: { ...sim.battle, fight_user: true, init: { ...sim.battle.init, aform: a.cards.formation.current, dform: d.cards.formation.current, atk_name: ap.name, dfd_name: dp.name, atk_lv: ap.level, dfd_lv: dp.level, atk_role: ap.role, dfd_role: dp.role, equip_att: a.cards.equip, equip_def: d.cards.equip, equip_pos_att: a.cards.equip_pos, equip_pos_def: d.cards.equip_pos } }, reward: {}, rewards: {}, battle_rewards: { reward_exp_player: [], reward_exp_character: {}, reward_character: {}, reward_item: {} }, friendly: true, diagnostics: { winner: sim.winner, rounds: sim.rounds, attacker: s.game_uid, defender: dp.uid, skillDiagnostics: sim.diagnostics, beastDiagnostics: sim.beastDiagnostics, lifeEvents: sim.lifeEvents } };
            }
            else
                fail('Chức năng bạn bè này chưa có quy tắc nguồn đầy đủ; chưa thay đổi dữ liệu.');
            audit(this.db, null, method, s.user_id, 'Bạn Bè: transaction, UID thật; tỉ thí không đổi Arena/thưởng', null, { requestKey: p.get('request_id'), target: p.get('target_id'), message: p.get('message_id') });
            return result;
        }, old => method === 'friend.battle' ? { ...old, replayed: true } : { ...this.messages(s.user_id), replayed: true });
    }
}
