export function aetherGroupScores(db, event, group, limit) {
    // Chỉ biên nhận chiến thắng quyết định chiến trường lịch sử. Không suy
    // người có quyền thưởng từ membership/hợp đồng hiện tại hoặc điểm QA trần.
    if (!Number.isSafeInteger(group) || group < 1)
        throw Error('Chiến trường BXH không hợp lệ.');
    if (limit !== undefined && (!Number.isSafeInteger(limit) || limit < 1 || limit > 1000))
        throw Error('Giới hạn BXH không hợp lệ.');
    const invalid = db.prepare(`SELECT 1 FROM aether_score_awards a LEFT JOIN aether_battles b ON b.id=a.battle_id
 WHERE a.event_id=? AND a.group_id=? AND (b.id IS NULL OR b.event_id<>a.event_id OR b.group_id<>a.group_id OR b.city_id<>a.city_id OR a.delta<=0 OR a.team NOT BETWEEN 1 AND 3) LIMIT 1`).get(event, group);
    if (invalid)
        throw Error('Biên nhận Huyết Tinh không khớp biên bản chiến trường; chưa kết toán.');
    const rows = db.prepare(`SELECT a.event_id,a.user_id,sum(a.delta) blood,max(a.rowid) reached_order
 FROM aether_score_awards a JOIN aether_battles b ON b.id=a.battle_id AND b.event_id=a.event_id AND b.group_id=a.group_id AND b.city_id=a.city_id
 WHERE a.event_id=? AND a.group_id=? GROUP BY a.user_id HAVING sum(a.delta)>0
 ORDER BY blood DESC,reached_order`).all(event, group);
    for (const row of rows) {
        const summary = db.prepare('SELECT blood FROM aether_scores WHERE event_id=? AND user_id=?').get(event, row.user_id), total = Number(db.prepare('SELECT sum(delta) n FROM aether_score_awards WHERE event_id=? AND user_id=?').get(event, row.user_id).n);
        if (!Number.isSafeInteger(row.blood) || Number(row.blood) < 1 || !Number.isSafeInteger(total) || Number(summary?.blood) !== total)
            throw Error('Tổng Huyết Tinh không khớp sổ biên nhận mùa; chưa xếp hạng hoặc phát thưởng.');
    }
    return limit === undefined ? rows : rows.slice(0, limit);
}
export function aetherBloodTotal(wins) {
    if (!Number.isSafeInteger(wins) || wins < 0 || wins > 10000)
        throw Error('Chuỗi thắng Aether không hợp lệ.');
    const n = BigInt(wins), den = 10n ** n, total = 1000n * (11n ** n - den) / den;
    if (total > BigInt(Number.MAX_SAFE_INTEGER))
        throw Error('Điểm Aether vượt giới hạn số nguyên an toàn; chưa kết toán.');
    return Number(total);
}
export function awardAetherVictory(db, scope, at) {
    if (!db.isTransaction)
        throw Error('Điểm Aether cần cùng transaction biên bản trận.');
    const old = db.prepare('SELECT * FROM aether_score_awards WHERE battle_id=?').get(scope.battle);
    if (old) {
        if (old.event_id !== scope.event || old.group_id !== scope.group || old.city_id !== scope.city || old.day !== scope.day || old.user_id !== scope.user || old.team !== scope.team)
            throw Error('Biên bản đã kết toán cho đội/phạm vi khác.');
        return { ...old, replayed: true };
    }
    const key = [scope.event, scope.group, scope.city, scope.day, scope.user, scope.team], streak = db.prepare('SELECT wins,total,closed FROM aether_streaks WHERE event_id=? AND group_id=? AND city_id=? AND day=? AND user_id=? AND team=?').get(...key);
    if (streak?.closed)
        throw Error('Đội đã thua/rời chuỗi, không được cộng thêm chiến thắng.');
    const wins = Number(streak?.wins ?? 0) + 1, total = aetherBloodTotal(wins), delta = total - Number(streak?.total ?? 0), current = Number(db.prepare('SELECT blood FROM aether_scores WHERE event_id=? AND user_id=?').get(scope.event, scope.user)?.blood ?? 0);
    if (!Number.isSafeInteger(current + delta))
        throw Error('Tổng điểm Aether vượt giới hạn an toàn.');
    db.prepare('INSERT INTO aether_streaks(event_id,group_id,city_id,day,user_id,team,wins,total) VALUES(?,?,?,?,?,?,?,?) ON CONFLICT(event_id,group_id,city_id,day,user_id,team) DO UPDATE SET wins=excluded.wins,total=excluded.total').run(...key, wins, total);
    const order = Number(db.prepare('INSERT INTO aether_score_awards(battle_id,event_id,user_id,group_id,city_id,day,team,wins,total,delta,created_at) VALUES(?,?,?,?,?,?,?,?,?,?,?)').run(scope.battle, scope.event, scope.user, scope.group, scope.city, scope.day, scope.team, wins, total, delta, at).lastInsertRowid);
    db.prepare('INSERT INTO aether_scores(event_id,user_id,blood,reached_order) VALUES(?,?,?,?) ON CONFLICT(event_id,user_id) DO UPDATE SET blood=blood+excluded.blood,reached_order=excluded.reached_order').run(scope.event, scope.user, delta, order);
    return { wins, total, delta, replayed: false };
}
export function closeAetherStreak(db, event, group, city, day, user, team) {
    if (!db.isTransaction)
        throw Error('Đóng chuỗi cần transaction.');
    db.prepare('INSERT INTO aether_streaks(event_id,group_id,city_id,day,user_id,team,closed) VALUES(?,?,?,?,?,?,1) ON CONFLICT(event_id,group_id,city_id,day,user_id,team) DO UPDATE SET closed=1').run(event, group, city, day, user, team);
}
