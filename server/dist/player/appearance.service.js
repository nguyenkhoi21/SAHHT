import { readConfigSync } from './local-content.js';
import { createBaseHero, heroBindingClientState } from './definitions.js';
import { contentReceipt } from './content-receipt.js';
import { appearanceState } from './appearance-state.js';
import { heroResources } from './hero-index.js';
import { audit } from '../admin/admin.audit.js';
import { CombatPowerService } from './combat-power.js';
import { WelfareService } from './welfare.service.js';
import { transformationSource, transformationSourceHash, transformationGraph, transformationClass, transformationProvenance, transformationClientState, inheritedAttributes } from './transformation-graph.js';
import { transformationSkillScript } from './transformation-skill.js';
export { transformationSource, transformationSourceHash } from './transformation-graph.js';
const fail = (m) => { throw Object.assign(new Error(m), { statusCode: 422 }); };
const fields = ['patk', 'matk', 'def', 'speed', 'hp'];
export class AppearanceService {
    db;
    constructor(db) {
        this.db = db;
    }
    heroes(s) { return this.db.prepare('SELECT id,state FROM player_heroes WHERE user_id=?').all(s.user_id).map(r => JSON.parse(String(r.state))); }
    hero(s, id) { if (typeof id !== 'string')
        fail('Thiếu mã tướng.'); const h = this.heroes(s).find(h => h.id === id); if (!h)
        fail('Tướng không thuộc tài khoản.'); return h; }
    inheritanceAssessment(s, h) {
        const provenance = transformationProvenance(h), record = this.db.prepare('SELECT * FROM player_transformations WHERE user_id=? AND hero_id=? AND target_id=? AND restored=0 ORDER BY created_at DESC LIMIT 1').get(s.user_id, h.id, h.c_id);
        if (!record)
            return { ...provenance, repairAvailable: false };
        const before = JSON.parse(String(record.before_state)), after = JSON.parse(String(record.after_state)), rule = transformationGraph.find(e => e.sourceId === before.c_id && e.targetId === h.c_id)?.inheritance;
        if (!rule)
            return { ...provenance, repairAvailable: false };
        const expected = inheritedAttributes(before, rule), matches = fields.every(f => h._local_transformation?.inherited?.[f] === expected[f]);
        const unchanged = ['lv', 'evo', 'bre', 'step', ...fields].every(f => h[f] === after[f]) && after.lv === 1 && after.evo === 0 && after.bre === 0;
        return { ...provenance, status: matches ? 'SNAPSHOT_VERIFIED' : 'SNAPSHOT_AVAILABLE_REVIEW', needsQaResolution: !matches, repairAvailable: !matches && unchanged, expectedInherited: expected, coefficient: rule.coefficient, notice: matches ? 'Kế thừa khớp snapshot nguồn trong ledger.' : unchanged ? 'Có snapshot nguồn, có thể sửa có xác nhận; giữ instance/trang bị/đội hình.' : 'Có snapshot nhưng tiến trình đã thay đổi; cần đối chiếu QA, không tự ghi đè.' };
    }
    state(s) { return appearanceState(this.db, s.user_id); }
    packet(s, removed = [], changedHeroIds) {
        const items = this.db.prepare('SELECT config_id,quantity FROM player_items WHERE user_id=?').all(s.user_id), state = this.state(s);
        const cards = Object.fromEntries(this.heroes(s).filter(h => !changedHeroIds || changedHeroIds.includes(h.id)).map(h => [h.id, heroBindingClientState(Object.fromEntries(Object.entries(transformationClientState(h)).filter(([k]) => !k.startsWith('_local_'))))]));
        for (const h of new CombatPowerService(this.db).calculate(s.user_id, true).heroes)
            if (cards[h.id])
                cards[h.id].client_final_attributes = h.attributes;
        return { ...state, alignment: JSON.parse(String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(s.user_id).formation)).alignment, _client_cache_update: { cards: { cards: { update: cards, remove: [] }, skin: { update: state.skin }, used_skin: { update: state.used_skin } }, equip: { _equip: { update: {}, remove: removed } }, item: { items: { update: Object.fromEntries(items.filter(r => Number(r.quantity) > 0).map(r => [String(r.config_id), [Number(r.quantity)]])), remove: items.filter(r => r.quantity === 0).map(r => String(r.config_id)) } } } };
    }
    async catalog(s) {
        const defs = readConfigSync('character_detail'), skinDefs = readConfigSync('character_skin'), resources = await heroResources(), heroes = this.heroes(s), state = this.state(s);
        const skins = Object.entries(skinDefs).map(([id, cfg]) => {
            const bases = Object.entries(defs).filter(([, h]) => h.is_skin === Number(id)).map(([id, h]) => ({ id: Number(id), name: h.name, model: h.animation }));
            const missing = !defs[id] ? 'Thiếu định nghĩa skill/model của skin.' : resources.get(Number(id))?.assetStatus !== 'FULL ASSETS' ? 'Thiếu bộ model/atlas/texture.' : !bases.length ? 'Thiếu liên kết hero → skin.' : null;
            return { id: Number(id), name: defs[id]?.name ?? 'Skin chờ xác minh #' + id, model: defs[id]?.animation, bases, cost: cfg.open_cost, attributeOptions: cfg.add_ability, attributePolicy: 'LOCAL_FIRST_VERIFIED_OPTION', supported: !missing, reason: missing, owned: !!state.skin[id], equipped: state.used_skin.includes(Number(id)), eligible: heroes.some(h => bases.some(b => b.id === h.c_id)), limited: cfg.open_cost.some((r) => r[1] === 9102365) };
        });
        const skills = readConfigSync('skill_detail'), items = readConfigSync('item'), equips = readConfigSync('equip');
        const transformations = transformationGraph.map(edge => {
            const { sourceId: id, targetId: target } = edge, missing = [], skillDependencies = [];
            for (const cid of [id, target]) {
                const cfg = defs[cid];
                if (!cfg) {
                    missing.push('Thiếu character_detail #' + cid);
                    continue;
                }
                if (resources.get(cid)?.assetStatus !== 'FULL ASSETS')
                    missing.push('Thiếu model/portrait/atlas #' + cid);
                for (let slot = 1; slot <= 7; slot++)
                    for (const [sid] of cfg['skill_' + slot + '_source'] ?? [])
                        if (!skills[sid])
                            missing.push('Thiếu skill_detail #' + sid);
            }
            const targetCfg = defs[target];
            if (targetCfg)
                for (let slot = 1; slot <= 7; slot++)
                    for (const [sid] of targetCfg['skill_' + slot + '_source'] ?? []) {
                        const skill = skills[sid], script = skill?.sprite_py ? transformationSkillScript(target, targetCfg.animation, sid, skill.sprite_py) : null;
                        skillDependencies.push({ slot, skillId: sid, type: skill?.skill_type, script: script?.name, status: script?.status ?? (skill?.sprite_py ? 'MISSING_SCRIPT' : 'NO_SCRIPT_REQUIRED') });
                        if (slot === 1 && skill?.skill_type === 'KBEFOREATTACK' && skill.sprite_py && !script)
                            missing.push('Thiếu script kỹ năng đầu #' + sid);
                    }
            if (!edge.inheritance)
                missing.push('Mô tả kế thừa chưa hỗ trợ.');
            if (!Number.isSafeInteger(edge.minimumEvolution) || edge.minimumEvolution < 0 || !Number.isSafeInteger(edge.energy) || edge.energy < 0)
                missing.push('Điều kiện nguồn không hợp lệ.');
            for (const [type, cid, n] of edge.cost ?? [])
                if (!Number.isSafeInteger(n) || n <= 0 || !(type === 6 ? items[cid] : type === 7 ? equips[cid] : null))
                    missing.push('Nguyên liệu chưa hỗ trợ #' + cid);
            return { ...edge, name: defs[id]?.name ?? String(id), targetName: defs[target]?.name ?? String(target), model: defs[id]?.animation, targetModel: defs[target]?.animation, targetClass: transformationClass(target), skillDependencies, supported: !missing.length, missing };
        });
        const history = this.db.prepare("SELECT method,request_key,created_at FROM player_content_operations WHERE user_id=? AND method IN('cards.buy_skin','cards.use_skin','cards.new_card_world') ORDER BY created_at DESC LIMIT 30").all(s.user_id);
        return { skins, transformations, graph: { sourceRows: Object.keys(transformationSource).length, sources: new Set(transformations.map(x => x.sourceId)).size, targets: new Set(transformations.map(x => x.targetId)).size, branches: [...new Set(transformations.map(x => x.sourceId))].map(id => ({ sourceId: id, name: defs[id]?.name, targets: transformations.filter(x => x.sourceId === id) })), chains: transformations.filter(e => transformationSource[e.targetId]?.afterlife_id?.length), supported: transformations.filter(x => x.supported).length, sourceHash: transformationSourceHash }, history, power: new CombatPowerService(this.db).calculate(s.user_id, true), heroes: heroes.map(h => ({ id: h.id, c_id: h.c_id, name: defs[h.c_id]?.name, classification: transformationClass(h.c_id), provenance: this.inheritanceAssessment(s, h), level: h.lv, evolution: h.evo, rebirth: h.bre, taskStep: h.card_world_step ?? 0, energy: h.after_world_point ?? 0, isWorld: !!h.is_world, inherited: h._local_transformation?.inherited ?? null, baseStats: Object.fromEntries(fields.map(f => [f, h[f]])) })), currencies: [511462, 9102365].map(id => ({ id, name: items[id]?.name, quantity: Number(this.db.prepare('SELECT quantity FROM player_items WHERE user_id=? AND config_id=?').get(s.user_id, id)?.quantity ?? 0) })), ...state, notice: 'Chuyển Thế dùng công thức từng quan hệ đã xác minh; stat thô trước trang bị/Vận Mệnh/Skin. Instance đích thiếu snapshot nguồn được giữ nguyên, không tự suy kế thừa. Nhiệm vụ gốc còn adapter riêng; QA có audit. Skin dùng tuple nguồn đầu tiên (LOCAL; chưa biết RNG gốc).' };
    }
    spend(s, cost) {
        const removed = [], totals = new Map();
        for (const [type, id, n] of cost) {
            if (!Number.isSafeInteger(n) || n <= 0)
                fail('Chi phí nguồn không hợp lệ.');
            if (type === 6)
                totals.set(id, (totals.get(id) ?? 0) + n);
            else if (type === 7) {
                const form = String(this.db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(s.user_id).formation);
                const rows = this.db.prepare('SELECT id,state FROM player_equipment WHERE user_id=? AND config_id=? ORDER BY id').all(s.user_id, id).filter(r => { const e = JSON.parse(String(r.state)); return !e.bind_card && !form.includes('"' + r.id + '"') && !(e.gem_fate ?? []).some(Boolean); });
                if (rows.length < n)
                    fail('Thiếu trang bị nguyên liệu chưa mặc/chưa khóa: #' + id);
                for (const r of rows.slice(0, n)) {
                    this.db.prepare('DELETE FROM player_equipment WHERE user_id=? AND id=?').run(s.user_id, r.id);
                    removed.push(String(r.id));
                }
            }
            else
                fail('Loại chi phí chưa hỗ trợ: ' + type);
        }
        for (const [id, n] of totals) {
            if (!readConfigSync('item')[id])
                fail('Thiếu config nguyên liệu #' + id);
            const r = this.db.prepare('UPDATE player_items SET quantity=quantity-? WHERE user_id=? AND config_id=? AND quantity>=?').run(n, s.user_id, id, n);
            if (r.changes !== 1)
                fail('Không đủ nguyên liệu #' + id);
        }
        return removed;
    }
    async buySkin(s, id, key) {
        const entry = (await this.catalog(s)).skins.find(x => x.id === Number(id));
        if (!entry?.supported)
            fail(entry?.reason ?? 'Skin không hợp lệ.');
        return contentReceipt(this.db, s.user_id, 'cards.buy_skin', key, { id: Number(id) }, () => {
            if (!this.heroes(s).some(h => entry.bases.some(b => b.id === h.c_id)))
                fail('Chưa sở hữu tướng tương ứng với skin.');
            if (this.db.prepare('SELECT 1 FROM player_skins WHERE user_id=? AND skin_id=?').get(s.user_id, entry.id))
                fail('Skin đã được sở hữu.');
            const attr = entry.attributeOptions[0];
            if (!Array.isArray(attr) || !fields[attr[0] - 1] || !Number.isFinite(attr[1]) || attr[1] < 0)
                fail('Thiếu thuộc tính nguồn đã xác minh.');
            this.spend(s, entry.cost);
            this.db.prepare('INSERT INTO player_skins VALUES(?,?,?,0,?)').run(s.user_id, entry.id, JSON.stringify(attr), Date.now());
            audit(this.db, null, 'skin.buy', s.user_id, 'Mở khóa Skin; tuple đầu tiên nguồn Việt Nam', null, { id: entry.id, cost: entry.cost, attribute: attr });
            return this.packet(s);
        }, () => ({ ...this.packet(s), replayed: true }));
    }
    useSkin(s, value, key) {
        if (typeof value !== 'string' || !/^\d*(?:_\d+)*$/.test(value))
            fail('Danh sách Skin không hợp lệ.');
        const ids = value ? String(value).split('_').filter(Boolean).map(Number) : [];
        if (ids.length > 20 || new Set(ids).size !== ids.length)
            fail('Skin bị trùng hoặc quá giới hạn.');
        return contentReceipt(this.db, s.user_id, 'cards.use_skin', key, { ids }, () => {
            const defs = readConfigSync('character_detail'), owned = this.state(s), heroDefs = this.heroes(s).map(h => defs[h.c_id]), identities = new Set();
            for (const id of ids) {
                const skinDef = defs[id], identity = String(skinDef?.character_ID ?? '');
                if (!owned.skin[id] || !skinDef || !heroDefs.some(h => h && (h.is_skin === id || String(h.character_ID) === identity)))
                    fail('Chưa sở hữu skin hoặc tướng tương ứng.');
                if (identities.has(identity))
                    fail('Không thể mặc hai skin của cùng nhân vật.');
                identities.add(identity);
            }
            this.db.prepare('UPDATE player_skins SET equipped=0 WHERE user_id=?').run(s.user_id);
            for (const id of ids)
                this.db.prepare('UPDATE player_skins SET equipped=1 WHERE user_id=? AND skin_id=?').run(s.user_id, id);
            audit(this.db, null, 'skin.equip', s.user_id, 'Đổi ngoại hình, giữ nguyên progression/trang bị', null, { ids });
            return this.packet(s);
        }, () => ({ ...this.packet(s), replayed: true }));
    }
    async transform(s, id, target, key, actor = null) {
        const pre = this.hero(s, id), options = (await this.catalog(s)).transformations.filter(e => e.sourceId === pre.c_id), to = target === undefined ? (options.length === 1 ? options[0].targetId : NaN) : Number(target), defs = readConfigSync('character_detail');
        return contentReceipt(this.db, s.user_id, 'cards.new_card_world', key, { id, target: target ?? null }, () => {
            const h = this.hero(s, id), rule = options.find(e => e.sourceId === h.c_id && e.targetId === to);
            if (!rule?.supported || !rule.inheritance)
                fail('Cần chọn đúng nhánh Chuyển Thế đã xác minh; ' + (rule?.missing.join('; ') ?? 'không có quan hệ nguồn → đích.'));
            if (h.evo < rule.minimumEvolution || h.bre < rule.minimumRebirth)
                fail(`Cần tiến hóa +${rule.minimumEvolution} trở lên và Chuyển Sinh${rule.minimumRebirth}.`);
            if (h.card_world_step !== rule.requiredTaskStep || Number(h.after_world_point ?? 0) < rule.energy)
                fail('Chưa hoàn thành3bước nhiệm vụ và năng lượng Chuyển Thế.');
            const result = { ...createBaseHero(h.id, to, defs[to]), bind_equip: h.bind_equip ?? [], famous: h.famous ?? {}, is_world: true, card_world_step: 0, after_world_point: 0 };
            const inherited = inheritedAttributes(h, rule.inheritance);
            for (const f of fields)
                result[f] += inherited[f];
            result._local_transformation = { sourceId: h.c_id, targetId: to, inherited, coefficient: rule.inheritance.coefficient, scope: rule.inheritance.scope, sourceHash: transformationSourceHash, sourceStats: Object.fromEntries(fields.map(f => [f, h[f]])), policy: 'VN_AFTERLIFE_PRE_EQUIPMENT', createdAt: Date.now() };
            const removed = this.spend(s, rule.cost);
            this.db.prepare('INSERT INTO player_transformations VALUES(?,?,?,?,?,?,?,0)').run(s.user_id, h.id, h.c_id, to, JSON.stringify(h), JSON.stringify(result), Date.now());
            this.db.prepare('UPDATE player_heroes SET config_id=?,state=? WHERE user_id=? AND id=?').run(to, JSON.stringify(result), s.user_id, h.id);
            // Lua dùng card duy nhất trong update để chạy model/hiệu ứng Chuyển Thế.
            audit(this.db, actor, 'hero.transform', s.user_id, `Chuyển Thế cùng instance; ${rule.inheritance.coefficient * 100}% stat trước trang bị; reset hiển thị theo nguồn`, h, result);
            return this.packet(s, removed, [h.id]);
        }, () => ({ ...this.packet(s, [], [String(id)]), replayed: true }));
    }
    prepareQa(s, id, adminId, key) {
        return contentReceipt(this.db, s.user_id, 'admin.transform_prepare', key, { id }, () => {
            const h = this.hero(s, id), rule = transformationSource[h.c_id];
            if (!rule?.afterlife_id?.length || h.evo < 35 || h.bre < 7)
                fail('QA chỉ chuẩn bị tướng đã +35/Chuyển Sinh7 và có target nguồn.');
            const next = { ...h, card_world_step: 3, after_world_point: rule.afterlife_point, _local_transformation_qa: true };
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(next), s.user_id, h.id);
            audit(this.db, adminId, 'hero.transform_qa_prepare', s.user_id, 'QA riêng: hoàn thành gate nhiệm vụ/năng lượng; không phải gameplay gốc', h, next);
            return this.packet(s);
        }, () => this.packet(s));
    }
    grantQaMaterials(s, id, adminId, key) {
        return contentReceipt(this.db, s.user_id, 'admin.transform_materials', key, { id }, () => {
            const h = this.hero(s, id), rule = transformationSource[h.c_id];
            if (!rule?.afterlife_id?.length || h.evo < 35 || h.bre < 7)
                fail('Cần tướng hợp lệ đã +35/Chuyển Sinh7.');
            const reward = rule.afterlife_material;
            if (!reward.every(r => [6, 7].includes(r[0])))
                fail('Nguyên liệu nguồn chưa được hỗ trợ.');
            new WelfareService(this.db).applyInTransaction(s, reward, { heroes: readConfigSync('character_detail'), items: readConfigSync('item'), equipment: readConfigSync('equip') });
            audit(this.db, adminId, 'hero.transform_qa_materials', s.user_id, 'Cấp đúng một bộ nguyên liệu cấu hình cho QA, không tự Chuyển Thế', null, { heroId: h.id, reward });
            return this.packet(s);
        }, () => this.packet(s));
    }
    restoreQa(s, id, adminId, key) {
        return contentReceipt(this.db, s.user_id, 'admin.transform_restore', key, { id }, () => {
            const h = this.hero(s, id), r = this.db.prepare('SELECT * FROM player_transformations WHERE user_id=? AND hero_id=? AND restored=0 ORDER BY created_at DESC LIMIT 1').get(s.user_id, h.id);
            if (!r)
                fail('Không có snapshot Chuyển Thế để khôi phục.');
            const before = JSON.parse(String(r.before_state));
            if (!before._local_transformation_qa || JSON.stringify(h) !== r.after_state)
                fail('Chỉ khôi phục lượt QA khi instance chưa tăng EXP hoặc thay đổi thêm.');
            this.db.prepare('UPDATE player_heroes SET config_id=?,state=? WHERE user_id=? AND id=?').run(before.c_id, JSON.stringify(before), s.user_id, h.id);
            this.db.prepare('UPDATE player_transformations SET restored=1 WHERE user_id=? AND hero_id=? AND source_id=?').run(s.user_id, h.id, r.source_id);
            audit(this.db, adminId, 'hero.transform_qa_restore', s.user_id, 'Khôi phục đúng instance QA; không hoàn vật phẩm/tiền, không đổi account khác', h, before);
            return this.packet(s);
        }, () => this.packet(s));
    }
    repairInheritance(s, id, adminId, key) {
        return contentReceipt(this.db, s.user_id, 'admin.transform_repair', key, { id }, () => {
            const h = this.hero(s, id), assessment = this.inheritanceAssessment(s, h);
            if (!assessment.repairAvailable)
                fail('Không có snapshot nguồn đủ an toàn; giữ nguyên instance và tiến trình.');
            const row = this.db.prepare('SELECT * FROM player_transformations WHERE user_id=? AND hero_id=? AND target_id=? AND restored=0 ORDER BY created_at DESC LIMIT 1').get(s.user_id, h.id, h.c_id);
            const before = JSON.parse(String(row.before_state)), base = createBaseHero(h.id, h.c_id, readConfigSync('character_detail')[h.c_id]), inherited = assessment.expectedInherited;
            const next = { ...h, ...Object.fromEntries(fields.map(f => [f, base[f] + inherited[f]])), _local_transformation: { sourceId: before.c_id, targetId: h.c_id, inherited, coefficient: assessment.coefficient, sourceHash: transformationSourceHash, sourceStats: Object.fromEntries(fields.map(f => [f, before[f]])), scope: 'PRE_EQUIPMENT_PROGRESSION', policy: 'VN_AFTERLIFE_PRE_EQUIPMENT', createdAt: Date.now() } };
            this.db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(next), s.user_id, h.id);
            audit(this.db, adminId, 'hero.transform_inheritance_repair', s.user_id, 'Sửa từ snapshot nguồn xác thực khi tiến trình vẫn bằng snapshot đích; không dựng nguồn, không tiêu/cấp lại vật phẩm', h, next);
            return this.packet(s, [], [h.id]);
        }, () => ({ ...this.packet(s, [], [String(id)]), replayed: true }));
    }
}
