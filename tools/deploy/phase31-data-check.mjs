// Kiểm qua root tương tác; secret chỉ đọc từ môi trường, không in bản ghi người chơi.
import {DatabaseSync} from 'node:sqlite';
import {createHash} from 'node:crypto';
import {readFile,writeFile,readdir,stat} from 'node:fs/promises';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const release='/opt/sahht/releases/release-20261028-phase31-v10';
const old='/opt/sahht/releases/release-20261028-phase30-rc3';
const work=process.env.PHASE31_AUDIT_DIRECTORY;
assert.equal(work,'/var/backups/sahht/phase31-v10-20261028');
assert.equal(process.env.ACCOUNT_DB_PATH,'/var/lib/sahht/online.db');
assert.equal(process.env.BACKUP_DIRECTORY,'/var/backups/sahht');
const database=process.env.ACCOUNT_DB_PATH;
const {BackupStore,dryRunArchive}=await import(pathToFileURL(release+'/server/dist/system/backup.js'));
const {openDatabase}=await import(pathToFileURL(release+'/server/dist/db/database.js'));
const secret=(await readFile(process.env.BACKUP_KEY_FILE,'utf8')).trim();
function snapshot(path){
 const db=new DatabaseSync(path,{readOnly:true});try{
  assert.equal(db.prepare('PRAGMA integrity_check').get().integrity_check,'ok');
  assert.equal(db.prepare('PRAGMA foreign_key_check').all().length,0);
  return {schema:Number(db.prepare('PRAGMA user_version').get().user_version),tables:Object.fromEntries(db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all().map(({name})=>{const rows=db.prepare('SELECT * FROM '+JSON.stringify(name)+' ORDER BY rowid').all();return [name,{rows:rows.length,sha256:createHash('sha256').update(JSON.stringify(rows)).digest('hex')}];})),integrity:'ok',foreignKeyViolations:0};
 }finally{db.close();}
}
async function report(name,value){await writeFile(join(work,name+'.json'),JSON.stringify(value,null,2),{mode:0o600});return value;}
async function backup(reason,source){const db=new DatabaseSync(database,{readOnly:true});try{const store=new BackupStore(db,{directory:process.env.BACKUP_DIRECTORY,environment:'ONLINE',dataFiles:['server-list.json','local-hero-definitions.json','vip-store-compatible.json'].map(n=>source+'/server/data/'+n)});const made=await store.create(secret,reason);await store.verify(made.id,secret);return {...made,archive:join(process.env.BACKUP_DIRECTORY,made.id+'.sahht')};}finally{db.close();}}
async function dryRun(made){const stage=join(process.env.BACKUP_DIRECTORY,'restore-stage-phase31-'+made.id),restored=await dryRunArchive(made.archive,secret,process.env.BACKUP_DIRECTORY,23,stage),before=snapshot(stage+'/database.sqlite');const db=openDatabase(stage+'/database.sqlite');db.close();const after=snapshot(stage+'/database.sqlite');assert.deepEqual(after,before,'Schema23 phải không thay dữ liệu khi mở lại');return {archive:restored,schema:23,integrity:'ok',tablesUnchanged:Object.keys(before.tables).length};}
const mode=process.argv[2];
if(mode==='prepare'){
 const manifest=JSON.parse(await readFile(release+'/release-manifest.json','utf8'));
 assert.equal(manifest.release,'release-20261028-phase31-v10');assert.equal(manifest.schemaVersion,23);assert.equal(manifest.databaseIncluded,false);assert.match(manifest.sourceCommit,/^[0-9a-f]{40}$/);
 for(const [path,sha]of Object.entries(manifest.files)){assert(!path.startsWith('/')&&!path.split('/').includes('..'));assert.equal(createHash('sha256').update(await readFile(release+'/'+path)).digest('hex'),sha,path);}
 const external=[];
 for(const dir of ['/var/lib/sahht','/opt/sahht/shared'])for(const name of await readdir(dir)){const path=join(dir,name),s=await stat(path);if(dir==='/var/lib/sahht'&&['online.db','online.db-wal','online.db-shm'].includes(name))continue;if(s.isDirectory()&&(await readdir(path)).length===0)continue;external.push({path,bytes:s.size});}
 assert.equal(external.length,0,'Có persistent ngoài DB cần bổ sung backup trước');
 for(const name of ['server-list.json','local-hero-definitions.json','vip-store-compatible.json'])assert.deepEqual(await readFile(old+'/server/data/'+name),await readFile(release+'/server/data/'+name),'Không tự ghi đè persistent config: '+name);
 assert.equal(snapshot(database).schema,23,'Chỉ cho nâng code schema23→23 đã duyệt');
 const made=await backup('pre-phase31-v10',old),restored=await dryRun(made);
 const result=await report('prepared',{ok:true,release,previousRelease:old,sourceCommit:manifest.sourceCommit,filesVerified:Object.keys(manifest.files).length,baseline:snapshot(database),externalPersistent:external,backup:made,restore:restored,migration:{from:23,to:23,required:false}});
 console.log(JSON.stringify({ok:true,phase:mode,sourceCommit:result.sourceCommit,backupId:made.id,backupSha256:made.sha256,restoreVerified:true,schema:23}));
}else if(mode==='quiesced'){
 const made=await backup('pre-phase31-v10-quiesced',old),before=snapshot(database);assert.equal(before.schema,23);
 const db=openDatabase(database);db.close();const after=snapshot(database);assert.deepEqual(after,before,'Dữ liệu live phải nguyên trước khi start');
 await report('quiesced',{ok:true,before,after,backup:made,tablesPreserved:Object.keys(before.tables).length,migrationRequired:false});
 console.log(JSON.stringify({ok:true,phase:mode,schema:23,tablesPreserved:Object.keys(before.tables).length,backupId:made.id}));
}else if(mode==='post'){
 const before=JSON.parse(await readFile(join(work,'quiesced.json'),'utf8')).before,current=snapshot(database);assert.equal(current.schema,23);
 const preservation=Object.entries(before.tables).map(([name,v])=>({name,before:v.rows,after:current.tables[name]?.rows,identical:v.sha256===current.tables[name]?.sha256}));
 assert(preservation.every(v=>v.after>=v.before),'Có bảng giảm dòng; dừng để đối chiếu hoạt động sau start');
 const made=await backup('post-phase31-v10',release),restored=await dryRun(made);
 await report('post',{ok:true,release,current,preservation,backup:made,restore:restored});
 console.log(JSON.stringify({ok:true,phase:mode,schema:23,backupId:made.id,tables:preservation.length,changedAfterStart:preservation.filter(v=>!v.identical).map(v=>v.name)}));
}else throw Error('Chỉ hỗ trợ prepare/quiesced/post');
