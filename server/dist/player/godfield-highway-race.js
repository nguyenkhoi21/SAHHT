import { godfieldConfig, godfieldSource } from './godfield-source.js';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
let helperChecked = false;
export function verifyHighwayHelperSource() {
    if (helperChecked)
        return;
    const entry = godfieldSource().scripts['game_pop/game_god_escort_helper.lua'];
    if (!entry || createHash('sha256').update(readFileSync(new URL('../../../' + entry.path, import.meta.url))).digest('hex') !== entry.sha256)
        throw Error('Nguồn Lua Tháp đã đổi; cần đối chiếu lại lịch/hành trình.');
    helperChecked = true;
}
function valid(n, label, minimum = -Number.MAX_SAFE_INTEGER) {
    if (!Number.isFinite(n) || Math.abs(n) > Number.MAX_SAFE_INTEGER || n < minimum)
        throw Error('Dữ liệu hành trình không hợp lệ: ' + label);
    return n;
}
function whole(n, min, max, label) {
    if (!Number.isSafeInteger(n) || n < min || n > max)
        throw Error('Dữ liệu hành trình không hợp lệ: ' + label);
    return n;
}
export function highwayInitialFleet(area) {
    whole(area, 1, 6, 'vũ trụ');
    const cfg = godfieldConfig('highway_ship')['1'], names = godfieldConfig('highway_txt');
    return Array.from({ length: 8 }, (_, i) => {
        const ship_id = i + 1, name = names[(area - 1) * 8 + ship_id + 6]?.des;
        if (typeof name !== 'string' || !name)
            throw Error('Thiếu tên tàu nguồn.');
        return { ship_id, lv: 1, power: 0, odds: Number(cfg.odds), steps: {}, mileage: 0, achieve_ts: 0, name };
    });
}
/** Ngưỡng tổng năng lượng chung đã góp: người dùng xác nhận29/10/2026.
 * Không phải phí phải trả lại cho mỗi cấp. Hàm này không trừ ví.
 */
export function highwayShipLevels() {
    return Object.entries(godfieldConfig('highway_ship')).map(([key, r]) => ({
        level: Number(key), energy: Number(r.power), basic: r.basic, odds: Number(r.odds),
    })).sort((a, b) => a.level - b.level);
}
export function highwayLevelFromPower(total) {
    whole(total, 0, Number.MAX_SAFE_INTEGER, 'tổng năng lượng góp');
    const levels = highwayShipLevels();
    if (levels.length !== 5 || levels[0].energy !== 0 || levels.some((r, i) => !Number.isSafeInteger(r.energy) || i > 0 && r.energy <= levels[i - 1].energy))
        throw Error('Ngưỡng cấp tàu nguồn không hợp lệ.');
    const current = levels.filter(r => r.energy <= total).at(-1), next = levels.find(r => r.level > current.level);
    return { level: current.level, totalPower: total, levelThreshold: current.energy,
        nextLevel: next?.level ?? null, nextThreshold: next?.energy ?? null,
        remaining: next ? next.energy - total : 0, maxLevel: !next };
}
/** Quy hoạch góp thuần: cộng vào đúng một tàu, không sửa đầu vào/trừ ví.
 * Chỉ dùng cho preview/kiểm thử tới khi luồng cược-kết toán thật đủ nguồn.
 */
export function highwayContributionPreview(total, added) {
    const before = highwayLevelFromPower(total);
    whole(added, 0, Number.MAX_SAFE_INTEGER, 'năng lượng góp thêm');
    const after = highwayLevelFromPower(whole(total + added, 0, Number.MAX_SAFE_INTEGER, 'tổng năng lượng sau góp'));
    return { before, after, added, levelsGained: after.level - before.level };
}
/** Đúng getAttrDatasBySteps + voyageRest/voyageSprint.refreshUi nguồn Việt.
 * Lợi tức chỉ là thuộc tính, không đồng nghĩa có thưởng đã phát.
 */
