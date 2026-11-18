import { runAdvancedPet, advancedPetFamily, petCombatRules } from './pet-advanced.js';
import { petSkillPlan } from './pet-skills.js';
import { skillVisualTransition } from './combat-visual-state.js';
import { beastConfig } from './beast-source.js';
import { beastSkillPlan, beastCombatSupported } from './beast-skills.js';
import { dragonBallContext } from './combat-faction.js';
import { transformationClientState } from './transformation-graph.js';
import { artifactReduction, artifactLifeSteal } from './artifact-combat.js';
import { transformationSkillScript } from './transformation-skill.js';
import { compileSkill } from './skill-effects.js';
import { revivalRule, EmpowermentCombat, empoweredFamilies } from './combat-lifecycle.js';
import { playerExperience } from './player-vitals.js';
import { fusionRule, fusionPartner, fusionCandidates, fusionAttributes, fusionDiagnostics, fusionStatPolicy, fusionFields, fusionSkillPlan, fusionSkillAnimation } from './combat-fusion.js';
export const localCombatRules = { version: 'local-combat-v6', maxRounds: 30, normalMultiplier: 1, minimumDamage: 1, notice: 'LOCAL: hệ số skill = effect + effect_lvchange×cấp theo Lua; công vật/ma/tốc, hồi HP, hiệu ứng có hạn theo mô tả nguồn. Phòng thủ×0,5/dao động sát thương/thứ tự cộng dồn còn là adapter LOCAL. Hiệu ứng chưa có hợp đồng nguồn được báo thiếu, không dùng đòn1,5× thay thế.' };
export function localPlayerExperience(profile, gain) {
    return playerExperience(profile, gain);
}
export function serializeEntity(index, id, cfgId, h, cfg, skills) {
    const values = [h.hp, h.patk, h.matk, h.def, h.speed];
    if (values.some(v => !Number.isFinite(v) || v < 0) || h.hp <= 0)
        throw Object.assign(new Error('Chỉ số combat không hợp lệ.'), { statusCode: 422 });
    // battle_over_pop.init tách id bằng '_' để lấy owned ID ở phần thứ hai.
    const wireId = 'local_' + id, card = { card_id: cfgId, id: wireId, hp: h.hp, phsc: h.patk, mgc: h.matk, dfs: h.def, speed: h.speed, lv: h.lv ?? 1, exp: h.exp ?? 0, pos: index % 100 + 1, hr: 95, dr: 0, crit: 0, career: cfg.career ?? 0, race: cfg.race ?? 0, boss: cfg.is_boss ?? 0, animation: cfg.animation };
    return { index, card, record: { ...Object.fromEntries(Object.entries(transformationClientState(h)).filter(([k]) => !['combat_empowerment', 'combat_auxiliary'].includes(k))), id: wireId, c_id: cfgId }, hp: h.hp, maxHp: h.hp, attack: Math.max(h.patk, h.matk), defense: h.def, speed: h.speed, skills, skinActive: skills.some(s => s.skinActive === true), originConfigId: Number(h.c_id ?? cfgId), empowerment: h.combat_empowerment ?? [], ...(h.combat_auxiliary?.length ? { auxiliary: h.combat_auxiliary } : {}) };
}
export function compatibleSkills(entity, type = 'KBEFOREATTACK') {
    // Ưu tiên sprite_py; adapter cùng model/slot có provenance rõ trong catalog.
    // Bộ lọc tài nguyên độc lập với loại hiệu ứng; KDEAD/heal/buff vẫn được đăng ký.
    return entity.skills.flatMap(s => {
        if (s.cfg?.skill_type !== type || !s.cfg.sprite_py)
            return [];
        const script = transformationSkillScript(entity.card.card_id, entity.card.animation, s.id, s.cfg.sprite_py);
        return script ? [{ ...s, animationName: script.name, scriptResolution: script.status }] : [];
    });
}
export function compatibleSkill(entity) { return compatibleSkills(entity)[0]; }
export function combatSkillDiagnostics(e) { return e.skills.map(s => { const plan = fusionSkillPlan(e, s); return { skillId: s.id, type: s.cfg?.skill_type, rate: s.cfg?.rate, preCooldown: s.cfg?.pre_cd, cooldown: s.cfg?.cd, roundLimit: plan.roundLimit, maxRound: plan.maxRound, sourceSlot: s.sourceSlot, runtimeSlot: s.runtimeSlot, origin: s.origin, requiredStage: s.requiredStage, status: !compatibleSkills(e, s.cfg?.skill_type).some(x => x.id === s.id) ? 'MISSING_CLIENT_RESOURCE' : !plan.effects.length ? 'MISSING_BATTLE_HANDLER' : plan.status, effects: plan.effects, revival: revivalRule(e, s), fusion: fusionDiagnostics(e, s), ...(e.skills.some(v => fusionRule(e, v)) ? { postFusion: { effects: fusionSkillPlan(e, s, true).effects, animation: fusionSkillAnimation(e, compatibleSkills(e, s.cfg?.skill_type).find(v => v.id === s.id) ?? s, true), blockers: fusionSkillPlan(e, s, true).blockers, notice: 'Chỉ áp dụng sau khi có trạng thái Hợp Thể trong trận; không phát lại tiền chiến.' } } : {}), blockers: plan.blockers, coefficient: plan.coefficient, progression: plan.rebirthSource, visualTransition: skillVisualTransition(e, s), notice: 'Hệ số theo consumer Lua; xem các giới hạn còn thiếu, không tương đương engine gốc.' }; }); }
export function combatEmpowermentDiagnostics(e) { const chosen = empoweredFamilies(e); return (e.empowerment ?? []).flatMap(row => (row.lines ?? []).map((l) => ({ equipmentId: row.equipmentId, family: l.family, skillId: l.sid, name: l.name, count: l.count, required: l.required, active: l.active, effect: l.effect, attributeStatus: l.active ? 'CANONICAL_APPLIED' : 'INACTIVE', battleStatus: !l.active ? 'INACTIVE' : l.family === 6 ? 'STAT_SUPPORTED' : chosen.get(l.family)?.equipmentId === row.equipmentId ? 'IMPLEMENTED_UNVERIFIED' : 'NON_STACKING_SUPPRESSED', missing: l.family === 10 ? 'Tỉ lệ/cap/không tiền chiến từ txt#11; khôi phục vòng đời/HP từ quan sát bản gốc người dùng xác nhận. Thứ tự đồng thời dùng adapter LOCAL.' : l.family === 5 ? 'Config A ghi3lượt, txt/power_text ghi2lượt; LOCAL dùng số có cấu trúc3, chưa xác nhận parity thời hạn.' : l.family === 6 ? null : l.family === 2 ? 'Thiếu atlas/texture buff_qusanwudi trong cả gói VN: có gỡ Vô Địch và damage, chưa có hoạt ảnh phá riêng.' : 'Theo tooltip VN; thứ tự đồng thời và chọn mục tiêu không ghi rõ vẫn là adapter LOCAL.' }))); }
export function simulateBattle(input, seed, options = {}) {
    const entities = structuredClone(input), init = { atk: Array(10).fill(0), dfd: Array(10).fill(0), card_att: {}, card_def: {}, atk_skill: [0, 0, 0], dfd_skill: [0, 0, 0], atk_name: 'Đội local', dfd_name: 'Đối thủ Thám Hiểm', atk_lv: 1, dfd_lv: 1, atk_role: 1, dfd_role: 1, aform: 1, dform: 1, equip_att: {}, equip_def: {}, equip_pos_att: {}, equip_pos_def: {}, sort_array: [] };
    for (const e of entities) {
        const own = e.index < 100;
        init[own ? 'atk' : 'dfd'][e.index % 100] = { ...e.card, hp: e.maxHp };
        init[own ? 'card_att' : 'card_def'][e.card.id] = e.record;
    }
    const pets = entities.flatMap(e => e.pet ? [{ ...e.pet, camp: e.index < 100 ? 0 : 1 }] : []);
    for (const camp of [0, 1]) {
        const team = pets.filter(p => p.camp === camp);
        if (team.length > 1)
            throw Error('Mỗi phe chỉ có một PET chiến đấu.');
        for (const p of team) {
            if (!p.id || !p.animation || !['hp', 'patk', 'matk', 'def', 'speed'].every(f => Number.isFinite(p[f]) && p[f] >= 0) || p.hp <= 0 || !Array.isArray(p.selectedSkills) || !p.selectedSkills.length || p.selectedSkills.length > 2 || new Set(p.selectedSkills.map((s) => s.s)).size !== p.selectedSkills.length || p.selectedSkills.some((s) => !petSkillPlan(s.s) || !Number.isInteger(s.lv) || s.lv < 1 || s.lv > petSkillPlan(s.s).cfg.max_lv))
                throw Error('PET thiếu kỹ năng/chỉ số chiến đấu hợp lệ.');
            const key = camp === 0 ? 'att' : 'def';
            init['pet_id_' + key] = p.id;
            init['pet_' + key] = { [p.id]: p };
        }
    }
    init.pet_att ??= {};
    init.pet_def ??= {};
    const beasts = entities.flatMap(e => (e.beasts ?? []).map(b => ({ ...b, camp: e.index < 100 ? 0 : 1 })));
    if (beasts.length) {
        for (const camp of [0, 1]) {
            const team = beasts.filter(b => b.camp === camp);
            if (team.length > 2 || new Set(team.map(b => b.beast_num)).size !== team.length)
                throw Error('Đội Thần Thú bị trùng hoặc quá số lượng.');
            for (const b of team) {
                const cfg = beastConfig('combiner')[b.beast_num];
                if (!cfg || b.animation !== cfg.animation || !Number.isFinite(b.patk) || b.patk < 0 || !Number.isFinite(b.hp) || b.hp <= 0 || !Array.isArray(b.selectedSkills) || !b.selectedSkills.length || b.selectedSkills.length > 2 || new Set(b.selectedSkills).size !== b.selectedSkills.length || b.selectedSkills.some((sid) => Math.floor(sid / 100) !== b.beast_num || !beastCombatSupported(sid)))
                    throw Error('Thiếu handler chiến đấu Thần Thú.');
            }
            init[camp === 0 ? 'beast_att' : 'beast_def'] = team;
            init[camp === 0 ? 'beast_skill_att' : 'beast_skill_def'] = [...team.flatMap(b => b.selectedSkills), 0, 0, 0, 0].slice(0, 4);
        }
    }
    let frameNumber = 0;
    const frames = {}, emit = (flag, param) => frames[String(++frameNumber)] = { flag, param };
    // Chỉ vị trí 0..4 vào sân. 5..9 là dự bị, thay người qua frame sbt gốc.
    const active = new Set(entities.filter(e => e.index % 100 < 5));
    const side = (own) => entities.filter(e => active.has(e) && (e.index < 100) === own && e.hp > 0);
    if (!side(true).length || !side(false).length)
        throw Object.assign(new Error('Cần đội hình và đối thủ còn sống.'), { statusCode: 422 });
    let rounds = 0, state = seed >>> 0;
    const rng = () => { if (options.random) {
        const n = options.random();
        if (!Number.isFinite(n) || n < 0 || n >= 1)
            throw Error('RNG ngoài giới hạn');
        return n;
    } state = (Math.imul(state, 1664525) + 1013904223) >>> 0; return state / 4294967296; };
    const trace = [], tracing = options.trace ?? process.env.LOCAL_BATTLE_TRACE === '1';
    const log = (e, data) => { if (tracing && trace.length < 1000)
        trace.push({ hero: e.card.id, round: rounds, ...data }); };
    const statuses = new Map(), used = new Map(), baseStats = new Map(entities.map(e => [e, { patk: e.card.phsc, matk: e.card.mgc, def: e.defense - Number(e.continuation?.bonus.def ?? 0), speed: e.speed - Number(e.continuation?.bonus.speed ?? 0), hp: e.continuation ? e.card.hp : e.maxHp, ...Object.fromEntries(['fire', 'water', 'wind', 'earth', 'fire_dfs', 'water_dfs', 'wind_dfs', 'earth_dfs', 'crit', 'dodge', 'healAmp', 'damageReduction'].map(f => [f, Number(e.record[f] ?? (f === 'crit' ? e.card.crit : f === 'dodge' ? e.card.dr : 0) ?? 0)])) }]));
    const fusionBonus = new Map(entities.flatMap(e => e.continuation ? [[e, e.continuation.bonus]] : []));
    const activeStatuses = (e) => (statuses.get(e) ?? []).filter(s => (s.starts ?? 0) <= rounds && s.expires >= rounds);
    const stat = (e, f) => Number(baseStats.get(e)[f] ?? 0) * (1 + activeStatuses(e).filter(s => s.effect.kind === 'modifier' && s.effect.stat === f).reduce((n, s) => n + s.effect.percent * s.count, 0) / 100) + activeStatuses(e).filter(s => s.effect.kind === 'modifier' && s.effect.stat === f).reduce((n, s) => n + Number(s.effect.flat ?? 0) * s.count, 0) + Number(fusionBonus.get(e)?.[f] ?? 0);
    const refresh = (e) => { e.attack = Math.max(0, stat(e, 'patk'), stat(e, 'matk')); e.defense = Math.max(0, stat(e, 'def')); e.speed = Math.max(0, stat(e, 'speed')); const next = Math.max(1, stat(e, 'hp')); if (next !== e.maxHp) {
        e.hp = Math.min(next, Math.floor(e.hp / e.maxHp * next));
        e.maxHp = next;
    } };
    const petExtensions = pets.some(p => p.selectedSkills.some((s) => advancedPetFamily(petSkillPlan(s.s)?.cfg.sprite_py ?? '')));
    const reduction = (e) => Math.max(0, activeStatuses(e).filter(s => s.effect.kind === 'reduction').reduce((n, s) => Math.max(n, s.effect.percent), artifactReduction(e.auxiliary ?? [])) + stat(e, 'damageReduction'));
    const healingMultiplier = (e) => 1 + Math.max(0, stat(e, 'healAmp') + Math.max(0, ...activeStatuses(e).filter(s => s.effect.kind === 'healingBoost').map(s => e.hp / e.maxHp * 100 < petCombatRules.haoHealing.lowHpThreshold ? petCombatRules.haoHealing.lowHpBonus : s.effect.percent))) / 100;
    const elementGuard = (t, value) => { if (value <= 0)
        return value; const guard = activeStatuses(t).find(s => s.effect.kind === 'elementGuard' && s.count > 0); if (!guard)
        return value; guard.count--; log(t, { event: 'PET_ELEMENT_GUARD', blocked: value }); return 0; };
    const skillElement = (e, t) => petExtensions ? elementGuard(t, ['fire', 'water', 'wind', 'earth'].reduce((n, f) => n + Math.max(0, stat(e, f) - stat(t, f + '_dfs')), 0)) : 0;
    const petHit = (e, t) => { if (!petExtensions)
        return true; const blind = activeStatuses(e).filter(s => s.effect.kind === 'blind').reduce((n, s) => Math.max(n, s.effect.percent), 0), miss = Math.min(100, Math.max(0, stat(t, 'dodge')) + blind); if (miss > 0 && rng() * 100 < miss) {
        log(e, { event: 'PET_STATUS_MISS', target: t.index, miss });
        return false;
    } return true; };
    const petCritical = (e) => { const chance = petExtensions ? Math.min(100, Math.max(0, stat(e, 'crit'))) : 0; if (chance > 0 && rng() * 100 < chance) {
        log(e, { event: 'PET_CRITICAL', multiplier: petCombatRules.critical.multiplier });
        return petCombatRules.critical.multiplier;
    } return 1; };
    const burnCover = (source, target) => { if (source.hp <= 0)
        return; for (const cover of activeStatuses(target).filter(s => s.effect.kind === 'burnCover')) {
        const key = cover.source + ':return-burn', list = (statuses.get(source) ?? []).filter(s => s.source !== key);
        list.push({ source: key, effect: { kind: 'dot', stat: 'burn', target: 'enemy', percent: cover.effect.percent, duration: petCombatRules.kirara.returnBurnTurns, frame: 'buff_fire' }, expires: Math.max(1, rounds) + petCombatRules.kirara.returnBurnTurns - 1, count: 1 });
        statuses.set(source, list);
        emit('add_buff', { src: source.index, des: source.index, name: 'buff_fire' });
        log(source, { event: 'PET_BURN_COVER', defender: target.index, percent: cover.effect.percent });
    } };
    const artifactHeal = (e, damage) => { if (e.hp <= 0 || damage <= 0)
        return; const hp = Math.min(e.maxHp - e.hp, Math.floor(artifactLifeSteal(e.auxiliary ?? [], damage) * healingMultiplier(e))); if (hp > 0) {
        e.hp += hp;
        emit('cur_data', { [e.index]: { tempHp: e.hp } });
        log(e, { event: 'ARTIFACT_LIFESTEAL', damage, health: hp });
    } };
    const cooldown = new Map(), diagnostics = entities.flatMap(e => combatSkillDiagnostics(e).map(s => ({ hero: e.card.id, ...s })));
    const sorted = () => entities.filter(e => active.has(e) && e.hp > 0).sort((a, b) => b.speed - a.speed || a.index - b.index);
    const lifeEvents = [], lifeUse = new Map(), settling = new Set(), pending = new Map();
    const lethalCauses = new Map();
    const entry = new Map();
    const fusions = new Map(entities.flatMap(e => e.continuation ? [[e, e.continuation.fusion]] : [])), visualStates = new Map();
    const event = (e, v) => { if (lifeEvents.length < 1000)
        lifeEvents.push({ hero: e.card.id, round: rounds, ...v }); log(e, v); };
    const fate = new EmpowermentCombat(entities, rng, () => rounds, sorted, emit, (e, v) => event(e, { ...v, event: 'EMPOWERMENT_' + v.event }));
    const donorEvidence = (e) => ({ hero: e.card.id, active: active.has(e), hp: e.hp, cause: lethalCauses.get(e)?.kind ?? null, native: compatibleSkills(e, 'KDEAD').flatMap(s => { const rule = revivalRule(e, s); return rule ? [{ skillId: s.id, used: lifeUse.get(e)?.get(s.id) ?? 0, limit: rule.limit }] : []; }) });
    const donorEligible = (e) => {
        const cause = lethalCauses.get(e);
        if (e.hp <= 0 && (cause?.kind === 'annihilation' || cause?.kind === 'fatalBurn'))
            return false;
        const native = compatibleSkills(e, 'KDEAD').flatMap(s => { const rule = revivalRule(e, s); return rule ? [{ s, rule }] : []; });
        // Không áp đặt skill đỏ Kakarot nếu nguồn không yêu cầu và anh ta còn sống.
        // Khi đã có ngân sách xác minh, hết lượt thì không dùng để Hợp Thể.
        return native.length ? native.some(({ s, rule }) => (lifeUse.get(e)?.get(s.id) ?? 0) < rule.limit && Number(s.cfg.rate) > 0 && rounds >= (cooldown.get(e)?.get(s.id) ?? Number(s.cfg.pre_cd ?? 0))) : e.hp > 0;
    };
    let deathResolutions = 0;
    const markDeath = (target, cause = { kind: 'damage' }) => {
        if (target.hp !== 0 || !active.has(target))
            return;
        if (settling.has(target)) {
            pending.set(target, cause);
            return;
        }
        settling.add(target);
        try {
            // KDEAD hai bên có thể Diệt Ngay lẫn nhau và đồng thời hoàn lượt. Hủy
            // giao dịch nếu chuỗi không hội tụ; tuyệt đối không giả chết/thắng để thoát.
            if (++deathResolutions > 500)
                throw Object.assign(Error('Chuỗi Hồi Sinh vượt giới hạn an toàn LOCAL; trận chưa được kết toán.'), { statusCode: 422, code: 'LOCAL_COMBAT_CYCLE' });
            if (cause.kind !== 'annihilation' && cause.kind !== 'fatalBurn')
                for (const s of compatibleSkills(target, 'KDEAD')) {
                    const native = revivalRule(target, s, dragonBallContext(target, side(target.index < 100))?.count);
                    if (!native)
                        continue;
                    const fusion = fusions.get(target), rule = fusion ? { ...native, limit: fusion.revivals, refundChance: 0 } : native;
                    const counters = lifeUse.get(target) ?? new Map();
                    lifeUse.set(target, counters);
                    const consumed = counters.get(s.id) ?? 0;
                    const pre = Number(s.cfg.pre_cd ?? 0), cd = Number(s.cfg.cd ?? 0), rate = Number(s.cfg.rate ?? 100), plan = compileSkill(s.cfg, s.lv, target.skinActive === true);
                    if (![pre, cd, rate].every(Number.isFinite) || pre < 0 || cd < 0 || rate < 0 || rate > 100 || rounds < (cooldown.get(target)?.get(s.id) ?? pre) || plan.maxRound && rounds > plan.maxRound)
                        continue;
                    if (consumed >= rule.limit)
                        continue;
                    const combine = !fusion ? fusionRule(target, s) : null, partner = combine ? fusionPartner(target, entities, active, donorEligible) : undefined;
                    if (combine && !partner)
                        event(target, { event: 'FUSION_INELIGIBLE', reason: 'Không có Kakarot cùng sân còn điều kiện sống/ngân sách hồi sinh hợp lệ.', partners: fusionCandidates(target, entities).map(donorEvidence) });
                    if (rng() * 100 >= rate)
                        continue;
                    if (combine && partner) {
                        // Chụp chỉ số hiện tại một lần theo xác nhận user; không sao chép vật phẩm/buff.
                        const before = Object.fromEntries(fusionFields.map(f => [f, stat(target, f)])), donor = Object.fromEntries(fusionFields.map(f => [f, stat(partner, f)])), after = fusionAttributes(before, donor, combine.bonusPercent), partnerBefore = donorEvidence(partner);
                        fusionBonus.set(target, Object.fromEntries(fusionFields.map(f => [f, after[f] - before[f]])));
                        refresh(target);
                        target.hp = target.maxHp;
                        emit('cur_data', { [target.index]: { tempHp: target.hp, maxHp: target.maxHp } });
                        // game_util.playSection chặn qianjin/bianshen khi model còn siwang.
                        // Cam kết s6→s8 trước khi giải quyết KDEAD phản hồi của mục tiêu.
                        // Không bỏ Kakarot trước khi actor/trạng thái Gogeta có frame hợp lệ.
                        let committed = false;
                        const executed = cast(target, s, rounds, true, target.hp, false, () => {
                            if (!active.has(target) || target.hp <= 0 || !active.has(partner) || !donorEligible(partner))
                                throw Object.assign(Error('Hợp Thể chưa thể khởi tạo actor an toàn; trận chưa được kết toán.'), { statusCode: 422, code: 'FUSION_TRANSITION_FAILED' });
                            emit('skill', { src: target.index, des: target.index, hurt: 0, spc: 0, name: combine.animation, skillid: s.id, desh: target.index, health: target.hp });
                            fusions.set(target, { ...combine, partner: partner.card.id, statPolicy: fusionStatPolicy, donor });
                            counters.set(s.id, 0);
                            cooldown.get(target)?.delete(s.id);
                            partner.hp = 0;
                            active.delete(partner);
                            statuses.delete(partner);
                            lethalCauses.delete(partner);
                            emit('cur_data', { [partner.index]: { tempHp: 0 } });
                            emit('death', partner.index);
                            event(target, { event: 'FUSION', partner: partner.card.id, skillId: s.id, form: combine.kind, statsBefore: before, partnerStats: donor, statsAfter: after, statPolicy: fusionStatPolicy, revivals: combine.revivals, source: combine.source, partnerBefore });
                            committed = true;
                            fate.nativeRevived(target);
                        });
                        if (!executed || !committed)
                            throw Object.assign(Error('Hợp Thể thiếu callback khởi tạo; trận chưa được kết toán.'), { statusCode: 422, code: 'FUSION_TRANSITION_FAILED' });
                        return;
                    }
                    if (consumed < rule.limit) {
                        const refunded = rule.refundChance > 0 && rng() * 100 < rule.refundChance;
                        counters.set(s.id, consumed + (refunded ? 0 : 1));
                        target.hp = Math.max(1, Math.floor(target.maxHp * rule.hpPercent / 100));
                        // Không phát death: objectDead của client xóa model khỏi scene. Hồi sinh
                        // thường dùng chính KDEAD/health trên actor còn tồn tại; reenter chỉ Con Lắc.
                        emit('cur_data', { [target.index]: { tempHp: target.hp, maxHp: target.maxHp } });
                        event(target, { event: 'NATIVE_REVIVE', skillId: s.id, consumed: counters.get(s.id), limit: rule.limit, refunded, health: target.hp, source: rule.source });
                        lethalCauses.delete(target);
                        fate.nativeRevived(target);
                        cast(target, s, rounds, true, target.hp);
                        return;
                    }
                }
            fate.realDeath(target);
            if (fate.rewindAllowed(target, cause)) {
                for (const frame of new Set((statuses.get(target) ?? []).filter(s => !s.effect.permanent).map(s => s.effect.frame).filter(Boolean)))
                    emit('remove_buff', { src: target.index, name: frame });
                lifeUse.delete(target);
                cooldown.delete(target);
                used.delete(target);
                statuses.set(target, structuredClone(entry.get(target) ?? []));
                refresh(target);
                target.hp = target.maxHp;
                emit('cur_data', { [target.index]: { tempHp: target.hp, maxHp: target.maxHp } });
                emit('reenter', { src: target.index });
                event(target, { event: 'TIME_REWIND', cause: cause.kind, nativeCountersReset: true, health: target.hp, rewindCount: fate.inspect(target).rewinds });
                return;
            }
            emit('death', target.index);
            active.delete(target);
            statuses.delete(target);
            event(target, { event: 'FINAL_DEATH', cause: cause.kind });
            const reserve = entities.find(r => !active.has(r) && r.hp > 0 && r.index % 100 >= 5 && (r.index < 100) === (target.index < 100));
            if (reserve) {
                const from = reserve.index;
                reserve.index = target.index;
                active.add(reserve);
                emit('sbt', { a: target.index, b: from });
                emit('cur_data', { [target.index]: { tempHp: reserve.hp } });
            }
        }
        finally {
            settling.delete(target);
            const queued = pending.get(target);
            pending.delete(target);
            if (deathResolutions <= 500 && target.hp === 0 && active.has(target))
                markDeath(target, queued ?? cause);
        }
    };
    let depth = 0;
    const running = new Set();
    const annihilate = (source, target) => { const damage = target.hp; target.hp = 0; lethalCauses.set(target, { kind: 'annihilation', source }); emit('buff_skill', { src: source.index, des: target.index, name: 'buff_juemie_skill', hurt: damage }); emit('cur_data', { [target.index]: { tempHp: 0 } }); markDeath(target, { kind: 'annihilation', source }); };
    const cast = (e, s, round, alreadyRolled = false, reviveHealth = 0, followup = false, afterFrame) => {
        const plan = fusionSkillPlan(e, s, fusions.has(e), side(e.index < 100));
        if (!plan.effects.length) {
            log(e, { skillId: s.id, result: 'UNSUPPORTED', reason: plan.blockers });
            return false;
        }
        if (plan.effects.every(x => x.kind === 'revive') && !alreadyRolled)
            return false;
        const times = cooldown.get(e) ?? new Map();
        cooldown.set(e, times);
        const pre = Number(s.cfg.pre_cd ?? 0), cd = Number(s.cfg.cd ?? 0), rate = Number(s.cfg.rate ?? 100);
        const calls = used.get(e) ?? new Map();
        used.set(e, calls);
        const callKey = round + ':' + s.id, limit = plan.roundLimit ?? 100, inflight = e.card.id + ':' + s.id;
        const reason = ![pre, cd, rate].every(Number.isFinite) || pre < 0 || cd < 0 || rate < 0 || rate > 100 ? 'INVALID_CONFIG' : plan.maxRound && round > plan.maxRound ? 'EXPIRED' : !followup && round < (times.get(s.id) ?? pre) ? 'COOLDOWN' : e.hp <= 0 || !active.has(e) ? 'NOT_ACTIVE' : (calls.get(callKey) ?? 0) >= limit ? 'ROUND_LIMIT' : depth >= 12 || running.has(inflight) ? 'REACTION_GUARD' : null;
        if (reason) {
            log(e, { skillId: s.id, event: s.cfg.skill_type, result: reason });
            return false;
        }
        const target = side(e.index >= 100)[0];
        if (!target)
            return false;
        if (!alreadyRolled && (rate === 0 || rate < 100 && rng() * 100 >= rate)) {
            log(e, { skillId: s.id, result: 'RATE_MISS' });
            return false;
        }
        times.set(s.id, round + Math.floor(cd));
        calls.set(callKey, (calls.get(callKey) ?? 0) + 1);
        running.add(inflight);
        depth++;
        try {
            // Với Hợp Thể, giữ chỗ frame KDEAD thật, khởi tạo actor mới trước mọi
            // phản ứng lồng nhau. Hệ số/hurt sẽ điền từ chính kết quả tính bên dưới.
            const transitionFrame = afterFrame ? String(frameNumber + 1) : null;
            if (transitionFrame) {
                emit('skill', {});
                emit('attack_over', { src: e.index });
                afterFrame();
            }
            let skillFrame = transitionFrame ? frames[transitionFrame] : undefined;
            const reserveFrame = () => { if (!skillFrame) {
                emit('skill', {});
                skillFrame = frames[String(frameNumber)];
            } };
            const dealt = new Map(), healed = new Map(reviveHealth > 0 ? [[e, reviveHealth]] : []), affected = new Set(reviveHealth > 0 ? [e] : []), causes = new Map(), killed = new Set();
            let total = 0;
            const petElementTargets = new Set(), hitCache = new Map();
            const killCandidates = side(e.index >= 100);
            const targets = (effect) => { const opponents = side(e.index >= 100).filter(t => !effect.excludeKilled || !killed.has(t)); if (effect.kind === 'instantKill') {
                const pool = effect.reviveDrain ? killCandidates.filter(t => active.has(t)) : [...opponents];
                if (effect.randomTargets)
                    for (let i = pool.length - 1; i > 0; i--) {
                        const j = Math.floor(rng() * (i + 1));
                        [pool[i], pool[j]] = [pool[j], pool[i]];
                    }
                return pool.slice(0, effect.limit ?? 0);
            } return effect.target === 'self' ? [e] : effect.target === 'allies' ? side(e.index < 100) : effect.target === 'allEnemies' ? opponents : effect.target === 'back' ? opponents.slice(-1) : opponents.slice(0, 1); };
            effects: for (const effect of plan.effects) {
                if (effect.kind === 'revive')
                    continue;
                for (const t of targets(effect)) {
                    if (t.hp <= 0 && !(effect.kind === 'instantKill' && effect.reviveDrain && active.has(t)))
                        continue;
                    if (effect.chance !== undefined && rng() * 100 >= effect.chance)
                        continue;
                    if (effect.kind === 'control' && effect.frame === 'buff_giddy' && activeStatuses(t).some(v => v.effect.kind === 'controlImmunity' && v.effect.stat === 'stun')) {
                        log(t, { event: 'CONTROL_IMMUNE', source: e.card.id });
                        continue;
                    }
                    affected.add(t);
                    if (effect.kind === 'damage') {
                        trigger(t, 'KBEATTACK', round);
                        if (e.hp <= 0 || !active.has(e))
                            break effects;
                        if (t.hp <= 0 || !active.has(t))
                            continue;
                        // Đặt frame khi người phát còn trên sân; phản ứng ở mục tiêu AOE sau
                        // có thể hấp thụ/chuyển actor này, không được phát animation từ actor đã mất.
                        reserveFrame();
                        if (!hitCache.has(t))
                            hitCache.set(t, petHit(e, t));
                        if (!hitCache.get(t))
                            continue;
                        const extra = petElementTargets.has(t) ? 0 : skillElement(e, t);
                        petElementTargets.add(t);
                        const value = stat(e, effect.stat ?? 'patk') * effect.percent / 100, raw = Math.max(1, Math.floor(((value - (effect.trueDamage ? 0 : t.defense * .5)) * (effect.trueDamage ? 1 : .95 + rng() * .1) + extra) * petCritical(e))), damage = Math.min(t.hp, fate.damage(e, t, Math.floor(raw * (1 - Math.min(100, reduction(t)) / 100))));
                        t.hp -= damage;
                        if (damage > 0)
                            burnCover(e, t);
                        if (t.hp === 0)
                            lethalCauses.set(t, { kind: 'damage', source: e });
                        dealt.set(t, (dealt.get(t) ?? 0) + damage);
                        total += damage;
                    }
                    else if (effect.kind === 'heal' || effect.kind === 'lifesteal') {
                        const value = effect.kind === 'lifesteal' ? total * effect.percent / 100 : stat(t, effect.stat ?? 'hp') * effect.percent / 100, health = Math.max(0, Math.min(t.maxHp - t.hp, Math.floor(value * healingMultiplier(t))));
                        t.hp += health;
                        healed.set(t, (healed.get(t) ?? 0) + health);
                    }
                    else if (effect.kind === 'instantKill') {
                        const victim = t;
                        if (victim.hp > 0 || effect.reviveDrain) {
                            if (effect.reviveDrain) {
                                if (fusions.has(victim))
                                    event(victim, { event: 'REVIVE_DRAIN_BLOCKED', source: e.card.id, reason: 'Hai lượt Hồi Sinh hợp thể không bị xoá theo tooltip.' });
                                else
                                    for (const deathSkill of compatibleSkills(victim, 'KDEAD')) {
                                        const rule = revivalRule(victim, deathSkill);
                                        if (!rule)
                                            continue;
                                        const counters = lifeUse.get(victim) ?? new Map();
                                        lifeUse.set(victim, counters);
                                        const before = counters.get(deathSkill.id) ?? 0, after = Math.min(rule.limit, before + effect.reviveDrain);
                                        counters.set(deathSkill.id, after);
                                        event(victim, { event: 'REVIVE_DRAIN', source: e.card.id, skillId: deathSkill.id, removed: after - before, consumed: after, limit: rule.limit });
                                    }
                            }
                            if (victim.hp > 0 && fate.instantKillAllowed(e, victim)) {
                                const damage = victim.hp;
                                victim.hp = 0;
                                killed.add(victim);
                                dealt.set(victim, (dealt.get(victim) ?? 0) + damage);
                                affected.add(victim);
                                causes.set(victim, { kind: 'instantKill', source: e });
                                lethalCauses.set(victim, { kind: 'instantKill', source: e });
                                total += damage;
                            }
                        }
                    }
                    else if (effect.kind === 'guard') {
                        fate.grantGuard(t, effect.limit ?? 0, effect.duration);
                    }
                    else if (effect.kind === 'invulnerable' && effect.duration) {
                        fate.setInvulnerable(t, effect.duration);
                    }
                    else if (effect.duration || effect.permanent) {
                        const list = statuses.get(t) ?? [], key = e.card.id + ':' + s.id + ':' + effect.kind + ':' + effect.stat, old = list.find(x => x.source === key);
                        const expires = effect.permanent ? Number.MAX_SAFE_INTEGER : Math.max(1, round) + effect.duration - 1;
                        if (old) {
                            old.expires = expires;
                            old.count = Math.min(effect.stacks ?? 1, old.count + 1);
                        }
                        else
                            list.push({ source: key, effect, expires, count: 1 });
                        statuses.set(t, list);
                        const beforeMax = t.maxHp;
                        refresh(t);
                        if (beforeMax !== t.maxHp)
                            emit('cur_data', { [t.index]: { tempHp: t.hp, maxHp: t.maxHp } });
                        if (effect.frame)
                            emit('add_buff', { src: t.index, name: effect.frame, des: t.index });
                    }
                }
            }
            const damaged = [...dealt], healing = [...healed], param = { src: e.index, des: damaged.length === 1 ? damaged[0][0].index : damaged.length ? damaged.map(([t]) => t.index) : e.index, hurt: damaged.length === 1 ? damaged[0][1] : damaged.length ? damaged.map(([, v]) => v) : 0, spc: 0, name: fusionSkillAnimation(e, s, fusions.has(e)), skillid: s.id };
            if (healing.length) {
                param.desh = healing.length === 1 ? healing[0][0].index : healing.map(([t]) => t.index);
                param.health = healing.length === 1 ? healing[0][1] : healing.map(([, v]) => v);
            }
            if (!skillFrame && (e.hp <= 0 || !active.has(e))) {
                log(e, { skillId: s.id, result: 'INTERRUPTED', reason: 'Actor đã rời sân trong phản ứng; không phát skill từ actor đã mất.' });
                return false;
            }
            if (skillFrame)
                skillFrame.param = param;
            else
                emit('skill', param);
            for (const t of affected)
                emit('cur_data', { [t.index]: { tempHp: t.hp } });
            if (!transitionFrame)
                emit('attack_over', { src: e.index });
            log(e, { skillId: s.id, source: s.origin, sourceSlot: s.sourceSlot, event: s.cfg.skill_type, result: 'EXECUTED', targets: [...affected].map(t => t.index), damage: total, healing: healing.reduce((n, [, v]) => n + v, 0), effects: plan.effects });
            if (s.cfg.skill_type === 'KBEFOREATTACK')
                fate.afterActiveAttack(e, t => annihilate(e, t));
            if (s.cfg.skill_type === 'KBEFOREATTACK')
                artifactHeal(e, total);
            const visual = skillVisualTransition(e, s);
            if (visual && visualStates.get(e) !== visual.state) {
                visualStates.set(e, visual.state);
                event(e, { event: 'SKILL_TRANSFORM', skillId: s.id, model: e.card.animation, state: visual.state, source: visual.source, requiredRebirthForAttributes: visual.requiredRebirthForAttributes });
            }
            // Một gói AOE là một sự kiện: xét Hợp Thể đủ điều kiện trước khi tiêu
            // lượt của Kakarot cùng bị hạ. Không phụ thuộc ai đứng ô thấp hơn.
            const deathPriority = (t) => t.hp === 0 && compatibleSkills(t, 'KDEAD').some(v => fusionRule(t, v)) && fusionPartner(t, entities, active, donorEligible) ? 0 : 1;
            const settlement = [...damaged].sort(([a], [b]) => deathPriority(a) - deathPriority(b) || a.index - b.index);
            for (const [t] of settlement) {
                if (t.hp > 0)
                    trigger(t, 'KBEFOREHERT', round);
                markDeath(t, causes.get(t) ?? { kind: 'damage', source: e });
            }
            return true;
        }
        finally {
            depth--;
            running.delete(inflight);
        }
    };
    const trigger = (e, type, round, first = false) => {
        if (activeStatuses(e).some(s => s.effect.kind === 'triggerLock' && s.effect.stat === type)) {
            log(e, { event: type, result: 'BEAST_TRIGGER_LOCKED' });
            return false;
        }
        for (const s of compatibleSkills(e, type))
            if (cast(e, s, round)) {
                if (fusions.has(e) && /Ở trạng thái "Cực Ý Gogeta" liên tục phóng 2 lần/.test(s.cfg.skill_story) && e.hp > 0 && active.has(e))
                    cast(e, s, round, true, 0, true);
                if (first)
                    return true;
            }
        return false;
    };
    const beastUsed = new Map(), beastRoundUsed = new Map();
    const castBeasts = (phase, round) => {
        for (const b of beasts)
            for (const sid of b.selectedSkills) {
                if (!side(true).length || !side(false).length)
                    return;
                const plan = beastSkillPlan(sid), cfg = plan.cfg, key = b.camp + ':' + b.beast_num + ':' + sid;
                // Notice176 VN: mỗi phe chỉ phát một chiêu Thần Thú trong một hiệp.
                // Duyệt theo đội/kỹ năng đã lưu (adapter LOCAL); chưa trúng rate/đang CD không chiếm suất.
                if (beastRoundUsed.get(b.camp) === round)
                    continue;
                if (cfg.skill_type !== phase || round < cfg.pre_cd || round < (plan.firstRound ?? 0) || round < (beastUsed.get(key) ?? -10000) + cfg.cd || plan.roundRange && (round < plan.roundRange[0] || round > plan.roundRange[1]))
                    continue;
                let allies = side(b.camp === 0), opponents = side(b.camp === 1);
                if (plan.deathCondition) {
                    const camp = plan.deathCondition.camp === 'ally' ? b.camp : 1 - b.camp, members = entities.filter(e => (e.index < 100 ? 0 : 1) === camp), dead = new Set(lifeEvents.filter(e => e.event === 'FINAL_DEATH').map(e => e.hero));
                    const fallen = members.filter(e => dead.has(e.card.id) && e.hp === 0).length;
                    if (plan.deathCondition.mode === 'moreThanCount' ? fallen <= plan.deathCondition.threshold : fallen / Math.max(1, members.length) * 100 < plan.deathCondition.threshold)
                        continue;
                }
                if (plan.hpThreshold !== undefined && allies.reduce((n, e) => n + e.hp, 0) / allies.reduce((n, e) => n + e.maxHp, 0) * 100 >= plan.hpThreshold)
                    continue;
                if (rng() * 100 >= cfg.rate)
                    continue;
                beastUsed.set(key, round);
                if (plan.damage)
                    for (const target of (plan.target === 'single' ? opponents.slice(0, 1) : opponents))
                        trigger(target, 'KBEATTACK', round);
                allies = side(b.camp === 0);
                opponents = side(b.camp === 1);
                if (!allies.length || !opponents.length)
                    return;
                const source = { card: { id: 'beast-' + b.camp + '-' + b.beast_num }, empowerment: [], maxHp: b.hp };
                const damaged = new Map(), healed = new Map(), causes = new Map();
                const frame = String(frameNumber + 1);
                emit('skill_combiner', {});
                beastRoundUsed.set(b.camp, round);
                const targets = plan.target === 'single' ? opponents.slice(0, 1) : opponents;
                if (plan.damage) {
                    const value = (plan.stat === 'partyHp' ? allies.reduce((n, e) => n + e.maxHp, 0) + b.hp : Number(b[plan.stat])) * cfg.effect / 100;
                    for (const target of targets) {
                        const raw = Math.max(1, Math.floor((value - target.defense * .5) * (.95 + rng() * .1))), damage = Math.min(target.hp, fate.damage(source, target, Math.floor(raw * (1 - Math.min(100, reduction(target)) / 100))));
                        target.hp -= damage;
                        damaged.set(target, damage);
                        if (target.hp === 0)
                            lethalCauses.set(target, { kind: 'damage' });
                    }
                }
                if (plan.healBalls)
                    for (const ally of allies) {
                        const health = Math.max(0, Math.min(ally.maxHp - ally.hp, Math.floor(ally.maxHp * cfg.effect / 100 * healingMultiplier(ally)) * plan.healBalls));
                        ally.hp += health;
                        healed.set(ally, health);
                    }
                if (plan.killChance && rng() * 100 < plan.killChance) {
                    const pool = opponents.filter(e => e.hp > 0), target = pool[Math.floor(rng() * pool.length)];
                    if (target && fate.instantKillAllowed(source, target)) {
                        damaged.set(target, (damaged.get(target) ?? 0) + target.hp);
                        target.hp = 0;
                        causes.set(target, { kind: 'instantKill', source });
                        lethalCauses.set(target, { kind: 'instantKill', source });
                    }
                }
                if (plan.guardChance && rng() * 100 < plan.guardChance) {
                    const ally = allies[Math.floor(rng() * allies.length)];
                    fate.grantGuard(ally, 1);
                    event(ally, { event: 'BEAST_GUARD', beast: b.beast_num, skillId: sid, stacks: 1 });
                }
                const specialTargets = plan.triggerLock ? opponents : allies;
                if (plan.modifiers)
                    for (const ally of allies)
                        for (const modifier of plan.modifiers) {
                            const sourceKey = 'beast-buff:' + b.camp + ':' + modifier.stat, list = (statuses.get(ally) ?? []).filter(s => s.source !== sourceKey);
                            list.push({ source: sourceKey, effect: { kind: 'modifier', target: 'allies', duration: 1, ...modifier }, expires: Math.max(1, round), count: 1 });
                            statuses.set(ally, list);
                            refresh(ally);
                            emit('add_buff', { src: ally.index, des: ally.index, name: modifier.frame });
                            event(ally, { event: 'BEAST_MODIFIER', beast: b.beast_num, skillId: sid, stat: modifier.stat, percent: modifier.percent, flat: modifier.flat ?? 0, effective: stat(ally, modifier.stat), duration: 1 });
                        }
                if (plan.triggerLock && rng() * 100 < plan.lockChance)
                    for (const target of opponents) {
                        const sourceKey = 'beast-lock:' + b.camp + ':' + plan.triggerLock, list = (statuses.get(target) ?? []).filter(s => s.source !== sourceKey);
                        list.push({ source: sourceKey, effect: { kind: 'triggerLock', stat: plan.triggerLock, percent: 0, target: 'enemy', duration: 1 }, expires: Math.max(1, round), count: 1 });
                        statuses.set(target, list);
                        event(target, { event: 'BEAST_TRIGGER_LOCK', beast: b.beast_num, skillId: sid, type: plan.triggerLock, duration: 1 });
                    }
                const dealt = [...damaged], health = [...healed];
                frames[frame].param = { src: b.camp, des: dealt.length ? dealt.map(([t]) => t.index) : health.length ? health.map(([t]) => t.index) : specialTargets.map(t => t.index), hurt: dealt.length ? dealt.map(([, n]) => n) : 0, spc: 0, name: b.animation + '_s' + (sid % 100 >= 20 ? 2 : 1), beast_num: b.beast_num, skillid: sid, ...(health.length ? { desh: health.map(([t]) => t.index), health: health.map(([, n]) => n) } : {}) };
                for (const [target, damage] of dealt) {
                    emit('cur_data', { [target.index]: { tempHp: target.hp } });
                    if (target.hp > 0 && plan.stun && !activeStatuses(target).some(s => s.effect.kind === 'controlImmunity' && s.effect.stat === 'stun')) {
                        const list = (statuses.get(target) ?? []).filter(s => s.source !== 'beast:' + key);
                        list.push({ source: 'beast:' + key, effect: { kind: 'control', percent: 0, target: 'enemy', duration: plan.stun, frame: 'buff_giddy' }, expires: Math.max(1, round) + plan.stun - 1, count: 1 });
                        statuses.set(target, list);
                        emit('add_buff', { src: target.index, des: target.index, name: 'buff_giddy' });
                    }
                    event(target, { event: 'BEAST_DAMAGE', skillId: sid, beast: b.beast_num, camp: b.camp, damage, stat: plan.stat });
                }
                for (const [ally, health] of healed) {
                    emit('cur_data', { [ally.index]: { tempHp: ally.hp } });
                    event(ally, { event: 'BEAST_HEAL', skillId: sid, beast: b.beast_num, health, balls: plan.healBalls });
                }
                // Cùng ưu tiên Fusion trước hồi sinh đơn khi một gói AOE hạ đồng thời hai tướng.
                const priority = (t) => t.hp === 0 && compatibleSkills(t, 'KDEAD').some(v => fusionRule(t, v)) && fusionPartner(t, entities, active, donorEligible) ? 0 : 1;
                for (const [target] of dealt.sort(([a], [b]) => priority(a) - priority(b) || a.index - b.index)) {
                    if (target.hp > 0 && active.has(target))
                        trigger(target, 'KBEFOREHERT', round);
                    markDeath(target, causes.get(target) ?? { kind: 'damage' });
                }
            }
    };
    const petUsed = new Map();
    const castPets = (phase, round) => {
        for (const p of pets)
            for (const skill of p.selectedSkills) {
                if (!side(true).length || !side(false).length)
                    return;
                const plan = petSkillPlan(skill.s);
                if (!plan)
                    throw Error('PET thiếu handler kỹ năng ' + skill.s);
                const cfg = plan.cfg, key = p.camp + ':' + p.id + ':' + skill.s;
                if (cfg.skill_type !== phase || round < cfg.pre_cd || round < (petUsed.get(key) ?? -10000) + cfg.cd || rng() * 100 >= cfg.rate)
                    continue;
                petUsed.set(key, round);
                if (plan.extension) {
                    const frame = String(frameNumber + 1), name = p.animation + '_s' + (skill.s % 100 < 20 ? 1 : skill.s % 100 < 30 ? 2 : 3), damageMap = new Map(), healMap = new Map(), affected = new Set(), causes = new Map(), hits = new Map();
                    const source = { card: { id: 'pet-' + p.camp + '-' + p.id }, maxHp: p.hp, empowerment: [] };
                    emit('skill_pet', { src: p.camp, des: [], hurt: 0, spc: 0, name, skillid: skill.s });
                    const put = (t, suffix, effect, duration, delay = 0) => {
                        if (t.hp <= 0 || !active.has(t))
                            return;
                        const sourceKey = 'pet:' + key + ':' + suffix, list = (statuses.get(t) ?? []).filter(s => s.source !== sourceKey), starts = round + delay;
                        list.push({ source: sourceKey, effect: { ...effect, ...(duration === undefined ? { permanent: true } : { duration }) }, starts, expires: duration === undefined ? Number.MAX_SAFE_INTEGER : Math.max(1, starts) + duration - 1, count: 1 });
                        statuses.set(t, list);
                        const max = t.maxHp;
                        refresh(t);
                        affected.add(t);
                        if (max !== t.maxHp)
                            emit('cur_data', { [t.index]: { tempHp: t.hp, maxHp: t.maxHp } });
                        if (effect.frame && starts <= round)
                            emit('add_buff', { src: t.index, des: t.index, name: effect.frame });
                        log(t, { event: 'PET_STATUS', pet: p.id, skill: skill.s, kind: effect.kind, field: effect.stat, percent: effect.percent, flat: effect.flat ?? 0, starts, expires: duration === undefined ? 'battle' : Math.max(1, starts) + duration - 1, rules: petCombatRules.version });
                    };
                    runAdvancedPet({ pet: p, ratio: plan.coefficient(skill.lv), round, family: plan.family, rng, allies: () => side(p.camp === 0), enemies: () => side(p.camp !== 0), stat: (t, f) => Math.max(0, stat(t, f)),
                        damage: (t, parts, factor = 1) => {
                            if (t.hp <= 0 || !active.has(t) || !side(p.camp === 0).length)
                                return 0;
                            trigger(t, 'KBEATTACK', round);
                            if (t.hp <= 0 || !active.has(t) || !side(p.camp === 0).length)
                                return 0;
                            if (!hits.has(t)) {
                                const dodge = Math.min(100, Math.max(0, stat(t, 'dodge')));
                                hits.set(t, !dodge || rng() * 100 >= dodge);
                            }
                            if (!hits.get(t)) {
                                log(t, { event: 'PET_DODGE', pet: p.id });
                                return 0;
                            }
                            let raw = Number(parts.true ?? 0);
                            for (const f of ['physical', 'magic'])
                                if (parts[f])
                                    raw += Math.max(0, parts[f] - t.defense * .5);
                            const elemental = ['fire', 'water', 'wind', 'earth'].reduce((n, f) => n + Math.max(0, Number(parts[f] ?? 0) - stat(t, f + '_dfs')), 0);
                            raw += elementGuard(t, elemental);
                            const amount = Math.min(t.hp, fate.damage(source, t, Math.max(0, Math.floor(raw * factor * (1 - Math.min(100, reduction(t)) / 100)))));
                            t.hp -= amount;
                            damageMap.set(t, (damageMap.get(t) ?? 0) + amount);
                            affected.add(t);
                            if (t.hp === 0) {
                                causes.set(t, { kind: 'damage', source });
                                lethalCauses.set(t, { kind: 'damage', source });
                            }
                            log(t, { event: 'PET_DAMAGE', pet: p.id, skill: skill.s, damage: amount, components: parts, factor, elemental, rules: petCombatRules.version });
                            return amount;
                        },
                        heal: (t, value) => { if (t.hp <= 0)
                            return; const amount = Math.max(0, Math.min(t.maxHp - t.hp, Math.floor(value * healingMultiplier(t)))); t.hp += amount; healMap.set(t, (healMap.get(t) ?? 0) + amount); affected.add(t); log(t, { event: 'PET_HEAL', pet: p.id, skill: skill.s, health: amount }); },
                        mod: (t, field, percent, flat, duration, delayed = 0) => put(t, 'modifier:' + field, { kind: 'modifier', stat: field, target: 'allies', percent, flat }, duration, delayed),
                        control: (t, kind, duration, delayed = 0) => { if (activeStatuses(t).some(s => s.effect.kind === 'controlImmunity' && s.effect.stat === kind)) {
                            log(t, { event: 'PET_CONTROL_IMMUNE', kind });
                            return false;
                        } if (t.hp <= 0)
                            return false; put(t, 'control:' + kind, { kind: 'control', stat: kind, target: 'enemy', percent: 0, ...(kind === 'stun' ? { frame: 'buff_giddy' } : {}) }, duration, delayed); return true; },
                        dot: (t, kind, percent, flat, duration) => put(t, 'dot:' + kind, { kind: 'dot', stat: kind, target: 'enemy', percent, flat, ...(kind === 'burn' ? { frame: 'buff_fire' } : {}) }, duration),
                        special: (t, kind, value, duration) => put(t, kind, { kind: kind, target: 'allies', percent: value }, duration),
                        has: (t, kind) => activeStatuses(t).some(s => s.effect.kind === 'dot' && s.effect.stat === kind), purge: t => fate.purgeInvulnerable(t),
                        kill: t => { if (t.hp <= 0 || !fate.instantKillAllowed(source, t))
                            return; const amount = t.hp; t.hp = 0; damageMap.set(t, (damageMap.get(t) ?? 0) + amount); affected.add(t); causes.set(t, { kind: 'instantKill', source }); lethalCauses.set(t, { kind: 'instantKill', source }); log(t, { event: 'PET_INSTANT_KILL', pet: p.id, skill: skill.s, damage: amount }); }, note: v => log(source, { ...v, pet: p.id, skill: skill.s }) });
                    const dealt = [...damageMap], healed = [...healMap];
                    frames[frame].param = { src: p.camp, des: dealt.length ? dealt.map(([t]) => t.index) : [...affected].map(t => t.index), hurt: dealt.length ? dealt.map(([, d]) => d) : 0, spc: 0, name, skillid: skill.s, ...(healed.length ? { desh: healed.map(([t]) => t.index), health: healed.map(([, v]) => v) } : {}) };
                    for (const t of affected)
                        emit('cur_data', { [t.index]: { tempHp: t.hp, maxHp: t.maxHp } });
                    const priority = (t) => t.hp === 0 && compatibleSkills(t, 'KDEAD').some(s => fusionRule(t, s)) && fusionPartner(t, entities, active, donorEligible) ? 0 : 1;
                    for (const [t] of dealt.sort(([a], [b]) => priority(a) - priority(b) || a.index - b.index)) {
                        if (t.hp > 0)
                            trigger(t, 'KBEFOREHERT', round);
                        markDeath(t, causes.get(t) ?? { kind: 'damage', source });
                    }
                    continue;
                }
                const allies = side(p.camp === 0), enemies = side(p.camp !== 0), ratio = plan.coefficient(skill.lv), first = enemies[0], damaged = [];
                let targets = plan.target === 'all' ? enemies : plan.target === 'front' ? enemies.filter(e => e.index % 100 < 3) : plan.target === 'column' ? enemies.filter(e => e.index % 3 === first.index % 3) : plan.target === 'row' ? enemies.filter(e => Math.floor(e.index % 100 / 3) === Math.floor(first.index % 100 / 3)) : plan.target === 'one' ? [first] : [];
                const frame = String(frameNumber + 1);
                emit('skill_pet', { src: p.camp, des: [], hurt: 0, spc: 0, name: p.animation + '_s' + (skill.s % 100 < 20 ? 1 : skill.s % 100 < 30 ? 2 : 3), skillid: skill.s });
                if (plan.modifiers)
                    for (const [field, source, sign] of plan.modifiers) {
                        for (const target of sign > 0 ? allies : enemies) {
                            const sourceKey = 'pet:' + key + ':' + field, list = (statuses.get(target) ?? []).filter(s => s.source !== sourceKey);
                            list.push({ source: sourceKey, effect: { kind: 'modifier', target: sign > 0 ? 'allies' : 'enemy', stat: field, percent: 0, flat: sign * p[source] * ratio, permanent: true }, expires: Number.MAX_SAFE_INTEGER, count: 1 });
                            statuses.set(target, list);
                            refresh(target);
                            log(target, { event: 'PET_MODIFIER', pet: p.id, skill: skill.s, field, flat: sign * p[source] * ratio });
                        }
                    }
                for (const target of targets) {
                    trigger(target, 'KBEATTACK', round);
                    if (!side(p.camp === 0).length)
                        break;
                    if (target.hp <= 0)
                        continue;
                    const source = { card: { id: 'pet-' + p.camp + '-' + p.id }, maxHp: p.hp, empowerment: [] };
                    const raw = Math.max(1, Math.floor((p[plan.stat] * ratio - target.defense * 0.5) * (target.index % 100 < 3 ? (plan.frontMultiplier ?? 1) : 1))), damage = Math.min(target.hp, fate.damage(source, target, Math.floor(raw * (1 - Math.min(100, reduction(target)) / 100))));
                    target.hp -= damage;
                    damaged.push([target, damage]);
                    log(target, { event: 'PET_DAMAGE', pet: p.id, skill: skill.s, damage });
                    if (target.hp > 0 && plan.poison) {
                        const list = (statuses.get(target) ?? []).filter(v => v.source !== key + ':poison');
                        list.push({ source: key + ':poison', effect: { kind: 'dot', target: 'enemy', percent: 0, flat: Math.floor(Math.min(target.maxHp * plan.poison.percent / 100, p.matk * plan.poison.capPercent / 100)), duration: 3, frame: 'buff_poison' }, expires: round + 2, count: 1 });
                        statuses.set(target, list);
                    }
                    if (target.hp > 0 && (plan.slow || plan.stun)) {
                        const list = statuses.get(target) ?? [];
                        if (plan.slow)
                            list.push({ source: key, effect: { kind: 'modifier', target: 'enemy', stat: 'speed', percent: -plan.slow, duration: plan.duration }, expires: round + plan.duration - 1, count: 1 });
                        if (plan.stun && !activeStatuses(target).some(s => s.effect.kind === 'controlImmunity' && s.effect.stat === 'stun'))
                            list.push({ source: key, effect: { kind: 'control', target: 'enemy', percent: 0, duration: 1, frame: 'buff_giddy' }, expires: round, count: 1 });
                        statuses.set(target, list);
                        refresh(target);
                    }
                }
                if (side(p.camp === 0).length && plan.delayedFrontControl)
                    for (const target of enemies.filter(e => e.index % 100 < 3 && e.hp > 0)) {
                        const starts = round + plan.delayedFrontControl.startsAfter, keyControl = key + ':delayed-root', list = (statuses.get(target) ?? []).filter(v => v.source !== keyControl);
                        list.push({ source: keyControl, effect: { kind: 'control', stat: 'root', target: 'enemy', percent: 0, duration: plan.delayedFrontControl.duration }, starts, expires: starts + plan.delayedFrontControl.duration - 1, count: 1 });
                        statuses.set(target, list);
                        log(target, { event: 'PET_DELAYED_CONTROL', pet: p.id, skill: skill.s, starts, expires: starts + plan.delayedFrontControl.duration - 1 });
                    }
                frames[frame].param = { src: p.camp, des: damaged.length ? damaged.map(([e]) => e.index) : plan.modifiers ? (plan.modifiers[0][2] > 0 ? allies : enemies).map(e => e.index) : [], hurt: damaged.length ? damaged.map(([, d]) => d) : 0, spc: 0, name: p.animation + '_s' + (skill.s % 100 < 20 ? 1 : skill.s % 100 < 30 ? 2 : 3), skillid: skill.s };
                const priority = (t) => t.hp === 0 && compatibleSkills(t, 'KDEAD').some(s => fusionRule(t, s)) && fusionPartner(t, entities, active, donorEligible) ? 0 : 1;
                for (const [target] of damaged.sort(([a], [b]) => priority(a) - priority(b) || a.index - b.index)) {
                    emit('cur_data', { [target.index]: { tempHp: target.hp } });
                    if (target.hp > 0)
                        trigger(target, 'KBEFOREHERT', round);
                    markDeath(target, { kind: 'damage' });
                }
            }
    };
    // sort trong Lua vừa khởi tạo thứ tự vừa tăng m_currentRound. Không phát
    // trước tiền chiến: client gốc giữ m_currentRound=0 ở giai đoạn chuẩn bị.
    const opening = sorted();
    // Xa luân Aether: thanh HP dùng maxHp, đồng bộ HP còn lại bằng consumer
    // cur_data thật. Không dùng cur_hp (nhánh Lua gốc đã bỏ xử lý).
    if (options.carry)
        for (const e of opening) {
            const fused = fusions.get(e);
            if (fused)
                emit('skill', { src: e.index, des: e.index, hurt: 0, spc: 0, name: fused.animation, skillid: fused.skillId ?? 0 });
            emit('cur_data', { [e.index]: { maxHp: e.maxHp, tempHp: e.hp } });
        }
    // Ưu tiên tiền chiến đã chốt: Thần Thú/PET của hai phe trước kỹ năng
    // tiền chiến của tướng. Phản ứng do trúng đòn vẫn xử lý ngay trong cast.
    castBeasts('KBEFOREBATTLE', 0);
    castPets('KBEFOREBATTLE', 0);
    for (const e of opening)
        if (e.hp > 0 && side(true).length && side(false).length)
            trigger(e, 'KBEFOREBATTLE', 0);
    for (const e of entities)
        entry.set(e, structuredClone((statuses.get(e) ?? []).filter(s => s.effect.permanent)));
    for (let round = 1; round <= localCombatRules.maxRounds && side(true).length && side(false).length; round++) {
        rounds = round;
        for (const e of sorted())
            if ((statuses.get(e) ?? []).some(s => s.starts === round)) {
                refresh(e);
                log(e, { event: 'DELAYED_STATUS_ACTIVE' });
            }
        // Mở đúng hiệp trước mọi KBEFOREROUND (kể cả khi chiêu đầu hiệp kết thúc
        // trận). sort_array và frame cùng một snapshot; initiative thật vẫn lấy
        // lại sau hiệu ứng đầu hiệp như trước, không đổi công thức combat.
        const roundOrder = sorted().map(e => e.index);
        init.sort_array.push(roundOrder);
        emit('sort', roundOrder);
        // Adapter LOCAL: xử lý Thần Thú ở đầu pha trước lượt tướng, để chiêu
        // bắt đầu hiệp1 không bị kỹ năng KBEFOREROUND của tướng kết thúc trận nuốt mất.
        // Giữ nguyên tiền chiến: nếu trận đã kết thúc trước hiệp1 thì không gọi thú giả.
        castBeasts('KBEFOREROUND', round);
        castPets('KBEFOREROUND', round);
        for (const e of sorted())
            if (side(true).length && side(false).length)
                trigger(e, 'KBEFOREROUND', round);
        const order = sorted();
        for (const e of order) {
            if (e.hp <= 0 || !active.has(e))
                continue;
            if (!side(e.index >= 100).length)
                break;
            if (activeStatuses(e).some(s => s.effect.kind === 'control')) {
                log(e, { event: 'TURN', result: 'CONTROLLED' });
                continue;
            }
            let target = side(e.index >= 100)[0];
            if (!target)
                break;
            if (trigger(e, 'KBEFOREATTACK', round, true)) {
                trigger(e, 'KATTACK', round);
                continue;
            }
            if (e.hp <= 0 || !active.has(e))
                continue;
            target = side(e.index >= 100)[0];
            if (!target)
                break;
            trigger(target, 'KBEATTACK', round);
            if (e.hp <= 0 || !active.has(e))
                continue;
            target = side(e.index >= 100)[0];
            if (!target)
                break;
            const hit = petHit(e, target), raw = hit ? Math.max(1, Math.floor((e.attack - target.defense * .5) * (.95 + rng() * .1) * petCritical(e))) : 0, damage = Math.min(target.hp, fate.damage(e, target, Math.floor(raw * (1 - Math.min(100, reduction(target)) / 100))));
            emit('attack', { src: e.index, des: target.index, hurt: damage, spc: 0 });
            target.hp -= damage;
            if (damage > 0)
                burnCover(e, target);
            emit('cur_data', { [target.index]: { tempHp: target.hp } });
            emit('attack_over', { src: e.index });
            artifactHeal(e, damage);
            fate.afterActiveAttack(e, t => annihilate(e, t));
            if (target.hp > 0)
                trigger(target, 'KBEFOREHERT', round);
            markDeath(target, { kind: 'damage', source: e });
            trigger(e, 'KATTACK', round);
        }
        fate.endRound(markDeath);
        for (const e of sorted()) {
            const list = statuses.get(e) ?? [];
            for (const s of list)
                if (s.effect.kind === 'dot' && (s.starts ?? 0) <= round) {
                    const damage = Math.min(e.hp, Math.floor(e.maxHp * s.effect.percent / 100 + Number(s.effect.flat ?? 0)));
                    e.hp -= damage;
                    if (s.effect.stat !== 'bleed')
                        emit('buff_skill', { src: e.index, des: e.index, name: 'buff_fire_skill', hurt: damage });
                    emit('cur_data', { [e.index]: { tempHp: e.hp } });
                    log(e, { event: 'DOT', damage, source: s.source, status: s.effect.stat ?? 'dot' });
                    markDeath(e);
                }
            const expired = list.filter(s => s.expires <= round), remaining = list.filter(s => s.expires > round);
            statuses.set(e, remaining);
            for (const s of expired)
                if (s.effect.frame && !remaining.some(v => v.effect.frame === s.effect.frame))
                    emit('remove_buff', { src: e.index, name: s.effect.frame });
            refresh(e);
        }
    }
    const winner = side(true).length && !side(false).length ? 0 : 100;
    emit('winer', winner);
    const carry = options.carry ? entities.filter(e => e.hp > 0 && (active.has(e) || e.index % 100 >= 5)).map((e) => {
        const base = baseStats.get(e), bonus = fusionBonus.get(e) ?? {}, fusion = fusions.get(e), maxHp = Math.max(1, base.hp + Number(bonus.hp ?? 0));
        // Buff có hạn không mang sang trận kế. Actor hợp thể và tướng dự bị đã
        // thay vào được giữ; actor bị hấp thụ/chết không thể xuất hiện trở lại.
        return { ...structuredClone(e), hp: Math.min(e.hp, maxHp), maxHp, card: { ...e.card, hp: base.hp, phsc: base.patk, mgc: base.matk }, attack: Math.max(base.patk + Number(bonus.patk ?? 0), base.matk + Number(bonus.matk ?? 0)), defense: base.def + Number(bonus.def ?? 0), speed: base.speed + Number(bonus.speed ?? 0), ...(fusion ? { continuation: { fusion, bonus } } : {}) };
    }) : undefined;
    return { battle: { init, battle: frames, winer: winner }, winner, rounds, seed, rules: localCombatRules.version, diagnostics, ...(pets.length ? { petDiagnostics: pets.map(p => ({ id: p.id, c_id: p.c_id, camp: p.camp, skills: p.selectedSkills.map((s) => s.s), rules: petCombatRules.version, notice: petCombatRules.notice })) } : {}), beastDiagnostics: beasts.flatMap(b => b.selectedSkills.map((sid) => ({ beast: b.beast_num, camp: b.camp, ...beastSkillPlan(sid) }))), lifeEvents, empowerment: entities.flatMap(e => combatEmpowermentDiagnostics(e).map(line => ({ hero: e.card.id, ...line }))), ...(tracing ? { trace } : {}), ...(carry ? { carry } : {}), remaining: entities.map(e => ({ index: e.index, hp: e.hp, lifecycle: fate.inspect(e), stats: { hp: e.maxHp, patk: stat(e, 'patk'), matk: stat(e, 'matk'), def: e.defense, speed: e.speed, ...(petExtensions ? Object.fromEntries(['fire', 'water', 'wind', 'earth', 'fire_dfs', 'water_dfs', 'wind_dfs', 'earth_dfs', 'crit', 'dodge', 'healAmp', 'damageReduction'].map(f => [f, stat(e, f)])) : {}), ...(petExtensions ? { effectiveReduction: reduction(e) } : {}) } })) };
}
