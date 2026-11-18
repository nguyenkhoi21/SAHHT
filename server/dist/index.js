import { buildApp } from './app.js';
import { runtimeConfig } from './system/runtime.js';
import { beforeMigration } from './system/backup-cli.js';
const runtime = runtimeConfig();
const port = runtime.port;
if (!Number.isInteger(port) || port < 1 || port > 65535)
    throw new Error('PORT không hợp lệ');
if (runtime.online)
    await beforeMigration(runtime);
const app = await buildApp({ logger: true, port, online: runtime.online, onlineUnified: runtime.online && process.env.ONLINE_UNIFIED_RELEASE === '1', publicOrigin: runtime.origin, backupDirectory: runtime.backupDirectory, adminDev: process.env.ADMIN_DEV === '1', adminOrigin: runtime.online ? runtime.origin : process.env.ADMIN_ORIGIN, localAuth: runtime.online || process.env.LOCAL_AUTH_MODE === '1', accountDb: runtime.online || process.env.LOCAL_AUTH_MODE === '1' ? runtime.database : undefined, allowSynthetic: process.env.ALLOW_SYNTHETIC_AUTH === '1', journalPath: runtime.journal, runId: process.env.RUNTIME_RUN_ID ?? `${runtime.online ? 'online' : 'local'}-${new Date().toISOString()}` });
await app.listen({ host: '127.0.0.1', port });
for (const signal of ['SIGINT', 'SIGTERM']) {
    process.on(signal, async () => { await app.close(); process.exit(0); });
}
