import {AuthService} from './dist/auth/auth.service.js';
import {readConfigSync as config} from './dist/player/local-content.js';
import {createBaseHero,createBaseEquipment} from './dist/player/definitions.js';
import {qaHeroPlan} from './dist/player/qa-hero.js';
import {fatePreset} from './dist/player/fate-empowerment.js';
import {randomUUID} from 'node:crypto';
import {repairOfflineEquipment} from './repair-offline-equipment.mjs';
import {slotState,assistantEffectWire} from './dist/player/formation-systems.js';
import {backup} from 'node:sqlite';
import {existsSync} from 'node:fs';

export async function upgradeOffline(path) {
  const auth=new AuthService(path),db=auth.db;
  db.exec('CREATE TABLE IF NOT EXISTS offline_updates(version INTEGER PRIMARY KEY,applied_at INTEGER NOT NULL)');
  let changed=false;
  if(db.prepare('SELECT 1 FROM offline_updates WHERE version=16').get()){
    changed=await repairOfflineEquipment(db,path);
  }
  const main=db.prepare("SELECT id FROM users WHERE username='user01'").get();
  if(!main){db.close();throw Error('Save offline thiếu tài khoản QA gốc.');}
  const defs=config('character_detail'),equips=config('equip'),skins=config('character_skin');
  const horse=[119405,121405,120405,122405];
  const targets=[81800,81200,84500,84200,84100,84000,83900,83800,83700,83600,83500,83300,83200,83000,82900,82800,82700,82600,82500,82400,82300,82200,82100,82000,81900];
  const plans=new Map();
  for(const cid of targets){if(!defs[cid])continue;try{plans.set(cid,(await qaHeroPlan(createBaseHero('qa-probe',cid,defs[cid]),250)).state);}catch(e){if(cid===81800||cid===81200)throw e;}}
  if(plans.size<5)throw Error('Thiếu năm tướng chuyển thế có preset hợp lệ.');
  const hero=(uid,cid)=>{
    const old=db.prepare('SELECT id,state FROM player_heroes WHERE user_id=? AND config_id=? ORDER BY id LIMIT 1').get(uid,cid);
    const id=old?String(old.id):`offline-${uid}-${cid}-${randomUUID().slice(0,8)}`;
    if(!old){const state={...plans.get(cid),id};db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(uid,id,cid,JSON.stringify(state));}
    return id;
  };
  if(!db.prepare('SELECT 1 FROM offline_updates WHERE version=16').get()){
  db.exec('BEGIN IMMEDIATE');
  try{
    const uid=Number(main.id),row=db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid),p=JSON.parse(row.profile);
    for(const field of ['min_fate_stone','mid_fate_stone','max_fate_stone'])p[field]=Math.max(100000,Number(p[field]??0));
    db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p),uid);
    const stock=(table,id,n,kind)=>{
      if(kind)db.prepare(`INSERT INTO ${table}(user_id,kind,config_id,quantity) VALUES(?,?,?,?) ON CONFLICT(user_id,kind,config_id) DO UPDATE SET quantity=MAX(quantity,excluded.quantity)`).run(uid,kind,id,n);
      else db.prepare(`INSERT INTO ${table}(user_id,config_id,quantity) VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=MAX(quantity,excluded.quantity)`).run(uid,id,n);
    };
    for(const cid of [601,602,603,604,605])stock('player_fate_gems',cid,300);
    for(const [cid,n]of [[9102120,150],[522134,150],[266,500],[9100994,1000]]){if(!config('item')[cid])throw Error('Thiếu item '+cid);stock('player_items',cid,n);}
    for(const cid of [1,2,3])stock('player_fate_materials',cid,1000,'stone');
    for(const cid of [81200,81800])hero(uid,cid);
    for(const cid of [425000,428000]){if(!skins[cid])throw Error('Thiếu skin '+cid);db.prepare('INSERT OR IGNORE INTO player_skins VALUES(?,?,?,?,?)').run(uid,cid,JSON.stringify(skins[cid].add_ability[0]),0,Date.now());}
    const pool=[...plans.keys()];
    for(let bot=1;bot<=20;bot++){
      const user=db.prepare('SELECT id FROM users WHERE username=?').get('bot'+String(bot).padStart(2,'0'));if(!user)throw Error('Thiếu bot '+bot);
      const bid=Number(user.id),r=db.prepare('SELECT profile,formation FROM player_state WHERE user_id=?').get(bid),bp=JSON.parse(r.profile),f=JSON.parse(r.formation);
      bp.show_name='Cẩu Tặc bị gay';bp.level=250;bp.vip=15;
      const cids=[81800,81200];for(let k=0;cids.length<5&&k<pool.length;k++){const cid=pool[(bot*3+k)%pool.length];if(!cids.includes(cid))cids.push(cid);}
      const ids=cids.map(cid=>hero(bid,cid));
      f.alignment=[ids,Array(5).fill('-1')];f.equip_pos=Object.fromEntries(Array.from({length:10},(_,i)=>[String(i),Array(4).fill('0')]));
      for(let pos=0;pos<ids.length;pos++){
        const hid=ids[pos],h={...plans.get(cids[pos]),id:hid,bind_equip:Array(4).fill(0)};
        for(const cid of horse){
          const ec=equips[cid];if(!ec)throw Error('Thiếu bộ Năm Ngựa '+cid);
          const id=`offline-horse-${bid}-${pos}-${cid}`,tier=Object.values(config('equip_fate')).filter(t=>t.equip_quality===ec.quality).sort((a,b)=>a.id-b.id).at(-1);
          if(!tier)throw Error('Thiếu cấp khóa Vận Mệnh');
          const state={...createBaseEquipment(id,cid,ec),lv:250,bind_card:hid,bind_data:{[ec.ability1]:tier.refresh_range1,[ec.ability2]:tier.refresh_range2},gem_fate:[]};
          for(let slot=0;slot<4;slot++){
            const gemCid=slot===0?600+ec.sort:605,gemId=`${gemCid}-${randomUUID()}`,preset=fatePreset({configId:gemCid,skillId:24});
            db.prepare('INSERT INTO player_fate_special VALUES(?,?,?,?)').run(bid,gemId,gemCid,JSON.stringify({...preset,createdAt:Date.now()}));state.gem_fate.push(gemId);
          }
          db.prepare('INSERT OR REPLACE INTO player_equipment VALUES(?,?,?,?)').run(bid,id,cid,JSON.stringify(state));
          f.equip_pos[String(pos)][ec.sort-1]=id;h.bind_equip[ec.sort-1]=id;
        }
        db.prepare('UPDATE player_heroes SET state=? WHERE user_id=? AND id=?').run(JSON.stringify(h),bid,hid);
      }
      db.prepare('UPDATE player_state SET profile=?,formation=? WHERE user_id=?').run(JSON.stringify(bp),JSON.stringify(f),bid);
    }
    db.prepare('INSERT INTO offline_updates VALUES(16,?)').run(Date.now());db.exec('COMMIT');changed=true;
  }catch(e){db.exec('ROLLBACK');db.close();throw e;}
  }
  changed=(await repairOfflineEquipment(db,path))||changed;
  // Version 19: additive QA extension for the requested offline test account.
  // It also repairs the skin link for Kakarot/Inori and never resets existing rows.
  if(!db.prepare('SELECT 1 FROM offline_updates WHERE version=19').get()){
    if(!existsSync(path+'.pre19.db'))await backup(db,path+'.pre19.db');
    const uid=Number(main.id),row=db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid),p=JSON.parse(row.profile);
    db.exec('BEGIN IMMEDIATE');
    try{
      for(const field of ['min_fate_stone','mid_fate_stone','max_fate_stone'])p[field]=Math.max(100000,Number(p[field]??0));
      db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p),uid);
      const stock=(table,id,n,kind)=>kind
        ?db.prepare(`INSERT INTO ${table}(user_id,kind,config_id,quantity) VALUES(?,?,?,?) ON CONFLICT(user_id,kind,config_id) DO UPDATE SET quantity=MAX(quantity,excluded.quantity)`).run(uid,kind,id,n)
        :db.prepare(`INSERT INTO ${table}(user_id,config_id,quantity) VALUES(?,?,?) ON CONFLICT(user_id,config_id) DO UPDATE SET quantity=MAX(quantity,excluded.quantity)`).run(uid,id,n);
      for(const cid of [401,402,403,404,405,501,502,503,504,505,601,602,603,604,605])stock('player_fate_gems',cid,300);
      for(const [cid,n]of [[9101003,1000],[9102120,150],[522134,150],[266,500],[9100994,1000]]){if(!config('item')[cid])throw Error('Thiếu item '+cid);stock('player_items',cid,n);}
      for(const cid of [1,2,3])stock('player_fate_materials',cid,100000,'stone');
      for(const cid of [81200,81800,83300]){
        const old=db.prepare('SELECT id FROM player_heroes WHERE user_id=? AND config_id=? ORDER BY id LIMIT 1').get(uid,cid);
        if(!old){const id=`offline-${uid}-${cid}-${randomUUID().slice(0,8)}`,plan=plans.get(cid);if(!plan)throw Error('Thiếu preset tướng '+cid);db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(uid,id,cid,JSON.stringify({...plan,id}));}
      }
      for(const cid of [425000,428000]){
        if(!skins[cid])throw Error('Thiếu skin '+cid);
        db.prepare('INSERT OR IGNORE INTO player_skins VALUES(?,?,?,?,?)').run(uid,cid,JSON.stringify(skins[cid].add_ability[0]),0,Date.now());
        db.prepare('UPDATE player_skins SET equipped=0 WHERE user_id=? AND skin_id=?').run(uid,cid);
      }
      const form=JSON.parse(db.prepare('SELECT formation FROM player_state WHERE user_id=?').get(uid).formation),state=slotState(form);
      form._local_slot_qa??={};
      for(const system of ['assistant','destiny','formation_bonus']){
        form._local_slot_qa[system]??=state[system];
        form[system]=state[system].map(v=>v==='-1'?'0':v);
      }
      form.assistant_effect=assistantEffectWire(form);
      db.prepare('UPDATE player_state SET formation=? WHERE user_id=?').run(JSON.stringify(form),uid);
      db.prepare('INSERT INTO offline_updates VALUES(19,?)').run(Date.now());db.exec('COMMIT');changed=true;
    }catch(e){db.exec('ROLLBACK');db.close();throw e;}
  }
  if(!db.prepare('SELECT 1 FROM offline_updates WHERE version=20').get()){
    if(!existsSync(path+'.pre20.db'))await backup(db,path+'.pre20.db');
    db.exec('BEGIN IMMEDIATE');
    try{
      const uid=Number(main.id),p=JSON.parse(db.prepare('SELECT profile FROM player_state WHERE user_id=?').get(uid).profile),before={...p};
      for(const field of ['min_fate_stone','mid_fate_stone','max_fate_stone'])p[field]=Math.max(10000,Number(p[field]??0));
      db.prepare('UPDATE player_state SET profile=? WHERE user_id=?').run(JSON.stringify(p),uid);
      // Save QA cũ có skin đang mặc của tướng đã bị thay khỏi roster. Giữ quyền
      // sở hữu, chỉ bỏ trạng thái mặc không còn hero để UI không gửi ID stale.
      const heroDefs=db.prepare('SELECT config_id FROM player_heroes WHERE user_id=?').all(uid).map(r=>defs[r.config_id]);
      const removed=[];
      for(const r of db.prepare('SELECT skin_id FROM player_skins WHERE user_id=? AND equipped=1').all(uid)){
        if(!heroDefs.some(h=>Number(h?.is_skin)===Number(r.skin_id))){db.prepare('UPDATE player_skins SET equipped=0 WHERE user_id=? AND skin_id=?').run(uid,r.skin_id);removed.push(Number(r.skin_id));}
      }
      db.prepare('INSERT INTO offline_updates VALUES(20,?)').run(Date.now());db.exec('COMMIT');changed=true;
    }catch(e){db.exec('ROLLBACK');db.close();throw e;}
  }
  try{return{applied:changed,version:20,systems:true};}finally{db.close();}
}