export function highwayAttributes(ship, throughStep = 5) {
    verifyHighwayHelperSource();
    whole(ship.lv, 1, 5, 'cấp tàu');
    whole(throughStep, 0, 5, 'chặng thuộc tính');
    const cfg = godfieldConfig('highway_ship')[ship.lv], bonus = { speed_add1: 0, speed_add2: 0, ship_income_add: 0 };
    for (let i = 1; i <= throughStep; i++)
        for (const key of Object.keys(bonus))
            bonus[key] = valid(bonus[key] + valid(ship.steps[String(i)]?.[key] ?? 0, key), 'tổng ' + key);
    return { level: ship.lv, base: { speed: Number(cfg.basic[0]), extraSpeed: Number(cfg.basic[1]), income: Number(cfg.basic[2]) }, bonus,
        effective: { speed: Math.max(Number(cfg.basic[0]) + bonus.speed_add1, 0), extraSpeed: Math.max(Number(cfg.basic[1]) + bonus.speed_add2, 0), income: Math.max(Number(cfg.basic[2]) + bonus.ship_income_add, 0) } };
}
/** Tổng quãng đường giống Lua gốc. speed_add2 ở đây cũng nhân thời gian
 * tuyến tính; không tự thay bằng công thức gia tốc vật lý a*t²/2.
 * steps là kết quả đã có của từng chặng, không phải bộ sinh RNG.
 */
export function highwayMileage(ship, c) {
    verifyHighwayHelperSource();
    if (!ship || c.round_id === 0 || c.sort === 0)
        return 0;
    whole(c.round_id, 1, 10, 'vòng');
    whole(c.sort, 1, 6, 'giai đoạn');
    if (!godfieldConfig('highway_time')[c.round_id])
        throw Error('Thiếu vòng nguồn.');
    if (c.sort === 6)
        return valid(ship.mileage ?? 0, 'quãng đường đã kết toán', 0);
    whole(ship.lv, 1, 5, 'cấp tàu');
    whole(c.step, 0, 5, 'chặng');
    const row = godfieldConfig('highway_ship')[ship.lv], point = godfieldConfig('highway_time')[c.round_id].point;
    if (!row || !Number.isFinite(point) || point <= 0)
        throw Error('Thiếu cấp tàu/mốc hành trình nguồn.');
    if (c.sort === 1)
        return 0;
    const now = Math.floor(valid(c.now, 'giờ server', 0)), start = valid(c.ts_start, 'đầu giai đoạn', 0);
    if (now < start || c.step < 1)
        throw Error('Dữ liệu hành trình không hợp lệ: thời điểm/chặng chưa bắt đầu.');
    const elapsed = Math.min(now - start, 60);
    const speed = (step) => {
        let a = Number(row.basic[0]), b = Number(row.basic[1]);
        for (let j = 1; j <= step; j++) {
            const entry = ship.steps[String(j)];
            a = valid(a + valid(entry?.speed_add1 ?? 0, 'speed_add1'), 'tổng speed_add1');
            b = valid(b + valid(entry?.speed_add2 ?? 0, 'speed_add2'), 'tổng speed_add2');
        }
        return valid(Math.max(a, 0) + Math.max(b, 0), 'tốc độ', 0);
    };
    const navigation = () => {
        let result = 0;
        for (let i = 1; i <= (c.sort === 2 ? c.step : c.step - 1); i++)
            result = valid(result + speed(i) * (i === c.step ? elapsed : 60), 'quãng đường', 0);
        return Math.min(result, point);
    };
    if (c.sort === 2 || c.sort === 3)
        return navigation();
    if (c.sort === 4)
        return Math.min(navigation() + speed(c.step) * elapsed, point);
    const achieved = ship.achieve_ts ?? 0;
    valid(achieved, 'mốc đến', 0);
    if (achieved > now)
        throw Error('Dữ liệu hành trình không hợp lệ: mốc đến ở tương lai.');
    const result = achieved === 0
        ? navigation() + speed(c.step) * 60 + speed(c.step) * elapsed
        : point + speed(c.step) * Math.max(start - achieved, 0) + speed(c.step) * elapsed;
    return valid(result, 'quãng đường chặng cuối', 0);
}
export const highwayQaModel = {
    id: 'race-v1', rate: 6, seed: 'highway-local-race-v1',
    notice: 'ĐUA MÔ PHỎNG LOCAL · không cược, không tiêu đồ, không thưởng.',
    // Đây là đầu vào QA được duyệt, không phải thuật toán server gốc:
    // một biến động ở chặng1, chọn đều trong moneyfix hàng10/cấp1.
    variation: 'Đầu vào mô phỏng: moneyfix hàng10 của cấp1 → speed_add1 chặng1; chặng sau không thêm biến động. Không phải công thức server gốc.',
};
function qaVariation(area, ship, min, max) {
    whole(min, -100000, 100000, 'khoảng QA');
    whole(max, min, 100000, 'khoảng QA');
    const width = max - min + 1, ceiling = Math.floor(0x100000000 / width) * width;
    for (let counter = 0;; counter++) {
        const n = createHash('sha256').update(`${highwayQaModel.seed}:${area}:${ship}:${counter}`).digest().readUInt32BE();
        if (n < ceiling)
            return min + n % width;
    }
}
/** Snapshot QA công khai, không DB/phiên/cược/tài nguyên. Chu kỳ100s phát
 * toàn bộ600s lịch nguồn ở tốc độ6×; mọi tài khoản xem cùng một đoàn tàu.
 */
