import { databaseSchemaVersion } from '../db/database.js';
import { DatabaseSync } from 'node:sqlite';
import { readFile, access, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { BackupStore, dryRunArchive, persistentBackupFiles } from './backup.js';
import { runtimeConfig } from './runtime.js';
import { randomUUID } from 'node:crypto';
import { hiddenInput } from './hidden-input.js';
export async function beforeMigration(r) { try {
    await access(r.database);
}
catch {
    return;
} const d = new DatabaseSync(r.database, { readOnly: true }); try {
    const version = Number(d.prepare('PRAGMA user_version').get().user_version);
    if (version > databaseSchemaVersion)
        throw Error('Schema mới hơn backend; không được rollback database.');
    if (version < databaseSchemaVersion) {
        const secret = (await readFile(process.env.BACKUP_KEY_FILE, 'utf8')).trim(), b = new BackupStore(d, { directory: r.backupDirectory, environment: 'ONLINE' }), created = await b.create(secret, 'pre-migration');
        await b.verify(created.id, secret);
    }
}
finally {
    d.close();
} }
async function main() {
    const r = runtimeConfig(), mode = process.argv[2] ?? 'daily', secret = mode.endsWith('-manual') ? await hiddenInput('Mật khẩu mã hóa archive (ẩn): ') : (await readFile(process.env.BACKUP_KEY_FILE, 'utf8')).trim();
    if (['dry-run', 'dry-run-manual', 'stage-restore', 'stage-restore-manual'].includes(mode)) {
        const archive = process.argv[3];
        if (!archive)
            throw Error('Thiếu đường dẫn archive.');
        console.log(JSON.stringify(await dryRunArchive(archive, secret, r.backupDirectory, databaseSchemaVersion, mode.startsWith('stage-restore') ? join(r.backupDirectory, 'restore-stage-' + randomUUID()) : undefined)));
        return;
    }
    const db = new DatabaseSync(r.database, { readOnly: true });
    try {
        const b = new BackupStore(db, { directory: r.backupDirectory, environment: r.online ? 'ONLINE' : 'LOCAL', dataFiles: persistentBackupFiles(), retentionDays: Number(process.env.BACKUP_RETENTION_DAYS ?? 14) }), created = await b.create(secret, mode);
        await b.verify(created.id, secret);
        await b.cleanup();
        await writeFile(join(r.backupDirectory, 'automatic-status.json'), JSON.stringify({ ok: true, at: new Date().toISOString(), id: created.id }), { mode: 0o600 });
        console.log(JSON.stringify({ ok: true, id: created.id, schema: created.schema }));
    }
    catch (e) {
        await writeFile(join(r.backupDirectory, 'automatic-status.json'), JSON.stringify({ ok: false, at: new Date().toISOString(), error: 'BACKUP_FAILED' }), { mode: 0o600 }).catch(() => { });
        throw e;
    }
    finally {
        db.close();
    }
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href)
    await main();
