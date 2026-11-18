import { buildApp } from './dist/app.js';
import { runtimeConfig } from './dist/system/runtime.js';

process.env.ALLOW_REMOTE_ADMIN ??= '1';

const runtime = runtimeConfig();
const port = Number(process.env.PORT ?? 7860);

console.log(`Booting SAHHT server on port ${port}...`);
const app = await buildApp({
  logger: true,
  port,
  online: false,
  publicOrigin: 'http://127.0.0.1:18787',
  adminOrigin: runtime.origin,
  localAuth: true,
  accountDb: runtime.database,
  allowSynthetic: false,
  adminDev: false,
  journalPath: runtime.journal,
  runId: 'hf-turso-v1'
});

app.get('/gm', async (_req, reply) => reply.redirect('/admin/'));
app.get('/gm/', async (_req, reply) => reply.redirect('/admin/'));

await app.listen({ host: '0.0.0.0', port });
console.log(`SAHHT server (Turso) listening on 0.0.0.0:${port} (origin: ${runtime.origin})`);

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    await app.close();
    process.exit(0);
  });
}
