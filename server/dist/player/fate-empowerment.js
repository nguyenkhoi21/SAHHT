import { auxPreviewRewards } from './auxiliary-state.js';
import { randomInt, randomUUID } from 'node:crypto';
import { readConfigSync } from './local-content.js';
const cfg = readConfigSync;
export function fateRewardPreview(rewards) { return auxPreviewRewards(rewards).map(r => r?.kind === 'transformed_hero' ? [5, r.configId, r.quantity] : r?.kind === 'empowered_gem' ? [50, r.configId, r.quantity] : r); }
export const fateFail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
export function fatePreset(value) {
    const c = cfg('equip_gem_fate')[String(value.configId)], skill = cfg('equip_gem_fate_skill')[String(value.skillId)];
    if (!c || !skill || ![4, 5, 6].includes(c.quality) || value.imprintGrade && value.imprintGrade !== 'none')
        fateFail('Cấu hình đá không hợp lệ. Thác Ấn tạo Đá Điểm Hóa riêng, không gắn cấp In lên viên đá.');
    const possible = Object.values(cfg('equip_gem_fate_word')).some((w) => (w['level' + c.quality + '_lack'] ?? []).some(([id]) => id === Number(value.skillId)));
    if (!possible)
        fateFail('Phẩm Ban Sức này không thể xuất hiện ở cấp đá đã chọn theo nguồn.');
    return { c_id: Number(value.configId), skill: { sid: Number(value.skillId), sort: skill.skill_sort } };
}
export function fateMaterials(db, userId) { const rows = (kind) => Object.fromEntries(db.prepare('SELECT config_id,quantity FROM player_fate_materials WHERE user_id=? AND kind=?').all(userId, kind).map(r => [String(r.config_id), Number(r.quantity)])); return { fate_word: rows('word'), fate_stone: rows('stone') }; }
export function fateSnapshot(db, userId) { const owners = new Map(); for (const row of db.prepare('SELECT id,state FROM player_equipment WHERE user_id=?').all(userId))
    for (const gem of JSON.parse(String(row.state)).gem_fate ?? [])
        if (typeof gem === 'string' && gem.includes('-'))
            owners.set(gem, String(row.id)); return { ...fateMaterials(db, userId), gem_special: Object.fromEntries(db.prepare('SELECT id,state FROM player_fate_special WHERE user_id=?').all(userId).map(r => [String(r.id), { ...JSON.parse(String(r.state)), owner: owners.get(String(r.id)) ?? '' }])), word_round: Object.fromEntries(db.prepare('SELECT word_id,rounds FROM player_fate_pity WHERE user_id=?').all(userId).map(r => [String(r.word_id), Number(r.rounds)])) }; }
