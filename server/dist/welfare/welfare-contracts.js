export const welfareKinds = ['daily', 'month', 'quarter'];
export const welfareLengths = { daily: 25, month: 21, quarter: 90 };
export const welfarePolicy = {
    revision: 'welfare-local-v1', timezone: 'Asia/Ho_Chi_Minh',
    sourceConfidence: 'PARTIAL',
    notice: 'Thưởng và màn hình gốc đã xác minh. Vòng đời LOCAL QA: Điểm danh tích lũy 25 ngày đăng nhập, không reset theo tháng; vòng tiếp theo dùng daily_award_loop. Thẻ tháng 21 ngày, Thẻ Mùa 90 ngày; mỗi ngày nhận một gói theo thứ tự, bỏ lỡ không tự cấp. Kích hoạt bằng quyền QA, không thanh toán thật. Chưa có bằng chứng nhiệm vụ, EXP hoặc hai nhánh miễn phí/trả phí.',
    unsupported: ['Điểm danh bù', 'Thưởng VIP nhân đôi', 'Battle-pass EXP/nhiệm vụ/free-premium', 'Thanh toán thật', 'Điểm danh nạp liên tục'],
};
export function welfareFail(message, statusCode = 422) {
    throw Object.assign(new Error(message), { statusCode });
}
export const welfareDay = (at) => new Date(at + 7 * 3600000).toISOString().slice(0, 10);
export function positiveId(value) {
    const id = Number(value);
    if (!Number.isSafeInteger(id) || id < 1)
        welfareFail('Mã người chơi không hợp lệ.', 400);
    return id;
}
