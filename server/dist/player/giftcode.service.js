import { randomBytes, randomUUID } from 'node:crypto';
import { audit } from '../admin/admin.audit.js';
import { staticConfig } from './player.service.js';
import { contentIndex } from './content-index.js';
import { createBaseHero, createBaseEquipment } from './definitions.js';
import { heroResources } from './hero-index.js';
import { heroSkillIndex } from './skill-index.js';
import { readConfigSync } from './local-content.js';
import { giftcodeCurrencies } from './giftcode-currencies.js';
function fail(message, statusCode = 422) { throw Object.assign(new Error(message), { statusCode }); }
export const normalizeCode = (v) => {
    if (typeof v !== 'string' || !/^[A-Z0-9_-]{3,20}$/.test(v.trim().toUpperCase()))
        fail('Mã quà tặng gồm 3–20 chữ, số, dấu gạch ngang hoặc gạch dưới.');
    return v.trim().toUpperCase();
};
export class GiftcodeService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    async validateRewards(input) {
        if (!Array.isArray(input) || input.length < 1 || input.length > 10)
            fail('Chọn từ 1 đến 10 phần thưởng.');
        const defs = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') };
        const heroes = await heroResources(), skills = await heroSkillIndex(), equipment = await contentIndex('equipment_catalog');
        const rewards = [], details = [];
        for (const r of input) {
            if (!r || !Number.isSafeInteger(r.quantity) || r.quantity < 1 || r.quantity > 100_000_000)
                fail('Số lượng phần thưởng không hợp lệ.');
            let type = 0, cid = 0, name = '';
            if (r.kind === 'currency') {
                if (typeof r.currency !== 'string' || !Object.hasOwn(giftcodeCurrencies, r.currency))
                    fail('Loại tài nguyên Giftcode chưa được hỗ trợ.');
                const c = giftcodeCurrencies[r.currency];
                type = c.type;
                name = c.name;
            }
            else if (r.kind === 'hero') {
                cid = r.configId;
                const cfg = defs.heroes[String(cid)];
                createBaseHero('gift-preview', cid, cfg);
                if (r.quantity > 5 || heroes.get(cid)?.assetStatus !== 'FULL ASSETS' || !skills.heroByConfigId[String(cid)] || skills.heroByConfigId[String(cid)].skills.some((s) => s.slot === 1 && !s.exists))
                    fail('Tướng thiếu config, resource hoặc skill hợp lệ.');
                type = 5;
                name = cfg.name;
            }
            else if (r.kind === 'equipment') {
                cid = r.configId;
                const cfg = defs.equipment[String(cid)];
                createBaseEquipment('gift-preview', cid, cfg);
                if (r.quantity > 5 || !equipment.some(h => h.configId === cid && h.grantable))
                    fail('Trang bị chưa có schema/icon hợp lệ.');
                type = 7;
                name = cfg.name;
            }
            else if (r.kind === 'item') {
                cid = r.configId;
                const cfg = defs.items[String(cid)];
                if (!cfg || cfg.is_show !== 1 || !Number.isSafeInteger(cfg.stack) || r.quantity > cfg.stack)
                    fail('Vật phẩm hoặc số lượng vượt stack được hỗ trợ.');
                type = 6;
                name = cfg.name;
            }
            else
                fail('Loại phần thưởng chưa được hỗ trợ. EXP/VIP chưa có quy tắc tăng trưởng được xác minh.');
            // Bộ cấp thưởng gốc giới hạn một tuple ở một triệu; chia tiền tệ, giữ nguyên tổng.
            for (let left = r.quantity; left > 0; left -= 1_000_000)
                rewards.push([type, cid, Math.min(left, 1_000_000)]);
            details.push({ ...r, name });
        }
        return { rewards, details };
    }
    async create(adminId, body) {
        const code = normalizeCode(body.code), rewards = await this.validateRewards(body.rewards);
        return this.save(adminId, body, [code], rewards).items[0];
    }
    save(adminId, body, codes, rewards) {
        const { campaign, description = '', totalLimit = 100, perAccountLimit = 1, minLevel = 1, minVip = 0, enabled = true } = body;
        const start = Date.parse(body.startsAt), end = Date.parse(body.expiresAt);
        if (typeof campaign !== 'string' || !campaign.trim() || campaign.length > 80 || typeof description !== 'string' || description.length > 1000 || !Number.isFinite(start) || !Number.isFinite(end) || end <= start || typeof enabled !== 'boolean')
            fail('Tên chiến dịch hoặc thời gian không hợp lệ.');
        const maxVip = Math.max(...Object.keys(readConfigSync('vip')).map(Number));
        for (const [v, min, max] of [[totalLimit, 1, 1_000_000], [perAccountLimit, 1, 10], [minLevel, 1, 250], [minVip, 0, maxVip]])
            if (!Number.isSafeInteger(v) || v < min || v > max)
                fail('Giới hạn lượt/Level/VIP không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const items = [];
            for (const code of codes) {
                if (this.db.prepare('SELECT 1 FROM giftcodes WHERE code=?').get(code))
                    fail('Mã quà tặng đã tồn tại.', 409);
                const id = Number(this.db.prepare('INSERT INTO giftcodes(code,campaign,description,rewards,starts_at,expires_at,total_limit,per_account_limit,min_level,min_vip,enabled,created_by,created_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)').run(code, campaign.trim(), description, JSON.stringify(rewards), start, end, totalLimit, perAccountLimit, minLevel, minVip, Number(enabled), adminId, this.now()).lastInsertRowid);
                audit(this.db, adminId, 'giftcode.create', null, 'Tạo mã quà tặng local', null, { id, code, ...rewards });
                items.push({ ok: true, id, code });
            }
            this.db.exec('COMMIT');
            return { ok: true, items };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    async batch(adminId, body) {
        if (!Number.isInteger(body.count) || body.count < 1 || body.count > 50)
            fail('Mỗi đợt từ 1 đến 50 code.');
        const rewards = await this.validateRewards(body.rewards);
        const codes = Array.from({ length: body.count }, () => 'SL' + randomBytes(7).toString('hex').toUpperCase());
        return this.save(adminId, body, codes, rewards);
    }
    list(q = {}) {
        const term = String(q.q ?? '').slice(0, 80).toLowerCase();
        const rows = this.db.prepare(`SELECT g.*,(SELECT COUNT(*) FROM giftcode_redemptions r WHERE r.giftcode_id=g.id) used FROM giftcodes g ORDER BY g.id DESC`).all();
        const filtered = rows.filter(r => (r.code + ' ' + r.campaign).toLowerCase().includes(term) && (q.status !== 'active' || r.enabled === 1) && (q.status !== 'disabled' || r.enabled === 0));
        const page = Math.max(1, Math.min(10000, Number(q.page) || 1));
        return { items: filtered.slice((page - 1) * 20, page * 20).map(r => ({ ...r, rewards: JSON.parse(r.rewards) })), total: filtered.length, page };
    }
    history(id) { return { items: this.db.prepare(`SELECT r.id,r.user_id,u.username,r.redeemed_at,r.mail_id,r.reward_snapshot,CASE WHEN m.read_at IS NULL THEN 'MAIL_PENDING' ELSE 'CLAIMED' END delivery_status FROM giftcode_redemptions r JOIN users u ON u.id=r.user_id JOIN player_mail m ON m.user_id=r.user_id AND m.id=r.mail_id WHERE r.giftcode_id=? ORDER BY r.id DESC LIMIT 200`).all(id) }; }
    toggle(adminId, id, enabled) {
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const old = this.db.prepare('SELECT enabled FROM giftcodes WHERE id=?').get(id);
            if (!old)
                fail('Không tìm thấy code.', 404);
            this.db.prepare('UPDATE giftcodes SET enabled=? WHERE id=?').run(Number(enabled), id);
            audit(this.db, adminId, 'giftcode.toggle', null, 'Đổi trạng thái mã quà tặng', old, { id, enabled });
            this.db.exec('COMMIT');
            return { ok: true };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    index(s) {
        // Không giả ID bảng code tĩnh: lịch sử local có namespace riêng, UI gốc chấp nhận danh sách rỗng.
        return { codes: [], local_history: this.db.prepare(`SELECT g.code,r.redeemed_at FROM giftcode_redemptions r JOIN giftcodes g ON g.id=r.giftcode_id WHERE r.user_id=? ORDER BY r.id DESC LIMIT 10`).all(s.user_id) };
    }
    redeem(s, value, requestId) {
        const code = normalizeCode(value), key = requestId === undefined ? 'game:' + code : String(requestId);
        if (!/^[A-Za-z0-9:_-]{3,100}$/.test(key))
            fail('Mã yêu cầu không hợp lệ.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const g = this.db.prepare('SELECT * FROM giftcodes WHERE code=?').get(code);
            if (!g)
                fail('Mã quà tặng không tồn tại.');
            const prior = this.db.prepare('SELECT r.giftcode_id,r.mail_id,m.read_at FROM giftcode_redemptions r JOIN player_mail m ON m.user_id=r.user_id AND m.id=r.mail_id WHERE r.user_id=? AND r.request_id=?').get(s.user_id, key);
            if (prior) {
                if (prior.giftcode_id !== g.id)
                    fail('Mã yêu cầu đã dùng cho phần thưởng khác.');
                this.db.exec('COMMIT');
                return { ...this.index(s), delivery: prior.read_at === null ? 'MAIL_PENDING' : 'CLAIMED', mail_id: prior.mail_id, replayed: true };
            }
            if (!g.enabled)
                fail('Mã quà tặng đã tắt.');
            if (this.now() < g.starts_at)
                fail('Mã quà tặng chưa đến ngày sử dụng.');
            if (this.now() >= g.expires_at)
                fail('Mã quà tặng đã hết hạn.');
            const used = Number(this.db.prepare('SELECT COUNT(*) n FROM giftcode_redemptions WHERE giftcode_id=?').get(g.id).n);
            const count = Number(this.db.prepare('SELECT COUNT(*) n FROM giftcode_redemptions WHERE giftcode_id=? AND user_id=?').get(g.id, s.user_id).n);
            if (count >= g.per_account_limit)
                fail('Tài khoản đã sử dụng hết lượt của mã quà tặng này.');
            if (used >= g.total_limit)
                fail('Mã quà tặng đã hết lượt.');
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id);
            if (!row)
                fail('Hãy vào game trước khi nhận quà.');
            const profile = JSON.parse(row.profile);
            if ((profile.level ?? 1) < g.min_level || (profile.vip ?? 0) < g.min_vip)
                fail('Chưa đủ điều kiện Level/VIP để nhận mã quà tặng.');
            const mailId = 'localcode-' + randomUUID(), snapshot = JSON.parse(g.rewards);
            this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(s.user_id, mailId, 'Quà tặng: ' + g.campaign + '\n\n' + g.description + '\nMã: ' + code, JSON.stringify(snapshot.rewards));
            this.db.prepare('INSERT INTO giftcode_redemptions(giftcode_id,user_id,request_id,ordinal,redeemed_at,mail_id,reward_snapshot) VALUES(?,?,?,?,?,?,?)').run(g.id, s.user_id, key, count + 1, this.now(), mailId, g.rewards);
            audit(this.db, null, 'giftcode.redeem', s.user_id, 'Đổi mã thành thư; chưa cộng inventory', null, { giftcodeId: g.id, mailId });
            this.db.exec('COMMIT');
            return { ...this.index(s), delivery: 'MAIL_PENDING', mail_id: mailId, replayed: false };
        }
        catch (e) {
            if (this.db.isTransaction)
                this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
