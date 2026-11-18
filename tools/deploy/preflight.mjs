// Kiểm bản release trên DB tạm, không mở database người chơi.

import {mkdtemp,rm} from 'node:fs/promises';

import {tmpdir} from 'node:os';

import {join} from 'node:path';

import assert from 'node:assert/strict';

import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const runtime=process.argv[2]?resolve(process.argv[2]):new URL('../../',import.meta.url).pathname;
const load=n=>import(pathToFileURL(resolve(runtime,'server/dist',n)).href);
const {buildApp}=await load('app.js');

const {openDatabase,databaseSchemaVersion}=await load('db/database.js');

const {GodfieldService}=await load('player/godfield.service.js');

const {createBaseHero}=await load('player/definitions.js');

const {readConfigSync}=await load('player/local-content.js');

const {AdminAuth}=await load('admin/admin.auth.js');

const {installRegistrationRateLimit}=await load('auth/registration-rate-limit.js');
const {installRegistrationAccountCapacity}=await load('auth/registration-account-capacity.js');
const dir=await mkdtemp(join(tmpdir(),'sahht-release-'));

const setup=openDatabase(join(dir,'isolated.db'));installRegistrationRateLimit(setup);installRegistrationAccountCapacity(setup);setup.close();
const app=await buildApp({localAuth:true,accountDb:join(dir,'isolated.db'),online:true,onlineUnified:true,publicOrigin:'https://103.90.227.23',adminOrigin:'https://103.90.227.23',backupDirectory:join(dir,'backups')});

