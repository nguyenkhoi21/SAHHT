import { staticConfig } from './player.service.js';
export const LOCAL_MAX_LEVEL = 250;
export function levelState(level) {
    if (!Number.isInteger(level) || level < 1 || level > LOCAL_MAX_LEVEL)
        throw Object.assign(new Error('Cấp độ phải là số nguyên từ1 đến250.'), { statusCode: 422 });
    // GM trực tiếp: chưa có bảng EXP người chơi; không bịa đường cong tăng cấp.
    return { level, exp: 0, exp_max: 0 };
}
export async function progressionConfig() {
    const [cfg, rewards, items] = await Promise.all([staticConfig('vip'), staticConfig('new_vip_reward'), staticConfig('item')]);
    const rewardView = (tuples = []) => tuples.map(([type, configId, quantity]) => ({ type, configId, quantity, name: type === 6 ? items[String(configId)]?.name ?? 'Vật phẩm chưa liên kết' : { 9: 'Kim cương', 15: 'Vàng', 1: 'Lương thực', 2: 'Sắt', 4: 'Tinh thạch' }[type] ?? 'Loại thưởng cần kiểm chứng' }));
    const vips = Object.entries(cfg).map(([id, c]) => ({ level: Number(id), need_exp: c.need_exp, story: c.story, privileges: Object.fromEntries(Object.entries(c).filter(([k, v]) => k !== 'story' && typeof v === 'number')), rewardSupported: !!rewards[id], dailyRewards: rewardView(rewards[id]?.everyday), signRewards: Object.fromEntries(Array.from({ length: 7 }, (_, i) => ['day' + (i + 1), rewardView(rewards[id]?.['day' + (i + 1)])])) })).sort((a, b) => a.level - b.level);
    if (!vips.length || vips.some((v, i) => v.level !== i || !Number.isSafeInteger(v.need_exp) || v.need_exp < 0))
        throw new Error('Config VIP không hợp lệ.');
    return { minLevel: 1, maxLevel: LOCAL_MAX_LEVEL, maxVip: vips.at(-1).level, vips, expMode: 'LOCAL_GM_MANUAL', notice: 'Cấp độ GM trực tiếp; EXP0/0, chưa mô phỏng tăng cấp hoặc tự mở tiến độ ải. Hãy xếp ít nhất một tướng vào Trận hình trước khi nâng lên cấp150+: giao diện Blood Stone gốc lỗi nếu đội hình trống.' };
}
export async function vipState(vip) {
    const cfg = await progressionConfig();
    if (!Number.isInteger(vip) || vip < 0 || vip > cfg.maxVip)
        throw Object.assign(new Error(`VIP phải là số nguyên từ0 đến${cfg.maxVip}.`), { statusCode: 422 });
    // Chính sách GM local: mốc thấp nhất theo need_exp hàng trước; không giả thanh toán.
    return { vip, vip_exp: vip === 0 ? 0 : cfg.vips[vip - 1].need_exp };
}
