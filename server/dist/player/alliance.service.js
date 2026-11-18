import { assertAetherMembershipMutable } from './aether-lock.js';
import { contentReceipt } from './content-receipt.js';
import { phase36Config, phase36Source } from './phase36-source.js';
import { CombatPowerService } from './combat-power.js';
import { audit } from '../admin/admin.audit.js';
import { grantGodfieldReward } from './godfield-reward.js';
import { PlayerService } from './player.service.js';
import { ProgressionEconomyService } from './progression-economy.js';
function fail(message) { throw Object.assign(Error(message), { statusCode: 422 }); }
function positive(raw) { if (typeof raw !== 'string' || !/^\d{1,12}$/.test(raw) || Number(raw) < 1)
    fail('ID Liên Minh không hợp lệ.'); return Number(raw); }
// Profile phản chiếu quan hệ thật, không dùng association_id do client gửi lên.
export function allianceIdentity(db, userId) {
    const row = db.prepare('SELECT a.id,a.name,m.dedication FROM alliance_members m JOIN alliances a ON a.id=m.alliance_id WHERE m.user_id=? AND a.closed_at IS NULL').get(userId);
    return { association_id: Number(row?.id ?? 0), association_name: String(row?.name ?? ''), association_dedication: Number(row?.dedication ?? 0) };
}
export class AllianceService {
    db;
    now;
    constructor(db, now = () => Date.now()) {
        this.db = db;
        this.now = now;
    }
    member(id) { return this.db.prepare('SELECT * FROM alliance_members WHERE user_id=?').get(id); }
    profile(id) { const r = this.db.prepare('SELECT p.game_uid,p.role,s.profile FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id WHERE p.user_id=?').get(id); if (!r)
        fail('Nhân vật chưa sẵn sàng.'); return { ...JSON.parse(String(r.profile)), uid: String(r.game_uid), role: String(r.role) }; }
    eligible(id) { if (Number(this.profile(id).level) < phase36Source().rules.entryLevel)
        fail('Liên Minh mở từ cấp 10.'); }
    available(id) {
        this.eligible(id);
        if (this.member(id))
            fail('Bạn đã thuộc một Liên Minh.');
        const until = Number(this.db.prepare('SELECT until_at FROM alliance_cooldowns WHERE user_id=?').get(id)?.until_at ?? 0);
        if (until > this.now())
            fail('Bạn cần chờ ' + Math.ceil((until - this.now()) / 60000) + ' phút sau khi rời Liên Minh.');
    }
    guild(id) { const g = this.db.prepare('SELECT * FROM alliances WHERE id=? AND closed_at IS NULL').get(id); if (!g)
        fail('Liên Minh không còn tồn tại.'); return g; }
    room(id) { const g = this.guild(id), max = Number(phase36Config('guild_level')[g.level]?.member_num); if (!Number.isInteger(max) || max < 1)
        fail('Thiếu giới hạn thành viên của cấp hội.'); const count = Number(this.db.prepare('SELECT COUNT(*) n FROM alliance_members WHERE alliance_id=?').get(id).n); if (count >= max)
        fail('Liên Minh đã đủ thành viên.'); }
    actor(id, owner = false) { const m = this.member(id); if (!m)
        fail('Bạn chưa thuộc Liên Minh.'); if (owner ? m.role !== 'owner' : m.role === 'member')
        fail('Bạn không có quyền thực hiện thao tác này.'); return m; }
    target(uid) { const r = this.db.prepare('SELECT user_id FROM player_profiles WHERE game_uid=?').get(uid ?? ''); if (!r)
        fail('Người chơi không tồn tại.'); return Number(r.user_id); }
    remove(id) {
        assertAetherMembershipMutable(this.db, id, undefined, this.now());
        this.db.prepare('DELETE FROM alliance_members WHERE user_id=?').run(id);
        this.db.prepare('INSERT INTO alliance_cooldowns VALUES(?,?) ON CONFLICT(user_id) DO UPDATE SET until_at=excluded.until_at').run(id, this.now() + phase36Source().rules.rejoinCooldownSeconds * 1000);
    }
    donationDay() {
        const hour = phase36Source().rules.donation.resetHourVietnam;
        if (!Number.isInteger(hour) || hour < 0 || hour > 23)
            fail('Chưa xác minh giờ đặt lại cống hiến; chưa trừ tài nguyên.');
        return new Date(this.now() + (7 - hour) * 3600000).toISOString().slice(0, 10);
    }
    donationStatus(id) {
        const rules = phase36Source().rules.donation, hour = rules.resetHourVietnam;
        // Vẫn đọc hội được khi giờ reset còn SOURCE BLOCKED; giao dịch không được chạy.
        const day = Number.isInteger(hour) ? this.donationDay() : null;
        const log = day ? this.db.prepare('SELECT * FROM alliance_donation_days WHERE user_id=? AND day=?').get(id, day) : undefined;
        return { day, reset_hour: hour, goods_limit: Number(this.profile(id).level) * rules.resourcePerPlayerLevel, goods_log: Number(log?.goods ?? 0), war_flag_limit: rules.warFlagDailyLimit, war_flag_log: Number(log?.war_flags ?? 0), war_flag: Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(id, rules.warFlagItem)?.quantity ?? 0), dedication: Number(this.member(id)?.dedication ?? 0) };
    }
    donate(id, p, gid) {
        const flag = p.get('flag') ?? p.get('type'), raw = p.get('amount');
        if (p.has('flag') && p.has('type') && p.get('flag') !== p.get('type'))
            fail('Loại cống hiến không nhất quán.');
        if (!['food', 'metal', 'energy', 'war_flag'].includes(flag ?? '') || !raw || !/^\d{1,9}$/.test(raw) || Number(raw) < 1)
            fail('Loại hoặc số lượng cống hiến không hợp lệ.');
        const amount = Number(raw), day = this.donationDay(), status = this.donationStatus(id), rules = phase36Source().rules.donation, profile = this.profile(id), member = this.member(id), g = this.guild(gid);
        let points, goods;
        if (flag === 'war_flag') {
            if (status.war_flag_log + amount > status.war_flag_limit)
                fail('Vượt giới hạn Cờ chiến trong ngày.');
            if (status.war_flag < amount)
                fail('Không đủ Cờ chiến #18; Thư khiêu chiến lôi đài #80000 không dùng thay được.');
            points = amount * rules.warFlagPoints;
            goods = amount * rules.warFlagGoods;
        }
        else {
            if (amount % rules.resourcePerPoint !== 0)
                fail('LOCAL chỉ nhận bội số 10 tài nguyên để tránh mất phần dư chưa rõ quy tắc gốc.');
            if (status.goods_log + amount > status.goods_limit)
                fail('Vượt trần cống hiến tài nguyên theo cấp nhân vật trong ngày.');
            if (!Number.isSafeInteger(profile[flag] ?? 0) || (profile[flag] ?? 0) < amount)
                fail('Không đủ tài nguyên để cống hiến.');
            points = goods = amount / rules.resourcePerPoint;
        }
        if (![Number(member.dedication) + points, Number(g.goods) + goods, Number(g.war_flag) + (flag === 'war_flag' ? amount : 0)].every(Number.isSafeInteger))
            fail('Số dư Liên Minh vượt giới hạn biểu diễn.');
        if (flag === 'war_flag') {
            this.db.prepare('UPDATE player_items SET quantity=quantity-? WHERE user_id=? AND config_id=?').run(amount, id, rules.warFlagItem);
            this.db.prepare('DELETE FROM player_items WHERE user_id=? AND config_id=? AND quantity=0').run(id, rules.warFlagItem);
            this.db.prepare('UPDATE alliances SET war_flag=war_flag+? WHERE id=?').run(amount, gid);
        }
        else
            this.db.prepare('UPDATE player_state SET profile=json_set(profile,?,?) WHERE user_id=?').run('$.' + flag, profile[flag] - amount, id);
        this.db.prepare('UPDATE alliances SET goods=goods+? WHERE id=?').run(goods, gid);
        this.db.prepare('UPDATE alliance_members SET dedication=dedication+? WHERE user_id=?').run(points, id);
        this.db.prepare('INSERT INTO alliance_donation_days VALUES(?,?,?,?) ON CONFLICT(user_id,day) DO UPDATE SET goods=goods+excluded.goods,war_flags=war_flags+excluded.war_flags').run(id, day, flag === 'war_flag' ? 0 : amount, flag === 'war_flag' ? amount : 0);
    }
    levelup(id, p, gid) {
        this.actor(id);
        const flag = p.get('flag');
        if (flag !== 'guild' && flag !== 'shop')
            fail('Khoa kỹ chiến đấu này chưa nối hiệu ứng; chưa tiêu vật tư.');
        const g = this.guild(gid), field = flag === 'guild' ? 'level' : 'shop_level', current = Number(g[field]), table = phase36Config(flag === 'guild' ? 'guild_level' : 'guild_shop'), cost = Number(table[current]?.cost);
        if (!table[current + 1])
            fail('Khoa kỹ đã đạt cấp tối đa trong nguồn.');
        if (!Number.isSafeInteger(cost) || cost < 0)
            fail('Thiếu giá nâng khoa kỹ đã xác minh.');
        if (Number(g.goods) < cost)
            fail('Không đủ vật tư Liên Minh để nâng cấp.');
        this.db.prepare('UPDATE alliances SET ' + field + '=?,goods=goods-? WHERE id=?').run(current + 1, cost, gid);
    }
    messages(gid) { return this.db.prepare('SELECT m.body,m.created_at,json_extract(s.profile,\'$.show_name\') name FROM alliance_messages m JOIN player_state s ON s.user_id=m.user_id WHERE m.alliance_id=? ORDER BY m.id DESC LIMIT 100').all(gid).reverse().map(r => ({ name: r.name, text: r.body, time: new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh', dateStyle: 'short', timeStyle: 'short' }).format(Number(r.created_at)) })); }
    shop(id) {
        const member = this.member(id);
        if (!member)
            fail('Bạn chưa thuộc Liên Minh.');
        const guild = this.guild(Number(member.alliance_id)), level = Number(this.profile(id).level);
        const shop = Object.entries(phase36Config('guild_shop_item')).map(([key, c]) => {
            const period = c.refresh === 0 ? 'once' : 'SOURCE_BLOCKED', bought = Number(this.db.prepare('SELECT quantity FROM alliance_purchases WHERE user_id=? AND offer_id=? AND period=?').get(id, Number(key), period)?.quantity ?? 0);
            const supported = c.refresh === 0 && c.shop_reward.every((r) => [5, 6, 7].includes(r[0]));
            const eligible = level >= c.show_level[0] && level <= c.show_level[1];
            return { ...c, id: Number(key), need_shoplevel: c.need_shoplevel, shop_reward: c.shop_reward, remain_amount: supported && eligible ? Math.max(0, c.times - bought) : 0, total_num: c.times, refresh_time: 0, need_gongxian: c.need_gongxian, source_status: supported ? 'SOURCE_VERIFIED' : 'SOURCE_BLOCKED', blocked_reason: !supported ? 'Chưa có quy tắc reset/loại thưởng đủ nguồn.' : !eligible ? 'Ngoài khoảng cấp nguồn.' : null };
        });
        return { shop, shop_lv: guild.shop_level, dedication: member.dedication };
    }
    list(id, name = '') {
        this.eligible(id);
        if (name.length > 80)
            fail('Tên tìm kiếm quá dài.');
        const guild_list = this.db.prepare('SELECT * FROM alliances WHERE closed_at IS NULL ORDER BY level DESC,id').all().filter(g => String(g.name).toLocaleLowerCase('vi').includes(name.toLocaleLowerCase('vi'))).map(g => {
            const members = this.db.prepare('SELECT user_id,role FROM alliance_members WHERE alliance_id=? ORDER BY user_id').all(g.id), owner = members.find(m => m.role === 'owner');
            return { id: Number(g.id), name: String(g.name), lv: Number(g.level), player_count: members.length, player_max: Number(phase36Config('guild_level')[String(g.level)]?.member_num ?? 0), owner: owner ? this.profile(Number(owner.user_id)).show_name : '', gvg_land: 0, tech_lv: 0 };
        });
        return { guild_list, guilds: guild_list, ...allianceIdentity(this.db, id) };
    }
    detail(id, guildId) {
        this.eligible(id);
        const g = this.guild(guildId), mine = this.member(id), same = mine?.alliance_id === guildId;
        const rows = this.db.prepare('SELECT * FROM alliance_members WHERE alliance_id=? ORDER BY dedication DESC,user_id').all(guildId), player = {};
        rows.forEach((m, index) => { const p = this.profile(Number(m.user_id)); player[p.uid] = { uid: p.uid, name: p.show_name, level: Number(p.level), vip: Number(p.vip ?? 0), role: p.role, title: m.role, combat: new CombatPowerService(this.db).calculate(Number(m.user_id)).combat, dedication: m.dedication, dedication_rank: index + 1, arena_rank: Number(this.db.prepare('SELECT rank FROM arena_positions WHERE user_id=?').get(m.user_id)?.rank ?? 0), online: this.db.prepare('SELECT 1 FROM sessions WHERE user_id=? AND expires_at>? LIMIT 1').get(m.user_id, this.now()) ? 1 : 0 }; });
        const owner = rows.find(m => m.role === 'owner'), waiter = same && mine?.role !== 'member' ? this.db.prepare('SELECT * FROM alliance_applications WHERE alliance_id=? ORDER BY created_at,user_id').all(guildId).map(r => { const p = this.profile(Number(r.user_id)); return { uid: p.uid, name: p.show_name, level: Number(p.level), vip: Number(p.vip ?? 0), arena_rank: Number(this.db.prepare('SELECT rank FROM arena_positions WHERE user_id=?').get(r.user_id)?.rank ?? 0), regist_time: new Date(Number(r.created_at)).toISOString().slice(0, 10), active_day: 0 }; }) : [];
        return { guild: { g_id: guildId, id: guildId, name: g.name, guild_lv: g.level, guild_level: { lv: g.level }, owner: this.profile(Number(owner.user_id)).uid, vp: rows.filter(m => m.role === 'vp').map(m => this.profile(Number(m.user_id)).uid), player: rows.map(m => this.profile(Number(m.user_id)).uid), waiter, goods: g.goods, war_flag: g.war_flag, level: { guild: g.level, shop: g.shop_level, gvg_player: 0, gvg_monster: 0, gvg_home: 0, map: 0, boss: 0 }, shop_lv: g.shop_level, map_lv: 0, boss_lv: 0, gvg_player_lv: 0, gvg_monster_lv: 0, gvg_home_lv: 0 }, player, guild_notice: g.notice, guild_msg: same ? this.messages(guildId) : [], user_data: same ? this.donationStatus(id) : { dedication: 0 }, ...allianceIdentity(this.db, id) };
    }
    read(id, method, p) {
        if (method === 'association.shop')
            return this.shop(id);
        if (method === 'association.flush_msg') {
            const m = this.member(id);
            if (!m)
                fail('Bạn chưa thuộc Liên Minh.');
            return { player_msg: this.messages(Number(m.alliance_id)) };
        }
        if (method === 'association.guild_all' || method === 'association.guild_search')
            return this.list(id, p.get('name') ?? '');
        if (method === 'association.guild_detail' || method === 'association.guild_one')
            return this.detail(id, positive(p.get('guild_id') ?? p.get('ass_id') ?? String(this.member(id)?.alliance_id ?? 0)));
        fail('Chức năng Liên Minh này đang khôi phục; chưa thay đổi tài nguyên.');
    }
    execute(s, method, p) {
        const allowed = ['guild_create', 'guild_join', 'guild_agree', 'guild_not_agree', 'guild_quit', 'guild_destroy', 'appoint_player', 'remove_player', 'add_notice', 'dedicate', 'levelup', 'buy_commodity', 'add_msg'].map(k => 'association.' + k);
        if (!allowed.includes(method))
            fail('Chức năng Liên Minh này chưa đủ quy tắc nguồn; chưa trừ tài nguyên hoặc phát thưởng.');
        const body = Object.fromEntries([...p.entries()].filter(([k]) => !['request_id', 'user_token', 'mk', 'rans', 'account'].includes(k)).sort(([a], [b]) => a.localeCompare(b)));
        return contentReceipt(this.db, s.user_id, method, p.get('request_id'), body, () => {
            this.eligible(s.user_id);
            let gid, delivery = {};
            if (method === 'association.guild_create') {
                this.available(s.user_id);
                const name = (p.get('name') ?? '').normalize('NFC').trim();
                if (!/^[\p{L}\p{N} _-]{1,24}$/u.test(name))
                    fail('Tên Liên Minh gồm 1–24 chữ, số, khoảng trắng, _ hoặc -.');
                if (this.db.prepare('SELECT 1 FROM alliances WHERE name=? COLLATE NOCASE').get(name))
                    fail('Tên Liên Minh đã được sử dụng.');
                const profile = this.profile(s.user_id), cost = phase36Source().rules.creationFood;
                if (!Number.isSafeInteger(profile.food) || profile.food < cost)
                    fail('Cần 20.000 Thức ăn để tạo Liên Minh.');
                // Chỉ ghi số dư, giữ toàn bộ thuộc tính hồ sơ khác.
                this.db.prepare("UPDATE player_state SET profile=json_set(profile,'$.food',?) WHERE user_id=?").run(profile.food - cost, s.user_id);
                gid = Number(this.db.prepare('INSERT INTO alliances(name,icon,level,created_at) VALUES(?,?,?,?)').run(name, '1', phase36Source().rules.initialGuildLevel, this.now()).lastInsertRowid);
                this.db.prepare("INSERT INTO alliance_members(user_id,alliance_id,role,joined_at) VALUES(?,?,'owner',?)").run(s.user_id, gid, this.now());
                this.db.prepare('DELETE FROM alliance_applications WHERE user_id=?').run(s.user_id);
            }
            else if (method === 'association.guild_join') {
                this.available(s.user_id);
                gid = positive(p.get('guild_id'));
                assertAetherMembershipMutable(this.db, s.user_id, gid, this.now());
                this.room(gid);
                this.db.prepare('INSERT INTO alliance_applications VALUES(?,?,?) ON CONFLICT DO NOTHING').run(gid, s.user_id, this.now());
            }
            else {
                const mine = this.member(s.user_id);
                if (!mine)
                    fail('Bạn chưa thuộc Liên Minh.');
                gid = Number(mine.alliance_id);
                if (method === 'association.guild_agree' || method === 'association.guild_not_agree') {
                    this.actor(s.user_id);
                    const target = this.target(p.get('user_id'));
                    if (!this.db.prepare('SELECT 1 FROM alliance_applications WHERE alliance_id=? AND user_id=?').get(gid, target))
                        fail('Đơn xin gia nhập không còn hợp lệ.');
                    if (method === 'association.guild_agree') {
                        this.available(target);
                        assertAetherMembershipMutable(this.db, target, gid, this.now());
                        this.room(gid);
                        this.db.prepare("INSERT INTO alliance_members(user_id,alliance_id,role,joined_at) VALUES(?,?,'member',?)").run(target, gid, this.now());
                        this.db.prepare('DELETE FROM alliance_applications WHERE user_id=?').run(target);
                    }
                    else
                        this.db.prepare('DELETE FROM alliance_applications WHERE alliance_id=? AND user_id=?').run(gid, target);
                }
                else if (method === 'association.guild_quit') {
                    if (mine.role === 'owner')
                        fail('Hội trưởng cần chuyển chức trước khi rời, hoặc giải tán khi hội chỉ còn một người.');
                    this.remove(s.user_id);
                }
                else if (method === 'association.guild_destroy') {
                    assertAetherMembershipMutable(this.db, s.user_id, gid, this.now());
                    this.actor(s.user_id, true);
                    if (Number(this.db.prepare('SELECT COUNT(*) n FROM alliance_members WHERE alliance_id=?').get(gid).n) !== 1)
                        fail('Chỉ có thể giải tán khi Liên Minh không còn thành viên khác.');
                    this.remove(s.user_id);
                    this.db.prepare('DELETE FROM alliance_applications WHERE alliance_id=?').run(gid);
                    this.db.prepare('UPDATE alliances SET closed_at=? WHERE id=?').run(this.now(), gid);
                }
                else if (method === 'association.buy_commodity') {
                    const offer = this.shop(s.user_id).shop.find(r => r.id === positive(p.get('commodity_id')));
                    if (!offer)
                        fail('Vật phẩm đổi không tồn tại.');
                    if (offer.source_status !== 'SOURCE_VERIFIED')
                        fail('Chưa có quy tắc reset/thưởng của hàng này; chưa trừ điểm.');
                    if (this.guild(gid).shop_level < offer.need_shoplevel)
                        fail('Cấp cửa hàng chưa đủ.');
                    if (offer.remain_amount < 1)
                        fail('Đã hết lượt mua hoặc ngoài cấp nguồn.');
                    if (Number(mine.dedication) < offer.need_gongxian)
                        fail('Không đủ cống hiến cá nhân.');
                    delivery = grantGodfieldReward(this.db, s, offer.shop_reward);
                    this.db.prepare('UPDATE alliance_members SET dedication=dedication-? WHERE user_id=?').run(offer.need_gongxian, s.user_id);
                    this.db.prepare("INSERT INTO alliance_purchases VALUES(?,?,'once',1) ON CONFLICT(user_id,offer_id,period) DO UPDATE SET quantity=quantity+1").run(s.user_id, offer.id);
                    delivery = { ...delivery, association_buy_commodity: delivery.reward, shop: this.shop(s.user_id) };
                }
                else if (method === 'association.add_msg') {
                    const body = (p.get('msg') ?? '').trim();
                    if (!body || [...body].length > 500 || /[\x00-\x1f]/.test(body))
                        fail('Lời nhắn gồm 1–500 ký tự hợp lệ.');
                    this.db.prepare('INSERT INTO alliance_messages(alliance_id,user_id,body,created_at) VALUES(?,?,?,?)').run(gid, s.user_id, body, this.now());
                    delivery = { player_msg: this.messages(gid) };
                }
                else if (method === 'association.dedicate') {
                    this.donate(s.user_id, p, gid);
                }
                else if (method === 'association.levelup') {
                    this.levelup(s.user_id, p, gid);
                }
                else if (method === 'association.add_notice') {
                    this.actor(s.user_id);
                    const notice = p.get('notice') ?? '';
                    if ([...notice].length > 500 || /[\x00-\x08\x0b-\x1f]/.test(notice))
                        fail('Thông báo tối đa 500 ký tự hợp lệ.');
                    this.db.prepare('UPDATE alliances SET notice=? WHERE id=?').run(notice, gid);
                }
                else {
                    this.actor(s.user_id, true);
                    const target = this.target(p.get('user_id')), m = this.member(target);
                    if (!m || m.alliance_id !== gid || target === s.user_id)
                        fail('Chỉ có thể quản lý thành viên khác trong chính Liên Minh.');
                    if (method === 'association.remove_player')
                        this.remove(target);
                    else {
                        const pos = p.get('position');
                        if (!['0', '1', '2'].includes(pos ?? ''))
                            fail('Chức vụ không hợp lệ.');
                        if (pos === '2' && m.role !== 'vp' && Number(this.db.prepare("SELECT COUNT(*) n FROM alliance_members WHERE alliance_id=? AND role='vp'").get(gid).n) >= phase36Source().rules.maxViceOwners)
                            fail('Liên Minh tối đa hai hội phó.');
                        if (pos === '1')
                            this.db.prepare("UPDATE alliance_members SET role='member' WHERE user_id=?").run(s.user_id);
                        this.db.prepare('UPDATE alliance_members SET role=? WHERE user_id=?').run(pos === '1' ? 'owner' : pos === '2' ? 'vp' : 'member', target);
                    }
                }
            }
            audit(this.db, null, method, s.user_id, 'Liên Minh LOCAL · quyền thành viên và transaction', { allianceId: gid }, { requestKey: p.get('request_id'), target: p.get('user_id') });
            return { ...(this.member(s.user_id) ? { ...this.detail(s.user_id, Number(this.member(s.user_id).alliance_id)), ...this.list(s.user_id) } : { ...this.list(s.user_id), application_submitted: method === 'association.guild_join' }), ...delivery };
        }, old => { const { _client_cache_update: discard, ...rest } = old, packet = new ProgressionEconomyService(this.db).packet(s, { ...rest, ...((this.member(s.user_id)) ? this.detail(s.user_id, Number(this.member(s.user_id).alliance_id)) : this.list(s.user_id)), reward: {}, association_buy_commodity: {}, ...(this.member(s.user_id) ? { shop: this.shop(s.user_id) } : {}), replayed: true }); packet._client_cache_update.equip = { _equip: { update: new PlayerService(this.db).cards(s).equip, remove: [] } }; return packet; });
    }
    diagnostics(id) { return { scope: 'LOCAL · Liên Minh', identity: allianceIdentity(this.db, id), donation: this.donationStatus(id), directory: this.list(id), shop: this.member(id) ? this.shop(id) : null, detail: this.member(id) ? this.detail(id, Number(this.member(id).alliance_id)) : null, cooldownUntil: Number(this.db.prepare('SELECT until_at FROM alliance_cooldowns WHERE user_id=?').get(id)?.until_at ?? 0), rules: phase36Source().rules, userConfirmedRules: phase36Source().userConfirmedRules, history: this.db.prepare("SELECT action,created_at,summary FROM admin_audit WHERE target_user_id=? AND action LIKE 'association.%' ORDER BY id DESC LIMIT 50").all(id), limitations: ['Cấp khởi đầu 1 và chờ 1 giờ: user xác nhận; chưa có thuật toán server gốc.', 'Đã nối hàng không reset (refresh=0); hàng reset chưa rõ kỳ, khoa kỹ chiến đấu/boss/chiến minh còn khóa.', 'Tài nguyên chỉ nhận bội số10; chưa biết quy tắc phần dư của server gốc.'] }; }
}
