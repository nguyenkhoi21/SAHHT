import { PlayerVitalsService } from './player-vitals.js';
import { staticConfig } from './player.service.js';
import { serverDay } from './welfare.service.js';
import { EventCalendarService } from './event-calendar.js';
// LOCAL TEST IMPLEMENTATION: catalog chỉ đọc; không mở trận/claim chưa có backend.
export async function activityIndex() {
    const chapters = await staticConfig('active_chapter');
    return { month_award: 2, week_award: 2, world_boss: 0, gift_reward: {},
        // Chưa có lượt mua/trận local: số0 và log rỗng có nghĩa; không mở lượt combat giả.
        // game_activity_new_pop:244–272 đọc cur_buy_times trực tiếp khi VIP được mua lượt.
        index: Object.fromEntries(Object.keys(chapters).map(id => [id, { cur_times: 0, times: 0, cur_buy_times: 0, active_steps: {} }])),
        active_forever: { forever_fails: 3 }, sacrifice: { times: 0 },
        search_treasure: { cur_times: 0, times: 0, treasure: 0, cur_buy_times: 0 }, wanted: { success: true, fail_times: 0 } };
}
// Chưa có lượt phái cử local: log/kho/alignment thực sự rỗng. Không sinh trận,
// thời gian còn lại hoặc reward. game_dispatch_main314/384,dispatch_card1.store_limit.
export async function dispatchIndex() {
    const cfg = await staticConfig('dispatch_card'), capacity = cfg['1']?.store_limit;
    if (!Number.isSafeInteger(capacity) || capacity < 0)
        throw new Error('Thiếu config dung lượng kho phái cử local.');
    return { dispatch_data: {}, fight_log: [], store: [], store_max: capacity };
}
// Reward có trực tiếp trong game_fuli_subui_liveres.lua:112; lịch là policy local.
export class ActivityService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    settings() { return this.db.prepare("SELECT * FROM local_activity_settings WHERE activity_id='10'").get(); }
    available(s, now = this.now()) { const cfg = this.settings(); return cfg.enabled === 1 && now >= cfg.starts_at && now < cfg.ends_at && !this.db.prepare("SELECT 1 FROM player_claims WHERE user_id=? AND system='activity_supplies' AND period=? AND claim_key='1'").get(s.user_id, serverDay(now)); }
    async open(s) { const data = await activityIndex(), p = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile)), calendar = new EventCalendarService(this.db, this.now), chapters = calendar.chapters(p.level ?? 1); return { ...data, index: Object.fromEntries(chapters.filter(c => c.active).map(c => [c.id, { ...data.index[c.id], expire_day: 0 }])), calendar: { timezone: 'Asia/Ho_Chi_Minh', visible_activities: Object.fromEntries(Object.entries(await staticConfig('active')).map(([id, row]) => { const refs = (row.active_chapterID ?? []).flat(Infinity).map(String); return [id, !refs.length || refs.some((ref) => chapters.some(c => c.id === ref && c.active)) ? 1 : 0]; })), chapters: chapters.map(c => ({ id: c.id, active: c.active, reason: c.blockedReason })) }, gift_reward: this.available(s) ? { '1': 1 } : {} }; }
    claim(s, id) {
        if (id !== '1')
            throw Object.assign(new Error('Mã vật tư local không hợp lệ'), { statusCode: 422 });
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const now = this.now();
            if (!this.available(s, now))
                throw Object.assign(new Error('Ngoài lịch local, đang tắt hoặc hôm nay đã nhận vật tư.'), { statusCode: 422 });
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id);
            if (!row)
                throw Object.assign(new Error('Player state chưa khởi tạo'), { statusCode: 409 });
            const profile = new PlayerVitalsService(this.db, this.now).sync(s.user_id), next = profile.action_point + 50;
            if (!Number.isSafeInteger(next) || next > 1_000_000)
                throw Object.assign(new Error('Thể lực vượt giới hạn local'), { statusCode: 422 });
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...profile, action_point: next }), s.user_id);
            this.db.prepare("INSERT INTO player_claims VALUES(?,'activity_supplies',?,'1',?)").run(s.user_id, serverDay(now), now);
            this.db.exec('COMMIT');
            return { reward: [[13, 0, 50]] };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
