import { aetherGroupScores } from './aether-score.js';
import { aetherPhase } from './aether-source.js';
// Chỉ đọc. Không suy quyền thưởng từ thành viên hiện tại hoặc số dư tự đặt.
export function aetherSettlementPreview(db, event, time) {
    const phase = aetherPhase(event.start_at, event.end_at, time), due = phase.step === 7 || phase.ended;
    return db.prepare('SELECT DISTINCT group_id FROM aether_guilds WHERE event_id=? ORDER BY group_id').all(event.id).map(g => {
        const group = Number(g.group_id), pendingJobs = Number(db.prepare("SELECT count(*) n FROM aether_wars WHERE event_id=? AND group_id=? AND status<>'done'").get(event.id, group).n), unresolvedCities = Number(db.prepare('SELECT count(*) n FROM aether_cities WHERE event_id=? AND group_id=? AND attacker_id IS NOT NULL').get(event.id, group).n);
        const claims = db.prepare("SELECT user_id,reward FROM aether_claims WHERE event_id=? AND kind='personal-final' AND claim_key=?").all(event.id, String(group));
        try {
            const scores = aetherGroupScores(db, event.id, group);
            let invalid = claims.some(c => !scores.some(s => s.user_id === c.user_id));
            for (const [i, row] of scores.entries()) {
                const c = claims.find(r => r.user_id === row.user_id);
                if (c) {
                    const saved = JSON.parse(String(c.reward));
                    if (saved.rank !== i + 1 || saved.score !== row.blood)
                        invalid = true;
                }
            }
            if (invalid)
                throw Error('Snapshot thưởng cũ không khớp sổ biên nhận; cần kiểm tra trước khi phát lại.');
            return { groupId: group, eligible: scores.length, mailed: claims.length, pending: Math.max(0, scores.length - claims.length), pendingJobs, unresolvedCities, status: pendingJobs || unresolvedCities ? 'BLOCKED_JOB' : !due ? 'PENDING_PHASE' : !scores.length ? 'EMPTY' : claims.length === scores.length ? 'SETTLED' : 'PENDING_MAIL', basis: 'SEASON_BATTLE_AWARDS', error: null };
        }
        catch (error) {
            return { groupId: group, eligible: null, mailed: claims.length, pending: null, pendingJobs, unresolvedCities, status: 'LEDGER_ERROR', basis: 'SEASON_BATTLE_AWARDS', error: error instanceof Error ? error.message : 'Không đọc được sổ kết toán.' };
        }
    });
}
