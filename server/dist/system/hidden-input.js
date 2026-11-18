// Chỉ dùng CLI tương tác; không nhận bí mật qua argv hoặc ghi tệp/log.
export function hiddenInput(prompt) {
    if (!process.stdin.isTTY)
        throw Error('Cần terminal tương tác để nhập mật khẩu ẩn.');
    process.stdout.write(prompt);
    process.stdin.setRawMode(true);
    process.stdin.resume();
    return new Promise((resolve, reject) => { let value = ''; const done = () => { process.stdin.off('data', read); process.stdin.setRawMode(false); process.stdin.pause(); process.stdout.write('\n'); }; const read = (b) => { for (const c of b.toString('utf8')) {
        if (c === '\x03') {
            done();
            reject(Error('Đã hủy.'));
            return;
        }
        if (c === '\r' || c === '\n') {
            done();
            resolve(value);
            return;
        }
        if (c === '\x7f' || c === '\b')
            value = Array.from(value).slice(0, -1).join('');
        else if (c >= ' ')
            value += c;
    } }; process.stdin.on('data', read); });
}
