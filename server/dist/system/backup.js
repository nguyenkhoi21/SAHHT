import { DatabaseSync, backup } from 'node:sqlite';
import { databaseSchemaVersion } from '../db/database.js';
import { createReadStream, createWriteStream } from 'node:fs';
import { mkdir, mkdtemp, rm, readFile, writeFile, readdir, stat, lstat, open, chmod, rename, copyFile } from 'node:fs/promises';
import { join, resolve, basename, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createCipheriv, createDecipheriv, randomBytes, randomUUID, scrypt, createHash } from 'node:crypto';
import { promisify } from 'node:util';
import { pipeline } from 'node:stream/promises';
import { execFile } from 'node:child_process';
const run = promisify(execFile), derive = promisify(scrypt), magic = Buffer.from('SAHHTB01');
const fail = (m, code = 422) => { throw Object.assign(new Error(m), { statusCode: code }); };
const idPattern = /^[a-f0-9-]{36}$/;
export const persistentBackupFiles = () => ['server-list.json', 'local-hero-definitions.json', 'vip-store-compatible.json'].map(n => fileURLToPath(new URL('../../data/' + n, import.meta.url)));
export async function fileHash(path) { const h = createHash('sha256'); for await (const b of createReadStream(path))
    h.update(b); return h.digest('hex'); }
