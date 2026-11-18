import { battleSkillConfig, sourceSkillChain } from './battle-skill-registry.js';
import { transformationSkillScript } from './transformation-skill.js';
import { compileSkill, activeSkillClause } from './skill-effects.js';
import { dragonBallContext } from './combat-faction.js';
// Chủ dự án xác nhận công thức gốc: Vegeta +20% chỉ số Kakarot lúc hợp thể.
// HP là chỉ số HP tối đa; không phải lượng máu còn lại của người cho.
export const fusionStatPolicy = 'OWNER_PLUS_PARTNER_CURRENT_PERCENT';
const norm = (s) => String(s ?? '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/đ/g, 'd');
export const fusionFields = ['hp', 'patk', 'matk', 'def', 'speed'];
export function fusionRule(e, s) {
    const defs = battleSkillConfig('character_detail'), skills = battleSkillConfig('skill_detail'), c = defs[e.originConfigId ?? e.card.card_id], story = norm(s.cfg?.skill_story);
    if (!c || s.cfg?.skill_type !== 'KDEAD' || !sourceSkillChain(c, 4, skills).includes(s.id))
        return null;
    if (Number(e.record.super_step ?? 0) < Number(battleSkillConfig('super_evolution')[c.super_evo]?.skill4_open ?? Infinity))
        return null;
    const m = story.match(/hop the voi kakalot bien thanh cuc y gogeta, hap thu them thuoc tinh co so cua kakalot va tang them (\d+)%\. co lai (\d+) lan su dung hoi sinh/);
    if (!m)
        return null;
    const script = transformationSkillScript(e.card.card_id, e.card.animation, s.id, e.card.animation + '_s8');
    if (!script)
        return null;
    return { kind: 'gogeta', skillId: s.id, bonusPercent: Number(m[1]), revivals: Number(m[2]), animation: script.name, source: 'skill_detail#' + s.id + '; Lua ' + script.name + '.aniState=1', triggerEvidence: 'User xác nhận: lần tử trận đầu đủ điều kiện; Kakarot rời sân.' };
}
export function fusionCandidates(owner, units) {
    const defs = battleSkillConfig('character_detail');
    return units.filter(e => e !== owner && e.index % 100 < 5 && (e.index < 100) === (owner.index < 100) && /^kaka(?:rot|lot)$/.test(norm(defs[e.originConfigId ?? e.card.card_id]?.name)));
}
export function fusionPartner(owner, units, active, eligible = e => e.hp > 0) {
    return fusionCandidates(owner, units).find(e => active.has(e) && eligible(e));
}
export function fusionAttributes(owner, donor, percent) {
    if (!Number.isFinite(percent) || percent < 0)
        throw Error('Thiếu phần trăm chỉ số Hợp Thể hợp lệ.');
    return Object.fromEntries(fusionFields.map(f => {
        if (!Number.isFinite(owner[f]) || !Number.isFinite(donor[f]) || owner[f] < 0 || donor[f] < 0)
            throw Error('Thiếu chỉ số cơ sở Hợp Thể hợp lệ.');
        const n = owner[f] + donor[f] * percent / 100;
        if (!Number.isFinite(n) || n > Number.MAX_SAFE_INTEGER)
            throw Error('Chỉ số Hợp Thể vượt giới hạn an toàn.');
        return [f, n];
    }));
}
export function fusionDiagnostics(e, s) {
    const rule = fusionRule(e, s);
    return rule ? { ...rule, statPolicy: fusionStatPolicy, status: 'IMPLEMENTED_UNVERIFIED', formulaEvidence: 'User: Vegeta +20% chỉ số Kakarot tại thời điểm hợp thể.', notice: 'Hợp thể chỉ tồn tại trong trận, không tiêu tướng sở hữu. Sát thương nguyên tố/nhánh CS khác chưa được suy thành công thức giả.' } : null;
}
// Bộ xử lý CS dùng chung theo source slot; Gogeta là một context, không phải engine riêng.
export function fusionSkillPlan(e, s, fused = false, party) {
    const plan = compileSkill(s.cfg, s.lv, e.skinActive === true, { fusion: fused ? 'gogeta' : undefined }), defs = battleSkillConfig('character_detail'), skills = battleSkillConfig('skill_detail'), c = defs[e.originConfigId ?? e.card.card_id];
    if (!c)
        return plan;
    const visual = defs[e.card.card_id] ?? c;
    const slot = [1, 2, 3, 4, 5, 6, 7].find(n => sourceSkillChain(c, n, skills).includes(s.id) || sourceSkillChain(visual, n, skills).includes(s.id)), stage = { 1: 1, 2: 2, 3: 3, 6: 4, 7: 5, 4: 6, 5: 7 }[slot ?? 0];
    if (!stage || Number(e.record.bre ?? 0) < stage)
        return plan;
    const story = String(battleSkillConfig('character_break_new')[e.originConfigId ?? e.card.card_id]?.['story_detail' + stage] ?? '');
    if (!story)
        return plan;
    // Annotation Skin CS7 không được cắt mất mệnh đề Thần Ngự phía sau.
    const clean = story.replace(/\(nếu có trang bị Skin[^)]*\)/gi, ''), t = activeSkillClause(clean, fused);
    const extra = compileSkill({ ...s.cfg, skill_story: clean, resource_count: 0 }, s.lv, false, { fusion: fused ? 'gogeta' : undefined });
    const effects = [...plan.effects], blockers = [...plan.blockers], add = (v) => { if (!effects.some(e => e.kind === v.kind && e.stat === v.stat && e.percent === v.percent && e.target === v.target))
        effects.push(v); };
    for (const reason of extra.blockers)
        if (!blockers.includes(reason))
            blockers.push(reason);
    for (const effect of extra.effects) {
        if (effect.kind === 'instantKill')
            continue;
        add(effect);
    }
    const max = t.match(/moi luot toi da (?:phat dong|kich hoat) (\d+) lan/) ?? t.match(/so lan kich hoat bien thanh (\d+)/);
    if (max)
        plan.roundLimit = Number(max[1]);
    const killed = t.match(/diet ngay (?:ngau nhien )?(\d+) (?:don vi|muc tieu|ke dich)/) ?? t.match(/diet ngay (\d+) don vi ngau nhien/);
    if (killed && !effects.some(e => e.kind === 'instantKill'))
        effects.push({ kind: 'instantKill', percent: 100, target: 'enemy', limit: Number(killed[1]), randomTargets: /ngau nhien/.test(t) });
    const additionalSpeed = t.match(/st bang (\d+) lan toc do/);
    if (additionalSpeed) {
        // Tính đòn bổ sung trước buff tốc độ của chính lần phát kỹ năng này.
        const at = effects.findIndex(e => e.kind === 'modifier');
        effects.splice(at < 0 ? effects.length : at, 0, { kind: 'damage', stat: 'speed', percent: Number(additionalSpeed[1]) * 100, target: plan.effects.find(e => e.kind === 'damage')?.target ?? 'enemy', trueDamage: plan.effects.find(e => e.kind === 'damage')?.trueDamage ?? false });
        blockers.push('ST bổ sung theo tốc độ nguồn; loại ST và cộng phần trăm vẫn dùng adapter LOCAL.');
    }
    if (fused) {
        const count = t.match(/so nguoi bi diet bien thanh (\d+)/), drain = t.match(/xoa (\d+) luot hoi sinh/);
        for (const effect of effects)
            if (effect.kind === 'instantKill') {
                if (count)
                    effect.limit = Number(count[1]);
                if (drain)
                    effect.reviveDrain = Number(drain[1]);
            }
        const guard = t.match(/co them "than ngu" trong (\d+) luot/);
        if (guard)
            effects.push({ kind: 'guard', percent: 100, target: 'self', duration: Number(guard[1]) });
    }
    const guard = t.match(/(?:nhan|cho ban than) (\d+) (?:tang|lan) "?than ngu"?/);
    const guardTurns = t.match(/nhan "than ngu", (?:keo dai|duy tri) (\d+) (?:luot|hiep)/);
    if (guard)
        add({ kind: 'guard', percent: 100, target: 'self', limit: Number(guard[1]) });
    if (guardTurns)
        add({ kind: 'guard', percent: 100, target: 'self', duration: Number(guardTurns[1]) });
    const drain = t.match(/xoa (\d+) lan so luot hoi sinh/);
    if (drain)
        for (const effect of effects)
            if (effect.kind === 'instantKill')
                effect.reviveDrain = Number(drain[1]);
    if (e.skinActive && /co dinh diet (\d+) lan/.test(norm(story))) {
        // User xác nhận: xoá bốn lượt trước một lần Diệt Ngay, không phát skill bốn lần.
        const n = Number(norm(story).match(/co dinh diet (\d+) lan/)[1]);
        let kill = effects.find(v => v.kind === 'instantKill');
        if (!kill) {
            kill = { kind: 'instantKill', percent: 100, target: 'enemy', limit: 1, randomTargets: true };
            effects.push(kill);
        }
        kill.reviveDrain = n;
    }
    else if (/dua (?:vao|tren) so (?:nguoi|luong dong minh)/.test(t) && /ngoc rong/.test(t)) {
        const context = dragonBallContext(e, party);
        if (context) {
            for (const effect of effects)
                if (effect.kind === 'instantKill')
                    effect.reviveDrain = context.count;
        }
        else
            blockers.push('Thiếu ngữ cảnh đồng minh phe Ngọc Rồng; chưa tự xoá lượt theo phe.');
    }
    if (/truy kich cho ke dich khac voi st bang (\d+)% hp max ban than/.test(t)) {
        const n = Number(t.match(/truy kich cho ke dich khac voi st bang (\d+)% hp max ban than/)[1]);
        effects.push({ kind: 'damage', stat: 'hp', percent: n, target: 'enemy', trueDamage: true, excludeKilled: true });
        blockers.push('Truy kích HP đúng hệ số/mục tiêu khác; loại ST theo adapter LOCAL của chiêu.');
    }
    if (/mien dich.*choang/.test(t)) {
        effects.push({ kind: 'controlImmunity', stat: 'stun', percent: 100, target: 'self', permanent: true });
        blockers.push('Đã nối miễn Choáng; Trầm Mặc/Hoá Đá/Hỗn Loạn/Chế Giễu/Tsukuyomi chưa có đầy đủ handler.');
    }
    if (/ho gia/.test(t) && fused)
        blockers.push('Hộ Giá chưa có hợp đồng hiệu ứng; không đánh đồng với Thần Ngự.');
    if (slot === 1 && /them \d+ lan st/.test(t))
        blockers.push('CS1 thêm lần ST chưa rõ số hit hay số lần phát skill; không tự nhân activation.');
    if (/phong ngu nguyen to/.test(t))
        blockers.push('Phòng ngự nguyên tố chưa có công thức nguồn đầy đủ.');
    if (/khong the phong ky nang tu vong/.test(t))
        blockers.push('Khóa KDEAD/Diệt Ngay thiếu thời hạn và quy tắc gỡ; chưa tự gán cấm vĩnh viễn.');
    // HP/miễn choáng tiền chiến có hiệu lực trước các đòn trong cùng kỹ năng.
    if (slot === 5)
        effects.sort((a, b) => Number(b.kind === 'modifier' || b.kind === 'controlImmunity') - Number(a.kind === 'modifier' || a.kind === 'controlImmunity'));
    if (!extra.effects.length && !guard && !guardTurns && !max && !killed && !drain)
        blockers.push('Mốc CS' + stage + ' chưa có đủ handler: ' + story);
    return { ...plan, effects, blockers, rebirthSource: { heroId: e.originConfigId ?? e.card.card_id, sourceSlot: slot, stage, story }, status: !effects.length ? 'MISSING_BATTLE_HANDLER' : blockers.length ? 'PARTIAL' : 'IMPLEMENTED_UNVERIFIED' };
}
export function fusionSkillAnimation(e, s, fused = false) {
    if (!fused)
        return s.animationName;
    const c = battleSkillConfig('character_detail')[e.originConfigId ?? e.card.card_id];
    if (c && sourceSkillChain(c, 5, battleSkillConfig('skill_detail')).includes(s.id)) {
        // s71 gốc dùng gongji8_2_teixao1; s7 dùng gongji8_teixao1 của dạng thường.
        return transformationSkillScript(e.card.card_id, e.card.animation, s.id, e.card.animation + '_s71')?.name ?? s.animationName;
    }
    return s.animationName;
}
