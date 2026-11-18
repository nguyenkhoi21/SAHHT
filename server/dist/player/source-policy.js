// Chính sách pha15: code8 chỉ lưu nghiên cứu; không cho flag runtime bật lại nguồn China.
export const contentSourcePolicy = { revision: 'vn-source-policy-v1', preferred: 'vn-code10', quarantined: ['com.kaiqigu.cjyx.kvsdk'],
    notice: 'Nguồn China đã cách ly. Chỉ dữ liệu Việt Nam đã xác minh được phép cấp vào game local.' };
export function assertImportSource(source) {
    if (contentSourcePolicy.quarantined.includes(source))
        throw Object.assign(new Error('Nguồn China đang cách ly, không được nhập hoặc cấp tướng.'), { statusCode: 422 });
    if (!source.startsWith('vn-code10-'))
        throw Object.assign(new Error('Chưa xác minh nguồn Việt Nam này.'), { statusCode: 422 });
}
