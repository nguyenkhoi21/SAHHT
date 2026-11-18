import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { aetherSource } from './aether-source.js';
import { readConfigSync } from './local-content.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { fateCache } from './fate-empowerment.js';
import { grantGodfieldReward } from './godfield-reward.js';
let materials;
export function aetherItems() {
    if (materials)
        return materials;
    const proof = aetherSource().seasonItems, raw = readFileSync(new URL('../../../' + proof.path, import.meta.url));
    if (createHash('sha256').update(raw).digest('hex') !== proof.sha256)
        throw Error('Nguồn vật liệu Aether đã đổi.');
    const data = JSON.parse(raw.toString()), base = readConfigSync('item'), rows = {};
    for (const key of Object.keys(proof.records)) {
        if (JSON.stringify(data[key]) !== JSON.stringify(base[key]) || data[key].is_show !== 2 || data[key].is_use !== 18)
            throw Error('Sai mapping vật liệu mùa Aether.');
        rows[key] = data[key];
    }
    return materials = rows;
}
export class AetherEconomy {
    db;
    event;
    constructor(db, event) {
        this.db = db;
        this.event = event;
    }
    inventory(id) { return Object.fromEntries(Object.keys(aetherItems()).map(k => [k, Number(this.db.prepare('SELECT quantity FROM aether_items WHERE event_id=? AND user_id=? AND config_id=?').get(this.event, id, Number(k))?.quantity ?? 0)])); }
    cost(s, rows) {
        if (!this.db.isTransaction)
            throw Error('Thiếu transaction Aether.');
        const normal = [];
        for (const [t, cid, n] of rows) {
            if (t !== 6 || !aetherItems()[cid]) {
                normal.push([t, cid, n]);
                continue;
            }
            if (!Number.isSafeInteger(n) || n < 0)
                throw Error('Giá vật liệu Aether không hợp lệ.');
            const owned = this.inventory(s.user_id)[cid];
            if (owned < n)
                throw Object.assign(Error('Không đủ vật liệu Aether trong mùa hiện tại.'), { statusCode: 422 });
            this.db.prepare('UPDATE aether_items SET quantity=quantity-? WHERE event_id=? AND user_id=? AND config_id=?').run(n, this.event, s.user_id, cid);
        }
        if (normal.length)
            new ProgressionEconomyService(this.db).cost(s, normal);
    }
    grant(s, rows) {
        if (!this.db.isTransaction)
            throw Error('Thiếu transaction thưởng Aether.');
        const normal = [], season = [];
        for (const row of rows)
            (row[0] === 6 && aetherItems()[row[1]] ? season : normal).push(row);
        const out = normal.length ? grantGodfieldReward(this.db, s, normal) : { reward: {} };
        for (const [, cid, n] of season) {
            const current = this.inventory(s.user_id)[cid], cfg = aetherItems()[cid];
            if (!Number.isSafeInteger(n) || n < 1 || n > 10000 || current + n > cfg.stack)
                throw Object.assign(Error('Kho mùa Aether vượt giới hạn; chưa cấp một phần.'), { statusCode: 422 });
            this.db.prepare('INSERT INTO aether_items VALUES(?,?,?,?) ON CONFLICT(event_id,user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(this.event, s.user_id, cid, current + n);
            (out.reward.item ??= []).push(...Array(n).fill(cid));
        }
        return out;
    }
    packet(s, out) { const p = new ProgressionEconomyService(this.db).packet(s, out); p._client_cache_update = { ...out._client_cache_update, ...p._client_cache_update, gem_fate: fateCache(this.db, s.user_id) }; const cache = p._client_cache_update.item.items, inv = this.inventory(s.user_id); for (const [k, n] of Object.entries(inv)) {
        delete cache.update[k];
        cache.remove = cache.remove.filter((v) => v !== k);
        if (n > 0)
            cache.update[k] = [n];
        else
            cache.remove.push(k);
    } return p; }
}
