import { battleSkillConfig, sourceSkillChain } from './battle-skill-registry.js';
import { compileSkill } from './skill-effects.js';
const normalize = (s) => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/đ/g, 'd').replace(/\s+/g, ' ');
// Mốc CS lấy theo source slot, KHÔNG theo ô runtime đã bị thay bởi skill mua.
export function revivalRule(e, s, factionCount) {
    const plan = compileSkill(s.cfg, s.lv, e.skinActive === true), revive = plan.effects.find(v => v.kind === 'revive');
    if (!revive)
        return null;
    const cid = e.originConfigId ?? e.card.card_id, c = battleSkillConfig('character_detail')[cid], defs = battleSkillConfig('skill_detail'), bre = Number(e.record.bre ?? 0);
    const sourceSlot = s.sourceSlot ?? [1, 2, 3, 4, 5, 6, 7].find(n => sourceSkillChain(c ?? {}, n, defs).includes(s.id)), stage = { 1: 1, 2: 2, 3: 3, 6: 4, 7: 5, 4: 6, 5: 7 }[sourceSlot];
    const upgrade = stage && bre >= stage ? String(battleSkillConfig('character_break_new')[cid]?.['story_detail' + stage] ?? '') : '', text = normalize(upgrade).split(/\bneu\b/)[0];
    const override = text.match(/so (?:lan|luot) hoi sinh(?: toi da)? (?:bien thanh|tang (?:len(?: den)?|thanh|den)) (\d+)|toi da (?:co the )?(?:duoc )?hoi sinh (\d+) lan|hoi sinh toi da (\d+) lan/), increment = text.match(/so lan hoi sinh tang (\d+)|tang (\d+) lan hoi sinh/), refund = text.match(/(?:ti le|xac suat) (\d+)% (?:khong ton|khong bi tru) so (?:lan|luot) hoi sinh/);
    const limit = Number(override?.[1] ?? override?.[2] ?? override?.[3] ?? (Number(revive.limit) + Number(increment?.[1] ?? increment?.[2] ?? 0)));
    // Nhánh Skin có xác suất cố định rõ: không suy phe Ngọc Rồng từ race (race là vũ trụ).
    const skin = normalize(String(s.cfg.skill_story ?? '')).match(/hieu ung skin:.*?co ti le (\d+)% duoc hoi sinh khong ton so (?:luot|lan), sau khi chuyen sinh tang len (\d+)%/);
    const perMember = normalize(String(s.cfg.skill_story ?? '')).match(/moi 1 nguoi tang (\d+)%/), upgradedMember = text.match(/moi nhan vat cung cap tang thanh (\d+)%/), memberRate = Number(upgradedMember?.[1] ?? perMember?.[1] ?? 0);
    const skinRefund = e.skinActive && skin ? Number(skin[bre > 0 ? 2 : 1]) : 0, refundChance = Math.max(Number(refund?.[1] ?? 0), skinRefund, e.skinActive ? 0 : memberRate * Number(factionCount ?? 0));
    if (!Number.isSafeInteger(limit) || limit < 1 || limit > 100 || refundChance < 0 || refundChance > 100)
        return null;
    return { skillId: s.id, sourceSlot, requiredRebirth: upgrade ? stage : null, limit, hpPercent: revive.percent, refundChance, ...(memberRate ? { factionRefund: { perMember: memberRate, count: factionCount ?? null, skinOverride: e.skinActive === true } } : {}), source: 'skill_detail' + (upgrade ? ' + character_break_new.story_detail' + stage : '') + (skinRefund ? ' + hiệu ứng Skin xác suất cố định' : ''), upgrade };
}
export function empoweredFamilies(e) {
    const families = new Map();
    for (const row of e.empowerment ?? [])
        for (const l of row.lines ?? [])
            if (l.active) {
                const old = families.get(l.family);
                if (!old || Number(l.skill_quality) > Number(old.skill_quality) || Number(l.sid) > Number(old.sid))
                    families.set(l.family, { ...l, equipmentId: row.equipmentId });
            }
    return families;
}
export class EmpowermentCombat {
    units;
    rng;
    round;
    alive;
    emit;
    trace;
    families = new Map();
    state = new Map();
    cooldown = new Map();
    constructor(units, rng, round, alive, emit, trace) {
        this.units = units;
        this.rng = rng;
        this.round = round;
        this.alive = alive;
        this.emit = emit;
        this.trace = trace;
        for (const e of units) {
            this.families.set(e, empoweredFamilies(e));
            this.state.set(e, { guard: 0, guardUntil: 0, banUntil: 0, invulnerableUntil: 0, rewinds: 0, burnPercent: 0 });
        }
    }
    get(e) { return this.state.get(e); }
    family(e, n) { return this.families.get(e)?.get(n); }
    values(l) { return (l.effect ?? []).map((x) => Number(x[1])); }
    roll(percent) { return percent > 0 && (percent >= 100 || this.rng() * 100 < percent); }
    ready(e, family) { const rule = this.family(e, family); if (!rule)
        return null; const times = this.cooldown.get(e) ?? new Map(); this.cooldown.set(e, times); if (this.round() < (times.get(family) ?? 0))
        return null; times.set(family, this.round() + Number(rule.cd ?? 0)); return rule; }
    buff(e, name) { this.emit('add_buff', { src: e.index, des: e.index, name, hurt: 0 }); }
    guarded(e) { const s = this.get(e); return s.guard > 0 || s.guardUntil >= Math.max(1, this.round()); }
    spendGuard(e) { const s = this.get(e); if (s.guard > 0)
        s.guard--; if (!this.guarded(e))
        this.emit('remove_buff', { src: e.index, name: 'buff_shenyu' }); }
    setInvulnerable(e, turns) { this.get(e).invulnerableUntil = Math.max(1, this.round()) + turns - 1; this.buff(e, 'buff_undead'); }
    purgeInvulnerable(e) { const state = this.get(e); if (state.invulnerableUntil >= Math.max(1, this.round())) {
        state.invulnerableUntil = 0;
        this.emit('remove_buff', { src: e.index, name: 'buff_undead' });
        this.trace(e, { event: 'PET_PURGE_INVULNERABLE' });
    } }
    grantGuard(e, count, turns) { const s = this.get(e); if (turns)
        s.guardUntil = Math.max(s.guardUntil, Math.max(1, this.round()) + turns - 1);
    else
        s.guard += count; this.buff(e, 'buff_shenyu'); }
    applyBan(e, turns) { this.get(e).banUntil = Math.max(this.get(e).banUntil, Math.max(1, this.round()) + turns - 1); this.buff(e, 'buff_shenjin'); }
    hasBan(e) { return this.get(e).banUntil >= Math.max(1, this.round()); }
    instantKillAllowed(attacker, target) {
        const aether = this.family(target, 1), state = this.get(target);
        if (aether && this.roll(this.values(aether)[0])) {
            if (state.guard > 0)
                this.spendGuard(target);
            this.buff(target, 'buff_tired');
            this.trace(target, { event: 'INSTANT_KILL_BLOCKED', family: 1, source: attacker.card.id });
            return false;
        }
        if (this.guarded(target)) {
            if (state.guardUntil < Math.max(1, this.round()))
                this.spendGuard(target);
            this.trace(target, { event: 'INSTANT_KILL_BLOCKED', family: 4, guard: state.guard });
            return false;
        }
        return true;
    }
    damage(attacker, target, raw) {
        let extra = 0;
        const state = this.get(target), invulnerable = state.invulnerableUntil >= Math.max(1, this.round());
        // Gói VN chỉ có Lua buff_qusanwudi, thiếu atlas/texture: dùng phản hồi gỡ
        // Vô Địch có sẵn, không gửi animation thiếu khiến client treo.
        if (invulnerable) {
            const titan = this.family(attacker, 2);
            if (!titan)
                return 0;
            state.invulnerableUntil = 0;
            this.emit('remove_buff', { src: target.index, name: 'buff_undead' });
            extra = Math.floor(attacker.maxHp * this.values(titan)[0] / 100);
            this.trace(attacker, { event: 'TITAN_PURGE', extra, target: target.index, visual: 'Thiếu atlas/texture buff_qusanwudi; đã gỡ Vô Địch.' });
        }
        const light = this.family(attacker, 7), multiplier = light && this.guarded(target) ? 1 + this.values(light)[0] / 100 : 1;
        return Math.max(0, Math.floor((raw + extra) * multiplier));
    }
    afterActiveAttack(e, annihilate) {
        if (e.hp <= 0)
            return;
        const spirit = this.ready(e, 5), targets = this.alive().filter(t => (t.index < 100) !== (e.index < 100));
        if (spirit) {
            const [chance, count, turns] = this.values(spirit);
            if (this.roll(chance))
                for (const t of targets.slice(0, count))
                    this.applyBan(t, turns);
        }
        const origin = this.ready(e, 9);
        if (origin) {
            const [chance, threshold] = this.values(origin);
            for (const t of targets)
                if (t.hp / t.maxHp * 100 < threshold && this.hasBan(t) && this.roll(chance)) {
                    this.trace(e, { event: 'ANNIHILATION', family: 9, target: t.index });
                    annihilate(t);
                }
        }
    }
    nativeRevived(target) {
        const enemies = this.alive().filter(e => (e.index < 100) !== (target.index < 100)), burn = Math.max(0, ...enemies.map(e => this.family(e, 3) ? this.values(this.family(e, 3))[0] : 0));
        if (burn) {
            this.get(target).burnPercent = burn;
            this.get(target).burnFrom = enemies.find(e => this.family(e, 3) && this.values(this.family(e, 3))[0] === burn);
            this.buff(target, 'buff_fire');
        }
    }
    // KDEAD thất bại/hết lượt → KREALDEAD → KAFTERDEAD → thay dự bị.
    realDeath(target) {
        for (const e of this.alive().filter(e => e !== target && (e.index < 100) === (target.index < 100))) {
            const lord = this.family(e, 4);
            if (lord) {
                const [chance, layers] = this.values(lord);
                if (this.roll(chance)) {
                    this.grantGuard(e, layers);
                    this.trace(e, { event: 'GUARD_GRANTED', family: 4, skillId: lord.sid, equipmentId: lord.equipmentId, trigger: 'KTEAMMATEDEAD', fallen: target.card.id, chance, layers, guard: this.get(e).guard });
                }
            }
        }
        const throne = this.family(target, 8);
        if (throne) {
            const [chance, turns] = this.values(throne);
            if (this.roll(chance))
                for (const ally of this.alive().filter(e => (e.index < 100) === (target.index < 100))) {
                    this.grantGuard(ally, 0, turns);
                    this.trace(ally, { event: 'GUARD_GRANTED', family: 8, skillId: throne.sid, equipmentId: throne.equipmentId, trigger: 'KREALDEAD', fallen: target.card.id, chance, turns, guardUntil: this.get(ally).guardUntil });
                }
        }
    }
    rewindAllowed(e, cause) {
        if (cause.kind === 'annihilation')
            return false;
        const line = this.family(e, 10);
        if (!line)
            return false;
        const [chance, limit] = this.values(line), state = this.get(e);
        if (state.rewinds >= limit || !this.roll(chance))
            return false;
        for (const [present, name] of [[state.guard || state.guardUntil, 'buff_shenyu'], [state.banUntil, 'buff_shenjin'], [state.invulnerableUntil, 'buff_undead'], [state.burnPercent, 'buff_fire']])
            if (present)
                this.emit('remove_buff', { src: e.index, name });
        state.rewinds++;
        state.guard = 0;
        state.guardUntil = 0;
        state.banUntil = 0;
        state.invulnerableUntil = 0;
        state.burnPercent = 0;
        state.burnFrom = undefined;
        this.cooldown.delete(e);
        this.trace(e, { event: 'TIME_REWIND', family: 10, count: state.rewinds, limit, evidence: 'Tỉ lệ/cap từ config; khôi phục vòng đời theo xác nhận bản gốc của người dùng27/10/2026.' });
        return true;
    }
    endRound(fatal) {
        for (const e of this.alive()) {
            const s = this.get(e);
            if (s.burnPercent > 0) {
                const damage = Math.min(e.hp, Math.floor(e.maxHp * s.burnPercent / 100));
                e.hp -= damage;
                this.emit('buff_skill', { src: e.index, des: e.index, name: 'buff_fire_skill', hurt: damage });
                this.emit('cur_data', { [e.index]: { tempHp: e.hp } });
                this.trace(e, { event: 'FATAL_BURN', family: 3, damage });
                if (e.hp === 0)
                    fatal(e, { kind: 'fatalBurn', source: s.burnFrom });
            }
            if (s.banUntil === this.round()) {
                s.banUntil = 0;
                this.emit('remove_buff', { src: e.index, name: 'buff_shenjin' });
            }
            if (s.guardUntil === this.round()) {
                s.guardUntil = 0;
                if (!s.guard)
                    this.emit('remove_buff', { src: e.index, name: 'buff_shenyu' });
            }
            if (s.invulnerableUntil === this.round()) {
                s.invulnerableUntil = 0;
                this.emit('remove_buff', { src: e.index, name: 'buff_undead' });
            }
        }
    }
    inspect(e) { return { ...this.get(e), burnFrom: this.get(e).burnFrom?.card.id, families: [...(this.families.get(e)?.keys() ?? [])] }; }
}
