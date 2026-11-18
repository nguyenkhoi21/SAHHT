import { RechargeSettings } from './recharge-settings.js';
import { hotFail } from '../player/hot-source.js';
export function registerRechargeAdmin(admin, db, online, released = false) {
    const guard = () => { if (online && !released)
        throw Object.assign(Error('Giá Vé Vàng chỉ mở LOCAL; chưa phát hành ONLINE.'), { statusCode: 403 }); };
    admin.get('/api/hot/ticket-prices', async () => { guard(); return new RechargeSettings(db).list(); });
    admin.post('/api/hot/ticket-prices', { config: { adminPermission: 'owner' }, schema: { body: { type: 'object', additionalProperties: false, required: ['confirmed', 'requestId', 'packageId', 'revision', 'tickets', 'enabled'], properties: { confirmed: { const: true }, requestId: { type: 'string', minLength: 8, maxLength: 120 }, packageId: { type: 'integer', minimum: 1, maximum: 99 }, revision: { type: 'integer', minimum: 0 }, tickets: { type: 'integer', minimum: 1, maximum: 1000000 }, enabled: { type: 'boolean' } } } } }, async (request) => {
        guard();
        const body = request.body;
        if (body.confirmed !== true)
            hotFail('Cần xác nhận thay đổi.');
        return new RechargeSettings(db).save(request.adminIdentity.id, body);
    });
}
