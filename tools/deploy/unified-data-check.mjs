// Kiểm backup/restore/migration; chỉ xuất summary/hash, không xuất record hoặc khóa.
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {createHash} from 'node:crypto';
import {readFile,writeFile,readdir,lstat} from 'node:fs/promises';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
const id=process.env.UNIFIED_RELEASE;
assert.match(id??'',/^release-\d{8}-unified-v\d+$/);
const release='/opt/sahht/releases/'+id,audit='/var/backups/sahht/'+id;
const database=process.env.ACCOUNT_DB_PATH,old=process.env.UNIFIED_PREVIOUS_RELEASE,rollback=process.env.UNIFIED_ROLLBACK_RELEASE;
assert.equal(database,'/var/lib/sahht/online.db');
assert.equal(process.env.APP_ENV,'online');assert.equal(process.env.BACKUP_DIRECTORY,'/var/backups/sahht');
assert.match(old??'',/^\/opt\/sahht\/releases\/release-[a-z0-9-]+$/);
assert.equal(rollback,release+'-rollback');
const {BackupStore,dryRunArchive}=await import(pathToFileURL(release+'/server/dist/system/backup.js'));
const {openDatabase,databaseSchemaVersion}=await import(pathToFileURL(release+'/server/dist/db/database.js'));
assert.equal(databaseSchemaVersion,32);
const secret=(await readFile(process.env.BACKUP_KEY_FILE,'utf8')).trim();
const digest=b=>createHash('sha256').update(b).digest('hex');
function snapshot(path){
 const d=new DatabaseSync(path,{readOnly:true});
 try{
  assert.equal(d.prepare('PRAGMA integrity_check').get().integrity_check,'ok');
  assert.equal(d.prepare('PRAGMA foreign_key_check').all().length,0);
  const tables=Object.fromEntries(d.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all().map(({name})=>{
   const rows=d.prepare('SELECT * FROM '+JSON.stringify(name)+' ORDER BY rowid').all();
   return [name,{rows:rows.length,sha256:digest(JSON.stringify(rows))}];
  }));
  return {schema:Number(d.prepare('PRAGMA user_version').get().user_version),integrity:'ok',foreignKeyViolations:0,tables};
 }finally{d.close();}
}
function unchanged(before,after){
 for(const [name,value]of Object.entries(before.tables))assert.deepEqual(after.tables[name],value,'Migration đổi dữ liệu bảng '+name);
}
async function save(name,data){await writeFile(join(audit,name+'.json'),JSON.stringify(data,null,2),{mode:0o600});}
async function backup(reason){
 const d=new DatabaseSync(database,{readOnly:true});
 try{
  const store=new BackupStore(d,{directory:process.env.BACKUP_DIRECTORY,environment:'ONLINE',dataFiles:['server-list.json','local-hero-definitions.json','vip-store-compatible.json'].map(n=>(reason.startsWith('post')?release:old)+'/server/data/'+n)});
  const made=await store.create(secret,reason);await store.verify(made.id,secret);
  return {...made,archive:join(process.env.BACKUP_DIRECTORY,made.id+'.sahht')};
 }finally{d.close();}
}
async function verifyManifest(path){
 const m=JSON.parse(await readFile(path+'/release-manifest.json','utf8'));
 assert.equal(m.databaseIncluded,false);assert.equal(m.schemaVersion,32);
 for(const [name,sha]of Object.entries(m.files)){
  assert(!name.startsWith('/')&&!name.split('/').includes('..')&&!name.includes('\\'));
  assert.equal(digest(await readFile(path+'/'+name)),sha,'Sai checksum '+name);
 }
 return m;
}
const mode=process.argv[2];
if(mode==='prepare'){
 const manifest=await verifyManifest(release);await verifyManifest(rollback);
 const live=snapshot(database);assert.equal(live.schema,26,'Chỉ nhận baseline ONLINE26 đã đối chiếu.');
 const persistent=[];
 for(const name of ['server-list.json','local-hero-definitions.json','vip-store-compatible.json']){
  const a=await readFile(old+'/server/data/'+name),b=await readFile(release+'/server/data/'+name);
  assert.deepEqual(a,b,'Cấu hình production khác: '+name);persistent.push({name,sha256:digest(a)});
 }
 // Những thư mục này đã có trong tar root-only. Không cho symlink dẫn dữ liệu ra ngoài phạm vi backup.
 async function noLinks(path){for(const n of await readdir(path)){const p=join(path,n),s=await lstat(p);assert(!s.isSymbolicLink(),'Persistent symlink cần review: '+p);if(s.isDirectory())await noLinks(p);}}
 await noLinks('/var/lib/sahht');await noLinks('/opt/sahht/shared');
 const made=await backup('pre-unified-v12'),stage=join(process.env.BACKUP_DIRECTORY,'restore-stage-unified-'+made.id);
 const restored=await dryRunArchive(made.archive,secret,process.env.BACKUP_DIRECTORY,32,stage);
 const before=snapshot(stage+'/database.sqlite');assert.equal(before.schema,26);
 openDatabase(stage+'/database.sqlite').close();const after=snapshot(stage+'/database.sqlite');unchanged(before,after);assert.equal(after.schema,32);
 openDatabase(stage+'/database.sqlite').close();assert.deepEqual(snapshot(stage+'/database.sqlite'),after);
 const rb=(await import(pathToFileURL(rollback+'/server/dist/db/database.js'))).openDatabase;
 rb(stage+'/database.sqlite').close();assert.deepEqual(snapshot(stage+'/database.sqlite'),after);
 await save('prepared',{ok:true,release:id,sourceCommit:manifest.sourceCommit,previousRelease:old,rollback,manifestFiles:Object.keys(manifest.files).length,backup:made,restored,before,after,persistent,oldTablesPreserved:Object.keys(before.tables).length,idempotent:true,rollbackModuleVerified:true});
 console.log(JSON.stringify({ok:true,mode,backupId:made.id,migration:'26→32',oldTablesPreserved:Object.keys(before.tables).length}));
}else if(mode==='migrate-live'){
 assert.equal(JSON.parse(await readFile(join(audit,'prepared.json'),'utf8')).ok,true);
 assert.equal(snapshot(database).schema,26);
 const made=await backup('pre-unified-quiesced'),before=snapshot(database);
 await save('quiesced-baseline',{...before,backup:made});
 // Không mở DB live bằng module mới trước khi bản backup cuối đã được verify.
 openDatabase(database).close();const after=snapshot(database);assert.equal(after.schema,32);unchanged(before,after);
 await save('migration',{ok:true,from:26,to:32,before,after,backup:made,oldTablesPreserved:Object.keys(before.tables).length});
 console.log(JSON.stringify({ok:true,mode,oldTablesPreserved:Object.keys(before.tables).length}));
}else if(mode==='post'){
 const migrated=JSON.parse(await readFile(join(audit,'migration.json'),'utf8')),current=snapshot(database);
 assert.equal(current.schema,32);
 const made=await backup('post-unified-v12'),restore=await dryRunArchive(made.archive,secret,process.env.BACKUP_DIRECTORY,32);
 const changesAfterStart=Object.entries(migrated.after.tables).filter(([n,v])=>JSON.stringify(current.tables[n])!==JSON.stringify(v)).map(([name])=>name);
 await save('post',{ok:true,release:id,current,backup:made,restore,changesAfterStart,migrationPreserved:migrated.oldTablesPreserved});
 console.log(JSON.stringify({ok:true,mode,schema:32,backupId:made.id,changesAfterStart}));
}else throw Error('Chỉ hỗ trợ prepare/migrate-live/post.');
