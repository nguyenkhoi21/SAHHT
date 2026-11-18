import { aetherEntityInUse } from './aether-lock.js';
import { beginHotSpend, endHotSpend } from './hot-spending.js';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { readConfigSync } from './local-content.js';
import { PlayerService } from './player.service.js';
import { WelfareService } from './welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { hasOnlyInitialHeroSkills } from './definitions.js';
import { inheritedProgress, rebirthRefund, assertDonorAvailable, progressionChange, inheritancePreview } from './inheritance.js';
export const economyFail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
const cache = new Map();
export function economyConfig(name) {
    if (cache.has(name))
        return cache.get(name);
    const hashes = JSON.parse(readFileSync(new URL('../../../tools/runtime/phase24-source.json', import.meta.url), 'utf8'));
    let data;
    if (hashes[name]) {
        const raw = readFileSync(new URL(`../../../work/runtime-content/configs/${name}.json`, import.meta.url));
        if (createHash('sha256').update(raw).digest('hex') !== hashes[name])
            throw new Error('Nguồn Việt Nam đã đổi hash: ' + name);
        data = JSON.parse(raw.toString());
    }
    else
        data = readConfigSync(name);
    cache.set(name, data);
    return data;
}
export const abilityFields = { 1: 'patk', 2: 'matk', 3: 'def', 4: 'speed', 5: 'hp', 201: 'fire', 202: 'water', 203: 'wind', 204: 'earth', 301: 'fire_dfs', 302: 'water_dfs', 303: 'wind_dfs', 304: 'earth_dfs' };
export function heroExpThreshold(h, lv) { const c = economyConfig('character_detail')[h.c_id], value = economyConfig('character_base')[lv]?.exp * economyConfig('character_base_rate')[c.quality]?.exp_rate; if (!Number.isFinite(value) || value <= 0)
    economyFail('Thiếu ngưỡng EXP tướng.'); return value; }
export function heroStoredExp(h) { let total = Number(h.exp ?? 0); for (let lv = 1; lv < h.lv; lv++)
    total += heroExpThreshold(h, lv); return total; }
export function heroLevelDelta(h, lv) { const c = economyConfig('character_detail')[h.c_id], name = c.evo_kind < 3 ? 'evolution' : c.evo_kind === 3 ? 'evolution_3' : c.evo_kind === 4 ? 'evolution_4' : 'evolution_5', e = economyConfig(name)[h.evo ?? 0], b = economyConfig('break_control')[h.bre ?? 0]; if (!e)
    economyFail('Thiếu bảng tăng cấp.'); const result = { ...h, lv }; for (const field of ['patk', 'matk', 'def', 'speed', 'hp'])
    result[field] += c['growth_' + field] * (lv - h.lv) * (1 + e.all + (field === 'hp' ? (b?.hp_add ?? 0) : 0)); return result; }
