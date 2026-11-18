export const welfareSchemaVersion = 1;
export function installWelfareSchema(db) {
    if (Number(db.prepare('PRAGMA user_version').get().user_version) !== 39)
        throw new Error('Chỉ áp extension trên baseline schema39 đã kiểm.');
    if (db.prepare("SELECT 1 FROM sqlite_master WHERE name='welfare_schema'").get()) {
        if (db.prepare('SELECT version FROM welfare_schema').get()?.version !== welfareSchemaVersion)
            throw new Error('Phiên bản extension chưa hỗ trợ.');
        return;
    }
    db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE welfare_schema(version INTEGER PRIMARY KEY CHECK(version=1));
    INSERT INTO welfare_schema VALUES(1);
    CREATE TABLE welfare_configs(id INTEGER PRIMARY KEY,kind TEXT NOT NULL CHECK(kind IN('daily','month','quarter')),realm TEXT NOT NULL CHECK(realm='local-1'),revision INTEGER NOT NULL CHECK(revision>0),status TEXT NOT NULL CHECK(status IN('draft','published','ended')),definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL);
    CREATE INDEX welfare_config_window ON welfare_configs(realm,kind,status);
    CREATE TABLE welfare_attendance(user_id INTEGER NOT NULL REFERENCES users(id),realm TEXT NOT NULL,cycle INTEGER NOT NULL CHECK(cycle>0),score INTEGER NOT NULL CHECK(score BETWEEN 1 AND 25),last_day TEXT NOT NULL,snapshot TEXT NOT NULL CHECK(json_valid(snapshot)),PRIMARY KEY(user_id,realm));
    CREATE TABLE welfare_entitlements(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),realm TEXT NOT NULL,kind TEXT NOT NULL CHECK(kind IN('month','quarter')),config_id INTEGER REFERENCES welfare_configs(id),starts INTEGER NOT NULL,ends INTEGER NOT NULL CHECK(ends>starts),snapshot TEXT NOT NULL CHECK(json_valid(snapshot)),revoked_at INTEGER,created_at INTEGER NOT NULL);
    CREATE INDEX welfare_entitlement_player ON welfare_entitlements(user_id,realm,kind,created_at);
    CREATE TABLE welfare_claims(id INTEGER PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),realm TEXT NOT NULL,kind TEXT NOT NULL,scope TEXT NOT NULL,day INTEGER NOT NULL CHECK(day>0),server_day TEXT NOT NULL,rewards TEXT NOT NULL CHECK(json_valid(rewards)),claimed_at INTEGER NOT NULL,UNIQUE(user_id,realm,kind,scope,day));
    CREATE UNIQUE INDEX welfare_card_day ON welfare_claims(user_id,realm,kind,server_day) WHERE kind IN('month','quarter');
    CREATE INDEX welfare_claim_history ON welfare_claims(realm,claimed_at,user_id);
    CREATE TABLE welfare_operations(actor TEXT NOT NULL,request_key TEXT NOT NULL,fingerprint TEXT NOT NULL,result TEXT NOT NULL CHECK(json_valid(result)),created_at INTEGER NOT NULL,PRIMARY KEY(actor,request_key));
    CREATE TABLE welfare_qa_players(user_id INTEGER PRIMARY KEY REFERENCES users(id),clock_offset INTEGER NOT NULL DEFAULT 0 CHECK(clock_offset>=0),updated_at INTEGER NOT NULL);
    COMMIT;`);
}
