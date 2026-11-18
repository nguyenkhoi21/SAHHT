import { readFile } from 'node:fs/promises';
import { localContent } from './local-content.js';
let index;
export function heroResources() {
    index ??= readFile(new URL('../../../work/extracted-data/hero-resource-index.json', import.meta.url), 'utf8').then(raw => new Map([...JSON.parse(raw).entries, ...(localContent()?.resources ?? [])].map((r) => [r.configId, r])));
    return index;
}
