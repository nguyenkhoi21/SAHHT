// Quy tắc do chủ dự án xác nhận 28/10/2026: bốn hạng trên, thiếu thì bù dưới.
export function rankedCandidates(rows, uid) {
    const own = rows.find(r => r.user_id === uid) ?? { rank: Math.max(0, ...rows.map(r => r.rank)) + 1 };
    const above = rows.filter(r => r.rank < own.rank).sort((a, b) => b.rank - a.rank).slice(0, 4);
    const below = rows.filter(r => r.rank > own.rank).sort((a, b) => a.rank - b.rank).slice(0, 4 - above.length);
    return [...above, ...below].sort((a, b) => a.rank - b.rank);
}
export function arenaPositions(db, rows) {
    // Chỉ append người mới. Không xếp lại hạng đã lưu theo lực chiến/rating.
    const sync = () => {
        let last = Number(db.prepare('SELECT COALESCE(MAX(rank),0) n FROM arena_positions').get().n);
        for (const row of rows)
            if (!db.prepare('SELECT 1 FROM arena_positions WHERE user_id=?').get(row.user_id))
                db.prepare('INSERT INTO arena_positions VALUES(?,?)').run(row.user_id, ++last);
    };
    const own = !db.isTransaction;
    if (own)
        db.exec('BEGIN IMMEDIATE');
    try {
        sync();
        if (own)
            db.exec('COMMIT');
    }
    catch (e) {
        if (own)
            db.exec('ROLLBACK');
        throw e;
    }
    const positions = new Map(db.prepare('SELECT user_id,rank FROM arena_positions').all().map(r => [Number(r.user_id), Number(r.rank)]));
    return rows.map(r => ({ ...r, rank: positions.get(r.user_id) })).sort((a, b) => a.rank - b.rank);
}
export function settleArenaRank(db, attacker, defender, won) {
    if (!db.isTransaction)
        throw Error('Đổi hạng Arena cần transaction.');
    const get = (uid) => Number(db.prepare('SELECT rank FROM arena_positions WHERE user_id=?').get(uid).rank), a = get(attacker), d = get(defender);
    if (won && d < a) {
        const spare = Number(db.prepare('SELECT MAX(rank)+1 n FROM arena_positions').get().n);
        db.prepare('UPDATE arena_positions SET rank=? WHERE user_id=?').run(spare, attacker);
        db.prepare('UPDATE arena_positions SET rank=? WHERE user_id=?').run(a, defender);
        db.prepare('UPDATE arena_positions SET rank=? WHERE user_id=?').run(d, attacker);
    }
    return { oldRank: a, rank: get(attacker), defenderBefore: d, defenderAfter: get(defender) };
}
