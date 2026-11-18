import { randomInt, createHash } from 'node:crypto';
import { EventPlanner, eventFail } from './event-planner.js';
import { skyRows, eventSource } from './event-source.js';
import { audit } from '../admin/admin.audit.js';
// LOCAL đã được chủ dự án duyệt: chọn khoảng theo tỷ trọng nguồn, số nguyên đều trong khoảng.
export class SkyStarService {
    db;
    now;
    roll;
    constructor(db, now = Date.now, roll = (max) => randomInt(max)) {
        this.db = db;
        this.now = now;
        this.roll = roll;
    }
    profile(s) { const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id); if (!row)
        eventFail('Tài khoản chưa vào game.'); return JSON.parse(String(row.profile)); }
    occurrence(s, target) {
        if (!['main.506', 'server.905'].includes(target))
            eventFail('Loại Xu đầy trời không hợp lệ.');
        const e = new EventPlanner(this.db, this.now).resolveSky(target);
        if (!e)
            eventFail('Xu đầy trời đang tắt, chưa đến giờ hoặc server ngoài phạm vi.');
        const p = this.profile(s), meta = eventSource(target === 'main.506' ? 'active_inreview' : 'server_inreview')[target.split('.')[1]];
        if ((p.level ?? 1) < (meta.show_lv ?? 0) || (p.vip ?? 0) < (meta.VIP_limit ?? 0))
            eventFail('Chưa đủ cấp/VIP tham gia Xu đầy trời.');
        return e;
    }
    wire(s, e, reward = 0) {
        const run = this.db.prepare('SELECT rules,steps FROM sky_star_runs WHERE user_id=? AND occurrence_id=?').get(s.user_id, e.id), rows = run ? JSON.parse(String(run.rules)) : skyRows(e.target, e.version), steps = Number(run?.steps ?? 0);
        const next = rows[steps], log = Object.fromEntries(this.db.prepare('SELECT step,reward FROM sky_star_draws WHERE user_id=? AND occurrence_id=? ORDER BY step').all(s.user_id, e.id).map(r => [String(r.step), Number(r.reward)]));
        // git_coin ở nguồn có mức quảng cáo lớn hơn miền bốc thật: UI dùng chính miền thực tế.
        const configs = Object.fromEntries(rows.map((r, i) => [String(i + 1), { ...r, id: i + 1, version: e.version, git_coin: [Math.min(...r.reward_coin.map((v) => v[0])), Math.max(...r.reward_coin.map((v) => v[1]))] }]));
        const notices = this.db.prepare("SELECT d.reward coin,p.game_uid,COALESCE(json_extract(s.profile,'$.name'),p.game_uid) name FROM sky_star_draws d JOIN player_profiles p ON p.user_id=d.user_id JOIN player_state s ON s.user_id=d.user_id WHERE d.occurrence_id=? ORDER BY d.created_at DESC,d.rowid DESC LIMIT 20").all(e.id).map(r => ({ name: r.name, coin: Number(r.coin) }));
        return { version: e.version, expire: Math.max(0, Math.ceil((e.ends - this.now()) / 1000)), log, notices, occurrence_id: e.id, next_step: steps + 1, completed: steps === 7, cost: next?.coin ?? 0, sky_configs: configs, reward: reward ? { coin: reward } : {}, local_policy: 'LOCAL_APPROVED_WEIGHTED_UNIFORM', event_name: e.name };
    }
    index(s, target) { return this.wire(s, this.occurrence(s, target)); }
    draw(s, target, q) {
        if (typeof q.request_id !== 'string' || !/^[a-zA-Z0-9:_-]{8,160}$/.test(q.request_id) || typeof q.occurrence_id !== 'string' || q.occurrence_id.length > 160 || typeof q.step !== 'string' || !/^[1-7]$/.test(q.step))
            eventFail('Cần mã giao dịch, mã đợt và lượt hợp lệ; mở lại sự kiện bằng APK mới.');
        const fingerprint = createHash('sha256').update(JSON.stringify([target, q.occurrence_id, q.step])).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT fingerprint,result FROM sky_star_draws WHERE user_id=? AND request_id=?').get(s.user_id, q.request_id);
            if (old) {
                if (old.fingerprint !== fingerprint)
                    eventFail('Mã giao dịch đã dùng cho lượt khác.');
                this.db.exec('COMMIT');
                return { ...JSON.parse(String(old.result)), replayed: true };
            }
            const e = this.occurrence(s, target);
            if (e.id !== q.occurrence_id)
                eventFail('Đợt sự kiện đã thay đổi; mở lại trước khi khởi động.');
            const run = this.db.prepare('SELECT * FROM sky_star_runs WHERE user_id=? AND occurrence_id=?').get(s.user_id, e.id), rows = run ? JSON.parse(String(run.rules)) : skyRows(target, e.version), steps = Number(run?.steps ?? 0);
            if (steps >= 7)
                eventFail('Bạn đã hoàn thành đủ bảy lượt của đợt này.');
            if (Number(q.step) !== steps + 1)
                eventFail('Lượt đã thay đổi hoặc đã được xử lý; mở lại sự kiện.');
            const row = rows[steps], p = this.profile(s), before = Number(p.coin ?? 0);
            if (before < row.coin)
                eventFail('Không đủ Xu để khởi động.');
            let ticket = this.roll(100);
            if (!Number.isSafeInteger(ticket) || ticket < 0 || ticket >= 100)
                throw Error('RNG không hợp lệ.');
            let band;
            for (const v of row.reward_coin) {
                if (ticket < v[2]) {
                    band = v;
                    break;
                }
                ticket -= v[2];
            }
            if (!band)
                throw Error('Tỷ trọng không phủ kết quả.');
            const offset = this.roll(band[1] - band[0] + 1);
            if (!Number.isSafeInteger(offset) || offset < 0 || offset > band[1] - band[0])
                throw Error('RNG miền thưởng không hợp lệ.');
            const reward = band[0] + offset, next = before - row.coin + reward;
            if (!Number.isSafeInteger(next) || next < 0 || next > 1000000000)
                eventFail('Số dư Xu sau thưởng vượt giới hạn; chưa tiêu Xu.');
            if (!run)
                this.db.prepare('INSERT INTO sky_star_runs VALUES(?,?,?,?,?)').run(s.user_id, e.id, JSON.stringify(rows), 0, this.now());
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, coin: next }), s.user_id);
            this.db.prepare('UPDATE sky_star_runs SET steps=steps+1 WHERE user_id=? AND occurrence_id=?').run(s.user_id, e.id);
            // Ghi trước để wire đọc được log của lượt vừa xử lý; result được chốt cùng transaction.
            this.db.prepare('INSERT INTO sky_star_draws VALUES(?,?,?,?,?,?,?,?,?)').run(s.user_id, q.request_id, fingerprint, e.id, steps + 1, row.coin, reward, '{}', this.now());
            const result = this.wire(s, e, reward);
            this.db.prepare('UPDATE sky_star_draws SET result=? WHERE user_id=? AND request_id=?').run(JSON.stringify(result), s.user_id, q.request_id);
            audit(this.db, null, 'event.sky_star.draw', s.user_id, 'Khởi động Xu đầy trời LOCAL', { coin: before }, { occurrence: e.id, step: steps + 1, cost: row.coin, reward, coin: next, requestId: q.request_id, policy: result.local_policy });
            this.db.exec('COMMIT');
            return result;
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
