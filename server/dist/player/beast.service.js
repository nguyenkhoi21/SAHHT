import { capacityFields } from './inventory-capacity.js';
import { beastLevelInvestment, beastRebirthPlan } from './beast-rebirth.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { beastAdvancement, beastQualityBonus } from './beast-progression.js';
import { beastConfig } from './beast-source.js';
import { beastSkillPlan, beastCombatSupported } from './beast-skills.js';
export { beastCombatSupported } from './beast-skills.js';
import { contentReceipt } from './content-receipt.js';
import { ProgressionEconomyService, abilityFields } from './progression-economy.js';
import { readConfigSync } from './local-content.js';
import { createBaseHero } from './definitions.js';
import { ProgressionService } from './progression.service.js';
import { audit } from '../admin/admin.audit.js';
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
export class BeastService {
    db;
    now;
    constructor(db, now = () => Date.now()) {
        this.db = db;
        this.now = now;
    }
    eligible(id) { const row = this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(id); if (!row)
        fail('Nhân vật chưa sẵn sàng.'); const gate = new ProgressionService(this.db).featureGates(id).find(g => g.buttonId === 129); if (gate && !gate.prerequisiteMet)
        fail('Chưa đủ điều kiện mở Thần Thú theo nguồn.'); }
    config(id) { return beastConfig('combiner')[id] ?? fail('Thần Thú không có trong nguồn Việt Nam.'); }
    owned(id, beast) { const r = this.db.prepare('SELECT state FROM player_beasts WHERE user_id=? AND beast_id=?').get(id, beast); return r ? JSON.parse(String(r.state)) : fail('Chưa triệu hồi Thần Thú này.'); }
    save(id, beast, s) { this.db.prepare('INSERT INTO player_beasts VALUES(?,?,?) ON CONFLICT(user_id,beast_id) DO UPDATE SET state=excluded.state').run(id, beast, JSON.stringify(s)); }
    attributes(beast, s) {
        const c = this.config(beast), stats = {};
        for (const f of ['hp', 'patk', 'matk', 'def', 'speed'])
            stats[f] = c['base_' + f] + (s.level - 1) * c['growth_' + f];
        // Các vật liệu đã dung hợp tăng đúng một thuộc tính theo combiner.combine_card.
        for (const god of Object.values(s.beast_gods)) {
            const f = abilityFields[god.add_ability_type], r = beastConfig('combiner_evo')[god.quality_config];
            if (!f || !r)
                fail('Thiếu nguồn thuộc tính thẻ dung hợp.');
            stats[f] += r.nature;
        }
        for (const [field, value] of Object.entries(beastQualityBonus(beast, s.quality)))
            stats[field] += Number(value);
        return stats;
    }
    packet(beast, s) { return { ...s, ...this.attributes(beast, s), skill: beastConfig('combiner_advanced')[s.quality].skill, combat_skills: beastConfig('combiner_advanced')[s.quality].skill.filter(beastCombatSupported), advancement: beastAdvancement(beast, s) }; }
    breakdown(beast, s) { const c = this.config(beast), total = this.attributes(beast, s); return { level: s.level, attributes: Object.fromEntries(['hp', 'patk', 'matk', 'def', 'speed'].map(f => [f, { base: c['base_' + f], levelGrowth: (s.level - 1) * c['growth_' + f], materialGods: total[f] - c['base_' + f] - (s.level - 1) * c['growth_' + f] - (beastQualityBonus(beast, s.quality)[f] ?? 0), qualityBonus: beastQualityBonus(beast, s.quality)[f] ?? 0, total: total[f] }])), mainHeroBonus: 'Không áp dụng: chưa có nguồn cho phép cộng thuộc tính Thần Thú vào tướng/CP Main.', beastCombatPower: 'SOURCE BLOCKED: chưa có công thức lực chiến riêng, không tự đặt hệ số.' }; }
    index(id, checkEligibility = true) { if (checkEligibility)
        this.eligible(id); const fable_beasts = {}; for (const key of Object.keys(beastConfig('combiner')))
        fable_beasts[key] = { is_open: 0, beast_gods: Object.fromEntries(this.config(Number(key)).combine_card.map((r) => [String(r[1]), { quality_config: 1, quality: 1, add_ability_type: r[3] }])) }; for (const r of this.db.prepare('SELECT beast_id,state FROM player_beasts WHERE user_id=?').all(id))
        fable_beasts[String(r.beast_id)] = this.packet(Number(r.beast_id), JSON.parse(String(r.state))); return { fable_beasts, fight_beast: this.formation(id).map((b) => b.beast), source_status: '7 Thần Thú từ runtime Việt Nam. Mở chi tiết để xem phần hiệu ứng còn thiếu nguồn.' }; }
    formation(id) { const r = this.db.prepare('SELECT state FROM player_beast_formation WHERE user_id=?').get(id); return r ? JSON.parse(String(r.state)) : []; }
    fragmentRecipes(id) {
        const materialIds = new Set(Object.values(beastConfig('combiner')).flatMap(c => c.combine_card.map((r) => r[1]))), heroes = readConfigSync('character_detail'), items = readConfigSync('item');
        return Object.entries(readConfigSync('exchange')).flatMap(([key, row]) => {
            if (row.change_sort !== 1 || row.change_id?.length !== 1 || row.change_id[0][0] !== 5 || !materialIds.has(row.change_id[0][1]) || heroes[row.change_id[0][1]]?.skill_num !== 0 || !items[row.need_item])
                return [];
            return [{ id: Number(key), ...row, fragment: { id: row.need_item, name: items[row.need_item].name, icon: items[row.need_item].icon, owned: Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(id, row.need_item)?.quantity ?? 0) }, card: { id: row.change_id[0][1], name: heroes[row.change_id[0][1]].name }, sourceStatus: 'SOURCE_VERIFIED' }];
        });
    }
    combat(id) { return this.formation(id).map(b => { const s = this.owned(id, b.beast); return { ...this.packet(b.beast, s), beast_num: b.beast, animation: this.config(b.beast).animation, selectedSkills: b.skills }; }); }
    rebirthPreview(id, beast) { this.eligible(id); const plan = beastRebirthPlan(beast, this.owned(id, beast)), profile = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile)), owned = Number(this.db.prepare('SELECT COUNT(*) n FROM player_heroes WHERE user_id=?').get(id).n); return { ...plan, freeCardSlots: Math.max(0, capacityFields(profile).card_max - owned), capacityEnough: owned + plan.refundCount <= capacityFields(profile).card_max }; }
    execute(s, method, p) {
        if (!['fable_beast.open_fable_beast', 'fable_beast.add_beast_exp', 'fable_beast.up_beast_god', 'fable_beast.update_fight_beast', 'fable_beast.up_beast_quality', 'fable_beast.fable_beast_rebirth'].includes(method))
            fail('Thao tác Thần Thú chưa có hợp đồng nguồn; chưa thay đổi tài sản.');
        const body = [...p].filter(([k]) => !['request_id', 'user_token', 'mk', 'rans', 'account'].includes(k)).sort(([a, av], [b, bv]) => a.localeCompare(b) || av.localeCompare(bv));
        return contentReceipt(this.db, s.user_id, method, p.get('request_id'), body, () => {
            this.eligible(s.user_id);
            const beast = Number(p.get('beast')), economy = new ProgressionEconomyService(this.db), selected = new URLSearchParams(), ids = (p.get('materials') ?? '').split('_').filter(Boolean);
            let result = {}, removed = [];
            if (new Set(ids).size !== ids.length)
                fail('Không thể dùng trùng một thẻ nguyên liệu.');
            const field = this.db.prepare('SELECT state FROM godfield_formations WHERE user_id=?').get(s.user_id), contains = (v, id) => v === id || !!(v && typeof v === 'object' && Object.entries(v).some(([k, x]) => k === id || contains(x, id)));
            for (const id of ids) {
                const h = economy.hero(s, id), base = createBaseHero(h.id, h.c_id, readConfigSync('character_detail')[h.c_id]);
                if (h.lock || h._local_transformation || h.step || ['hp', 'patk', 'matk', 'def', 'speed'].some(f => h[f] !== base[f] || h[f + '_crystal']) || h.bind_equip?.some((v) => v && String(v) !== '0') || field && contains(JSON.parse(String(field.state)), id))
                    fail('Thẻ nguyên liệu đã nâng, đang khóa, kế thừa, gắn đồ hoặc thuộc đội Thần Vực; chưa tiêu.');
                selected.append('card', id);
            }
            if (method === 'fable_beast.update_fight_beast') {
                const entries = p.getAll('fight_beasts').flatMap(v => v.split('&fight_beasts=')), formation = [];
                if (entries.length > 2)
                    fail('Không quá 2 Thần Thú xuất chiến theo nguồn.');
                for (const entry of entries) {
                    if (!/^\d+(?:_\d+){1,2}$/.test(entry))
                        fail('Đội hình Thần Thú không hợp lệ.');
                    const [id, ...skills] = entry.split('_').map(Number), own = this.owned(s.user_id, id), allowed = beastConfig('combiner_advanced')[own.quality].skill;
                    if (formation.some(b => b.beast === id) || new Set(skills).size !== skills.length || skills.some(k => !allowed.includes(k)))
                        fail('Thần Thú/kỹ năng bị trùng hoặc chưa mở.');
                    if (skills.some(k => !beastCombatSupported(k)))
                        fail('Kỹ năng này chưa đủ hợp đồng chiến đấu gốc; chưa cho xuất chiến để tránh hiệu ứng giả.');
                    formation.push({ beast: id, skills });
                }
                this.db.prepare('INSERT INTO player_beast_formation VALUES(?,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state').run(s.user_id, JSON.stringify(formation));
            }
            else if (method === 'fable_beast.up_beast_quality') {
                if (ids.length)
                    fail('Tiến cấp dùng phẩm năm thẻ đã dung hợp, không gửi thẻ để tiêu thêm.');
                const own = this.owned(s.user_id, beast), plan = beastAdvancement(beast, own);
                if (plan.max)
                    fail('Thần Thú đã đạt phẩm tối đa nguồn.');
                if (!plan.ready)
                    fail('Cả năm thẻ dung hợp cần phẩm ' + plan.requiredLabel + ' hoặc cao hơn; hãy nâng từng thẻ trước.');
                own.quality = plan.next;
                this.save(s.user_id, beast, own);
                const formation = this.formation(s.user_id), deployed = formation.find(b => b.beast === beast);
                if (deployed) {
                    deployed.skills = beastConfig('combiner_advanced')[own.quality].skill.filter(beastCombatSupported);
                    this.db.prepare('UPDATE player_beast_formation SET state=? WHERE user_id=?').run(JSON.stringify(formation), s.user_id);
                }
                result.beast_info = this.packet(beast, own);
                result.advanced = true;
            }
            else if (method === 'fable_beast.fable_beast_rebirth') {
                if (ids.length)
                    fail('Tái Sinh không tiêu thêm thẻ nguyên liệu.');
                const own = this.owned(s.user_id, beast), preview = this.rebirthPreview(s.user_id, beast);
                if (!preview.canRebirth)
                    fail('Thần Thú đang Lv1, chưa có EXP để Tái Sinh.');
                if (p.get('preview_key') !== preview.key)
                    fail('Thần Thú đã đổi hoặc chưa xem trước; hãy mở lại Tái Sinh.');
                if (!preview.capacityEnough)
                    fail('Kho tướng cần thêm ô để nhận đủ thẻ56; chưa Tái Sinh.');
                const reward = preview.refundCount ? grantGodfieldReward(this.db, s, [[5, 56, preview.refundCount]]) : { reward: {} };
                own.level = 1;
                own.exp = 0;
                own.evo = 0;
                own.levelFeedExp = 0;
                this.save(s.user_id, beast, own);
                result = { ...reward, beast_info: this.packet(beast, own), rebirth_preview: preview };
            }
            else if (method === 'fable_beast.open_fable_beast') {
                const c = this.config(beast);
                if (this.db.prepare('SELECT 1 FROM player_beasts WHERE user_id=? AND beast_id=?').get(s.user_id, beast))
                    fail('Đã triệu hồi Thần Thú này.');
                if (ids.length !== 5)
                    fail('Cần đúng 5 thẻ dung hợp nguồn.');
                removed = economy.cost(s, c.combine_card.map((r) => r.slice(0, 3)), selected);
                const beast_gods = {};
                for (const [, cid, , kind] of c.combine_card)
                    beast_gods[cid] = { quality_config: 1, quality: 1, add_ability_type: kind };
                const next = { is_open: 1, level: 1, exp: 0, evo: 0, quality: beast * 100 + 1, beast_gods };
                this.save(s.user_id, beast, next);
                result.beast_info = this.packet(beast, next);
            }
            else {
                const own = this.owned(s.user_id, beast), base = beastConfig('combiner_base');
                if (method === 'fable_beast.add_beast_exp') {
                    const cap = Math.max(...Object.keys(base).map(Number));
                    if (own.level >= cap)
                        fail('Thần Thú đã đạt giới hạn cấp nguồn.');
                    if (!ids.length || ids.length > 6)
                        fail('Chọn 1–6 thẻ nguyên liệu.');
                    const costs = [], heroes = readConfigSync('character_detail');
                    let gain = 0;
                    for (const id of ids) {
                        const h = economy.hero(s, id), c = heroes[h.c_id];
                        if (c?.quality < 3 || !(c?.exchange_id > 0) || !Number.isSafeInteger(c?.call_price) || c.call_price <= 0)
                            fail('Cần thẻ phẩm chất từ 3, exchange_id và giá trị EXP đúng nguồn.');
                        gain += c.call_price;
                        costs.push([5, h.c_id, 1]);
                    }
                    const invested = beastLevelInvestment(own);
                    removed = economy.cost(s, costs, selected);
                    own.levelFeedExp = invested + gain;
                    if (!Number.isSafeInteger(own.levelFeedExp))
                        fail('EXP đã nạp vượt giới hạn an toàn.');
                    own.exp += gain;
                    while (own.level < cap && own.exp >= base[own.level].exp) {
                        const need = base[own.level].exp;
                        if (!Number.isSafeInteger(need) || need <= 0)
                            fail('Thiếu ngưỡng EXP nguồn.');
                        own.exp -= need;
                        own.level++;
                    }
                    if (own.level === cap)
                        own.exp = 0;
                    own.evo = own.exp;
                }
                else {
                    const cid = Number(p.get('beast_god')), god = own.beast_gods[cid], table = beastConfig('combiner_evo');
                    if (!god)
                        fail('Thẻ không thuộc bộ dung hợp Thần Thú này.');
                    const current = table[god.quality_config], next = table[god.quality_config + 1];
                    if (!next)
                        fail('Thẻ dung hợp đã đạt cấp tối đa nguồn.');
                    if (own.level < current.level)
                        fail('Cấp Thần Thú chưa đủ điều kiện nâng thẻ.');
                    if (ids.length !== current.advanced)
                        fail('Chọn đúng số thẻ nguyên liệu nguồn.');
                    removed = economy.cost(s, [...current.need, ...current.advanced_item, [5, cid, current.advanced]], selected);
                    god.quality_config++;
                    god.quality = next.quality;
                }
                this.save(s.user_id, beast, own);
                result.beast_info = this.packet(beast, own);
            }
            audit(this.db, null, method, s.user_id, result.rebirth_preview ? `Tái Sinh Thần Thú #${beast}: Lv${result.rebirth_preview.fromLevel} →1, hoàn${result.rebirth_preview.refundCount} thẻ56; giữtiếncấp` : 'Thần Thú combiner nguồn Việt Nam', null, { beast, removed, ...(result.rebirth_preview ? { rebirth: result.rebirth_preview } : {}), requestId: p.get('request_id') });
            return economy.packet(s, { ...this.index(s.user_id), ...result, removed, rewards: {} });
        }, old => new ProgressionEconomyService(this.db).packet(s, { ...old, ...this.index(s.user_id), ...(old.beast_info ? { beast_info: this.packet(Number(p.get('beast')), this.owned(s.user_id, Number(p.get('beast')))) } : {}), reward: {}, reward_tuples: [], rewards: {}, replayed: true }));
    }
    diagnostics(id) { let blockedReason = null; try {
        this.eligible(id);
    }
    catch (e) {
        blockedReason = e.message;
    } return { ...this.index(id, false), blockedReason, fragmentRecipes: this.fragmentRecipes(id), rebirth: Object.fromEntries(this.db.prepare('SELECT beast_id FROM player_beasts WHERE user_id=?').all(id).map(r => { try {
            return [String(r.beast_id), this.rebirthPreview(id, Number(r.beast_id))];
        }
        catch (e) {
            return [String(r.beast_id), { blockedReason: e.message }];
        } })), expMaterial: { id: 56, name: readConfigSync('character_detail')[56].name, exp: 1280 }, skills: Object.entries(beastConfig('combiner_skill_detail')).map(([key, c]) => ({ ...c, ...beastSkillPlan(Number(key)) })), upgradeMaterial: { id: 262, name: readConfigSync('item')[262]?.name }, formation: this.combat(id), attributeBreakdown: Object.fromEntries(this.db.prepare('SELECT beast_id,state FROM player_beasts WHERE user_id=?').all(id).map(r => [String(r.beast_id), this.breakdown(Number(r.beast_id), JSON.parse(String(r.state)))])), catalog: Object.entries(beastConfig('combiner')).map(([key, c]) => ({ id: Number(key), ...c, aliases: key === '5' ? ['Osiris', 'Rồng Trời'] : key === '7' ? ['Eva-01'] : [], materials: c.combine_card.map((r) => ({ type: r[0], id: r[1], quantity: r[2], attribute: abilityFields[r[3]], name: readConfigSync('character_detail')[r[1]]?.name })), combatSkills: beastConfig('combiner_advanced')[Number(key) * 100 + 1].skill.map((sid) => ({ ...beastConfig('combiner_skill_detail')[sid], ...beastSkillPlan(sid) })) })), history: this.db.prepare("SELECT action,summary,created_at,after_state FROM admin_audit WHERE target_user_id=? AND action LIKE 'fable_beast.%' ORDER BY id DESC LIMIT 60").all(id), limitations: ['Chỉ nhận thẻ gốc chưa nâng/khóa/ràng buộc và ngoài mọi đội hình; không tự tháo tướng đang dùng.', 'Tiến cấp dùng nature của bậc hiện tại như popup nguồn, không cộng nature_show; chưa có packet server gốc. Tái Sinh chỉ reset level/EXP, giữ phẩm/năm thẻ/đội; hoàn80%EXP thànhthẻ56/làmtrònxuống theo xác nhận người chơi. Thú cap cũ thiếu ledgerEXP tràn phải đối chiếu riêng.', 'Combat dùng bảng runtime Việt Nam mới. Osiris/Arceus/Eva chiêu HP từ hiệp1/mỗi hiệp theo user xác nhận; Long chưa có thời hạn Choáng, Chu Tước chưa có tham số burn. Xem trạng thái từng kỹ năng, không coi PARTIAL là đủ hiệu ứng gốc.', 'Không cộng chỉ số Thần Thú vào hồ sơ tướng hoặc lực chiến Main; chưa có bằng chứng nguồn cho phép. Không áp vào đội Thần Vực khi chưa có liên kết nguồn.'] }; }
}
