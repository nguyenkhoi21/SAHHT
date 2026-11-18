const text = (s) => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/đ/g, 'd').replace(/\s+/g, ' ').trim();
export function activeSkillClause(raw, fused = false) { const state = /\bo trang thai "cuc y gogeta"\s*,?\s*/; const s = text(raw); return (fused ? s.replace(new RegExp(state.source, 'g'), '') : s.split(state)[0]).split(/\bneu\b|\bmoi (?:mot|1) dong doi\b/)[0]; }
export function compileSkill(skill, level, skin = false, context = {}) {
    const raw = String(skill.skill_story ?? ''), story = text(raw), effects = [], blockers = [], lv = Math.min(Math.max(1, level || 1), skill.max_lv ?? 30), coefficient = Number((Number(skill.effect) + Number(skill.effect_lvchange ?? 0) * lv).toFixed(1));
    const roundLimit = Number(story.match(/moi hiep toi da (?:hoi phuc |phat ra |tha )?(\d+) lan/)?.[1] ?? 0) || undefined;
    const maxRound = Number(story.match(/(?:truoc|trong) (\d+) hiep (?:co hieu luc|dau)/)?.[1] ?? 0) || undefined;
    const result = () => ({ effects, blockers, story: raw, coefficient, roundLimit, maxRound, status: !effects.length ? 'MISSING_BATTLE_HANDLER' : blockers.length ? 'PARTIAL' : 'IMPLEMENTED_UNVERIFIED' });
    if (!raw || /[\u3400-\u9fff]/.test(raw) || !Number.isFinite(coefficient) || coefficient < 0) {
        blockers.push('Thiếu mô tả Việt Nam/hệ số hợp lệ.');
        return result();
    }
    if (Number(skill.resource_count ?? 0) > 0)
        blockers.push('resource_type/count chưa có consumer chiến đấu xác minh; không tự trừ tài nguyên/nộ khí.');
    const skinParts = [...story.matchAll(/\(hieu ung skin:([^)]*)\)/g)].map(m => m[1]), fullBase = story.replace(/\(hieu ung skin:[^)]*\)/g, '');
    // Không thực thi mệnh đề sau “nếu …” khi chưa có bộ đánh giá điều kiện.
    // Giữ phần trước điều kiện (ví dụ damage gốc), không lấy heal/buff/target ở phần sau.
    const stateClause = (s) => {
        const state = /\bo trang thai "cuc y gogeta"\s*,?\s*/;
        return context.fusion === 'gogeta' ? s.replace(new RegExp(state.source, 'g'), '') : s.split(state)[0];
    };
    const safeClause = (s) => stateClause(s).split(/\bneu\b|\bmoi (?:mot|1) dong doi\b/)[0];
    const base = safeClause(fullBase), skinText = skin ? skinParts.map(safeClause).join(' ') : '', active = base + ' ' + skinText;
    if (base !== stateClause(fullBase) || skin && skinParts.some(s => safeClause(s) !== stateClause(s)))
        blockers.push('Mệnh đề điều kiện/phe chưa có evaluator; không kích hoạt phần hiệu ứng sau điều kiện.');
    // “Tăng effect% ST ma pháp” là buff, không phải một đòn gây sát thương.
    const damageScope = base.split(/[.;]/).filter(s => !/tang.*effect%/.test(s) || /(?:gay|tao).*effect%/.test(s)).join('.').replace(/diet ngay[^.]+/g, '');
    const ambiguous = /\b\d+\s*[-–]\s*\d+ muc tieu|ngau nhien|uu tien.*(thap|cao)|truc tuyen|hang doc/.test(damageScope);
    const target = /toan bo (?:don vi )?(?:doi phuong|dich)|moi nguoi ben doi phuong|toan phe dich/.test(base) ? 'allEnemies' : /xep sau/.test(base) ? 'back' : 'enemy';
    const physical = /(?:sat thuong|st)(?: thuc| that)?(?: bang)?(?: tan cong)? vat l[iy] effect%|effect% (?:sat thuong|st)(?: thuc| that)?(?: tan cong)? vat l[iy]|(?:sat thuong|st) (?:thuc|that) bang effect% (?:tan cong|luc cong) vat l[iy]/.test(damageScope);
    const magical = /(?:sat thuong|st)(?: thuc| that)?(?: bang)?(?: tan cong)? ma phap effect%|effect% (?:sat thuong|st)(?: thuc| that)?(?: tan cong)? ma phap|(?:sat thuong|st) (?:thuc|that) bang effect% (?:tan cong|luc cong) ma phap/.test(damageScope);
    const speed = /sat thuong diem toc do effect%/.test(damageScope);
    if (ambiguous && (physical || magical || speed))
        blockers.push('Chưa xác minh chọn nhiều mục tiêu/ngẫu nhiên/hàng cho mô tả này.');
    else if (physical || magical || speed) {
        for (const [yes, stat] of [[physical, 'patk'], [magical, 'matk'], [speed, 'speed']])
            if (yes)
                effects.push({ kind: 'damage', stat, percent: coefficient, target, trueDamage: /(?:sat thuong|st) (?:thuc|that)/.test(base) });
    }
    // Một số mẫu trước chỉ số đặt effect phía sau danh từ; không suy diễn từ tên skill.
    if (!effects.some(e => e.kind === 'damage') && !ambiguous && /tao (?:tong )?sat thuong vat li effect%/.test(base))
        effects.push({ kind: 'damage', stat: 'patk', percent: coefficient, target });
    const hpDamage = base.match(/(?:sat thuong|st) truy kich bang (\d+(?:\.\d+)?)% hp (?:max|toi da)(?: cua)? ban than/) ?? base.match(/truy kich (?:them )?voi st (?:thuc|that) bang (\d+(?:\.\d+)?)% hp/);
    if (hpDamage) {
        effects.push({ kind: 'damage', stat: 'hp', percent: Number(hpDamage[1]), target, trueDamage: /truy kich (?:them )?voi st (?:thuc|that)/.test(base) || effects.find(e => e.kind === 'damage')?.trueDamage === true });
        blockers.push('ST truy kích theo HP nguồn; gộp loại ST/phòng thủ dùng adapter LOCAL của kỹ năng.');
    }
    const duration = Number(base.match(/(?:keo dai|duy tri) (\d+) (?:hiep|luot)/)?.[1] ?? 0), stack = Number(base.match(/(?:toi da don|cong don toi da) (\d+) lan/)?.[1] ?? 1);
    const healEffect = /hoi phuc (?:hp )?effect% hp(?:\.|,|$)/.test(base) || /hoi phuc hp effect%/.test(base);
    const fixedHeal = active.match(/(?:hoi|hoi phuc|phuc hoi) (\d+(?:\.\d+)?)% hp(?: max| toi da)?(?: ban than| cua ban than)?/) ?? active.match(/luong hp max duoc hoi phuc len toi (\d+)%/);
    const fullHeal = skill.skill_type !== 'KDEAD' && /(?:hoi|hoi phuc|phuc hoi) (?:toan bo|tat ca) hp/.test(active);
    if (healEffect || fixedHeal || fullHeal) {
        const perRound = base.match(/moi hiep toi da (?:hoi phuc|phat ra) (\d+) lan/);
        effects.push({ kind: 'heal', stat: 'hp', percent: fullHeal ? 100 : healEffect ? coefficient : Number(fixedHeal[1]), target: 'self', limit: perRound ? Number(perRound[1]) : undefined });
        if (/giam 20%/.test(base)) {
            effects.pop();
            blockers.push('Chưa xác minh cách suy giảm trị liệu mỗi hiệp.');
        }
    }
    const healPosition = base.search(/(?:hoi|hoi phuc|phuc hoi) (?:toan bo|tat ca|\d+(?:\.\d+)?%) hp/), damagePosition = base.search(/(?:gay|tao) (?:ra |nen )?(?:st|sat thuong|effect)/);
    if (healPosition >= 0 && damagePosition >= 0 && healPosition < damagePosition) {
        const i = effects.findIndex(v => v.kind === 'heal');
        if (i >= 0)
            effects.unshift(...effects.splice(i, 1));
    }
    const stats = [[/toc do/, 'speed', 'buff_speed'], [/phong ngu/, 'def', 'buff_dfs'], [/vat cong/, 'patk', 'buff_phsc'], [/ma cong/, 'matk', 'buff_mgc']];
    // Chỉ nhận mẫu tăng/giảm có thời hạn và đối tượng rõ. Không đoán thời hạn vĩnh viễn.
    for (const [pattern, stat, frame] of stats) {
        const label = stat === 'speed' ? '(?:diem )?toc do' : stat === 'def' ? 'phong ngu' : stat === 'patk' ? 'vat cong' : 'ma cong';
        const up = new RegExp('tang (?:effect|\\d+(?:\\.\\d+)?)% ' + label + ' (?:ban than|toan bo phe ta|cho ban than)'), down = new RegExp('giam ' + label + ' (?:ke dich|doi phuong) (effect|\\d+(?:\\.\\d+)?)%');
        const m = base.match(up), d = base.match(down);
        if (duration && (m || d)) {
            const amount = m ? (m[0].includes('effect') ? coefficient : Number(m[0].match(/(\d+(?:\.\d+)?)%/)?.[1])) : d[1] === 'effect' ? coefficient : Number(d[1]);
            if (Number.isFinite(amount))
                effects.push({ kind: 'modifier', stat, percent: d ? -amount : amount, target: d ? 'enemy' : /toan bo phe ta/.test(m[0]) ? 'allies' : 'self', duration, stacks: stack, frame: d ? frame.replace('buff_', 'buff_') + 'low' : frame });
        }
        const permanent = new RegExp('tang (?:them )?(effect|\\d+(?:\\.\\d+)?)% (?:' + label + (stat === 'matk' ? '|luc cong ma phap' : stat === 'patk' ? '|luc cong vat li' : '') + ') (?:cua )?ban than cho den khi (?:chien dau ket thuc|ket thuc chien dau)').exec(base);
        if (permanent)
            effects.push({ kind: 'modifier', stat, percent: permanent[1] === 'effect' ? coefficient : Number(permanent[1]), target: 'self', permanent: true, stacks: /co the chong/.test(base) ? Number.MAX_SAFE_INTEGER : 1, frame });
    }
    const burn = base.match(/co (\d+)% ti le khien muc tieu bi thieu dot, ke bi thieu moi hiep giam (\d+)% hp, keo dai (\d+) hiep/);
    if (burn && effects.some(e => e.kind === 'damage'))
        effects.push({ kind: 'dot', percent: Number(burn[2]), chance: Number(burn[1]), duration: Number(burn[3]), target, frame: 'buff_fire' });
    const stun = base.match(/(?:co (\d+)% ti le )?lam choang (?:muc tieu da dinh|doi phuong|muc tieu) (\d+) hiep/);
    if (stun)
        effects.push({ kind: 'control', percent: 0, chance: Number(stun[1] ?? 100), duration: Number(stun[2]), target: 'enemy', frame: 'buff_giddy' });
    const steal = base.match(/(\d+)% sat thuong tao ra se chuyen hoa thanh diem hp/);
    if (steal)
        effects.push({ kind: 'lifesteal', percent: Number(steal[1]), target: 'self' });
    const permanentHp = base.match(/(?:vinh vien tang|tang vinh vien) (\d+)% hp max/);
    if (permanentHp)
        effects.push({ kind: 'modifier', stat: 'hp', percent: Number(permanentHp[1]), target: 'self', permanent: true, frame: 'buff_hp' });
    const reduce = base.match(/(\d+)% giam thuong chinh the/);
    if (reduce)
        effects.push({ kind: 'reduction', percent: Number(reduce[1]), target: 'self', permanent: true, frame: 'buff_jianshang' });
    const invulnerable = base.match(/(?:nhan|duoc) (?:trang thai )?vo dich(?: trong)? (\d+) (?:hiep|luot)/) ?? base.match(/(?:nhan|duoc) (\d+) (?:hiep|luot) "?vo dich"?/);
    if (invulnerable)
        effects.push({ kind: 'invulnerable', percent: 100, target: 'self', duration: Number(invulnerable[1]), frame: 'buff_undead' });
    if (skill.skill_type === 'KDEAD' && /hoi (?:phuc )?(?:toan bo|tat ca|100%|toan) hp/.test(active)) {
        const max = base.match(/toi da (?:co the )?(?:duoc )?hoi sinh (\d+) lan|hoi sinh toi da (\d+) lan|moi (?:tran|cuoc doi chien)(?: chien)? (?:chi )?(?:duoc )?(?:phat dong|dung)?\s*(\d+) lan/);
        if (max)
            effects.push({ kind: 'revive', percent: 100, target: 'self', limit: Number(max[1] ?? max[2] ?? max[3]) });
        else
            blockers.push('Thiếu số lần Hồi Sinh tối đa; không tự cho hồi sinh vô hạn.');
    }
    const kill = base.match(/diet ngay (?:ngau nhien )?(\d+) (?:don vi|muc tieu|ke dich)/);
    if (kill)
        effects.push({ kind: 'instantKill', percent: 100, target: 'enemy', limit: Number(kill[1]), randomTargets: /ngau nhien/.test(base.slice(kill.index)) });
    if (skill.skill_type === 'KDEAD' && /hoi sinh|tai sinh/.test(active) && !effects.some(e => e.kind === 'revive'))
        blockers.push('Chưa đủ HP/số lần hồi sinh để nối vòng đời tử trận an toàn; không tự gán HP hoặc số lần.');
    if (/st thuoc tinh|st t\.tinh|st t\.tinh|% st.*(?:hoa|gio|thuy|tho)|sat thuong nguyen to/.test(base))
        blockers.push('Chưa có công thức kháng/sát thương nguyên tố nguồn.');
    if (/diet ngay|goi don|on dinh|vo dich|than ngu|than cam|truy kich|phe ngoc rong|ti le ne|ne tranh|bao kich|hoang so|nang luong|no khi/.test(base))
        blockers.push('Còn điều kiện phe/buff/kháng hoặc hiệu ứng đặc biệt chưa có handler nguồn.');
    if (/choang/.test(base) && !stun)
        blockers.push('Thiếu thời hạn/quy tắc khống chế chính xác.');
    if (/st max/.test(base))
        blockers.push('Mô tả ST max không chỉ rõ HP hay sát thương; không tự đổi đơn vị.');
    if (/khong ton so (?:lan|luot) hoi sinh/.test(active))
        blockers.push('Hoàn lượt theo phe/Skin cần evaluator riêng; chỉ áp dụng mốc CS có xác suất cố định rõ trong character_break_new.');
    if (!effects.length)
        blockers.push('Mô tả chưa thuộc mẫu hiệu ứng đã xác minh; không dùng hệ số sát thương giả.');
    if (effects.some(e => e.kind === 'damage' && !e.trueDamage))
        blockers.push('Hệ số/loại công từ config; trừ DEF và làm tròn vẫn theo adapter LOCAL, chưa có công thức server gốc.');
    if (effects.some(e => e.kind === 'modifier'))
        blockers.push('Cộng phần trăm trong từng trạng thái theo adapter LOCAL; chưa có quy tắc cộng dồn production.');
    return result();
}
