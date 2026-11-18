// DB tổng hợp tạo bằng đúng module schema26 đang chạy trên VPS; không dùng DB LOCAL/production.
import assert from 'node:assert/strict';
import {DatabaseSync,backup} from 'node:sqlite';
import {readFile,mkdtemp,writeFile} from 'node:fs/promises';
import {createHash,randomBytes} from 'node:crypto';
import {join,resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {openDatabase} from '../../server/dist/db/database.js';
import {BackupStore,dryRunArchive} from '../../server/dist/system/backup.js';
const root=resolve(import.meta.dirname,'../..'),modulePath=join(root,'work/unified-release/private/schema26-database.mjs');
const hash=b=>createHash('sha256').update(b).digest('hex');
assert.equal(hash(await readFile(modulePath)),'e6da778d738860415d723a7e8855744b7cd13bbc0475d975649d00c1f246bde6');
const legacy=await import(pathToFileURL(modulePath));assert.equal(legacy.databaseSchemaVersion,26);
const dir=await mkdtemp(join(root,'work/unified-release/private/migration-')),path=join(dir,'synthetic26.sqlite');
function state(file){const d=new DatabaseSync(file,{readOnly:true});try{
 assert.equal(d.prepare('PRAGMA integrity_check').get().integrity_check,'ok');assert.equal(d.prepare('PRAGMA foreign_key_check').all().length,0);
 return {schema:Number(d.prepare('PRAGMA user_version').get().user_version),tables:Object.fromEntries(d.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all().map(({name})=>{const rows=d.prepare('SELECT * FROM '+JSON.stringify(name)+' ORDER BY rowid').all();return [name,{count:rows.length,sha256:hash(JSON.stringify(rows))}];}))};
}finally{d.close();}}
const d=legacy.openDatabase(path);
for(let i=1;i<=2;i++){
 d.prepare('INSERT INTO users(username,password_hash,created_at,updated_at) VALUES(?,?,1,1)').run('synthetic_migration_'+i,'SYNTHETIC_NOT_A_LOGIN_HASH');
 d.prepare('INSERT INTO player_profiles VALUES(?,?,?,1)').run(i,'local_player_'+(1000000+i),'1');
 d.prepare('INSERT INTO player_state VALUES(?,?,?)').run(i,JSON.stringify({uid:'local_player_'+(1000000+i),show_name:'Kiểm migration '+i,level:100,coin:12345*i,food:45678,vip:7}),JSON.stringify({alignment:[['hero-'+i],[]]}));
 d.prepare('INSERT INTO player_heroes VALUES(?,?,?,?)').run(i,'hero-'+i,1,JSON.stringify({id:'hero-'+i,c_id:1,lv:100}));
}
const before=state(path),snapshot=join(dir,'online-backup.sqlite');await backup(d,snapshot);assert.deepEqual(state(snapshot),before);
const secret=randomBytes(32).toString('hex'),store=new BackupStore(d,{directory:join(dir,'backups'),environment:'SYNTHETIC_RELEASE_TEST'});
const made=await store.create(secret,'migration-test');await store.verify(made.id,secret);
const restored=join(dir,'backups','restored');await dryRunArchive(join(dir,'backups',made.id+'.sahht'),secret,join(dir,'backups'),32,restored);
const copy=join(restored,'database.sqlite');assert.deepEqual(state(copy),before);
openDatabase(copy).close();const after=state(copy);assert.equal(after.schema,32);
for(const [name,row]of Object.entries(before.tables))assert.deepEqual(after.tables[name],row,name);
openDatabase(copy).close();assert.deepEqual(state(copy),after);
assert.throws(()=>legacy.openDatabase(copy),/database|hỗ trợ/);
// Rollback adapter dùng chính module openDatabase32 đã kiểm, không chạy code26 nguyên trên DB32.
openDatabase(copy).close();assert.deepEqual(state(copy),after);assert.deepEqual(state(path),before);d.close();
const report={ok:true,kind:'SYNTHETIC_ONLY_NOT_PRODUCTION',legacyModuleSha256:'e6da778d738860415d723a7e8855744b7cd13bbc0475d975649d00c1f246bde6',from:26,to:32,oldTablesPreserved:Object.keys(before.tables).length,newTables:Object.keys(after.tables).filter(n=>!before.tables[n]),integrity:'ok',foreignKeyViolations:0,onlineBackupVerified:true,encryptedRestoreVerified:true,idempotent:true,originalUntouched:true,rollbackModuleVerified:true};
await writeFile(join(root,'work/unified-release/migration-synthetic.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));
