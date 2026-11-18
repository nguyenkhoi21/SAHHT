import { NewstarConfig } from '../player/newstar-config.js';
import { resourceIcon } from './resource-icons.js';
import { giftcodeCurrencies } from '../player/giftcode-currencies.js';
import { HotCards } from '../player/hot-cards.js';
import { createHash } from 'node:crypto';
import { HotCampaignAdmin, rewardProblem } from '../player/hot-campaigns.js';
import { HotService } from '../player/hot.service.js';
import { HotRechargeService } from '../player/hot-recharge.js';
import { hotFail, hotPolicy, hotStamp } from '../player/hot-source.js';
import { readConfigSync } from '../player/local-content.js';
const schema = { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'action'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, action: { enum: ['save', 'publish', 'disable', 'duplicate', 'bulk', 'source_on', 'source_off'] }, id: {}, revision: { type: 'integer' }, sourceKey: { type: 'string', maxLength: 100 }, date: { type: 'string', pattern: '^\\d{4}-\\d{2}-\\d{2}$' }, dates: { type: 'array', minItems: 1, maxItems: 31, uniqueItems: true, items: { type: 'string', pattern: '^\\d{4}-\\d{2}-\\d{2}$' } }, definition: { type: 'object' } } };
export function registerHotAdmin(admin, db, online, released = false) {
    const guard = () => { if (online && !released)
        throw Object.assign(Error('Sự kiện & nạp sandbox chỉ mở LOCAL; chưa được phát hànhONLINE.'), { statusCode: 403 }); };
    admin.get('/api/hot/calendar', async (request) => { guard(); return { ...new HotCampaignAdmin(db).list(request.query), policy: hotPolicy }; });
    admin.get('/api/hot/preview', async (request) => { guard(); const q = request.query, user = Number(q.user); if (!Number.isSafeInteger(user) || !db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(user))
        hotFail('Chọn tài khoảnLOCAL đã vào game.'); const at = q.at ? hotStamp(q.at) : Date.now(); if (!Number.isFinite(at))
        hotFail('Giờ preview không hợp lệ.'); return new HotService(db).index({ user_id: user }, at); });
    admin.get('/api/hot/catalog', async (request) => { guard(); const q = request.query, query = String(q.q ?? '').toLocaleLowerCase('vi'), page = Math.max(1, Math.min(100000, Math.floor(Number(q.page) || 1))), type = Number(q.type ?? 6), table = type === 5 ? 'character_detail' : type === 7 ? 'equip' : type === 50 ? 'equip_gem_fate' : type === 108 ? 'equip_gem_fate_stone' : type === 109 ? 'equip_gem_fate_word' : type === 25 ? 'pet_detail' : 'item', rows = Object.entries(readConfigSync(table)).filter(([id, c]) => (id + ' ' + c.name).toLocaleLowerCase('vi').includes(query)); return { page, total: rows.length, type, entries: rows.slice((page - 1) * 40, page * 40).map(([id, c]) => ({ id: Number(id), name: c.name, icon: c.icon ?? c.img ?? '', type, quantity: 1 })), currencies: [{ type: 9, name: 'Xu' }, { type: 1, name: 'Thức ăn' }, { type: 2, name: 'Sắt' }, { type: 106, name: 'Vé S' }, { type: 40, name: 'Năng Tinh siêu cấp' }, { type: 43, name: 'Đá Vận Mệnh siêu cấp' }] }; });
    admin.get('/api/hot/reward-preview', async (request) => { guard(); const q = request.query; let rows; try {
        rows = JSON.parse(String(q.rows ?? '[]'));
    }
    catch {
        hotFail('Gói thưởng không hợp lệ.');
    } if (q.context === 'newstar')
        new NewstarConfig(db).validateRewards(rows);
    else {
        const reason = rewardProblem(rows);
        if (reason)
            hotFail(reason);
    } const names = { ...Object.fromEntries(Object.values(giftcodeCurrencies).map(c => [c.type, c.name])), 1: 'Thức ăn', 9: 'Xu', 106: 'Vé S', 47: 'Đá Fancy' }; return { entries: rows.map(([type, id, quantity]) => { const table = type === 6 ? 'item' : type === 5 ? 'character_detail' : type === 7 ? 'equip' : type === 50 ? 'equip_gem_fate' : type === 108 ? 'equip_gem_fate_stone' : type === 109 ? 'equip_gem_fate_word' : type === 25 ? 'pet_detail' : null; return { type, id, quantity, name: table ? readConfigSync(table)[id]?.name : names[type] ?? 'Tài nguyên loại ' + type, iconUrl: '/admin/api/hot/icon/' + type + '/' + id }; }) }; });
    admin.get('/api/hot/icon/:type/:id', async (request, reply) => { guard(); const p = request.params; const raw = resourceIcon(Number(p.type), String(p.id)); return raw ? reply.type('image/png').header('Cache-Control', 'private, max-age=3600').send(raw) : reply.code(404).send(); });
    admin.post('/api/hot/campaign', { config: { adminPermission: 'owner' }, bodyLimit: 65536, schema: { body: schema } }, async (request) => {
        guard();
        const b = request.body, a = request.adminIdentity.id, hash = createHash('sha256').update(JSON.stringify(b)).digest('hex');
        const old = db.prepare('SELECT fingerprint,result FROM hot_admin_operations WHERE admin_id=? AND request_key=?').get(a, b.requestId);
        if (old) {
            if (old.fingerprint !== hash)
                hotFail('Mã thao tác đã dùng cho nội dung khác.');
            return { ...JSON.parse(String(old.result)), replayed: true };
        }
        // Các domain dùng savepoint: bulk và biên nhận cùng transaction ngoài.
        const svc = new HotCampaignAdmin(db);
        db.exec('BEGIN IMMEDIATE');
        try {
            const result = ['source_on', 'source_off'].includes(b.action) ? svc.toggleSource(a, String(b.id), b.action === 'source_on') : b.action === 'save' ? svc.save(a, b) : b.action === 'duplicate' ? svc.duplicate(a, String(b.id), String(b.date)) : b.action === 'bulk' ? { created: b.dates.map(date => svc.duplicate(a, String(b.id), date)) } : svc.publish(a, Number(b.id), Number(b.revision), b.action === 'disable');
            db.prepare('INSERT INTO hot_admin_operations VALUES(?,?,?,?)').run(a, b.requestId, hash, JSON.stringify(result));
            db.exec('COMMIT');
            return result;
        }
        catch (e) {
            if (db.isTransaction)
                db.exec('ROLLBACK');
            throw e;
        }
    });
    admin.get('/api/players/:id/hot', async (request) => { guard(); const id = Number(request.params.id), q = request.query; return { ...new HotService(db).history(id, q), recharge: new HotRechargeService(db, Date.now, online).info({ user_id: id }) }; });
    admin.post('/api/players/:id/hot-recharge', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'packageId', 'method'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 160 }, packageId: { type: 'integer', minimum: 1, maximum: 99 }, method: { enum: ['voucher', 'sandbox'] }, expectedTickets: { type: 'integer', minimum: 1, maximum: 1000000 }, ticketRevision: { type: 'integer', minimum: 0 } } } } }, async (request) => { guard(); const id = Number(request.params.id), b = request.body; const result = new HotRechargeService(db, Date.now, online).buy({ user_id: id }, new URLSearchParams({ package_id: String(b.packageId), payment_method: b.method, ...(b.expectedTickets === undefined ? {} : { expected_tickets: String(b.expectedTickets) }), ...(b.ticketRevision === undefined ? {} : { ticket_revision: String(b.ticketRevision) }), sandbox_confirm: '1', request_id: 'admin-' + request.adminIdentity.id + '-' + b.requestId })); return result; });
    admin.get('/api/hot/cards', async () => { guard(); return { cards: new HotCards(db).settings() }; });
    admin.post('/api/hot/cards', { config: { adminPermission: 'owner' }, bodyLimit: 32768, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'packageId', 'revision', 'definition'], properties: { confirmed: { const: true }, packageId: { enum: [1, 2] }, revision: { type: 'integer', minimum: 0 }, definition: { type: 'object' } } } } }, async (request) => { guard(); const b = request.body; return new HotCards(db).set(request.adminIdentity.id, b.packageId, b.revision, b.definition); });
    admin.get('/api/hot/history', async (request) => { guard(); const q = request.query, page = Math.max(1, Math.min(100000, Math.floor(Number(q.page) || 1))); return { page, audit: db.prepare("SELECT id,admin_id,action,target_user_id,summary,after_state,created_at FROM admin_audit WHERE action LIKE 'hot.%' ORDER BY id DESC LIMIT 40 OFFSET ?").all((page - 1) * 40) }; });
}