function checkDatabase(path) { const d = new DatabaseSync(path, { readOnly: true }); try {
    if (d.prepare('PRAGMA integrity_check').get().integrity_check !== 'ok' || d.prepare('PRAGMA foreign_key_check').all().length)
        fail('Snapshot SQLite không toàn vẹn.');
    return Number(d.prepare('PRAGMA user_version').get().user_version);
}
finally {
    d.close();
} }
export class BackupStore {
    db;
    options;
    busy = false;
    lastManual = 0;
    directory;
    constructor(db, options) {
        this.db = db;
        this.options = options;
        this.directory = resolve(options.directory);
    }
    async init() { await mkdir(this.directory, { recursive: true, mode: 0o700 }); if ((await lstat(this.directory)).isSymbolicLink())
        fail('Thư mục sao lưu không được là symlink.'); await chmod(this.directory, 0o700); }
    path(id, suffix) { if (!idPattern.test(id))
        fail('Mã sao lưu không hợp lệ.', 404); return join(this.directory, id + suffix); }
    async list() { await this.init(); const rows = []; for (const name of await readdir(this.directory)) {
        if (!/^[a-f0-9-]{36}\.json$/.test(name))
            continue;
        try {
            if ((await lstat(join(this.directory, name))).isSymbolicLink())
                continue;
            const m = JSON.parse(await readFile(join(this.directory, name), 'utf8'));
            if (m.format === 'SAHHTB01')
                rows.push(m);
        }
        catch { }
    } return rows.sort((a, b) => b.createdAt.localeCompare(a.createdAt)); }
    async automaticStatus() { try {
        const p = join(this.directory, 'automatic-status.json');
        if ((await lstat(p)).isSymbolicLink())
            return null;
        const s = JSON.parse(await readFile(p, 'utf8'));
        return { ok: s.ok === true, at: s.at, error: s.ok ? undefined : 'BACKUP_FAILED' };
    }
    catch {
        return null;
    } }
    async create(passphrase, reason = 'manual') {
        if (typeof passphrase !== 'string' || passphrase.length < 16 || passphrase.length > 256)
            fail('Mật khẩu mã hóa cần16–256 ký tự, hãy giữ riêng để khôi phục.');
        if (this.busy || reason === 'manual' && Date.now() - this.lastManual < 60_000)
            fail('Đang sao lưu hoặc vừa tạo bản sao; chờ một phút.', 429);
        this.busy = true;
        if (reason === 'manual')
            this.lastManual = Date.now();
        let temp;
        const id = randomUUID(), archive = this.path(id, '.sahht');
        try {
            await this.init();
            temp = await mkdtemp(join(this.directory, '.stage-'));
            await chmod(temp, 0o700);
            const snapshot = join(temp, 'database.sqlite');
            await backup(this.db, snapshot);
            await chmod(snapshot, 0o600);
            const schema = checkDatabase(snapshot);
            const files = [{ name: 'database.sqlite', sha256: await fileHash(snapshot), bytes: (await stat(snapshot)).size }];
            for (const [i, source] of (this.options.dataFiles ?? []).entries()) {
                const s = await lstat(source);
                if (!s.isFile() || s.isSymbolicLink() || s.size > 10 * 1024 * 1024 || !source.endsWith('.json'))
                    fail('Cấu hình bền vững không thuộc allowlist JSON.');
                const raw = await readFile(source);
                JSON.parse(raw.toString());
                const name = `persistent-${i}.json`;
                await writeFile(join(temp, name), raw, { mode: 0o600 });
                files.push({ name, sha256: await fileHash(join(temp, name)), bytes: raw.length, restoreName: basename(source) });
            }
            const release = await readFile(new URL('../../../release-manifest.json', import.meta.url), 'utf8').then(s => JSON.parse(s).release).catch(() => 'workspace');
            const manifest = { format: 'SAHHTB01', id, createdAt: new Date().toISOString(), environment: this.options.environment, backendVersion: process.env.RELEASE_ID ?? release, node: process.versions.node, schema, reason, files };
            await writeFile(join(temp, 'manifest.json'), JSON.stringify(manifest, null, 2), { mode: 0o600 });
            const packed = join(temp, 'payload.tar.gz');
            await run('tar', ['-czf', packed, '-C', temp, 'manifest.json', ...files.map(f => f.name)], { maxBuffer: 1024 * 1024 });
            const salt = randomBytes(16), iv = randomBytes(12), key = await derive(passphrase, salt, 32), cipher = createCipheriv('aes-256-gcm', key, iv), out = this.path(id, '.partial');
            cipher.setAAD(magic);
            await writeFile(out, Buffer.concat([magic, salt, iv]), { mode: 0o600, flag: 'wx' });
            try {
                await pipeline(createReadStream(packed), cipher, createWriteStream(out, { flags: 'a', mode: 0o600 }));
                const h = await open(out, 'a');
                try {
                    await h.write(cipher.getAuthTag());
                    await h.sync();
                }
                finally {
                    await h.close();
                }
                await rename(out, archive);
            }
            finally {
                key.fill(0);
                await rm(out, { force: true });
            }
            const result = { ...manifest, files: undefined, bytes: (await stat(archive)).size, sha256: await fileHash(archive), status: 'READY', integrity: 'VERIFIED_SNAPSHOT', encryption: 'AES-256-GCM/scrypt' };
            await writeFile(this.path(id, '.json'), JSON.stringify(result, null, 2), { mode: 0o600, flag: 'wx' });
            return result;
        }
        catch (e) {
            await rm(archive, { force: true });
            throw e;
        }
        finally {
            if (temp)
                await rm(temp, { recursive: true, force: true });
            this.busy = false;
        }
    }
    async download(id) { await this.init(); const p = this.path(id, '.sahht'), s = await lstat(p).catch(() => fail('Không có bản sao lưu.', 404)); if (!s.isFile() || s.isSymbolicLink())
        fail('Tệp sao lưu không hợp lệ.'); return { stream: createReadStream(p), bytes: s.size, name: `SAHHT-${id}.sahht` }; }
    async remove(id) { await this.init(); const p = this.path(id, '.sahht'); if ((await lstat(p)).isSymbolicLink())
        fail('Tệp sao lưu không hợp lệ.'); await rm(p); await rm(this.path(id, '.json'), { force: true }); return { ok: true }; }
    async verify(id, passphrase, maxSchema = databaseSchemaVersion) { if (this.busy)
        fail('Đang xử lý sao lưu; hãy đợi.', 429); this.busy = true; try {
        const meta = this.path(id, '.json'), archive = this.path(id, '.sahht');
        for (const p of [meta, archive])
            if ((await lstat(p)).isSymbolicLink())
                fail('Tệp sao lưu không hợp lệ.');
        const m = JSON.parse(await readFile(meta, 'utf8'));
        if (await fileHash(archive) !== m.sha256)
            fail('Checksum archive không khớp.');
        const result = await dryRunArchive(archive, passphrase, this.directory, maxSchema);
        m.integrity = 'VERIFIED_ARCHIVE';
        m.checkedAt = new Date().toISOString();
        await writeFile(meta, JSON.stringify(m, null, 2), { mode: 0o600 });
        return result;
    }
    finally {
        this.busy = false;
    } }
    async cleanup() { const days = this.options.retentionDays ?? 14; if (days < 7 || days > 90)
        fail('Retention cần7–90 ngày.'); for (const m of await this.list())
        if (m.reason === 'daily' && Date.parse(m.createdAt) < Date.now() - days * 86400000)
            await this.remove(m.id); }
}
export async function dryRunArchive(archive, passphrase, isolatedRoot, maxSchema = databaseSchemaVersion, stageDirectory) {
    if (typeof passphrase !== 'string' || passphrase.length < 16 || passphrase.length > 256)
        fail('Thiếu mật khẩu mã hóa hợp lệ.');
    await mkdir(isolatedRoot, { recursive: true, mode: 0o700 });
    const temp = await mkdtemp(join(resolve(isolatedRoot), '.verify-'));
    await chmod(temp, 0o700);
    try {
        const h = await open(archive, 'r'), size = (await h.stat()).size, head = Buffer.alloc(36), tag = Buffer.alloc(16);
        try {
            await h.read(head, 0, 36, 0);
            await h.read(tag, 0, 16, size - 16);
        }
        finally {
            await h.close();
        }
        if (size < 53 || !head.subarray(0, 8).equals(magic))
            fail('Định dạng sao lưu chưa hỗ trợ.');
        const key = await derive(passphrase, head.subarray(8, 24), 32), d = createDecipheriv('aes-256-gcm', key, head.subarray(24, 36));
        d.setAAD(magic);
        d.setAuthTag(tag);
        const packed = join(temp, 'payload.tar.gz');
        try {
            await pipeline(createReadStream(archive, { start: 36, end: size - 17 }), d, createWriteStream(packed, { mode: 0o600 }));
        }
        catch {
            fail('Sai mật khẩu hoặc archive đã hỏng.');
        }
        finally {
            key.fill(0);
        }
        const { stdout } = await run('tar', ['-tzf', packed], { maxBuffer: 1024 * 1024 });
        const names = stdout.trim().split(/\r?\n/);
        if (new Set(names).size !== names.length || names.some(n => !/^(manifest\.json|database\.sqlite|persistent-\d+\.json)$/.test(n)))
            fail('Archive chứa đường dẫn không hợp lệ.');
        // Không chấp nhận symlink/hardlink, thư mục hoặc tên tùy ý khi dry-run.
        const types = await run('tar', ['-tvzf', packed], { maxBuffer: 1024 * 1024 });
        if (types.stdout.trim().split(/\r?\n/).some(l => !l.startsWith('-')))
            fail('Archive chứa entry không phải tệp thường.');
        await run('tar', ['-xzf', packed, '-C', temp], { maxBuffer: 1024 * 1024 });
        const m = JSON.parse(await readFile(join(temp, 'manifest.json'), 'utf8'));
        if (m.format !== 'SAHHTB01' || !Array.isArray(m.files) || m.files.length + 1 !== names.length || !Number.isInteger(m.schema) || m.schema > maxSchema)
            fail('Manifest/schema không tương thích.');
        for (const f of m.files) {
            if (!names.includes(f.name) || f.name === 'manifest.json' || !/^[a-f0-9]{64}$/.test(f.sha256) || await fileHash(join(temp, f.name)) !== f.sha256 || (await stat(join(temp, f.name))).size !== f.bytes)
                fail('Checksum tệp không khớp.');
        }
        const schema = checkDatabase(join(temp, 'database.sqlite'));
        if (schema !== m.schema)
            fail('Schema manifest khác database.');
        if (stageDirectory) {
            if (dirname(resolve(stageDirectory)) !== resolve(isolatedRoot))
                fail('Vùng khôi phục phải là thư mục con mới trong khu vực cô lập.');
            await mkdir(stageDirectory, { mode: 0o700 });
            try {
                for (const name of names) {
                    await copyFile(join(temp, name), join(stageDirectory, name));
                    await chmod(join(stageDirectory, name), 0o600);
                }
            }
            catch (e) {
                await rm(stageDirectory, { recursive: true, force: true });
                throw e;
            }
        }
        return { ok: true, integrity: 'ok', schema, files: m.files.length, environment: m.environment, mode: stageDirectory ? 'ISOLATED_STAGE_ONLY' : 'DRY_RUN_ONLY', stageDirectory };
    }
    finally {
        await rm(temp, { recursive: true, force: true });
    }
}
