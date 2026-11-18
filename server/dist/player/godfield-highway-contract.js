import { godfieldConfig } from './godfield-source.js';
import { verifyHighwayHelperSource } from './godfield-highway-race.js';
/** Hợp đồng Lua Việt Nam, không suy ra thuật toán odds/buff/payout từ tên cột.
 * power_change: minTr=5, maxTr=highway_time[round].odd_limit, item9101353.
 * voyagePreAssist: num=power_att3_att1_att2, tương ứng năng lượng/Aether/gia tốc/khoang.
 * voyageRest/Sprint: sort1..3 trợ giúp tàu mình;4..6 quấy rối tàu khác.
 */
const fail = (s) => { throw Object.assign(Error(s), { statusCode: 422 }); };
const integer = (v, min, max, label) => {
    if (!/^\d+$/.test(String(v)) || !Number.isSafeInteger(Number(v)) || Number(v) < min || Number(v) > max)
        fail(label + ' không hợp lệ.');
    return Number(v);
};
export const highwayActionMaterials = [9101351, 9101347, 9101349, 9101352, 9101348, 9101350];
export function highwayBetContract(round, areaValue, shipValue, numValue) {
    verifyHighwayHelperSource();
    const row = godfieldConfig('highway_time')[integer(round, 1, 10, 'Vòng')];
    if (!row || row.timelist[0] === 6)
        fail('Vòng nghỉ không nhận đặt cược.');
    const max = Number(row.odd_limit);
    if (max !== 50)
        fail('Trần cược nguồn đã đổi; cần đối chiếu client trước khi nhận vé.');
    const area = integer(areaValue, 1, 6, 'Vũ trụ'), ship = integer(shipValue, 1, 8, 'Tàu'), tickets = integer(numValue, 5, max, 'Số vé cược');
    return { area, ship, tickets, cost: [[6, 9101353, tickets]], minimum: 5, maximum: max };
}
export function highwayContributionContract(numValue) {
    verifyHighwayHelperSource();
    if (typeof numValue !== 'string' || !/^\d+_\d+_\d+_\d+$/.test(numValue))
        fail('Gói góp năng lượng phải gồm năng lượng_Aether_gia tốc_khoang.');
    // Trần kỹ thuật để nhân/tổng chi phí luôn an toàn, không phải trần góp gốc.
    const [energy, aether, accelerator, cargo] = numValue.split('_').map(v => integer(v, 0, 100000000, 'Số lượng góp'));
    if (energy + aether + accelerator + cargo === 0)
        fail('Chưa chọn năng lượng hoặc đạo cụ để góp.');
    return { energy, aether, accelerator, cargo, cost: [[111, 0, energy], [6, 9101351, aether], [6, 9101347, accelerator], [6, 9101349, cargo]].filter(v => v[2] > 0) };
}
export function highwayBuffContract(sortValue, shipValue, ownBetShip) {
    verifyHighwayHelperSource();
    const sort = integer(sortValue, 1, 6, 'Loại trợ giúp/quấy rối'), ship = integer(shipValue, 1, 8, 'Tàu');
    if (ownBetShip === null)
        fail('Bạn chưa đặt cược cho tàu trong vũ trụ này.');
    const own = integer(ownBetShip, 1, 8, 'Tàu đã cược'), assist = sort <= 3;
    if (assist && ship !== own)
        fail('Chỉ được trợ giúp tàu mình đã đặt cược.');
    if (!assist && ship === own)
        fail('Không được quấy rối tàu mình đã đặt cược.');
    const material = highwayActionMaterials[sort - 1], group = (sort - 1) % 3 + 1, row = godfieldConfig('highway_num')[group];
    if (!row || !row.lack.includes(material))
        fail('Đạo cụ không khớp nhóm nguồn.');
    return { sort, ship, assist, group, material, cost: [[6, material, 1]] };
}