export function highwayQaRace(nowMs, area, contributed = Array(8).fill(0)) {
    verifyHighwayHelperSource();
    whole(area, 1, 6, 'vũ trụ');
    valid(nowMs, 'giờ QA', 0);
    if (contributed.length !== 8)
        throw Error('Đoàn tàu QA phải có đúng8 tổng năng lượng.');
    for (const total of contributed)
        whole(total, 0, Number.MAX_SAFE_INTEGER, 'tổng góp tàu QA');
    const config = godfieldConfig('highway_time')['1'], day = new Date(nowMs + 7 * 3600000).toISOString().slice(0, 10), start = Date.parse(day + 'T' + config.ready_time + '+07:00') / 1000, real = nowMs / 1000, durations = { 1: 150, 2: 60, 3: 30, 4: 60, 5: 60 }, duration = config.timelist.reduce((sum, stage) => sum + durations[stage], 0), cycleSeconds = duration / highwayQaModel.rate, cycle = Math.floor(real / cycleSeconds), offset = (real - cycle * cycleSeconds) * highwayQaModel.rate;
    let elapsed = offset, ts_start = start, sort = 0, step = 0, navigation = 0, remaining = 0;
    for (const phase of config.timelist) {
        if (phase === 2)
            navigation++;
        if (elapsed < durations[phase]) {
            sort = phase;
            step = phase === 1 ? 0 : phase === 2 ? navigation : navigation + 1;
            remaining = (durations[phase] - elapsed) / highwayQaModel.rate;
            break;
        }
        elapsed -= durations[phase];
        ts_start += durations[phase];
    }
    const now = start + offset, range = godfieldConfig('highway_ship')['1'].moneyfix[0], ships = highwayInitialFleet(area).map(s => {
        const power = contributed[s.ship_id - 1], lv = highwayLevelFromPower(power).level, ship = { ...s, power, lv, odds: Number(godfieldConfig('highway_ship')[lv].odds), steps: { '1': { speed_add1: qaVariation(area, s.ship_id, range[1], range[2]), speed_add2: 0, ship_income_add: 0 } } };
        return { ...ship, attributes: highwayAttributes(ship), mileage: highwayMileage(ship, { round_id: 1, sort, step, ts_start, now }) };
    });
    return { round_id: 1, sort, step, ts_start, data: ships, betting: {}, gift_box: {},
        qa_only: true, qa_clock: { real_at: real, virtual_at: now, rate: highwayQaModel.rate, remaining, cycle },
        qa_model: highwayQaModel, reward: [], source_range: { table: 'highway_ship', level: 1, column: 'moneyfix', row: range } };
}
