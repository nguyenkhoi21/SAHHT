import { readStaticConfigSync as readConfigSync } from './local-content.js';
import { eventFail as fail } from './event-planner.js';
import { audit } from '../admin/admin.audit.js';
export class PlayerNotices {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    settings() { const row = this.db.prepare('SELECT * FROM local_notice_settings WHERE id=1').get(); return row ? { revision: Number(row.revision), definition: JSON.parse(String(row.definition)) } : { revision: 0, definition: { mail: true, hero: true, equipment: true, item: true, events: true } }; }
    save(admin, revision, d) { const keys = ['mail', 'hero', 'equipment', 'item', 'events']; if (!d || Object.keys(d).length !== 5 || keys.some(k => typeof d[k] !== 'boolean'))
        fail('Cần đủ5công tắc chấm đỏ.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const old = this.settings();
        if (old.revision !== revision)
            fail('Cấu hình chấm đỏ đã đổi; tải lại.');
        const next = { revision: revision + 1, definition: d };
        this.db.prepare('INSERT INTO local_notice_settings VALUES(1,?,?) ON CONFLICT(id) DO UPDATE SET revision=excluded.revision,definition=excluded.definition').run(next.revision, JSON.stringify(d));
        audit(this.db, admin, 'notice.settings', null, 'Chỉnh nhắc việc LOCAL', old, next);
        this.db.exec('COMMIT');
        return next;
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    pending(user) { const defs = readConfigSync('character_detail'), items = readConfigSync('item'), equip = readConfigSync('equip'), unseen = (table, kind, id) => this.db.prepare(`SELECT ${id} id,config_id FROM ${table} p WHERE user_id=? ${table === 'player_items' ? 'AND quantity>0' : ''} AND NOT EXISTS(SELECT 1 FROM player_notice_seen n WHERE n.user_id=p.user_id AND n.kind=? AND n.entity_id=CAST(p.${id} AS TEXT)) LIMIT 1000`).all(user, kind).map(r => ({ id: String(r.id), configId: Number(r.config_id) })); return { hero: unseen('player_heroes', 'hero', 'id').filter(r => (defs[r.configId]?.quality ?? 0) > 3).map(r => r.id), equipment: unseen('player_equipment', 'equipment', 'id').filter(r => (equip[r.configId]?.quality ?? 0) > 3).map(r => r.id), item: unseen('player_items', 'item', 'config_id').filter(r => items[r.configId]?.is_show === 1).map(r => r.id) }; }
    wire(user) { const c = this.settings().definition, p = this.pending(user), mail = Number(this.db.prepare('SELECT count(*) n FROM player_mail WHERE user_id=? AND read_at IS NULL').get(user).n), eventReady = {}; if (c.events)
        for (const r of this.db.prepare('SELECT kind,state FROM restored_event_runs WHERE user_id=?').all(user)) {
            const t = JSON.parse(String(r.state)), ready = r.kind === 'investment' ? Object.values(t.investments).some((v) => v.time_long && !v.flag && v.end <= this.now()) : Object.values(t.tasks).some((v) => v.status === 1 && v.end <= this.now());
            if (ready)
                eventReady[r.kind === 'investment' ? 'main.524' : 'main.561'] = true;
        } return { schema: 1, mail: c.mail && mail > 0, mailCount: mail, hero: c.hero ? p.hero : [], equipment: c.equipment ? p.equipment : [], item: c.item ? p.item : [], events: eventReady }; }
    acknowledge(user, kind, ids) { if (!['hero', 'equipment', 'item'].includes(kind) || !Array.isArray(ids) || ids.length > 1000 || ids.some(id => typeof id !== 'string' || id.length > 100))
        fail('Danh sách đã xem không hợp lệ.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const valid = new Set(this.pending(user)[kind]);
        let count = 0;
        for (const id of ids)
            if (valid.has(id)) {
                this.db.prepare('INSERT OR IGNORE INTO player_notice_seen VALUES(?,?,?,1)').run(user, kind, id);
                count++;
            }
        this.db.exec('COMMIT');
        return { acknowledged: count };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    inspect(user) { return { ...this.wire(user), notice: 'Thư hết chấm khi đã nhận. Tướng/trang bị mới phẩm chất>3 theo Lua, vật phẩm hiển thị mới theo nguồn; hết chấm khi rời danh sách đã xem. Không ép nhận quà hoặc xóa thư.' }; }
}
