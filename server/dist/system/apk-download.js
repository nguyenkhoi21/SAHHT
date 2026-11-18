import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { lstat } from 'node:fs/promises';
import { createReadStream } from 'node:fs';
// Chỉ vùng APK công khai đã chủ dự án cho phép phân phối; không dùng đường backup/DB.
export function registerApkDownload(app, directory = fileURLToPath(new URL('../../../public-downloads/', import.meta.url))) {
    app.get('/downloads/:name', async (r, reply) => {
        const name = r.params.name;
        if (!/^SAHHT-ONLINE-v[1-9]\d{0,3}\.apk$/.test(name))
            return reply.code(404).send({ error: 'Không có APK này.' });
        const path = join(directory, name), s = await lstat(path).catch(() => null);
        if (!s?.isFile() || s.isSymbolicLink())
            return reply.code(404).send({ error: 'APK chưa sẵn sàng.' });
        reply.type('application/vnd.android.package-archive').header('Content-Disposition', `attachment; filename="${name}"`).header('Cache-Control', 'public, max-age=86400').header('X-Content-Type-Options', 'nosniff').header('Accept-Ranges', 'bytes');
        let start = 0, end = s.size - 1;
        if (r.headers.range) {
            const m = /^bytes=(\d+)-(\d*)$/.exec(r.headers.range);
            if (!m || Number(m[1]) >= s.size || m[2] && Number(m[2]) < Number(m[1]))
                return reply.code(416).header('Content-Range', `bytes */${s.size}`).send();
            start = Number(m[1]);
            if (m[2])
                end = Math.min(Number(m[2]), end);
            reply.code(206).header('Content-Range', `bytes ${start}-${end}/${s.size}`);
        }
        return reply.header('Content-Length', end - start + 1).send(createReadStream(path, { start, end }));
    });
}
