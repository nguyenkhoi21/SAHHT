import { beginHotSpend, endHotSpend } from './hot-spending.js';
import { PetService } from './pet.service.js';
import { arenaPositions, rankedCandidates, settleArenaRank } from './arena-ranking.js';
import { randomBytes, randomUUID } from 'node:crypto';
import { readStaticConfigSync as readConfigSync } from './local-content.js';
import { PlayerService } from './player.service.js';
import { ProgressionService } from './progression.service.js';
import { battleAppearance } from './appearance-state.js';
import { serializeEntity, simulateBattle } from './local-combat.js';
import { BeastService } from './beast.service.js';
import { audit } from '../admin/admin.audit.js';
import { CombatPowerService } from './combat-power.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
export const arenaPolicy = { free: 10, timeZone: process.env.LOCAL_ARENA_TIME_ZONE ?? 'Asia/Ho_Chi_Minh', winRating: 25, lossRating: 10, notice: 'Đấu trường: hạng lưu riêng, thắng đối thủ trên thì đổi hạng; rating lịch sử chỉ là chỉ số phụ +25/−10; reset00:00 Việt Nam, lượt mua hết hạn cùng ngày. Giá pay3/VIP.buy_arena từ config Việt Nam.' };
export class ArenaCombatService {
    db;
    now;
    constructor(db, now = Date.now) {
        this.db = db;
        this.now = now;
    }
    day() { return new Intl.DateTimeFormat('en-CA', { timeZone: arenaPolicy.timeZone, year: 'numeric', month: '2-digit', day: '2-digit' }).format(this.now()); }
    available() { return arenaPositions(this.db, this.db.prepare('SELECT p.user_id,p.game_uid,p.role,s.profile,s.formation,COALESCE(a.rating,1000) rating FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id LEFT JOIN arena_players a ON a.user_id=p.user_id').all().filter(row => { try {
        this.team(Number(row.user_id), 0);
        return true;
    }
    catch (e) {
        if (e.statusCode === 422)
            return false;
        throw e;
    } }).sort((a, b) => b.rating - a.rating || a.user_id - b.user_id)); }
    status(id, day = this.day()) { const d = this.db.prepare('SELECT used,purchased FROM arena_days WHERE user_id=? AND day=?').get(id, day), a = this.db.prepare('SELECT * FROM arena_players WHERE user_id=?').get(id); return { day, used: Number(d?.used ?? 0), purchased: Number(d?.purchased ?? 0), remaining: Math.max(0, arenaPolicy.free + Number(d?.purchased ?? 0) - Number(d?.used ?? 0)), rating: Number(a?.rating ?? 1000), points: Number(a?.points ?? 0), wins: Number(a?.wins ?? 0), losses: Number(a?.losses ?? 0) }; }
    eligible(id) { if (!new ProgressionService(this.db).featureGates(id).find((g) => g.buttonId === 200)?.prerequisiteMet)
        fail('Cần hoàn thành city103 để mở Đấu Trường.'); }
    init(id, day = this.day()) { this.db.prepare('INSERT OR IGNORE INTO arena_players(user_id) VALUES(?)').run(id); this.db.prepare('INSERT OR IGNORE INTO arena_days(user_id,day) VALUES(?,?)').run(id, day); }
    rank(id) { return this.available().find(r => r.user_id === id)?.rank ?? 0; }
    candidates(id) { return rankedCandidates(this.available(), id); }
    key(q) { if (typeof q.request_id !== 'string' || !/^[A-Za-z0-9_.:-]{8,160}$/.test(q.request_id))
        fail('Thiếu mã yêu cầu duy nhất; hãy cập nhật client test.'); return q.request_id; }
    duplicate(id, key, kind, target) { const old = this.db.prepare('SELECT * FROM arena_operations WHERE user_id=? AND request_key=?').get(id, key); if (old) {
        if (old.kind !== kind || (target !== undefined && old.target_user_id !== target))
            fail('Mã yêu cầu đã dùng cho thao tác khác.');
        return JSON.parse(old.packet);
    } }
    purchase(s, q) {
        const key = this.key(q), prior = this.duplicate(s.user_id, key, 'purchase');
        if (prior)
            return prior;
        this.eligible(s.user_id);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const duplicate = this.duplicate(s.user_id, key, 'purchase');
            if (duplicate) {
                this.db.exec('COMMIT');
                return duplicate;
            }
            beginHotSpend(this.db, s.user_id, 'arena.purchase', key, this.now());
            const day = this.day();
            this.init(s.user_id, day);
            const status = this.status(s.user_id, day), profile = JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile), limit = readConfigSync('vip')[String(profile.vip ?? 0)]?.buy_arena ?? 0, prices = readConfigSync('pay')['3'].coin;
            if (status.purchased >= limit)
                fail('Đã hết số lượt mua Đấu Trường hôm nay.');
            const price = prices[Math.min(status.purchased, prices.length - 1)];
            if (!Number.isSafeInteger(price) || price < 0)
                fail('Giá mua lượt không hợp lệ.');
            if ((profile.coin ?? 0) < price)
                fail('Không đủ kim cương để mua lượt.');
            profile.coin -= price;
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(profile), s.user_id);
            this.db.prepare('UPDATE arena_days SET purchased=purchased+1 WHERE user_id=? AND day=?').run(s.user_id, status.day);
            const packet = { can_battle_times: status.remaining + 1, buy_count: status.purchased + 1, price }, id = 'arenabuy-' + randomUUID();
            this.db.prepare('INSERT INTO arena_operations VALUES(?,?,?,?,?,?,?,?,?,?)').run(id, s.user_id, key, 'purchase', null, status.day, 'SETTLED', JSON.stringify(packet), JSON.stringify({ price }), this.now());
            endHotSpend(this.db, s.user_id);
            audit(this.db, null, 'arena.purchase', s.user_id, 'Mua1lượt theo pay3/VIP', status, packet);
            this.db.exec('COMMIT');
            return packet;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    team(userId, offset) {
        const player = this.db.prepare('SELECT p.user_id,p.game_uid,p.role,u.username FROM player_profiles p JOIN users u ON u.id=p.user_id WHERE p.user_id=?').get(userId);
        const cards = new PlayerService(this.db).cards(player), defs = readConfigSync('character_detail'), equip = readConfigSync('equip'), skills = readConfigSync('skill_detail'), entities = [];
        const canonical = new Map(new CombatPowerService(this.db).calculate(userId).heroes.map(h => [h.id, h]));
        const used = new Set();
        for (let slot = 0; slot < 8; slot++) {
            const id = cards.alignment[slot < 5 ? 0 : 1][slot % 5];
            if (id === '-1')
                continue;
            if (used.has(id))
                fail('Trùng tướng trong đội hình.');
            used.add(id);
            const h = cards.cards[id], cfg = defs[h?.c_id];
            if (!h || !cfg || !cfg.skill_num)
                fail('Đội hình có tướng không hợp lệ.');
            const attrs = canonical.get(id);
            if (!attrs)
                fail('Thiếu chỉ số đội hình canonical.');
            const state = { ...h, ...attrs.attributes, combat_empowerment: attrs.breakdown.empowerLines, combat_auxiliary: attrs.breakdown.auxiliary.effects };
            const appearance = battleAppearance(this.db, userId, h, defs, skills);
            entities.push(serializeEntity(offset + slot, id, appearance.configId, state, appearance.cfg, appearance.skills));
        }
        if (!entities.some(e => e.index % 100 < 5))
            fail('Đội hình chính đang trống.');
        const pet = new PetService(this.db).combat(userId);
        if (pet)
            entities[0].pet = pet;
        const beasts = new BeastService(this.db).combat(userId);
        if (beasts.length)
            entities[0].beasts = beasts;
        return { entities, cards, player };
    }
    battle(s, q) {
        const key = this.key(q), target = this.db.prepare('SELECT p.user_id FROM player_profiles p JOIN users u ON u.id=p.user_id WHERE p.game_uid=?').get(String(q.target ?? ''));
        if (!target || target.user_id === s.user_id)
            fail('Đối thủ local không hợp lệ.');
        const prior = this.duplicate(s.user_id, key, 'battle', Number(target.user_id));
        if (prior)
            return prior;
        this.eligible(s.user_id);
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const duplicate = this.duplicate(s.user_id, key, 'battle', Number(target.user_id));
            if (duplicate) {
                this.db.exec('COMMIT');
                return duplicate;
            }
            const day = this.day();
            this.init(s.user_id, day);
            this.init(Number(target.user_id), day);
            const before = this.status(s.user_id, day);
            if (before.remaining <= 0)
                fail('Đã hết lượt Đấu Trường hôm nay.');
            const candidates = this.candidates(s.user_id), candidate = candidates.find(r => r.user_id === Number(target.user_id));
            if (!candidate)
                fail('Đối thủ không thuộc danh sách hạng được phép; mở lại Đấu Trường.');
            if (q.rank !== undefined && Number(q.rank) !== candidate.rank)
                fail('Hạng đối thủ đã đổi; hãy tải lại Đấu Trường.');
            const attacker = this.team(s.user_id, 0), defender = this.team(Number(target.user_id), 100), sim = simulateBattle([...attacker.entities, ...defender.entities], randomBytes(4).readUInt32LE()), won = sim.winner === 0, oldRank = this.rank(s.user_id), rating = Math.max(0, before.rating + (won ? 25 : -10));
            this.db.prepare('UPDATE arena_days SET used=used+1 WHERE user_id=? AND day=?').run(s.user_id, before.day);
            this.db.prepare('UPDATE arena_players SET rating=?,wins=wins+?,losses=losses+? WHERE user_id=?').run(rating, won ? 1 : 0, won ? 0 : 1, s.user_id);
            const rank = settleArenaRank(this.db, s.user_id, Number(target.user_id), won).rank, award = Object.values(readConfigSync('arena_award')).find((r) => r.start_rank <= rank && rank <= r.end_rank), points = won ? Number(award?.per_point ?? 0) : 0;
            this.db.prepare('UPDATE arena_players SET points=points+? WHERE user_id=?').run(points, s.user_id);
            const profiles = [s.user_id, Number(target.user_id)].map(id => JSON.parse(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile));
            const packet = { battle: { ...sim.battle, init: { ...sim.battle.init, aform: attacker.cards.formation.current, dform: defender.cards.formation.current, atk_name: profiles[0].show_name, dfd_name: profiles[1].show_name, atk_lv: profiles[0].level ?? 1, dfd_lv: profiles[1].level ?? 1, atk_role: s.role, dfd_role: defender.player.role, equip_att: attacker.cards.equip, equip_def: defender.cards.equip, equip_pos_att: attacker.cards.equip_pos, equip_pos_def: defender.cards.equip_pos } }, cur_rank: rank, old_rank: oldRank, reward: { arena_point: points }, rewards: {}, battle_rewards: { reward_exp_player: [], reward_exp_character: {}, reward_character: {}, reward_item: {} }, can_battle_times: before.remaining - 1 };
            const id = 'arenabattle-' + randomUUID(), metadata = { winner: sim.winner, rounds: sim.rounds, rules: sim.rules, skillDiagnostics: sim.diagnostics, beastDiagnostics: sim.beastDiagnostics, petDiagnostics: sim.petDiagnostics, lifeEvents: sim.lifeEvents, empowermentDiagnostics: sim.empowerment, ...(sim.trace ? { trace: sim.trace } : {}), oldRank, rank, rating, points, attacker: s.game_uid, defender: defender.player.game_uid, a_combat: new CombatPowerService(this.db).calculate(s.user_id).combat, d_combat: new CombatPowerService(this.db).calculate(Number(target.user_id)).combat };
            this.db.prepare('INSERT INTO arena_operations VALUES(?,?,?,?,?,?,?,?,?,?)').run(id, s.user_id, key, 'battle', target.user_id, before.day, 'SETTLED', JSON.stringify(packet), JSON.stringify(metadata), this.now());
            audit(this.db, null, 'arena.battle.settle', s.user_id, 'SimulatorLOCAL; kết quả/rating/thưởng nguyên tử', before, metadata);
            this.db.exec('COMMIT');
            return packet;
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    history(id) { return this.db.prepare('SELECT id,kind,day,metadata,created_at FROM arena_operations WHERE user_id=? ORDER BY created_at DESC,id LIMIT 50').all(id).map(r => ({ ...r, metadata: JSON.parse(r.metadata) })); }
    clientHistory(id) { return this.db.prepare("SELECT id,user_id,packet,metadata,created_at FROM arena_operations WHERE kind='battle' AND (user_id=? OR target_user_id=?) ORDER BY created_at DESC,id LIMIT 30").all(id, id).map(r => { const p = JSON.parse(r.packet), m = JSON.parse(r.metadata); return { battle_log: r.id, tp: r.user_id === id ? 'attack' : 'defend', is_win: m.winner === 0, attacker: p.battle.init.atk_name, defender: p.battle.init.dfd_name, a_combat: m.a_combat ?? 0, d_combat: m.d_combat ?? 0, time: Math.floor(r.created_at / 1000) }; }); }
    replay(id, key) { const r = this.db.prepare("SELECT packet FROM arena_operations WHERE id=? AND kind='battle' AND (user_id=? OR target_user_id=?)").get(String(key ?? ''), id, id); if (!r)
        fail('Không có biên bản Arena của tài khoản này.'); return JSON.parse(r.packet); }
    reset(id, adminId, exhaust = false) { this.db.exec('BEGIN IMMEDIATE'); try {
        const day = this.day();
        this.init(id, day);
        const before = this.status(id, day);
        this.db.prepare('UPDATE arena_days SET used=?,purchased=? WHERE user_id=? AND day=?').run(exhaust ? arenaPolicy.free + before.purchased : 0, exhaust ? before.purchased : 0, id, before.day);
        audit(this.db, adminId, 'arena.qa.reset', id, exhaust ? 'QA hết lượt để kiểm UI; không tạo trận/thưởng' : 'QA hoàn lại lượt; không hoàn tiền/rank/thưởng', before, this.status(id));
        this.db.exec('COMMIT');
        return this.status(id);
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    restore(id, adminId) {
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const snapshot = this.db.prepare("SELECT id,before_state,after_state,created_at FROM admin_audit WHERE target_user_id=? AND action='arena.qa.reset' ORDER BY id DESC LIMIT 1").get(id);
            if (!snapshot)
                fail('Không có snapshot lượt Arena QA.');
            if (this.db.prepare("SELECT 1 FROM admin_audit WHERE target_user_id=? AND action='arena.qa.restore' AND id>?").get(id, snapshot.id))
                fail('Snapshot đã được khôi phục.');
            const before = JSON.parse(snapshot.before_state), applied = JSON.parse(snapshot.after_state), current = this.status(id);
            if (before.day !== current.day || JSON.stringify(current) !== JSON.stringify(applied) || this.db.prepare('SELECT 1 FROM arena_operations WHERE user_id=? AND created_at>=?').get(id, snapshot.created_at))
                fail('Arena đã có thay đổi hoặc qua ngày; không ghi đè tiến trình mới.');
            this.db.prepare('UPDATE arena_days SET used=?,purchased=? WHERE user_id=? AND day=?').run(before.used, before.purchased, id, before.day);
            audit(this.db, adminId, 'arena.qa.restore', id, 'Khôi phục riêng lượt từ snapshot QA; giữ toàn bộ tiền/thưởng/trận', current, this.status(id));
            this.db.exec('COMMIT');
            return this.status(id);
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
}
