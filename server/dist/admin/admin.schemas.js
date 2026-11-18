import { giftcodeCurrencies } from '../player/giftcode-currencies.js';
const integer = (min, max) => ({ type: 'integer', minimum: min, maximum: max });
const string = (min, max) => ({ type: 'string', minLength: min, maxLength: max });
const object = (properties, required = Object.keys(properties)) => ({ type: 'object', additionalProperties: false, properties, required });
// Cùng cấu trúc phẳng như Mail: oneOf + removeAdditional có thể làm mất configId của phần thưởng hỗn hợp.
const giftReward = { ...object({ kind: { enum: ['currency', 'hero', 'equipment', 'item'] }, currency: { enum: Object.keys(giftcodeCurrencies) }, configId: integer(1, 99_999_999), quantity: integer(1, 100_000_000) }, ['kind', 'quantity']), allOf: [
        { if: { properties: { kind: { const: 'currency' } } }, then: { required: ['currency'], not: { required: ['configId'] } } },
        { if: { properties: { kind: { enum: ['hero', 'equipment', 'item'] } } }, then: { required: ['configId'], not: { required: ['currency'] }, properties: { quantity: integer(1, 1_000_000) } } },
        { if: { properties: { kind: { enum: ['hero', 'equipment', 'pet'] } } }, then: { properties: { quantity: integer(1, 5) } } }
    ] };
// Một tập property ngoài cùng: tránh AJV removeAdditional của oneOf xóa skillId
// khi thử các nhánh khác, làm mất metadata trước khi domain kiểm tra.
const mailAttachment = { ...object({ kind: { enum: ['hero', 'transformed_hero', 'item', 'equipment', 'currency', 'empowered_gem', 'fate_word', 'fate_stone', 'auxiliary', 'pet'] }, system: { enum: ['talisman', 'gem', 'soul', 'god_stone', 'medal', 'material'] }, level: integer(0, 30), forgingId: integer(1, 99), forgingEffect: integer(0, 10000), configId: integer(1, 99_999_999), skillId: integer(1, 99999), sourceId: integer(1, 99999999), prepared: false, preview: false, state: false, currency: { enum: ['coin', 'food', 'metal', 'crystal', 'silver', 'ticket', 'grace', 'grace_high', 'adv_crystal', 'super_crystal', 'min_fate_stone', 'mid_fate_stone', 'max_fate_stone', 'pet_crystal', 'pet_exp_ball', 'pet_skill_stone'] }, quantity: integer(1, 100_000_000) }, ['kind', 'quantity']), allOf: [
        { if: { properties: { kind: { const: 'auxiliary' } } }, then: { required: ['system', 'configId'], not: { anyOf: [{ required: ['currency'] }, { required: ['skillId'] }, { required: ['sourceId'] }] } } },
        { if: { properties: { kind: { const: 'transformed_hero' } } }, then: { required: ['configId', 'sourceId'], properties: { quantity: integer(1, 5) }, not: { anyOf: [{ required: ['skillId'] }, { required: ['currency'] }] } } },
        { if: { properties: { kind: { const: 'empowered_gem' } } }, then: { required: ['configId', 'skillId'], properties: { quantity: integer(1, 50) }, not: { required: ['currency'] } } },
        { if: { properties: { kind: { const: 'currency' } } }, then: { required: ['currency'], not: { anyOf: [{ required: ['skillId'] }, { required: ['configId'] }] } } },
        { if: { properties: { kind: { enum: ['hero', 'equipment', 'pet'] } } }, then: { required: ['configId'], properties: { quantity: integer(1, 5) }, not: { anyOf: [{ required: ['skillId'] }, { required: ['currency'] }] } } },
        { if: { properties: { kind: { enum: ['item', 'fate_word', 'fate_stone'] } } }, then: { required: ['configId'], properties: { quantity: integer(1, 1000000) }, not: { anyOf: [{ required: ['skillId'] }, { required: ['currency'] }] } } }
    ] };
