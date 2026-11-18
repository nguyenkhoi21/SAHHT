import { WelfareService } from './welfare.service.js';
import { readConfigSync } from './local-content.js';
// Consumer gốc rewardTipsByDataTable đọc bảng {item:[cid,...],cards:[uid,...],
// talisman:[instance,...],currency:n}; không đọc danh sách tuple config.
// Wrapper chỉ đổi hình thức phản hồi, không cấp/thêm tài sản lần thứ hai.
export function grantGodfieldReward(db, s, tuples) {
    if (!db.isTransaction)
        throw Error('Phần thưởng Thần Vực cần transaction.');
    const currency = { 1: 'food', 2: 'metal', 4: 'crystal', 9: 'coin', 10: 'dirt_silver', 11: 'dirt_gold', 15: 'silver', 16: 'metalcore', 17: 'grace', 18: 'grace_high', 20: 'adv_crystal', 23: 'refine_stone', 33: 'small_forge_stone', 34: 'middle_forge_stone', 35: 'high_forge_stone', 40: 'super_crystal', 41: 'min_fate_stone', 42: 'mid_fate_stone', 43: 'max_fate_stone', 47: 'fenzuan', 24: 'pet_crystal', 26: 'pet_exp_ball', 27: 'pet_skill_stone' };
    for (const [type, , amount] of tuples)
        if (![5, 6, 7, 25, 49, 108, 109].includes(type) && !currency[type] || !Number.isSafeInteger(amount) || amount < 1 || ([5, 6, 7, 25, 49, 108, 109].includes(type) && amount > 10000))
            throw Error('Chưa có hợp đồng hiển thị phần thưởng nguồn loại' + type + '.');
    const priorPets = new Set(db.prepare('SELECT id FROM player_pets WHERE user_id=?').all(s.user_id).map(r => String(r.id)));
    const previous = new Set(db.prepare("SELECT id FROM player_auxiliary WHERE user_id=? AND kind='talisman'").all(s.user_id).map(r => String(r.id)));
    const delivery = new WelfareService(db).applyInTransaction(s, tuples, { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') }), reward = {};
    const cards = Object.keys(delivery._client_cache_update.cards?.cards?.update ?? {}), newTalismans = db.prepare("SELECT id FROM player_auxiliary WHERE user_id=? AND kind='talisman'").all(s.user_id).map(r => String(r.id)).filter(id => !previous.has(id));
    const equipment = Object.keys(delivery._client_cache_update.equip?._equip?.update ?? {});
    let cardOffset = 0, talismanOffset = 0, equipOffset = 0;
    for (const [type, cid, amount] of tuples) {
        if (type === 108 || type === 109)
            (reward[type === 108 ? 'fate_stone' : 'fate_word'] ??= []).push(...Array(amount).fill(cid));
        else if (type === 25) {
            const ids = db.prepare('SELECT id FROM player_pets WHERE user_id=?').all(s.user_id).map(r => String(r.id)).filter(id => !priorPets.has(id));
            (reward.pets ??= []).push(...ids);
            for (const id of ids)
                priorPets.add(id);
        }
        else if (type === 6)
            (reward.item ??= []).push(...Array(amount).fill(cid));
        else if (type === 5) {
            const ids = cards.slice(cardOffset, cardOffset + amount);
            if (ids.length !== amount)
                throw Error('Thiếu UID tướng mới cho phản hồi thưởng.');
            (reward.cards ??= []).push(...ids);
            cardOffset += amount;
        }
        else if (type === 49) {
            const ids = newTalismans.slice(talismanOffset, talismanOffset + amount);
            if (ids.length !== amount)
                throw Error('Thiếu instance Pháp Bảo mới cho phản hồi thưởng.');
            (reward.talisman ??= []).push(...ids);
            talismanOffset += amount;
        }
        else if (type === 7) {
            const ids = equipment.slice(equipOffset, equipOffset + amount);
            if (ids.length !== amount)
                throw Error('Thiếu instance trang bị mới.');
            (reward.equip ??= []).push(...ids);
            equipOffset += amount;
        }
        else
            reward[currency[type]] = (reward[currency[type]] ?? 0) + amount;
    }
    return { ...delivery, reward, reward_tuples: tuples };
}
