import { PlayerService } from './player.service.js';
import { CombatPowerService } from './combat-power.js';
import { ArenaCombatService } from './arena-combat.js';
import { readConfigSync } from './local-content.js';
// LOCAL TEST IMPLEMENTATION: rating từ kết quả Arena, ID chỉ dùng phân xử đồng hạng.
export class ArenaService {
    db;
    constructor(db) {
        this.db = db;
    }
    pool() {
        const rows = new ArenaCombatService(this.db).available();
        return rows.filter(row => JSON.parse(String(row.formation)).alignment[0].some((x) => x !== '-1' && x !== '0'))
            .map(row => { const p = JSON.parse(String(row.profile)), arena = new ArenaCombatService(this.db).status(Number(row.user_id)); return { userId: Number(row.user_id), uid: String(row.game_uid), name: String(p.show_name), role: String(row.role), rank: Number(row.rank), level: Number(p.level ?? 1), rating: arena.rating, combat: new CombatPowerService(this.db).calculate(Number(row.user_id)).combat, title: Number(p.cur_title ?? 0), guild_name: '' }; }).sort((a, b) => a.rank - b.rank);
    }
    open(session) {
        const pool = this.pool(), self = pool.find(p => p.uid === session.game_uid);
        const status = new ArenaCombatService(this.db).status(session.user_id);
        return { award_expire: 0, can_battle_times: status.remaining, buy_count: status.purchased, rank: self?.rank ?? pool.length + 1, point: status.points, combat: self?.combat ?? 0,
            front_user: new ArenaCombatService(this.db).candidates(session.user_id).map(r => pool.find(p => p.userId === r.user_id)).filter(Boolean), exchange_log: {}, log: new ArenaCombatService(this.db).clientHistory(session.user_id) };
    }
    top(page) {
        if (typeof page !== 'string' || !/^[0-4]$/.test(page))
            throw Object.assign(new Error('Trang Arena không hợp lệ'), { statusCode: 422 });
        return { top: this.pool().slice(Number(page) * 20, (Number(page) + 1) * 20) };
    }
    playerRanking(kind, page, selfUid) {
        // Main1166 không gửi page ở request đầu; các tab sau gửi page0..4.
        const current = page === undefined ? '0' : page;
        if (typeof current !== 'string' || !/^[0-4]$/.test(current))
            throw Object.assign(new Error('Trang xếp hạng không hợp lệ'), { statusCode: 422 });
        // Dữ liệu công khai từ account local; không bịa combat hoặc thành tích thi đấu.
        const rows = this.db.prepare('SELECT p.user_id,p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id ORDER BY p.user_id').all();
        const players = rows.map(row => { const p = JSON.parse(String(row.profile)); return { userId: Number(row.user_id), uid: String(row.game_uid), name: String(p.show_name), role: String(row.role), level: Number(p.level ?? 1), exp: Number(p.exp ?? 0), combat: new CombatPowerService(this.db).calculate(Number(row.user_id)).combat, title: Number(p.cur_title ?? 0), rank: 0 }; });
        players.sort((a, b) => b[kind] - a[kind] || (kind === 'level' ? b.exp - a.exp : 0) || a.userId - b.userId);
        players.forEach((p, i) => p.rank = i + 1);
        return { top: players.slice(Number(current) * 20, (Number(current) + 1) * 20).map(({ userId, exp, ...p }) => p), ...(selfUid ? { own_rank: players.find(p => p.uid === selfUid)?.rank ?? 0, total: players.length } : {}) };
    }
    publicProfile(uid) {
        if (typeof uid !== 'string' || !/^local_player_[1-9][0-9]*$/.test(uid))
            throw Object.assign(new Error('Chỉ xem identity local hợp lệ'), { statusCode: 404 });
        const target = this.db.prepare('SELECT p.user_id,p.game_uid,p.role FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.game_uid=?').get(uid);
        if (!target)
            throw Object.assign(new Error('Không có player local này'), { statusCode: 404 });
        const players = new PlayerService(this.db), all = players.cards(target, true), profile = players.profile(target, {});
        const visible = new Set([...all.alignment.flat(), ...all.assistant, ...all.destiny]);
        const equipment = new Set([...Object.values(all.equip_pos), ...Object.values(all.ass_equip_pos)].flat());
        const publicEquip = Object.fromEntries(Object.entries(all.equip).filter(([id]) => equipment.has(id))), specials = new Set(Object.values(publicEquip).flatMap((e) => e.gem_fate ?? []).map(String));
        const extra = { _gem_special: Object.fromEntries(Object.entries(all.gem_special ?? {}).filter(([id]) => specials.has(id))) };
        extra.gem_special = extra._gem_special;
        // game_player_data.updateCardsOpenByJsonData → setCurCardSkinData;
        // isWearSkin duyệt pairs() ngay cả khi tướng chỉ hỗ trợ Skin nhưng chưa mặc.
        // Luôn gửi bảng rỗng; chỉ công khai Skin đang mặc của các tướng đang trưng bày.
        const definitions = readConfigSync('character_detail'), skinIds = new Set([...visible].map(id => Number(definitions[all.cards[id]?.c_id]?.is_skin ?? 0)).filter(id => id > 0));
        extra.used_skin = (all.used_skin ?? []).map(Number).filter((id) => skinIds.has(id));
        const worn = new Set(extra.used_skin.map(String));
        extra.skin = Object.fromEntries(Object.entries(all.skin ?? {}).filter(([id]) => worn.has(id)));
        for (const kind of ['talisman', 'gem', 'soul', 'god_stone', 'medal']) {
            const pos = all[kind + '_pos'] ?? {}, ids = new Set(Object.values(pos).flat().map(String));
            extra[kind + '_pos'] = pos;
            extra[kind] = Object.fromEntries(Object.entries(all[kind] ?? {}).filter(([id]) => ids.has(id)));
        }
        for (const key of ['ass_talisman_pos', 'bonus_talisman_pos', 'talisman_pos_1', 'talisman_pos_2', 'talisman_pos_3', 'equip_pos_1', 'equip_pos_2', 'equip_pos_3', 'bonus_equip_pos', 'formation_bonus_addition', 'assistant_effect', 'god_field_ids'])
            extra[key] = all[key] ?? {};
        // Chỉ snapshot đang trưng bày; không gửi currency/inventory/session/account secret.
        return { new_data: { ...extra, user: { uid: target.game_uid, name: profile.show_name, role: target.role, title: profile.cur_title ?? 0, level: profile.level ?? 1, combat: profile.combat ?? 0, association_id: 0, association_name: '' },
                cards: Object.fromEntries(Object.entries(all.cards).filter(([id]) => visible.has(id))),
                equip: Object.fromEntries(Object.entries(all.equip).filter(([id]) => equipment.has(id))),
                alignment: all.alignment, formation: all.formation, equip_pos: all.equip_pos, ass_equip_pos: all.ass_equip_pos,
                assistant: all.assistant, destiny: all.destiny, gem_pos: all.gem_pos, medal_pos: all.medal_pos } };
    }
}
