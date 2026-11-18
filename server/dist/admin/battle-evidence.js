// Biên bản kiểm thử lịch sử; không phải giám sát Android trực tiếp hoặc simulator.
const historicalBattleEvidence = {
    observedAt: '2026-10-24T04:15:00+07:00',
    clientSha256: 'db94682dd9b65c3fe61a7d2b38730ae9040ce13b2f29bb9e3643d8c9f0f4b9f6',
    scope: 'Biên bản lịch sử pha7–11; SHA ở đầu là APK replay pha7. APK khác ghi riêng từng dòng. Roster/detail/preview không phải account battle; không tự chạy Android từ web.',
    heroes: [
        { configId: 63400, name: 'Vehito.Blue', model: 'VageteBlue', evidence: 'ANDROID VERIFIED', idle: 'OWNED DETAIL / ROSTER', attack: 'DETAIL PREVIEW; không phải account battle', battle: 'Chưa có account battle', capture: 'phase12-blue-max-detail', clientSha256: 'f2cc06bf09dfbd6f26ceb9f009fad3d9b60edf8cc2396a2643850ece49fc7934', progression: 'GM255/evo60/super8/bre7/năm crystal40; tên Hồn·CT-Black từ character_break_new gốc' },
        { configId: 32000, name: 'Naruto (Tiên nhân)', model: 'naruto2', evidence: 'ANDROID VERIFIED', idle: 'OWNED DETAIL / ROSTER', attack: 'UNKNOWN; chưa audit từng section', battle: 'Chưa có account battle', capture: 'phase12-naruto-detail', clientSha256: 'f2cc06bf09dfbd6f26ceb9f009fad3d9b60edf8cc2396a2643850ece49fc7934', progression: 'GM255/evo54/super0/bre7/năm crystal40; skill8026 không có link kế tiếp' },
        { configId: 4800, name: 'Seya', model: 'xingshi', evidence: 'ANDROID VERIFIED', idle: 'DETAIL PREVIEW', attack: 'UNKNOWN; chưa audit từng section', battle: 'Chưa có account battle', capture: 'phase11-seya-detail-ready', clientSha256: '35dbe2c0de921dbe8d2ca153eda5e72e393beb02ceaa703cb0f1e8b61b2f9980', progression: 'GM255/evo60/super8/bre7/năm crystal40; phase11-seya-reform-max' },
        { configId: 32600, name: 'CT-Vehito', model: 'vegete', evidence: 'ANDROID VERIFIED', idle: 'DETAIL / MAIN / FORMATION', attack: 'UNKNOWN; chưa audit từng section', battle: 'Chưa có account battle', capture: 'phase11-mail-weapon-equipped', clientSha256: '35dbe2c0de921dbe8d2ca153eda5e72e393beb02ceaa703cb0f1e8b61b2f9980' },
        { configId: 2300, name: 'Luffy', model: 'luffy', evidence: 'ANDROID VERIFIED', idle: 'PREVIEW', attack: 'gongji1 / gongji2 · PREVIEW', battle: 'Chưa kiểm thử với instance sở hữu', capture: 'phase7-luffy-detail' },
        { configId: 3300, name: 'Magneto', model: 'magneto', evidence: 'ANDROID VERIFIED', idle: 'PREVIEW', attack: 'gongji1 / gongji2 · PREVIEW', battle: 'Chưa kiểm thử với instance sở hữu', capture: 'phase7-magneto-detail' },
        { configId: 42500, name: 'Songoku', model: 'XWukong', evidence: 'ANDROID VERIFIED', idle: 'PREVIEW', attack: 'gongji1 / gongji2 · PREVIEW', battle: 'Chưa kiểm thử với instance sở hữu', capture: 'phase7-songoku-detail' },
        ...[{ configId: 100, name: 'Alice', model: 'ailisi', capture: 'phase8-alice-detail' },
            { configId: 200, name: 'Ada', model: 'ada', capture: 'phase8-ada-detail' },
            { configId: 300, name: 'Michonne', model: 'daonv', capture: 'phase8-michonne-detail' },
            { configId: 400, name: 'Andy', model: 'andy', capture: 'phase8-andy-detail' },
            { configId: 500, name: 'Wesker', model: 'weisike', capture: 'phase8-wesker-detail' }]
            .map(h => ({ ...h, evidence: 'ANDROID VERIFIED', idle: 'PREVIEW', attack: 'gongji1 / gongji2 · PREVIEW', battle: 'Chưa kiểm thử với instance sở hữu', clientSha256: 'b6ae945763c6f93222afc1eb804cb5c30169e26da845dcf15bda4d1d2953d03e' })),
    ],
    replay: { evidence: 'ANDROID VERIFIED', source: 'battleData.temp gốc trong APK', frames: 54, actors: 8, observed: 'Hai phe/HP, biến hình, skill, hit, FX; tới winer rồi về main.', capture: 'phase7-replay-completed', limitations: 'Actor tutorial khác hero sở hữu. Không import account/cache/reward, không tính damage/AI/PvE. Audio và death từng hero chưa xác minh.' },
    blocker: 'Pha16: world_map/open/map_fight_and_enemy đã trả200 và Android hiển thị. recapture(city100,building100001,step0) vẫn501: thiếu simulator/transcript account. Preflight chỉ đọc đã triển khai; chưa có attack/skill/win/reward account. PvP/Activity battle dùng cùng giới hạn, không lấy tutorial làm trận thật.',
};
// Bằng chứng account battle LOCAL, giữ nguyên biên bản preview/tutorial cũ để đối chiếu.
const phase17ClientSha256 = '9008da4cc375567989cf00871b6cda05f48f4d4e1dc5f4e0c5f2a2e66301ee32';
const phase17Heroes = [
    { configId: 63400, name: 'Vehito.Blue', model: 'VageteBlue', attack: 'Đòn tấn công trong trận city194', battle: 'Đội chính formation6; thắng city194, thua city219', capture: 'phase17-formation6-eight-battle' },
    { configId: 42500, name: 'Songoku', model: 'XWukong', attack: 'Tấn công / XWukong_s1 trong account battle', battle: 'Đội chính; city156 / city194 / city219', capture: 'phase17-formation6-eight-victory' },
    { configId: 32600, name: 'CT-Vehito', model: 'vegete', attack: 'Tấn công / vegete_s1 trong account battle', battle: 'Đội chính; city156 / city194 / city219', capture: 'phase17-formation6-eight-victory' },
    { configId: 81300, name: 'Luffy - Nika', model: 'NIKAlufei', attack: 'Tấn công / NIKAlufei_s4 trong account battle', battle: 'Đội chính; city100 / city156 / city194 / city219', capture: 'phase17-formation6-eight-victory' },
    { configId: 34700, name: 'Boa Hancock', model: 'nvdi', attack: 'Tấn công trong account battle; EXP đã kiểm trên Android', battle: 'City194 thắng; Lv5/21EXP → Lv6/96EXP', capture: 'phase17-formation6-eight-victory' },
    { configId: 4800, name: 'Seya', model: 'xingshi', attack: 'Dự bị vào sân / xingshi_s1 tại city219', battle: 'Thua thật; không cấp thưởng thắng', capture: 'phase17-city219-defeat' },
    { configId: 32000, name: 'Naruto (Tiên nhân)', model: 'naruto2', attack: 'Chưa kiểm riêng attack/skill trong account battle', battle: 'Dự bị formation6; save/reopen/relogin đủ8 vị trí, có trong battle init', capture: 'phase17-formation6-eight-after-relogin' },
    { configId: 2300, name: 'Luffy', model: 'luffy', attack: 'Chưa kiểm riêng attack/skill trong account battle', battle: 'Dự bị formation6; save/reopen/relogin đủ8 vị trí, có trong battle init', capture: 'phase17-formation6-eight-after-relogin' },
];
export const battleEvidence = {
    ...historicalBattleEvidence,
    observedAt: '2026-10-25T18:50:00+07:00',
    clientSha256: phase17ClientSha256,
    scope: 'Biên bản Android theo từng capture. Pha17 đã có account battle với simulator LOCAL; công thức giản lược không phải production. Preview/tutorial cũ giữ riêng; không tự chạy Android từ web.',
    heroes: [
        ...phase17Heroes.map(h => ({ ...historicalBattleEvidence.heroes.find(old => old.configId === h.configId), ...h, evidence: 'ANDROID VERIFIED', idle: [32000, 2300].includes(h.configId) ? 'MODEL TRONG FORMATION; DỰ BỊ TRONG BATTLE INIT' : 'MODEL TRONG ACCOUNT BATTLE', clientSha256: phase17ClientSha256 })),
        ...historicalBattleEvidence.heroes.filter(h => !phase17Heroes.some(current => current.configId === h.configId)),
    ],
    history: { observedAt: historicalBattleEvidence.observedAt, clientSha256: historicalBattleEvidence.clientSha256, scope: historicalBattleEvidence.scope },
    blocker: 'PvE account battle đã hoạt động: formation6, attack/skill, thắng/thua, thưởng, EXP hero, Tiếp tục về map. Simulator LOCAL chưa mô phỏng đủ buff/heal/AOE/energy/cooldown production. Arena/Activities mới UI/API VERIFIED; chưa có combat các mode đó. Không dùng replay tutorial thay account battle.',
};
