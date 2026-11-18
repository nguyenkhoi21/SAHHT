import { createHash } from 'node:crypto';
import { aetherConfig } from './aether-source.js';
import { aetherItems } from './aether-economy.js';
import { issueAetherMail } from './aether-mail.js';
import { aetherScienceLevel } from './aether-science.js';
import { simAssert, simGet, simPut, simRewards } from './aether-sim-policy.js';
// Chỉ dùng trong fixture được cho phép. Không suy diễn sở hữu/người nhận
// cho những ngày trước khi bật mô phỏng hoặc trong khoảng server đã tắt.
export class AetherSimProduction {
    db;
    event;
    now;
    constructor(db, event, now = () => Date.now()) {
        this.db = db;
        this.event = event;
        this.now = now;
        simAssert(db, event);
    }
    mail(user, rewards, scope) {
        const season = rewards.filter(r => r[0] === 6 && !!aetherItems()[r[1]]), normal = rewards.filter(r => !season.includes(r));
        if (season.length)
            issueAetherMail(this.db, this.event, user, season, scope, this.now());
        if (normal.length)
            this.db.prepare('INSERT INTO player_mail VALUES(?,?,?,NULL,?)').run(user, 'aether-production-' + createHash('sha256').update(this.event.id + ':' + user + ':' + scope).digest('hex').slice(0, 32), 'Sản lượng Aether · MÔ PHỎNG LOCAL; người nhận theo snapshot ngày đã quan sát', JSON.stringify(normal));
    }
    tax(group, city, type, scope) {
        const owner = aetherConfig('build')[city].city_zone.map(zone => this.db.prepare('SELECT owner_id FROM aether_cities WHERE event_id=? AND group_id=? AND city_id=?').get(this.event.id, group, zone)?.owner_id).find(Boolean);
        if (!owner)
            return 0;
        const town = aetherConfig('build')[city], cfg = Object.values(aetherConfig('product')).find(r => r.build_sort === 3 && r.bulid_level === town.city_level);
        const g = this.db.prepare('SELECT science_level,science_exp FROM aether_guilds WHERE event_id=? AND guild_id=?').get(this.event.id, owner);
        const percent = Object.values(aetherConfig('science')).filter(r => r.level <= Number(g.science_level)).flatMap(r => r.buff2).filter(r => r[0] === 2).reduce((n, r) => n + r[1], 0), amount = Math.floor(cfg.taxation[type - 1] * (100 + percent) / 100), total = Number(g.science_exp) + amount;
        if (!Number.isSafeInteger(total))
            throw Error('Thuế KHKT vượt giới hạn.');
        this.db.prepare('UPDATE aether_guilds SET science_exp=?,science_level=? WHERE event_id=? AND guild_id=?').run(total, aetherScienceLevel(total), this.event.id, owner);
        simPut(this.db, this.event.id, 0, 'resource-tax', scope, { guild: Number(owner), city, group, base: cfg.taxation[type - 1], percent, amount, total }, this.now());
        return amount;
    }
    tick(day) {
        const e = this.event.id, old = simGet(this.db, e, 0, 'production-clock', 'towns');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            // Một snapshot cuối ngày đã quan sát; downtime không tự dựng thêm lịch sử.
            if (old.day && old.day < day && !old.paid) {
                for (const city of old.cities ?? []) {
                    const town = aetherConfig('build')[city.city], cfg = Object.values(aetherConfig('product')).find(r => r.build_sort === 1 && r.bulid_level === town.city_level);
                    if (!cfg)
                        throw Error('Thiếu sản lượng thành nguồn.');
                    for (const user of city.users) {
                        const scope = 'town:' + city.group + ':' + city.city + ':' + old.day, rewards = simRewards(cfg.product1, e + ':' + user + ':' + scope);
                        if (rewards.length)
                            this.mail(user, rewards, scope);
                    }
                }
            }
            const cities = this.db.prepare('SELECT group_id,city_id,owner_id FROM aether_cities WHERE event_id=? AND owner_id IS NOT NULL ORDER BY group_id,city_id').all(e).filter(r => aetherConfig('build')[Number(r.city_id)]?.sort === 1).map(r => ({ group: Number(r.group_id), city: Number(r.city_id), guild: Number(r.owner_id), users: this.db.prepare("SELECT user_id FROM alliance_members WHERE alliance_id=? UNION SELECT user_id FROM aether_mercenaries WHERE event_id=? AND guild_id=? AND status='active' ORDER BY user_id").all(r.owner_id, e, r.owner_id).map(u => Number(u.user_id)) }));
            const next = { day, cities };
            if (JSON.stringify(old) !== JSON.stringify(next))
                simPut(this.db, e, 0, 'production-clock', 'towns', next, this.now());
            this.db.exec('COMMIT');
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