const giftFields = { campaign: string(1, 80), description: string(0, 1000), startsAt: string(20, 35), expiresAt: string(20, 35), totalLimit: integer(1, 1_000_000), perAccountLimit: integer(1, 10), minLevel: integer(1, 250), minVip: integer(0, 17), enabled: { type: 'boolean' }, rewards: { type: 'array', minItems: 1, maxItems: 10, items: giftReward } };
export const schemas = {
    formationSlots: object({ confirmed: { const: true }, systems: { type: 'array', minItems: 1, maxItems: 3, uniqueItems: true, items: { enum: ['assistant', 'destiny', 'formation_bonus'] } }, restore: { type: 'boolean' } }),
    equipmentDestiny: object({ confirmed: { const: true }, requestId: string(8, 160), action: { enum: ['bind', 'unbind', 'upgrade', 'upgrade_ten', 'synthesize', 'socket', 'grant_gem', 'grant_stone', 'grant_voucher', 'grant_material'] }, equipmentId: string(1, 80), heroId: string(1, 80), sort: integer(1, 3), resourceType: integer(41, 43), configId: integer(1, 99999999), gemTeam: integer(1, 5), gemLevel: integer(1, 99), quantity: integer(1, 1000000), gemIds: { type: 'array', minItems: 4, maxItems: 4, items: integer(0, 999999) } }, ['confirmed', 'requestId', 'action']),
    mapCompletion: object({ confirmed: { const: true }, formationOverride: { type: 'boolean' } }),
    giftcode: object({ ...giftFields, code: string(3, 20) }, ['code', 'campaign', 'startsAt', 'expiresAt', 'rewards']),
    giftcodeBatch: object({ ...giftFields, count: integer(1, 50) }, ['count', 'campaign', 'startsAt', 'expiresAt', 'rewards']),
    giftcodeStatus: object({ enabled: { type: 'boolean' }, confirmed: { const: true } }),
    skillUnlock: object({ index: integer(4, 5), confirmed: { const: true } }),
    skillSelection: object({ slots: { type: 'array', minItems: 3, maxItems: 3, uniqueItems: true, items: integer(1, 5) }, confirmed: { const: true } }),
    skillLevel: object({ index: integer(1, 5), level: integer(1, 30), confirmed: { const: true } }),
    equipmentLevel: object({ level: integer(1, 251), confirmed: { const: true } }),
    login: object({ username: string(3, 32), password: string(10, 128) }),
    profile: object({ show_name: string(1, 15) }),
    level: object({ level: integer(1, 250) }),
    vip: object({ vip: integer(0, 100) }),
    welfare: object({ system: { enum: ['level', 'vip_daily', 'vip_sign'] }, enabled: { type: 'boolean' } }),
    currency: object({ action: { enum: ['ADD', 'SET', 'REMOVE'] }, amount: integer(0, 1_000_000_000) }),
    definition: object({ configId: integer(1, 99_999_999) }),
    rosterCapacity: object({ capacity: integer(20, 5000), confirmed: { const: true } }),
    equipmentAssign: object({ heroId: string(1, 80), confirmed: { const: true } }),
    heroProgression: object({ field: { enum: ['level', 'evolution', 'superStep', 'rebirth', 'reform'] }, value: integer(0, 255), confirmed: { const: true } }),
    heroPreset: { ...object({ count: integer(1, 5), type: integer(1, 4) }), required: ['count'] },
    activitySchedule: object({ enabled: { type: 'boolean' }, startsAt: string(20, 35), endsAt: string(20, 35) }),
    item: object({ configId: integer(1, 99_999_999), action: { enum: ['ADD', 'SET', 'REMOVE'] }, amount: integer(0, 1_000_000) }),
    mail: object({ requestId: { ...string(8, 160), pattern: '^[A-Za-z0-9_.:-]+$' }, title: string(1, 80), content: string(1, 4000), confirmed: { const: true }, attachments: { type: 'array', maxItems: 3, items: mailAttachment } }, ['title', 'content', 'confirmed']),
    empty: object({}),
    heroRemove: object({ confirmed: { const: true } }),
};
export function pageQuery(query) {
    const number = (x, fallback, max) => { const n = x === undefined ? fallback : Number(x); return Number.isInteger(n) && n >= 1 && n <= max ? n : fallback; };
    return { page: number(query.page, 1, 1_000_000), pageSize: number(query.pageSize, 20, 50), q: String(query.q ?? '').slice(0, 100) };
}
