export function installPlayerSystems(db) {
    if (db.prepare('PRAGMA user_version').get().user_version !== 39)
        throw Error('Cần schema39 đã kiểm.');
    const existing = db.prepare("SELECT 1 FROM sqlite_master WHERE name='local_player_systems_schema'").get() ? db.prepare('SELECT version FROM local_player_systems_schema LIMIT 1').get() : undefined;
    if (existing) {
        if (existing.version !== 1)
            throw Error('Phiên bản extension LOCAL không được hỗ trợ.');
        return;
    }
    db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE local_player_systems_schema(version INTEGER PRIMARY KEY CHECK(version=1));
    INSERT INTO local_player_systems_schema VALUES(1);
    CREATE TABLE legacy_store_items(user_id INTEGER NOT NULL REFERENCES users(id),config_id INTEGER NOT NULL,quantity INTEGER NOT NULL CHECK(quantity>0),PRIMARY KEY(user_id,config_id));
    CREATE TABLE legacy_store_cards(user_id INTEGER NOT NULL REFERENCES users(id),id TEXT NOT NULL,config_id INTEGER NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),PRIMARY KEY(user_id,id));
    CREATE TABLE legacy_store_equips(user_id INTEGER NOT NULL REFERENCES users(id),id TEXT NOT NULL,config_id INTEGER NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),PRIMARY KEY(user_id,id));
    CREATE TABLE legacy_store_talismans(user_id INTEGER NOT NULL REFERENCES users(id),id TEXT NOT NULL,config_id INTEGER NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),PRIMARY KEY(user_id,id));
    CREATE TABLE legacy_title_owned(user_id INTEGER NOT NULL REFERENCES users(id),title_id INTEGER NOT NULL,expires_at INTEGER NOT NULL CHECK(expires_at=-1 OR expires_at>0),PRIMARY KEY(user_id,title_id));
    CREATE TABLE legacy_public_ids(user_id INTEGER PRIMARY KEY REFERENCES users(id),public_id TEXT NOT NULL UNIQUE CHECK(length(public_id)=10 AND public_id GLOB 'vn[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),revision INTEGER NOT NULL DEFAULT 1,updated_at INTEGER NOT NULL);
    CREATE TABLE legacy_server_realms(id TEXT PRIMARY KEY,name TEXT NOT NULL,kind TEXT NOT NULL CHECK(kind IN('test','official')),status TEXT NOT NULL CHECK(status IN('open','closed')),revision INTEGER NOT NULL DEFAULT 1,created_at INTEGER NOT NULL);
    CREATE TABLE legacy_giftcode_scopes(giftcode_id INTEGER PRIMARY KEY REFERENCES giftcodes(id),scope TEXT NOT NULL CHECK(scope IN('all','test','official')),realm_ids TEXT NOT NULL CHECK(json_valid(realm_ids)),revision INTEGER NOT NULL DEFAULT 1);
    INSERT INTO legacy_server_realms VALUES('local-1','Phòng thử nghiệm cục bộ','test','open',1,strftime('%s','now')*1000);
    COMMIT;`);
}
export function playerSystemsReady(db) { return !!db.prepare("SELECT 1 FROM sqlite_master WHERE name='local_player_systems_schema'").get() && db.prepare('SELECT version FROM local_player_systems_schema LIMIT 1').get()?.version === 1; }