export class ProgressionEconomyService {
    db;
    now;
    costs = [];
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    profile(s) { return JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile)); }
    hero(s, id) { if (typeof id !== 'string' || !/^[a-zA-Z0-9-]{1,80}$/.test(id))
        economyFail('Mã tướng không hợp lệ.'); const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, id); if (!row)
        economyFail('Tướng không thuộc tài khoản.'); return JSON.parse(String(row.state)); }
    save(s, h) { this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(h), s.user_id, h.id); }
    saveProfile(s, p) { this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), s.user_id); }
    // Không dùng MAX QA: mọi delta đến từ một thao tác trả phí theo bảng nguồn.
    cost(s, entries, selected = new URLSearchParams(), protectedHero = '') {
        const p = this.profile(s), items = new Map(), used = new Set(), remove = [];
        const fields = { 1: 'food', 2: 'metal', 9: 'coin', 10: 'dirt_silver', 11: 'dirt_gold', 17: 'grace', 18: 'grace_high', 20: 'adv_crystal', 23: 'refine_stone', 33: 'small_forge_stone', 34: 'middle_forge_stone', 35: 'high_forge_stone', 40: 'super_crystal', 41: 'min_fate_stone', 42: 'mid_fate_stone', 43: 'max_fate_stone' };
        for (const [type, id, n] of entries) {
            if (!Number.isSafeInteger(n) || n < 0)
                economyFail('Chi phí cấu hình không hợp lệ.');
            if (!n)
                continue;
            if (type === 6) {
                if (!economyConfig('item')[id])
                    economyFail('Thiếu cấu hình nguyên liệu #' + id);
                const own = items.get(id) ?? Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0);
                if (own < n)
                    economyFail('Thiếu nguyên liệu #' + id);
                items.set(id, own - n);
            }
            else if (type === 5) {
                const candidates = [...new Set(selected.getAll('material').concat(selected.getAll('card')))];
                const chosen = candidates.filter(cid => !used.has(cid) && cid !== protectedHero).filter(cid => this.hero(s, cid).c_id === id).slice(0, n);
                if (chosen.length !== n)
                    economyFail('Chọn đủ thẻ nguyên liệu #' + id);
                const form = JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(s.user_id).formation));
                for (const cid of chosen) {
                    if (aetherEntityInUse(this.db, s.user_id, cid, this.now()))
                        economyFail('Thẻ đang thuộc đội Aether trong mùa; chưa tiêu.');
                    const h = this.hero(s, cid), contains = (v) => v === cid || !!(v && typeof v === 'object' && Object.entries(v).some(([k, x]) => k === cid || contains(x)));
                    if (h.lv !== 1 || h.evo || h.bre || h.super_step || h.element_break || h.remove_avail?.length || !hasOnlyInitialHeroSkills(h) || contains(form) || contains(p) || this.db.prepare("SELECT 1 FROM player_equipment WHERE user_id=? AND json_extract(state,'$.bind_card')=?").get(s.user_id, cid))
                        economyFail('Thẻ nguyên liệu đang dùng/đã nâng/khóa; chưa tiêu.');
                    used.add(cid);
                    remove.push(cid);
                }
            }
            else {
                const f = fields[type];
                if (!f || id !== 0)
                    economyFail('Chi phí chưa hỗ trợ: ' + type);
                if (!Number.isSafeInteger(p[f] ?? 0) || (p[f] ?? 0) < n)
                    economyFail('Không đủ tài nguyên ' + f);
                p[f] -= n;
            }
        }
        for (const [id, q] of items)
            this.db.prepare('UPDATE player_items SET quantity=? WHERE user_id=? AND config_id=?').run(q, s.user_id, id);
        const consumed = remove.map(id => this.hero(s, id));
        this.costs.push({ rewards: entries, heroes: consumed });
        for (const id of remove)
            this.db.prepare('DELETE FROM player_heroes WHERE user_id=? AND id=?').run(s.user_id, id);
        this.saveProfile(s, p);
        return remove;
    }
    packet(s, result) { const cards = new PlayerService(this.db).cards(s, true).cards, items = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id); return { ...result, cards, _client_cache_update: { cards: { cards: { update: cards, remove: result.removed ?? [] } }, item: { items: { update: Object.fromEntries(items.filter(r => Number(r.quantity) > 0).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: items.filter(r => !r.quantity).map(r => String(r.config_id)) } } } }; }
    execute(s, method, p, operation) {
        const key = p.get('request_id') ?? '';
        if (!/^[A-Za-z0-9_.:-]{8,160}$/.test(key))
            economyFail('Thiếu mã thao tác duy nhất; cần client Pha24.');
        const args = [...p].filter(([k]) => !['request_id', 'method', 'rans', 'mk', 'user_token'].includes(k)).sort(([a, av], [b, bv]) => a.localeCompare(b) || av.localeCompare(bv)), hash = createHash('sha256').update(JSON.stringify(args)).digest('hex');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            this.costs = [];
            const old = this.db.prepare('SELECT method,fingerprint,result FROM player_content_operations WHERE user_id=? AND request_key=?').get(s.user_id, key);
            if (old) {
                if (old.method !== method || old.fingerprint !== hash)
                    economyFail('Mã giao dịch đã dùng cho nội dung khác.');
                const result = this.packet(s, { ...JSON.parse(String(old.result)), reward: [], effect: [], removed: [], replayed: true });
                this.db.exec('COMMIT');
                return result;
            }
            beginHotSpend(this.db, s.user_id, method, key, this.now());
            const result = operation ? operation() : method === 'cards.inherit' ? this.inherit(s, p) : method === 'cards.element_break' ? this.breakthrough(s, p) : economyFail('Thao tác tiến trình chưa hỗ trợ.');
            endHotSpend(this.db, s.user_id);
            this.db.prepare('INSERT INTO player_content_operations VALUES(?,?,?,?,?,?)').run(s.user_id, key, method, hash, JSON.stringify(result), this.now());
            audit(this.db, null, method, s.user_id, 'Nâng cấp tự nhiên theo bảng Việt Nam', null, { key, args, result });
            const packet = this.packet(s, result);
            this.db.exec('COMMIT');
            return packet;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    inherit(s, p) {
        if (p.has('preview_hash') && p.get('preview_hash') !== inheritancePreview(this.db, s.user_id, p.get('master') ?? '', p.get('student') ?? '', p.get('use_exp_ball') === '1').fingerprint)
            economyFail('Kế Thừa đã thay đổi; mở lại bản xem trước.');
        const target = this.hero(s, p.get('student')), master = p.get('master'), source = master ? this.hero(s, master) : null, use = p.get('use_exp_ball');
        if (!['0', '1'].includes(use ?? ''))
            economyFail('Cờ EXP dự trữ không hợp lệ.');
        for (const h of [source, target])
            if (h && (!Number.isSafeInteger(h.lv) || h.lv < 1 || h.lv > 255 || !Number.isSafeInteger(h.exp ?? 0) || (h.exp ?? 0) < 0))
                economyFail('State cấp/EXP tướng không hợp lệ.');
        if (source?.id === target.id)
            economyFail('Hai ô kế thừa phải khác nhau.');
        if (!source && use !== '1')
            economyFail('Cần tướng nguồn hoặc EXP dự trữ.');
        if (source)
            assertDonorAvailable(this.db, s.user_id, source);
        const transfer = source ? inheritedProgress(source, target) : null, refund = source ? rebirthRefund(this.db, s.user_id, source) : { rewards: [], evidence: 'Chỉ dùng bóng EXP.' };
        const profile = this.profile(s), cfg = economyConfig('character_detail')[target.c_id], cap = Math.min(255, (profile.level ?? 1) + 5, cfg.level_max > 1 ? cfg.level_max : 255);
        if (target.lv >= cap && !source)
            economyFail('Tướng đích đã đạt giới hạn cấp.');
        if (!cfg.skill_num)
            economyFail('Không kế thừa vào thẻ nguyên liệu.');
        const factor = profile.vip >= 1 ? 1 : .7, sourceExp = source ? Math.floor(heroStoredExp(source) * factor) : 0, orb = use === '1' ? Number(profile.exp_ball ?? 0) : 0, orbFactor = source ? 1 : factor;
        let need = -Number(target.exp ?? 0);
        for (let lv = target.lv; lv < cap; lv++)
            need += heroExpThreshold(target, lv);
        need = Math.max(0, need);
        const fromSource = Math.min(need, sourceExp), fromOrb = Math.min(orb, Math.ceil(Math.max(0, need - fromSource) / orbFactor)), gain = fromSource + Math.floor(fromOrb * orbFactor);
        if (gain <= 0 && !source)
            economyFail('Không có EXP có thể kế thừa.');
        // Có nguồn: ưu tiên Giấy Công Chứng #24; chỉ dùng bóng: Lua xác nhận trả Xu pay[15].
        const ticket = source && Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=24').get(s.user_id)?.quantity ?? 0) > 0;
        this.cost(s, ticket ? [[6, 24, 1]] : [[9, 0, economyConfig('pay')['15'].coin[0]]]);
        const afterProfile = this.profile(s);
        afterProfile.exp_ball = orb + (Number(profile.exp_ball ?? 0) - orb) - fromOrb + Math.max(0, sourceExp - fromSource);
        if (!Number.isSafeInteger(afterProfile.exp_ball) || afterProfile.exp_ball < 0)
            economyFail('EXP dự trữ vượt giới hạn an toàn.');
        this.saveProfile(s, afterProfile);
        let lv = target.lv, exp = Number(target.exp ?? 0) + gain;
        while (lv < cap && exp >= heroExpThreshold(target, lv)) {
            exp -= heroExpThreshold(target, lv);
            lv++;
        }
        const next = progressionChange(transfer?.receiver ?? target, { lv });
        next.exp = lv === cap ? 0 : exp;
        next.level_max = cap;
        this.save(s, next);
        if (transfer)
            this.save(s, transfer.donor);
        const delivery = refund.rewards.length ? new WelfareService(this.db).applyInTransaction(s, refund.rewards, { heroes: economyConfig('character_detail'), items: economyConfig('item'), equipment: economyConfig('equip') }) : { reward: [] };
        return { ...delivery, inherited_exp: gain, orb_consumed: fromOrb, source_exp: sourceExp, transferred_reform: transfer?.reform ?? {}, transferred_skills: transfer?.transfers ?? [], rebirth_refund: refund, policy: transfer?.policy ?? 'Bóng EXP giữ cơ chế đã xác minh; không thay đổi Cải Tạo/kỹ năng khi không có tướng cho.' };
    }
    breakthroughRows(h) { const cfg = economyConfig('character_detail')[h.c_id], ids = cfg?.breakthrough_ids; if (!Array.isArray(ids) || !ids.length)
        economyFail('Tướng chưa có bảng Đột Phá.'); return ids.map((id) => { const row = economyConfig('breakthrough')[id]; if (!row || row.character_id !== h.c_id)
        economyFail('Thiếu dòng Đột Phá #' + id); return { id, ...row }; }); }
    selectMaterials(s, rewards, major) { const params = new URLSearchParams(), used = new Set(), form = JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(s.user_id).formation)), profile = this.profile(s); for (const [t, cid, n] of rewards)
        if (t === 5) {
            const candidates = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND config_id=? ORDER BY id').all(s.user_id, cid).map(r => JSON.parse(String(r.state))).filter(h => { const contains = (v) => v === h.id || !!(v && typeof v === 'object' && Object.entries(v).some(([k, x]) => k === h.id || contains(x))); return h.id !== major && !used.has(h.id) && h.lv === 1 && !h.evo && !h.bre && !h.super_step && !h.element_break && !h.remove_avail?.length && hasOnlyInitialHeroSkills(h) && !contains(form) && !contains(profile) && !this.db.prepare("SELECT 1 FROM player_equipment WHERE user_id=? AND json_extract(state,'$.bind_card')=?").get(s.user_id, h.id); }).slice(0, n);
            if (candidates.length !== n)
                economyFail('Thiếu thẻ nguyên liệu an toàn #' + cid);
            for (const h of candidates) {
                used.add(h.id);
                params.append('card', h.id);
            }
        } return params; }
    query(s, id) { const h = this.hero(s, id), rows = this.breakthroughRows(h); return { break_info: { cur_break_lv: h.element_break ?? 0, next_break_info: rows.map((r, i) => ({ break_lv: i + 1, add_abilitys: r.abilitys })) } }; }
    breakthrough(s, p) {
        const h = this.hero(s, p.get('card_id')), lv = h.element_break ?? 0, rows = this.breakthroughRows(h);
        if (String(lv) !== p.get('element_lv'))
            economyFail('Cấp Đột Phá đã đổi, hãy tải lại.');
        if (lv >= rows.length)
            economyFail('Đột Phá đã đạt giới hạn nguồn.');
        const row = rows[lv];
        for (const [t, n] of row.abilitys)
            if (!abilityFields[t] || !Number.isFinite(n) || n < 0)
                economyFail('Thuộc tính Đột Phá chưa hỗ trợ #' + t);
        const removed = this.cost(s, [[1, 0, row.need_money], ...row.need_material], p.getAll('card').length || p.getAll('material').length ? p : this.selectMaterials(s, row.need_material, h.id), h.id);
        h.element_break = lv + 1;
        for (const [t, n] of row.abilitys)
            h[abilityFields[t]] = Number(h[abilityFields[t]] ?? 0) + n;
        this.save(s, h);
        return { reward: [], removed, breakthrough_level: h.element_break, abilitys: row.abilitys };
    }
    catalog(s) { const p = this.profile(s), items = economyConfig('item'); return { expBall: p.exp_ball ?? 0, expItems: Object.entries(items).filter(([, v]) => v.is_use === 19).map(([id, v]) => ({ id: Number(id), ...v })), breakthrough: Object.values(new PlayerService(this.db).cards(s).cards).filter((h) => economyConfig('character_detail')[h.c_id]?.breakthrough_ids?.length).map((h) => { try {
            return { heroId: h.id, configId: h.c_id, level: h.element_break ?? 0, rows: this.breakthroughRows(h), blockedReason: '' };
        }
        catch (error) {
            return { heroId: h.id, configId: h.c_id, level: h.element_break ?? 0, rows: [], blockedReason: error.message };
        } }), history: this.db.prepare("SELECT method,request_key,created_at,result FROM player_content_operations WHERE user_id=? AND method IN ('cards.inherit','cards.element_break') ORDER BY created_at DESC LIMIT 30").all(s.user_id) }; }
}
