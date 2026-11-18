import { grantPets, petCache } from './pet-state.js';
import { petConfig } from './pet-source.js';
import { inventoryRewardItem } from './inventory-items.js';
import { capacityFields } from './inventory-capacity.js';
import { storedTransformedHero } from './transformed-mail.js';
import { auxRewardKind, auxiliaryPreset, auxGrant, auxiliaryCache } from './auxiliary-state.js';
import { fatePreset, createFateSpecial, fateCache, fateRewardPreview } from './fate-empowerment.js';
import { randomUUID } from 'node:crypto';
import { staticConfig, PlayerService } from './player.service.js';
import { createBaseHero, createBaseEquipment } from './definitions.js';
import { audit } from '../admin/admin.audit.js';
import { readConfigSync } from './local-content.js';
const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
// Ngày server local UTC+7; không reset claim khi restart hoặc đổi VIP.
export const serverDay = (now) => new Date(now + 7 * 3600_000).toISOString().slice(0, 10);
export class WelfareService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    profile(s) { return JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile); }
    enabled(s, system) { return this.profile(s)._local_welfare_enabled?.[system] !== false; }
    claimed(s, system, period, key) { return !!this.db.prepare('SELECT 1 FROM player_claims WHERE user_id=? AND system=? AND period=? AND claim_key=?').get(s.user_id, system, period, key); }
    async onceIndex(s) {
        const cfg = await staticConfig('reward_once'), p = this.profile(s), levelEnabled = p._local_welfare_enabled?.level !== false, result = {};
        for (const [id, c] of Object.entries(cfg)) {
            const target = c.target_data?.[0] ?? 0, level = Number(id) > 1000 && Number(id) < 2000 && c.target_sort === 1;
            // Các hệ thống chưa có tiến độ chỉ hiện chưa hoàn thành; không giả đã nhận.
            const progress = level ? (p.level ?? 1) : 0;
            result[id] = [progress, target, this.claimed(s, 'level', 'once', id) ? 2 : level && progress >= target && levelEnabled ? 1 : 0];
        }
        return { once: { result } };
    }
    async vipIndex(s) {
        const vip = this.profile(s).vip ?? 0, cfg = await staticConfig('new_vip_reward'), sign_record = {}, today = serverDay(this.now());
        for (let v = 1; v <= vip; v++) {
            if (!cfg[String(v)])
                continue;
            const days = this.db.prepare("SELECT COUNT(*) AS n FROM player_claims WHERE user_id=? AND system='vip_sign' AND claim_key=?").get(s.user_id, String(v)).n;
            sign_record[String(v)] = { day: days, flag: this.enabled(s, 'vip_sign') && days < 7 && !this.claimed(s, 'vip_sign', today, String(v)) };
        }
        const mail = this.db.prepare('SELECT id,read_at FROM player_mail WHERE user_id=? AND id=?').get(s.user_id, this.vipMailId('vip_daily', today, 'daily'));
        return { sign_record, is_every_day: this.enabled(s, 'vip_daily') && vip > 0 && !!cfg[String(vip)] && !this.claimed(s, 'vip_daily', today, 'daily'), daily_delivery: mail ? (mail.read_at === null ? 'MAIL_PENDING' : 'MAIL_CLAIMED') : this.claimed(s, 'vip_daily', today, 'daily') ? 'DIRECT' : 'AVAILABLE', daily_mail_id: mail?.id };
    }
    vipMailId(system, period, key) { return `localvip-${system}-${period}-${key}`; }
    async definitions() { return { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') }; }
    // Kiểm tra toàn bộ gói trước khi ghi. Kho đầy có thể chuyển sang thư;
    // config sai/loại chưa hỗ trợ luôn bị từ chối, không tạo thư lỗi.
    rewardPlan(s, rewards, defs) {
        const entries = Array.isArray(rewards) ? rewards : fail('Cấu trúc phần thưởng không hợp lệ.');
        if (entries.length === 0)
            fail('Chưa có phần thưởng có thể cấp an toàn.');
        const raw = this.profile(s), p = { ...raw, ...capacityFields(raw) }, items = {}, cards = {}, equipment = {}, gems = {}, materials = {}, specials = [];
        let capacityReason = '';
        const blocked = (reason) => { capacityReason ||= reason; };
        let heroCount = Number(this.db.prepare('SELECT COUNT(*) n FROM player_heroes WHERE user_id=?').get(s.user_id).n), equipCount = Number(this.db.prepare('SELECT COUNT(*) n FROM player_equipment WHERE user_id=?').get(s.user_id).n);
        for (const r of entries) {
            if (r?.kind === 'auxiliary') {
                auxiliaryPreset(r);
                specials.push(r);
                continue;
            }
            if (r?.kind === 'transformed_hero') {
                if (!Number.isSafeInteger(r.quantity) || r.quantity < 1 || r.quantity > 5)
                    fail('Số tướng preset không hợp lệ.');
                heroCount += r.quantity;
                if (heroCount > (p.card_max ?? 20))
                    blocked('Danh sách tướng đã đầy.');
                for (let i = 0; i < r.quantity; i++) {
                    const id = `localr${s.user_id}-${randomUUID().replaceAll('-', '')}`;
                    cards[id] = storedTransformedHero(r, id);
                }
                continue;
            }
            if (r?.kind === 'empowered_gem') {
                fatePreset(r);
                if (!Number.isSafeInteger(r.quantity) || r.quantity < 1 || r.quantity > 50)
                    fail('Tối đa50 đá Ban Sức mỗi dòng.');
                specials.push(r);
                continue;
            }
            if (!Array.isArray(r) || r.length !== 3 || !r.every(Number.isSafeInteger) || r[2] < 1)
                fail('Cấu trúc phần thưởng chưa hỗ trợ.');
            const [type, cid, count] = r;
            const auxiliaryKind = auxRewardKind(type);
            if (auxiliaryKind) {
                const preset = auxiliaryPreset({ kind: 'auxiliary', system: auxiliaryKind, configId: cid, quantity: count });
                specials.push(preset);
                continue;
            }
            const field = { 1: 'food', 2: 'metal', 4: 'crystal', 9: 'coin', 10: 'dirt_silver', 11: 'dirt_gold', 14: 'star', 15: 'silver', 16: 'metalcore', 17: 'grace', 18: 'grace_high', 20: 'adv_crystal', 23: 'refine_stone', 33: 'small_forge_stone', 34: 'middle_forge_stone', 35: 'high_forge_stone', 40: 'super_crystal', 41: 'min_fate_stone', 42: 'mid_fate_stone', 43: 'max_fate_stone', 106: 'ticket', 24: 'pet_crystal', 26: 'pet_exp_ball', 27: 'pet_skill_stone' }[type];
            if (type === 47) {
                if (cid !== 0 || count > 100_000_000)
                    fail('Mã hoặc số lượng Đá Fancy không hợp lệ.');
                const next = Number(p.pink_coin ?? 0) + count;
                if (!Number.isSafeInteger(next) || next > 1000000000)
                    blocked('Đá Fancy vượt giới hạn tài nguyên.');
                p.pink_coin = next;
                continue;
            }
            if (count > (field && type !== 106 ? 100_000_000 : 1_000_000))
                fail('Số lượng phần thưởng vượt giới hạn local.');
            if (field) {
                if (cid !== 0)
                    fail('Mã tiền tệ không hợp lệ.');
                const next = (p[field] ?? 0) + count;
                if (!Number.isSafeInteger(next) || next < 0)
                    fail('Số dư tài nguyên không hợp lệ.');
                if (next > 1_000_000_000)
                    blocked('Vượt giới hạn tài nguyên local.');
                p[field] = next;
            }
            else if (type === 25) {
                if (!petConfig('pet_detail')[cid] || count > 5)
                    fail('PET không có nguồn/số lượng vượt giới hạn.');
                specials.push({ kind: 'pet', configId: cid, quantity: count });
            }
            else if (type === 108 || type === 109) {
                const kind = type === 108 ? 'stone' : 'word', table = type === 108 ? 'equip_gem_fate_stone' : 'equip_gem_fate_word';
                if (!readConfigSync(table)[String(cid)])
                    fail('Vật liệu Ban Sức thiếu config.');
                const key = kind + ':' + cid, old = materials[key]?.quantity ?? Number(this.db.prepare('SELECT quantity FROM player_fate_materials WHERE user_id=? AND kind=? AND config_id=?').get(s.user_id, kind, cid)?.quantity ?? 0);
                if (old + count > 1000000)
                    fail('Kho vật liệu Ban Sức vượt giới hạn.');
                materials[key] = { kind, id: cid, quantity: old + count };
            }
            else if (type === 6) {
                const cfg = defs.items[String(cid)];
                if (!inventoryRewardItem(cfg))
                    fail('Inventory reward chưa có schema phù hợp.');
                const old = items[String(cid)]?.[0] ?? this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, cid)?.quantity ?? 0;
                const quantity = old + count;
                if (quantity > cfg.stack)
                    blocked('Kho vật phẩm vượt stack.');
                items[String(cid)] = [quantity];
            }
            else if (type === 7) {
                equipCount += count;
                if (equipCount > (p.equip_max ?? 20))
                    blocked('Kho trang bị đã đầy.');
                for (let i = 0; i < count; i++) {
                    const id = `localre${s.user_id}-${randomUUID().replaceAll('-', '')}`;
                    equipment[id] = createBaseEquipment(id, cid, defs.equipment?.[String(cid)]);
                }
            }
            else if (type === 5) {
                heroCount += count;
                if (heroCount > (p.card_max ?? 20))
                    blocked('Danh sách tướng đã đầy.');
                for (let i = 0; i < count; i++) {
                    const id = `localr${s.user_id}-${randomUUID().replaceAll('-', '')}`;
                    cards[id] = createBaseHero(id, cid, defs.heroes[String(cid)]);
                }
            }
            else if (type === 50) {
                if (!readConfigSync('equip_gem_fate')[String(cid)])
                    fail('Đá Vận Mệnh không có config hợp lệ.');
                const old = gems[String(cid)] ?? Number(this.db.prepare('SELECT quantity FROM player_fate_gems WHERE user_id=? AND config_id=?').get(s.user_id, cid)?.quantity ?? 0);
                if (old + count > 1_000_000)
                    blocked('Kho đá Vận Mệnh đã đầy.');
                gems[String(cid)] = old + count;
            }
            else
                fail('Loại phần thưởng chưa được tái dựng; chưa nhận và chưa cấp dữ liệu.');
        }
        return { p, items, cards, equipment, gems, materials, specials, rewards, capacityReason };
    }
    applyPlan(s, plan) {
        const { p, items, cards, equipment, gems, materials, specials, rewards, capacityReason } = plan;
        if (capacityReason)
            fail(capacityReason);
        for (const [cid, q] of Object.entries(items))
            this.db.prepare('INSERT INTO player_items VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(s.user_id, Number(cid), q[0]);
        for (const [id, h] of Object.entries(cards))
            this.db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(s.user_id, id, h.c_id, JSON.stringify(h));
        for (const [id, e] of Object.entries(equipment))
            this.db.prepare('INSERT INTO player_equipment VALUES(?,?,?,?)').run(s.user_id, id, e.c_id, JSON.stringify(e));
        for (const [cid, q] of Object.entries(gems))
            this.db.prepare('INSERT INTO player_fate_gems VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(s.user_id, Number(cid), q);
        for (const m of Object.values(materials))
            this.db.prepare('INSERT INTO player_fate_materials VALUES(?,?,?,?) ON CONFLICT(user_id,kind,config_id) DO UPDATE SET quantity=excluded.quantity').run(s.user_id, m.kind, m.id, m.quantity);
        for (const preset of specials) {
            if (preset.kind === 'pet')
                grantPets(this.db, s.user_id, preset.configId, preset.quantity);
            else if (preset.kind === 'auxiliary')
                auxGrant(this.db, s.user_id, preset);
            else
                for (let n = 0; n < preset.quantity; n++)
                    createFateSpecial(this.db, s.user_id, preset);
        }
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), s.user_id);
        // game_data.updateDataByJsonData:2807 đọc equip._equip, không phải cards.equip.
        // Dùng đúng projection cards.open: state base level_max=1 không phải cap của
        // người nhận. Trả raw sẽ khóa Kế Thừa ngay sau Mail/gacha và thiếu aura/cache.
        const projected = Object.keys(cards).length ? new PlayerService(this.db).cards(s, true).cards : {}, clientCards = Object.fromEntries(Object.keys(cards).map(id => [id, projected[id]]));
        return { reward: fateRewardPreview(rewards), _client_cache_update: { ...(specials.some(r => r.kind === 'pet') ? petCache(this.db, s.user_id) : {}), ...(specials.some(r => r.kind === 'auxiliary') ? auxiliaryCache(this.db, s.user_id) : {}), item: { items: { update: items, remove: [] } }, cards: { cards: { update: clientCards, remove: [] } }, ...((Object.keys(gems).length || specials.some(r => r.kind === 'empowered_gem') || Object.keys(materials).length) ? { gem_fate: { ...fateCache(this.db, s.user_id), _gem_fate: { update: gems, remove: [] } } } : {}), ...(Object.keys(equipment).length ? { equip: { _equip: { update: equipment, remove: [] } } } : {}) } };
    }
    applyInTransaction(s, rewards, defs) {
        if (!this.db.isTransaction)
            throw new Error('Cấp thưởng cần transaction đang mở.');
        return this.applyPlan(s, this.rewardPlan(s, rewards, defs));
    }
    claim(s, system, period, key, rewards, defs, validate) {
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (!this.enabled(s, system))
                fail('Tính năng này đang tạm tắt cho tài khoản thử nghiệm.');
            validate();
            if (this.claimed(s, system, period, key))
                fail('Bạn đã nhận phần thưởng này.');
            const plan = this.rewardPlan(s, rewards, defs), mailId = this.vipMailId(system, period, key), deferred = system.startsWith('vip_') && !!plan.capacityReason;
            const result = deferred ? { reward: [], delivery: 'MAIL_PENDING', mail_id: mailId, delivery_message: 'Quà VIP đã được gửi vào Tin tức. Hãy dùng bớt tài nguyên hoặc dọn kho rồi nhận thư; chưa cộng thưởng vào túi.' } : this.applyPlan(s, plan);
            if (deferred)
                this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(s.user_id, mailId, `Quà VIP ${this.profile(s).vip} · ${period}\n${plan.capacityReason}\nToàn bộ phần thưởng được giữ trong thư. Hãy tạo đủ chỗ rồi nhận; không cấp một phần.`, JSON.stringify(rewards));
            if (system.startsWith('vip_'))
                audit(this.db, null, 'vip.reward.claim', s.user_id, 'Nhận quà VIP từ config; kho đầy chuyển toàn bộ sang thư', null, { system, period, key, vip: this.profile(s).vip, rewards, delivery: deferred ? 'MAIL_PENDING' : 'DIRECT', mailId: deferred ? mailId : null });
            this.db.prepare('INSERT INTO player_claims VALUES(?,?,?,?,?)').run(s.user_id, system, period, key, this.now());
            this.db.exec('COMMIT');
            return result;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    async vipDiagnostics(s) {
        const cfg = await staticConfig('new_vip_reward'), p = this.profile(s), vip = p.vip ?? 0, today = serverDay(this.now()), state = await this.vipIndex(s), rewards = cfg[String(vip)]?.everyday ?? [];
        let capacityReason = '';
        if (rewards.length)
            try {
                capacityReason = this.rewardPlan(s, rewards, await this.definitions()).capacityReason;
            }
            catch (e) {
                capacityReason = e.message;
            }
        const claimed = this.claimed(s, 'vip_daily', today, 'daily'), reason = !this.enabled(s, 'vip_daily') ? 'Quà VIP đang tạm tắt.' : !rewards.length ? 'VIP này chưa có cấu hình quà hằng ngày.' : claimed ? (state.daily_delivery === 'MAIL_PENDING' ? 'Đã gửi thư, chưa cộng vào túi.' : 'Đã nhận hôm nay.') : capacityReason ? 'Kho đầy: nhận sẽ chuyển toàn bộ quà sang thư.' : 'Đủ điều kiện nhận trực tiếp.';
        const history = this.db.prepare("SELECT c.system,c.period,c.claim_key,c.claimed_at,m.id mail_id,m.read_at,m.attachments FROM player_claims c LEFT JOIN player_mail m ON m.user_id=c.user_id AND m.id=('localvip-'||c.system||'-'||c.period||'-'||c.claim_key) WHERE c.user_id=? AND c.system IN ('vip_daily','vip_sign') ORDER BY c.claimed_at DESC LIMIT 50").all(s.user_id).map(r => ({ ...r, mail_id: r.mail_id, delivery: r.mail_id ? (r.read_at === null ? 'MAIL_PENDING' : 'MAIL_CLAIMED') : 'DIRECT', rewards: r.attachments ? JSON.parse(String(r.attachments)) : null }));
        return { vip, day: today, rewards, coin: p.coin ?? 0, currencyLimit: 1_000_000_000, reason, capacityReason, delivery: state.daily_delivery, history };
    }
    async claimLevel(s, value) {
        if (typeof value !== 'string' || !/^1[0-9]{3}$/.test(value))
            fail('Mã quà cấp độ không hợp lệ.');
        const id = value, cfg = (await staticConfig('reward_once'))[id];
        if (!cfg || cfg.target_sort !== 1)
            fail('Quà cấp độ chưa hỗ trợ.');
        const defs = await this.definitions(), result = this.claim(s, 'level', 'once', id, cfg.reward, defs, () => { if ((this.profile(s).level ?? 1) < cfg.target_data[0])
            fail('Chưa đạt cấp nhận quà.'); });
        return { ...await this.onceIndex(s), ...result };
    }
    async claimVipDaily(s) {
        const defs = await this.definitions(), cfg = await staticConfig('new_vip_reward'), vip = this.profile(s).vip ?? 0, today = serverDay(this.now());
        if (vip < 1)
            fail('Chưa đủ VIP để nhận quà hằng ngày.');
        if (!cfg[String(vip)])
            fail(`Chưa có cấu hình quà hằng ngày cho VIP${vip}.`);
        const result = this.claim(s, 'vip_daily', today, 'daily', cfg[String(vip)].everyday, defs, () => { if (this.profile(s).vip !== vip)
            fail('VIP đã đổi, hãy tải lại.'); });
        return { ...await this.vipIndex(s), ...result };
    }
    async claimVipSign(s, value) {
        if (value !== undefined && (typeof value !== 'string' || !/^\d{1,2}$/.test(value)))
            fail('Mã VIP không hợp lệ.');
        const vip = value === undefined ? (this.profile(s).vip ?? 0) : Number(value), cfg = await staticConfig('new_vip_reward');
        if (!Number.isInteger(vip) || vip < 1 || vip > (this.profile(s).vip ?? 0) || !cfg[String(vip)])
            fail('Chưa đủ VIP cho mốc này.');
        const before = await this.vipIndex(s), record = before.sign_record[String(vip)];
        if (!record?.flag)
            fail('Hôm nay đã nhận hoặc đã đủ7 ngày.');
        const defs = await this.definitions(), result = this.claim(s, 'vip_sign', serverDay(this.now()), String(vip), cfg[String(vip)]['day' + (record.day + 1)], defs, () => { const count = this.db.prepare("SELECT COUNT(*) AS n FROM player_claims WHERE user_id=? AND system='vip_sign' AND claim_key=?").get(s.user_id, String(vip)).n; if (count !== record.day || vip > (this.profile(s).vip ?? 0))
            fail('Trạng thái nhận quà đã đổi, hãy tải lại.'); });
        return { ...await this.vipIndex(s), ...result };
    }
}
