import { buildApp } from './dist/app.js';
import { runtimeConfig } from './dist/system/runtime.js';
import { flushTursoWrites } from './dist/db/database.js';

process.env.ALLOW_REMOTE_ADMIN ??= '1';

const runtime = runtimeConfig();
const port = Number(process.env.PORT ?? 7860);

console.log(`Booting SAHHT server on port ${port}...`);
const app = await buildApp({
  logger: false,
  port,
  online: false,
  publicOrigin: 'http://127.0.0.1:18787',
  adminOrigin: runtime.origin,
  localAuth: true,
  accountDb: runtime.database,
  allowSynthetic: false,
  adminDev: false,
  journalPath: undefined,
  runId: 'hf-turso-v1'
});

app.get('/gm', async (_req, reply) => reply.redirect('/admin/'));
app.get('/gm/', async (_req, reply) => reply.redirect('/admin/'));

await app.listen({ host: '0.0.0.0', port });
console.log(`SAHHT server (fast local sqlite + async Turso sync) listening on 0.0.0.0:${port}`);

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    await flushTursoWrites();
    await app.close();
    process.exit(0);
  });
}
