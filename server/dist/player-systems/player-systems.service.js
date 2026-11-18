import { randomInt } from 'node:crypto';
import { readStaticConfigSync as cfg } from '../player/local-content.js';
import { contentReceipt } from '../player/content-receipt.js';
import { capacityFields } from '../player/inventory-capacity.js';
import { audit } from '../admin/admin.audit.js';
import { PlayerService } from '../player/player.service.js';
import { playerSystemsReady } from './player-systems-migration.js';
export const systemsFail = (m, statusCode = 422) => { throw Object.assign(Error(m), { statusCode }); };
export function publicIdentity(db, id) {
    if (!playerSystemsReady(db))
        return null;
    let row = db.prepare('SELECT * FROM legacy_public_ids WHERE user_id=?').get(id);
    if (!row) {
        for (let n = 0; n < 100; n++) {
            const key = 'vn' + String(randomInt(0, 100000000)).padStart(8, '0');
            if (db.prepare('SELECT 1 FROM legacy_public_ids WHERE public_id=?').get(key))
                continue;
            db.prepare('INSERT OR IGNORE INTO legacy_public_ids(user_id,public_id,updated_at) VALUES(?,?,?)').run(id, key, Date.now());
            break;
        }
        row = db.prepare('SELECT * FROM legacy_public_ids WHERE user_id=?').get(id);
        if (!row)
            throw Error('Không cấp được ID duy nhất.');
    }
    return row;
}
export function titleState(db, id, at = Date.now()) {
    if (!playerSystemsReady(db))
        return { all_title: {}, cur_title: 0 };
    const all_title = Object.fromEntries(db.prepare('SELECT title_id,expires_at FROM legacy_title_owned WHERE user_id=?').all(id).map(r => [String(r.title_id), Number(r.expires_at)]));
    const p = JSON.parse(String(db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id)?.profile ?? '{}')), cur = Number(p.cur_title ?? 0), expiry = all_title[String(cur)];
    return { all_title, cur_title: expiry === -1 || expiry > Math.floor(at / 1000) ? cur : 0 };
}
const kinds = { item: { table: 'player_items', store: 'legacy_store_items', field: 'items', limit: 200, sort: 6 }, card: { table: 'player_heroes', store: 'legacy_store_cards', field: 'cards', limit: 200, sort: 5 }, equip: { table: 'player_equipment', store: 'legacy_store_equips', field: 'equips', limit: 100, sort: 7 }, talisman: { table: 'player_auxiliary', store: 'legacy_store_talismans', field: 'talismans', limit: 100, sort: 49 } };
export class PlayerSystemsService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    warehouse(id) { const out = { extends: {} }; for (const k of Object.values(kinds)) {
        const rows = this.db.prepare(`SELECT * FROM ${k.store} WHERE user_id=?`).all(id);
        out[k.field] = Object.fromEntries(rows.map(r => [String(k.field === 'items' ? r.config_id : r.id), k.field === 'items' ? Number(r.quantity) : JSON.parse(String(r.state))]));
    } return out; }
    transfer(s, method, p) {
        const match = /^storehouse\.(store|del)_(item|card|equip|talisman)$/.exec(method);
        if (!match)
            systemsFail('Thao tác Siêu Kho không hợp lệ.');
        const [, direction, kind] = match, k = kinds[kind], deposit = direction === 'store', field = kind === 'item' ? 'item_id' : kind + '_ids';
        const ids = p.getAll(field).flatMap(v => v.split(/[|,]/)).filter(Boolean);
        if (!ids.length || ids.length > 50 || new Set(ids).size !== ids.length || ids.some(v => !/^[-a-zA-Z0-9_]{1,100}$/.test(v)))
            systemsFail('Chọn 1–50 đối tượng khác nhau.');
        const num = kind === 'item' ? Number(p.get('num')) : 1;
        if (!Number.isSafeInteger(num) || num < 1 || num > 1000000 || kind === 'item' && ids.length !== 1)
            systemsFail('Số lượng không hợp lệ.');
        return contentReceipt(this.db, s.user_id, method, p.get('request_id'), { ids, num }, () => {
            const state = this.db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(s.user_id);
            if (!state)
                systemsFail('Chưa có nhân vật.');
            const form = JSON.parse(String(state.formation)), profile = capacityFields(JSON.parse(String(state.profile))), removed = [], updated = {};
            const has = (v, id) => Array.isArray(v) ? v.some(x => has(x, id)) : v && typeof v === 'object' ? Object.entries(v).some(([key, x]) => !key.startsWith('_local_') && has(x, id)) : String(v) === id;
            for (const id of ids) {
                if (kind === 'item') {
                    const cid = Number(id), def = cfg('item')[id];
                    if (!def || !Number.isSafeInteger(cid))
                        systemsFail('Vật phẩm không có trong catalog.');
                    const source = deposit ? k.table : k.store, target = deposit ? k.store : k.table, row = this.db.prepare(`SELECT quantity FROM ${source} WHERE user_id=? AND config_id=?`).get(s.user_id, cid), before = Number(row?.quantity ?? 0), dest = Number(this.db.prepare(`SELECT quantity FROM ${target} WHERE user_id=? AND config_id=?`).get(s.user_id, cid)?.quantity ?? 0);
                    if (before < num)
                        systemsFail('Không đủ vật phẩm.');
                    if (dest + num > def.stack)
                        systemsFail('Vượt số lượng cộng dồn của vật phẩm.');
                    if (deposit && !dest && Number(this.db.prepare(`SELECT COUNT(*) n FROM ${target} WHERE user_id=?`).get(s.user_id).n) >= k.limit)
                        systemsFail('Siêu Kho đã đầy.');
                    if (deposit)
                        this.db.prepare(`UPDATE ${source} SET quantity=quantity-? WHERE user_id=? AND config_id=?`).run(num, s.user_id, cid);
                    else if (before === num)
                        this.db.prepare(`DELETE FROM ${source} WHERE user_id=? AND config_id=?`).run(s.user_id, cid);
                    else
                        this.db.prepare(`UPDATE ${source} SET quantity=quantity-? WHERE user_id=? AND config_id=?`).run(num, s.user_id, cid);
                    this.db.prepare(`INSERT INTO ${target}(user_id,config_id,quantity) VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity`).run(s.user_id, cid, dest + num);
                    removed.push(id);
                    continue;
                }
                const source = deposit ? k.table : k.store, target = deposit ? k.store : k.table, where = kind === 'talisman' && deposit ? " AND kind='talisman'" : '', row = this.db.prepare(`SELECT config_id,state FROM ${source} WHERE user_id=? AND id=?${where}`).get(s.user_id, id);
                if (!row)
                    systemsFail('Đối tượng không thuộc kho của bạn.');
                const h = JSON.parse(String(row.state));
                if (deposit && (has(form, id) || h.lock || Object.values(h.remove_avail ?? {}).length || h.bind_card || h.bind_equip?.some((x) => x && String(x) !== '0')))
                    systemsFail('Hãy tháo khỏi đội hình, mở khóa và gỡ liên kết trước khi cất.');
                if (kind === 'card' && deposit) {
                    for (const table of ['godfield_formations', 'aether_formations'])
                        for (const r of this.db.prepare(`SELECT state FROM ${table} WHERE user_id=?`).all(s.user_id))
                            if (has(JSON.parse(String(r.state)), id))
                                systemsFail('Tướng còn trong đội Thần Vực/Chiến trường.');
                    for (const r of this.db.prepare("SELECT state FROM restored_event_runs WHERE user_id=? AND kind='dispatch'").all(s.user_id))
                        if (Object.values(JSON.parse(String(r.state)).tasks ?? {}).some((t) => t.status === 1 && has(t.selected, id)))
                            systemsFail('Tướng đang thực hiện nhiệm vụ phái đi.');
                }
                const limit = deposit ? k.limit : kind === 'card' ? profile.card_max : kind === 'equip' ? profile.equip_max : Infinity, extra = kind === 'talisman' && !deposit ? " AND kind='talisman'" : '';
                if (Number(this.db.prepare(`SELECT COUNT(*) n FROM ${target} WHERE user_id=?${extra}`).get(s.user_id).n) >= limit)
                    systemsFail('Kho đích đã đầy.');
                if (this.db.prepare(`SELECT 1 FROM ${target} WHERE user_id=? AND id=?${extra}`).get(s.user_id, id))
                    systemsFail('ID instance đã tồn tại ở kho đích.');
                if (kind === 'talisman' && !deposit)
                    this.db.prepare(`INSERT INTO ${target}(user_id,kind,id,config_id,state) VALUES(?,'talisman',?,?,?)`).run(s.user_id, id, row.config_id, row.state);
                else
                    this.db.prepare(`INSERT INTO ${target}(user_id,id,config_id,state) VALUES(?,?,?,?)`).run(s.user_id, id, row.config_id, row.state);
                this.db.prepare(`DELETE FROM ${source} WHERE user_id=? AND id=?${where}`).run(s.user_id, id);
                removed.push(id);
                updated[id] = h;
            }
            audit(this.db, null, method, s.user_id, 'Chuyển Siêu Kho; giữ nguyên instance và progression', null, { ids, num }, this.now());
            return this.packet(s, kind, deposit, removed, updated);
        }, () => ({ ...this.packet(s, kind, deposit, ids, {}), replayed: true }));
    }
    packet(s, kind, deposit, ids, updated) {
        const all = new PlayerService(this.db).cards(s, true), warehouse = this.warehouse(s.user_id), c = {};
        if (kind === 'item')
            c.item = { items: { update: all.items, remove: ids.filter(id => !all.items[id]) } };
        if (kind === 'card')
            c.cards = { cards: { update: all.cards, remove: ids.filter(id => !all.cards[id]) } };
        if (kind === 'equip')
            c.equip = { _equip: { update: all.equip, remove: ids.filter(id => !all.equip[id]) } };
        if (kind === 'talisman')
            c.talisman = { _talisman: { update: all.talisman, remove: ids.filter(id => !all.talisman[id]) } };
        const store = {};
        for (const k of Object.values(kinds))
            store[k.field] = { update: warehouse[k.field], remove: k === kinds[kind] ? ids.filter(id => !warehouse[k.field][id]) : [] };
        store.extends = { update: {} };
        return { storehouse: warehouse, _client_cache_update: { ...c, storehouse: store }, reward: [] };
    }
    titles(id) { return titleState(this.db, id, this.now()); }
    useTitle(s, id, key) { const title = Number(id); if (!Number.isSafeInteger(title) || title < 0 || title > 0 && !cfg('title_list')[title])
        systemsFail('Danh Hiệu không hợp lệ.'); return contentReceipt(this.db, s.user_id, 'user.use_title', key, { title }, () => { const state = this.titles(s.user_id), expires = state.all_title[String(title)]; if (title && expires !== -1 && !(expires > Math.floor(this.now() / 1000)))
        systemsFail('Danh Hiệu chưa sở hữu hoặc đã hết hạn.'); const p = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile)); this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, cur_title: title }), s.user_id); audit(this.db, null, 'user.use_title', s.user_id, 'Đeo Danh Hiệu LOCAL', null, { title }, this.now()); return this.titles(s.user_id); }, () => ({ ...this.titles(s.user_id), replayed: true })); }
    grantTitle(admin, id, title, expires, revoke) { if (!cfg('title_list')[title] || !Number.isSafeInteger(expires) || (expires !== -1 && expires <= Math.floor(this.now() / 1000)))
        systemsFail('Danh Hiệu/thời hạn không hợp lệ.'); this.db.exec('BEGIN IMMEDIATE'); try {
        if (revoke)
            this.db.prepare('DELETE FROM legacy_title_owned WHERE user_id=? AND title_id=?').run(id, title);
        else
            this.db.prepare('INSERT INTO legacy_title_owned VALUES(?,?,?) ON CONFLICT(user_id,title_id) DO UPDATE SET expires_at=excluded.expires_at').run(id, title, expires);
        audit(this.db, admin, revoke ? 'title.revoke' : 'title.grant', id, 'Quản lý Danh Hiệu LOCAL; chưa kích hoạt buff/phát tài nguyên', null, { title, expires }, this.now());
        this.db.exec('COMMIT');
        return this.titles(id);
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    renameId(admin, id, value, revision) { if (!/^vn\d{8}$/.test(value))
        systemsFail('ID phải là vn và 8 chữ số.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const before = publicIdentity(this.db, id);
        if (before.revision !== revision)
            systemsFail('ID vừa thay đổi; hãy tải lại.', 409);
        if (this.db.prepare('SELECT 1 FROM legacy_public_ids WHERE public_id=? AND user_id<>?').get(value, id))
            systemsFail('ID này đã có người sử dụng.', 409);
        this.db.prepare('UPDATE legacy_public_ids SET public_id=?,revision=revision+1,updated_at=? WHERE user_id=?').run(value, this.now(), id);
        audit(this.db, admin, 'player.public_id', id, 'Đổi ID công khai; giữ nguyên UID nội bộ và dữ liệu', before, { public_id: value }, this.now());
        this.db.exec('COMMIT');
        return publicIdentity(this.db, id);
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
}
