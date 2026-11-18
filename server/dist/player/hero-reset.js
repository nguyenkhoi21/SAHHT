import { createBaseHero } from './definitions.js';
import { readConfigSync as cfg } from './local-content.js';
import { historyHash, historyOf, sourceResetRules } from './consumption-history.js';
import { heroStoredExp, ProgressionEconomyService } from './progression-economy.js';
import { WelfareService } from './welfare.service.js';
const fail = (m) => { throw Object.assign(Error(m), { statusCode: 422 }); };
const progress = (h) => ({ level: h.lv, evolution: h.evo ?? 0, step: h.step ?? 0, rebirth: h.bre ?? 0, superEvolution: h.super_step ?? 0, breakthrough: h.element_break ?? 0, reform: Object.fromEntries(['hp', 'patk', 'matk', 'def', 'speed'].map(f => [f, h[f + '_crystal'] ?? 0])) });
export class HeroResetService {
    db;
    constructor(db) {
        this.db = db;
    }
    preview(userId, heroId) {
        const core = new ProgressionEconomyService(this.db), s = { user_id: userId }, h = core.hero(s, heroId), profile = core.profile(s), form = JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(userId).formation)), rule = sourceResetRules(), history = historyOf(h);
        const contains = (v) => v === heroId || !!(v && typeof v === 'object' && Object.entries(v).some(([k, x]) => k === heroId || contains(x))), bound = this.db.prepare("SELECT 1 FROM player_equipment WHERE user_id=? AND json_extract(state,'$.bind_card')=?").get(userId, heroId), missing = [];
        if ((profile.level ?? 1) < 19)
            missing.push('Cần cấp người chơi19 theo inreview128.');
        if ((h.step ?? 0) < 4)
            missing.push('Cần tiến hóa step≥4 theo Lua gốc, không phải+6.');
        if (contains(form) || h.lock || h.remove_avail?.length || bound || h.bind_equip?.some((v) => v && String(v) !== '0'))
            missing.push('Tháo tướng khỏi đội/Trợ Uy/Vận Mệnh/Trận Pháp, mở khóa và gỡ ràng buộc trang bị trước.');
        if (h._local_transformation)
            missing.push('Tướng có kế thừa Chuyển Thế: chưa xác minh Tái Sinh xử lý nền kế thừa; không xóa provenance.');
        if (h.element_break)
            missing.push('Chưa có quy tắc hoàn/reset Đột Phá trong notice133.');
        if (!history?.complete)
            missing.push('Không có ledger tiêu hao liên tục từ trạng thái gốc. Không suy thẻ lịch sử hay cấp lại theo một bảng phỏng đoán.');
        if (this.db.prepare('SELECT 1 FROM player_hero_qa_backup WHERE user_id=? AND id=?').get(userId, heroId))
            missing.push('Tướng có snapshot chỉnh tiến trình QA; không hoàn nguyên liệu cho tiến trình được cấp miễn phí.');
        const normal = h._local_skill_bank ?? [h.s_1, h.s_2, h.s_3];
        if (normal.some((v) => v && (v.lv > 1 || v.exp > 0)) || [h.s_4, h.s_5].some(v => v && (v.lv > 1 || v.exp > 0)) || h._local_skill_bank?.slice(3).some((v) => v.avail === 2))
            missing.push('Cấp/EXP kỹ năng hoặc quyền mua thêm đã thay đổi; chưa có định nghĩa hoàn EXP skill trong nguồn, giữ chặn để không mất tiến trình.');
        const refunds = [], excluded = [];
        for (const e of history?.entries ?? []) {
            if (!['cards.card_evolution', 'cards.card_break', 'cards.make_soul', 'cards.super_evolution', 'laboratory.level_up'].includes(e.method)) {
                if (e.method !== 'cards.inherit.reset')
                    missing.push('Ledger chứa thao tác chưa có quy tắc hoàn: ' + e.method);
                continue;
            }
            for (const c of e.costs)
                for (const [type, id, n] of c.rewards) {
                    const allowed = e.method === 'cards.card_break' ? type === 5 : [5, 6, 4, 20, 40].includes(type);
                    if (allowed)
                        refunds.push([type, id, n]);
                    else
                        excluded.push({ type, id, quantity: n, reason: e.method === 'cards.card_break' ? 'Tái Sinh không hoàn tài nguyên Chuyển Sinh (notice133).' : type === 9 ? 'Không hoàn Xu đã nâng (notice133).' : 'Không thuộc danh mục tài nguyên hoàn trong notice133.' });
                }
        }
        const grouped = new Map();
        for (const [t, id, n] of refunds)
            grouped.set(t + ':' + id, (grouped.get(t + ':' + id) ?? 0) + n);
        const reward = [...grouped].map(([key, n]) => [...key.split(':').map(Number), n]);
        const neededHeroes = reward.filter(r => r[0] === 5).reduce((n, r) => n + r[2], 0), owned = Number(this.db.prepare('SELECT COUNT(*) n FROM player_heroes WHERE user_id=?').get(userId).n);
        if (owned + neededHeroes > (profile.card_max ?? 20))
            missing.push('Cần thêm ' + Math.max(0, owned + neededHeroes - (profile.card_max ?? 20)) + ' ô tướng trống để nhận đủ thẻ hoàn trả; không reset trước rồi làm mất thẻ.');
        const next = createBaseHero(h.id, h.c_id, cfg('character_detail')[h.c_id]), orb = (h.quality ?? cfg('character_detail')[h.c_id].quality) <= 2 ? 0 : heroStoredExp(h), fingerprint = historyHash({ hero: h, rule: rule.sha256 });
        return { heroId, name: cfg('character_detail')[h.c_id]?.name, current: progress(h), eligibility: { minimumEvolutionStep: 4, meetsStep: (h.step ?? 0) >= 4, inFormation: contains(form), locked: !!h.lock, boundEquipment: h.bind_equip ?? [] }, proposedReset: progress(next), refund: missing.length ? null : { reward, orbExp: orb, returnedFodder: reward.filter(r => r[0] === 5) }, nonrefundable: excluded, cost: { coin: 0, evidence: 'Người dùng xác nhận Tái Sinh không mất phí27/10/2026; Lua không có màn thu phí.' }, fingerprint, canExecute: missing.length === 0, status: missing.length ? 'BLOCKED_MISSING_PROVENANCE' : 'READY', missing: [...new Set(missing)], notice: 'Tái Sinh khác Chuyển Sinh/Kế Thừa: hoàn theo ledger và notice133, tài nguyên Chuyển Sinh không hoàn. Skin tài khoản giữ nguyên; trang bị phải tháo trước.', source: rule };
    }
    execute(userId, heroId, key, expected) {
        const core = new ProgressionEconomyService(this.db), s = { user_id: userId }, params = new URLSearchParams({ card_id: heroId, request_id: key ?? '', preview_hash: expected ?? '' });
        return core.execute(s, 'cards.card_rebirth', params, () => {
            const preview = this.preview(userId, heroId);
            if (!preview.canExecute)
                fail(preview.missing.join(' '));
            if (!expected || preview.fingerprint !== expected)
                fail('Tướng hoặc bản xem trước đã đổi; mở lại preview trước khi xác nhận.');
            const h = core.hero(s, heroId), p = core.profile(s);
            p.exp_ball = Number(p.exp_ball ?? 0) + preview.refund.orbExp;
            if (!Number.isSafeInteger(p.exp_ball) || p.exp_ball > Number.MAX_SAFE_INTEGER)
                fail('EXP bóng vượt giới hạn.');
            core.save(s, createBaseHero(h.id, h.c_id, cfg('character_detail')[h.c_id]));
            core.saveProfile(s, p);
            const delivery = preview.refund.reward.length ? new WelfareService(this.db).applyInTransaction(s, preview.refund.reward, { heroes: cfg('character_detail'), items: cfg('item'), equipment: cfg('equip') }) : { reward: [] };
            return { ...delivery, hero_id: h.id, reset: preview.proposedReset, orb_added: preview.refund.orbExp, nonrefundable: preview.nonrefundable };
        });
    }
}
