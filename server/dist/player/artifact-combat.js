export function artifactBattleEffects(lines) { const bySprite = new Map(); for (const line of lines)
    if (line.sprite && ['fb_dfs_jianshang', 'fb_hurt_addHp1'].includes(line.sprite))
        bySprite.set(line.sprite, line); return [...bySprite.values()]; }
export function artifactReduction(lines) { return Math.max(0, ...artifactBattleEffects(lines).filter(v => v.sprite === 'fb_dfs_jianshang').map(v => Math.min(100, Number(v.effect)))); }
export function artifactLifeSteal(lines, damage) { const last = artifactBattleEffects(lines).find(v => v.sprite === 'fb_hurt_addHp1'); return last ? Math.floor(damage * Number(last.effect) / 100) : 0; }
