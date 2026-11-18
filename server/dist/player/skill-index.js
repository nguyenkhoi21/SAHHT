import { readFile } from 'node:fs/promises';
import { localContent, readConfigSync } from './local-content.js';
let index;
export function heroSkillIndex() {
    index ??= readFile(new URL('../../../work/extracted-data/hero-skill-index.json', import.meta.url), 'utf8').then(raw => {
        const base = JSON.parse(raw), extra = localContent()?.skillIndex;
        const heroByConfigId = { ...base.heroByConfigId, ...extra?.heroByConfigId }, heroes = readConfigSync('character_detail');
        const heroByName = { ...base.heroByName };
        for (const [id, h] of Object.entries(heroByConfigId)) {
            const name = heroes[id]?.name ?? h.name;
            heroByConfigId[id] = { ...h, name };
            heroByName[name] = [...new Set([...(heroByName[name] ?? []), Number(id)])];
        }
        return { ...base, heroByName, heroByConfigId, skillById: { ...base.skillById, ...extra?.skillById } };
    });
    return index;
}
