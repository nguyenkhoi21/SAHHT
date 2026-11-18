import { createHash } from 'node:crypto';
import { aetherItems, AetherEconomy } from './aether-economy.js';
const fail = (message) => { throw Object.assign(Error(message), { statusCode: 422 }); };
// Metadata nằm cùng transaction với Mail; không đưa vật liệu is_show2 vào kho thường.
export function issueAetherMail(db, event, user, rewards, key, at) {
    if (!db.isTransaction)
        throw Error('Thư Aether cần transaction.');
    if (!rewards.length || rewards.some(([kind, id, n]) => kind !== 6 || !aetherItems()[id] || !Number.isSafeInteger(n) || n < 1 || n > aetherItems()[id].stack))
        fail('Thư chỉ nhận vật liệu mùa Aether đã xác minh.');
    const time = event.qa ? Number(event.qa_time) + at - Number(event.qa_updated) : at;
    if (event.qa && !event.qa_active || time < event.start_at || time > event.end_at)
        fail('Mùa Aether không còn hiệu lực; chưa gửi thư.');
    const id = 'aether-season-' + createHash('sha256').update(event.id + ':' + user + ':' + key).digest('hex').slice(0, 32), metadata = { mail: id, event: event.id, expiresAt: Number(event.end_at), rewards };
    db.prepare('INSERT INTO player_mail(user_id,id,content,read_at,attachments) VALUES(?,?,?,NULL,?)').run(user, id, `Vật liệu Aether · mùa ${event.version}\nChỉ nhận và sử dụng trong mùa gắn với thư; không chuyển sang mùa sau.`, JSON.stringify(rewards));
    db.prepare("INSERT INTO aether_claims VALUES(?,?,'season-mail',?,?,?)").run(event.id, user, id, JSON.stringify(metadata), at);
    return metadata;
}
export function aetherMailPlan(db, user, id, rewards, at) {
    const row = db.prepare("SELECT c.reward,e.* FROM aether_claims c JOIN aether_events e ON e.id=c.event_id WHERE c.user_id=? AND c.kind='season-mail' AND c.claim_key=?").get(user, id);
    if (!row) {
        if (rewards.some(r => Array.isArray(r) && r[0] === 6 && aetherItems()[r[1]]))
            fail('Thư vật liệu Aether thiếu thông tin mùa; chưa nhận hoặc xóa thư.');
        return null;
    }
    const metadata = JSON.parse(row.reward), time = row.qa ? Number(row.qa_time) + at - Number(row.qa_updated) : at;
    if (metadata.mail !== id || metadata.event !== row.id || metadata.expiresAt !== row.end_at || JSON.stringify(metadata.rewards) !== JSON.stringify(rewards))
        fail('Đính kèm thư không khớp thông tin mùa Aether; chưa nhận.');
    if (row.qa && !row.qa_active || time < row.start_at || time > metadata.expiresAt)
        fail('Thư vật liệu Aether đã hết mùa hoặc mùa QA đã đóng; không cấp vào mùa khác.');
    return { event: String(row.id), rewards: metadata.rewards };
}
export function receiveAetherMails(db, session, plans, result) {
    if (!plans.length)
        return result;
    const events = new Set(plans.map(p => p.event));
    if (events.size !== 1)
        fail('Không nhận gộp vật liệu của các mùa Aether khác nhau.');
    const economy = new AetherEconomy(db, plans[0].event), rewards = plans.flatMap(p => p.rewards);
    economy.grant(session, rewards);
    const inventory = economy.inventory(session.user_id);
    const cache = result._client_cache_update ??= {}, item = cache.item ?? {}, items = item.items ?? { update: {}, remove: [] }, update = { ...items.update }, remove = (items.remove ?? []).filter((id) => !Object.hasOwn(inventory, id));
    for (const [id, n] of Object.entries(inventory)) {
        if (n > 0)
            update[id] = [n];
        else {
            delete update[id];
            remove.push(id);
        }
    }
    return { ...result, reward: [...(result.reward ?? []), ...rewards], _client_cache_update: { ...cache, item: { ...item, items: { ...items, update, remove } } } };
}
