import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { audit } from '../admin/admin.audit.js';
import { readConfigSync } from './local-content.js';
const root = new URL('../../../', import.meta.url);
const manifest = JSON.parse(readFileSync(new URL('tools/runtime/client-presentation-source.json', root), 'utf8'));
const cache = new Map();
export function presentationSource(name) {
    if (cache.has(name))
        return cache.get(name);
    const entry = manifest.tables[name];
    if (!entry)
        throw Error('Không có bảng nguồn đã xác minh.');
    const raw = readFileSync(new URL(entry.path, root));
    if (createHash('sha256').update(raw).digest('hex') !== entry.sha256)
        throw Error('Hash nguồn không khớp: ' + name);
    const result = JSON.parse(raw.toString());
    cache.set(name, result);
    return result;
}
export const presentationFail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
export function discordLink(value) {
    if (typeof value !== 'string' || value.length > 200)
        presentationFail('Link Discord tối đa200ký tự.');
    if (value === '')
        return '';
    if (!/^https:\/\/(?:discord\.gg\/[A-Za-z0-9-]{2,100}|discord\.com\/invite\/[A-Za-z0-9-]{2,100})$/.test(value))
        presentationFail('Dùng https://discord.gg/mã hoặc https://discord.com/invite/mã, không thêm query.');
    return value;
}
export class ClientPresentation {
    db;
    constructor(db) {
        this.db = db;
    }
    animations() { const heroes = readConfigSync('character_detail'); return manifest.animations.map((a) => { const match = Object.entries(heroes).find(([, h]) => h.animation === a.id); return { id: a.id, name: match?.[1].name ?? a.id, heroId: match ? Number(match[0]) : null }; }); }
    settings() { const row = this.db.prepare('SELECT revision,definition FROM client_presentation_settings WHERE id=1').get(); const definition = row ? JSON.parse(String(row.definition)) : { captionEnabled: true, captions: ['Đang tải… Chúc bạn có những trận đấu vui vẻ!'], animationMode: 'source', animations: ['ailisi'], discordUrl: 'https://discord.gg/wabQhDQEfM' }; delete definition.inviteRewards; return { revision: Number(row?.revision ?? 0), definition }; }
    validate(d) {
        if (!d || typeof d.captionEnabled !== 'boolean' || !Array.isArray(d.captions) || !d.captions.length || d.captions.length > 12 || d.captions.some((v) => typeof v !== 'string' || !v.trim() || v.length > 240 || /[\x00-\x08\x0b-\x1f\x7f]/.test(v)))
            presentationFail('Cần1–12chú thích, mỗi dòng1–240ký tự.');
        if (!['source', 'selected'].includes(d.animationMode) || !Array.isArray(d.animations) || !d.animations.length || d.animations.length > 12 || new Set(d.animations).size !== d.animations.length || d.animations.some((v) => !manifest.animations.some((a) => a.id === v)))
            presentationFail('Chọn1–12hoạt ảnh có sẵn, không trùng.');
        return { captionEnabled: d.captionEnabled, captions: d.captions.map((v) => v.trim()), animationMode: d.animationMode, animations: [...d.animations], discordUrl: discordLink(d.discordUrl) };
    }
    save(admin, revision, d) { const definition = this.validate(d); if (!Number.isSafeInteger(revision) || revision < 0)
        presentationFail('Revision không hợp lệ.'); this.db.exec('BEGIN IMMEDIATE'); try {
        const old = this.settings();
        if (old.revision !== revision)
            presentationFail('Cấu hình đã thay đổi; tải lại trước khi lưu.');
        const next = revision + 1, stored = this.db.prepare('SELECT definition FROM client_presentation_settings WHERE id=1').get(), inviteRewards = stored ? JSON.parse(String(stored.definition)).inviteRewards : undefined, combined = { ...definition, ...(inviteRewards ? { inviteRewards } : {}) };
        this.db.prepare('INSERT INTO client_presentation_settings VALUES(1,?,?,?) ON CONFLICT(id) DO UPDATE SET revision=excluded.revision,definition=excluded.definition,updated_at=excluded.updated_at').run(next, JSON.stringify(combined), Date.now());
        audit(this.db, admin, 'client.presentation.save', null, 'Đổi chú thích tải, hoạt ảnh hoặc Discord LOCAL', old, { revision: next, definition });
        this.db.exec('COMMIT');
        return { revision: next, definition };
    }
    catch (e) {
        this.db.exec('ROLLBACK');
        throw e;
    } }
    wire(level = 1) { const { revision, definition: d } = this.settings(); const row = presentationSource('loading')[String(Math.min(250, Math.max(1, Math.floor(level))))]; let animations = d.animationMode === 'selected' ? d.animations : (row?.loading_animition ?? ['ailisi']).filter((n) => manifest.animations.some((a) => a.id === n)); if (!animations.length)
        animations = ['ailisi']; return { schema: 1, revision, captionEnabled: d.captionEnabled, captions: d.captions, animations, discordUrl: d.discordUrl }; }
    admin() { return { ...this.settings(), animations: this.animations(), notice: 'Đồng bộ khi về Main/đăng nhập; màn tải đầu phiên dùng cache lần trước hoặc chú thích Việt mặc định. Chỉ chọn hoạt ảnh đã có trong APK, không nạp mã/asset bên ngoài.' }; }
}
