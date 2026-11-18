import { staticConfig } from './player.service.js';
import { readFile, readdir } from 'node:fs/promises';
import { isDeepStrictEqual } from 'node:util';
let cityLayout;
let referencedEnemies;
async function referencedEnemy(id) {
    referencedEnemies ??= (async () => {
        const names = (await readdir(new URL('../../../work/extracted-data/configs/', import.meta.url))).filter(n => /^enemy_soldier_\d+\.json$/.test(n)).sort(), index = new Map();
        for (const name of names)
            for (const [key, value] of Object.entries(await staticConfig(name.slice(0, -5)))) {
                const prior = index.get(key);
                if (prior === null)
                    continue;
                index.set(key, prior && !isDeepStrictEqual(prior, value) ? null : value);
            }
        return index;
    })();
    const value = (await referencedEnemies).get(id);
    if (value === null)
        throw Object.assign(new Error('ID đối thủ xung đột giữa các bảng VN: ' + id), { statusCode: 422 });
    return value;
}
// LOCAL TEST IMPLEMENTATION: địa hình chỉ đọc từ sample gốc; không nhận reward/progression.
export async function openInitialCity(city, chapter) {
    if (city !== '100' || chapter !== '1')
        throw Object.assign(new Error('Chỉ hỗ trợ địa hình city100/chapter1 đã có evidence'), { statusCode: 422 });
    cityLayout ??= readFile(new URL('../../../work/extracted-data/city100-layout.json', import.meta.url), 'utf8').then(JSON.parse);
    const layout = await cityLayout;
    if (layout.city !== '100' || layout.land.length !== 7 || layout.land.some(row => row.length !== 7))
        throw new Error('Địa hình mẫu không hợp lệ');
    return { city: layout.city, land: structuredClone(layout.land), world_level: 1, world_score: 0, curt_regain: 0, sweep_log: {} };
}
// Preview đối thủ từ config gốc; không tạo transcript, trừ thể lực hoặc cấp thưởng.
export async function buildingEnemies(city, building) {
    const layout = await openInitialCity(city, '1');
    if (typeof building !== 'string' || !layout.land.flat().some(cell => cell[1] === building && cell[3] === 0 && Number(building) > 100000))
        throw Object.assign(new Error('Công trình không thuộc city local đã biết'), { statusCode: 422 });
    return configuredBuildingEnemies(building);
}
export async function configuredBuildingEnemies(building, city) {
    const [titles, fights, enemies] = await Promise.all(['map_title_detail', 'map_fight', 'enemy_detail'].map(staticConfig));
    let specific = {};
    if (city && /^\d+$/.test(city)) {
        // staticConfig hiện có thể throw đồng bộ trước khi trả Promise.
        try {
            specific = await staticConfig('enemy_soldier_' + city);
        }
        catch (error) {
            if (error.code !== 'ENOENT')
                throw error;
        }
    }
    const enemyConfig = { ...enemies, ...specific };
    if (typeof building !== 'string' || !/^\d+$/.test(building))
        throw Object.assign(new Error('ID công trình không hợp lệ'), { statusCode: 422 });
    const title = titles[building];
    if (!title || !Array.isArray(title.fight_list))
        throw Object.assign(new Error('Chưa có config công trình này'), { statusCode: 422 });
    const map_fight = {}, enemy_detail = {};
    for (const tuple of title.fight_list) {
        const id = String(tuple[1]), fight = fights[id];
        if (!fight)
            throw Object.assign(new Error('Config trận của công trình chưa đầy đủ'), { statusCode: 422 });
        map_fight[id] = fight;
        for (let slot = 1; slot <= 5; slot++) {
            const position = fight[`position${slot}`];
            if (!Array.isArray(position))
                throw new Error('Kiểu position trong config không hợp lệ');
            if (position.length) {
                const enemyId = String(position[0]);
                // Một số fight (city194 → fight199022) tham chiếu ID quái thuộc bảng khác.
                // Chỉ nhận chính xác ID có định nghĩa duy nhất/đồng nhất; không mượn quái theo tên.
                if (!enemyConfig[enemyId])
                    enemyConfig[enemyId] = await referencedEnemy(enemyId);
                if (!enemyConfig[enemyId])
                    throw Object.assign(new Error('Config đối thủ chưa đầy đủ: ' + enemyId + ' / fight ' + id), { statusCode: 422 });
                enemy_detail[enemyId] = enemyConfig[enemyId];
            }
        }
    }
    return structuredClone({ map_fight, enemy_detail });
}
// GM LOCAL: vị trí/kích thước/ảnh lấy từ map+map_title_detail. Trạng thái2 là được
// thám hiểm, không phải đã chiếm (1). Không tạo win/reward/progression gốc.
export async function configuredCity(city, chapter, localAnchorAdapter = false) {
    const fail = (message) => { throw Object.assign(new Error(message), { statusCode: 422 }); };
    if (typeof city !== 'string' || !/^\d+$/.test(city))
        fail('City không hợp lệ.');
    const [maps, titles, stories] = await Promise.all(['map', 'map_title_detail', 'map_main_story'].map(staticConfig));
    const story = Object.values(stories).find((s) => String(s.stage_id) === city);
    if (!story || (chapter !== undefined && String(story.chapter) !== chapter))
        fail('City/chapter không khớp config.');
    const grid = maps[city];
    if (!Array.isArray(grid) || !grid.length || grid.some((r) => !Array.isArray(r) || r.length !== grid[0].length))
        fail('Chưa có lưới city hợp lệ.');
    const land = grid.map((r) => r.map(() => [0, '0', '', 0]));
    const filled = new Set();
    for (let y = 0; y < grid.length; y++)
        for (let x = 0; x < grid[y].length; x++) {
            const id = grid[y][x];
            if (id === 0)
                continue;
            if (id === -1) {
                land[y][x] = [1, '99999', '', 0];
                continue;
            }
            const cfg = titles[String(Math.abs(id))];
            if (!cfg || !Number.isInteger(cfg.title_x) || !Number.isInteger(cfg.title_y) || cfg.title_x < 1 || cfg.title_y < 1 || typeof cfg.title_img !== 'string')
                fail('Thiếu config hình học công trình; không đoán layout.');
            for (let dy = 0; dy < cfg.title_y; dy++)
                for (let dx = 0; dx < cfg.title_x; dx++) {
                    const yy = y + dy, xx = x + dx, key = yy + ':' + xx;
                    if (yy >= grid.length || xx >= grid[yy].length)
                        fail('Config footprint vượt biên lưới.');
                    if (((dx || dy) && grid[yy][xx] !== 0) || filled.has(key)) {
                        // Adapter LOCAL: giữ mọi anchor có ID gốc; chỉ bỏ cell phụ che anchor/cell đã sở hữu.
                        // Không đổi tọa độ, ID, texture hoặc config nguồn. Không trình bày là layout server gốc.
                        if (localAnchorAdapter && (dx || dy))
                            continue;
                        fail('Config footprint xung đột; cần truy tiếp, không chồng công trình.');
                    }
                    filled.add(key);
                    land[yy][xx] = [id > 0 ? 2 : 0, String(id), cfg.title_img, dx || dy ? 1 : 0];
                }
        }
    if (!grid.flat().includes(-1))
        fail('Chưa có điểm bắt đầu được config chứng minh.');
    return { city, land, world_level: 1, world_score: 0, curt_regain: 0, sweep_log: {} };
}
// Chỉ trạng thái bản đồ chưa hoàn thành; chưa cấp thưởng hoặc mô phỏng trận đấu.
export async function initialWorldMap() {
    const story = await staticConfig('map_main_story');
    const first = story['1'];
    if (first.chapter !== 1 || first.open_level !== 1)
        throw new Error('Config ải đầu không khớp evidence');
    return { hard_last_attack: { chapter: 1 }, last_chapter: '1', hard_last_chapter: '201', last_city: first.stage_id,
        hard_last_city: '0', world_level: 1, world_score: 0, buy_hard_times: 0, hard_done_times: 0, hard_max_times: 0,
        all_city_regain_percent: { [first.stage_id]: 0 } };
}
