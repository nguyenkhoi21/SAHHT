import { readFileSync } from 'node:fs';
const manifest = JSON.parse(readFileSync(new URL('../../../tools/runtime/main-event-icons.json', import.meta.url), 'utf8'));
if (manifest.schema !== 1)
    throw Error('Catalog icon Main không tương thích.');
export const mainEventIcons = manifest.events;
