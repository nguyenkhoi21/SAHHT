import { appendFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { endpointEvidence } from './endpoint-evidence.js';
const safeFields = new Set(['method', 'config_name', 'version', 'kqg_cjxy']);
const safeNumericFields = new Set(['city', 'chapter', 'building', 'step_n', 'lvs', 'guide_team', 'guide_id']);
function safeFieldsOnly(value) {
    if (!value || typeof value !== 'object')
        return { type: typeof value, value: '[REDACTED]' };
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key,
        typeof item === 'string' && ((safeFields.has(key) && /^[a-zA-Z0-9_.-]{1,120}$/.test(item)) || (safeNumericFields.has(key) && /^-?\d{1,10}$/.test(item))) ? item : '[REDACTED]']));
}
function bodySummary(request) {
    const value = request.body;
    if (value === undefined)
        return { type: 'absent', declaredBytes: request.headers['content-length'] ?? null };
    if (typeof value === 'string') {
        const isForm = String(request.headers['content-type']).startsWith('application/x-www-form-urlencoded');
        return { type: isForm ? 'form' : 'text', bytes: Buffer.byteLength(value), fields: isForm ? safeFieldsOnly(Object.fromEntries(new URLSearchParams(value))) : '[REDACTED]' };
    }
    return { type: 'json', fields: safeFieldsOnly(value) };
}
export async function registerJournal(app, path, runId) {
    await mkdir(dirname(path), { recursive: true });
    const queuePath = join(dirname(path), 'unimplemented.jsonl');
    await appendFile(queuePath, '', 'utf8');
    const frequencies = new Map();
    const firstSeen = new Map();
    const observations = new WeakMap();
    const pendingWrites = new Set();
    app.addHook('onClose', async () => { await Promise.all([...pendingWrites]); });
    app.addHook('onRequest', async (request) => {
        observations.set(request, { timestamp: new Date().toISOString(), response: null });
    });
    app.addHook('onSend', async (request, reply, payload) => {
        let shape = null;
        if (typeof payload === 'string') {
            try {
                const body = JSON.parse(payload);
                shape = { keys: Object.keys(body), status: body.status, dataKeys: body.data && typeof body.data === 'object' ? Object.keys(body.data) : [], serverCount: Array.isArray(body.data?.server_list) ? body.data.server_list.length : undefined };
            }
            catch {
                shape = { type: 'non-json' };
            }
        }
        const record = observations.get(request);
        if (record)
            record.response = { statusCode: reply.statusCode, contentType: reply.getHeader('content-type') ?? null, bytes: typeof payload === 'string' ? Buffer.byteLength(payload) : null, shape };
        return payload;
    });
    app.addHook('onResponse', async (request, reply) => {
        const record = observations.get(request);
        const url = new URL(request.url, 'http://127.0.0.1');
        const headers = Object.fromEntries(['host', 'user-agent', 'accept', 'content-type', 'content-length'].filter(key => request.headers[key] !== undefined).map(key => [key, request.headers[key]]));
        const timestamp = record?.timestamp ?? new Date().toISOString();
        const metadata = { query: safeFieldsOnly(Object.fromEntries(url.searchParams)), body: bodySummary(request) };
        const writes = [appendFile(path, JSON.stringify({ timestamp, completedAt: new Date().toISOString(), runId, sourceEvidence: 'UNCLASSIFIED', auth: request.localAuthAudit, gameContext: request.gameContext, clientAddress: request.ip, durationMs: reply.elapsedTime, requestId: request.id, method: request.method, path: url.pathname, ...metadata, headers, response: record?.response ?? { statusCode: reply.statusCode } }) + '\n', 'utf8')];
        if (reply.statusCode === 501 || (reply.statusCode === 404 && /^\/(pub_abroad_vr\/)?(api|login|config)\//.test(url.pathname))) {
            const rpc = url.searchParams.get('method') ?? 'UNKNOWN';
            const method = /^[a-zA-Z0-9_.-]{1,120}$/.test(rpc) ? rpc : 'UNKNOWN';
            const key = request.method + ' ' + url.pathname + ' ' + method;
            const frequency = (frequencies.get(key) ?? 0) + 1;
            frequencies.set(key, frequency);
            if (!firstSeen.has(key))
                firstSeen.set(key, timestamp);
            const evidence = endpointEvidence[method];
            writes.push(appendFile(queuePath, JSON.stringify({ timestamp, runId, requestId: request.id,
                userId: request.gameContext?.userId ?? null, gameUid: request.gameContext?.gameUid ?? null,
                httpMethod: request.method, method, path: url.pathname, payloadMetadata: metadata,
                caller: evidence?.caller ?? 'UNKNOWN', screen: evidence?.screen ?? 'UNKNOWN', feature: evidence?.feature ?? 'UNKNOWN',
                blocking: evidence?.blocking ?? 'UNKNOWN', schemaStatus: evidence?.schemaStatus ?? 'UNKNOWN', firstSeen: firstSeen.get(key), lastSeen: timestamp,
                schemaEvidence: evidence ? 'STATIC VERIFIED' : 'UNKNOWN', currentResponse: record?.response ?? { statusCode: reply.statusCode },
                frequency, frequencyScope: 'run', sourceEvidence: 'UNCLASSIFIED' }) + '\n', 'utf8'));
        }
        const write = Promise.all(writes).then(() => undefined);
        pendingWrites.add(write);
        try {
            await write;
        }
        finally {
            pendingWrites.delete(write);
        }
    });
}
