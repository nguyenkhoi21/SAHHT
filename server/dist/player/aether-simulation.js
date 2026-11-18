import { aetherConfig } from './aether-source.js';
import { AetherEconomy } from './aether-economy.js';
import { simAssert, simPolicy, simGet, simPut, simRoll, simRewards } from './aether-sim-policy.js';
export const simReads = ['box_index', 'war_index', 'player_index', 'explore_index'];
export const simWrites = ['select_reward', 'get_war_reward', 'auto_get_war_reward', 'send_war_card', 'simulate_purchase', 'stationed_source', 'declare_war_source', 'down_alignment_source', 'stationed_fate', 'down_alignment_fate', 'explore', 'get_fate_reward'];
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
export class AetherSimulation {
    db;
    event;
    host;
    now;
    constructor(db, event, host, now = () => Date.now()) {
        this.db = db;
        this.event = event;
        this.host = host;
        this.now = now;
        simAssert(db, event);
    }
    packet(id, out) { return new AetherEconomy(this.db, this.event.id).packet({ user_id: id }, { ...out, simulation: true, simulation_policy: simPolicy.version, simulation_label: simPolicy.label }); }
    activity(id, action) {
        if (!this.db.isTransaction)
            throw Error('Hoạt động mô phỏng cần transaction.');
        const d = this.host.day(), log = simGet(this.db, this.event.id, id, 'activity', 'days', { days: [] });
        if (!log.days.includes(d)) {
            log.days.push(d);
            log.days.sort();
            log.days = log.days.slice(0, 30);
            simPut(this.db, this.event.id, id, 'activity', 'days', log, this.now());
        }
        this.db.prepare("INSERT OR IGNORE INTO aether_claims VALUES(?,?,'simulation-activity',?,?,?)").run(this.event.id, id, d, JSON.stringify({ event: this.event.id, groupId: this.host.group(id).group_id, guildId: this.host.group(id).guild_id, action, policy: simPolicy.version }), this.now());
    }
    pass(id) { return simGet(this.db, this.event.id, id, 'pass', 'card', { premium: false, gifts: 0 }); }
    passRows() { return Object.values(aetherConfig('card')).filter(r => r.version === this.event.version); }
    war(id) { const card = this.pass(id), days = new Set([...simGet(this.db, this.event.id, id, 'activity', 'days', { days: [] }).days, ...this.db.prepare("SELECT substr(claim_key,1,10) day FROM aether_claims WHERE event_id=? AND user_id=? AND kind='science-contribution'").all(this.event.id, id).map(r => String(r.day))]); return this.packet(id, { version: this.event.version, score: Math.min(30, days.size), war_card: card.premium ? 1 : 0, war_card_num: card.gifts, got_war_card_reward_free: this.claimed(id, 'war-free'), got_war_card_reward: this.claimed(id, 'war-premium') }); }
    guildScore(guild) { const row = this.db.prepare('SELECT science_level FROM aether_guilds WHERE event_id=? AND guild_id=?').get(this.event.id, guild); const city = this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND owner_id=?').all(this.event.id, guild).reduce((n, r) => n + Number(aetherConfig('build')[Number(r.city_id)]?.score ?? 0), 0), science = Object.values(aetherConfig('science')).filter(r => r.level <= Number(row?.science_level ?? 0)).flatMap(r => r.buff2).filter(r => r[0] === 5).reduce((n, r) => n + r[1], 0); return city + science; }
    guildRank(id, group) {
        if (!Object.values(aetherConfig('group')).some(g => g.version === this.event.version && g.group_id === group))
            fail('Chiến trường không thuộc mùa này.');
        const rows = this.db.prepare('SELECT g.guild_id,a.name,a.icon FROM aether_guilds g JOIN alliances a ON a.id=g.guild_id WHERE g.event_id=? AND g.group_id=?').all(this.event.id, group).map(r => ({ ...r, score: this.guildScore(Number(r.guild_id)) })).sort((a, b) => b.score - a.score || Number(a.guild_id) - Number(b.guild_id)), own = this.host.group(id).guild_id;
        return this.packet(id, { version: this.event.version, ass_id: String(own), rank: Object.fromEntries(rows.map((r, i) => [i + 1, { ...r, guild_id: String(r.guild_id), city_count: Object.fromEntries([1, 2, 3].map(lv => [String(lv), this.db.prepare('SELECT city_id FROM aether_cities WHERE event_id=? AND owner_id=?').all(this.event.id, r.guild_id).filter(c => aetherConfig('build')[Number(c.city_id)]?.city_level === lv && aetherConfig('build')[Number(c.city_id)]?.sort === 1).length])) }])), self_score: this.guildScore(own), self_rank: Math.max(0, rows.findIndex(r => r.guild_id === own) + 1), ranking_status: 'LOCAL_SIMULATION', ranking_message: 'Mô phỏng LOCAL: điểm thành + buff2 loại5 cộng dồn; bằng điểm xếp ID hội. Không phải công thức server gốc.' });
    }
    guildFinal() {
        if (this.host.phase().step !== 7 && !this.host.phase().ended)
            return;
        for (const row of this.db.prepare('SELECT guild_id,group_id FROM aether_guilds WHERE event_id=?').all(this.event.id)) {
            const group = Number(row.group_id), guild = Number(row.guild_id);
            if (this.db.prepare("SELECT 1 FROM aether_wars WHERE event_id=? AND group_id=? AND status<>'done'").get(this.event.id, group) || this.db.prepare('SELECT 1 FROM aether_cities WHERE event_id=? AND group_id=? AND attacker_id IS NOT NULL').get(this.event.id, group))
                continue;
            const score = this.guildScore(guild), cfg = Object.values(aetherConfig('reward_season')).filter(r => r.need <= score).sort((a, b) => b.need - a.need)[0];
            if (!cfg)
                continue;
            const users = this.db.prepare("SELECT DISTINCT user_id FROM aether_claims WHERE event_id=? AND kind IN('science-contribution','simulation-activity') AND json_extract(reward,'$.guildId')=?").all(this.event.id, guild);
            this.db.exec('BEGIN IMMEDIATE');
            try {
                for (const user of users) {
                    const id = Number(user.user_id), key = String(guild);
                    if (this.db.prepare("SELECT 1 FROM aether_claims WHERE event_id=? AND user_id=? AND kind='sim-guild-final' AND claim_key=?").get(this.event.id, id, key))
                        continue;
                    const mail = 'aether-sim-guild-' + this.event.id + ':' + guild + ':' + id;
                    this.db.prepare('INSERT INTO player_mail VALUES(?,?,?,NULL,?)').run(id, mail, 'Thưởng hội Aether · MÔ PHỎNG LOCAL, theo hoạt động ghi trong mùa', JSON.stringify(cfg.reward));
                    this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'sim-guild-final',?,?,?)").run(this.event.id, id, key, JSON.stringify({ score, need: cfg.need, rewards: cfg.reward, mail, policy: simPolicy.version }), this.now());
                }
                this.db.exec('COMMIT');
            }
            catch (error) {
                this.db.exec('ROLLBACK');
                throw error;
            }
        }
    }
    claimed(id, kind) { return this.db.prepare('SELECT claim_key FROM aether_claims WHERE event_id=? AND user_id=? AND kind=? ORDER BY CAST(claim_key AS INTEGER)').all(this.event.id, id, kind).map(r => Number(r.claim_key)); }
    players(id) { const g = this.host.group(id), rows = this.db.prepare("SELECT m.user_id FROM alliance_members m WHERE m.alliance_id=? UNION SELECT user_id FROM aether_mercenaries WHERE event_id=? AND guild_id=? AND status='active'").all(g.guild_id, this.event.id, g.guild_id); return { ...this.war(id), player_info: rows.filter(r => r.user_id !== id && !this.pass(Number(r.user_id)).premium).map(r => ({ ...this.host.person(Number(r.user_id)), icon: this.host.person(Number(r.user_id)).role })) }; }
    boxes(id) {
        const group = this.host.group(id).group_id, day = this.host.day(), scope = group + ':' + day, s = simGet(this.db, this.event.id, 0, 'boxes', scope, { opened: {} }), records = {}, all = {};
        for (let i = 1; i <= 63; i++) {
            const kind = 1 + simRoll(this.event.id + ':box:' + scope, i, 4);
            if (s.opened[i])
                records[i] = s.opened[i];
            else {
                records[i] = { box_id: 0, got: 0, name: 'QA · Chưa mở', uid: '' };
                all[i] = [i, kind];
            }
        }
        return this.packet(id, { version: this.event.version, group_id: group, ass_id: String(this.host.group(id).guild_id), all_gift: all, reward_record: records });
    }
    execute(s, method, p) {
        const id = s.user_id, e = this.event.id, phase = this.host.phase();
        this.host.group(id);
        if (phase.ended || phase.step === 0)
            fail('Ngoài mùa mô phỏng.');
        let out;
        if (method === 'select_reward') {
            if (phase.step === 1)
                fail('Chưa mở rương trong Dự Cáo.');
            const gift = Number(p.get('gift_id'));
            if (!Number.isInteger(gift) || gift < 1 || gift > 63)
                fail('Ô rương không hợp lệ.');
            const group = this.host.group(id).group_id, day = this.host.day(), scope = group + ':' + day, boxes = simGet(this.db, e, 0, 'boxes', scope, { opened: {} });
            if (boxes.opened[gift])
                fail('Ô rương đã được người khác mở.');
            if (this.db.prepare("SELECT 1 FROM aether_claims WHERE event_id=? AND user_id=? AND kind='sim-box' AND claim_key=?").get(e, id, day))
                fail('Đã dùng lượt rương hôm nay.');
            const cfgId = 1 + simRoll(e + ':box:' + scope, gift, 4), cfg = aetherConfig('box')[cfgId], reward = simRewards(cfg.box_reward, e + ':gift:' + scope + ':' + gift, cfg.get_max), delivery = new AetherEconomy(this.db, e).grant(s, reward);
            boxes.opened[gift] = { box_id: cfgId, got: 1, name: this.host.person(id).name, uid: s.game_uid };
            simPut(this.db, e, 0, 'boxes', scope, boxes, this.now());
            this.db.prepare("INSERT INTO aether_claims VALUES(?,?,'sim-box',?,?,?)").run(e, id, day, JSON.stringify({ gift, cfgId, reward, policy: simPolicy.version }), this.now());
            out = { ...this.boxes(id), ...delivery };
        }
        else if (method === 'simulate_purchase') {
            const buy = Number(p.get('buy_id')), row = this.passRows().find(r => r.buy_id === buy && r.card_sort >= 2);
            if (!row)
                fail('Gói QA không thuộc Mật Lệnh của mùa này.');
            const card = this.pass(id);
            if (row.card_sort === 2) {
                if (card.premium)
                    fail('Mật Lệnh QA đã kích hoạt.');
                card.premium = true;
            }
            else {
                if (card.gifts + row.send_num > 30)
                    fail('Tín dụng tặng QA tối đa30, chưa cộng.');
                card.gifts += row.send_num;
            }
            simPut(this.db, e, id, 'pass', 'card', card, this.now());
            out = row.card_sort === 2 ? this.war(id) : this.players(id);
        }
        else if (method === 'send_war_card') {
            const target = Number(this.db.prepare('SELECT user_id FROM player_profiles WHERE game_uid=?').get(p.get('t_uid'))?.user_id ?? 0), a = this.host.group(id), b = this.host.group(target), card = this.pass(id), to = this.pass(target);
            if (id === target || a.guild_id !== b.guild_id || card.gifts < 1 || to.premium)
                fail('Người nhận hoặc số lượt tặng không hợp lệ.');
            card.gifts--;
            to.premium = true;
            simPut(this.db, e, id, 'pass', 'card', card, this.now());
            simPut(this.db, e, target, 'pass', 'card', to, this.now());
            out = this.players(id);
        }
        else if (method === 'get_war_reward' || method === 'auto_get_war_reward') {
            const type = Number(p.get('reward_type'));
            if (![0, 1].includes(type))
                fail('Loại thưởng Mật Lệnh không hợp lệ.');
            const state = this.war(id), kind = type === 0 ? 'war-free' : 'war-premium', row = this.passRows().find(r => r.card_sort === type + 1);
            if (type === 1 && !state.war_card)
                fail('Chưa kích hoạt Mật Lệnh QA.');
            const got = this.claimed(id, kind), ids = method === 'get_war_reward' ? [Number(p.get('reward_id'))] : Array.from({ length: state.score }, (_, i) => i + 1).filter(n => !got.includes(n)), rewards = [];
            if (!ids.length)
                fail('Không có mốc Mật Lệnh chưa nhận.');
            for (const n of ids) {
                if (!Number.isInteger(n) || n < 1 || n > state.score || got.includes(n) || !Array.isArray(row['level_' + n]))
                    fail('Mốc chưa đạt hoặc đã nhận.');
                rewards.push(...row['level_' + n]);
            }
            const delivery = rewards.length ? new AetherEconomy(this.db, e).grant(s, rewards) : { reward: {} };
            for (const n of ids)
                this.db.prepare('INSERT INTO aether_claims VALUES(?,?,?,?,?,?)').run(e, id, kind, String(n), JSON.stringify({ reward: row['level_' + n], policy: simPolicy.version }), this.now());
            out = { ...this.war(id), ...delivery };
        }
        else
            fail('Thao tác mô phỏng chưa có handler.');
        this.activity(id, method);
        return this.packet(id, out);
    }
}
