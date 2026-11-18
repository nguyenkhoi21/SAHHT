import { readConfigSync } from './local-content.js';
import { configuredCity } from './stage.service.js';
import { audit } from '../admin/admin.audit.js';
import { levelState, LOCAL_MAX_LEVEL } from './progression.js';
import { naturalFormationSlots } from './player-vitals.js';
import { TutorialService } from './tutorial.js';
export const progressionError = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
let graphPromise;
export function stageGraph() { return graphPromise ??= buildGraph(); }
async function buildGraph() {
    const stories = readConfigSync('map_main_story'), chapters = readConfigSync('chapter'), titles = readConfigSync('map_title_detail'), fights = readConfigSync('map_fight'), maps = readConfigSync('map');
    const cities = [], stages = [], blocked = [], adapters = [];
    for (const [storyId, story] of Object.entries(stories).sort((a, b) => Number(a[0]) - Number(b[0]))) {
        const city = String(story.stage_id), chapter = String(story.chapter);
        let reason = '';
        let localAdapter = false;
        try {
            await configuredCity(city, chapter);
        }
        catch (e) {
            reason = e.message;
            if (reason.includes('footprint')) {
                try {
                    await configuredCity(city, chapter, true);
                    reason = '';
                    localAdapter = true;
                }
                catch { }
            }
        }
        const buildings = [...new Set((maps[city] ?? []).flat().filter((id) => id > 0).map(String))];
        const entries = [];
        for (const building of buildings) {
            const cfg = titles[building];
            if (!Array.isArray(cfg?.fight_list) || !cfg.fight_list.length) {
                reason ||= 'Thiếu fight_list';
                continue;
            }
            cfg.fight_list.forEach((tuple, step) => { const fightId = String(tuple[1]); if (!fights[fightId])
                reason ||= 'Thiếu map_fight ' + fightId; entries.push({ key: city + ':' + building + ':' + step, storyId, city, chapter, building, step, fightId, name: tuple[0], previous: step ? city + ':' + building + ':' + (step - 1) : null }); });
        }
        const entry = { storyId, city, chapter, name: story.stage_name, difficulty: chapters[chapter]?.is_hard, openLevel: Math.max(story.open_level, chapters[chapter]?.open_level ?? 1), steps: entries.map(s => s.key), buildings, valid: !reason, reason, localAdapter };
        if (localAdapter)
            adapters.push({ city, reason: 'LOCAL anchor adapter: giữ anchor gốc, bỏ cell phụ bị chồng. Chưa xác minh layout server production.' });
        cities.push(entry);
        if (reason)
            blocked.push(entry);
        else
            stages.push(...entries);
    }
    return { version: 'vn-code10-local-progression-v2', cities, stages, blocked, adapters, chapters: Object.keys(chapters), maxStars: null, notice: 'Client bản đồ gốc dùng phần trăm thu hồi, chưa tìm thấy contract sao. Không tự tạo sao hoặc gói quà GM.' };
}
export class ProgressionService {
    db;
    constructor(db) {
        this.db = db;
    }
    access(id) { const row = this.db.prepare('SELECT state FROM player_map_access WHERE user_id=?').get(id); return row ? JSON.parse(row.state) : null; }
    completed(id) { return new Set(this.db.prepare('SELECT city,building,step FROM player_stage_steps WHERE user_id=?').all(id).map(r => r.city + ':' + r.building + ':' + r.step)); }
    async status(id) {
        const graph = await stageGraph(), natural = this.completed(id), access = this.access(id), full = access?.mode === 'LOCAL_GM_COMPLETE';
        const done = new Set([...natural, ...(full ? access.completed : [])]), cities = graph.cities.map((c) => ({ ...c, completed: c.valid && c.steps.every((k) => done.has(k)), percent: c.steps.length ? Math.floor(c.steps.filter((k) => done.has(k)).length * 100 / c.steps.length) : 0 }));
        const snapshot = this.db.prepare('SELECT id,created_at FROM map_completion_snapshots WHERE user_id=? AND restored_at IS NULL').get(id);
        return { graph, done, cities, summary: { totalStages: graph.stages.length, completedStages: graph.stages.filter((s) => done.has(s.key)).length, totalCities: cities.filter((c) => c.valid).length, completedCities: cities.filter((c) => c.completed).length, totalChapters: graph.chapters.length, completedChapters: graph.chapters.filter((ch) => { const cs = cities.filter((c) => c.chapter === ch); return cs.length && cs.every((c) => c.completed); }).length, maxStars: null, formation: this.slots(id), features: this.featureGates(id), ...this.featureUnlockInfo(id), featuresUnlocked: access?.featureUnlock === true, snapshot, blocked: graph.blocked, adapters: graph.adapters }, access };
    }
    featureUnlockInfo(id) {
        const row = this.db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(id);
        const profile = row ? JSON.parse(row.profile) : {}, formation = row ? JSON.parse(row.formation) : {}, main = formation.alignment?.[0] ?? [];
        const ready = main.slice(0, 5).some((heroId) => heroId !== '-1' && !!this.db.prepare('SELECT 1 FROM player_heroes WHERE user_id=? AND id=?').get(id, heroId));
        return { playerLevel: profile.level ?? 1, featureUnlockLevel: LOCAL_MAX_LEVEL, featureUnlockReady: ready, featureUnlockReason: ready ? null : 'Hãy xếp ít nhất một tướng sở hữu vào đội hình chính trước khi mở chức năng cấp cao.' };
    }
    featureGates(id) {
        const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id);
        if (!row)
            return [];
        const profile = JSON.parse(row.profile), guide = this.profileFields(id, profile).guide, links = readConfigSync('guide_button_open_new'), teams = readConfigSync('guide_team'), tips = readConfigSync('button_open');
        const names = { 200: 'Đấu Trường', 700: 'Hoạt Động', 800: 'Ải khó', 502: 'Tiến hóa', 503: 'Kỹ năng', 601: 'Trang bị' };
        return Object.entries(links).map(([buttonId, [team, step]]) => {
            const cfg = teams[String(team)], met = cfg?.open_sort === 2 ? (profile.level ?? 1) >= cfg.open_value : (guide[String(team)] ?? -1) >= step;
            return { buttonId: Number(buttonId), name: names[buttonId] ?? 'Chức năng #' + buttonId, guideTeam: team, guideStep: step, requirement: { kind: { 1: 'initial', 2: 'level', 3: 'building', 4: 'city' }[cfg?.open_sort] ?? 'unsupported', value: cfg?.open_value }, prerequisiteMet: met, guideCompleted: (guide[String(team)] ?? -1) >= step, description: tips[buttonId] ?? 'Chưa có mô tả mở chức năng trong nguồn.', evidence: 'STATIC VERIFIED / SERVER VERIFIED', notice: 'Điều kiện mở menu; trạng thái gameplay cần kiểm riêng trên Android.' };
        });
    }
    slots(id) { const access = this.access(id), row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id), p = row ? JSON.parse(String(row.profile)) : {}; const natural = naturalFormationSlots(p.level ?? 1); return { position_num: access?.formationOverride ? Math.max(5, natural.position_num) : natural.position_num, alternate_num: access?.formationOverride ? Math.max(3, natural.alternate_num) : natural.alternate_num }; }
    updateGuide(id, team, value) {
        const key = String(team), index = Number(value), guides = readConfigSync('guide'), cfg = readConfigSync('guide_team')[key];
        if (!cfg || !Number.isSafeInteger(index) || !guides[key]?.[String(index)])
            progressionError('Bước hướng dẫn không có trong config.');
        this.db.exec('BEGIN IMMEDIATE');
        try {
            if (key === '1' && new TutorialService(this.db).guide(id, index)) {
                this.db.exec('COMMIT');
                return {};
            }
            const row = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id), p = JSON.parse(row.profile), derived = this.profileFields(id, p).guide;
            if (cfg.open_sort !== 1 && cfg.open_sort !== 2 && !(derived[key] >= index))
                progressionError('Chưa đạt điều kiện map cho hướng dẫn.');
            if (cfg.open_sort === 2 && (p.level ?? 1) < cfg.open_value)
                progressionError('Chưa đạt level hướng dẫn.');
            // Guide phát sinh từ hoàn thành GM chỉ là overlay. Không chép vào profile vĩnh viễn,
            // nếu không restore snapshot sẽ để lại menu đã mở dù không còn đạt map.
            const access = this.access(id), mapDerived = cfg.open_sort === 3 || cfg.open_sort === 4, qaDerived = mapDerived && access?.mode === 'LOCAL_GM_COMPLETE' || access?.featureUnlock === true && [1, 2].includes(cfg.open_sort);
            if (!qaDerived)
                p.guide = { ...(p.guide ?? {}), [key]: Math.max(p.guide?.[key] ?? -1, index) };
            this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p), id);
            this.db.exec('COMMIT');
            return {};
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
    }
    profileFields(id, profile) {
        const natural = this.completed(id), access = this.access(id), done = new Set([...natural, ...(access?.mode === 'LOCAL_GM_COMPLETE' ? access.completed : [])]), maps = readConfigSync('map'), titles = readConfigSync('map_title_detail'), guide = { ...(profile.guide ?? {}) };
        const buildingDone = (b, city) => titles[b]?.fight_list?.length > 0 && titles[b].fight_list.every((_, i) => done.has(city + ':' + b + ':' + i));
        const cityDone = (city) => { const buildings = [...new Set((maps[city] ?? []).flat().filter((n) => n > 0).map(String))]; return buildings.length > 0 && buildings.every(b => buildingDone(b, city)); };
        const teams = readConfigSync('guide_team'), guides = readConfigSync('guide');
        for (const [key, cfg] of Object.entries(teams)) {
            const allowed = cfg.open_sort === 4 ? cityDone(String(cfg.open_value)) : cfg.open_sort === 3 ? Object.keys(maps).some(city => (maps[city] ?? []).flat().includes(cfg.open_value) && buildingDone(String(cfg.open_value), city)) : access?.featureUnlock === true && (cfg.open_sort === 1 || cfg.open_sort === 2 && (profile.level ?? 1) >= cfg.open_value);
            if (allowed)
                guide[key] = Math.max(guide[key] ?? -1, ...Object.keys(guides[key] ?? {}).map(Number));
        }
        return { guide };
    }
    async derivedProfile(id, profile) {
        const status = await this.status(id), guide = { ...(profile.guide ?? {}) }, teams = readConfigSync('guide_team'), guides = readConfigSync('guide');
        for (const [id, cfg] of Object.entries(teams)) {
            const allowed = cfg.open_sort === 4 ? status.cities.some((c) => c.city === String(cfg.open_value) && c.completed) : cfg.open_sort === 3 ? status.graph.stages.filter((s) => s.building === String(cfg.open_value)).length > 0 && status.graph.stages.filter((s) => s.building === String(cfg.open_value)).every((s) => status.done.has(s.key)) : false;
            if (allowed)
                guide[id] = Math.max(guide[id] ?? -1, ...Object.keys(guides[id] ?? {}).map(Number));
        }
        return { guide };
    }
    async completeAll(id, formationOverride, adminId, unlockFeatures = false) {
        const graph = await stageGraph();
        let replayed = false, levelChanged = false;
        this.db.exec('BEGIN IMMEDIATE');
        try {
            const prior = this.access(id), active = this.db.prepare('SELECT id,applied_state FROM map_completion_snapshots WHERE user_id=? AND restored_at IS NULL').get(id);
            const profileRow = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id);
            if (!profileRow)
                progressionError('Tài khoản chưa vào game để tạo tiến trình.');
            const profile = JSON.parse(profileRow.profile), beforeLevel = { level: profile.level, exp: profile.exp, exp_max: profile.exp_max };
            if (unlockFeatures && !this.featureUnlockInfo(id).featureUnlockReady)
                progressionError(this.featureUnlockInfo(id).featureUnlockReason);
            if (active && unlockFeatures && JSON.stringify(prior) !== active.applied_state)
                progressionError('Override đã thay đổi sau snapshot; hãy kiểm tra trước khi mở chức năng.');
            if (unlockFeatures && (profile.level ?? 1) < LOCAL_MAX_LEVEL) {
                const { _local_mission_preview, ...clean } = profile;
                this.db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify({ ...clean, ...levelState(LOCAL_MAX_LEVEL) }), id);
                levelChanged = true;
            }
            replayed = !!active && (!unlockFeatures || prior?.featureUnlock === true && !levelChanged);
            if (!replayed) {
                const state = active ? { ...prior, featureUnlock: true } : { storyIds: graph.cities.filter((c) => c.valid).map((c) => c.storyId), cityIds: graph.cities.filter((c) => c.valid).map((c) => c.city), mode: 'LOCAL_GM_COMPLETE', completed: graph.stages.map((s) => s.key), formationOverride, version: graph.version, ...(unlockFeatures ? { featureUnlock: true } : {}) };
                if (active)
                    this.db.prepare('UPDATE map_completion_snapshots SET applied_state=? WHERE id=?').run(JSON.stringify(state), active.id);
                else
                    this.db.prepare('INSERT INTO map_completion_snapshots(user_id,before_state,applied_state,created_at) VALUES(?,?,?,?)').run(id, prior ? JSON.stringify(prior) : null, JSON.stringify(state), Date.now());
                this.db.prepare('INSERT INTO player_map_access VALUES(?,?) ON CONFLICT(user_id) DO UPDATE SET state=excluded.state').run(id, JSON.stringify(state));
                audit(this.db, adminId, unlockFeatures ? 'map.complete_features' : 'map.complete_all', id, unlockFeatures ? 'Full map + menu theo map/cấp; đặt cấp GM250, không mở sự kiện ngoài lịch' : 'Hoàn thành GM, không phát thưởng; snapshot có thể khôi phục', { access: prior, level: beforeLevel }, { stages: state.completed.length, formationOverride: state.formationOverride, featureUnlock: !!state.featureUnlock, level: unlockFeatures ? Math.max(profile.level ?? 1, LOCAL_MAX_LEVEL) : profile.level });
            }
            this.db.exec('COMMIT');
        }
        catch (e) {
            this.db.exec('ROLLBACK');
            throw e;
        }
        return { ok: true, replayed, levelChanged, ...(await this.status(id)).summary };
    }
    restore(id) {
        const snap = this.db.prepare('SELECT * FROM map_completion_snapshots WHERE user_id=? AND restored_at IS NULL').get(id);
        if (!snap)
            progressionError('Không có snapshot tiến trình đang áp dụng.');
        const row = this.db.prepare('SELECT state FROM player_map_access WHERE user_id=?').get(id);
        if (row?.state !== snap.applied_state)
            progressionError('Override đã thay đổi sau snapshot; không ghi đè tiến trình mới.');
        // Không khóa/xóa hero đang dùng ở slot QA: yêu cầu người dùng gỡ trước, không sửa đội âm thầm.
        const form = JSON.parse(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(id).formation);
        const old = snap.before_state ? JSON.parse(snap.before_state) : null;
        const profile = JSON.parse(String(this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id).profile)), natural = naturalFormationSlots(profile.level ?? 1);
        if (!old?.formationOverride && form.alignment.flat().some((v, i) => v !== '-1' && (i < 5 ? i >= natural.position_num : i - 5 >= natural.alternate_num)))
            progressionError('Hãy gỡ tướng khỏi các vị trí QA bổ sung trước khi khôi phục tiến trình.');
        if (snap.before_state)
            this.db.prepare('UPDATE player_map_access SET state=? WHERE user_id=?').run(snap.before_state, id);
        else
            this.db.prepare('DELETE FROM player_map_access WHERE user_id=?').run(id);
        this.db.prepare('UPDATE map_completion_snapshots SET restored_at=? WHERE id=?').run(Date.now(), snap.id);
        return { ok: true, notice: 'Đã khôi phục override map/menu; giữ cấp người chơi hiện tại cùng battle tự nhiên, hero, trang bị, tiền và Giftcode. Nếu đã cấp GM250, dùng mục Tiến trình người chơi để đổi cấp riêng.' };
    }
}
