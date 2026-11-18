import { randomInt } from 'node:crypto';
import { readConfigSync } from './local-content.js';
import { WelfareService } from './welfare.service.js';
import { contentReceipt } from './content-receipt.js';
import { audit } from '../admin/admin.audit.js';
// LOCAL: nâng giới hạn lượt của 2 mode chiêu mộ cố định (999 = Vàng, 201 = Kim cương).
// Hai mode này luôn ra ĐÚNG 1 tướng cố định (không random); chi phí vẫn bị trừ như cũ.
const BOOST_LIMIT = { '999': 999999, '201': 999999 };
const gachaCfg = () => Object.fromEntries(Object.entries(readConfigSync('gacha')).map(([id, c]) => [id, BOOST_LIMIT[id] ? { ...c, gacha_num: BOOST_LIMIT[id], _boost: true } : c]));
// LOCAL (không phải luật gốc): mode 999/201 quay NGẪU NHIÊN trong toàn bộ tướng gốc phẩm 3 và 4
// lấy từ tài khoản user01 (358 tướng, id chia hết cho 100). Không có bảo hiểm/điểm tích lũy.
// RARE_CHANCE = xác suất ra nhóm phẩm 4 (331 tướng), phần còn lại ra nhóm phẩm 3 (27 tướng). Sửa số này để chỉnh tỷ lệ.
// Tướng nào không có trong character_detail của server sẽ tự bị bỏ qua.
const RARE_CHANCE = 0.5;
const COMMON_IDS = [100, 200, 300, 400, 700, 800, 1000, 1200, 1300, 1400, 1600, 1700, 1800, 2400, 3000, 3800, 3900, 4000, 4300, 4500, 4700, 5200, 5300, 5400, 5500, 5900, 6000];
const RARE_IDS = [500, 600, 900, 1100, 1900, 2000, 2100, 2200, 2300, 2500, 3100, 3300, 3400, 3500, 3600, 3700, 4100, 4200, 4400, 4600, 4800, 4900, 5600, 5700, 5800, 6100, 6200, 6300, 6400, 6500, 6700, 6800, 6900, 7000, 7100, 7300, 7400, 7500, 7600, 7700, 7800, 7900, 8100, 8200, 8300, 8400, 8500, 8600, 8700, 8800, 8900, 9000, 9100, 9200, 9300, 9400, 9500, 9600, 9700, 9800, 9900, 32000, 32100, 32200, 32300, 32400, 32500, 32600, 32700, 32800, 32900, 33000, 33100, 33200, 33300, 33400, 33500, 33600, 33700, 33800, 33900, 34000, 34100, 34200, 34300, 34400, 34500, 34600, 34800, 34900, 35000, 35100, 35200, 35400, 35500, 35600, 35700, 35800, 35900, 36000, 36100, 36200, 36300, 36400, 36500, 36600, 36700, 36800, 36900, 37000, 37100, 37200, 37300, 37400, 37500, 37600, 37700, 37800, 37900, 38000, 38100, 38200, 38300, 38400, 38500, 38600, 38700, 38800, 38900, 39000, 39100, 39200, 39300, 39400, 39500, 39600, 39700, 39800, 39900, 40000, 40100, 40200, 40300, 40400, 40500, 40600, 40700, 40800, 40900, 41000, 41100, 41200, 41300, 41400, 41500, 41600, 41700, 41800, 41900, 42000, 42100, 42200, 42300, 42400, 42500, 42600, 42900, 43000, 43100, 43200, 43300, 43400, 43500, 43600, 43700, 43800, 43900, 44000, 44200, 60400, 60500, 60600, 60700, 60800, 60900, 61000, 61100, 61200, 61300, 61400, 61500, 61600, 61700, 61800, 61900, 62000, 62100, 62200, 62300, 62400, 62500, 62600, 62700, 62800, 62900, 63000, 63100, 63200, 63300, 63400, 63500, 63600, 63800, 63900, 64000, 64100, 64300, 64400, 64500, 64600, 64700, 64800, 64900, 65000, 65100, 65200, 65300, 65400, 65500, 65600, 65700, 65800, 65900, 66000, 66100, 66200, 66300, 66400, 66500, 66600, 66700, 66800, 66900, 67000, 67100, 67200, 67300, 67400, 67600, 67700, 67800, 67900, 68000, 68100, 68200, 68300, 68400, 68500, 68600, 68700, 68800, 68900, 69000, 69100, 69200, 69300, 69400, 69500, 69600, 69700, 69800, 69900, 78000, 78100, 78200, 78300, 78400, 78500, 78600, 78700, 78800, 78900, 79000, 79100, 79200, 79300, 79400, 79500, 79600, 79700, 79800, 79900, 80000, 80100, 80200, 80300, 80400, 80500, 80600, 80700, 80800, 80900, 81000, 81100, 81200, 81300, 81400, 81500, 81800, 81900, 82000, 82100, 82200, 82300, 82400, 82500, 82600, 82700, 82800, 82900, 83000, 83200, 83300, 83500, 83600, 83700, 83800, 83900, 84000, 84100, 84200];
const randomHero = (heroes, fallback) => {
    const common = COMMON_IDS.filter(i => heroes[i]), rare = RARE_IDS.filter(i => heroes[i]);
    const list = rare.length && (!common.length || randomInt(1_000_000) < RARE_CHANCE * 1_000_000) ? rare : common;
    return list.length ? list[randomInt(list.length)] : fallback;
};
const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
// Chỉ mở pool xác định ở cả hai nhánh; không đoán xác suất hoặc pity.
export class GachaService {
    db;
    constructor(db) {
        this.db = db;
    }
    draws(userId, id) {
        return Number(this.db.prepare('SELECT draws FROM player_gacha WHERE user_id=? AND gacha_id=?').get(userId, id)?.draws ?? 0);
    }
    pool(c) {
        if (c.is_box !== 0 || c.get_num !== 1 || c.piece.length || c.good_item.length !== 1 || JSON.stringify(c.good_item) !== JSON.stringify(c.bad_item))
            return null;
        const row = c.good_item[0];
        if (row.length !== 3 || !row.every(Number.isSafeInteger) || !readConfigSync('character_detail')[row[0]] || ![2, 3].includes(c.consume_sort) || c.gacha_sort !== 2 || (c.gacha_num !== 1 && !c._boost) || c.star_time || c.end_time)
            return null;
        return row[0];
    }
    diagnostics(s) { return { modes: Object.entries(gachaCfg()).map(([id, c]) => ({ id, cost: c.value, currency: c.consume_sort === 2 ? 'silver' : 'coin', count: c.get_num, draws: this.draws(s.user_id, id), limit: c.gacha_num, prerequisite: c.use_gacha, available: this.pool(c) !== null, reason: this.pool(c) !== null ? 'Pool một nhân vật xác định; khởi tạo tướng cấp1 từ registry local, không suy cấp từ tuple nguồn.' : c.is_box ? 'Thiếu dữ liệu pool backend bad_item/is_box và thuật toán bảo hiểm.' : 'Chưa xác minh cách chọn good_point/bad_point; không tự chế xác suất.', goodPool: c.good_item, badPool: c.bad_item })), history: this.db.prepare("SELECT method,result,created_at FROM player_content_operations WHERE user_id=? AND method='gacha.get_gacha' ORDER BY created_at DESC LIMIT 50").all(s.user_id).map(r => ({ ...r, result: JSON.parse(String(r.result)) })), notice: 'Giữ ledger cũ; không tiếp tục lượt Luffy hardcode #221. Các pool ngẫu nhiên chưa đủ dữ liệu sẽ không tiêu tài nguyên.' }; }
    open(session) {
        const all = {};
        for (const [id, c] of Object.entries(gachaCfg())) {
            if (this.pool(c) === null)
                continue;
            const [pre, n] = c.use_gacha;
            if (pre && this.draws(session.user_id, String(pre)) < n)
                continue;
            const remaining = Math.max(0, c.gacha_num - this.draws(session.user_id, id));
            if (remaining)
                all[id] = remaining;
        }
        const score = Number(this.db.prepare("SELECT COALESCE(SUM(json_extract(result,'$.points')),0) n FROM player_content_operations WHERE user_id=? AND method='gacha.get_gacha'").get(session.user_id).n);
        return { gacha_all: all, score, energy_slot: 0, msg: 'Chiêu mộ local theo pool xác định. Không chế tỷ lệ hoặc bảo hiểm.' };
    }
    async draw(s, type, key) {
        if (typeof type !== 'string' || !/^\d{1,5}$/.test(type))
            fail('Mã chiêu mộ không hợp lệ.');
        const id = String(type), c = gachaCfg()[id], cid = c && this.pool(c);
        if (!c || !cid)
            fail('Chiêu mộ này chưa hỗ trợ: thiếu quy tắc pool/đảm bảo đã xác minh.');
        const defs = { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') };
        return contentReceipt(this.db, s.user_id, 'gacha.get_gacha', key, { id }, () => {
            const p = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(s.user_id).profile));
            if (this.draws(s.user_id, id) >= c.gacha_num)
                fail('Đã dùng lượt chiêu mộ theo cấu hình.');
            const [pre, n] = c.use_gacha;
            if (pre && this.draws(s.user_id, String(pre)) < n)
                fail('Chưa hoàn thành lượt chiêu mộ trước đó.');
            if (p.level < c.use_level[0] || p.level > c.use_level[1])
                fail('Chưa đủ điều kiện cấp người chơi.');
            const field = c.consume_sort === 2 ? 'silver' : 'coin';
            if (!Number.isSafeInteger(c.value) || c.value < 1 || !Number.isSafeInteger(p[field]) || p[field] < c.value)
                fail('Không đủ ' + (field === 'coin' ? 'Xu' : 'vàng') + ' để chiêu mộ.');
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...p, [field]: p[field] - c.value }), s.user_id);
            const pick = c._boost ? randomHero(defs.heroes, cid) : cid;
            const applied = new WelfareService(this.db).applyInTransaction(s, [[5, pick, 1]], defs);
            this.db.prepare('INSERT INTO player_gacha VALUES(?,?,1) ON CONFLICT(user_id,gacha_id) DO UPDATE SET draws=draws+1').run(s.user_id, id);
            const points = c.add_point;
            audit(this.db, null, 'gacha.draw', s.user_id, 'Pool xác định từ config; schema khởi tạo tướng local', { balance: p[field] }, { gachaId: id, cost: c.value, cid: pick, points });
            const state = this.open(s);
            return { ...applied, ...state, score: state.score + points, points, new_card: Object.keys(applied._client_cache_update.cards.cards.update), gacha_type: id };
        }, old => ({ ...old, ...this.open(s), reward: [], new_card: [], replayed: true, _client_cache_update: { cards: { cards: { update: Object.fromEntries(this.db.prepare('SELECT id,state FROM player_heroes WHERE user_id=?').all(s.user_id).map(r => [String(r.id), JSON.parse(String(r.state))])), remove: [] } } } }));
    }
}
