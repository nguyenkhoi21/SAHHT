import { buildApp } from './dist/app.js';
import { runtimeConfig } from './dist/system/runtime.js';

const runtime = runtimeConfig();

const port = Number(process.env.PORT ?? 7860);
const app = await buildApp({
  logger: true,
  port,
  online: false,
  publicOrigin: runtime.origin,
  localAuth: true,
  accountDb: runtime.database,
  allowSynthetic: false,
  adminDev: false,
  journalPath: runtime.journal,
  runId: 'hf-turso-v1'
});

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
