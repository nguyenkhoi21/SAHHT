import { randomInt } from 'node:crypto';
import { simEnabled, simGet, simPut } from './aether-sim-policy.js';
import { aetherConfig, aetherSource } from './aether-source.js';
import { AetherEconomy, aetherItems } from './aether-economy.js';
import { ProgressionEconomyService } from './progression-economy.js';
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
export function aetherScienceLevel(total) {
    if (!Number.isSafeInteger(total) || total < 0)
        fail('Tổng cống hiến KHKT không hợp lệ.');
    const rows = Object.values(aetherConfig('science'));
    let level = 0, last = 0;
    for (const row of rows.sort((a, b) => a.level - b.level)) {
        if (!Number.isSafeInteger(row.need_price) || row.need_price <= last)
            fail('Mốc KHKT nguồn không tăng dần.');
        last = row.need_price;
        if (total >= row.need_price)
            level = row.level;
    }
    return level;
}
export function aetherScienceCombat(level, cityBuff = []) {
    if (!Number.isInteger(level) || level < 0 || level > Object.keys(aetherConfig('science')).length)
        fail('Cấp KHKT chiến đấu không hợp lệ.');
    const buffs = new Map();
    for (const row of Object.values(aetherConfig('science')))
        if (row.level <= level)
            for (const [kind, value] of row.buff) {
                if (![1, 2, 5].includes(kind) || !Number.isFinite(value) || value < 0)
                    fail('Buff KHKT chưa có hợp đồng chỉ số.');
                buffs.set(kind, (buffs.get(kind) ?? 0) + value);
            }
    for (const [kind, value] of cityBuff) {
        if (![1, 2, 5].includes(kind) || !Number.isFinite(value) || value < 0)
            fail('Buff thành chưa có hợp đồng chỉ số.');
        if (buffs.has(kind) && aetherSource().userConfirmedRules.scienceCityStats !== 'ADDITIVE_PERCENT')
            fail('Chưa chốt phép ghép buff KHKT và thành cùng một chỉ số; chưa kết toán trận.');
        buffs.set(kind, (buffs.get(kind) ?? 0) + value);
    }
    // rate đã là mức giảm ô nhiễm tích lũy của cấp hiện tại; không cộng
    // rate1+rate2+... (sẽ tính trùng). Buff chỉ số của các sao thì cộng dồn.
    const reduction = Number(aetherConfig('science')[level]?.rate ?? 0);
    if (!Number.isFinite(reduction) || reduction < 0 || reduction > 100)
        fail('Giảm Ô Nhiễm KHKT không hợp lệ.');
    return { buffs: [...buffs], pollutionReduction: reduction };
}
export class AetherScience {
    db;
    event;
    day;
    at;
    roll;
    constructor(db, event, day, at, roll = () => randomInt(100)) {
        this.db = db;
        this.event = event;
        this.day = day;
        this.at = at;
        this.roll = roll;
    }
    total(user) { return Number(this.db.prepare("SELECT coalesce(sum(json_extract(reward,'$.points')),0) n FROM aether_claims WHERE event_id=? AND user_id=? AND kind='science-contribution'").get(this.event, user).n); }
    used(user) { return Number(this.db.prepare("SELECT count(*) n FROM aether_claims WHERE event_id=? AND user_id=? AND kind='science-contribution' AND claim_key=?").get(this.event, user, this.day + ':free').n); }
    milestones(user) { return this.db.prepare("SELECT claim_key FROM aether_claims WHERE event_id=? AND user_id=? AND kind='science-star' ORDER BY CAST(claim_key AS INTEGER)").all(this.event, user).map(r => String(r.claim_key)); }
    contribute(s, guild, type) {
        if (!this.db.isTransaction)
            throw Error('Cống KHKT cần transaction.');
        let claimKey = this.day + ':free';
        if (type !== 1) {
            const event = this.db.prepare('SELECT * FROM aether_events WHERE id=?').get(this.event);
            if (type !== 2 || !event || !simEnabled(this.db, event))
                fail('Chưa có sổ nạp tiền Aether xác minh để mở lượt trả phí; chưa trừ vật liệu/Xu.');
            const credit = simGet(this.db, this.event, s.user_id, 'science-credit', this.day, { credits: 0, used: 0 });
            if (credit.used >= Math.min(3, credit.credits))
                fail('Chưa có tín dụng nạp QA hoặc hết3lượt; chưa tiêu vật liệu.');
            claimKey = this.day + ':paid:' + (credit.used + 1);
        }
        const level = Number(guild.science_level), current = Number(guild.science_exp);
        if (aetherScienceLevel(current) !== level)
            fail('Cấp và tổng điểm KHKT đang lệch; chưa tiêu vật liệu.');
        const cfg = aetherConfig('science')[Math.max(1, level)];
        if (!cfg || !Array.isArray(cfg.item) || cfg.item.length !== cfg.price.length)
            fail('Thiếu bảng cống KHKT cùng phiên bản.');
        if (cfg.free_num !== 1)
            fail('Trần cống KHKT không khớp quy tắc một lượt ngày đã xác minh.');
        if (type === 1 && this.used(s.user_id) >= cfg.free_num)
            fail('Đã hết lượt cống KHKT miễn phí hôm nay.');
        const economy = new AetherEconomy(this.db, this.event), inventory = economy.inventory(s.user_id), profile = new ProgressionEconomyService(this.db).profile(s), costs = [];
        let basePoints = 0;
        const fields = { 20: 'adv_crystal', 18: 'grace_high', 40: 'super_crystal' };
        const seen = new Set();
        cfg.item.forEach(([kind, id, count], index) => {
            const points = cfg.price[index], key = kind + ':' + id;
            if (seen.has(key) || !Number.isSafeInteger(count) || count < 1 || !Number.isSafeInteger(points) || points < 1)
                fail('Giá/điểm cống KHKT không hợp lệ.');
            seen.add(key);
            let own;
            if (kind === 6)
                own = aetherItems()[id] ? inventory[id] : Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0);
            else {
                const field = fields[kind];
                if (!field || id !== 0)
                    fail('Vật liệu cống KHKT chưa có hợp đồng kho.');
                own = Number(profile[field] ?? 0);
            }
            if (!Number.isSafeInteger(own) || own < 0)
                fail('Số dư vật liệu KHKT không hợp lệ.');
            if (own >= count) {
                costs.push([kind, id, count]);
                basePoints += points;
            }
        });
        if (!costs.length)
            fail('Không có loại vật liệu nào đủ số lượng để cống; chưa dùng lượt.');
        // Sao6 buff2[1,10] và mô tả Việt Nam: 10% cống hiến gấp đôi. Chỉ
        // bốc một lần/giao dịch rồi lưu receipt; không cộng các lần gửi lại.
        const chance = Math.max(0, ...Object.values(aetherConfig('science')).filter((r) => r.level <= level).flatMap((r) => r.buff2.filter((b) => b[0] === 1).map((b) => Number(b[1]))));
        if (!Number.isInteger(chance) || chance < 0 || chance > 100)
            fail('Xác suất cống KHKT không hợp lệ.');
        let rolled = null;
        if (chance) {
            rolled = this.roll();
            if (!Number.isInteger(rolled) || rolled < 0 || rolled >= 100)
                fail('Giá trị kiểm xác suất KHKT không hợp lệ.');
        }
        const doubled = rolled !== null && rolled < chance, points = basePoints * (doubled ? 2 : 1), total = current + points;
        if (!Number.isSafeInteger(total) || !Number.isSafeInteger(this.total(s.user_id) + points))
            fail('Điểm KHKT vượt giới hạn an toàn.');
        economy.cost(s, costs);
        const nextLevel = aetherScienceLevel(total);
        if (this.db.prepare('UPDATE aether_guilds SET science_exp=?,science_level=? WHERE event_id=? AND guild_id=?').run(total, nextLevel, this.event, guild.guild_id).changes !== 1)
            fail('Đăng ký hội KHKT đã thay đổi; chưa cống.');
        const receipt = { guildId: guild.guild_id, groupId: guild.group_id, costs, basePoints, points, doubled, chance, roll: rolled, total, oldLevel: level, level: nextLevel, day: this.day };
        this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'science-contribution',?,?,?)").run(this.event, s.user_id, claimKey, JSON.stringify(receipt), this.at);
        if (type === 2) {
            const credit = simGet(this.db, this.event, s.user_id, 'science-credit', this.day);
            credit.used++;
            simPut(this.db, this.event, s.user_id, 'science-credit', this.day, credit, this.at);
        }
        return receipt;
    }
    claim(s, threshold) {
        if (!this.db.isTransaction)
            throw Error('Mốc KHKT cần transaction.');
        const cfg = aetherConfig('sciencestar')[threshold];
        if (!Number.isSafeInteger(threshold) || !cfg)
            fail('Mốc KHKT không có trong nguồn Việt Nam.');
        if (this.total(s.user_id) < threshold)
            fail('Cống hiến cá nhân chưa đủ mốc KHKT.');
        if (this.milestones(s.user_id).includes(String(threshold)))
            fail('Đã nhận mốc KHKT này.');
        const delivery = new AetherEconomy(this.db, this.event).grant(s, cfg.reward);
        this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'science-star',?,?,?)").run(this.event, s.user_id, String(threshold), JSON.stringify({ threshold, rewards: cfg.reward }), this.at);
        return delivery;
    }
}
