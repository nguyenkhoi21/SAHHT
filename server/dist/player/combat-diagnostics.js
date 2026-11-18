import { readConfigSync as cfg } from './local-content.js';
import { sourceSkillChain, skillSourceSlots } from './battle-skill-registry.js';
import { compileSkill } from './skill-effects.js';
import { transformationSkillScript } from './transformation-skill.js';
import { battleAppearance } from './appearance-state.js';
import { CombatPowerService } from './combat-power.js';
import { combatSkillDiagnostics, combatEmpowermentDiagnostics, serializeEntity } from './local-combat.js';
import { heroResources } from './hero-index.js';
let auditCache;
export async function combatRegistryAudit() {
    if (auditCache)
        return auditCache;
    const heroes = cfg('character_detail'), skills = cfg('skill_detail'), supers = cfg('super_evolution'), resources = await heroResources(), skinIds = new Set(Object.values(heroes).map(c => Number(c.is_skin)).filter(Boolean));
    const rows = Object.entries(heroes).filter(([id, c]) => Number(c.skill_num) > 0 && !skinIds.has(Number(id)) && resources.get(Number(id))?.assetStatus === 'FULL ASSETS').map(([id, c]) => {
        const entries = [];
        for (const slot of [...skillSourceSlots(c), 4, 5]) {
            const source = c['skill_' + slot + '_source'], chain = sourceSkillChain(c, slot, skills), origin = slot >= 6 ? 'PURCHASED' : slot >= 4 ? 'SUPER_EVOLUTION' : 'NATIVE';
            if (!chain.length) {
                if (source?.length)
                    entries.push({ sourceSlot: slot, origin, status: source.length > 1 ? 'INVALID_SLOT_MAPPING' : 'MISSING_CONFIG', skillId: source?.[0]?.[0], blockers: ['Chưa chọn variant nguồn hoặc thiếu skill_detail.'] });
                continue;
            }
            for (const sid of chain) {
                const s = skills[sid], script = s.sprite_py ? transformationSkillScript(Number(id), c.animation, sid, s.sprite_py) : null, plan = compileSkill(s, 1, false);
                entries.push({ sourceSlot: slot, origin, selectionSlot: skillSourceSlots(c).indexOf(slot) + 1 || null, runtimeSlot: slot >= 4 && slot <= 5 ? slot : null, requiredSuperStage: origin === 'SUPER_EVOLUTION' ? supers[c.super_evo]?.['skill' + slot + '_open'] ?? null : null, skillId: sid, name: s.skill_name, trigger: s.skill_type, rate: s.rate, cooldown: s.cd, preCooldown: s.pre_cd, script: script?.name ?? null, status: !script ? 'MISSING_CLIENT_RESOURCE' : !plan.effects.length ? 'MISSING_BATTLE_HANDLER' : plan.status, effects: plan.effects, blockers: plan.blockers });
            }
        }
        return { configId: Number(id), name: c.name, model: c.animation, entries };
    });
    const summary = { heroes: rows.length, skillReferences: 0, statuses: {} };
    for (const h of rows)
        for (const s of h.entries) {
            summary.skillReferences++;
            summary.statuses[s.status] = (summary.statuses[s.status] ?? 0) + 1;
        }
    return auditCache = { scope: 'Hero có config chơi được và tài nguyên FULL ASSETS trong registry hiện tại; loại Skin/NPC không có kỹ năng. Không phải xác nhận mọi hero đã thử Android.', source: 'character_detail/skill_detail/super_evolution + chỉ mục model VN hiện có', summary, heroes: rows };
}
export async function heroCombatDiagnostics(db, userId, heroId) {
    const r = db.prepare('SELECT state FROM player_heroes WHERE user_id=? AND id=?').get(userId, heroId);
    if (!r)
        throw Object.assign(Error('Tướng không thuộc tài khoản.'), { statusCode: 404 });
    const h = JSON.parse(String(r.state)), canonical = new CombatPowerService(db).calculate(userId, true).heroes.find(x => x.id === heroId);
    const appearance = battleAppearance(db, userId, h, cfg('character_detail'), cfg('skill_detail')), e = serializeEntity(0, heroId, appearance.configId, { ...h, ...canonical.attributes, combat_empowerment: canonical.breakdown.empowerLines }, appearance.cfg, appearance.skills);
    // Chỉ lấy bằng chứng từ packet đã lưu, không tạo trận để chẩn đoán.
    const history = [];
    for (const row of db.prepare("SELECT id,packet,result AS metadata,created_at FROM local_battles WHERE user_id=? UNION ALL SELECT id,packet,metadata,created_at FROM arena_operations WHERE kind='battle' AND (user_id=? OR target_user_id=?) UNION ALL SELECT request_key AS id,result AS packet,json_extract(result,'$.diagnostics') AS metadata,created_at FROM player_content_operations WHERE user_id=? AND method='friend.battle' ORDER BY created_at DESC LIMIT 30").all(userId, userId, userId, userId)) {
        const p = JSON.parse(String(row.packet)), init = p.battle?.init;
        if (!init)
            continue;
        const actor = [...(init.atk ?? []).map((v, i) => ({ v, index: i })), ...(init.dfd ?? []).map((v, i) => ({ v, index: 100 + i }))].find(x => x.v?.id === 'local_' + heroId);
        if (!actor)
            continue;
        const identities = new Map();
        for (const [offset, team] of [[0, init.atk], [100, init.dfd]])
            (team ?? []).forEach((v, i) => { if (v?.id)
                identities.set(offset + i, v.id); });
        const used = [];
        for (const f of Object.values(p.battle.battle ?? {})) {
            if (f.flag === 'sbt') {
                const a = identities.get(f.param.a), b = identities.get(f.param.b);
                if (b)
                    identities.set(f.param.a, b);
                if (a)
                    identities.set(f.param.b, a);
            }
            else if (f.flag === 'skill' && identities.get(f.param?.src) === 'local_' + heroId)
                used.push({ skillId: f.param.skillid, animation: f.param.name, damage: f.param.hurt, healing: f.param.health ?? 0 });
        }
        history.push({ battleId: row.id, time: row.created_at, lifeEvents: (JSON.parse(String(row.metadata ?? '{}')).lifeEvents ?? []).filter((e) => e.hero === 'local_' + heroId), activations: used.slice(0, 40), note: 'Bằng chứng frame/settlement; không tự xác nhận hoạt ảnh Android.' });
        if (history.length >= 3)
            break;
    }
    return { heroId, configId: h.c_id, name: cfg('character_detail')[h.c_id]?.name, progression: { evolution: h.evo, rebirth: h.bre, superEvolution: h.super_step ?? 0 }, registration: appearance.registration, skills: combatSkillDiagnostics(e), empowerment: combatEmpowermentDiagnostics(e), attributes: canonical.attributes, breakdown: canonical.breakdown, power: canonical.power, history, trace: { enabled: process.env.LOCAL_BATTLE_TRACE === '1', setting: 'LOCAL_BATTLE_TRACE=1 khi khởi động server; mặc định tắt, tối đa1000 dòng/trận, không ghi credential.' } };
}
