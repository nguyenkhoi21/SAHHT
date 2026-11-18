import { RegistrationAccountCapacityError } from './registration-account-capacity.js';
import { AuthError } from './auth.service.js';
import { RegistrationRateLimitError } from './registration-rate-limit.js';
const token = (request) => /^Bearer (local_[a-f0-9]{64})$/.exec(request.headers.authorization ?? '')?.[1] ?? '';
export function registerAuthRoutes(app, service) {
    const failures = new Map();
    const refreshFailures = new Map();
    for (const action of ['remember', 'refresh', 'forget'])
        app.post('/local-auth/' + action, { bodyLimit: 4096 }, async (request, reply) => {
            const b = (typeof request.body === 'string' ? Object.fromEntries(new URLSearchParams(request.body)) : request.body);
            try {
                if (action === 'refresh') {
                    const r = refreshFailures.get(request.ip);
                    if (r && Date.now() - r.start < 60000 && r.count >= 30)
                        throw new AuthError(429, 'REMEMBER_RATE_LIMIT', 'Thử lại quá nhiều lần. Vui lòng đợi một phút.');
                    try {
                        const result = service.refreshRemembered(b?.username, b?.credential);
                        refreshFailures.delete(request.ip);
                        return result;
                    }
                    catch (e) {
                        if (refreshFailures.size >= 1000)
                            refreshFailures.delete(refreshFailures.keys().next().value);
                        refreshFailures.set(request.ip, r && Date.now() - r.start < 60000 ? { ...r, count: r.count + 1 } : { count: 1, start: Date.now() });
                        throw e;
                    }
                }
                if (action === 'forget') {
                    service.forgetRemembered(b?.credential);
                    return { ok: true };
                }
                const s = service.session(token(request) || b?.sessionToken);
                if (!s)
                    throw new AuthError(401, 'SESSION_EXPIRED', 'Hãy đăng nhập lại.');
                return { ok: true, remembered: service.remember(s) };
            }
            catch (e) {
                if (e instanceof AuthError)
                    return reply.code(e.status).send({ ok: false, code: e.code, message: e.message });
                throw e;
            }
        });
    for (const event of ['register', 'login']) {
        app.post(`/local-auth/${event}`, { bodyLimit: 4096 }, async (request, reply) => {
            try {
                const body = typeof request.body === 'string' ? Object.fromEntries(new URLSearchParams(request.body)) : request.body;
                const username = service.normalizeUsername(body?.username);
                const rateKey = request.ip + ':' + username, rate = failures.get(rateKey);
                if (event === 'login' && rate && Date.now() - rate.start < 900000 && rate.count >= 10)
                    throw new AuthError(429, 'LOGIN_RATE_LIMIT', 'Đã thử sai quá nhiều lần. Hãy thử lại sau 15 phút.');
                request.localAuthAudit = { event, result: 'pending', username };
                const result = event === 'register' ? await service.register(username, body?.password, request.ip) : await service.login(username, body?.password);
                failures.delete(rateKey);
                const user = 'user' in result ? result.user : result;
                request.localAuthAudit = { event, result: 'ok', username: user.username, userId: user.id };
                return reply.code(event === 'register' ? 201 : 200).send({ ok: true, ...(event === 'register' ? { user: result } : result) });
            }
            catch (error) {
                if (event === 'login' && error instanceof AuthError && error.code === 'INVALID_CREDENTIALS') {
                    const rateKey = request.ip + ':' + request.localAuthAudit?.username, old = failures.get(rateKey);
                    if (failures.size >= 1000)
                        failures.delete(failures.keys().next().value);
                    failures.set(rateKey, old && Date.now() - old.start < 900000 ? { ...old, count: old.count + 1 } : { count: 1, start: Date.now() });
                }
                const status = error instanceof AuthError ? error.status : error instanceof RegistrationRateLimitError ? 429 : error instanceof RegistrationAccountCapacityError ? 409 : 0;
                const code = error instanceof AuthError || error instanceof RegistrationRateLimitError || error instanceof RegistrationAccountCapacityError ? error.code : 'DATABASE_FAILURE';
                request.localAuthAudit = { event, ...request.localAuthAudit, result: code };
                if (error instanceof RegistrationRateLimitError)
                    reply.header('Retry-After', Math.max(1, Math.ceil((error.retryAt - Date.now()) / 1000))).header('Cache-Control', 'no-store');
                if (error instanceof RegistrationAccountCapacityError)
                    reply.header('Cache-Control', 'no-store');
                if (status)
                    return reply.code(status).send({ ok: false, code, message: error.message, ...(error instanceof RegistrationRateLimitError ? { retryAt: error.retryAt } : {}) });
                request.log.error({ event, code: 'LOCAL_AUTH_FAILURE' }, 'Lỗi dịch vụ tài khoản local');
                return reply.code(503).send({ ok: false, code: 'SERVER_UNAVAILABLE', message: 'Máy chủ thử nghiệm đang bận. Vui lòng thử lại.' });
            }
        });
    }
    app.get('/local-auth/session', async (request, reply) => {
        const current = service.session(token(request));
        request.localAuthAudit = { event: 'session', result: current ? 'ok' : 'expired', userId: current?.user_id };
        if (!current)
            return reply.code(401).send({ ok: false, message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.' });
        return { ok: true, user: { id: current.user_id, username: current.username }, expiresAt: new Date(current.expires_at).toISOString() };
    });
    app.post('/local-auth/change-password', { bodyLimit: 4096 }, async (request, reply) => {
        const body = (typeof request.body === 'string' ? Object.fromEntries(new URLSearchParams(request.body)) : request.body);
        // Cocos HTTP form hiện không có binding setHeaders; session chỉ nhận trong body, không query/log.
        const current = service.session(token(request) || body?.sessionToken);
        if (!current)
            return reply.code(401).send({ ok: false, message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.' });
        request.localAuthAudit = { event: 'change_password', result: 'pending', userId: current.user_id };
        try {
            const result = await service.changePassword(current, body?.currentPassword, body?.newPassword, body?.confirmPassword);
            request.localAuthAudit.result = 'ok';
            return result;
        }
        catch (e) {
            if (e instanceof AuthError) {
                request.localAuthAudit.result = e.code;
                return reply.code(e.status).send({ ok: false, code: e.code, message: e.message });
            }
            throw e;
        }
    });
    app.post('/local-auth/logout', async (request) => {
        const body = (typeof request.body === 'string' ? Object.fromEntries(new URLSearchParams(request.body)) : request.body);
        const secret = token(request) || (typeof body?.sessionToken === 'string' ? body.sessionToken : '');
        const current = service.session(secret);
        service.logout(secret);
        request.localAuthAudit = { event: 'logout', result: 'ok', userId: current?.user_id };
        return { ok: true };
    });
    app.post('/local-auth/resume', { bodyLimit: 4096 }, async (request, reply) => {
        const body = (typeof request.body === 'string' ? Object.fromEntries(new URLSearchParams(request.body)) : request.body);
        const secret = token(request) || body?.sessionToken, current = service.session(secret);
        if (!current)
            return reply.code(401).send({ ok: false, message: 'Phiên đã hết hạn. Hãy nhập mật khẩu.' });
        return { ok: true, user: { id: current.user_id, username: current.username }, authResult: { result: true, platform: 'kvgames', needverify: true, userID: 'local_user_' + current.user_id, session_id: secret } };
    });
}
