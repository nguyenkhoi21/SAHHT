import { aetherEvent, aetherPhase } from './aether-source.js';
import { CombatPowerService } from './combat-power.js';
import { contentReceipt } from './content-receipt.js';
import { auxInventory, auxKinds, validateAuxiliaryFormation } from './auxiliary-state.js';
import { readConfigSync } from './local-content.js';
import { naturalFormationSlots } from './player-vitals.js';
import { audit } from '../admin/admin.audit.js';
import { godfieldSource, godfieldSchedules } from './godfield-source.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
const empty = (n) => Object.fromEntries(Array.from({ length: 10 }, (_, i) => [i, Array(n).fill('0')]));
const occupied = (id) => !['-1', '0'].includes(id);
const kinds = ['gem', 'soul', 'medal', 'god_stone', 'talisman'];
// game_god_adjustment.sendChangedTeamDataAll: một ô 0 tại vị trí thế trận,
// năm chính còn lại, ba dự bị. Không dùng alignment của đội thường làm mặc định.
export function emptyGodfield() {
    const state = { god_field_ids: {} };
    for (let t = 1; t <= 3; t++) {
        state.god_field_ids[t] = ['0', ...Array(8).fill('-1')];
        state['equip_pos_' + t] = empty(4);
        for (const k of kinds)
            state[k + '_pos_' + t] = empty(auxKinds[k].slots);
    }
    return state;
}
export function godfieldState(db, id) {
    const r = db.prepare('SELECT state FROM godfield_formations WHERE user_id=?').get(id);
    const state = r ? JSON.parse(String(r.state)) : emptyGodfield();
    // Tướng bị tiêu hao/xóa bởi chức năng gốc không tạo actor ma; chỉ projection,
    // không tự sửa kho hoặc đội hình thường khi đọc.
    const owned = new Set(db.prepare('SELECT id FROM player_heroes WHERE user_id=?').all(id).map(r => String(r.id)));
    for (const t of ['1', '2', '3'])
        state.god_field_ids[t] = state.god_field_ids[t].map((h) => occupied(h) && !owned.has(h) ? '-1' : h);
    return state;
}
export function godfieldTeam(state, t) {
    const grid = state.god_field_ids[t], hole = grid.indexOf('0');
    const physical = grid.map((_, i) => i).filter(i => i !== hole), ids = physical.map(i => grid[i]);
    const form = { alignment: [ids.slice(0, 5), [...ids.slice(5), '-1', '-1']], formation: { current: hole + 1, own: [hole + 1] }, equip_pos: {} };
    for (const k of ['equip', ...kinds]) {
        form[k + '_pos'] = empty(k === 'equip' ? 4 : auxKinds[k].slots);
        physical.forEach((p, i) => form[k + '_pos'][i] = state[k + '_pos_' + t][p]);
    }
    return form;
}
export class GodfieldService {
    db;
    constructor(db) {
        this.db = db;
    }
    assertUnlocked(id) { const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id), level = row ? JSON.parse(String(row.profile)).level ?? 1 : 0, required = readConfigSync('inreview')['174'].show_lv; if (level < required)
        fail('Thần Vực mở từ cấp ' + required + '.'); }
    packet(id, state = godfieldState(this.db, id)) {
        const power = new CombatPowerService(this.db), out = { ...state };
        for (let t = 1; t <= 3; t++)
            out['god_combat_' + t] = power.calculate(id, false, { formation: godfieldTeam(state, t), scope: 'godfield' }).combat;
        out.god_combat = out.god_combat_1 + out.god_combat_2 + out.god_combat_3;
        out.is_formation = Object.values(state.god_field_ids).every((team) => team.slice(0, 6).some(occupied));
        return out;
    }
    save(s, p) {
        this.assertUnlocked(s.user_id);
        const args = [...p].filter(([k]) => !['request_id', 'method', 'rans', 'mk', 'user_token'].includes(k)).sort(([a], [b]) => a.localeCompare(b));
        return contentReceipt(this.db, s.user_id, 'god_field.set_god_field', p.get('request_id'), args, () => {
            const state = this.updatedState(s, p, godfieldState(this.db, s.user_id));
            const before = this.db.prepare('SELECT state FROM godfield_formations WHERE user_id=?').get(s.user_id);
            this.db.prepare('INSERT INTO godfield_formations VALUES(?,?,1,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state,revision=revision+1,updated_at=excluded.updated_at').run(s.user_id, JSON.stringify(state), Date.now());
            audit(this.db, null, 'godfield.formation.save', s.user_id, 'Lưu ba đội Thần Vực riêng; không sửa đội hình thường', before ? JSON.parse(String(before.state)) : null, state);
            return this.packet(s.user_id);
        }, () => ({ ...this.packet(s.user_id), replayed: true }));
    }
    // Dùng cùng validation cho Godfield và bản đội riêng theo mùa của Thần Điện.
    updatedState(s, p, initial) {
        this.assertUnlocked(s.user_id);
        const state = structuredClone(initial), heroes = Object.fromEntries(this.db.prepare('SELECT id,config_id FROM player_heroes WHERE user_id=?').all(s.user_id).map(h => [String(h.id), Number(h.config_id)]));
        const profile = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile)), limits = naturalFormationSlots(profile.level ?? 1), defs = readConfigSync('character_detail');
        const parse = (key, n) => { const values = p.getAll(key); if (values.length !== 1)
            fail('Thiếu hoặc trùng ' + key); const v = values[0].split('_'); if (v.length !== n || v.some(x => !x))
            fail('Sai cấu trúc ' + key); return v; };
        // init gốc mở lưới open53; judgeAddHero kiểm riêng tổng chính/dự bị theo cấp.
        const mask = godfieldSource().slotMasks.open53;
        const used = new Set();
        for (let t = 1; t <= 3; t++) {
            const grid = parse('god_formation_' + t, 9), hole = grid.indexOf('0');
            if (hole < 0 || hole > 5 || grid.filter(v => v === '0').length !== 1)
                fail('Mỗi đội cần đúng một ô thế trận trống trong sáu ô chính.');
            let main = 0, reserve = 0;
            for (let i = 0; i < 9; i++)
                if (occupied(grid[i])) {
                    const h = grid[i];
                    if (!mask?.[i])
                        fail('Vị trí Thần Vực chưa mở theo cấp.');
                    if (!heroes[h] || !defs[heroes[h]]?.skill_num || /^5[0-5]-/.test(h))
                        fail('Tướng không thuộc tài khoản hoặc không được ra trận.');
                    if (used.has(h))
                        fail('Một tướng chỉ được ở một ô trong ba đội Thần Vực.');
                    used.add(h);
                    if (i < 6)
                        main++;
                    else
                        reserve++;
                }
            if (main > Math.min(5, limits.position_num) || reserve > Math.min(3, limits.alternate_num))
                fail('Số tướng vượt ô đã mở theo cấp nhân vật.');
            if (main === 0 && reserve > 0)
                fail('Đội có dự bị phải có tướng chính.');
            state.god_field_ids[t] = grid;
            for (let i = 0; i < 10; i++) {
                const suffix = i < 5 ? `${t * 2 + 1}${i + 1}` : `${t * 2 + 2}${i - 4}`, key = 'equip_' + suffix;
                if (p.has(key))
                    state['equip_pos_' + t][i] = parse(key, 4);
            }
            for (const k of kinds)
                for (let i = 0; i < 9; i++) {
                    const key = `${k}_${t}_${i + 1}`;
                    if (p.has(key))
                        state[k + '_pos_' + t][i] = parse(key, auxKinds[k].slots);
                }
        }
        this.validateItems(s.user_id, state);
        return state;
    }
    validateItems(id, state) {
        const equipment = Object.fromEntries(this.db.prepare('SELECT id,state FROM player_equipment WHERE user_id=?').all(id).map(r => [String(r.id), JSON.parse(String(r.state))])), defs = readConfigSync('equip'), used = new Set(), aux = auxInventory(this.db, id), counts = {};
        for (let t = 1; t <= 3; t++) {
            const grid = state.god_field_ids[t];
            for (let i = 0; i < 10; i++) {
                const e = state['equip_pos_' + t][i];
                for (let n = 0; n < 4; n++)
                    if (e[n] !== '0') {
                        if (i >= 9 || !occupied(grid[i]))
                            fail('Không thể gắn đồ vào ô không có tướng.');
                        if (!equipment[e[n]] || defs[equipment[e[n]].c_id]?.sort !== n + 1 || used.has(e[n]))
                            fail('Trang bị không thuộc tài khoản, sai loại hoặc trùng trong ba đội.');
                        used.add(e[n]);
                    }
            }
            const form = godfieldTeam(state, t);
            validateAuxiliaryFormation(this.db, id, form, new URLSearchParams());
            for (const k of kinds)
                for (const ids of Object.values(state[k + '_pos_' + t]))
                    for (const key of ids)
                        if (key !== '0') {
                            counts[k + ':' + key] = (counts[k + ':' + key] ?? 0) + 1;
                            const own = aux[k][key];
                            if (!own || counts[k + ':' + key] > (['soul', 'talisman'].includes(k) ? 1 : own.quantity))
                                fail('Vật phẩm phụ thiếu hoặc đã gắn ở đội Thần Vực khác.');
                        }
        }
    }
    index(id) { let aether = null; try {
        const e = aetherEvent(this.db, Date.now()), at = e.qa ? Number(e.qa_time) + Date.now() - Number(e.qa_updated) : Date.now(), text = (v) => new Date(v + 7 * 3600000).toISOString().slice(0, 19).replace('T', ' ');
        aether = { id: e.id, version: e.version, start_text: text(e.start_at), end_text: text(e.end_at), step: aetherPhase(e.start_at, e.end_at, at).step, managed: !!e.managed, qa: !!e.qa };
    }
    catch (e) {
        if (e.statusCode !== 422)
            throw e;
    } return { ...this.packet(id), cosmic_war: { version: 0, step: 0 }, guild_high_war_version: aether?.version ?? 0, aether_event: aether, temple_farmers: {}, status: 0, weekday: 1, is_enter: false }; }
    ranking(page) {
        const n = Number(page ?? 0);
        if (!Number.isInteger(n) || n < 0 || n > 4)
            fail('Trang xếp hạng không hợp lệ.');
        const rows = this.db.prepare('SELECT g.user_id,p.game_uid,p.role,s.profile FROM godfield_formations g JOIN player_profiles p ON p.user_id=g.user_id JOIN player_state s ON s.user_id=g.user_id').all().map(r => { const p = JSON.parse(String(r.profile)); return { userId: Number(r.user_id), uid: String(r.game_uid), role: Number(r.role), name: p.show_name ?? '', level: p.level ?? 1, combat: this.packet(Number(r.user_id)).god_combat }; }).sort((a, b) => b.combat - a.combat || a.userId - b.userId);
        return { rank: Object.fromEntries(rows.slice(n * 20, (n + 1) * 20).map(({ userId, ...r }, i) => [String(n * 20 + i + 1), r])), server_name: 'SAHHT LOCAL', tieRule: 'LOCAL: cùng lực chiến xếp UID ổn định; nguồn chưa có quy tắc đồng hạng server.' };
    }
    diagnostics(id) { return { ...this.packet(id), calendar: godfieldSchedules(), teams: [1, 2, 3].map(t => ({ team: t, ...new CombatPowerService(this.db).calculate(id, false, { formation: godfieldTeam(godfieldState(this.db, id), t), scope: 'godfield' }) })), history: this.db.prepare("SELECT action,created_at,summary FROM admin_audit WHERE target_user_id=? AND action='godfield.formation.save' ORDER BY id DESC LIMIT 20").all(id), scope: 'LOCAL; chưa triển khai Online', limitations: ['Đấu Tranh Bá tích điểm đã nối LOCAL; vòng cuối tuần và năm điểm đến còn đang khôi phục.', 'Lực chiến dùng stat engine chung trên bảng gắn riêng; các bonus thống soái chưa phục hồi không được tự giả lập.'] }; }
}
