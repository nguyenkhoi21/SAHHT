import { readFileSync } from 'node:fs';
import { audit, adminError } from '../admin/admin.audit.js';
export class SourceQuarantineService {
    db;
    constructor(db) {
        this.db = db;
    }
    inspect(configIds) {
        if (!configIds.length || configIds.some(v => !Number.isSafeInteger(v) || v < 1))
            adminError('ID nguồn cách ly không hợp lệ.');
        return this.db.prepare(`SELECT user_id,id,config_id,state FROM player_heroes WHERE config_id IN (${configIds.map(() => '?').join(',')}) ORDER BY user_id,id`).all(...configIds);
    }
    // Archive giữ nguyên ownership/state. Không xóa hero, chỉ chuyển khỏi active roster.
    quarantine(batch, configIds, replacementByUser = {}) {
        if (batch !== 'code8-b1' || JSON.stringify([...configIds].sort()) !== JSON.stringify([90100, 91200]))
            adminError('Batch chưa có bằng chứng nguồn China được phép cách ly.');
        const base = JSON.parse(readFileSync(new URL('../../../work/extracted-data/configs/character_detail.json', import.meta.url), 'utf8'));
        if (configIds.some(id => Object.hasOwn(base, id)))
            adminError('Không được cách ly ID thuộc config Việt Nam gốc.');
        const rows = this.inspect(configIds);
        const users = [...new Set(rows.map(r => r.user_id))];
        this.db.exec('BEGIN IMMEDIATE');
        try {
            for (const userId of users) {
                const owned = new Set(rows.filter(r => r.user_id === userId).map(r => r.id));
                const state = this.db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(userId);
                const before = JSON.parse(state.formation), profile = JSON.parse(state.profile);
                const contains = (v) => typeof v === 'string' ? owned.has(v) : v && typeof v === 'object' ? Object.entries(v).some(([k, x]) => owned.has(k) || contains(x)) : false;
                if (contains(profile))
                    adminError('Hero đang liên kết profile; cần adapter riêng trước cách ly.');
                const after = JSON.parse(state.formation);
                const replacement = replacementByUser[String(userId)];
                const oldIds = new Set(this.db.prepare('SELECT id,config_id FROM player_heroes WHERE user_id=?').all(userId).filter(r => base[String(r.config_id)]).map(r => r.id));
                const targets = before.alignment.flat().filter((id) => id !== '-1');
                if (replacement) {
                    if (targets.some((id) => !owned.has(id)) || JSON.stringify(before.equip_pos) !== JSON.stringify(replacement.equip_pos) ||
                        !Array.isArray(replacement.alignment) || replacement.alignment.length !== 2 || replacement.alignment.some((team) => !Array.isArray(team) || team.length !== 5) ||
                        replacement.alignment.flat().some((id) => id !== '-1' && !oldIds.has(id)))
                        adminError('Snapshot đội cũ không khớp; không ghi đè thay đổi của người dùng.');
                    after.alignment = replacement.alignment;
                }
                else {
                    after.alignment = before.alignment.map((team) => team.map(id => owned.has(id) ? '-1' : id));
                    before.alignment.flat().forEach((id, i) => { if (owned.has(id))
                        after.equip_pos[String(i)] = Array(4).fill('0'); });
                }
                const allowed = new Set(['alignment', 'formation', 'equip_pos']);
                if (Object.entries(after).some(([key, value]) => !allowed.has(key) && contains(value)))
                    adminError('Còn liên kết hero ngoài schema trận hình.');
                for (const row of rows.filter(r => r.user_id === userId)) {
                    this.db.prepare('INSERT INTO player_hero_archive VALUES(?,?,?,?,?)').run(userId, row.id, row.config_id, row.state, Date.now());
                    this.db.prepare('DELETE FROM player_heroes WHERE user_id=? AND id=?').run(userId, row.id);
                }
                this.db.prepare('UPDATE player_state SET formation=? WHERE user_id=?').run(JSON.stringify(after), userId);
                audit(this.db, null, 'content.source.quarantine', userId, 'Cách ly batch China; giữ nguyên hero trong lưu trữ', { batch, formation: before, heroes: rows.filter(r => r.user_id === userId).map(r => ({ ...r, state: JSON.parse(r.state) })) }, { batch, status: 'QUARANTINED', formation: after, archivedHeroIds: [...owned], replacementValidated: !!replacement });
            }
            this.db.exec('COMMIT');
            return { batch, status: 'QUARANTINED', archived: rows.length, affectedUsers: users };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
