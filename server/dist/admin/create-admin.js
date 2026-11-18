import { createInterface } from 'node:readline/promises';
import { openDatabase } from '../db/database.js';
import { AdminAuth } from './admin.auth.js';
import { runtimeConfig } from '../system/runtime.js';
if (!process.stdin.isTTY)
    throw new Error('Cần terminal tương tác; không truyền mật khẩu qua command-line hoặc file.');
const rl = createInterface({ input: process.stdin, output: process.stdout });
const username = await rl.question('Tên quản trị: ');
const role = (await rl.question('Quyền OWNER / ADMIN / VIEWER [OWNER]: ')).trim().toUpperCase() || 'OWNER';
rl.close();
function hidden(prompt) { process.stdout.write(prompt); process.stdin.setRawMode(true); process.stdin.resume(); return new Promise((resolve, reject) => { let secret = ''; const done = () => { process.stdin.off('data', read); process.stdin.setRawMode(false); process.stdin.pause(); process.stdout.write('\n'); }; const read = (chunk) => { for (const c of chunk.toString('utf8')) {
    if (c === '\x03') {
        done();
        reject(new Error('Đã hủy.'));
        return;
    }
    if (c === '\r' || c === '\n') {
        done();
        resolve(secret);
        return;
    }
    if (c === '\x7f' || c === '\b')
        secret = Array.from(secret).slice(0, -1).join('');
    else if (c >= ' ')
        secret += c;
} }; process.stdin.on('data', read); }); }
let password = await hidden('Mật khẩu admin (12–128 ký tự, không hiển thị): ');
let confirmation = await hidden('Nhập lại mật khẩu: ');
if (password !== confirmation)
    throw new Error('Mật khẩu không khớp.');
const runtime = runtimeConfig(), db = openDatabase(runtime.database);
try {
    const result = await new AdminAuth(db).create(username, password, role);
    console.log(`Đã tạo admin ${result.username} (${result.role}). Mở ${runtime.origin}/admin/`);
}
finally {
    password = '';
    confirmation = '';
    db.close();
}
