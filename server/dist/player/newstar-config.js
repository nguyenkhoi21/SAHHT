import { readConfigSync } from './local-content.js';
import { createBaseHero, createBaseEquipment } from './definitions.js';
import { inventoryRewardItem } from './inventory-items.js';
import { staticConfig } from './player.service.js';
import { rewardProblem } from './hot-campaigns.js';
import { audit } from '../admin/admin.audit.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export class NewstarConfig {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    async baseline() { return { version: 300, days: Object.values(await staticConfig('newstar_seven')).filter(r => r.version === 300).sort((a, b) => a.day_id - b.day_id).map(r => ({ day: r.day_id, rewards: r.reward })), tasks: Object.entries(await staticConfig('newstar_mission')).filter(([, r]) => r.version === 300).map(([id, r]) => ({ id: Number(id), rewards: r.reward })) }; }
    async complete(d) { return { ...d, tasks: d.tasks ?? (await this.baseline()).tasks }; }
    async current() { const r = this.db.prepare("SELECT * FROM newstar_reward_configs WHERE status='published' ORDER BY published_at DESC,id DESC LIMIT 1").get(); return r ? { id: Number(r.id), definition: await this.complete(JSON.parse(String(r.definition))) } : { id: null, definition: await this.baseline() }; }
    // Chỉ đóng băng hàng đã nhận; quà chưa nhận luôn theo bản công bố hiện hành.
    async forUser(userId, current) {
        const active = current ?? await this.current(), r = this.db.prepare('SELECT definition FROM newstar_reward_snapshots WHERE user_id=?').get(userId);
        if (!r)
            return active.definition;
        const saved = await this.complete(JSON.parse(String(r.definition)));
        const claimed = (kind) => new Set(this.db.prepare('SELECT claim_key FROM player_claims WHERE user_id=? AND system=? AND period=?').all(userId, 'newstar_' + kind, '300').map(r => Number(r.claim_key)));
        const signs = claimed('sign'), tasks = claimed('task');
        return { ...active.definition, days: active.definition.days.map((d) => signs.has(d.day) ? saved.days.find((v) => v.day === d.day) ?? d : d), tasks: active.definition.tasks.map((t) => tasks.has(t.id) ? saved.tasks.find((v) => v.id === t.id) ?? t : t) };
    }
    recordClaimSync(userId, definition) { this.db.prepare('UPDATE newstar_reward_snapshots SET definition=? WHERE user_id=?').run(JSON.stringify(definition), userId); }
    async capture(userId) { const c = await this.current(); this.captureSync(userId, c.id, c.definition); }
    captureSync(userId, id, definition) { this.db.prepare('INSERT OR IGNORE INTO newstar_reward_snapshots VALUES(?,?,?,?)').run(userId, id, JSON.stringify(definition), this.now()); }
    async list() { return { current: await this.current(), baseline: await this.baseline(), configs: this.db.prepare('SELECT * FROM newstar_reward_configs ORDER BY id DESC LIMIT 30').all().map(r => ({ ...r, definition: JSON.parse(String(r.definition)) })), customized: !!this.db.prepare("SELECT 1 FROM newstar_reward_configs WHERE status='published'").get() }; }
    validateRewards(rewards) {
        // Thẻ nguyên liệu nguồn (skill_num=0/is_evo=0/Lv1) có gói 10 thẻ;
        // tách giới hạn an toàn LOCAL khỏi giới hạn 5 tướng chơi được của HOT.
        const checking = Array.isArray(rewards) ? rewards.map(v => {
            if (Array.isArray(v) && v.length === 3 && v[0] === 5 && Number.isSafeInteger(v[2]) && v[2] <= 100) {
                const c = readConfigSync('character_detail')[v[1]];
                if (c?.skill_num === 0 && c.is_evo === 0 && c.level_max === 1)
                    return [v[0], v[1], Math.min(5, v[2])];
            }
            return v;
        }) : rewards;
        const error = rewardProblem(checking);
        if (error)
            fail(error);
        const rows = rewards;
        if (rows.some(v => ![1, 2, 4, 9, 15, 17, 18, 20, 24, 26, 27, 40, 41, 42, 43, 106, 5, 6, 7].includes(v[0])))
            fail('Loại thưởng chưa có adapter Tân Tinh.');
        for (const [type, id] of rows) {
            if (type === 5)
                createBaseHero('preview', id, readConfigSync('character_detail')[id]);
            if (type === 7)
                createBaseEquipment('preview', id, readConfigSync('equip')[id]);
            if (type === 6 && !inventoryRewardItem(readConfigSync('item')[id]))
                fail('Vật phẩm chưa có hợp đồng nhận thưởng: #' + id);
        }
        return rows;
    }
    validate(d) {
        if (!d || d.version !== 300 || !Array.isArray(d.days) || d.days.length !== 7)
            fail('Cần đúng bảy ngày của phiên bản300.');
        const days = d.days.map((r) => { if (!r || !Number.isInteger(r.day) || r.day < 1 || r.day > 7)
            fail('Ngày phải từ1 đến7.'); return { day: r.day, rewards: this.validateRewards(r.rewards) }; });
        if (new Set(days.map((r) => r.day)).size !== 7)
            fail('Ngày bị trùng.');
        const source = readConfigSync('newstar_mission'), ids = Object.keys(source).filter(id => source[id].version === 300).map(Number);
        const raw = d.tasks ?? ids.map(id => ({ id, rewards: source[id].reward }));
        if (!Array.isArray(raw) || raw.length !== ids.length)
            fail('Cần đủ quà của các nhiệm vụ Tân Tinh gốc.');
        const tasks = raw.map((r) => { if (!r || !Number.isInteger(r.id) || !ids.includes(r.id))
            fail('ID nhiệm vụ không có trong nguồn Tân Tinh.'); return { id: r.id, rewards: this.validateRewards(r.rewards) }; });
        if (new Set(tasks.map((r) => r.id)).size !== ids.length)
            fail('Nhiệm vụ bị trùng.');
        return { version: 300, days: days.sort((a, b) => a.day - b.day), tasks: tasks.sort((a, b) => a.id - b.id) };
    }
    async save(adminId, b) {
        const d = this.validate(b.definition);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            let id = b.id, revision = 1;
            if (id) {
                const old = this.db.prepare('SELECT * FROM newstar_reward_configs WHERE id=?').get(id);
                if (!old || old.status !== 'draft' || old.revision !== b.revision)
                    fail('Bản nháp đã thay đổi hoặc đã công bố; tải lại.');
                revision = Number(old.revision) + 1;
                this.db.prepare('UPDATE newstar_reward_configs SET definition=?,revision=? WHERE id=?').run(JSON.stringify(d), revision, id);
            }
            else {
                id = Number(this.db.prepare("INSERT INTO newstar_reward_configs(revision,status,definition,created_at) VALUES(1,'draft',?,?)").run(JSON.stringify(d), this.now()).lastInsertRowid);
            }
            audit(this.db, adminId, 'event.newstar.draft', null, 'Lưu nháp quà đăng nhập và nhiệm vụ Tân Tinh', null, { id, revision, definition: d });
            this.db.exec('COMMIT');
            return { id, revision };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    async publish(adminId, b) {
        const baseline = await this.baseline();
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const r = this.db.prepare('SELECT * FROM newstar_reward_configs WHERE id=?').get(b.id);
            if (!r || r.revision !== b.revision)
                fail('Phiên bản cấu hình không còn khớp.');
            if (r.status === 'published') {
                this.db.exec('COMMIT');
                return { ok: true, replayed: true };
            }
            const d = this.validate(JSON.parse(String(r.definition)));
            const previous = this.db.prepare("SELECT id,definition FROM newstar_reward_configs WHERE status='published' ORDER BY published_at DESC,id DESC LIMIT 1").get();
            // Giữ snapshot cho claim lịch sử; hàng chưa nhận được forUser đồng bộ theo hiện hành.
            for (const p of this.db.prepare("SELECT user_id FROM player_claims WHERE system='newstar_join' AND period='300'").all())
                this.captureSync(Number(p.user_id), previous ? Number(previous.id) : null, previous ? JSON.parse(String(previous.definition)) : baseline);
            const stamp = Math.max(this.now(), Number(this.db.prepare('SELECT COALESCE(MAX(published_at),0) n FROM newstar_reward_configs').get().n) + 1);
            this.db.prepare("UPDATE newstar_reward_configs SET status='published',published_at=? WHERE id=?").run(stamp, b.id);
            audit(this.db, adminId, 'event.newstar.publish', null, 'Công bố quà chưa nhận; giữ lịch sử đã nhận', null, { id: b.id, definition: d });
            this.db.exec('COMMIT');
            return { ok: true };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
