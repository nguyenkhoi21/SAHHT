import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
export function runtimeConfig(env = process.env) {
    const root = fileURLToPath(new URL('../../../', import.meta.url)), online = env.APP_ENV === 'online', port = Number(env.PORT ?? 8787);
    if (!Number.isInteger(port) || port < 1 || port > 65535)
        throw Error('PORT không hợp lệ.');
    const url = new URL(env.PUBLIC_API_ORIGIN ?? `http://127.0.0.1:${port}`);
    if (url.username || url.password || url.pathname !== '/' || url.search || url.hash || (online ? url.protocol !== 'https:' : !['http:', 'https:'].includes(url.protocol)))
        throw Error('PUBLIC_API_ORIGIN không hợp lệ; ONLINE bắt buộc HTTPS.');
    if (online && (env.ALLOW_SYNTHETIC_AUTH === '1' || env.ADMIN_DEV === '1'))
        throw Error('ONLINE không cho phép auth giả lập/Admin dev.');
    const database = resolve(env.ACCOUNT_DB_PATH ?? resolve(root, 'server/data/sahht-local.db'));
    if (online && (!env.ACCOUNT_DB_PATH || !env.BACKUP_DIRECTORY || !env.BACKUP_KEY_FILE))
        throw Error('ONLINE cần ACCOUNT_DB_PATH/BACKUP_DIRECTORY/BACKUP_KEY_FILE riêng.');
    return { online, port, origin: url.origin, database, backupDirectory: env.BACKUP_DIRECTORY ?? resolve(database, '../backups-secure'), journal: env.JOURNAL_PATH ?? resolve(root, 'logs/runtime/requests.jsonl') };
}
