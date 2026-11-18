import { PlayerService } from '../player/player.service.js';
import { WelfareLocalService } from './welfare-local.service.js';
import { positiveId, welfareFail } from './welfare-contracts.js';
import { validateRewards, welfareTicketIcon } from './welfare-source.js';
import { readStaticConfigSync } from '../player/local-content.js';
import { inventoryRewardItem } from '../player/inventory-items.js';
import { readFileSync } from 'node:fs';
const currencies = { 1: 'Thức ăn', 2: 'Sắt', 4: 'Năng tinh', 9: 'Xu', 10: 'Bạc treo thưởng', 11: 'Vàng treo thưởng', 14: 'Hồn sao', 15: 'Vàng', 16: 'Đá tinh luyện', 17: 'Thần Ân', 18: 'Thần Ân cao', 20: 'Năng tinh tiến cấp', 23: 'Đá tinh luyện cao', 24: 'Tinh thể PET', 26: 'EXP PET', 27: 'Đá kỹ năng PET', 33: 'Đá rèn nhỏ', 34: 'Đá rèn vừa', 35: 'Đá rèn cao', 40: 'Năng tinh siêu cấp', 41: 'Đá Vận Mệnh nhỏ', 42: 'Đá Vận Mệnh vừa', 43: 'Đá Vận Mệnh cao', 47: 'Đá Fancy', 106: 'Vé S' };
function rewardEntry(type, id, quantity = 1) { const table = { 5: 'character_detail', 6: 'item', 7: 'equip', 25: 'pet_detail', 50: 'equip_gem_fate', 108: 'equip_gem_fate_stone', 109: 'equip_gem_fate_word' }[type], cfg = table ? readStaticConfigSync(table)[id] : null; return { type, id, quantity, name: cfg?.name ?? currencies[type] ?? ('Tài nguyên #' + id), rarity: cfg?.quality ?? null, iconUrl: '/admin/api/hot/icon/' + type + '/' + id }; }
export function registerWelfareGame(app, accounts, online, released = false) {
    const base = JSON.parse(readFileSync(new URL('../../data/local-player.json', import.meta.url), 'utf8'));
    const methods = ['daily_award.all_reward', 'daily_award.get_reward', 'daily_award.coin_award', 'pay_award.index', 'pay_award.get_award'];
    app.addHook('preHandler', async (request, reply) => {
        const path = request.url.split('?')[0], q = request.query, method = String(q.method ?? '');
        if (!['/api/', '/pub_abroad_vr/api/'].includes(path) || !methods.includes(method))
            return;
        if ((online || process.env.APP_ENV === 'online') && !released)
            return reply.code(403).send({ status: 'WELFARE_LOCAL_ONLY', msg: 'Phúc Lợi mới chỉ mở LOCAL.' });
        if (request.method !== 'GET')
            return reply.code(405).send({ msg: 'Hợp đồng client dùng GET.' });
        const s = accounts.session(q.rans);
        if (!s || q.user_token !== s.game_uid || !accounts.validGameToken(s, q.mk))
            return reply.code(403).send({ msg: 'Phiên gameplay LOCAL không hợp lệ.' });
        const players = new PlayerService(accounts.db);
        await players.ensure(s);
        try {
            const service = new WelfareLocalService(accounts.db, Date.now, online);
            if (method === 'daily_award.coin_award')
                welfareFail('Điểm danh nạp liên tục chưa được xác minh; không trừ tài nguyên.');
            if (method.endsWith('get_reward') || method.endsWith('get_award')) {
                if (q.welfare_schema !== '1')
                    welfareFail('Cần APK Phúc Lợi LOCAL để đồng bộ quà và mã thao tác an toàn.');
                if (method === 'pay_award.get_award' && !['month', 'quarter'].includes(String(q.tp)))
                    welfareFail('Loại thẻ không hợp lệ.');
            }
            const data = method === 'daily_award.all_reward' ? service.daily(s) : method === 'pay_award.index' ? service.cards(s) : await service.claim(s, method === 'daily_award.get_reward' ? 'daily' : q.tp, q.reward, q.request_id);
            return reply.send({ status: '0', data, user_status: players.profile(s, base) });
        }
        catch (e) {
            const code = e.statusCode;
            if (code && code < 500)
                return reply.send({ status: 'LOCAL_WELFARE_ERROR', msg: e.message });
            throw e;
        }
    });
}
const writeBody = { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId'], properties: { confirmed: { const: true }, requestId: { type: 'string', pattern: '^[a-zA-Z0-9:_-]{8,120}$' }, id: { type: 'integer', minimum: 1 }, revision: { type: 'integer', minimum: 1 }, definition: { type: 'object' } } };
export function registerWelfareAdmin(admin, db, online, released = false) {
    const service = () => { if ((online || process.env.APP_ENV === 'online') && !released)
        welfareFail('Chưa mở quản lý Phúc Lợi ONLINE.', 403); return new WelfareLocalService(db, Date.now, online); };
    admin.get('/api/welfare/overview', async () => service().overview());
    admin.get('/api/welfare/configs', async () => service().list());
    admin.get('/api/welfare/icon/ticket', async (_r, reply) => { service(); return reply.type('image/png').header('Cache-Control', 'private, max-age=3600').send(welfareTicketIcon()); });
    admin.get('/api/welfare/catalog', async (r) => { service(); const q = r.query, type = Number(q.type ?? 6), term = String(q.q ?? '').toLocaleLowerCase('vi'), page = Math.max(1, Math.min(10000, Math.floor(Number(q.page) || 1))); let rows = []; if (type === 0)
        rows = Object.entries(currencies).map(([k, name]) => ({ type: Number(k), id: 0, name }));
    else {
        const table = { 5: 'character_detail', 6: 'item', 7: 'equip', 25: 'pet_detail', 50: 'equip_gem_fate' }[type];
        if (!table)
            welfareFail('Nhóm catalog không hợp lệ.');
        rows = Object.entries(readStaticConfigSync(table)).filter(([, c]) => type !== 6 || inventoryRewardItem(c)).map(([id, c]) => ({ id: Number(id), type, name: c.name }));
    } rows = rows.filter(v => (v.id + ' ' + v.name).toLocaleLowerCase('vi').includes(term)); return { page, total: rows.length, entries: rows.slice((page - 1) * 30, page * 30).map(v => rewardEntry(v.type, v.id)) }; });
    admin.get('/api/welfare/preview', async (r) => { service(); let rows; try {
        rows = JSON.parse(String(r.query.rows));
    }
    catch {
        welfareFail('Gói thưởng không hợp lệ.');
    } return { entries: validateRewards(rows).map(([type, id, n]) => rewardEntry(type, id, n)) }; });
    admin.get('/api/welfare/history', async (r) => service().history(r.query));
    admin.get('/api/welfare/players/:id', async (r) => service().inspect(positiveId(r.params.id)));
    admin.post('/api/welfare/draft', { config: { adminPermission: 'write' }, bodyLimit: 65536, schema: { body: { ...writeBody, required: [...writeBody.required, 'definition'] } } }, async (r) => service().save(r.adminIdentity.id, r.body));
    admin.post('/api/welfare/publish', { config: { adminPermission: 'owner' }, schema: { body: { ...writeBody, required: [...writeBody.required, 'id', 'revision'], properties: { confirmed: writeBody.properties.confirmed, requestId: writeBody.properties.requestId, id: writeBody.properties.id, revision: writeBody.properties.revision } } } }, async (r) => service().publish(r.adminIdentity.id, r.body));
    admin.post('/api/welfare/manage', { config: { adminPermission: 'owner' }, bodyLimit: 65536, schema: { body: { ...writeBody, required: [...writeBody.required, 'id', 'revision', 'action'], properties: { ...writeBody.properties, action: { enum: ['run', 'stop', 'apply', 'trash', 'restore'] } } } } }, async (r) => service().manage(r.adminIdentity.id, r.body));
    admin.post('/api/welfare/qa', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'action', 'userId'], properties: { confirmed: { const: true }, requestId: writeBody.properties.requestId, action: { enum: ['mark', 'advance', 'activate', 'expire'] }, userId: { type: 'integer', minimum: 1 }, kind: { enum: ['month', 'quarter'] }, days: { type: 'integer', minimum: 1, maximum: 100 }, configId: { type: 'integer', minimum: 1 } } } } }, async (r) => service().qa(r.adminIdentity.id, r.body));
}
