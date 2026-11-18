// is_show là cờ hiển thị túi, không phải quyền nhận thưởng. Các mảnh gốc
// is_show=0 vẫn được giữ trong item.items (consumer game_data / cửa hàng đổi).
export function inventoryRewardItem(c) {
    return !!c && [0, 1].includes(c.is_show) && Number.isSafeInteger(c.stack) && c.stack > 0 && c.stack <= 1000000 && typeof c.name === 'string' && c.name.length > 0 && typeof c.icon === 'string' && c.icon.length > 0 && Number.isSafeInteger(c.quality) && c.quality >= 0 && c.quality <= 6;
}
// Mảnh hiển thị ở màn Mảnh, không ở Túi. Chỉ mở quyền Mail khi có recipe canonical khớp ID.
export function mailRewardItem(id, c, recipe) {
    const fragment = !!recipe && Array.isArray(recipe.change_id) && recipe.change_id.length === 1 && Number.isSafeInteger(recipe.change_id[0][1]) && recipe.change_id[0][2] === 1;
    const hero = fragment && recipe.change_sort === 1 && recipe.change_id[0][0] === 5 && c?.is_use === 0;
    const pet = fragment && recipe.change_sort === 4 && recipe.change_id[0][0] === 25 && c?.is_use === 1 && c.use_num === recipe.need_num?.[0];
    return inventoryRewardItem(c) && (c.is_show === 1 || c.is_show === 0 && Number.isSafeInteger(c.sort) && c.sort > 0 && recipe?.need_item === id && (hero || pet));
}
