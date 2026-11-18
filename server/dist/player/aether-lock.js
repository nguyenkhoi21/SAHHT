export function aetherEntityInUse(db, user, entity, now = Date.now()) {
    const rows = db.prepare("SELECT e.*,f.state FROM aether_formations f JOIN aether_events e ON e.id=f.event_id WHERE (e.qa=0 OR e.qa_active=1) AND f.user_id=? AND EXISTS(SELECT 1 FROM json_tree(f.state) WHERE type='text' AND value=?)").all(user, entity);
    return rows.some(e => { const at = e.qa ? Number(e.qa_time) + now - Number(e.qa_updated) : now; return at >= Number(e.start_at) && at <= Number(e.end_at); });
}
// Quy tắc word1/30: không đổi hội gốc của lính, không vào hội đã được chọn;
// mở lại sau kết thúc mùa một tiếng. Không thay membership khi thuê.
export function assertAetherMembershipMutable(db, user, guild, now) {
    const events = db.prepare('SELECT * FROM aether_events WHERE qa=0 OR qa_active=1').all();
    for (const e of events) {
        const at = e.qa ? Number(e.qa_time) + now - Number(e.qa_updated) : now;
        if (at > Number(e.end_at) + 3600000)
            continue;
        const hired = db.prepare("SELECT 1 FROM aether_mercenaries WHERE event_id=? AND user_id=? AND status='active'").get(e.id, user), member = db.prepare('SELECT alliance_id FROM alliance_members WHERE user_id=?').get(user);
        if (hired || db.prepare('SELECT 1 FROM aether_guilds WHERE event_id=? AND guild_id IN(?,?)').get(e.id, guild ?? 0, member?.alliance_id ?? 0))
            throw Object.assign(Error('Hội đang tham gia Aether hoặc đang làm lính đánh thuê; chỉ đổi thành viên sau hết mùa một tiếng.'), { statusCode: 422 });
    }
}
