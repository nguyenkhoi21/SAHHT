import { randomBytes, randomUUID, createHash } from 'node:crypto';
import { GodfieldService, godfieldState } from './godfield.service.js';
import { GodfieldLeagueService } from './godfield-league.js';
import { godfieldConfig } from './godfield-source.js';
import { godfieldCombatTeam } from './godfield-battle.js';
import { readConfigSync } from './local-content.js';
import { serializeEntity, simulateBattle } from './local-combat.js';
import { contentReceipt } from './content-receipt.js';
import { audit } from '../admin/admin.audit.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
const integer = (v, min, max, label) => { if (!/^\d+$/.test(String(v)) || !Number.isSafeInteger(Number(v)) || Number(v) < min || Number(v) > max)
    fail(label + ' không hợp lệ.'); return Number(v); };
const clean = (p) => [...p].filter(([k]) => !['request_id', 'rans', 'rand', 'user_token', 'mk', 'method'].includes(k)).sort(([a], [b]) => a.localeCompare(b));
export const zodiacBlockers = [
    'Boss: chưa xác minh công thức HP theo số người/nhánh hp_add và thời điểm phát thưởng BXH; chưa mở đánh hoặc phát quà Boss.',
    'Ô may mắn: nguồn có thưởng/luck_time nhưng thiếu cách chọn ô và giờ 3:00 mâu thuẫn; chưa tạo ô hoặc phát thưởng giả.',
    'Nhiệm vụ truy nã/kẻ thù: có UI và cấu hình, chưa đủ quy tắc chọn mục tiêu/kết toán; chưa mở giao dịch.',
    'Thời điểm gửi Thư khi thu hồi/bị đánh bật do người dùng xác nhận. LOCAL dùng+07 và mốc10phút từ lúc chiếm, không trả phần lẻ; ngày mới gửi tồn đọng. Mốc tick server gốc chưa xác minh. Khóa ba đội sau trận đầu trong ngày theo team_lock.',
];
export class GodfieldZodiacService {
    db;
    realNow;
    seed;
    store;
    constructor(db, realNow = Date.now, seed = () => randomBytes(4).readUInt32LE()) {
        this.db = db;
        this.realNow = realNow;
        this.seed = seed;
        this.store = new GodfieldLeagueService(db, realNow);
    }
    clock() { const c = this.store.clock(), r = godfieldConfig('constellation_detail')['1'], start = Date.parse(c.day + 'T' + r.active_start + ':00+07:00'), end = Date.parse(c.day + 'T' + r.active_end + ':00+07:00'); return { ...c, start, end, open: c.now >= start && c.now < end }; }
    check(id, open = false) { new GodfieldService(this.db).assertUnlocked(id); if (open && !this.clock().open)
        fail('12 Cung mở từ11:00 đến23:00; chưa tiêu lượt.'); }
    raw(id) { return this.store.state(id, 'zodiac-formation', this.clock().day, {}); }
    visible(id, state) { const copy = structuredClone(state), owned = new Set(this.db.prepare('SELECT id FROM player_heroes WHERE user_id=?').all(id).map(r => String(r.id))); for (let t = 1; t <= 3; t++)
        copy.god_field_ids[t] = copy.god_field_ids[t].map((h) => h !== '0' && h !== '-1' && !owned.has(h) ? '-1' : h); return copy; }
    join(id) { let row = this.raw(id); if (!row.formation) {
        row = { formation: godfieldState(this.db, id), locked: false };
        this.store.put(id, 'zodiac-formation', this.clock().day, row);
    } return row; }
    formation(id) { this.check(id); const row = this.raw(id); return { ...new GodfieldService(this.db).packet(id, this.visible(id, row.formation ?? godfieldState(this.db, id))), teams: this.teams(id), team_lock: row.locked ? 1 : 0 }; }
    teams(id) { const out = { '1': { floor: 0, pos: 0 }, '2': { floor: 0, pos: 0 }, '3': { floor: 0, pos: 0 } }; for (const r of this.db.prepare('SELECT team,floor,pos FROM godfield_zodiac_positions WHERE day=? AND user_id=?').all(this.clock().day, id))
        out[String(r.team)] = { floor: Number(r.floor), pos: Number(r.pos) }; return out; }
    who(id) { const r = this.db.prepare('SELECT p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?').get(id); if (!r)
        fail('Nhân vật không còn tồn tại.'); const p = JSON.parse(String(r.profile)); return { uid: String(r.game_uid), name: String(p.show_name), level: Number(p.level), role: Number(r.role), server: 'SAHHT LOCAL', guild: '' }; }
    dayState(id) { return this.store.state(id, 'zodiac-day', this.clock().day, { used: 0, wins: {} }); }
    run(s, method, p, fn) { this.check(s.user_id); return contentReceipt(this.db, s.user_id, method, p.get('request_id'), clean(p), () => { const data = fn(); audit(this.db, null, method, s.user_id, '12 Cung LOCAL: thao tác có ledger, không sửa Main/Arena', null, { day: this.clock().day, floor: p.get('floor'), pos: p.get('pos'), team: p.get('team') }); return data; }, old => ({ ...old, reward: [], _client_cache_update: undefined, replayed: true })); }
    save(s, p) { return this.run(s, 'zodiac.update_field', p, () => { this.check(s.user_id, true); const row = this.join(s.user_id); if (row.locked)
        fail('Đã đánh trong ngày; trận hình 12 Cung đã khóa, chưa thay đổi đội.'); row.formation = new GodfieldService(this.db).updatedState(s, p, row.formation); this.store.put(s.user_id, 'zodiac-formation', this.clock().day, row); return this.formation(s.user_id); }); }
    rank(floor) { const c = this.clock(); return this.db.prepare('SELECT user_id,team,wins FROM godfield_zodiac_positions WHERE day=? AND floor=? ORDER BY wins DESC,occupied_at,user_id,team LIMIT 3').all(c.day, floor).map(r => ({ ...this.who(Number(r.user_id)), team: String(r.team), vin_times: Number(r.wins) })); }
    occupationId(id, row) {
        const ref = this.store.state(id, 'zodiac-day', String(row.day), {}).occupationIds?.[String(row.team)];
        const battle = ref ? this.db.prepare("SELECT id FROM godfield_zodiac_battles WHERE id=? AND user_id=? AND day=? AND team=? AND floor=? AND pos=? AND json_extract(packet,'$.won')=1").get(ref, id, row.day, row.team, row.floor, row.pos) : this.db.prepare("SELECT id FROM godfield_zodiac_battles WHERE user_id=? AND day=? AND team=? AND floor=? AND pos=? AND json_extract(packet,'$.won')=1 ORDER BY created_at DESC,rowid DESC LIMIT 1").get(id, row.day, row.team, row.floor, row.pos);
        if (!battle)
            fail('Thiếu trận chiếm ô để đối chiếu quyền thu nhập; giữ nguyên dữ liệu.');
        return String(battle.id);
    }
    income(row) {
        const end = Date.parse(String(row.day) + 'T' + godfieldConfig('constellation_detail')[String(row.floor)].active_end + ':00+07:00'), until = Math.min(this.clock().now, end), periods = Math.max(0, Math.floor((until - Number(row.paid_at)) / 600000));
        const rewards = periods ? godfieldConfig('constellation_reward')[String(row.floor)].reward_perten.map(([type, cid, n]) => [type, cid, n * periods]) : [];
        for (const [type, cid, n] of rewards)
            if (![1, 2].includes(type) || cid !== 0 || !Number.isSafeInteger(n) || n <= 0)
                fail('Thu nhập12Cung chưa có hợp đồng thư hợp lệ; giữ nguyên trận địa.');
        return { periods, rewards };
    }
    info(id) { const c = this.clock(), teams = this.teams(id), team_reward = { '1': [], '2': [], '3': [] }, vin_times_rank = {}; for (const r of this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE day=? AND user_id=?').all(c.day, id))
        team_reward[String(r.team)] = this.income(r).rewards; for (let f = 1; f <= 12; f++) {
        const r = this.rank(f)[0];
        if (r)
            vin_times_rank[f] = r;
    } return { regular: godfieldConfig('constellation_detail')['1'].regular, teams, team_reward, vin_times_rank, challenge_times: Math.max(0, Number(godfieldConfig('constellation_detail')['1'].challenge_times) - this.dayState(id).used), zodiac_notice: ['Thu nhập tích lũy mỗi10phút; gửi vào Thư khi hủy nhóm hoặc bị đánh bật. LOCAL: Boss, ô may mắn và truy nã chưa mở.'], source_blockers: zodiacBlockers, open: c.open }; }
    // paid_at giữ nguyên các khoảng đã trả trực tiếp ở bản cũ. Bản mới chỉ
    // tạo thư cho phần chưa thanh toán của đúng đội rời ô, cùng transaction.
    settle(id, rows, reason) {
        const mailIds = [], totals = new Map();
        for (const r of rows) {
            const { periods, rewards } = this.income(r);
            if (!periods)
                continue;
            const next = Number(r.paid_at) + periods * 600000, mailId = 'zodiac-income-' + createHash('sha256').update(JSON.stringify([id, r.day, r.floor, r.pos, r.team, r.paid_at, next, this.occupationId(id, r)])).digest('hex');
            const content = `Thu nhập Thần Vực12Cung\n${godfieldConfig('constellation_detail')[String(r.floor)].floor_name} · ô${r.pos} · đội${r.team}\n${periods} chu kỳ10phút. ${reason}\nPhần thưởng chưa cộng vào túi; nhận thư để lĩnh.`;
            // ID ổn định + PK tài khoản/thư; lỗi insert rollback việc trảô/cursor.
            this.db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(id, mailId, content, JSON.stringify(rewards));
            this.db.prepare('UPDATE godfield_zodiac_positions SET paid_at=? WHERE day=? AND floor=? AND pos=? AND user_id=?').run(next, r.day, r.floor, r.pos, id);
            for (const [type, cid, n] of rewards) {
                const k = type + ':' + cid;
                totals.set(k, (totals.get(k) ?? 0) + n);
            }
            mailIds.push(mailId);
            audit(this.db, null, 'zodiac.income.mail', id, 'Thu nhập12Cung qua Thư khi rời ô; thời điểm do user xác nhận', null, { periods, rewards, mailId, floor: r.floor, pos: r.pos, team: r.team, reason });
        }
        return mailIds.length ? { reward: [], delivery: 'MAIL_PENDING', mail_ids: mailIds, reward_tuples: [...totals].map(([k, n]) => [...k.split(':').map(Number), n]) } : {};
    }
    index(id) {
        this.check(id);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            // Ngày mới buộc trảô cũ. Gửi phần còn tồn đọng, không xóa tiến trình/thư.
            const expired = this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE user_id=? AND day<? ORDER BY day,floor,pos').all(id, this.clock().day), delivery = this.settle(id, expired, 'Kết thúc ngày giữ trận địa.');
            const data = { ...this.info(id), ...delivery };
            this.db.exec('COMMIT');
            return data;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    palace(id, value) {
        this.check(id);
        const floor = integer(value, 1, 12, 'Cung'), c = this.clock(), cfg = godfieldConfig('constellation_detail')[floor], rows = this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE day=? AND floor=?').all(c.day, floor), byPos = new Map(rows.map(r => [Number(r.pos), r])), pos_info = {};
        for (let pos = 1; pos <= 60; pos++) {
            const r = byPos.get(pos);
            pos_info[pos] = r ? { ...this.who(Number(r.user_id)), team_id: Number(r.team) } : { uid: 'NPC:' + floor + ':' + pos, name: 'Thủ vệ', team_id: 0 };
        }
        return { ...this.info(id), pos_info, rank_vin_times_info: this.rank(floor), enemy_info: {}, lucky_situation: {}, isactive: false, team_fight_boss_times: { '1': 0, '2': 0, '3': 0 }, tiltle_name: cfg.tiltle_name, boss_info: { start_time: Math.max(0, Math.floor((Date.parse(c.day + 'T' + godfieldConfig('constellation_reward')[floor].boss_start + ':00+07:00') - c.now) / 1000)) }, floor, source_blockers: zodiacBlockers };
    }
    npc(floor, pos) { const fight = godfieldConfig('constellation_detail')[floor]['fight' + pos], row = godfieldConfig('constellationfight_position')[fight], defs = godfieldConfig('constellation_enemy'); if (!row)
        fail('Thiếu đội NPC nguồn #' + fight + '.'); const ids = Array.from({ length: 8 }, (_, i) => Number(row['position' + (i + 1)] ?? 0)); for (const id of ids)
        if (id && !defs[id])
            fail('Thiếu NPC nguồn #' + id + '.'); return { fight, ids, defs }; }
    userInfo(id, p) {
        this.check(id);
        const floor = integer(p.get('floor'), 1, 12, 'Cung'), pos = integer(p.get('pos'), 1, 60, 'Trận địa'), row = this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE day=? AND floor=? AND pos=?').get(this.clock().day, floor, pos), uid = row ? this.who(Number(row.user_id)).uid : 'NPC:' + floor + ':' + pos;
        if (p.get('uid') !== uid)
            fail('Người giữ trận địa đã đổi; mở lại cung trước.');
        if (row) {
            const owner = Number(row.user_id), team = Number(row.team), formation = this.visible(owner, this.raw(owner).formation ?? godfieldState(this.db, owner)), a = godfieldCombatTeam(this.db, owner, team, 0, formation);
            return { ...this.who(owner), team_id: team, combat: a.power, alignment_info: a.entities.map(e => ({ ...e.record, c_id: e.originConfigId })), floor, pos };
        }
        const npc = this.npc(floor, pos), alignment_info = npc.ids.filter(Boolean).map(cid => ({ c_id: cid }));
        return { uid, server: 'NPC', name: 'Thủ vệ ' + godfieldConfig('constellation_detail')[floor].floor_name, level: Math.max(...npc.ids.filter(Boolean).map(cid => npc.defs[cid].lv ?? 1)), role: 1, guild: '', team_id: 0, combat: npc.ids.filter(Boolean).reduce((n, cid) => n + Number(npc.defs[cid].battle_point ?? 0), 0), combat_status: 'Tổng battle_point từng NPC từ config; không lấy lực chiến Main.', alignment_info, floor, pos };
    }
    battle(s, p) {
        return this.run(s, 'zodiac.zodiac_battle', p, () => {
            this.check(s.user_id, true);
            const floor = integer(p.get('floor'), 1, 12, 'Cung'), pos = integer(p.get('pos'), 1, 60, 'Trận địa'), team = integer(p.get('team'), 1, 3, 'Đội'), c = this.clock(), own = this.join(s.user_id), day = this.dayState(s.user_id), limit = Number(godfieldConfig('constellation_detail')[floor].limit_capacity), max = Number(godfieldConfig('constellation_detail')[floor].challenge_times);
            if (day.used >= max)
                fail('Đã hết20lượt khiêu chiến trong ngày.');
            if (this.teams(s.user_id)[team].floor)
                fail('Đội này đang giữ trận địa; hãy tự thu hồi trước.');
            const a = godfieldCombatTeam(this.db, s.user_id, team, 0, this.visible(s.user_id, own.formation));
            if (limit && a.power > limit)
                fail('Lực chiến đội vượt giới hạn cung này.');
            const target = this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE day=? AND floor=? AND pos=?').get(c.day, floor, pos), uid = target ? this.who(Number(target.user_id)).uid : 'NPC:' + floor + ':' + pos;
            if (p.get('target_uid') !== uid)
                fail('Người giữ trận địa đã đổi; mở lại thông tin trước khi đánh.');
            if (target?.user_id === s.user_id)
                fail('Không tự tấn công trận địa của mình.');
            let d, defenderName, defenderRole, npcInfo = null;
            if (target) {
                const owner = Number(target.user_id);
                d = godfieldCombatTeam(this.db, owner, Number(target.team), 100, this.visible(owner, this.raw(owner).formation ?? godfieldState(this.db, owner)));
                const who = this.who(owner);
                defenderName = who.name;
                defenderRole = who.role;
            }
            else {
                const npc = this.npc(floor, pos), skills = readConfigSync('skill_detail'), entities = npc.ids.flatMap((cid, i) => { if (!cid)
                    return []; const cfg = npc.defs[cid], active = [1, 2, 3].map(n => cfg['skill' + n]).filter(v => v?.length && skills[v[0]]).map(v => ({ id: v[0], lv: v[1], cfg: skills[v[0]] })); return [serializeEntity(100 + i, 'zodiac-npc-' + cid + '-' + i, cid, cfg, cfg, active)]; });
                if (!entities.some(e => e.index < 105))
                    fail('Đội NPC nguồn không có tướng chính.');
                d = { entities, formation: { formation: { current: 1 }, equip_pos: {} }, equipment: {} };
                defenderName = 'Thủ vệ ' + godfieldConfig('constellation_detail')[floor].floor_name;
                defenderRole = 1;
                npcInfo = { fight: npc.fight, enemyIds: npc.ids };
            }
            const id = 'zodiac-' + randomUUID(), seed = this.seed(), sim = simulateBattle([...a.entities, ...d.entities], seed), won = sim.winner === 0, who = this.who(s.user_id);
            own.locked = true;
            this.store.put(s.user_id, 'zodiac-formation', c.day, own);
            day.used++;
            if (won) {
                if (target) {
                    this.settle(Number(target.user_id), [target], 'Đội bị đánh bật khỏi trận địa.');
                    const lost = this.dayState(Number(target.user_id));
                    lost.wins[Number(target.team)] = 0;
                    this.store.put(Number(target.user_id), 'zodiac-day', c.day, lost);
                    this.db.prepare('DELETE FROM godfield_zodiac_positions WHERE day=? AND floor=? AND pos=?').run(c.day, floor, pos);
                }
                (day.occupationIds ??= {})[team] = id;
                day.wins[team] = Number(day.wins[team] ?? 0) + 1;
                this.db.prepare('INSERT INTO godfield_zodiac_positions VALUES(?,?,?,?,?,?,?,?)').run(c.day, floor, pos, s.user_id, team, c.now, c.now, day.wins[team]);
            }
            else {
                day.wins[team] = 0;
                if (target) {
                    const held = this.dayState(Number(target.user_id));
                    held.wins[Number(target.team)] = Number(held.wins[Number(target.team)] ?? Number(target.wins)) + 1;
                    this.store.put(Number(target.user_id), 'zodiac-day', c.day, held);
                    this.db.prepare('UPDATE godfield_zodiac_positions SET wins=? WHERE day=? AND floor=? AND pos=?').run(held.wins[Number(target.team)], c.day, floor, pos);
                }
            }
            this.store.put(s.user_id, 'zodiac-day', c.day, day);
            const battle = { ...sim.battle, init: { ...sim.battle.init, aform: a.formation.formation.current, dform: d.formation.formation.current, atk_name: who.name, dfd_name: defenderName, atk_lv: who.level, dfd_lv: target ? this.who(Number(target.user_id)).level : 1, atk_role: who.role, dfd_role: defenderRole, equip_att: a.equipment, equip_def: d.equipment, equip_pos_att: a.formation.equip_pos, equip_pos_def: d.formation.equip_pos } }, packet = { battle, reward: {}, battle_rewards: { reward_exp_player: [], reward_exp_character: {}, reward_character: {}, reward_item: {} }, match_id: id, won, teams: this.teams(s.user_id) }, metadata = { seed, won, rounds: sim.rounds, lifeEvents: sim.lifeEvents, diagnostics: sim.diagnostics, npc: npcInfo, defenderName };
            this.db.prepare('INSERT INTO godfield_zodiac_battles VALUES(?,?,?,?,?,?,?,?,?,?,?)').run(id, s.user_id, target ? Number(target.user_id) : null, c.day, floor, pos, team, p.get('request_id'), JSON.stringify(packet), JSON.stringify(metadata), this.realNow());
            return packet;
        });
    }
    withdraw(s, p) {
        const result = this.run(s, 'zodiac.remove_floor_pos', p, () => {
            const team = integer(p.get('team'), 1, 3, 'Đội'), c = this.clock(), row = this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE day=? AND user_id=? AND team=?').get(c.day, s.user_id, team);
            if (!row)
                fail('Đội không giữ trận địa nào.');
            if (p.has('floor') && Number(p.get('floor')) !== row.floor || p.has('pos') && Number(p.get('pos')) !== row.pos)
                fail('Trận địa đã đổi; chưa thu hồi.');
            const rewards = this.settle(s.user_id, [row], 'Người chơi thu hồi đội.');
            this.db.prepare('DELETE FROM godfield_zodiac_positions WHERE day=? AND user_id=? AND team=?').run(c.day, s.user_id, team);
            // remove_floor_pos: popup chọn đội cần formation. remove_floor_pos2: popup
            // ô đang giữ mở trực tiếp palace và cần đủ pos_info/lucky_situation/boss_info.
            return { ...this.formation(s.user_id), ...this.palace(s.user_id, Number(row.floor)), ...rewards };
        });
        // Receipt cũ đã thu hồi nhưng thiếu dữ liệu scene: chỉ bổ sung projection,
        // không chạy lại settle/xóa ô/cấp thưởng khi client gửi lại đúng request.
        return !result.pos_info && p.has('floor') ? { ...result, ...this.palace(s.user_id, p.get('floor')) } : result;
    }
    history(id) { return this.db.prepare('SELECT * FROM godfield_zodiac_battles WHERE user_id=? OR target_user_id=? ORDER BY created_at DESC LIMIT 30').all(id, id).reverse().map(r => { const m = JSON.parse(String(r.metadata)), a = this.who(Number(r.user_id)); return { battle_log: r.id, sort: 1, time: Math.floor(Number(r.created_at) / 1000), msg: `${a.name} → ${m.defenderName}: ${m.won ? 'chiếm thành công' : 'thất bại'} cung${r.floor}/ô${r.pos}`, floor: r.floor, pos: r.pos, team: r.team, won: m.won }; }); }
    replay(id, key) { if (typeof key !== 'string' || !/^zodiac-[a-f0-9-]+$/.test(key))
        fail('Mã xem lại không hợp lệ.'); const r = this.db.prepare('SELECT packet FROM godfield_zodiac_battles WHERE id=? AND (user_id=? OR target_user_id=?)').get(String(key), id, id); if (!r)
        fail('Không có quyền xem trận này.'); return JSON.parse(String(r.packet)); }
    blocked() { return fail('Phần 12 Cung này còn thiếu quy tắc server gốc; chưa mở thao tác hoặc trừ tài nguyên.'); }
    prepareQaIncome(adminId, id, key, team) {
        if (process.env.APP_ENV !== 'local')
            fail('Mô phỏng thu nhập chỉ được dùng trên LOCAL.');
        const t = integer(team, 1, 3, 'Đội');
        this.check(id, true);
        return contentReceipt(this.db, id, 'zodiac.qa.income', key, { team: t }, () => {
            const c = this.clock(), row = this.db.prepare('SELECT * FROM godfield_zodiac_positions WHERE day=? AND user_id=? AND team=?').get(c.day, id, t);
            if (!row)
                fail('Đội không giữ trận địa; chưa thay đổi dữ liệu.');
            const used = this.store.state(id, 'zodiac-qa-income', c.day, {}), marker = this.occupationId(id, row);
            if (used[marker])
                fail('Đợt giữ ô này đã mô phỏng10phút; không cộng lặp.');
            if (c.now - Number(row.paid_at) >= 600000)
                fail('Đã đủ10phút thật; tự hủy nhóm để gửi thưởng vào Thư, không cần mô phỏng.');
            // Dịch đúng hai mốc của đội đang giữ; không đổi đồng hồ, lịch, lượt,
            // chủ ô hoặc ví. Quyền QA chỉ một lần/đợt giữ ô và có audit riêng.
            this.db.prepare('UPDATE godfield_zodiac_positions SET occupied_at=occupied_at-600000,paid_at=paid_at-600000 WHERE day=? AND user_id=? AND team=?').run(c.day, id, t);
            used[marker] = true;
            this.store.put(id, 'zodiac-qa-income', c.day, used);
            audit(this.db, adminId, 'zodiac.qa.income', id, 'LOCAL QA: mô phỏng đã giữ thêm10phút; chưa cấp thưởng, người chơi tự hủy nhóm rồi nhận Thư', row, { team: t, shiftMs: 600000 });
            return { ok: true, message: 'Đã mô phỏng10phút. Người chơi tự hủy nhóm để gửi thu nhập vào Thư.' };
        }, () => ({ ok: true, message: 'Thao tác QA đã thực hiện; không dịch mốc thêm.', replayed: true }));
    }
    diagnostics(id) { this.check(id); const c = this.clock(), raw = this.raw(id); return { clock: c, joined: !!raw.formation, locked: raw.locked === true, formation: this.formation(id), positions: this.db.prepare('SELECT day,floor,pos,team,occupied_at,paid_at,wins FROM godfield_zodiac_positions WHERE user_id=? ORDER BY day DESC,floor,pos LIMIT 30').all(id), remaining: this.info(id).challenge_times, pendingIncome: this.info(id).team_reward, incomeMail: this.db.prepare("SELECT id,read_at,attachments FROM player_mail WHERE user_id=? AND id LIKE 'zodiac-income-%' ORDER BY id DESC LIMIT 30").all(id).map(r => ({ id: r.id, claimed: r.read_at !== null, rewards: JSON.parse(String(r.attachments)) })), history: this.history(id), palaces: Object.entries(godfieldConfig('constellation_detail')).map(([floor, r]) => ({ floor: Number(floor), name: r.floor_name, limit: r.limit_capacity, rewardPerTen: godfieldConfig('constellation_reward')[floor].reward_perten })), blockers: zodiacBlockers }; }
}
