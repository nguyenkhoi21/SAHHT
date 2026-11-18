import { NewstarConfig } from './newstar-config.js';
import { staticConfig } from './player.service.js';
import { WelfareService, serverDay } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
const eventId = 'newstar:300', version = 300;
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
// Adapter LOCAL có ghi nguồn: bảy ngày tính từ lần tham gia đầu trong lịch GM.
// Bộ đếm LOCAL lấy giao dịch đã lưu kể từ lúc tham gia, không tính GM/replay.
export class NewstarService {
    db;
    now;
    serverNumber;
    constructor(db, now = Date.now, serverNumber = Number(process.env.GAME_SERVER_NUMBER ?? 1)) {
        this.db = db;
        this.now = now;
        this.serverNumber = serverNumber;
        if (!Number.isSafeInteger(serverNumber) || serverNumber < 1)
            throw Error('GAME_SERVER_NUMBER phải là số server nguyên dương.');
    }
    scope() { const row = this.db.prepare('SELECT * FROM newstar_server_scope WHERE id=1').get(); return { serverFrom: row ? Number(row.server_from) : null, serverTo: row ? Number(row.server_to) : null, currentServer: this.serverNumber, realm: 'local-1', allowed: !row || (this.serverNumber >= Number(row.server_from) && this.serverNumber <= Number(row.server_to)) }; }
    setScope(adminId, b) {
        if (b.confirmed !== true || !Number.isSafeInteger(b.serverFrom) || !Number.isSafeInteger(b.serverTo) || b.serverFrom < 1 || b.serverTo < b.serverFrom || b.serverTo > 1000000)
            fail('Khoảng server phải từ1 đến1.000.000 và server cuối không nhỏ hơn server đầu.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const before = this.scope();
            this.db.prepare('INSERT INTO newstar_server_scope VALUES(1,?,?,?) ON CONFLICT(id) DO UPDATE SET server_from=excluded.server_from,server_to=excluded.server_to,updated_at=excluded.updated_at').run(b.serverFrom, b.serverTo, this.now());
            audit(this.db, adminId, 'event.newstar.scope', null, 'Giới hạn server Tân Tinh; không reset tiến độ', before, this.scope());
            this.db.exec('COMMIT');
            return this.scope();
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    settings() { return this.db.prepare('SELECT * FROM local_activity_settings WHERE activity_id=?').get(eventId); }
    available() { const s = this.settings(), now = this.now(); return !!s && s.enabled === 1 && now >= s.starts_at && now < s.ends_at && this.scope().allowed; }
    profile(s) { const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id); if (!row)
        return fail('Tài khoản chưa vào game.'); return JSON.parse(row.profile); }
    joined(s) { return this.db.prepare("SELECT claimed_at FROM player_claims WHERE user_id=? AND system='newstar_join' AND period='300' AND claim_key='joined'").get(s.user_id); }
    done(s, system) { return this.db.prepare('SELECT claim_key FROM player_claims WHERE user_id=? AND system=? AND period=? ORDER BY CAST(claim_key AS INTEGER)').all(s.user_id, system, String(version)).map(r => Number(r.claim_key)); }
    progress(s, sort) {
        if (sort === 1)
            return this.profile(s).level ?? 1;
        const joined = this.joined(s);
        if (!joined)
            return 0;
        const joinAudit = this.db.prepare("SELECT id,after_state FROM admin_audit WHERE target_user_id=? AND action='event.newstar.join' ORDER BY id LIMIT 1").get(s.user_id);
        const cursors = joinAudit ? JSON.parse(String(joinAudit.after_state)).cursors ?? {} : {};
        const args = [s.user_id, joined.claimed_at, this.now()];
        if (sort === 38)
            return Number(this.db.prepare("SELECT COUNT(*) n FROM arena_operations WHERE user_id=? AND created_at>=? AND created_at<=? AND rowid>? AND kind='battle' AND state='SETTLED'").get(...args, Number(cursors.arena ?? 0)).n);
        if (sort === 78)
            return Number(this.db.prepare('SELECT COUNT(*) n FROM local_battles WHERE user_id=? AND created_at>=? AND created_at<=? AND rowid>?').get(...args, Number(cursors.pve ?? 0)).n);
        if (sort === 35)
            return Number(this.db.prepare("SELECT COUNT(*) n FROM admin_audit WHERE target_user_id=? AND created_at>=? AND created_at<=? AND id>? AND admin_id IS NULL AND action='factory.equip_levelup'").get(...args, Number(joinAudit?.id ?? 0)).n);
        if (sort === 81) {
            const rows = this.db.prepare("SELECT before_state,after_state FROM admin_audit WHERE target_user_id=? AND created_at>=? AND created_at<=? AND id>? AND admin_id IS NULL AND action IN('shop.buy.item','shop.buy.metal')").all(...args, Number(joinAudit?.id ?? 0));
            return rows.reduce((total, r) => { const before = JSON.parse(String(r.before_state)), after = JSON.parse(String(r.after_state)); return total + Math.max(0, Number(after.bought ?? 0) - Number(before.bought ?? 0)); }, 0);
        }
        return 0;
    }
    async state(s, join = false) {
        if (!this.available())
            fail('Tân Tinh đang tắt, ngoài lịch hoặc server không thuộc phạm vi được mở.');
        this.profile(s);
        const configService = new NewstarConfig(this.db, this.now), config = await configService.current();
        if (join && !this.joined(s)) {
            this.db.exec('BEGIN IMMEDIATE');
            try {
                if (!this.available())
                    fail('Lịch sự kiện đã thay đổi.');
                const inserted = this.db.prepare("INSERT OR IGNORE INTO player_claims VALUES(?,'newstar_join','300','joined',?)").run(s.user_id, this.now());
                configService.captureSync(s.user_id, config.id, config.definition);
                if (inserted.changes)
                    audit(this.db, null, 'event.newstar.join', s.user_id, 'Tham gia Tân Tinh LOCAL', null, { version, cursors: { arena: Number(this.db.prepare('SELECT COALESCE(MAX(rowid),0) n FROM arena_operations').get().n), pve: Number(this.db.prepare('SELECT COALESCE(MAX(rowid),0) n FROM local_battles').get().n) } });
                this.db.exec('COMMIT');
            }
            catch (e) {
                this.db.exec('ROLLBACK');
                throw e;
            }
        }
        const joined = this.joined(s), days = joined ? Math.min(7, Math.floor((Date.parse(serverDay(this.now())) - Date.parse(serverDay(joined.claimed_at))) / 86400000) + 1) : 0;
        const tasks = await staticConfig('newstar_mission');
        const definition = await configService.forUser(s.user_id, config);
        const daily = Object.fromEntries(definition.days.map((r) => [String(r.day), { id: r.day, day_id: r.day, version, reward: r.rewards }]));
        const missions = Object.fromEntries(Object.entries(tasks).filter(([, r]) => r.version === version).map(([id, r]) => [id, { ...r, id: Number(id), reward: definition.tasks.find((t) => t.id === Number(id))?.rewards ?? r.reward }]));
        return { reward_config_id: config.id, newstar_configs: { newstar_seven: daily, newstar_mission: missions }, is_new: true, version, days, sign_gift_done: this.done(s, 'newstar_sign'), tasks_done: this.done(s, 'newstar_task'), tasks_data: { result: Object.fromEntries(Object.entries(tasks).filter(([, r]) => r.version === version).map(([id, r]) => [id, [this.progress(s, r.target_sort), r.target_data[0], 0]])) }, invite_done: [], invite_uids: {}, caller: '', acc_caller: '', cost: 0, charge: 0, charge_done: [], local_notice: 'Lịch local: điểm danh, cấp độ, Arena, mua hàng, cường hóa và Thám Hiểm. Bộ đếm tính giao dịch thành công từ lúc tham gia; không tính GM/replay. Chưa hỗ trợ mời bạn/nạp tiền.' };
    }
    async claim(s, kind, value) {
        if (typeof value !== 'string' || !/^\d{1,3}$/.test(value))
            fail('Mã phần thưởng sự kiện không hợp lệ.');
        const id = Number(value), before = await this.state(s), table = await staticConfig(kind === 'sign' ? 'newstar_seven' : 'newstar_mission');
        const original = kind === 'sign' ? Object.values(table).find(r => r.version === version && r.day_id === id) : table[String(id)];
        const row = original ? structuredClone(original) : null;
        if (!row || row.version !== version)
            fail('Không có phần thưởng đúng phiên bản sự kiện.');
        if (kind === 'sign') {
            row.reward = before.newstar_configs.newstar_seven[String(id)]?.reward ?? row.reward;
        }
        if (kind === 'task')
            row.reward = before.newstar_configs.newstar_mission[String(id)]?.reward ?? row.reward;
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') };
        this.db.exec('BEGIN IMMEDIATE');
        let reward;
        try {
            const latest = this.db.prepare("SELECT id FROM newstar_reward_configs WHERE status='published' ORDER BY published_at DESC,id DESC LIMIT 1").get();
            if ((latest ? Number(latest.id) : null) !== before.reward_config_id)
                fail('Quà vừa được cập nhật; hãy mở lại Tân Tinh trước khi nhận.');
            if (!this.available() || !this.joined(s))
                fail('Chưa tham gia hoặc đã hết lịch sự kiện.');
            const done = this.done(s, 'newstar_' + kind);
            if (done.includes(id))
                fail('Phần thưởng sự kiện này đã nhận.');
            if (kind === 'sign' && (id < 1 || id > before.days))
                fail('Chưa tới ngày nhận phần thưởng này.');
            if (kind === 'task' && (![1, 35, 38, 78, 81].includes(row.target_sort) || this.progress(s, row.target_sort) < row.target_data[0]))
                fail('Nhiệm vụ chưa đủ điều kiện hoặc bộ đếm chưa được hỗ trợ.');
            reward = new WelfareService(this.db).applyInTransaction(s, row.reward, defs);
            this.db.prepare('INSERT INTO player_claims VALUES(?,?,?,?,?)').run(s.user_id, 'newstar_' + kind, String(version), String(id), this.now());
            const applied = { version, days: Object.values(before.newstar_configs.newstar_seven).map((r) => ({ day: r.day_id, rewards: r.reward })), tasks: Object.values(before.newstar_configs.newstar_mission).map((r) => ({ id: r.id, rewards: r.reward })) };
            new NewstarConfig(this.db, this.now).recordClaimSync(s.user_id, applied);
            audit(this.db, null, 'event.newstar.claim', s.user_id, 'Nhận thưởng Tân Tinh theo config Việt Nam', { kind, id }, { reward: row.reward, version });
            this.db.exec('COMMIT');
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
        return { ...await this.state(s), ...reward };
    }
    participants(missions) {
        return this.db.prepare("SELECT c.user_id,c.claimed_at,p.game_uid,p.role,u.username FROM player_claims c JOIN player_profiles p ON p.user_id=c.user_id JOIN users u ON u.id=c.user_id WHERE c.system='newstar_join' AND c.period='300' ORDER BY c.claimed_at DESC LIMIT 100").all().map(p => ({ ...p, signDays: this.done(p, 'newstar_sign'), availableDays: Math.min(7, Math.floor((Date.parse(serverDay(this.now())) - Date.parse(serverDay(Number(p.claimed_at)))) / 86400000) + 1), progress: Object.fromEntries(Object.entries(missions).filter(([, r]) => r.version === version).map(([id, r]) => [id, { description: r.des, current: this.progress(p, r.target_sort), required: r.target_data[0], claimed: this.done(p, 'newstar_task').includes(Number(id)) }])) }));
    }
    async info() {
        return { rewardConfig: await new NewstarConfig(this.db, this.now).list(), scope: this.scope(), id: eventId, name: 'Tân Tinh · thử nghiệm local', version, settings: this.settings() ?? { enabled: 0, starts_at: 0, ends_at: 1 }, source: await staticConfig('newstar_time'), daily: await staticConfig('newstar_seven'), missions: await staticConfig('newstar_mission'), supportedTaskSorts: [1, 35, 38, 78, 81], policy: 'Lịch GM riêng, mặc định tắt; ngày1–7 từ lần tham gia đầu, không reset khi đổi lịch. Nhiệm vụ LOCAL đếm trận Arena/PvE đã lưu, số món mua và giao dịch cường hóa thành công sau tham gia; không tính GM/replay. Mời bạn/nạp tiền chưa hỗ trợ.', participants: this.participants(await staticConfig('newstar_mission')), claims: this.db.prepare("SELECT user_id,system,claim_key,claimed_at FROM player_claims WHERE system IN('newstar_sign','newstar_task') AND period='300' ORDER BY claimed_at DESC LIMIT 100").all() };
    }
    schedule(adminId, body) {
        const start = Date.parse(body.startsAt), end = Date.parse(body.endsAt);
        if (typeof body.enabled !== 'boolean' || !Number.isSafeInteger(start) || !Number.isSafeInteger(end) || end <= start)
            fail('Lịch sự kiện không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const before = this.settings() ?? null;
            this.db.prepare('INSERT INTO local_activity_settings VALUES(?,?,?,?) ON CONFLICT(activity_id) DO UPDATE SET enabled=excluded.enabled,starts_at=excluded.starts_at,ends_at=excluded.ends_at').run(eventId, Number(body.enabled), start, end);
            audit(this.db, adminId, 'event.newstar.schedule', null, 'Đặt lịch Tân Tinh LOCAL; giữ claim', before, this.settings());
            this.db.exec('COMMIT');
            return { ok: true, settings: this.settings() };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
