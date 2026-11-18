// Đồ khóa đi theo chủ tướng; không mở khóa, đổi chủ hoặc thay chỉ số.
// Bản chẩn đoán: logic giữ nguyên, chỉ thêm chi tiết vào thông báo lỗi để biết hero/trang bị nào lệch.
export function reconcileBoundEquipment(cards, alignment, positions, definitions) {
  const team=alignment.flat();
  const invalid=(why)=>{throw Object.assign(new Error('Liên kết trang bị không hợp lệ.'+(why?' ['+why+']':'')),{statusCode:422});};
  for(let i=0;i<10;i++)for(let slot=0;slot<4;slot++){
    const id=positions[String(i)][slot];if(id==='0')continue;
    const item=cards.equip[id];if(!item)invalid('ô '+(i+1)+' gửi trang bị '+id+' nhưng tài khoản không có trang bị này');
    // Client giữ lại mảng equip_pos cũ trong lúc đổi tướng/đảo ô. Nếu món đã
    // khóa cho tướng cũ thì tháo khỏi payload trước khi kiểm sort; sort của món
    // có thể đang nằm ở ô khác sau thao tác đảo vị trí và không được làm request
    // đội hình thất bại chỉ vì state UI chưa kịp đồng bộ.
    if(team[i]==='-1'||(item.bind_card&&item.bind_card!==team[i])){positions[String(i)][slot]='0';continue;}
    if(Number(definitions[item.c_id]?.sort)!==slot+1)invalid('trang bị '+id+' (c_id '+item.c_id+') có loại '+definitions[item.c_id]?.sort+' nhưng nằm ô trang bị số '+(slot+1)+(definitions[item.c_id]?'':'; c_id không có trong config equip'));
  }
  for(let i=0;i<10;i++){
    const hero=cards.cards[team[i]];
    for(const raw of hero?.bind_equip??[]){
      if(!raw||String(raw)==='0')continue;
      const id=String(raw),item=cards.equip[id],slot=Number(definitions[item?.c_id]?.sort)-1;
      if(!item)invalid('tướng '+hero.id+' khóa trang bị '+id+' nhưng trang bị này không tồn tại');
      if(item.bind_card!==hero.id)invalid('tướng '+hero.id+' khóa trang bị '+id+' nhưng trang bị ghi chủ là '+item.bind_card);
      if(!Number.isInteger(slot)||slot<0||slot>3)invalid('trang bị '+id+' (c_id '+item.c_id+') không có loại ô hợp lệ trong config');
      for(const row of Object.values(positions))for(let j=0;j<4;j++)if(row[j]===id)row[j]='0';
      positions[String(i)][slot]=id;
    }
  }
}
