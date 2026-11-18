import { staticConfig } from './player.service.js';
import { audit } from '../admin/admin.audit.js';
import { superSkillProjection, skillSourceSlots } from './battle-skill-registry.js';
const fail = (m, code = 422) => { throw Object.assign(new Error(m), { statusCode: code }); };
export const publicHero = (hero) => Object.fromEntries(Object.entries(hero).filter(([k]) => !k.startsWith('_local_')));
// Pool local lưu riêng: UI chọn5 skill thường lấy source1/2/3/6/7; s4/5 là siêu tiến hóa.
// Không tạo s6/s7 trong packet vì consumer chỉ đọc s1..s5.
export async function skillState(hero) {
    const defs = await staticConfig('character_detail'), cfg = defs[String(hero.c_id)];
    if (!cfg)
        fail('Không tìm thấy config hero.');
    // game_data.getEvolutionCfgByQuality: kind <3 dùng evolution, không có evolution_1/2.
    const kind = Number(cfg.evo_kind ?? cfg.quality), evolutionTable = kind < 3 ? 'evolution' : kind === 3 ? 'evolution_3' : kind === 4 ? 'evolution_4' : 'evolution_5';
    const [skills, evolutions, supers] = await Promise.all(['skill_detail', evolutionTable, 'super_evolution'].map(staticConfig));
    const row = evolutions[String(hero.evo ?? 0)];
    if (!row)
        fail('Thiếu config tiến hóa của hero.');
    const sourceSlots = skillSourceSlots(cfg);
    const saved = hero._local_skill_bank;
    const bank = [];
    for (let i = 0; i < sourceSlots.length; i++) {
        const source = cfg['skill_' + sourceSlots[i] + '_source'];
        if (Array.isArray(source) && source.length === 0 && i < 3) {
            bank.push({ s: 0, lv: 1, exp: 0, avail: 0 });
            continue;
        }
        if (!Array.isArray(source) || source.length !== 1)
            fail('Skill có nhiều nguồn hoặc thiếu config, chưa chọn variant tự động.');
        let sid = Number(source[0][0]);
        const degree = i < 3 ? (row.skill[i] ?? 0) : 1;
        for (let n = 1; n < degree; n++) {
            sid = Number(skills[String(sid)]?.is_evolution);
            if (!sid)
                fail('Chuỗi skill tiến hóa không đầy đủ.');
        }
        const def = skills[String(sid)];
        if (!def)
            fail('Skill không có trong skill_detail: ' + sid);
        const current = saved?.[i] ?? (i < 3 ? hero['s_' + (i + 1)] : undefined);
        if (current && current.s !== sid)
            fail('Skill đã lưu không khớp nguồn/tiến hóa; cần đối chiếu trước khi đổi.');
        bank.push(current ? { ...current } : { s: sid, lv: 1, exp: 0, avail: i === 0 ? 2 : i < 3 && degree > 0 ? 1 : 0 });
    }
    const selection = hero._local_skill_selection ?? [1, 2, 3];
    if (selection.length !== 3 || new Set(selection).size !== 3 || selection.some(n => !Number.isInteger(n) || n < 1 || n > bank.length))
        fail('Ba vị trí skill local không hợp lệ.');
    const state = { ...hero, _local_skill_bank: bank, _local_skill_selection: selection };
    selection.forEach((slot, i) => state['s_' + (i + 1)] = { ...bank[slot - 1] });
    Object.assign(state, superSkillProjection(hero, cfg, skills, supers));
    return { state, bank, selection, cfg, skills };
}
export class HeroSkillService {
    db;
    constructor(db) {
        this.db = db;
    }
    hero(s, id) { const row = this.db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(s.user_id, id); if (!row)
        fail('Hero không thuộc tài khoản.', 404); return JSON.parse(row.state); }
    async info(s, id) {
        const { bank, selection, cfg, skills } = await skillState(this.hero(s, id)), pay = await staticConfig('pay');
        return { card_id: id, skill: bank, selection, normalSkillCount: bank.length, superSkillSlots: [4, 5], entries: bank.map((v, i) => ({ index: i + 1, sourceSlot: [1, 2, 3, 6, 7][i], ...v, name: skills[String(v.s)]?.skill_name ?? 'Không có skill', maxLevel: skills[String(v.s)]?.max_lv ?? 0, cost: i >= 3 ? pay[String(i + 39)]?.coin?.[0] : null })), heroName: cfg.name };
    }
    async change(s, id, action, admin, fn) {
        if (admin?.role === 'VIEWER')
            fail('Tài khoản chỉ có quyền xem.', 403);
        const before = this.hero(s, id), data = await skillState(before);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (JSON.stringify(this.hero(s, id)) !== JSON.stringify(before))
                fail('Hero đã thay đổi, hãy tải lại.', 409);
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id);
            const profile = JSON.parse(row.profile), oldProfile = { ...profile };
            fn(data, profile);
            data.state._local_skill_bank = data.bank;
            data.state._local_skill_selection = data.selection;
            data.selection.forEach((slot, i) => data.state['s_' + (i + 1)] = { ...data.bank[slot - 1] });
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(data.state), s.user_id, id);
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), s.user_id);
            audit(this.db, admin?.id ?? null, action, s.user_id, 'Skill local theo config/consumer', { hero: before, profile: oldProfile }, { hero: data.state, profile });
            this.db.exec('COMMIT');
            return { ...await this.info(s, id), _client_cache_update: { cards: { cards: { update: { [id]: publicHero(data.state) }, remove: [] } } } };
        }
        catch (e) {
            if (this.db.isTransaction)
                this.db.exec('ROLLBACK');
            throw e;
        }
    }
    async unlock(s, id, index, admin) {
        const pay = await staticConfig('pay');
        return this.change(s, id, 'hero.skill.unlock', admin, (d, p) => {
            if (![4, 5].includes(index) || d.bank.length !== 5)
                fail('Chỉ mua hai skill thường bổ sung của hero5skill.');
            const skill = d.bank[index - 1];
            if (skill.avail === 2)
                fail('Kỹ năng đã được mở.');
            const cost = pay[String(index + 38)]?.coin?.[0];
            if (!Number.isSafeInteger(cost) || cost < 0 || !Number.isSafeInteger(p.coin ?? 0) || (p.coin ?? 0) < cost)
                fail('Không đủ Xu để mở kỹ năng.');
            p.coin = (p.coin ?? 0) - cost;
            skill.avail = 2;
        });
    }
    select(s, id, slots, admin) {
        return this.change(s, id, 'hero.skill.select', admin, d => {
            if (slots.length !== 3 || new Set(slots).size !== 3 || slots.some(n => !Number.isInteger(n) || n < 1 || n > d.bank.length || d.bank[n - 1].avail !== 2))
                fail('Phải chọn đúng ba skill đã mở, không trùng.');
            d.selection = slots;
        });
    }
    setLevel(s, id, index, level, admin) {
        return this.change(s, id, 'hero.skill.qa.level', admin, d => {
            const skill = d.bank[index - 1], cfg = skill && d.skills[String(skill.s)];
            if (!Number.isInteger(index) || !skill || skill.avail !== 2 || !Number.isInteger(level) || level < 1 || level > cfg.max_lv)
                fail('Cấp skill hoặc trạng thái mở không hợp lệ.');
            skill.lv = level;
            skill.exp = 0;
        });
    }
    async upgrade(s, id, pos, materials) {
        if (!Number.isInteger(pos) || pos < 1 || pos > 5 || !materials.length || materials.length > 6 || new Set(materials).size !== materials.length || materials.includes(id))
            fail('Hero/vị trí/nguyên liệu nâng skill không hợp lệ.');
        const [levels, bases, rates] = await Promise.all(['skill_levelup', 'character_base', 'character_base_rate'].map(staticConfig));
        const snapshots = materials.map(mid => ({ id: mid, hero: this.hero(s, mid) }));
        const prepared = await Promise.all(snapshots.map(async (v) => ({ ...v, data: await skillState(v.hero) })));
        const result = await this.change(s, id, 'hero.skill.levelup', undefined, (d, p) => {
            const skill = pos <= 3 ? d.bank[d.selection[pos - 1] - 1] : d.state['s_' + pos], cfg = skill && d.skills[String(skill.s)];
            if (!cfg || skill.avail !== 2 || skill.lv >= Math.min(cfg.max_lv, Object.keys(levels).length))
                fail('Skill chưa mở hoặc đã đạt cấp tối đa.');
            const form = JSON.parse(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(s.user_id).formation);
            const protectedIds = [...form.alignment.flat(), ...(form.assistant ?? []), ...(form.destiny ?? []), ...(form.formation_bonus ?? []), ...Object.values(form.formation_bonus_addition ?? {}).flat()];
            let gain = 0, cost = 0;
            for (const v of prepared) {
                if (JSON.stringify(this.hero(s, v.id)) !== JSON.stringify(v.hero))
                    fail('Nguyên liệu đã thay đổi, hãy tải lại.', 409);
                if (v.hero.lock || (v.hero.bind_equip ?? []).some((eid) => eid && String(eid) !== '0') || protectedIds.includes(v.id) || Object.keys(v.hero.remove_avail ?? {}).length || this.db.prepare('SELECT 1 FROM player_hero_qa_backup WHERE user_id=? AND id=?').get(s.user_id, v.id))
                    fail('Không dùng hero đang ra trận, bị khóa/Vận Mệnh hoặc có snapshot QA làm nguyên liệu.');
                const base = bases[String(v.hero.lv)], rate = rates[String(v.data.cfg.type)];
                if (!base || !rate)
                    fail('Thiếu config EXP/chi phí nguyên liệu.');
                const exp = base.eaten_skill_exp * rate.eaten_skill_exp_rate;
                gain += exp;
                if ([v.data.state.s_1, v.data.state.s_2, v.data.state.s_3].some((x) => x?.s === skill.s))
                    gain += exp;
                cost += base.skill_strengthen_food * rate.skill_strengthen_food_rate;
            }
            if (!Number.isSafeInteger(cost) || cost < 0 || !Number.isFinite(gain) || gain <= 0 || (p.food ?? 0) < cost)
                fail('Không đủ thức ăn hoặc config chi phí/EXP chưa hỗ trợ.');
            let exp = skill.exp + gain, lv = skill.lv, cap = Math.min(cfg.max_lv, Object.keys(levels).length);
            while (lv < cap) {
                const need = levels[String(lv)]?.[cfg.skill_quality];
                if (!Number.isSafeInteger(need) || need <= 0)
                    fail('Thiếu ngưỡng EXP skill.');
                if (exp < need)
                    break;
                exp -= need;
                lv++;
            }
            skill.lv = lv;
            skill.exp = lv === cap ? 0 : exp;
            p.food = (p.food ?? 0) - cost;
            for (const v of prepared) {
                this.db.prepare('INSERT INTO player_hero_archive VALUES(?,?,?,?,?)').run(s.user_id, v.id, v.hero.c_id, JSON.stringify(v.hero), Date.now());
                this.db.prepare('DELETE FROM player_heroes WHERE user_id=? AND id=?').run(s.user_id, v.id);
            }
        });
        result._client_cache_update.cards.cards.remove = materials;
        return result;
    }
}
