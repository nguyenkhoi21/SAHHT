import { petConfig, petRecipes, petProof, petFail } from './pet-source.js';
import { petFormation, petWire, petCache, petFields, petBonuses } from './pet-state.js';
import { ProgressionEconomyService } from './progression-economy.js';
import { contentReceipt } from './content-receipt.js';
import { audit } from '../admin/admin.audit.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { petSkillSupported } from './pet-skills.js';
import { petSkillTier, petSkillsAtStar } from './pet-skill-tier.js';
import { petCombatRules } from './pet-advanced.js';
export class PetService {
    db;
    now;
    constructor(db, now = () => Date.now()) {
        this.db = db;
        this.now = now;
    }
    profile(user) { const r = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(user); return r ? JSON.parse(String(r.profile)) : petFail('Nhân vật chưa sẵn sàng.'); }
    eligible(user) { if (this.profile(user).level < Math.min(...Object.values(petConfig('pet_corral')).map(r => Number(r.limit_lv))))
        petFail('Thú nuôi mở từ cấp30 theo bảng corral.'); }
    owned(user, id) { const r = this.db.prepare('SELECT state FROM player_pets WHERE user_id=? AND id=?').get(user, id ?? ''); return r ? petSkillsAtStar(JSON.parse(String(r.state))) : petFail('Thú nuôi không thuộc tài khoản.'); }
    save(user, p) { this.db.prepare('UPDATE player_pets SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(p), user, p.id); }
    money(s, field, n) { const p = this.profile(s.user_id); if (!Number.isSafeInteger(n) || n < 0 || !Number.isSafeInteger(p[field] ?? 0) || (p[field] ?? 0) < n)
        petFail('Không đủ ' + ({ pet_crystal: 'Năng Tinh thú nuôi', pet_exp_ball: 'Bao Con Nhộng', pet_skill_stone: 'Đá kỹ năng thú nuôi', coin: 'Xu', dirt_silver: 'Bụi bạc', dirt_gold: 'Bụi vàng' }[field] ?? field)); p[field] -= n; this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), s.user_id); }
    packet(user, out = {}) { return { ...out, ...petWire(this.db, user), _client_cache_update: { ...out._client_cache_update, ...petCache(this.db, user) } }; }
    index(user) { this.eligible(user); return this.packet(user, { source: 'PET Việt Nam, riêng với fable_beast', blockers: petProof().blockers, combat_rules: petCombatRules }); }
    catalog() { return Object.entries(petConfig('pet_detail')).map(([id, c]) => ({ id: Number(id), ...c, skills: [1, 2].flatMap(slot => (slot === 1 ? [1, 2, 3] : [1, 2]).map(tier => { const sid = petSkillTier(c, slot, tier); return { id: sid, slot, tier, unlockStar: slot === 1 ? [1, 3, 5][tier - 1] : [2, 4][tier - 1], ...petConfig('pet_skill_detail')[sid], combatSupported: petSkillSupported(sid) }; })), recipe: Object.entries(petRecipes()).find(([, r]) => r.change_id[0][1] === Number(id))?.[1] })); }
    diagnostics(user) { return { ...this.packet(user), catalog: this.catalog(), resources: Object.fromEntries(['pet_exp_ball', 'pet_crystal', 'pet_skill_stone'].map(k => [k, this.profile(user)[k] ?? 0])), bonuses: petBonuses(this.db, user), rules: petProof().rules, combatRules: petCombatRules, blockers: petProof().blockers, battles: this.battleHistory(user), history: this.db.prepare("SELECT method,request_key,result,created_at FROM player_content_operations WHERE user_id=? AND (method LIKE 'pets.%' OR method='item.exchange') ORDER BY created_at DESC LIMIT 50").all(user) }; }
    battleHistory(user) { return this.db.prepare(`SELECT id,created_at,'PvE' mode,json_extract(result,'$.winner') winner,json_extract(result,'$.rounds') rounds,json_extract(result,'$.petDiagnostics') pets FROM local_battles WHERE user_id=? AND json_type(result,'$.petDiagnostics')='array' UNION ALL SELECT id,created_at,'Arena' mode,json_extract(metadata,'$.winner') winner,json_extract(metadata,'$.rounds') rounds,json_extract(metadata,'$.petDiagnostics') pets FROM arena_operations WHERE user_id=? AND kind='battle' AND json_type(metadata,'$.petDiagnostics')='array' ORDER BY created_at DESC LIMIT 20`).all(user, user).map(row => ({ ...row, pets: JSON.parse(String(row.pets)) })); }
    execute(s, method, p) {
        const allowed = ['pet_culture', 'pet_evolution', 'pet_strengthen', 'pet_skill_levelup', 'activate_pos', 'set_pet_formation', 'activate_pet_follow_pos', 'set_pet_follow_formation'];
        if (!allowed.includes(method))
            petFail(method === 'refresh_pet_follow' ? 'Tẩy tỷ lệ đi theo thiếu quy tắc bốc số gốc; chưa tiêu mảnh.' : method === 'pet_rebirth' ? 'Tái Sinh PET thiếu công thức hoàn và trạng thái gốc; chưa tiêu đá/Xu.' : 'Thao tác PET chưa có hợp đồng nguồn.');
        const body = [...p].filter(([k]) => !['request_id', 'mk', 'rans', 'user_token'].includes(k)).sort(([a, av], [b, bv]) => a.localeCompare(b) || av.localeCompare(bv));
        return contentReceipt(this.db, s.user_id, 'pets.' + method, p.get('request_id'), body, () => {
            this.eligible(s.user_id);
            let changed;
            const costs = [];
            if (method === 'activate_pos' || method === 'activate_pet_follow_pos') {
                const f = petFormation(this.db, s.user_id), follow = method === 'activate_pet_follow_pos', key = follow ? 'pet_follow_pos' : 'pet_pos', index = Number(p.get('pos')), cfg = petConfig(follow ? 'pet_follow' : 'pet_corral')[index + 1];
                if (!Number.isInteger(index) || index < 0 || !cfg || f[key][index] !== '-1')
                    petFail('Ô không hợp lệ hoặc đã mở.');
                const profile = this.profile(s.user_id);
                if (follow) {
                    const opened = f[key].filter((v) => v !== '-1').length;
                    if (index !== opened || Number(profile.vip ?? 0) < cfg.vip)
                        petFail('Mở ô đi theo tuần tự và đủ VIP nguồn.');
                }
                else if (profile.level < cfg.limit_lv)
                    petFail('Cấp nhân vật chưa đủ mở ô.');
                const field = cfg.sort === 1 ? 'dirt_silver' : cfg.sort === 2 ? 'dirt_gold' : cfg.sort === 3 ? 'coin' : petFail('Thiếu mapping chi phí ô.');
                this.money(s, field, cfg.price);
                costs.push({ field, amount: cfg.price });
                f[key][index] = '0';
                this.db.prepare('INSERT INTO player_pet_formation VALUES(?,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state').run(s.user_id, JSON.stringify(f));
            }
            else if (method === 'set_pet_formation' || method === 'set_pet_follow_formation') {
                const follow = method === 'set_pet_follow_formation', f = petFormation(this.db, s.user_id), key = follow ? 'pet_follow_pos' : 'pet_pos', raw = p.getAll('formation');
                if (raw.length !== 1)
                    petFail('Thiếu hoặc trùng formation.');
                const ids = raw[0].replace(/^_+/, '').split('_');
                if (ids.length !== 9)
                    petFail('Đội PET cần đúng9 vị trí nguồn.');
                const used = new Set();
                for (let i = 0; i < 9; i++) {
                    const id = ids[i];
                    if (f[key][i] === '-1' && id !== '-1' || f[key][i] !== '-1' && id === '-1')
                        petFail('Không thay khóa ô bằng packet đội hình.');
                    if (['0', '-1'].includes(id))
                        continue;
                    if (used.has(id))
                        petFail('Thú nuôi bị trùng ô.');
                    used.add(id);
                    const pet = this.owned(s.user_id, id), other = f[follow ? 'pet_pos' : 'pet_follow_pos'];
                    if (other.includes(id))
                        petFail('Không vừa ra trận vừa đi theo cùng một thú.');
                    if (!follow && i !== 0)
                        petFail('Client Việt Nam hiện hành chỉ dùng PET chiến đấu tại vị trí1.');
                    if (!follow && ![pet.s_1, pet.s_2].filter(x => x.avail === 2).every(x => petSkillSupported(x.s)))
                        petFail('Kỹ năng thú này thiếu thành phần hiệu ứng gốc; chưa cho ra trận bằng hoạt ảnh giả.');
                }
                f[key] = ids;
                this.db.prepare('INSERT INTO player_pet_formation VALUES(?,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state').run(s.user_id, JSON.stringify(f));
            }
            else {
                const pet = this.owned(s.user_id, p.get('pet_id')), cfg = petConfig('pet_detail')[pet.c_id], profile = this.profile(s.user_id);
                if (method === 'pet_culture') {
                    if (petProof().rules.cultureCost !== 'remaining_exp_capsules')
                        petFail('Chưa chốt chi phí Bao Con Nhộng.');
                    const base = petConfig('pet_base')[pet.lv], cap = Math.max(cfg.level_max, petConfig('pet_evolution')[pet.star].maxlv);
                    if (pet.lv >= cap)
                        petFail('Thú nuôi đã đạt giới hạn cấp theo sao.');
                    if (profile.level < base.player_level)
                        petFail('Cấp nhân vật chưa đủ nâng PET.');
                    const amount = base.exp - pet.exp;
                    if (!Number.isInteger(amount) || amount < 1)
                        petFail('EXP PET không khớp bảng nguồn.');
                    this.money(s, 'pet_exp_ball', amount);
                    costs.push({ field: 'pet_exp_ball', amount });
                    pet.lv++;
                    pet.exp = 0;
                }
                else if (method === 'pet_evolution') {
                    const next = petConfig('pet_evolution')[pet.star + 1];
                    if (!next || pet.star >= cfg.star_max)
                        petFail('Thú nuôi đã đạt sao tối đa.');
                    if (pet.lv < next.need_level || profile.level < next.player_level)
                        petFail('Chưa đủ cấp PET/nhân vật để tiến hóa.');
                    if (Number(p.get('item')) !== cfg.resolve_id)
                        petFail('Mảnh không đúng loài thú.');
                    if (petProof().rules.evolutionCost !== 'next_star_exp_fragments')
                        petFail('Chưa chốt số mảnh tiến hóa.');
                    new ProgressionEconomyService(this.db).cost(s, [[6, cfg.resolve_id, next.exp]]);
                    costs.push({ item: cfg.resolve_id, amount: next.exp });
                    pet.star++;
                    pet.evo = 0;
                    for (let n = 1; n <= 2; n++) {
                        const sid = petSkillTier(cfg, n, next.skill[n - 1]);
                        pet['s_' + n] = { ...pet['s_' + n], s: sid, step: Math.max(1, next.skill[n - 1]), avail: next.skill[n - 1] ? 2 : 0 };
                    }
                }
                else if (method === 'pet_strengthen') {
                    const types = p.getAll('type');
                    if (!types.length || types.length > 20)
                        petFail('Chọn1–20bước Cải Tạo.');
                    for (const f of types) {
                        if (!petFields.includes(f))
                            petFail('Thuộc tính Cải Tạo không hợp lệ.');
                        const next = petConfig('pet_strengthen')[pet[f + '_crystal'] + 1];
                        if (!next)
                            petFail('Cải Tạo đã đạt giới hạn nguồn.');
                        if (pet.lv < next.need_level || pet.star < next.need_star)
                            petFail('Cấp/sao PET chưa đủ Cải Tạo.');
                        const [kind, amount] = next['need_crstal_' + f];
                        if (kind !== 3 || next.need_time !== 0)
                            petFail('Chi phí/thời gian Cải Tạo chưa có hợp đồng.');
                        this.money(s, 'pet_crystal', amount);
                        new ProgressionEconomyService(this.db).cost(s, [[1, 0, next.need_food]]);
                        costs.push({ field: f, crystal: amount, food: next.need_food });
                        pet[f + '_crystal']++;
                    }
                }
                else if (method === 'pet_skill_levelup') {
                    const skill = [pet.s_1, pet.s_2].find(x => x.s === Number(p.get('skill_id'))), row = petConfig('pet_skill_detail')[skill?.s];
                    if (!skill || skill.avail !== 2)
                        petFail('Kỹ năng chưa mở hoặc không thuộc PET.');
                    if (skill.lv >= row.max_lv)
                        petFail('Kỹ năng đã đạt cấp tối đa.');
                    if (petProof().rules.skillCost !== 'stone_cost_one_level')
                        petFail('Chưa chốt chi phí kỹ năng.');
                    const amount = petConfig('pet_skill_levelup')[skill.lv]?.stone_cost[row.skill_quality];
                    if (!Number.isInteger(amount) || amount < 1)
                        petFail('Thiếu giá đá kỹ năng nguồn.');
                    this.money(s, 'pet_skill_stone', amount);
                    costs.push({ field: 'pet_skill_stone', amount });
                    skill.lv++;
                    skill.exp = 0;
                }
                if (petFormation(this.db, s.user_id).pet_pos.includes(pet.id) && [pet.s_1, pet.s_2].some(x => x.avail === 2 && !petSkillSupported(x.s)))
                    petFail('Hãy rút PET trước khi mở nhánh kỹ năng còn thiếu quy tắc gốc; chưa tiêu tài nguyên.');
                this.save(s.user_id, pet);
                changed = pet;
            }
            audit(this.db, null, 'pets.' + method, s.user_id, 'PET Việt Nam · giao dịch độc lập Thần Thú', null, { pet: changed?.id, costs, requestId: p.get('request_id') });
            return this.packet(s.user_id, { reward: {}, costs });
        }, () => this.packet(s.user_id, { reward: {}, replayed: true }));
    }
    useItem(s, p) {
        const cid = Number(p.get('item_id')), count = Number(p.get('num') ?? 1), cfg = petConfig('item')[cid];
        if (![204, 205, 206].includes(cid) || !Number.isSafeInteger(count) || count < 1 || count > 9999 || cfg?.is_use !== 1 || cfg.use_effect?.length !== 1)
            petFail('Hộp PET này thiếu quy tắc chọn quà gốc; chưa tiêu vật phẩm.');
        const boxes = petConfig('box')[cfg.use_effect[0]], rewards = [];
        for (const box of boxes) {
            if (box.num !== box.reward.length || box.reward.some((r) => r.length !== 4 || r[3] !== 100 || ![24, 26, 27].includes(r[0])))
                petFail('Không phải gói PET chắc chắn từ nguồn.');
            for (const [type, id, n] of box.reward)
                rewards.push([type, id, n * count]);
        }
        return contentReceipt(this.db, s.user_id, 'pets.use_item', p.get('request_id'), { cid, count }, () => { new ProgressionEconomyService(this.db).cost(s, [[6, cid, count]]); const out = grantGodfieldReward(this.db, s, rewards), item = Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, cid).quantity); return this.packet(s.user_id, { ...out, effect: out.reward, _client_cache_update: { ...out._client_cache_update, item: { items: { update: { [cid]: [item] }, remove: [] } } } }); }, () => this.packet(s.user_id, { replayed: true, effect: {}, _client_cache_update: { item: { items: { update: { [cid]: [Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, cid)?.quantity ?? 0)] }, remove: [] } } } }));
    }
    combat(user) { const p = petBonuses(this.db, user).active; if (!p)
        return; const selected = [p.s_1, p.s_2].filter(s => s.avail === 2); if (selected.some(s => !petSkillSupported(s.s)))
        petFail('PET đang xuất chiến có kỹ năng thiếu handler; hãy rút PET trước trận.'); return { ...p, animation: petConfig('pet_detail')[p.c_id].animation, selectedSkills: selected }; }
}
