import { staticConfig } from './player.service.js';
import { localContent } from './local-content.js';
// Bảng và thứ tự stage lấy từ consumer Lua; đây là inspector, không phải công thức server.
export async function heroProgression(configId) {
    const cfg = (await staticConfig('character_detail'))[String(configId)];
    if (!cfg)
        throw Object.assign(new Error('Không có hero config này.'), { statusCode: 404 });
    const kind = cfg.evo_kind ?? cfg.quality;
    const table = kind < 3 ? 'evolution' : kind === 3 ? 'evolution_3' : kind === 4 ? 'evolution_4' : 'evolution_5';
    const [evolution, superTable, superTeams, rebirth, control, anti] = await Promise.all(['' + table, 'super_evolution', 'super_evo_team', 'character_break_new', 'break_control', 'anti_group'].map(staticConfig));
    const stages = Object.entries(evolution).sort((a, b) => Number(a[0]) - Number(b[0])).map(([id, config]) => ({ id: Number(id), config }));
    const superConfig = cfg.super_evo ? superTable[String(cfg.super_evo)] : undefined;
    const superStages = superConfig ? Object.keys(superConfig).filter(k => /^level_\d+_need$/.test(k)).map(k => Number(k.split('_')[1])).sort((a, b) => a - b).filter(stage => superConfig[`level_${stage}_need`].length > 0).map(stage => ({ id: stage, requirements: superConfig[`level_${stage}_need`].map((id) => ({ id, config: superTeams[String(id)] ?? null })), add: superConfig[`level_${stage}_add`] ?? null })) : [];
    const rebirthConfig = rebirth[String(configId)];
    const runtimeSource = localContent()?.heroCatalog.find((r) => r.configId === configId)?.sourceDefinition;
    return { evidence: 'STATIC VERIFIED', mutable: false,
        notice: runtimeSource?.source.startsWith('vn-runtime-') ? 'Định nghĩa thật từ gói cập nhật Việt Nam; bổ sung theo ID gốc, giữ bảng local cũ. Planner QA tính giới hạn riêng; chiến đấu vẫn dùng simulator LOCAL.' : runtimeSource ? 'Định nghĩa nguồn lịch sử cách ly; không cấp ngầm.' : localContent()?.configs.character_detail[String(configId)] ? 'LOCAL TEST IMPLEMENTATION: chỉ số/skill từ template, không phải dữ liệu gốc.' : 'Chỉ đọc config gốc; MAX QA phải qua planner validation.',
        level: { base: 1, growth: Object.fromEntries(Object.entries(cfg).filter(([k]) => k.startsWith('growth_'))), configLevelMax: cfg.level_max, validMax: null, formula: 'UNKNOWN', playerLimitEvidence: 'loadingtips[21]: cấp hero không quá cấp nhân vật+5; chưa đủ để xác định MAX' },
        evolution: { table, enabled: cfg.is_evo, stages, consumer: 'game_hero_advanced_sure.refreshHeroInfo:1026–1220', request: 'cards.card_evolution', costStatus: 'UNKNOWN' },
        superEvolution: { configId: cfg.super_evo, config: superConfig ?? null, stages: superStages, consumer: 'game_hero_super_evolution.createAttrTableView:1263–1330', requests: ['cards.make_soul', 'cards.super_evolution'] },
        rebirth: { table: 'character_break_new', config: rebirthConfig ?? null, stages: rebirthConfig ? Object.entries(control).filter(([id]) => Number(id) <= Number(rebirthConfig.high_break ?? 5)).sort((a, b) => Number(a[0]) - Number(b[0])).map(([id, rule]) => ({ id: Number(id), control: rule, materials: rebirthConfig['material' + id] ?? null, description: rebirthConfig['break_story' + id] ?? null })) : [], request: 'cards.card_break', consumer: 'game_hero_breakthrough.refreshHeroInfo:634–786' },
        reincarnation: { table: 'anti_group', entries: Object.entries(anti).filter(([, row]) => row.card === configId || row.anti_group?.includes(configId)).map(([id, config]) => ({ id, config })), request: 'cards.new_card_world' },
        skillState: { fields: ['s', 'avail', 'lv', 'exp'], availability: { 0: 'Khóa', 1: 'Đã mở, chưa kích hoạt', 2: 'Đã kích hoạt' }, consumer: 'skills_strengthen_scene:754–800', initialAvailability: 'UNKNOWN' },
    };
}
export function runtimeAssetStatus(resources) {
    // Model/atlas/texture không chứng minh đầy đủ FX/projectile/audio và các section SAM.
    if (!resources)
        return 'UNKNOWN';
    return resources.model || resources.atlas || resources.portrait ? 'PARTIAL_RUNTIME_ASSETS' : 'STATIC_CONFIG_ONLY';
}
