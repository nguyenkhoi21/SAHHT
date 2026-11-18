import { staticConfig } from '../player/player.service.js';
import { WelfareService } from '../player/welfare.service.js';
import { audit } from '../admin/admin.audit.js';
import { WelfareRepository } from './welfare.repository.js';
import { sourceDefinition, validateDefinition } from './welfare-source.js';
import { welfareDay, welfareFail, welfarePolicy, welfareLengths, welfareKinds, positiveId } from './welfare-contracts.js';
const realm = 'local-1', DAY = 86400000;
export class WelfareLocalService {
    db;
    now;
    online;
    repo;
    constructor(db, now = Date.now, online = false) {
        this.db = db;
        this.now = now;
        this.online = online;
        this.repo = new WelfareRepository(db);
    }
    player(id) { if (!this.db.prepare('SELECT 1 FROM player_state WHERE user_id=?').get(id))
        welfareFail('Chọn người chơi LOCAL đã khởi tạo.'); }
    at(id) { return this.now() + (this.online ? 0 : Number(this.db.prepare('SELECT clock_offset FROM welfare_qa_players WHERE user_id=?').get(id)?.clock_offset ?? 0)); }
    active(kind, at, configId) {
        const row = configId ? this.db.prepare("SELECT * FROM welfare_configs WHERE id=? AND realm=? AND kind=? AND status='published'").get(configId, realm, kind) : this.db.prepare("SELECT * FROM welfare_configs WHERE realm=? AND kind=? AND status='published' AND json_extract(definition,'$.starts')<=? AND json_extract(definition,'$.ends')>? ORDER BY id DESC LIMIT 1").get(realm, kind, at, at);
        if (configId && !row)
            welfareFail('Cấu hình chưa xuất bản hoặc không thuộc hệ thống này.');
        if (row) {
            const definition = JSON.parse(String(row.definition));
            if (at < definition.starts || at >= definition.ends)
                welfareFail('Cấu hình chưa bắt đầu hoặc đã kết thúc.');
            return { id: Number(row.id), definition };
        }
        return { id: null, definition: sourceDefinition(kind) };
    }
    attendance(id, at, observe) {
        let row = this.db.prepare('SELECT * FROM welfare_attendance WHERE user_id=? AND realm=?').get(id, realm);
        const today = welfareDay(at);
        if (!row && observe) {
            const cfg = this.active('daily', at).definition;
            this.db.prepare('INSERT INTO welfare_attendance VALUES(?,?,1,1,?,?)').run(id, realm, today, JSON.stringify(cfg));
            row = this.db.prepare('SELECT * FROM welfare_attendance WHERE user_id=? AND realm=?').get(id, realm);
        }
        if (row && observe && today > row.last_day) {
            const all = Number(this.db.prepare("SELECT COUNT(*) n FROM welfare_claims WHERE user_id=? AND realm=? AND kind='daily' AND scope=?").get(id, realm, 'cycle-' + row.cycle).n) === 25;
            const nextCycle = row.score === 25 && all;
            const next = nextCycle ? this.active('daily', at) : undefined;
            const snapshot = nextCycle ? (next.id === null ? sourceDefinition('daily', 1, true) : next.definition) : JSON.parse(row.snapshot);
            this.db.prepare('UPDATE welfare_attendance SET cycle=?,score=?,last_day=?,snapshot=? WHERE user_id=? AND realm=?').run(Number(row.cycle) + (nextCycle ? 1 : 0), nextCycle ? 1 : Math.min(25, Number(row.score) + 1), today, JSON.stringify(snapshot), id, realm);
            row = this.db.prepare('SELECT * FROM welfare_attendance WHERE user_id=? AND realm=?').get(id, realm);
        }
        return row;
    }
    dailyState(id, at, observe) {
        const row = this.attendance(id, at, observe), cycle = Number(row?.cycle ?? 1), score = Number(row?.score ?? 0), current = this.active('daily', at);
        const receipts = this.db.prepare("SELECT day,rewards FROM welfare_claims WHERE user_id=? AND realm=? AND kind='daily' AND scope=?").all(id, realm, 'cycle-' + cycle);
        const claims = receipts.map(x => Number(x.day));
        const definition = current.id === null && cycle > 1 ? sourceDefinition('daily', 1, true) : structuredClone(current.definition);
        // Quà chưa nhận theo lịch đang chạy; receipt đã commit luôn giữ quà cũ.
        for (const receipt of receipts)
            definition.rows[Number(receipt.day) - 1].rewards = JSON.parse(String(receipt.rewards));
        return { score, reward: definition.rows.filter((r) => r.day <= score && !claims.includes(r.day)).map((r) => String(r.day)), daily_award_loop: cycle > 1, cycle, claimed: claims, definition, active_config_id: current.id,
            daily_config: Object.fromEntries(definition.rows.map((r) => [String(r.day), { award: r.rewards, icon: 'icon_daily_reward' }])), coin_days: 0, coin_status: 0, coin_pay_rmb: 0, coin_award_loop: false, coin_award_loop_reriod: 0, recharge_blocked: true, server_day: welfareDay(at), welfare_time: Math.floor(at / 1000), policy: welfarePolicy };
    }
    daily(s) { this.player(s.user_id); return this.repo.transaction(() => this.dailyState(s.user_id, this.at(s.user_id), true)); }
    entitlement(id, kind, at) { return this.db.prepare('SELECT * FROM welfare_entitlements WHERE user_id=? AND realm=? AND kind=? AND starts<=? ORDER BY created_at DESC,id DESC LIMIT 1').get(id, realm, kind, at); }
    cardState(id, kind, at) {
        const e = this.entitlement(id, kind, at), cfg = e ? JSON.parse(e.snapshot) : this.active(kind, at).definition;
        const claims = e ? this.db.prepare('SELECT day,server_day FROM welfare_claims WHERE user_id=? AND realm=? AND kind=? AND scope=? ORDER BY day').all(id, realm, kind, e.id) : [];
        const days = claims.length, active = !!e && e.revoked_at === null && at < e.ends && days < cfg.rows.length, claimedToday = claims.some(c => c.server_day === welfareDay(at));
        return { pay_dt: active ? String(e.starts) : '', award_day: claimedToday ? welfareDay(at) : '', days, version: cfg.sourceVersion,
            reward: Object.fromEntries(cfg.rows.map((r) => [String(r.day), kind === 'month' ? { award: r.rewards } : { reward: r.rewards }])),
            active, expired: !!e && at >= e.ends, starts: e?.starts ?? null, ends: e?.ends ?? null, remaining_days: e ? Math.max(0, Math.ceil((Number(e.ends) - at) / DAY)) : 0,
            claimable: active && !claimedToday, entitlement_id: e?.id ?? null, definition: cfg, welfare_time: Math.floor(at / 1000), server_day: welfareDay(at), claimed_days: claims.map(c => Number(c.day)) };
    }
    cards(s) { this.player(s.user_id); const at = this.at(s.user_id); return { month_award: this.cardState(s.user_id, 'month', at), quarter_award: this.cardState(s.user_id, 'quarter', at), policy: welfarePolicy }; }
    purchaseAvailability(id, kind) {
        this.player(id);
        const at = this.at(id), existing = this.entitlement(id, kind, at);
        const source = this.active(kind, at);
        return { supported: !(existing && existing.revoked_at === null && Number(existing.ends) > at), blockedReason: existing && existing.revoked_at === null && Number(existing.ends) > at ? 'Thẻ còn hiệu lực; chưa hỗ trợ mua cộng dồn.' : '', definition: source.definition };
    }
    purchaseInTransaction(id, kind, transactionId) {
        if (!this.db.isTransaction)
            throw Error('Mua thẻ cần cùng transaction trừ vé.');
        const available = this.purchaseAvailability(id, kind);
        if (!available.supported)
            welfareFail(available.blockedReason);
        const at = this.at(id), cfg = this.active(kind, at), entitlementId = 'recharge-' + transactionId;
        this.db.prepare('INSERT INTO welfare_entitlements(id,user_id,realm,kind,config_id,starts,ends,snapshot,created_at) VALUES(?,?,?,?,?,?,?,?,?)').run(entitlementId, id, realm, kind, cfg.id, at, Math.min(cfg.definition.ends, at + welfareLengths[kind] * DAY), JSON.stringify(cfg.definition), this.now());
        audit(this.db, null, 'welfare.purchase', id, 'Mua quyền lợi Phúc Lợi bằng gói nạp LOCAL; nhận quà trong Phúc Lợi', null, { kind, transactionId, entitlementId, configId: cfg.id }, this.now());
    }
    async claim(s, kind, dayValue, requestId) {
        this.player(s.user_id);
        if (!welfareKinds.includes(kind))
            welfareFail('Hệ thống không hợp lệ.');
        const definitions = { heroes: await staticConfig('character_detail'), items: await staticConfig('item'), equipment: await staticConfig('equip') };
        const outcome = this.repo.operation(`player:${realm}:${s.user_id}`, requestId, { kind, day: kind === 'daily' ? String(dayValue) : null }, this.now(), () => {
            const at = this.at(s.user_id);
            let day, scope, rewards;
            if (kind === 'daily') {
                const d = this.dailyState(s.user_id, at, true);
                day = Number(dayValue);
                if (!Number.isSafeInteger(day) || day < 1 || day > 25 || day > d.score)
                    welfareFail('Mốc Điểm danh chưa đến hoặc không hợp lệ.');
                if (!d.reward.includes(String(day)))
                    welfareFail('Bạn đã nhận mốc này.');
                scope = 'cycle-' + d.cycle;
                rewards = d.definition.rows[day - 1].rewards;
            }
            else {
                const c = this.cardState(s.user_id, kind, at);
                if (!c.active)
                    welfareFail(c.expired ? 'Thẻ đã hết hạn.' : 'Thẻ chưa kích hoạt hoặc đã nhận đủ.');
                if (!c.claimable)
                    welfareFail('Hôm nay đã nhận quà thẻ này.');
                day = c.days + 1;
                scope = c.entitlement_id;
                rewards = c.definition.rows[day - 1].rewards;
            }
            const result = new WelfareService(this.db, () => at).applyInTransaction(s, rewards, definitions);
            this.db.prepare('INSERT INTO welfare_claims(user_id,realm,kind,scope,day,server_day,rewards,claimed_at) VALUES(?,?,?,?,?,?,?,?)').run(s.user_id, realm, kind, scope, day, welfareDay(at), JSON.stringify(rewards), this.now());
            audit(this.db, null, 'welfare.claim', s.user_id, 'Nhận Phúc Lợi LOCAL; cấp thưởng và biên nhận cùng transaction', null, { kind, scope, day, rewards, serverDay: welfareDay(at) }, this.now());
            return { ...(kind === 'daily' ? { daily_state: this.dailyState(s.user_id, at, false) } : this.cards(s)), ...result, claimed_day: day };
        });
        if (outcome.replayed)
            return { ...(kind === 'daily' ? { daily_state: this.dailyState(s.user_id, this.at(s.user_id), false) } : this.cards(s)), claimed_day: outcome.claimed_day, reward: [], replayed: true };
        return outcome;
    }
    trashed(id) { return this.db.prepare("SELECT action FROM admin_audit WHERE action IN('welfare.config.trash','welfare.config.restore') AND json_extract(after_state,'$.configId')=? AND json_extract(after_state,'$.realm')=? ORDER BY id DESC LIMIT 1").get(id, realm)?.action === 'welfare.config.trash'; }
    list() { const at = this.now(); return { serverTime: at, configs: this.db.prepare('SELECT * FROM welfare_configs WHERE realm=? ORDER BY id DESC').all(realm).map(r => { const definition = JSON.parse(String(r.definition)), deleted = this.trashed(Number(r.id)); return { ...r, id: Number(r.id), revision: Number(r.revision), status: String(r.status), definition, deleted, state: deleted ? 'trash' : r.status === 'draft' ? 'draft' : r.status === 'ended' ? 'stopped' : at < definition.starts ? 'scheduled' : at >= definition.ends ? 'expired' : 'running' }; }), sources: welfareKinds.map(k => this.active(k, at)), templates: [sourceDefinition('daily'), sourceDefinition('month'), ...[1, 2, 3].map(v => sourceDefinition('quarter', v))], policy: welfarePolicy }; }
    save(admin, b) {
        const definition = validateDefinition(b.definition), at = this.now();
        return this.repo.operation('admin:' + admin, b.requestId, b, at, () => {
            const old = b.id ? this.db.prepare('SELECT * FROM welfare_configs WHERE id=? AND realm=?').get(positiveId(b.id), realm) : undefined;
            if (b.id && !old)
                welfareFail('Cấu hình không tồn tại.');
            if (old && (this.trashed(Number(old.id)) || old.status !== 'draft' || old.revision !== b.revision || old.kind !== definition.kind))
                welfareFail('Bản đã đổi, khác hệ thống hoặc đã xuất bản. Hãy nhân bản bản nháp mới.', 409);
            let id = Number(b.id);
            if (old)
                this.db.prepare('UPDATE welfare_configs SET definition=?,revision=revision+1,updated_at=? WHERE id=?').run(JSON.stringify(definition), at, id);
            else
                id = Number(this.db.prepare("INSERT INTO welfare_configs(kind,realm,revision,status,definition,created_at,updated_at) VALUES(?,?,1,'draft',?,?,?)").run(definition.kind, realm, JSON.stringify(definition), at, at).lastInsertRowid);
            audit(this.db, admin, 'welfare.config.save', null, 'Lưu bản nháp Phúc Lợi LOCAL', old, { id, definition }, at);
            return { id, revision: old ? Number(old.revision) + 1 : 1 };
        });
    }
    publish(admin, b) {
        return this.repo.operation('admin:' + admin, b.requestId, b, this.now(), () => {
            const old = this.db.prepare('SELECT * FROM welfare_configs WHERE id=? AND realm=?').get(positiveId(b.id), realm);
            if (!old || old.revision !== b.revision)
                welfareFail('Cấu hình đã đổi; tải lại trước khi xuất bản.', 409);
            const d = validateDefinition(JSON.parse(String(old.definition)));
            if (this.trashed(Number(old.id)) || old.status !== 'draft')
                welfareFail('Chỉ xuất bản bản nháp.');
            const overlap = this.db.prepare("SELECT 1 FROM welfare_configs WHERE realm=? AND kind=? AND status='published' AND json_extract(definition,'$.starts')<? AND json_extract(definition,'$.ends')>? LIMIT 1").get(realm, d.kind, d.ends, d.starts);
            if (overlap)
                welfareFail('Lịch trùng với cấu hình đã xuất bản. Hãy chọn khoảng khác.');
            this.db.prepare("UPDATE welfare_configs SET status='published',revision=revision+1,updated_at=? WHERE id=?").run(this.now(), b.id);
            audit(this.db, admin, 'welfare.config.publish', null, 'Xuất bản lịch; Điểm danh chưa nhận theo lịch mới, quyền lợi thẻ đã cấp được giữ', old, { id: b.id }, this.now());
            return { id: b.id, revision: b.revision + 1 };
        });
    }
    manage(admin, b) {
        return this.repo.operation('admin:' + admin, b.requestId, b, this.now(), () => {
            const old = this.db.prepare('SELECT * FROM welfare_configs WHERE id=? AND realm=?').get(positiveId(b.id), realm);
            if (!old || old.revision !== b.revision)
                welfareFail('Cấu hình đã thay đổi. Tải lại trước khi thao tác.', 409);
            const deleted = this.trashed(Number(old.id)), at = this.now();
            let d = validateDefinition(JSON.parse(String(old.definition))), status = String(old.status);
            if (b.action === 'restore') {
                if (!deleted)
                    welfareFail('Cấu hình không nằm trong thùng rác.');
                status = 'draft';
            }
            else {
                if (deleted)
                    welfareFail('Hãy khôi phục cấu hình trước khi sử dụng.');
                if (b.action === 'trash') {
                    if (status === 'published')
                        welfareFail('Ngừng lịch trước khi xóa để không đổi game ngoài ý muốn.');
                    status = 'ended';
                }
                else if (b.action === 'stop') {
                    if (status !== 'published')
                        welfareFail('Lịch này chưa được bật.');
                    status = 'ended';
                }
                else if (b.action === 'apply') {
                    if (status !== 'published')
                        welfareFail('Chỉ áp dụng trực tiếp vào lịch đã bật.');
                    d = validateDefinition(b.definition);
                    if (d.kind !== old.kind)
                        welfareFail('Không đổi loại Phúc Lợi của cấu hình.');
                    const overlap = this.db.prepare("SELECT 1 FROM welfare_configs WHERE realm=? AND kind=? AND status='published' AND id<>? AND json_extract(definition,'$.starts')<? AND json_extract(definition,'$.ends')>? LIMIT 1").get(realm, d.kind, b.id, d.ends, d.starts);
                    if (overlap)
                        welfareFail('Lịch bị trùng. Chỉnh lại thời gian hoặc ngừng lịch còn lại.');
                }
                else if (b.action === 'run') {
                    if (d.ends <= at)
                        welfareFail('Lịch đã hết hạn. Chỉnh ngày kết thúc trong một bản nháp mới.');
                    d.starts = Math.min(d.starts, at);
                    status = 'published';
                    const overlaps = this.db.prepare("SELECT * FROM welfare_configs WHERE realm=? AND kind=? AND status='published' AND id<>? AND json_extract(definition,'$.starts')<? AND json_extract(definition,'$.ends')>?").all(realm, d.kind, b.id, d.ends, d.starts);
                    for (const other of overlaps) {
                        this.db.prepare("UPDATE welfare_configs SET status='ended',revision=revision+1,updated_at=? WHERE id=?").run(at, other.id);
                        audit(this.db, admin, 'welfare.config.stop', null, 'Thay lịch Phúc Lợi đang chạy', other, { configId: other.id, realm, replacedBy: b.id }, at);
                    }
                }
                else
                    welfareFail('Thao tác quản lý không hợp lệ.');
            }
            this.db.prepare('UPDATE welfare_configs SET status=?,definition=?,revision=revision+1,updated_at=? WHERE id=?').run(status, JSON.stringify(d), at, b.id);
            audit(this.db, admin, 'welfare.config.' + b.action, null, { run: 'Bật lịch Phúc Lợi ngay', stop: 'Ngừng lịch Phúc Lợi', apply: 'Cập nhật lịch Phúc Lợi', trash: 'Chuyển cấu hình vào thùng rác', restore: 'Khôi phục bản nháp Phúc Lợi' }[b.action], old, { configId: b.id, realm, status, definition: d }, at);
            return { id: b.id, revision: Number(old.revision) + 1, status };
        });
    }
    inspect(id) { this.player(id); return { userId: id, realm, qa: this.db.prepare('SELECT * FROM welfare_qa_players WHERE user_id=?').get(id) ?? null, daily: this.dailyState(id, this.at(id), false), ...this.cards({ user_id: id }), entitlements: this.db.prepare('SELECT id,kind,starts,ends,revoked_at,created_at FROM welfare_entitlements WHERE user_id=? AND realm=? ORDER BY created_at DESC').all(id, realm) }; }
    qa(admin, b) {
        if (this.online)
            welfareFail('Công cụ QA không mở trên ONLINE.', 403);
        const id = positiveId(b.userId);
        this.player(id);
        return this.repo.operation('admin:' + admin, b.requestId, b, this.now(), () => {
            const qa = this.db.prepare('SELECT * FROM welfare_qa_players WHERE user_id=?').get(id);
            if (b.action === 'mark') {
                const u = this.db.prepare('SELECT username FROM users WHERE id=?').get(id);
                if (!/^qa_welfare_[a-z0-9_]+$/i.test(String(u.username)))
                    welfareFail('Chỉ đánh dấu tài khoản qa_welfare_* tổng hợp. Không bật đồng hồ QA trên tài khoản đang chơi.');
                this.db.prepare('INSERT INTO welfare_qa_players VALUES(?,0,?) ON CONFLICT(user_id) DO NOTHING').run(id, this.now());
            }
            else if (b.action === 'advance') {
                if (!qa)
                    welfareFail('Đồng hồ riêng chỉ áp dụng người chơi QA đã đánh dấu.');
                if (!Number.isInteger(b.days) || b.days < 1 || b.days > 100 || Number(qa.clock_offset) + b.days * DAY > 400 * DAY)
                    welfareFail('Tăng 1–100 ngày, tổng tối đa 400 ngày.');
                this.db.prepare('UPDATE welfare_qa_players SET clock_offset=clock_offset+?,updated_at=? WHERE user_id=?').run(b.days * DAY, this.now(), id);
            }
            else if (b.action === 'activate') {
                if (!['month', 'quarter'].includes(b.kind))
                    welfareFail('Chọn Thẻ tháng hoặc Thẻ Mùa.');
                const at = this.at(id), existing = this.entitlement(id, b.kind, at);
                if (existing && existing.revoked_at === null && Number(existing.ends) > at)
                    welfareFail('Thẻ còn hiệu lực. Nguồn chưa xác minh quy tắc cộng dồn, không ghi đè thẻ.');
                const cfg = this.active(b.kind, at, b.configId).definition;
                const entitlementId = 'qa-' + admin + '-' + b.requestId;
                this.db.prepare('INSERT INTO welfare_entitlements(id,user_id,realm,kind,config_id,starts,ends,snapshot,created_at) VALUES(?,?,?,?,?,?,?,?,?)').run(entitlementId, id, realm, b.kind, b.configId ?? null, at, Math.min(cfg.ends, at + welfareLengths[b.kind] * DAY), JSON.stringify(cfg), this.now());
            }
            else if (b.action === 'expire') {
                if (!qa)
                    welfareFail('Chỉ kết thúc thẻ của tài khoản QA tổng hợp.');
                if (!['month', 'quarter'].includes(b.kind))
                    welfareFail('Loại thẻ không hợp lệ.');
                this.db.prepare('UPDATE welfare_entitlements SET revoked_at=? WHERE user_id=? AND realm=? AND kind=? AND revoked_at IS NULL').run(this.now(), id, realm, b.kind);
            }
            else
                welfareFail('Công cụ QA không hợp lệ.');
            audit(this.db, admin, 'welfare.qa.' + b.action, id, 'Thao tác LOCAL QA; không thanh toán thật', qa, { ...b, requestId: undefined }, this.now());
            return { ok: true, userId: id };
        });
    }
    history(q = {}) {
        const id = q.user ? positiveId(q.user) : null, kind = q.kind ? String(q.kind) : null;
        if (kind && !welfareKinds.includes(kind))
            welfareFail('Hệ thống không hợp lệ.');
        const page = Math.max(1, Math.min(10000, Math.floor(Number(q.page) || 1))), date = q.date ? String(q.date) : null;
        if (date && !/^\d{4}-\d{2}-\d{2}$/.test(date))
            welfareFail('Ngày cần YYYY-MM-DD.');
        const args = [realm, id, id, kind, kind, date, date], where = 'realm=? AND (? IS NULL OR user_id=?) AND (? IS NULL OR kind=?) AND (? IS NULL OR server_day=?)';
        return { page, total: Number(this.db.prepare('SELECT COUNT(*) n FROM welfare_claims WHERE ' + where).get(...args).n), entries: this.db.prepare('SELECT * FROM welfare_claims WHERE ' + where + ' ORDER BY id DESC LIMIT 40 OFFSET ?').all(...args, (page - 1) * 40).map(r => ({ ...r, rewards: JSON.parse(String(r.rewards)) })), audit: this.db.prepare("SELECT action,target_user_id,summary,created_at FROM admin_audit WHERE action LIKE 'welfare.%' AND (? IS NULL OR target_user_id=?) ORDER BY id DESC LIMIT 40").all(id, id) };
    }
    overview() { const day = welfareDay(this.now()); return { day, realm, checkedInToday: Number(this.db.prepare('SELECT COUNT(*) n FROM welfare_attendance WHERE realm=? AND last_day=?').get(realm, day).n), claimsToday: this.db.prepare('SELECT kind,COUNT(*) count FROM welfare_claims WHERE realm=? AND server_day=? GROUP BY kind').all(realm, day), activeCards: this.db.prepare('SELECT kind,COUNT(*) count FROM welfare_entitlements WHERE realm=? AND starts<=? AND ends>? AND revoked_at IS NULL GROUP BY kind').all(realm, this.now(), this.now()), expiring: Number(this.db.prepare('SELECT COUNT(*) n FROM welfare_entitlements WHERE realm=? AND ends>? AND ends<=? AND revoked_at IS NULL').get(realm, this.now(), this.now() + 3 * DAY).n), ...this.list() }; }
}
