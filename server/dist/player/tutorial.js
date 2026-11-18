import { readConfigSync as cfg } from './local-content.js';
import { createBaseHero, createBaseEquipment } from './definitions.js';
import { audit } from '../admin/admin.audit.js';
import { contentReceipt } from './content-receipt.js';
import { characterName } from './definitions.js';
const fail = (m) => { throw Object.assign(Error(m), { statusCode: 422 }); };
export class TutorialService {
    db;
    constructor(db) {
        this.db = db;
    }
    exists(id) { return !!this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(id); }
    create(id, username, role) {
        const definition = cfg('role_detail')[role];
        if (!definition)
            fail('Nhân vật khởi đầu không có trong role_detail.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (this.exists(id)) {
                const p = this.profile(id);
                if (p._local_tutorial?.role !== role)
                    fail('Tài khoản đã có nhân vật; không tạo lại hoặc đổi phần thưởng khởi đầu.');
                this.db.exec('COMMIT');
                return { created: false };
            }
            const slots = Array.from({ length: 10 }, (_, i) => Number(definition['position' + (i + 1)] ?? 0)), formation = { alignment: [Array(5).fill('-1'), Array(5).fill('-1')], formation: { own: [1], current: 1 }, equip_pos: Object.fromEntries(Array.from({ length: 10 }, (_, i) => [String(i), Array(4).fill('0')])) }, ids = [];
            const heroIds = [...slots.filter(Boolean), ...(definition.character_bag ?? [])];
            for (let i = 0; i < heroIds.length; i++) {
                const cid = Number(heroIds[i]), hid = 'localstart' + id + '-' + (i + 1), h = createBaseHero(hid, cid, cfg('character_detail')[cid]);
                ids.push(hid);
                this.db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(id, hid, cid, JSON.stringify(h));
            }
            let index = 0;
            slots.forEach((cid, i) => { if (cid)
                formation.alignment[i < 5 ? 0 : 1][i % 5] = ids[index++]; });
            const p = { show_name: username, level: 1, exp: 0, coin: 0, silver: 300, food: 0, guide: { '1': 1 }, _local_tutorial: { version: 1, role, initialSilverEvidence: 'Người dùng xác nhận bản gốc tặng sẵn300 Vàng27/10/2026', phase: 'opening', startedAt: Date.now(), rewardPolicy: 'role_detail một lần; trận mở đầu chỉ là kịch bản, không phát thưởng giả.' } };
            this.db.prepare('INSERT INTO player_state VALUES(?,?,?)').run(id, JSON.stringify(p), JSON.stringify(formation));
            for (const [cid, n] of definition.item ?? []) {
                const item = cfg('item')[cid];
                if (!item || !Number.isSafeInteger(n) || n < 1 || n > item.stack)
                    fail('Vật phẩm khởi đầu sai config.');
                this.db.prepare('INSERT INTO player_items VALUES(?,?,?)').run(id, cid, n);
            }
            for (const [cid, n] of definition.equip ?? [])
                for (let i = 0; i < n; i++) {
                    const eid = 'localstarte' + id + '-' + cid + '-' + i;
                    this.db.prepare('INSERT INTO player_equipment VALUES(?,?,?,?)').run(id, eid, cid, JSON.stringify(createBaseEquipment(eid, cid, cfg('equip')[cid])));
                }
            this.db.prepare('UPDATE player_profiles SET role=? WHERE user_id=?').run(role, id);
            audit(this.db, null, 'tutorial.create', id, 'Tân Thủ từ role_detail VN; không áp dụng cho tài khoản cũ', null, { role, heroes: ids });
            this.db.exec('COMMIT');
            return { created: true };
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    profile(id) { const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id); if (!row)
        fail('Chưa tạo nhân vật.'); return JSON.parse(String(row.profile)); }
    rename(id, value) { if (typeof value !== 'string')
        fail('Tên nhân vật không hợp lệ.'); const name = characterName(value); this.db.exec('BEGIN IMMEDIATE'); try {
        const p = this.profile(id), t = p._local_tutorial;
        if (!t || t.phase === 'complete')
            fail('Đặt tên lần đầu chỉ dành cho Tân Thủ; đổi tên sau đó cần Thẻ Đổi Tên.');
        if (t.named) {
            if (p.show_name !== name)
                fail('Đã đặt tên Tân Thủ; muốn đổi tên hãy dùng Thẻ Đổi Tên.');
            this.db.exec('COMMIT');
            return { replayed: true };
        }
        p.show_name = name;
        t.named = true;
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
        audit(this.db, null, 'tutorial.rename', id, 'Đặt tên Tân Thủ một lần; không tiêu thẻ đổi tên', null, { name });
        this.db.exec('COMMIT');
        return { named: true };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    statistic(id, value) { const n = Number(value); if (!Number.isSafeInteger(n) || n < 1 || n > 1000)
        fail('Bước thống kê Tân Thủ không hợp lệ.'); const p = this.profile(id); if (p._local_tutorial) {
        p._local_tutorial.statisticsStep = Math.max(p._local_tutorial.statisticsStep ?? 0, n);
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
    } return { recorded: true, notice: 'Chỉ thống kê; không đánh dấu hoàn thành hướng dẫn hoặc cấp thưởng.' }; }
    opening(id, key) { return contentReceipt(this.db, id, 'tutorial.opening_complete', key, {}, () => { const p = this.profile(id); if (!p._local_tutorial)
        fail('Tài khoản cũ không bị đưa lại Tân Thủ.'); if (p._local_tutorial.phase === 'opening') {
        p._local_tutorial.phase = 'guide';
        p._local_tutorial.openingAt = Date.now();
        p.guide = { ...p.guide, '1': Math.max(2, p.guide?.['1'] ?? 1) };
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
    } return { guide: p.guide, tutorial: p._local_tutorial }; }, () => ({ guide: this.profile(id).guide, replayed: true })); }
    guide(id, step) {
        const p = this.profile(id), t = p._local_tutorial;
        if (!t || t.phase === 'complete')
            return false;
        const current = p.guide?.['1'] ?? 1;
        if (!cfg('guide')[1]?.[step] || step < current)
            fail('Bước Tân Thủ không hợp lệ.');
        if (step > current + 5)
            fail('Không thể bỏ qua toàn bộ hướng dẫn Tân Thủ.');
        if (step >= 8 && !this.db.prepare("SELECT 1 FROM player_stage_steps WHERE user_id=? AND city='100'").get(id))
            fail('Hoàn thành trận khởi đầu trên map100 trước.');
        if (step >= 18 && !this.db.prepare("SELECT 1 FROM player_gacha WHERE user_id=? AND gacha_id='999' AND draws>=1").get(id))
            fail('Hoàn thành lượt Chiêu Mộ hướng dẫn999 trước.');
        if (step === 27) {
            const form = JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(id).formation));
            if (form.alignment[0].filter((v) => !['0', '-1'].includes(v)).length < 2)
                fail('Xếp đồng đội vừa chiêu mộ vào đội trước khi hoàn tất Tân Thủ.');
            t.phase = 'complete';
            t.completedAt = Date.now();
        }
        p.guide = { ...p.guide, '1': step };
        if (t.phase === 'opening')
            t.phase = 'guide';
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
        return true;
    }
    diagnostics(id) { const p = this.profile(id), t = p._local_tutorial, role = t?.role; return { state: t ?? { phase: 'legacy', notice: 'Tài khoản có trước Pha28: giữ nguyên, không tự phát lại hướng dẫn.' }, guide: p.guide ?? {}, source: { role: 'role_detail', guide: 'guide[1] / game_guide_controller', opening: 'game_first_opening + battleData.temp' }, resetAllowed: !!t && !(p._local_fullmap || this.db.prepare('SELECT 1 FROM player_map_access WHERE user_id=?').get(id)) && !this.db.prepare("SELECT 1 FROM player_gacha WHERE user_id=? AND gacha_id='999' AND draws>0").get(id), currencyDiagnostic: { silver: p.silver ?? 0, firstRecruitPrice: cfg('gacha')[999].value, initialSilver: 300, evidence: 'Người dùng xác nhận bản gốc có sẵn300 Vàng27/10/2026; role_detail không có số dư.', notice: 'Tạo nhân vật cấp300 một lần; Chiêu Mộ999 vẫn trừ250. Phát lại hướng dẫn không cấp lại.' }, rewards: 'Chỉ cấp role_detail một lần; QA replay không cấp lại; battle/thưởng map dùng ledger gốc.' }; }
    reset(adminId, id, confirmed) { if (!confirmed)
        fail('Cần xác nhận phát lại Tân Thủ trên tài khoản QA.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const p = this.profile(id), d = this.diagnostics(id);
        if (!d.resetAllowed)
            fail('Chỉ phát lại tài khoản Tân Thủ riêng trước khi dùng lượt Chiêu Mộ999, không có override map; không xóa ledger để cấp lại thưởng hoặc hạ account cũ.');
        const before = structuredClone(p);
        p._local_tutorial = { ...p._local_tutorial, phase: 'opening', replay: true, replayedAt: Date.now() };
        p.guide = { ...p.guide, '1': 1 };
        this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
        audit(this.db, adminId, 'tutorial.qa.replay', id, 'Chỉ đổi cờ hướng dẫn; giữ thưởng/level/map/hero/ledger', before, p);
        this.db.exec('COMMIT');
        return this.diagnostics(id);
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
}
