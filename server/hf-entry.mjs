import { buildApp } from './dist/app.js';
import { runtimeConfig } from './dist/system/runtime.js';
import { AdminAuth } from './dist/admin/admin.auth.js';
import { openDatabase } from './dist/db/database.js';
import { installRegistrationRateLimit } from './dist/auth/registration-rate-limit.js';
import { installRegistrationAccountCapacity } from './dist/auth/registration-account-capacity.js';

process.env.ALLOW_REMOTE_ADMIN ??= '1';

const runtime = runtimeConfig();

// Tự tạo tài khoản GM đầu tiên và mở khóa đăng ký tài khoản
{
  const db = openDatabase(runtime.database);
  try {
    installRegistrationRateLimit(db);
    installRegistrationAccountCapacity(db);
    db.prepare("UPDATE local_registration_rules SET enabled=1, per_hour=100, per_day=500, reason='Mo dang ky cho server online' WHERE ip='*' AND enabled=0").run();

    const count = Number(db.prepare('SELECT count(*) AS c FROM admin_users').get()?.c ?? 0);
    if (count === 0) {
      const gmUser = process.env.GM_USER || 'admin';
      const gmPass = process.env.GM_PASS || 'SahhtGm@202611';
      await new AdminAuth(db).create(gmUser, gmPass, 'OWNER');
      console.log(`Đã khởi tạo tài khoản GM mặc định: ${gmUser}`);
    }
    db.sync?.();
  } catch (err) {
    console.error('Khởi tạo DB/GM thất bại:', err);
  } finally {
    db.close();
  }
}

const port = Number(process.env.PORT ?? 7860);
const app = await buildApp({
  logger: true,
  port,
  online: false,
  publicOrigin: runtime.origin,
  adminOrigin: runtime.origin,
  localAuth: true,
  accountDb: runtime.database,
  allowSynthetic: false,
  adminDev: false,
  journalPath: runtime.journal,
  runId: 'hf-turso-v1'
});

// Alias /gm -> /admin/
app.get('/gm', async (_req, reply) => reply.redirect('/admin/'));
app.get('/gm/', async (_req, reply) => reply.redirect('/admin/'));

await app.listen({ host: '0.0.0.0', port });
console.log(`SAHHT server (Turso) listening on 0.0.0.0:${port} (origin: ${runtime.origin})`);

const syncTimer = setInterval(() => {
  try {
    app.db?.sync?.();
  } catch (err) {
    console.error('Turso periodic sync error:', err);
  }
}, 60_000);

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    clearInterval(syncTimer);
    try {
      app.db?.sync?.();
    } catch {}
    await app.close();
    process.exit(0);
  });
}
