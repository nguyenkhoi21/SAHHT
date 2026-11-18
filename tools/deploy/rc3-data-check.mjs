// Chạy qua root SSH tương tác, chỉ in số lượng/hash; không in tài khoản hoặc secret.
import {DatabaseSync} from 'node:sqlite';
import {createHash,publicEncrypt,constants} from 'node:crypto';
import {readFile,writeFile,readdir,stat,copyFile} from 'node:fs/promises';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const release='/opt/sahht/releases/release-20261028-phase30-rc3';
const work=process.env.RC3_AUDIT_DIRECTORY;
assert(work?.startsWith('/var/backups/sahht/rc3-'));
const database=process.env.ACCOUNT_DB_PATH;
assert.equal(database,'/var/lib/sahht/online.db');
const {BackupStore,dryRunArchive}=await import(pathToFileURL(release+'/server/dist/system/backup.js'));
const {openDatabase}=await import(pathToFileURL(release+'/server/dist/db/database.js'));
const secret=(await readFile(process.env.BACKUP_KEY_FILE,'utf8')).trim();
const schema=d=>Number(d.prepare('PRAGMA user_version').get().user_version);
function snapshot(path){
 const d=new DatabaseSync(path,{readOnly:true});
 try{
  assert.equal(d.prepare('PRAGMA integrity_check').get().integrity_check,'ok');
  assert.equal(d.prepare('PRAGMA foreign_key_check').all().length,0);
  const tables=Object.fromEntries(d.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all().map(({name})=>{
   const rows=d.prepare('SELECT * FROM '+JSON.stringify(name)+' ORDER BY rowid').all();
   return [name,{rows:rows.length,sha256:createHash('sha256').update(JSON.stringify(rows)).digest('hex')}];
  }));
  return {schema:schema(d),integrity:'ok',foreignKeyViolations:0,tables};
 }finally{d.close();}
}
function unchanged(before,after){
 for(const [name,info]of Object.entries(before.tables))assert.deepEqual(after.tables[name],info,'Dữ liệu cũ thay đổi trong migration: '+name);
}
async function report(name,value){await writeFile(join(work,name+'.json'),JSON.stringify(value,null,2),{mode:0o600});return value;}
async function backup(reason,oldRelease){
 const d=new DatabaseSync(database,{readOnly:true});
 try{
  const configs=['server-list.json','local-hero-definitions.json','vip-store-compatible.json'].map(n=>oldRelease+'/server/data/'+n);
  const b=new BackupStore(d,{directory:process.env.BACKUP_DIRECTORY,environment:'ONLINE',dataFiles:configs});
  const made=await b.create(secret,reason);await b.verify(made.id,secret);
  return {...made,archive:join(process.env.BACKUP_DIRECTORY,made.id+'.sahht')};
 }finally{d.close();}
}
async function verifyRelease(){
 const manifest=JSON.parse(await readFile(release+'/release-manifest.json','utf8'));
 assert.equal(manifest.release,'release-20261028-phase30-rc3');assert.equal(manifest.schemaVersion,23);assert.equal(manifest.databaseIncluded,false);
 for(const [path,sha]of Object.entries(manifest.files)){
  assert(!path.startsWith('/')&&!path.split('/').includes('..'));
  assert.equal(createHash('sha256').update(await readFile(release+'/'+path)).digest('hex'),sha,'Release khác checksum: '+path);
 }
 return Object.keys(manifest.files).length;
}
const mode=process.argv[2],old=process.env.RC3_PREVIOUS_RELEASE;
assert(old?.startsWith('/opt/sahht/releases/release-'));
if(mode==='prepare'){
 const filesVerified=await verifyRelease();
 const baseline=snapshot(database);assert.equal(baseline.schema,22,'Chỉ cho chuỗi đã duyệt22→23');
 const persistentFiles=[];
 for(const name of ['server-list.json','local-hero-definitions.json','vip-store-compatible.json']){
  const a=await readFile(old+'/server/data/'+name),b=await readFile(release+'/server/data/'+name);assert.deepEqual(a,b,'Cấu hình persistent khác cần duyệt riêng: '+name);
  persistentFiles.push({name,sha256:createHash('sha256').update(a).digest('hex')});
 }
 const external=[];
 for(const folder of ['/var/lib/sahht','/opt/sahht/shared'])for(const name of await readdir(folder)){
  const path=join(folder,name),info=await stat(path);
  if(folder==='/var/lib/sahht'&&['online.db','online.db-wal','online.db-shm'].includes(name))continue;
  if(info.isDirectory()&&(await readdir(path)).length===0)continue;
  external.push({path,bytes:info.size});
 }
 assert.equal(external.length,0,'Có persistent ngoài DB chưa đưa vào backup, dừng để kiểm');
 const made=await backup('pre-rc3',old);
 const stage=join(process.env.BACKUP_DIRECTORY,'restore-stage-rc3-'+made.id);
 const restored=await dryRunArchive(made.archive,secret,process.env.BACKUP_DIRECTORY,23,stage);
 const before=snapshot(stage+'/database.sqlite');
 const migrated=openDatabase(stage+'/database.sqlite');migrated.close();
 const after=snapshot(stage+'/database.sqlite');assert.equal(after.schema,23);unchanged(before,after);
 const again=openDatabase(stage+'/database.sqlite');again.close();assert.deepEqual(snapshot(stage+'/database.sqlite'),after);
 const result=await report('prepared',{ok:true,release,previousRelease:old,filesVerified,baseline,persistentFiles,externalPersistent:external,backup:made,restore:restored,migration:{from:22,to:23,oldTablesPreserved:Object.keys(before.tables).length,idempotent:true,integrity:'ok'}});
 const recipient=await readFile(join(work,'backup-recipient.pem'),'utf8');
 await report('backup-key-escrow',{format:'SAHHT-OPS-KEY-OAEP-SHA256',recipientSha256:createHash('sha256').update(recipient).digest('hex'),ciphertext:publicEncrypt({key:recipient,padding:constants.RSA_PKCS1_OAEP_PADDING,oaepHash:'sha256'},Buffer.from(secret)).toString('base64')});
 console.log(JSON.stringify({ok:true,phase:mode,backupId:made.id,backupSha256:made.sha256,oldTablesPreserved:result.migration.oldTablesPreserved}));
}else if(mode==='migrate-live'){
 const prepared=JSON.parse(await readFile(join(work,'prepared.json'),'utf8'));assert.equal(prepared.ok,true);
 const check=new DatabaseSync(database,{readOnly:true});try{assert.equal(schema(check),22);}finally{check.close();}
 const made=await backup('pre-rc3-quiesced',old),before=snapshot(database);
 await report('quiesced-baseline',{...before,backup:made});
 const db=openDatabase(database);db.close();const after=snapshot(database);assert.equal(after.schema,23);unchanged(before,after);
 await report('migration',{ok:true,from:before.schema,to:after.schema,oldTablesPreserved:Object.keys(before.tables).length,before,after,backup:made});
 console.log(JSON.stringify({ok:true,phase:mode,schema:23,oldTablesPreserved:Object.keys(before.tables).length,backupId:made.id}));
}else if(mode==='post'){
 const migration=JSON.parse(await readFile(join(work,'migration.json'),'utf8')),current=snapshot(database);assert.equal(current.schema,23);
 const preserved=Object.entries(migration.before.tables).map(([name,info])=>({name,before:info.rows,after:current.tables[name]?.rows,identical:info.sha256===current.tables[name]?.sha256}));
 assert(preserved.every(t=>t.after>=t.before),'Có bảng giảm số dòng sau restart, cần kiểm riêng');
 const made=await backup('post-rc3',release),checked=await dryRunArchive(made.archive,secret,process.env.BACKUP_DIRECTORY,23);
 await report('post',{ok:true,release,schema:23,integrity:'ok',foreignKeyViolations:0,preservation:preserved,backup:made,backupVerified:checked});
 console.log(JSON.stringify({ok:true,phase:mode,schema:23,backupId:made.id,tables:preserved.length,changedAfterStart:preserved.filter(t=>!t.identical).map(t=>t.name)}));
}else throw Error('Chỉ hỗ trợ prepare/migrate-live/post');