export function fateCache(db, userId) { const s = fateSnapshot(db, userId), cache = (rows) => ({ update: Object.fromEntries(Object.entries(rows).filter(([, n]) => n > 0)), remove: Object.entries(rows).filter(([, n]) => n === 0).map(([id]) => id) }); return { _gem_special: { update: s.gem_special, remove: [] }, _fate_word: cache(s.fate_word), _fate_stone: cache(s.fate_stone), word_round: { update: s.word_round, remove: [] } }; }
export function fateClientSnapshot(db, userId) { const s = fateSnapshot(db, userId); return { ...s, fate_word: Object.fromEntries(Object.entries(s.fate_word).filter(([, n]) => n > 0)), fate_stone: Object.fromEntries(Object.entries(s.fate_stone).filter(([, n]) => n > 0)) }; }
export function fateMaterialDelta(db, userId, kind, id, delta) {
    const table = kind === 'word' ? 'equip_gem_fate_word' : kind === 'stone' ? 'equip_gem_fate_stone' : '';
    if (!table || !cfg(table)[String(id)] || !Number.isSafeInteger(delta))
        fateFail('Vật liệu Ban Sức không hợp lệ.');
    const old = Number(db.prepare('SELECT quantity FROM player_fate_materials WHERE user_id=? AND kind=? AND config_id=?').get(userId, kind, id)?.quantity ?? 0), next = old + delta;
    if (next < 0 || next > 1000000)
        fateFail('Không đủ vật liệu Ban Sức hoặc vượt giới hạn kho.');
    db.prepare('INSERT INTO player_fate_materials VALUES(?,?,?,?) ON CONFLICT(user_id,kind,config_id) DO UPDATE SET quantity=excluded.quantity').run(userId, kind, id, next);
}
export function createFateSpecial(db, userId, preset) { const state = { ...fatePreset(preset), createdAt: Date.now() }, id = state.c_id + '-' + randomUUID(); db.prepare('INSERT INTO player_fate_special VALUES(?,?,?,?)').run(userId, id, state.c_id, JSON.stringify(state)); return { id, ...state }; }
// Consumer game_util.bloodStone.getEquipStoneEffect2: nhóm cùng sort, đủ use_num,
// chọn dòng yếu nhất trong use_num viên mạnh nhất. Không phụ thuộc loại stat.
export function fateLineEffects(db, userId, equipment) {
    const groups = new Map(), seen = new Set();
    for (const id of equipment.gem_fate ?? []) {
        if (typeof id !== 'string' || !id.includes('-'))
            continue;
        if (seen.has(id))
            fateFail('Một viên đá xuất hiện hai lần trên trang bị.');
        seen.add(id);
        const row = db.prepare('SELECT state FROM player_fate_special WHERE user_id=? AND id=?').get(userId, id);
        if (!row)
            continue;
        const h = JSON.parse(String(row.state)), s = cfg('equip_gem_fate_skill')[h.skill.sid];
        if (!s)
            continue;
        groups.set(s.skill_sort, [...(groups.get(s.skill_sort) ?? []), h.skill.sid]);
    }
    return [...groups].map(([family, ids]) => { ids.sort((a, b) => a - b); const need = cfg('equip_gem_fate_skill')[ids[0]].use_num, active = ids.length >= need, sid = active ? ids[ids.length - need] : ids[0], skill = cfg('equip_gem_fate_skill')[sid]; return { family, count: ids.length, required: need, active, sid, ...skill, battleStatus: !active ? 'INACTIVE' : family === 6 ? 'STAT_SUPPORTED' : 'IMPLEMENTED_UNVERIFIED' }; });
}
export function fateGemDefinition(id) { return cfg('equip_gem_fate')[String(id).split('-')[0]]; }
export class FateEmpowermentService {
    db;
    random;
    constructor(db, random = randomInt) {
        this.db = db;
        this.random = random;
    }
    available(userId, id) {
        if (!/^\d+-(?:[a-f0-9-]+)$/.test(id))
            fateFail('Mã đá Ban Sức không hợp lệ.');
        const row = this.db.prepare('SELECT state FROM player_fate_special WHERE user_id=? AND id=?').get(userId, id);
        if (!row)
            fateFail('Đá Ban Sức không thuộc tài khoản.');
        if (this.db.prepare("SELECT 1 FROM player_equipment e,json_each(e.state,'$.gem_fate') g WHERE e.user_id=? AND CAST(g.value AS TEXT)=?").get(userId, id))
            fateFail('Hãy tháo đá khỏi trang bị trước khi Ban Sức/Điểm Hóa/Thác Ấn.');
        return JSON.parse(String(row.state));
    }
    weighted(pool) { if (!pool.length || pool.some(([id, w]) => !cfg('equip_gem_fate_skill')[id] || !Number.isSafeInteger(w) || w <= 0))
        fateFail('Thiếu phân bố Ban Sức hợp lệ.'); const total = pool.reduce((n, r) => n + r[1], 0); let roll = this.random(total); if (!Number.isInteger(roll) || roll < 0 || roll >= total)
        throw Error('RNG ngoài giới hạn'); for (const [id, w] of pool) {
        if (roll < w)
            return id;
        roll -= w;
    } throw Error('Phân bố rỗng'); }
    execute(userId, method, p) {
        const profile = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(userId).profile)), required = Math.max(cfg('inreview')['226']?.show_lv ?? 1, cfg('server_inreview')['226']?.show_lv ?? 1);
        if ((profile.level ?? 1) < required)
            fateFail('Cấp người chơi chưa mở Ban Sức Vận Mệnh.');
        const id = p.get('gem_id') ?? '', special = id.includes('-'), base = fateGemDefinition(id);
        if (!base || ![4, 5, 6].includes(base.quality))
            fateFail('Ban Sức/Điểm Hóa/Thác Ấn hỗ trợ đá cấp4–6 theo bảng nguồn.');
        let stone = special ? this.available(userId, id) : null, sid = 0;
        if (method === 'gem_fate.empowering') {
            const rule = cfg('equip_gem_fate_succinct')['1'];
            if (base.quality !== rule.succinct_quality)
                fateFail('Ban Sức cơ bản chỉ dùng đá cấp4 theo quy tắc nguồn; cấp5–6 dùng Điểm Hóa.');
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(userId), profile = JSON.parse(String(row.profile));
            for (const [t, c, n] of rule.succinct_need) {
                if (t === 9) {
                    if ((profile.coin ?? 0) < n)
                        fateFail('Không đủ Kim cương Ban Sức.');
                    profile.coin -= n;
                }
                else if (t === 6) {
                    const own = Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(userId, c)?.quantity ?? 0);
                    if (own < n)
                        fateFail('Không đủ Thủy Tinh Empower.');
                    this.db.prepare('UPDATE player_items SET quantity=quantity-? WHERE user_id=? AND config_id=?').run(n, userId, c);
                }
                else
                    fateFail('Chi phí Ban Sức chưa hỗ trợ.');
            }
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), userId);
            sid = this.weighted(rule.succinct_skill);
        }
        else if (method === 'gem_fate.printing') {
            const wid = Number(p.get('word_id')), word = cfg('equip_gem_fate_word')[wid], pool = word?.['level' + base.quality + '_lack'];
            if (!word || !Array.isArray(pool) || !pool.length)
                fateFail('Đá Điểm Hóa không có nhóm kết quả cho cấp đá này.');
            fateMaterialDelta(this.db, userId, 'word', wid, -1);
            const rounds = Number(this.db.prepare('SELECT rounds FROM player_fate_pity WHERE user_id=? AND word_id=?').get(userId, wid)?.rounds ?? 0), min = word.minimum_name.find((r) => r[0] === base.quality);
            const best = pool.filter(([x]) => cfg('equip_gem_fate_skill')[x].skill_sort === word.sort).sort(([a], [b]) => b - a)[0];
            if (!best || !min || min[1] < 1)
                fateFail('Thiếu quy tắc bảo hiểm Điểm Hóa.');
            const chance = Math.min(100, best[1] + rounds / min[1] * (100 - best[1]));
            sid = this.random(1000000) < Math.floor(chance * 10000) ? best[0] : this.weighted(pool.filter(([x]) => x !== best[0]).length ? pool.filter(([x]) => x !== best[0]) : pool);
            const success = cfg('equip_gem_fate_skill')[sid].skill_sort === word.sort && cfg('equip_gem_fate_skill')[sid].skill_quality >= min[2];
            this.db.prepare('INSERT INTO player_fate_pity VALUES(?,?,?) ON CONFLICT(user_id,word_id) DO UPDATE SET rounds=excluded.rounds').run(userId, wid, success ? 0 : rounds + 1);
        }
        else if (method === 'gem_fate.transfer') {
            if (!stone)
                fateFail('Chỉ Thác Ấn viên đá đã Ban Sức.');
            const material = Number(p.get('stone_id')), m = cfg('equip_gem_fate_stone')[material];
            if (!m)
                fateFail('Đá In chưa được xác minh.');
            const entry = Object.entries(cfg('equip_gem_fate_word')).find(([, w]) => w.sort === stone.skill.sort && w.skill_quality === cfg('equip_gem_fate_skill')[stone.skill.sid].skill_quality && w.level === m.level);
            if (!entry)
                fateFail('Không có Đá Điểm Hóa tương ứng trạng thái Thác Ấn.');
            fateMaterialDelta(this.db, userId, 'stone', material, -1);
            fateMaterialDelta(this.db, userId, 'word', Number(entry[0]), 1);
            this.db.prepare('DELETE FROM player_fate_special WHERE user_id=? AND id=?').run(userId, id);
            this.normalDelta(userId, stone.c_id, 1);
            return { gem_oid: String(stone.c_id), reward: [[109, Number(entry[0]), 1]], removedSpecial: [id], imprintResult: { wordId: Number(entry[0]), sourceSkill: stone.skill, imprintMaterial: material, notice: 'Thác Ấn trích dòng thành Đá Điểm Hóa; viên đá trở về thường.' } };
        }
        else
            fateFail('Thao tác Ban Sức chưa hỗ trợ.');
        if (special) {
            stone.skill = { sid, sort: cfg('equip_gem_fate_skill')[sid].skill_sort };
            this.db.prepare('UPDATE player_fate_special SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(stone), userId, id);
            return { gem_oid: id, reward: [] };
        }
        this.normalDelta(userId, Number(id), -1);
        const created = createFateSpecial(this.db, userId, { configId: Number(id), skillId: sid });
        return { gem_oid: created.id, reward: [] };
    }
    normalDelta(userId, id, delta) { const own = Number(this.db.prepare('SELECT quantity FROM player_fate_gems WHERE user_id=? AND config_id=?').get(userId, id)?.quantity ?? 0), next = own + delta; if (next < 0 || next > 1000000)
        fateFail('Không đủ đá hoặc vượt giới hạn kho.'); this.db.prepare('INSERT INTO player_fate_gems VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=excluded.quantity').run(userId, id, next); }
    catalog(userId) { return { source: 'VN runtime + Lua bloodStone', normalGems: cfg('equip_gem_fate'), skills: cfg('equip_gem_fate_skill'), words: cfg('equip_gem_fate_word'), imprints: cfg('equip_gem_fate_stone'), empower: cfg('equip_gem_fate_succinct')['1'], ...fateSnapshot(this.db, userId), equipment: this.db.prepare('SELECT id,state FROM player_equipment WHERE user_id=?').all(userId).map(r => ({ id: r.id, gems: JSON.parse(String(r.state)).gem_fate ?? [], lines: fateLineEffects(this.db, userId, JSON.parse(String(r.state))) })), limitations: ['RNG LOCAL: trọng số từ bảng; tăng xác suất/bảo hiểm theo consumer Lua, không khẳng định bit-exact server gốc.', 'Thác Ấn tạo vật liệu Điểm Hóa riêng; không có cấp In thứ hai trên đá.', 'Combat v4 có bộ xử lý10 họ theo tooltip VN; thứ tự đồng thời/chọn đích dùng adapter LOCAL, thời hạn Tinh Thần A có mâu thuẫn3/2lượt. Xem chẩn đoán chiến đấu để biết bộ trùng không cộng dồn.'] }; }
}