try{

 assert.equal((await app.inject('/health')).statusCode,200);

 assert.equal((await app.inject('/debug/state')).statusCode,403);

 const secret='Isolated_Preflight_Only_947',names=['preflight_a','preflight_b'];

 const created=await Promise.all(names.map(username=>app.inject({method:'POST',url:'/local-auth/register',payload:{username,password:secret}})));

 assert.ok(created.every(r=>r.statusCode===201));

 const sessions=[];

 for(const username of names){

  const login=await app.inject({method:'POST',url:'/local-auth/login',payload:{username,password:secret}});assert.equal(login.statusCode,200);const s=login.json();

  const q=new URLSearchParams({rans:s.sessionToken,account:'kvgames_local_user_'+s.user.id,method:'new_user',role:'1',server_name:'local-1'});

  const role=await app.inject('/login/?'+q);assert.equal(role.statusCode,200,role.body);const uid=role.json().data.uid;

  q.set('method','mark_user_login');q.set('user_token',uid);

  const mark=await app.inject('/login/?'+q);assert.equal(mark.statusCode,200);q.set('mk',mark.json().data.mk);q.set('method','cards.open');

  const cards=await app.inject('/api/?'+q);assert.equal(cards.statusCode,200,cards.body);assert.equal(cards.json().user_status.uid,uid);

  const list=await app.inject('/login/?'+new URLSearchParams({rans:s.sessionToken,account:'kvgames_local_user_'+s.user.id,method:'get_user_server_list'}));

  assert.ok(list.json().data.server_list.every(e=>e.master_url.startsWith('https://103.90.227.23/')));

  sessions.push({q,uid,userId:s.user.id});

 }

 const other=new URLSearchParams(sessions[0].q);other.set('user_token',sessions[1].uid);assert.equal((await app.inject('/api/?'+other)).statusCode,403);

 assert.equal((await app.inject({url:'/admin/api/backups',headers:{host:'103.90.227.23'}})).statusCode,401);

 const db=openDatabase(join(dir,'isolated.db'));

 try{

  const auth=new AdminAuth(db),headers={host:'103.90.227.23',origin:'https://103.90.227.23'},targetId=sessions[0].userId;let ownerHeaders;

  for(const role of ['OWNER','ADMIN','VIEWER']){

   const username='preflight_'+role.toLowerCase();await auth.create(username,secret,role);

   const login=await app.inject({method:'POST',url:'/admin/api/login',headers,payload:{username,password:secret}});assert.equal(login.statusCode,200);

   const h={...headers,cookie:String(login.headers['set-cookie']).split(';')[0],'x-csrf-token':login.json().csrfToken};

   if(role==='OWNER')ownerHeaders=h;

   const update=await app.inject({method:'POST',url:'/admin/api/players/'+targetId+'/level',headers:h,payload:{level:250}});assert.equal(update.statusCode,role==='VIEWER'?403:200,role+' '+update.body);

   assert.equal((await app.inject({url:'/admin/api/backups',headers:h})).statusCode,role==='OWNER'?200:403);

  }

  assert.equal(db.prepare("SELECT COUNT(*) AS n FROM admin_audit WHERE action='player.level.set'").get().n,2);

  assert.equal((await app.inject({method:'POST',url:'/admin/api/players/'+targetId+'/items',headers:ownerHeaders,payload:{configId:9102472,action:'ADD',amount:100}})).statusCode,200);

  const bulk=new URLSearchParams(sessions[0].q);bulk.set('method','item.use');bulk.set('item_id','9102472');bulk.set('num','100');bulk.set('type_list','1');bulk.set('request_id','preflight-bulk-source-stack');

  const opened=await app.inject('/api/?'+bulk);assert.equal(opened.json().status,'0',opened.body);assert.deepEqual(opened.json().data.effect,[[108,3,100]]);

  assert.equal((await app.inject('/api/?'+bulk)).json().data.replayed,true);

  assert.equal(db.prepare("SELECT quantity FROM player_fate_materials WHERE user_id=? AND kind='stone' AND config_id=3").get(targetId).quantity,100);

  const code='PREFLIGHTFATE',rewards=['min_fate_stone','mid_fate_stone','max_fate_stone'].flatMap(currency=>Array.from({length:3},()=>({kind:'currency',currency,quantity:200})));

  const gift=await app.inject({method:'POST',url:'/admin/api/giftcodes',headers:ownerHeaders,payload:{code,campaign:'Fixture Vận Mệnh',startsAt:new Date(Date.now()-60000).toISOString(),expiresAt:new Date(Date.now()+3600000).toISOString(),rewards}});assert.equal(gift.statusCode,200,gift.body);

  const redeem=new URLSearchParams(sessions[0].q);redeem.set('method','code.use_code');redeem.set('code',code);redeem.set('request_id','preflight-fate-redeem');

  const delivery=await app.inject('/api/?'+redeem);assert.equal(delivery.json().status,'0',delivery.body);

  const claim=new URLSearchParams(sessions[0].q);claim.set('method','notify.read');claim.set('message_id',delivery.json().data.mail_id);

  const claimed=await app.inject('/api/?'+claim);assert.equal(claimed.json().status,'0',claimed.body);for(const currency of ['min_fate_stone','mid_fate_stone','max_fate_stone'])assert.equal(claimed.json().user_status[currency],600);

  // Pha30: chạy đúng hợp đồng ONLINE trong database tạm, không mở database VPS.

  const funding=await app.inject({method:'POST',url:'/admin/api/players/'+targetId+'/currency',headers:ownerHeaders,payload:{action:'ADD',amount:1000}});assert.equal(funding.statusCode,200);

  const rpc=async(i,method,fields={})=>{const q=new URLSearchParams(sessions[i].q);q.set('method',method);q.set('client_content','phase30-v1');for(const [k,v] of Object.entries(fields))q.set(k,String(v));const r=await app.inject('/api/?'+q);assert.equal(r.statusCode,200);const data=r.json();assert.equal(data.status,'0',data.msg??r.body);return data;};

  const before=(await rpc(0,'cards.open')).user_status;

  const shopState=await rpc(0,'shop.open');for(const id of ['1013','1014','1016'])assert.equal(shopState.data.items[id].im_use,0);

  const bought=await rpc(0,'shop.buy',{shop_id:1013,count:1,request_id:'preflight30-buy-bag'});

  assert.equal(bought.user_status.card_max,before.card_max);assert.deepEqual(bought.data.goods,[[6,4001,1]]);

  const inventory=await rpc(0,'cards.open');assert.equal(inventory.data.items['4001'][0],1);

  const used=await rpc(0,'item.use',{item_id:4001,num:1,request_id:'preflight30-use-bag'});

  assert.equal(used.user_status.card_max,before.card_max+5);assert.equal(used.user_status.coin,bought.user_status.coin);

  assert.equal((await rpc(0,'shop.buy',{shop_id:1013,count:1,request_id:'preflight30-buy-bag'})).data.replayed,true);

  assert.equal((await rpc(0,'item.use',{item_id:4001,num:1,request_id:'preflight30-use-bag'})).user_status.card_max,before.card_max+5);

  const friend=await rpc(0,'friend.search',{target_id:sessions[1].uid});assert.equal(friend.data.user[0].uid,sessions[1].uid);

  await rpc(0,'friend.apply_friend',{target_id:sessions[1].uid,request_id:'preflight30-invite'});

  const messages=await rpc(1,'friend.messages');assert.equal(messages.data.messages.length,1);

  const diagnostic=await app.inject({url:'/admin/api/players/'+targetId+'/phase30',headers:ownerHeaders});assert.equal(diagnostic.statusCode,200);assert.equal(diagnostic.json().capacities.length,3);

  assert.equal(db.prepare('PRAGMA user_version').get().user_version,databaseSchemaVersion);

  const read=await rpc(0,'god_field.index');assert.equal(read.data.status,0);

  assert.equal(db.prepare('SELECT COUNT(*) n FROM godfield_competition_groups').get().n,0);

  await rpc(0,'god_field.upload_god_formation');await rpc(0,'god_field.get_combat_rank');

  const formation=new URLSearchParams({request_id:'preflight-godfield-save'});

  for(let t=1;t<=3;t++){

   const hero=createBaseHero('preflight-god-'+t,5300,readConfigSync('character_detail')[5300]);

   db.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(targetId,hero.id,5300,JSON.stringify(hero));

   formation.set('god_formation_'+t,['0',hero.id,...Array(7).fill('-1')].join('_'));

  }

  new GodfieldService(db).save({user_id:targetId},formation);

  await rpc(0,'universe_arena.index');await rpc(0,'universe_arena.team_index',{team_id:1});

  await rpc(0,'zodiac.index');await rpc(0,'highway.index');await rpc(0,'highway.shop_index',{sort:1});

  const frozen=JSON.stringify(db.prepare('SELECT * FROM player_items').all());

  for(const [method,params]of [

   ['god_field.god_field_battle',{}],['god_field.buy_ship_ticket',{}],

   ['highway.trans',{}],['highway.trans_index',{}],

   ['highway.betting',{local_play:'pool-v1',ship_id:1,num:5}],

   ['highway.add_power',{local_play:'pool-v1',ship_id:1,num:'100_0_0_0'}],

   ['highway.add_buff',{local_play:'pool-v1',ship_id:1,sort:2}],

   ['highway.area_index',{local_qa:'race-v1',area_id:4}]

  ]){

   const q=new URLSearchParams(sessions[0].q);q.set('method',method);for(const[k,v]of Object.entries(params))q.set(k,String(v));

   const r=await app.inject('/api/?'+q);assert.equal(r.statusCode,200);assert.equal(r.json().status,'SOURCE_BLOCKED',method+' '+r.body);

  }

  assert.equal(JSON.stringify(db.prepare('SELECT * FROM player_items').all()),frozen);

  const tv=await app.inject({url:'/admin/api/players/'+targetId+'/than-vuc',headers:ownerHeaders});assert.equal(tv.statusCode,200,tv.body);assert.equal(tv.json().qaAllowed,false);assert.equal(tv.json().highway.qaFleet,undefined);

  for(const endpoint of ['highway-play','highway-level-preview?total=0&added=1'])assert.equal((await app.inject({url:'/admin/api/players/'+targetId+'/than-vuc/'+endpoint,headers:ownerHeaders})).statusCode,403);



 }finally{db.close();}

 console.log(JSON.stringify({ok:true,checks:['Linux runtime/resources','DB tạm schema'+databaseSchemaVersion+'','hai tài khoản đồng thời','login/role/cards','UID isolation','server HTTPS URLs','debug/backup protected','GM OWNER/ADMIN; VIEWER denied; audit; backup OWNER only','bulk100 đúng nguồn; replay không cấp trùng','Giftcode9 dòng Đá Vận Mệnh → đổi code → nhận Mail đúng600 mỗi loại','Pha30 ONLINE: mua cấp túi, dùng tăng kho, retry không trùng','Pha30 ONLINE: UID/lời mời hai tài khoản và Admin diagnostics']}));

}finally{await app.close();await rm(dir,{recursive:true,force:true});}

