import { staticConfig } from './player.service.js';
import { audit } from '../admin/admin.audit.js';
import { equipmentClientState } from './definitions.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
// equipment_strengthen.onSureFunc2:242–275 và refreshEquipInfo:300–335.
// lvs là số cấp tăng, không phải cấp đích; chi phí cộng floor theo từng row.
export class EquipmentService {
    db;
    constructor(db) {
        this.db = db;
    }
    async levelUp(s, id, lvs, requestId) {
        if (typeof id !== 'string' || !/^[-a-zA-Z0-9]{1,80}$/.test(id) || typeof lvs !== 'string' || !/^\d{1,3}$/.test(lvs) || Number(lvs) < 1)
            fail('ID trang bị/số cấp tăng không hợp lệ.');
        const [equips, levels] = await Promise.all(['equip', 'equip_strongthen'].map(staticConfig));
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const key = requestId === undefined ? undefined : String(requestId), fingerprint = JSON.stringify([id, lvs]);
            if (key && !/^[A-Za-z0-9_.:-]{8,160}$/.test(key))
                fail('Mã thao tác không hợp lệ.');
            const prior = key ? this.db.prepare('SELECT method,fingerprint FROM player_content_operations WHERE user_id=? AND request_key=?').get(s.user_id, key) : undefined;
            if (prior) {
                if (prior.method !== 'factory.equip_levelup' || prior.fingerprint !== fingerprint)
                    fail('Mã thao tác đã dùng cho nội dung khác.');
                const current = this.db.prepare('SELECT state FROM player_equipment WHERE user_id=? AND id=?').get(s.user_id, id);
                if (!current)
                    fail('Trang bị không còn thuộc tài khoản.');
                this.db.exec('COMMIT');
                return { replayed: true, _client_cache_update: { equip: { _equip: { update: { [id]: JSON.parse(String(current.state)) }, remove: [] } } } };
            }
            const row = this.db.prepare('SELECT state FROM player_equipment WHERE user_id=? AND id=?').get(s.user_id, id);
            if (!row)
                fail('Trang bị không thuộc tài khoản.');
            const before = equipmentClientState(JSON.parse(row.state)), cfg = equips[String(before.c_id)];
            const profile = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile);
            // Hồ sơ mới chỉ lưu show_name; level1 đến từ fixture user_status, như Admin detail.
            const playerLevel = profile.level ?? 1, next = before.lv + Number(lvs), cap = Math.min(Object.keys(levels).length, playerLevel);
            if (!cfg || !Number.isSafeInteger(playerLevel) || playerLevel < 1 || !Number.isSafeInteger(before.lv) || before.lv < 1 || next > cap)
                fail('Cấp trang bị vượt config/cấp người chơi.');
            let cost = 0;
            for (let lv = before.lv; lv < next; lv++) {
                const c = levels[String(lv)], coefficient = c?.['quality' + cfg.quality];
                if (!c || !Number.isSafeInteger(coefficient) || coefficient < 0 || !Number.isSafeInteger(c.metal) || c.metal < 0 || !Array.isArray(c.need_item) || c.need_item.length)
                    fail('Chi phí cường hóa ngoài schema đã xác minh.');
                cost = Math.floor(cost + c.metal * (coefficient * 0.01));
            }
            const balance = profile.metal ?? 0; // Lua refreshEquipInfo342 mặc định0 khi profile thiếu metal.
            if (!Number.isSafeInteger(cost) || !Number.isSafeInteger(balance) || balance < cost)
                fail('Không đủ Kim loại để cường hóa.');
            const after = { ...before, lv: next }, updated = { ...profile, metal: balance - cost };
            this.db.prepare('UPDATE player_equipment SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(after), s.user_id, id);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(updated), s.user_id);
            audit(this.db, null, 'factory.equip_levelup', s.user_id, 'Cường hóa theo config/chi phí client', { equipment: before, metal: balance }, { equipment: after, metal: updated.metal });
            if (key)
                this.db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(s.user_id, key, 'factory.equip_levelup', fingerprint, '{}', Date.now());
            this.db.exec('COMMIT');
            return { _client_cache_update: { equip: { _equip: { update: { [id]: after }, remove: [] } } } };
        }
        catch (error) {
            this.db.exec('ROLLBACK');
            throw error;
        }
    }
}
