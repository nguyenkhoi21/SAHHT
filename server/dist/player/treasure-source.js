import { readConfigSync } from './local-content.js';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { eventDay } from './event-planner.js';
const index = JSON.parse(readFileSync(new URL('../../../tools/runtime/treasure-events-source.json', import.meta.url), 'utf8'));
const cache = new Map();
export function treasureSource(name) {
    if (cache.has(name))
        return cache.get(name);
    const m = index[name];
    if (!m)
        throw Error('Bảng sự kiện chưa được xác minh.');
    const raw = readFileSync(new URL('../../../' + m.source, import.meta.url)), parsed = readFileSync(new URL('../../../work/runtime-content/configs/' + name + '.json', import.meta.url)), sha = (b) => createHash('sha256').update(b).digest('hex');
    if (sha(raw) !== m.sourceSha256 || sha(parsed) !== m.sha256 || JSON.stringify(JSON.parse(raw.toString())) !== JSON.stringify(JSON.parse(parsed.toString())))
        throw Error('Hash nguồn Việt không khớp: ' + name);
    const value = JSON.parse(parsed.toString());
    cache.set(name, value);
    return value;
}
export const treasureKinds = { treasure: { name: 'Kho báu', target: 'main.509', table: 'one_piece' }, labyrinth: { name: 'Kho báu mê cung', target: 'main.540', table: 'new_roulette_item' }, pantheon: { name: 'Chúng thần điện', target: 'main.521', table: 'clone_lane' } };
export function treasureKind(target) { return Object.keys(treasureKinds).find(k => treasureKinds[k].target === target); }
export function treasurePresets(kind) { return Object.entries(treasureSource(treasureKinds[kind].table)).map(([id, r]) => ({ version: Number(id), date: r.start_time?.slice(0, 10) ?? '', ends: r.end_time ?? '' })).sort((a, b) => b.version - a.version); }
export function defaultTreasure(kind, version, at = Date.now()) {
    const presets = treasurePresets(kind), day = eventDay(at).replaceAll('-', '/');
    version ??= presets.find(p => p.date <= day)?.version ?? presets.at(-1).version;
    const source = structuredClone(treasureSource(treasureKinds[kind].table)[version]);
    if (!source)
        throw Error('Không có phiên bản Việt Nam được chọn.');
    const weighted = (rows) => rows.map((r, i) => ({ key: String(i + 1), reward: r.slice(0, 3), weight: r[3] ?? 1 }));
    const base = { name: treasureKinds[kind].name, kind, sourceVersion: version, policy: 'LOCAL_CONFIGURED', notice: source.notice };
    if (kind === 'treasure')
        return { ...base, prices: [source.one_coin, source.ten_coin], keyItem: 203, tenBonus: 1, wheel: Object.entries(treasureSource('one_piece_rate')).filter(([, r]) => r.version === version).map(([id, r]) => ({ key: id, slot: r.show_id, weight: r.rate, sourceScore: r.score, rewards: r.reward })), extras: weighted(source.free_reward), milestones: [1, 2, 3].map(n => ({ key: String(n), threshold: source['score_' + n], rewards: source['reward_' + n] })), exchanges: Object.entries(treasureSource('one_piece_exchange')).filter(([, r]) => r.version === version).map(([id, r]) => ({ key: id, group: r.sort, limit: r.limit_num, playerLimit: r.player_limit, cost: r.need_key_num, rewards: r.reward })), sourceRanking: source.show_ranking, sourceMaxRate: source.max_rate };
    if (kind === 'labyrinth')
        return { ...base, pools: [1, 2].map(type => { const row = structuredClone(treasureSource(type === 1 ? 'new_roulette_diamond' : 'new_roulette_item')[version]); if (!row)
                throw Error('Thiếu hai bể quà cùng phiên bản.'); return { type, prices: row.price, cost: type === 1 ? [9, 0, 1] : row.super_item[0], refresh: row.refresh_price, groups: row.reward_get.map(([n, count]) => ({ key: String(n), count, weight: row.reward_chance.find((v) => v[0] === n)[1], entries: weighted(row['reward_' + n]).map(e => { const [t, id] = e.reward; if (t === 5 && !readConfigSync('character_detail')[id] || t === 6 && !readConfigSync('item')[id])
                        return { ...e, sourceWeight: e.weight, weight: 0, blocked: 'Thiếu định nghĩa Việt Nam; giữ khóa, cần thay quà hợp lệ trước khi tăng tỷ trọng.' }; return e; }) })) }; }) };
    return { ...base, singlePrices: source.price, packPrices: source.price_all, refreshPrices: [...source.cost, 300], luckRange: source.score, luckMax: source.score_max, pieceChance: 10, pieceCount: 9, mystery: weighted(source.secret_reward), groups: [1, 2, 3, 4, 5].map(n => ({ key: String(n), distribution: n === 5 ? [] : source['reward_' + n + '_show'], entries: weighted(source['reward_' + n]) })), policyNotice: 'LOCAL: diễn giải cặp số nhóm thành số thẻ/tỷ trọng; điểm may mắn nguyên đều; tỷ lệ ảnh ghép do Admin cấu hình. Không tuyên bố là thuật toán server gốc.' };
}
