import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { petProof } from './pet-source.js';
const rulesProof = petProof().combatRules, rawRules = readFileSync(new URL('../../../' + rulesProof.path, import.meta.url));
if (createHash('sha256').update(rawRules).digest('hex') !== rulesProof.sha256)
    throw Error('Quy tắc PET LOCAL không khớp bản đã chốt.');
export const petCombatRules = JSON.parse(rawRules.toString());
const families = new Set(['PetSkill_7_s1', 'PetSkill_7_s2', 'PetSkill_8_s1', 'PetSkill_8_s2', 'PetSkill_9_s1', 'PetSkill_9_s2', 'PetSkill_17_s1', 'PetSkill_17_s2', 'PetSkill_18_s1', 'PetSkill_18_s2', 'PetSkill_19_s1', 'PetSkill_19_s2', 'PetSkill_20_s1', 'PetSkill_20_s2', 'PetSkill_21_s1', 'PetSkill_21_s2', 'PetSkill_22_s1', 'PetSkill_22_s2', 'PetSkill_23_s1', 'PetSkill_23_s2', 'PetSkill_24_s1', 'PetSkill_24_s2', 'qingyanbailong_s1', 'qingyanbailong_s2']);
export const advancedPetFamily = (name) => families.has(name);
// Thuật toán bốc số LOCAL đã được chốt; mỗi lần dùng chọn không trùng đích.
const elements = ['fire', 'water', 'wind', 'earth'];
export function runAdvancedPet(h) {
    const p = h.pet, r = h.ratio, own = h.allies, foes = h.enemies, turns = petCombatRules.status.unspecifiedActiveTurns;
    const roll = (a, b) => a === b ? a : a + Math.floor(h.rng() * (b - a + 1));
    const choose = (units, n) => { const a = [...units]; for (let i = a.length - 1; i > 0; i--) {
        const j = roll(0, i);
        [a[i], a[j]] = [a[j], a[i]];
    } return a.slice(0, Math.min(n, a.length)); };
    const front = (units) => units.filter(t => t.index % 100 < 3);
    const poison = (units, duration) => { for (const t of units)
        h.dot(t, 'burn', petCombatRules.status.burnMaxHpPercent, 0, duration); };
    const hpBuff = (t, ratio, duration) => h.mod(t, 'hp', 0, (h.stat(t, 'hp') + p.hp) * ratio, duration);
    const elementalBuff = (field, value) => { for (const t of own())
        h.mod(t, field, value, 0); };
    const attackDown = (units, value, duration) => { for (const t of units)
        for (const f of ['patk', 'matk'])
            h.mod(t, f, -value, 0, duration); };
    const weak = (t) => attackDown([t], petCombatRules.status.weakAttackPercent, 1);
    const controlSome = (units, kind, n, delay = 0, duration = 1) => { for (const t of choose(units, n))
        h.control(t, kind, duration, delay); };
    const controlAtLeastOne = (units, kind) => { let applied = false; for (const t of units)
        if (h.rng() < .3)
            applied = h.control(t, kind, 1) || applied; if (!applied)
        for (const t of choose(units, units.length))
            if (h.control(t, kind, 1))
                break; };
    switch (h.family) {
        case 'PetSkill_7_s1':
            for (const t of own()) {
                h.heal(t, p.hp * r);
                h.mod(t, 'def', 0, p.def * r, petCombatRules.rabbit.defenseTurns);
            }
            {
                const t = own().sort((a, b) => a.hp / a.maxHp - b.hp / b.maxHp || a.index - b.index)[0];
                if (t)
                    h.special(t, 'elementGuard', 1, petCombatRules.rabbit.guardTurns);
            }
            break;
        case 'PetSkill_7_s2':
            for (const t of own())
                h.mod(t, 'patk', 0, p.patk * r);
            elementalBuff('earth', 50);
            break;
        case 'PetSkill_8_s1': {
            const units = foes();
            for (const t of units)
                h.damage(t, { magic: p.matk * r });
            const first = units.find(t => t.hp > 0);
            if (first) {
                h.special(first, 'blind', petCombatRules.status.blindHitPointReduction, 1);
                weak(first);
            }
            break;
        }
        case 'PetSkill_8_s2':
            for (const t of foes())
                h.mod(t, 'speed', 0, -p.speed * r);
            elementalBuff('wind', 50);
            break;
        case 'PetSkill_9_s1': {
            const units = foes();
            for (const t of units)
                h.damage(t, { magic: p.matk * r });
            for (const t of front(units).filter(t => t.hp > 0)) {
                h.control(t, 'stun', 1);
                poison([t], 1);
            }
            break;
        }
        case 'PetSkill_9_s2':
            for (const t of foes()) {
                h.mod(t, 'matk', 0, -p.matk * r);
                h.mod(t, 'def', 0, -p.def * r);
            }
            elementalBuff('earth', 50);
            break;
        case 'PetSkill_17_s1': {
            const units = foes();
            for (const t of units)
                h.damage(t, { magic: p.matk * r }, t.index % 100 < 3 ? 1.5 : 1);
            for (const t of front(units).filter(t => t.hp > 0))
                h.control(t, 'root', 1, 1);
            break;
        }
        case 'PetSkill_17_s2':
            attackDown(foes(), r * 100);
            elementalBuff('fire', 100);
            break;
        case 'PetSkill_18_s1': {
            const units = front(foes());
            for (const t of units)
                h.damage(t, { physical: p.patk * r, true: t.card.boss ? 0 : t.hp * .1 });
            controlSome(foes(), 'fear', roll(1, 2));
            break;
        }
        case 'PetSkill_18_s2':
            for (const t of own())
                h.mod(t, 'speed', r * 100, 0, 2);
            for (const t of foes())
                h.mod(t, 'speed', -r * 100, 0);
            controlSome(foes(), 'root', roll(1, 2), 1);
            break;
        case 'PetSkill_19_s1': {
            const units = foes();
            for (const t of units)
                h.damage(t, { magic: p.matk * r, fire: p.patk * r });
            poison(choose(units.filter(t => t.hp > 0), 3), 2);
            break;
        }
        case 'PetSkill_19_s2':
            for (const t of own()) {
                h.special(t, 'burnCover', petCombatRules.status.burnMaxHpPercent);
                h.mod(t, 'healAmp', 0, petCombatRules.kirara.healBonusPercent);
                h.mod(t, 'hp', r * 100, 0);
            }
            break;
        case 'PetSkill_20_s1': {
            const units = foes(), duration = roll(1, 3);
            for (const t of units) {
                h.damage(t, { magic: p.matk * r, fire: p.matk * r });
                h.mod(t, 'fire', -50, 0, duration);
                h.mod(t, 'water', -50, 0, duration);
            }
            if (h.rng() < .8) {
                const rows = [...new Set(foes().map(t => Math.floor(t.index % 100 / 3)))];
                if (rows.length) {
                    const row = rows[roll(0, rows.length - 1)], targets = foes().filter(t => Math.floor(t.index % 100 / 3) === row);
                    for (const t of targets)
                        h.damage(t, { physical: p.patk * r, wind: p.patk * r });
                    controlSome(targets.filter(t => t.hp > 0), 'petrify', 2);
                }
            }
            break;
        }
        case 'PetSkill_20_s2':
            for (const t of own()) {
                hpBuff(t, r);
                h.mod(t, 'damageReduction', 0, r * 100);
            }
            break;
        case 'PetSkill_21_s1': {
            const target = foes().sort((a, b) => a.hp - b.hp || a.index - b.index)[0];
            if (!target)
                break;
            const field = roll(0, 1) ? 'matk' : 'patk', bonus = h.stat(target, field) * .4 + (p.patk + p.matk) * 1.5;
            const dealt = h.damage(target, { physical: p.patk * r, magic: p.matk * r });
            if (target.hp > 0)
                h.dot(target, 'bleed', 0, dealt * petCombatRules.kyukimon.bleedDamageMultiplier, petCombatRules.kyukimon.bleedTurns);
            for (const t of own())
                h.mod(t, field, 0, bonus, petCombatRules.kyukimon.attackBoostTurns);
            break;
        }
        case 'PetSkill_21_s2': {
            const units = choose(foes(), roll(2, 5)), factor = roll(2, 4);
            for (const t of units) {
                h.damage(t, { physical: p.patk * r, wind: p.matk * r }, h.has(t, 'burn') || h.has(t, 'bleed') ? factor : 1);
                const f = [...elements].sort((a, b) => h.stat(t, b) - h.stat(t, a))[0];
                h.mod(t, f, -50, 0, 1);
            }
            controlSome(units.filter(t => t.hp > 0), 'freeze', 2);
            break;
        }
        case 'PetSkill_22_s1': {
            const units = choose(foes(), 3), attack = roll(10, 80), reduction = roll(20, 40);
            for (const t of units) {
                for (const f of elements)
                    h.mod(t, f, -attack, 0, 1);
                h.mod(t, 'damageReduction', 0, -reduction, 1);
            }
            for (const t of own())
                for (const f of ['fire_dfs', 'water_dfs'])
                    h.mod(t, f, r * 100, 0, 2);
            break;
        }
        case 'PetSkill_22_s2': {
            const units = foes(), fire = roll(0, 1) === 0;
            h.note({ event: 'PET_BRANCH', branch: fire ? 'fire' : 'water' });
            for (const t of units)
                h.damage(t, fire ? { magic: p.matk * r, true: p.def * r, fire: p.patk * r } : { true: (p.patk + p.speed) * r, water: p.matk * r });
            controlAtLeastOne(units.filter(t => t.hp > 0), fire ? 'petrify' : 'freeze');
            break;
        }
        case 'PetSkill_23_s1': {
            const units = foes();
            for (const t of units)
                h.damage(t, { magic: (p.patk + p.matk) * r, wind: (p.speed + p.def) * r }, t.index % 100 < 3 ? 2 : 1);
            if (h.rng() < .8)
                for (const t of choose(foes(), roll(1, 3)))
                    h.purge(t);
            const attrs = choose(['elementAttack', 'elementDefense', 'crit', 'dodge'], 1);
            for (const t of choose(foes(), roll(1, 2))) {
                if (attrs[0] === 'elementAttack' || attrs[0] === 'elementDefense')
                    for (const f of elements)
                        h.mod(t, f + (attrs[0] === 'elementDefense' ? '_dfs' : ''), -30, 0, 1);
                else
                    h.mod(t, attrs[0], 0, -30, 1);
            }
            break;
        }
        case 'PetSkill_23_s2':
            for (const t of own()) {
                hpBuff(t, r);
                for (const f of ['patk', 'matk'])
                    h.mod(t, f, 0, (h.stat(t, f) + p[f]) * r);
            }
            {
                const amount = roll(20, 40);
                for (const t of choose(foes(), roll(1, 3))) {
                    attackDown([t], amount, 2);
                    h.mod(t, 'damageReduction', 0, -20, 2);
                }
            }
            break;
        case 'PetSkill_24_s1': {
            const units = foes(), amount = roll(10, 30);
            for (const t of units) {
                const vulnerable = h.has(t, 'burn') || h.has(t, 'bleed');
                h.damage(t, { physical: (p.patk + p.speed) * r, wind: (p.matk + p.def) * r });
                if (vulnerable)
                    attackDown([t], amount, 2);
            }
            for (const t of choose(foes(), roll(1, 5)))
                h.special(t, 'blind', petCombatRules.status.blindHitPointReduction, 2);
            controlSome(foes(), 'petrify', roll(1, 5), 0, 2);
            break;
        }
        case 'PetSkill_24_s2':
            for (const t of own()) {
                h.special(t, 'healingBoost', petCombatRules.haoHealing.normalBonus, 3);
                h.heal(t, p.hp * r);
                h.mod(t, 'def', 0, (p.patk + p.matk) * r, 3);
            }
            break;
        case 'qingyanbailong_s1': {
            const units = foes();
            for (const t of units) {
                h.control(t, 'root', 1);
                h.purge(t);
            }
            const victim = choose(foes(), 1)[0];
            if (victim)
                h.kill(victim);
            for (const t of units)
                if (t.hp > 0)
                    h.damage(t, { true: (p.patk + p.matk) * r });
            break;
        }
        case 'qingyanbailong_s2':
            for (const t of own()) {
                for (const f of ['patk', 'matk'])
                    h.mod(t, f, 600, 0);
                hpBuff(t, .3);
            }
            for (const t of foes()) {
                h.mod(t, 'damageReduction', 0, -50);
                h.damage(t, { true: p.patk * r });
            }
            break;
        default: throw Error('Kỹ năng PET chưa có runner: ' + h.family);
    }
}
