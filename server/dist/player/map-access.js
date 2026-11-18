import { contentIndex } from './content-index.js';
import { initialWorldMap, openInitialCity, buildingEnemies, configuredCity, configuredBuildingEnemies } from './stage.service.js';
import { ProgressionService } from './progression.service.js';
const fail = (s) => { throw Object.assign(new Error(s), { statusCode: 422 }); };
// GM chỉ mở quyền chọn từ catalog, không đánh dấu thắng/sao/first-clear hoặc cấp thưởng.
export class MapAccessService {
    db;
    constructor(db) {
        this.db = db;
    }
    async hardOpen(id, city, chapter) {
        const status = await new ProgressionService(this.db).status(id);
        if (status.access?.mode !== 'LOCAL_GM_COMPLETE')
            fail('Khiêu chiến tinh anh hiện chỉ hỗ trợ tài khoản có 100% MAP QA; hạn lượt tự nhiên chưa được xác minh.');
        // game_data.initChapterTab:292 chọn is_hard=2/chapter>200 cho nút Tinh Anh.
        // is_hard=1 là nhánh cũ vẫn có config, không đồng nhất hai namespace.
        if (!status.graph.cities.some((c) => c.city === city && [1, 2].includes(c.difficulty)))
            fail('City không thuộc chế độ tinh anh này.');
        return this.open(id, city, chapter);
    }
    async open(id, city, chapter) {
        const info = await this.info(id);
        const target = info.stages.find(s => String(s.cityId) === String(city));
        const p = this.db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(id);
        if (!target || !p || (JSON.parse(p.profile).level ?? 1) < target.openLevel)
            fail('Chưa đủ cấp hoặc city không có trong config.');
        if (!info.enabled && city === '100')
            return this.withProgress(id, await openInitialCity(city, chapter ?? '1'));
        if (!info.enabled) {
            const status = await new ProgressionService(this.db).status(id), current = status.cities.find((c) => c.city === city), sameMode = status.cities.filter((c) => c.difficulty === current?.difficulty);
            const index = sameMode.findIndex((c) => c.city === city);
            if (index < 1 || !sameMode[index - 1].completed)
                fail('Cần hoàn thành city trước.');
            return this.withProgress(id, await configuredCity(city, chapter, true));
        }
        if (!info.stages.some(s => String(s.cityId) === String(city) && info.state.storyIds.map(String).includes(String(s.storyId))))
            fail('City chưa được cấp quyền GM.');
        return this.withProgress(id, await configuredCity(city, chapter, true));
    }
    async enemies(id, city, building) {
        const info = await this.info(id);
        if (!info.enabled && city === '100')
            return buildingEnemies(city, building);
        const layout = await this.open(id, city, undefined);
        if (typeof building !== 'string' || !layout.land.flat().some((c) => c[1] === building && c[3] === 0 && Number(building) > 0))
            fail('Công trình không thuộc city GM này.');
        return configuredBuildingEnemies(building, city);
    }
    async info(id) {
        const row = this.db.prepare('SELECT state FROM player_map_access WHERE user_id=?').get(id);
        const stages = await contentIndex('stage_catalog');
        return { enabled: !!row, state: row ? JSON.parse(row.state) : null, stages, progress: (await new ProgressionService(this.db).status(id)).summary, notice: 'Quyền chọn và hoàn thành GM là hai thao tác riêng. Hoàn thành GM không cấp thưởng; trận thật dùng simulator LOCAL. City xung đột footprint không bị ghi hoàn thành giả. Bản đồ client dùng phần trăm, chưa có contract sao.' };
    }
    async withProgress(id, layout) {
        const status = await new ProgressionService(this.db).status(id), city = status.cities.find((c) => c.city === layout.city), titles = await import('./player.service.js').then(m => m.staticConfig('map_title_detail'));
        for (const cell of layout.land.flat()) {
            if (Number(cell[1]) <= 0 || cell[1] === '99999')
                continue;
            const b = String(cell[1]);
            if (titles[b]?.fight_list?.every((_, step) => status.done.has(layout.city + ':' + b + ':' + step)))
                cell[0] = 1;
        }
        const recapture_log = {};
        for (const building of city?.buildings ?? []) {
            const steps = [];
            for (let i = 0; i < (titles[building]?.fight_list?.length ?? 0); i++) {
                if (!status.done.has(layout.city + ':' + building + ':' + i))
                    break;
                steps.push(i);
            }
            if (steps.length)
                recapture_log[building] = steps;
        }
        return { ...layout, curt_regain: city?.percent ?? 0, recapture_log };
    }
    reset(id) {
        const old = this.db.prepare('SELECT state FROM player_map_access WHERE user_id=?').get(id);
        this.db.prepare('DELETE FROM player_map_access WHERE user_id=?').run(id);
        return { before: old ? JSON.parse(old.state) : null, after: null, result: { ok: true, notice: 'Đã gỡ override quyền chọn GM; không xóa claim, hero hoặc tiến độ khác.' } };
    }
    async world(id) {
        const base = await initialWorldMap();
        const info = await this.info(id);
        const last = this.db.prepare('SELECT city FROM local_battles WHERE user_id=? ORDER BY created_at DESC LIMIT 1').get(id);
        const lastCity = last && info.stages.find(s => String(s.cityId) === last.city);
        if (lastCity?.difficulty === 'normal') {
            base.last_city = last.city;
            base.last_chapter = String(lastCity.chapter);
        }
        if (!info.enabled) {
            const s = await new ProgressionService(this.db).status(id);
            const visible = s.cities.filter((c, i) => i === 0 || c.completed || s.cities[i - 1]?.completed);
            return { ...base, all_city_regain_percent: Object.fromEntries(visible.map((c) => [c.city, c.percent])) };
        }
        const allowed = info.stages.filter(s => info.state.storyIds.map(String).includes(String(s.storyId)));
        if (allowed.length !== info.state.storyIds.length)
            fail('Catalog đổi; cần kiểm tra lại quyền chọn GM.');
        // createChapterTips1491: percent chỉ là completion,0 giữ chưa hoàn thành.
        const status = await new ProgressionService(this.db).status(id);
        // QA 100% MAP cho phép xem/chạy lại hard đã hoàn thành, không mô phỏng lượt mua production.
        return { ...base, ...(info.state.mode === 'LOCAL_GM_COMPLETE' ? { hard_max_times: 1 } : {}), all_city_regain_percent: Object.fromEntries(allowed.map(s => [s.cityId, status.cities.find((c) => c.city === s.cityId)?.percent ?? 0])) };
    }
}
