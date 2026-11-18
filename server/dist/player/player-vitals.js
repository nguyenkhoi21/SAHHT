import { capacityFields } from './inventory-capacity.js';
import { readConfigSync } from './local-content.js';
let roleCache;
const roles = () => roleCache ??= readConfigSync('role');
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
export function playerLevelFields(profile) {
    const level = profile.level ?? 1, row = roles()[level], max = Math.max(...Object.keys(roles()).map(Number));
    if (!row || !Number.isSafeInteger(level))
        return fail('Cấp nhân vật vượt config hoặc sai kiểu dữ liệu.');
    if (!Number.isSafeInteger(profile.exp ?? 0) || (profile.exp ?? 0) < 0)
        fail('EXP nhân vật đã lưu không hợp lệ.');
    return { level, exp: level >= max ? 0 : profile.exp ?? 0, exp_max: level >= max ? 0 : row.exp };
}
export function playerExperience(profile, gain) {
    if (!Number.isSafeInteger(gain) || gain < 0 || gain > 1000000)
        fail('EXP nhân vật không hợp lệ.');
    profile = { ...profile, ...capacityFields(profile) };
    const all = roles(), max = Math.max(...Object.keys(all).map(Number)), start = playerLevelFields(profile), old = start.exp, path = [];
    if (start.level >= max)
        return { gain: 0, old, path, profile: { ...profile, ...start } };
    let lv = start.level, exp = old + gain, stamina = Number(profile.action_point ?? all[lv].point);
    path.push([lv, all[lv].exp]);
    while (lv < max && exp >= all[lv].exp) {
        exp -= all[lv].exp;
        lv++;
        stamina += all[lv].recover_point;
        path.push([lv, lv === max ? 0 : all[lv].exp]);
    }
    if (!Number.isSafeInteger(stamina) || stamina > 1_000_000_000)
        fail('Thể lực sau lên cấp vượt giới hạn.');
    return { gain, old, path, profile: { ...profile, ...playerLevelFields({ level: lv, exp }), action_point: stamina, action_point_max: all[lv].point, _local_exp_curve: 'vn-role-v1' } };
}
export function naturalFormationSlots(level) {
    const all = roles();
    let main = 0, reserve = 0;
    const requirements = [];
    for (const [key, row] of Object.entries(all).sort((a, b) => Number(a[0]) - Number(b[0]))) {
        for (let i = main; i < row.position_num; i++)
            requirements.push({ kind: 'main', slot: i, level: Number(key) });
        for (let i = reserve; i < row.alternate_num; i++)
            requirements.push({ kind: 'reserve', slot: i, level: Number(key) });
        main = Math.max(main, row.position_num);
        reserve = Math.max(reserve, row.alternate_num);
    }
    return { position_num: requirements.filter(r => r.kind === 'main' && r.level <= level).length, alternate_num: requirements.filter(r => r.kind === 'reserve' && r.level <= level).length, requirements };
}
// Consumer game_data.setUserStatusData: fallback360s; chưa có cấu hình server
// cho VIP/rate. Giữ rate hợp lệ đã lưu, không tự suy giảm thời gian theo VIP.
export function projectedVitals(profile, now = Date.now()) {
    const p = { ...profile, ...capacityFields(profile), ...playerLevelFields(profile) }, row = roles()[p.level], rate = Number(p.action_point_rate ?? 360), max = Number(row.point);
    if (!Number.isSafeInteger(rate) || rate < 1 || rate > 86400)
        fail('Chu kỳ thể lực không hợp lệ.');
    let value = Number(p.action_point ?? max), anchor = Number(p._local_stamina_at ?? now);
    if (!Number.isSafeInteger(value) || value < 0 || value > 1_000_000_000)
        fail('Thể lực đã lưu không hợp lệ.');
    if (!Number.isSafeInteger(anchor) || anchor < 0)
        anchor = now;
    if (now >= anchor && value < max) {
        const ticks = Math.floor((now - anchor) / (rate * 1000));
        value = Math.min(max, value + ticks);
        anchor += ticks * rate * 1000;
    }
    if (value >= max)
        anchor = now;
    return { ...p, action_point: value, action_point_max: max, action_point_rate: rate, action_point_update_left: value >= max ? 0 : Math.max(1, Math.ceil((anchor + rate * 1000 - now) / 1000)), _local_stamina_at: anchor };
}
export class PlayerVitalsService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    sync(id) {
        const own = !this.db.isTransaction;
        if (own)
            this.db.exec('BEGIN IMMEDIATE');
        try {
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id);
            if (!row)
                fail('Chưa có hồ sơ người chơi.');
            const before = JSON.parse(String(row.profile)), p = projectedVitals(before, this.now());
            if (JSON.stringify(before) !== JSON.stringify(p))
                this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
            if (own)
                this.db.exec('COMMIT');
            return p;
        }
        catch (e) {
            if (own)
                this.db.exec('ROLLBACK');
            throw e;
        }
    }
    diagnostics(id) { const r = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id); if (!r)
        fail('Chưa có hồ sơ người chơi.'); const p = projectedVitals(JSON.parse(String(r.profile)), this.now()); return { level: p.level, exp: p.exp, expRequired: p.exp_max, levelCap: Math.max(...Object.keys(roles()).map(Number)), stamina: p.action_point, staminaMax: p.action_point_max, intervalSeconds: p.action_point_rate, nextRecoverySeconds: p.action_point_update_left, expSource: 'role.exp', levelUpStaminaSource: 'role.recover_point', rateEvidence: 'action_point_rate đã lưu hoặc fallback360giây của consumer Lua; chưa xác minh rate server/VIP.', slots: naturalFormationSlots(p.level) }; }
}
