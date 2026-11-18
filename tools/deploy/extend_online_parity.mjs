// CLI release có chủ đích, chạy sau backup; không gọi từ API startup.
import {DatabaseSync} from 'node:sqlite';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const [runtime,database]=process.argv.slice(2);
if(!runtime||!database)throw Error('Cần runtime và DB đích đã backup.');
const root=resolve(runtime),db=new DatabaseSync(resolve(database));
const load=name=>import(pathToFileURL(resolve(root,'server/dist',name)).href);
function snapshot(){
 const rows=db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all();
 return Object.fromEntries(rows.map(({name})=>{const table='"'+String(name).replaceAll('"','""')+'"';return [String(name),createHash('sha256').update(JSON.stringify(db.prepare('SELECT * FROM '+table+' ORDER BY rowid').all())).digest('hex')];}));
}
try{
 db.exec('PRAGMA foreign_keys=ON;PRAGMA busy_timeout=10000;');
 assert.equal(db.prepare('PRAGMA user_version').get().user_version,39);
 assert.equal(db.prepare('PRAGMA integrity_check').get().integrity_check,'ok');assert.deepEqual(db.prepare('PRAGMA foreign_key_check').all(),[]);
 const before=snapshot();
 (await load('welfare/welfare-migration.js')).installWelfareSchema(db);
 (await load('recharge/recharge-settings.js')).installRechargeSettings(db);
 (await load('player-systems/player-systems-migration.js')).installPlayerSystems(db);
 const after=snapshot();for(const [table,hash]of Object.entries(before))assert.equal(after[table],hash,'Dữ liệu cũ đổi: '+table);
 assert.equal(db.prepare('PRAGMA user_version').get().user_version,39);
 assert.equal(db.prepare('PRAGMA integrity_check').get().integrity_check,'ok');assert.deepEqual(db.prepare('PRAGMA foreign_key_check').all(),[]);
 console.log(JSON.stringify({ok:true,existingTablesPreserved:Object.keys(before).length,addedTables:Object.keys(after).filter(k=>!(k in before)),schema:39,integrity:'ok',foreignKeyViolations:0}));
}finally{db.close();}
