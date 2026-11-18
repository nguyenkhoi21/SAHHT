import Database from 'libsql';
import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
export const databaseSchemaVersion = 39;
export function openDatabase(path) {
    if (path !== ':memory:')
        mkdirSync(dirname(path), { recursive: true });
    const useTurso = path !== ':memory:' && Boolean(process.env.TURSO_DATABASE_URL && process.env.TURSO_AUTH_TOKEN);
    const db = useTurso
        ? new Database(path, {
            syncUrl: process.env.TURSO_DATABASE_URL,
            authToken: process.env.TURSO_AUTH_TOKEN
        })
        : new Database(path);
    if (useTurso)
        db.sync();
    db.exec('PRAGMA foreign_keys=ON; PRAGMA busy_timeout=3000;');
    if (path !== ':memory:' && !useTurso)
        db.exec('PRAGMA journal_mode=WAL;');
    let version = db.prepare('PRAGMA user_version').get().user_version;
    if (useTurso) {
        db.exec('CREATE TABLE IF NOT EXISTS _schema_meta (id INTEGER PRIMARY KEY CHECK(id=1), version INTEGER NOT NULL);');
        const meta = db.prepare('SELECT version FROM _schema_meta WHERE id=1').get();
        if (meta) {
            version = meta.version;
        }
        else if (version > 0) {
            db.prepare('INSERT OR REPLACE INTO _schema_meta(id, version) VALUES(1, ?)').run(version);
        }
        const origExec = db.exec.bind(db);
        const origPrepare = db.prepare.bind(db);
        db.prepare = (sql) => {
            if (typeof sql === 'string' && /^\s*PRAGMA\s+user_version\s*;?\s*$/i.test(sql)) {
                return {
                    get: () => {
                        const row = origPrepare('SELECT version FROM _schema_meta WHERE id=1').get();
                        return { user_version: row ? Number(row.version) : 0 };
                    },
                    all: () => {
                        const row = origPrepare('SELECT version FROM _schema_meta WHERE id=1').get();
                        return [{ user_version: row ? Number(row.version) : 0 }];
                    },
                    run: () => ({ changes: 0, lastInsertRowid: 0 })
                };
            }
            return origPrepare(sql);
        };
        let txDepth = 0;
        db.exec = (sql) => {
            if (typeof sql === 'string') {
                const trimmed = sql.trim().replace(/;+$/, '');
                if (/^BEGIN(\s+IMMEDIATE|\s+DEFERRED|\s+EXCLUSIVE)?$/i.test(trimmed) || /^SAVEPOINT\s+/i.test(trimmed)) {
                    if (txDepth === 0)
                        origExec('BEGIN IMMEDIATE');
                    txDepth++;
                    return;
                }
                if (/^(COMMIT|END(\s+TRANSACTION)?|RELEASE(\s+SAVEPOINT)?\s+.+)$/i.test(trimmed)) {
                    if (txDepth > 0)
                        txDepth--;
                    if (txDepth === 0)
                        return origExec('COMMIT');
                    return;
                }
                if (/^ROLLBACK(\s+TRANSACTION)?(\s+TO(\s+SAVEPOINT)?\s+.+)?$/i.test(trimmed)) {
                    if (txDepth > 0)
                        txDepth--;
                    if (txDepth === 0)
                        return origExec('ROLLBACK');
                    return;
                }
                if (/PRAGMA\s+user_version\s*=/i.test(sql)) {
                    sql = sql.replace(/PRAGMA\s+user_version\s*=\s*(\d+)\s*;/gi, 'INSERT OR REPLACE INTO _schema_meta(id, version) VALUES(1, $1);');
                }
            }
            return origExec(sql);
        };
    }
    if (version > databaseSchemaVersion) {
        db.close();
        throw new Error('Phiên bản database local chưa hỗ trợ');
    }
    if (version === 0) {
        db.exec(`BEGIN IMMEDIATE;
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
      CREATE TABLE player_profiles (
        user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        game_uid TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL DEFAULT '1',
        created_at INTEGER NOT NULL
      );
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        token_hash TEXT NOT NULL UNIQUE,
        game_token_hash TEXT,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      );
      CREATE INDEX sessions_user ON sessions(user_id);
      PRAGMA user_version=1;
      COMMIT;`);
    }
    if (version < 2) {
        db.exec(`BEGIN IMMEDIATE;
      CREATE TABLE player_state(user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE, profile TEXT NOT NULL, formation TEXT NOT NULL);
      CREATE TABLE player_heroes(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, id TEXT NOT NULL, config_id INTEGER NOT NULL, state TEXT NOT NULL, PRIMARY KEY(user_id,id));
      CREATE TABLE player_equipment(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, id TEXT NOT NULL, config_id INTEGER NOT NULL, state TEXT NOT NULL, PRIMARY KEY(user_id,id));
      CREATE TABLE player_items(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, config_id INTEGER NOT NULL, quantity INTEGER NOT NULL CHECK(quantity>=0), PRIMARY KEY(user_id,config_id));
      PRAGMA user_version=2;
      COMMIT;`);
    }
    if (version < 3)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_mail(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,id TEXT NOT NULL,content TEXT NOT NULL,read_at INTEGER,PRIMARY KEY(user_id,id));
    INSERT INTO player_mail SELECT user_id,'local-welcome','Chào mừng đến máy chủ thử nghiệm cục bộ.\nDữ liệu này chỉ dùng để kiểm thử local, không liên quan tài khoản dịch vụ chính thức.',NULL FROM player_state;
    PRAGMA user_version=3;
    COMMIT;`);
    if (version < 4)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_shop(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,shop_id TEXT NOT NULL,bought INTEGER NOT NULL CHECK(bought>=0),PRIMARY KEY(user_id,shop_id));
    PRAGMA user_version=4;
    COMMIT;`);
    if (version < 5)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_gacha(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,gacha_id TEXT NOT NULL,draws INTEGER NOT NULL CHECK(draws>=0),PRIMARY KEY(user_id,gacha_id));
    PRAGMA user_version=5;
    COMMIT;`);
    if (version < 6)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE admin_users(id INTEGER PRIMARY KEY,username TEXT NOT NULL UNIQUE COLLATE NOCASE,password_hash TEXT NOT NULL,role TEXT NOT NULL CHECK(role IN ('OWNER','ADMIN','VIEWER')),created_at INTEGER NOT NULL,last_login_at INTEGER);
    CREATE TABLE admin_sessions(id INTEGER PRIMARY KEY,admin_id INTEGER NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,token_hash TEXT NOT NULL UNIQUE,created_at INTEGER NOT NULL,expires_at INTEGER NOT NULL);
    CREATE INDEX admin_sessions_expiry ON admin_sessions(expires_at);
    CREATE TABLE admin_audit(id INTEGER PRIMARY KEY,admin_id INTEGER REFERENCES admin_users(id),action TEXT NOT NULL,target_user_id INTEGER REFERENCES users(id),created_at INTEGER NOT NULL,summary TEXT NOT NULL,before_state TEXT,after_state TEXT);
    CREATE INDEX admin_audit_target_time ON admin_audit(target_user_id,created_at);
    PRAGMA user_version=6;
    COMMIT;`);
    if (version < 7)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_claims(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,system TEXT NOT NULL,period TEXT NOT NULL,claim_key TEXT NOT NULL,claimed_at INTEGER NOT NULL,PRIMARY KEY(user_id,system,period,claim_key));
    PRAGMA user_version=7;
    COMMIT;`);
    if (version < 8)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE local_activity_settings(activity_id TEXT PRIMARY KEY,enabled INTEGER NOT NULL CHECK(enabled IN (0,1)),starts_at INTEGER NOT NULL,ends_at INTEGER NOT NULL,CHECK(ends_at>starts_at));
    INSERT INTO local_activity_settings VALUES('10',0,0,1);
    PRAGMA user_version=8;
    COMMIT;`);
    if (version < 9)
        db.exec(`BEGIN IMMEDIATE;
    ALTER TABLE player_mail ADD COLUMN attachments TEXT NOT NULL DEFAULT '[]';
    PRAGMA user_version=9;
    COMMIT;`);
    if (version < 10)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_hero_archive(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,id TEXT NOT NULL,config_id INTEGER NOT NULL,state TEXT NOT NULL,archived_at INTEGER NOT NULL,PRIMARY KEY(user_id,id));
    PRAGMA user_version=10;
    COMMIT;`);
    if (version < 11)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_hero_qa_backup(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,id TEXT NOT NULL,state TEXT NOT NULL,created_at INTEGER NOT NULL,PRIMARY KEY(user_id,id));
    PRAGMA user_version=11;
    COMMIT;`);
    if (version < 12)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_map_access(user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,state TEXT NOT NULL);
    PRAGMA user_version=12;
    COMMIT;`);
    if (version < 13)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE giftcodes(
      id INTEGER PRIMARY KEY,code TEXT NOT NULL UNIQUE COLLATE NOCASE,campaign TEXT NOT NULL,description TEXT NOT NULL,
      rewards TEXT NOT NULL,starts_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,
      total_limit INTEGER NOT NULL CHECK(total_limit BETWEEN 1 AND 1000000),per_account_limit INTEGER NOT NULL CHECK(per_account_limit BETWEEN 1 AND 10),
      min_level INTEGER NOT NULL CHECK(min_level BETWEEN 1 AND 250),min_vip INTEGER NOT NULL CHECK(min_vip BETWEEN 0 AND 15),
      enabled INTEGER NOT NULL CHECK(enabled IN(0,1)),created_by INTEGER NOT NULL REFERENCES admin_users(id),created_at INTEGER NOT NULL,
      CHECK(expires_at>starts_at));
    CREATE TABLE giftcode_redemptions(
      id INTEGER PRIMARY KEY,giftcode_id INTEGER NOT NULL REFERENCES giftcodes(id),user_id INTEGER NOT NULL REFERENCES users(id),
      request_id TEXT NOT NULL,ordinal INTEGER NOT NULL,redeemed_at INTEGER NOT NULL,mail_id TEXT NOT NULL,
      reward_snapshot TEXT NOT NULL,UNIQUE(user_id,request_id),UNIQUE(giftcode_id,user_id,ordinal),
      FOREIGN KEY(user_id,mail_id) REFERENCES player_mail(user_id,id));
    CREATE INDEX giftcode_usage ON giftcode_redemptions(giftcode_id,user_id);
    PRAGMA user_version=13;
    COMMIT;`);
    if (version < 14)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_stage_steps(user_id INTEGER NOT NULL REFERENCES users(id),city TEXT NOT NULL,building TEXT NOT NULL,step INTEGER NOT NULL,first_battle TEXT NOT NULL,completed_at INTEGER NOT NULL,PRIMARY KEY(user_id,city,building,step));
    CREATE TABLE local_battles(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),request_key TEXT NOT NULL,city TEXT NOT NULL,building TEXT NOT NULL,step INTEGER NOT NULL,seed INTEGER NOT NULL,result TEXT NOT NULL,packet TEXT NOT NULL,created_at INTEGER NOT NULL,UNIQUE(user_id,request_key));
    CREATE TABLE map_completion_snapshots(id INTEGER PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),before_state TEXT,applied_state TEXT NOT NULL,created_at INTEGER NOT NULL,restored_at INTEGER);
    CREATE UNIQUE INDEX map_active_snapshot ON map_completion_snapshots(user_id) WHERE restored_at IS NULL;
    PRAGMA user_version=14;COMMIT;`);
    if (version < 15)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE arena_players(user_id INTEGER PRIMARY KEY REFERENCES users(id),rating INTEGER NOT NULL DEFAULT 1000 CHECK(rating>=0),points INTEGER NOT NULL DEFAULT 0 CHECK(points>=0),wins INTEGER NOT NULL DEFAULT 0,losses INTEGER NOT NULL DEFAULT 0);
    CREATE TABLE arena_days(user_id INTEGER NOT NULL REFERENCES users(id),day TEXT NOT NULL,used INTEGER NOT NULL DEFAULT 0 CHECK(used>=0),purchased INTEGER NOT NULL DEFAULT 0 CHECK(purchased>=0),PRIMARY KEY(user_id,day));
    CREATE TABLE arena_operations(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),request_key TEXT NOT NULL,kind TEXT NOT NULL CHECK(kind IN('battle','purchase')),target_user_id INTEGER REFERENCES users(id),day TEXT NOT NULL,state TEXT NOT NULL CHECK(state IN('SETTLED')),packet TEXT NOT NULL,metadata TEXT NOT NULL,created_at INTEGER NOT NULL,UNIQUE(user_id,request_key));
    CREATE INDEX arena_history ON arena_operations(user_id,created_at);
    PRAGMA user_version=15;COMMIT;`);
    if (version < 16) {
        // Giữ nguyên ID/receipt/reward đã phát hành; chỉ mở rộng giới hạn cấu trúc VIP.
        // Domain vẫn giới hạn theo config VIP thực tế đang được xác minh.
        db.exec('PRAGMA foreign_keys=OFF;');
        try {
            db.exec(`BEGIN IMMEDIATE;
        CREATE TABLE giftcodes_v16(
          id INTEGER PRIMARY KEY,code TEXT NOT NULL UNIQUE COLLATE NOCASE,campaign TEXT NOT NULL,description TEXT NOT NULL,
          rewards TEXT NOT NULL,starts_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,
          total_limit INTEGER NOT NULL CHECK(total_limit BETWEEN 1 AND 1000000),per_account_limit INTEGER NOT NULL CHECK(per_account_limit BETWEEN 1 AND 10),
          min_level INTEGER NOT NULL CHECK(min_level BETWEEN 1 AND 250),min_vip INTEGER NOT NULL CHECK(min_vip BETWEEN 0 AND 17),
          enabled INTEGER NOT NULL CHECK(enabled IN(0,1)),created_by INTEGER NOT NULL REFERENCES admin_users(id),created_at INTEGER NOT NULL,CHECK(expires_at>starts_at));
        INSERT INTO giftcodes_v16 SELECT * FROM giftcodes;
        DROP TABLE giftcodes;
        ALTER TABLE giftcodes_v16 RENAME TO giftcodes;`);
            if (db.prepare('PRAGMA foreign_key_check').all().length)
                throw new Error('Migration VIP phát hiện liên kết dữ liệu không hợp lệ.');
            db.exec('PRAGMA user_version=16; COMMIT;');
        }
        catch (error) {
            if (db.isTransaction)
                db.exec('ROLLBACK');
            db.close();
            throw error;
        }
        finally {
            if (db.isOpen)
                db.exec('PRAGMA foreign_keys=ON;');
        }
    }
    if (version < 17)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS player_fate_gems(user_id INTEGER NOT NULL REFERENCES users(id),config_id INTEGER NOT NULL,quantity INTEGER NOT NULL CHECK(quantity>=0),PRIMARY KEY(user_id,config_id));
    CREATE TABLE IF NOT EXISTS player_content_operations(user_id INTEGER NOT NULL REFERENCES users(id),request_key TEXT NOT NULL,method TEXT NOT NULL,fingerprint TEXT NOT NULL,result TEXT NOT NULL,created_at INTEGER NOT NULL,PRIMARY KEY(user_id,request_key));
    PRAGMA user_version=17;COMMIT;`);
    if (version < 18)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS auth_password_attempts(user_id INTEGER NOT NULL REFERENCES users(id),created_at INTEGER NOT NULL,success INTEGER NOT NULL CHECK(success IN(0,1)));
    CREATE INDEX IF NOT EXISTS auth_password_rate ON auth_password_attempts(user_id,created_at);
    CREATE TABLE IF NOT EXISTS local_vip_store_settings(product_id TEXT PRIMARY KEY,enabled INTEGER NOT NULL CHECK(enabled IN(0,1)),price INTEGER NOT NULL CHECK(price BETWEEN 1 AND 100000000),quota INTEGER NOT NULL CHECK(quota BETWEEN 1 AND 9999));
    PRAGMA user_version=18;COMMIT;`);
    if (version < 19)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS auth_remembered(id INTEGER PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),token_hash TEXT NOT NULL UNIQUE,family TEXT NOT NULL,created_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,used_at INTEGER,revoked_at INTEGER);
    CREATE INDEX IF NOT EXISTS auth_remembered_user ON auth_remembered(user_id);
    CREATE TABLE IF NOT EXISTS auth_remembered_sessions(session_id INTEGER PRIMARY KEY REFERENCES sessions(id) ON DELETE CASCADE,family TEXT NOT NULL);
    PRAGMA user_version=19;COMMIT;`);
    if (version < 20)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS player_skins(user_id INTEGER NOT NULL REFERENCES users(id),skin_id INTEGER NOT NULL,attribute TEXT NOT NULL,equipped INTEGER NOT NULL DEFAULT 0 CHECK(equipped IN(0,1)),created_at INTEGER NOT NULL,PRIMARY KEY(user_id,skin_id));
    CREATE TABLE IF NOT EXISTS player_transformations(user_id INTEGER NOT NULL REFERENCES users(id),hero_id TEXT NOT NULL,source_id INTEGER NOT NULL,target_id INTEGER NOT NULL,before_state TEXT NOT NULL,after_state TEXT NOT NULL,created_at INTEGER NOT NULL,restored INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(user_id,hero_id,source_id));
    PRAGMA user_version=20;COMMIT;`);
    if (version < 21)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS player_fate_special(user_id INTEGER NOT NULL REFERENCES users(id),id TEXT NOT NULL,c_id INTEGER NOT NULL,state TEXT NOT NULL,PRIMARY KEY(user_id,id));
    CREATE TABLE IF NOT EXISTS player_fate_materials(user_id INTEGER NOT NULL REFERENCES users(id),kind TEXT NOT NULL CHECK(kind IN('word','stone')),config_id INTEGER NOT NULL,quantity INTEGER NOT NULL CHECK(quantity>=0),PRIMARY KEY(user_id,kind,config_id));
    CREATE TABLE IF NOT EXISTS player_fate_pity(user_id INTEGER NOT NULL REFERENCES users(id),word_id INTEGER NOT NULL,rounds INTEGER NOT NULL CHECK(rounds>=0),PRIMARY KEY(user_id,word_id));
    PRAGMA user_version=21;COMMIT;`);
    if (version < 22)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS player_auxiliary(user_id INTEGER NOT NULL REFERENCES users(id),kind TEXT NOT NULL CHECK(kind IN('talisman','gem','soul','god_stone','medal','material')),id TEXT NOT NULL,config_id INTEGER NOT NULL,state TEXT NOT NULL,PRIMARY KEY(user_id,kind,id));
    PRAGMA user_version=22;COMMIT;`);
    if (version < 23)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE IF NOT EXISTS arena_positions(user_id INTEGER PRIMARY KEY REFERENCES users(id),rank INTEGER NOT NULL UNIQUE CHECK(rank>0));
    WITH existing AS MATERIALIZED (SELECT COALESCE(MAX(rank),0) last FROM arena_positions) INSERT INTO arena_positions SELECT p.user_id,existing.last+ROW_NUMBER() OVER (ORDER BY COALESCE(a.rating,1000) DESC,p.user_id) FROM player_profiles p JOIN player_state s ON s.user_id=p.user_id LEFT JOIN arena_players a ON a.user_id=p.user_id CROSS JOIN existing WHERE NOT EXISTS(SELECT 1 FROM arena_positions old WHERE old.user_id=p.user_id);
    CREATE TABLE IF NOT EXISTS friend_requests(id TEXT PRIMARY KEY,sender_id INTEGER NOT NULL REFERENCES users(id),recipient_id INTEGER NOT NULL REFERENCES users(id),status TEXT NOT NULL CHECK(status IN('PENDING','ACCEPTED','REJECTED','CANCELLED')),created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL,CHECK(sender_id<>recipient_id));
    CREATE UNIQUE INDEX IF NOT EXISTS friend_request_pending ON friend_requests(MIN(sender_id,recipient_id),MAX(sender_id,recipient_id)) WHERE status='PENDING';
    CREATE INDEX IF NOT EXISTS friend_request_inbox ON friend_requests(recipient_id,status,created_at);
    CREATE TABLE IF NOT EXISTS friendships(low_id INTEGER NOT NULL REFERENCES users(id),high_id INTEGER NOT NULL REFERENCES users(id),created_at INTEGER NOT NULL,CHECK(low_id<high_id),PRIMARY KEY(low_id,high_id));
    PRAGMA user_version=23;COMMIT;`);
    if (version < 24)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE godfield_formations(user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,state TEXT NOT NULL CHECK(json_valid(state)),revision INTEGER NOT NULL DEFAULT 1,updated_at INTEGER NOT NULL);
    PRAGMA user_version=24;COMMIT;`);
    if (version < 25)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE godfield_mode_state(user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,mode TEXT NOT NULL,period TEXT NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),updated_at INTEGER NOT NULL,PRIMARY KEY(user_id,mode,period));
    CREATE TABLE godfield_competition_groups(period TEXT NOT NULL,group_id INTEGER NOT NULL,members TEXT NOT NULL CHECK(json_valid(members)),created_at INTEGER NOT NULL,PRIMARY KEY(period,group_id));
    CREATE TABLE godfield_matches(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),target_user_id INTEGER NOT NULL REFERENCES users(id),mode TEXT NOT NULL,period TEXT NOT NULL,request_key TEXT NOT NULL,packet TEXT NOT NULL,metadata TEXT NOT NULL,created_at INTEGER NOT NULL,UNIQUE(user_id,request_key),CHECK(user_id<>target_user_id));
    CREATE INDEX godfield_match_history ON godfield_matches(user_id,mode,created_at);
    PRAGMA user_version=25;COMMIT;`);
    if (version < 26)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE godfield_zodiac_positions(day TEXT NOT NULL,floor INTEGER NOT NULL CHECK(floor BETWEEN 1 AND 12),pos INTEGER NOT NULL CHECK(pos BETWEEN 1 AND 60),user_id INTEGER NOT NULL REFERENCES users(id),team INTEGER NOT NULL CHECK(team BETWEEN 1 AND 3),occupied_at INTEGER NOT NULL,paid_at INTEGER NOT NULL,wins INTEGER NOT NULL DEFAULT 0 CHECK(wins>=0),PRIMARY KEY(day,floor,pos),UNIQUE(day,user_id,team));
    CREATE TABLE godfield_zodiac_battles(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),target_user_id INTEGER REFERENCES users(id),day TEXT NOT NULL,floor INTEGER NOT NULL,pos INTEGER NOT NULL,team INTEGER NOT NULL,request_key TEXT NOT NULL,packet TEXT NOT NULL,metadata TEXT NOT NULL,created_at INTEGER NOT NULL,UNIQUE(user_id,request_key));
    CREATE INDEX godfield_zodiac_history ON godfield_zodiac_battles(user_id,created_at);
    PRAGMA user_version=26;COMMIT;`);
    if (version < 27)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE alliances(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL UNIQUE COLLATE NOCASE,icon TEXT NOT NULL,level INTEGER NOT NULL CHECK(level>=1),notice TEXT NOT NULL DEFAULT '',goods INTEGER NOT NULL DEFAULT 0 CHECK(goods>=0),war_flag INTEGER NOT NULL DEFAULT 0 CHECK(war_flag>=0),created_at INTEGER NOT NULL,closed_at INTEGER);
    CREATE TABLE alliance_members(user_id INTEGER PRIMARY KEY REFERENCES users(id),alliance_id INTEGER NOT NULL REFERENCES alliances(id),role TEXT NOT NULL CHECK(role IN('owner','vp','member')),dedication INTEGER NOT NULL DEFAULT 0 CHECK(dedication>=0),joined_at INTEGER NOT NULL);
    CREATE UNIQUE INDEX alliance_owner ON alliance_members(alliance_id) WHERE role='owner';
    CREATE INDEX alliance_member_directory ON alliance_members(alliance_id,user_id);
    CREATE TABLE alliance_applications(alliance_id INTEGER NOT NULL REFERENCES alliances(id),user_id INTEGER NOT NULL REFERENCES users(id),created_at INTEGER NOT NULL,PRIMARY KEY(alliance_id,user_id));
    CREATE TABLE alliance_cooldowns(user_id INTEGER PRIMARY KEY REFERENCES users(id),until_at INTEGER NOT NULL);
    PRAGMA user_version=27;COMMIT;`);
    if (version < 28)
        db.exec(`BEGIN IMMEDIATE;
    ALTER TABLE alliances ADD COLUMN shop_level INTEGER NOT NULL DEFAULT 0 CHECK(shop_level>=0);
    CREATE TABLE alliance_donation_days(user_id INTEGER NOT NULL REFERENCES users(id),day TEXT NOT NULL,goods INTEGER NOT NULL DEFAULT 0 CHECK(goods>=0),war_flags INTEGER NOT NULL DEFAULT 0 CHECK(war_flags>=0),PRIMARY KEY(user_id,day));
    PRAGMA user_version=28;COMMIT;`);
    if (version < 29)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE alliance_purchases(user_id INTEGER NOT NULL REFERENCES users(id),offer_id INTEGER NOT NULL,period TEXT NOT NULL,quantity INTEGER NOT NULL CHECK(quantity>0),PRIMARY KEY(user_id,offer_id,period));
    CREATE TABLE alliance_messages(id INTEGER PRIMARY KEY AUTOINCREMENT,alliance_id INTEGER NOT NULL REFERENCES alliances(id),user_id INTEGER NOT NULL REFERENCES users(id),body TEXT NOT NULL,created_at INTEGER NOT NULL);
    CREATE INDEX alliance_message_history ON alliance_messages(alliance_id,id);
    CREATE TABLE player_homeland(user_id INTEGER PRIMARY KEY REFERENCES users(id),state TEXT NOT NULL CHECK(json_valid(state)),updated_at INTEGER NOT NULL);
    CREATE TABLE player_beasts(user_id INTEGER NOT NULL REFERENCES users(id),beast_id INTEGER NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),PRIMARY KEY(user_id,beast_id));
    CREATE TABLE player_beast_formation(user_id INTEGER PRIMARY KEY REFERENCES users(id),state TEXT NOT NULL CHECK(json_valid(state)));
    PRAGMA user_version=29;COMMIT;`);
    if (version < 30)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE aether_events(id TEXT PRIMARY KEY,realm_id TEXT NOT NULL,version INTEGER NOT NULL,start_at INTEGER NOT NULL,end_at INTEGER NOT NULL,qa INTEGER NOT NULL DEFAULT 0 CHECK(qa IN(0,1)),qa_time INTEGER,qa_updated INTEGER,managed INTEGER NOT NULL DEFAULT 0 CHECK(managed IN(0,1)),qa_active INTEGER NOT NULL DEFAULT 1 CHECK(qa_active IN(0,1)),CHECK(end_at>start_at));
    CREATE UNIQUE INDEX aether_normal_season ON aether_events(realm_id,start_at) WHERE qa=0;
    CREATE TABLE aether_guilds(event_id TEXT NOT NULL REFERENCES aether_events(id),guild_id INTEGER NOT NULL REFERENCES alliances(id),group_id INTEGER NOT NULL CHECK(group_id>0),slot INTEGER NOT NULL CHECK(slot BETWEEN 1 AND 12),science_level INTEGER NOT NULL DEFAULT 0,science_exp INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(event_id,guild_id),UNIQUE(event_id,group_id,slot));
    CREATE TABLE aether_mercenaries(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),guild_id INTEGER NOT NULL REFERENCES alliances(id),origin_guild INTEGER NOT NULL REFERENCES alliances(id),status TEXT NOT NULL CHECK(status IN('pending','active','left','refused')),updated_at INTEGER NOT NULL,PRIMARY KEY(event_id,user_id,guild_id));
    CREATE UNIQUE INDEX aether_one_employer ON aether_mercenaries(event_id,user_id) WHERE status='active';
    CREATE TABLE aether_formations(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),state TEXT NOT NULL CHECK(json_valid(state)),updated_at INTEGER NOT NULL,PRIMARY KEY(event_id,user_id));
    CREATE TABLE aether_deployments(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),team INTEGER NOT NULL CHECK(team BETWEEN 1 AND 3),city_id INTEGER NOT NULL,kind TEXT NOT NULL CHECK(kind IN('attack','defend','resource','explore')),block_id INTEGER NOT NULL DEFAULT 0,priority INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(event_id,user_id,team));
    CREATE TABLE aether_cities(event_id TEXT NOT NULL REFERENCES aether_events(id),group_id INTEGER NOT NULL,city_id INTEGER NOT NULL,owner_id INTEGER REFERENCES alliances(id),attacker_id INTEGER REFERENCES alliances(id),PRIMARY KEY(event_id,group_id,city_id));
    CREATE TABLE aether_battles(id TEXT PRIMARY KEY,event_id TEXT NOT NULL REFERENCES aether_events(id),group_id INTEGER NOT NULL,city_id INTEGER NOT NULL,packet TEXT NOT NULL CHECK(json_valid(packet)),metadata TEXT NOT NULL CHECK(json_valid(metadata)),created_at INTEGER NOT NULL);
    CREATE TABLE aether_wars(id TEXT PRIMARY KEY,event_id TEXT NOT NULL REFERENCES aether_events(id),group_id INTEGER NOT NULL,city_id INTEGER NOT NULL,day TEXT NOT NULL,status TEXT NOT NULL CHECK(status IN('ready','running','done','blocked')),state TEXT NOT NULL CHECK(json_valid(state)),error TEXT,created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL,UNIQUE(event_id,group_id,city_id,day));
    CREATE TABLE aether_scores(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),blood INTEGER NOT NULL DEFAULT 0 CHECK(blood>=0),reached_order INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(event_id,user_id));
    CREATE TABLE aether_streaks(event_id TEXT NOT NULL REFERENCES aether_events(id),group_id INTEGER NOT NULL,city_id INTEGER NOT NULL,day TEXT NOT NULL,user_id INTEGER NOT NULL REFERENCES users(id),team INTEGER NOT NULL,wins INTEGER NOT NULL DEFAULT 0 CHECK(wins>=0),total INTEGER NOT NULL DEFAULT 0 CHECK(total>=0),closed INTEGER NOT NULL DEFAULT 0 CHECK(closed IN(0,1)),PRIMARY KEY(event_id,group_id,city_id,day,user_id,team));
    CREATE TABLE aether_score_awards(battle_id TEXT PRIMARY KEY REFERENCES aether_battles(id),event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),group_id INTEGER NOT NULL,city_id INTEGER NOT NULL,day TEXT NOT NULL,team INTEGER NOT NULL,wins INTEGER NOT NULL,total INTEGER NOT NULL,delta INTEGER NOT NULL,created_at INTEGER NOT NULL);
    CREATE TABLE aether_claims(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),kind TEXT NOT NULL,claim_key TEXT NOT NULL,reward TEXT NOT NULL CHECK(json_valid(reward)),created_at INTEGER NOT NULL,PRIMARY KEY(event_id,user_id,kind,claim_key));
    CREATE TABLE aether_purchases(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),offer_id INTEGER NOT NULL,period TEXT NOT NULL,quantity INTEGER NOT NULL CHECK(quantity>0),PRIMARY KEY(event_id,user_id,offer_id,period));
    CREATE TABLE aether_items(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL REFERENCES users(id),config_id INTEGER NOT NULL,quantity INTEGER NOT NULL CHECK(quantity>=0),PRIMARY KEY(event_id,user_id,config_id));
    CREATE TABLE aether_admin_operations(admin_id INTEGER NOT NULL REFERENCES admin_users(id),request_key TEXT NOT NULL,fingerprint TEXT NOT NULL,result TEXT NOT NULL,PRIMARY KEY(admin_id,request_key));
    PRAGMA user_version=30;COMMIT;`);
    if (version < 31)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE aether_sim_state(event_id TEXT NOT NULL REFERENCES aether_events(id),user_id INTEGER NOT NULL CHECK(user_id>=0),kind TEXT NOT NULL,scope TEXT NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),updated_at INTEGER NOT NULL,PRIMARY KEY(event_id,user_id,kind,scope));
    PRAGMA user_version=31;COMMIT;`);
    if (version < 32)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE player_pets(user_id INTEGER NOT NULL REFERENCES users(id),id TEXT NOT NULL,config_id INTEGER NOT NULL,state TEXT NOT NULL CHECK(json_valid(state)),PRIMARY KEY(user_id,id));
    CREATE TABLE player_pet_formation(user_id INTEGER PRIMARY KEY REFERENCES users(id),state TEXT NOT NULL CHECK(json_valid(state)));
    PRAGMA user_version=32;COMMIT;`);
    if (version < 33)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE hot_campaigns(id INTEGER PRIMARY KEY AUTOINCREMENT,source_key TEXT UNIQUE,revision INTEGER NOT NULL DEFAULT 1,status TEXT NOT NULL CHECK(status IN('draft','published','disabled')),definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL);
    CREATE TABLE hot_recharges(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),realm TEXT NOT NULL,request_key TEXT NOT NULL,package_id INTEGER NOT NULL,method TEXT NOT NULL CHECK(method IN('sandbox','voucher')),price INTEGER NOT NULL,base_coin INTEGER NOT NULL,bonus_coin INTEGER NOT NULL,vip_exp INTEGER NOT NULL,event_amount INTEGER NOT NULL,tickets INTEGER NOT NULL,metadata TEXT NOT NULL CHECK(json_valid(metadata)),created_at INTEGER NOT NULL,UNIQUE(user_id,request_key));
    CREATE TABLE hot_claims(user_id INTEGER NOT NULL REFERENCES users(id),campaign TEXT NOT NULL,row_key TEXT NOT NULL,period TEXT NOT NULL,ordinal INTEGER NOT NULL,reward TEXT NOT NULL CHECK(json_valid(reward)),created_at INTEGER NOT NULL,PRIMARY KEY(user_id,campaign,row_key,period,ordinal));
    CREATE TABLE hot_admin_operations(admin_id INTEGER NOT NULL REFERENCES admin_users(id),request_key TEXT NOT NULL,fingerprint TEXT NOT NULL,result TEXT NOT NULL CHECK(json_valid(result)),PRIMARY KEY(admin_id,request_key));
    CREATE TABLE hot_card_settings(package_id INTEGER PRIMARY KEY CHECK(package_id IN(1,2)),revision INTEGER NOT NULL DEFAULT 1,definition TEXT NOT NULL CHECK(json_valid(definition)));
    CREATE TABLE hot_card_contracts(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),package_id INTEGER NOT NULL,starts_at INTEGER NOT NULL,ends_at INTEGER NOT NULL,definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL);
    CREATE INDEX hot_card_account ON hot_card_contracts(user_id,package_id,ends_at);
    CREATE TABLE hot_card_deliveries(contract_id TEXT NOT NULL REFERENCES hot_card_contracts(id),day INTEGER NOT NULL,mail_id TEXT NOT NULL,created_at INTEGER NOT NULL,PRIMARY KEY(contract_id,day));
    CREATE TABLE hot_spend_context(user_id INTEGER PRIMARY KEY REFERENCES users(id),kind TEXT NOT NULL,request_key TEXT NOT NULL,created_at INTEGER NOT NULL);
    CREATE TABLE hot_spending(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL REFERENCES users(id),realm TEXT NOT NULL DEFAULT 'local-1',kind TEXT NOT NULL,request_key TEXT NOT NULL,amount INTEGER NOT NULL CHECK(amount>0),created_at INTEGER NOT NULL);
    CREATE INDEX hot_recharge_window ON hot_recharges(user_id,realm,created_at);
    CREATE INDEX hot_spending_window ON hot_spending(user_id,realm,created_at);
    CREATE TRIGGER hot_coin_spending AFTER UPDATE OF profile ON player_state
    WHEN json_extract(OLD.profile,'$.coin')>json_extract(NEW.profile,'$.coin') AND EXISTS(SELECT 1 FROM hot_spend_context WHERE user_id=NEW.user_id)
    BEGIN INSERT INTO hot_spending(user_id,kind,request_key,amount,created_at) SELECT NEW.user_id,kind,request_key,CAST(json_extract(OLD.profile,'$.coin')-json_extract(NEW.profile,'$.coin') AS INTEGER),created_at FROM hot_spend_context WHERE user_id=NEW.user_id; END;
    PRAGMA user_version=33;COMMIT;`);
    if (version < 34)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE newstar_reward_configs(id INTEGER PRIMARY KEY AUTOINCREMENT,revision INTEGER NOT NULL DEFAULT 1,status TEXT NOT NULL CHECK(status IN('draft','published')),definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL,published_at INTEGER);
    CREATE TABLE newstar_reward_snapshots(user_id INTEGER PRIMARY KEY REFERENCES users(id),config_id INTEGER REFERENCES newstar_reward_configs(id),definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL);
    CREATE TABLE admin_reward_templates(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,revision INTEGER NOT NULL DEFAULT 1,rewards TEXT NOT NULL CHECK(json_valid(rewards)),updated_at INTEGER NOT NULL);
    PRAGMA user_version=34;COMMIT;`);
    if (version < 35)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE newstar_server_scope(id INTEGER PRIMARY KEY CHECK(id=1),server_from INTEGER NOT NULL CHECK(server_from>=1),server_to INTEGER NOT NULL CHECK(server_to>=server_from),updated_at INTEGER NOT NULL);
    PRAGMA user_version=35;COMMIT;`);
    if (version < 36)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE event_calendar_settings(id INTEGER PRIMARY KEY CHECK(id=1),opened_at INTEGER NOT NULL,updated_at INTEGER NOT NULL);
    CREATE TABLE event_calendar_rules(id INTEGER PRIMARY KEY AUTOINCREMENT,revision INTEGER NOT NULL DEFAULT 1,status TEXT NOT NULL CHECK(status IN('draft','published','disabled')),name TEXT NOT NULL,target TEXT NOT NULL,definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL,published_at INTEGER);
    CREATE INDEX event_calendar_target ON event_calendar_rules(target,status);
    CREATE TABLE sky_star_runs(user_id INTEGER NOT NULL REFERENCES users(id),occurrence_id TEXT NOT NULL,rules TEXT NOT NULL CHECK(json_valid(rules)),steps INTEGER NOT NULL DEFAULT 0 CHECK(steps BETWEEN 0 AND 7),created_at INTEGER NOT NULL,PRIMARY KEY(user_id,occurrence_id));
    CREATE TABLE sky_star_draws(user_id INTEGER NOT NULL REFERENCES users(id),request_id TEXT NOT NULL,fingerprint TEXT NOT NULL,occurrence_id TEXT NOT NULL,step INTEGER NOT NULL,cost INTEGER NOT NULL,reward INTEGER NOT NULL,result TEXT NOT NULL CHECK(json_valid(result)),created_at INTEGER NOT NULL,PRIMARY KEY(user_id,request_id),UNIQUE(user_id,occurrence_id,step));
    PRAGMA user_version=36;COMMIT;`);
    if (version < 37)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE treasure_event_configs(id INTEGER PRIMARY KEY AUTOINCREMENT,kind TEXT NOT NULL CHECK(kind IN('treasure','labyrinth','pantheon')),name TEXT NOT NULL,status TEXT NOT NULL CHECK(status IN('draft','published','disabled')),revision INTEGER NOT NULL DEFAULT 1,definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL);
    CREATE TABLE treasure_event_runs(user_id INTEGER NOT NULL REFERENCES users(id),occurrence_id TEXT NOT NULL,kind TEXT NOT NULL,config_id INTEGER NOT NULL REFERENCES treasure_event_configs(id),snapshot TEXT NOT NULL CHECK(json_valid(snapshot)),state TEXT NOT NULL CHECK(json_valid(state)),revision INTEGER NOT NULL DEFAULT 0,updated_at INTEGER NOT NULL,PRIMARY KEY(user_id,occurrence_id,kind));
    CREATE TABLE treasure_event_receipts(user_id INTEGER NOT NULL REFERENCES users(id),request_id TEXT NOT NULL,fingerprint TEXT NOT NULL,occurrence_id TEXT NOT NULL,kind TEXT NOT NULL,action TEXT NOT NULL,result TEXT NOT NULL CHECK(json_valid(result)),created_at INTEGER NOT NULL,PRIMARY KEY(user_id,request_id));
    CREATE INDEX treasure_event_history ON treasure_event_receipts(kind,created_at);
    PRAGMA user_version=37;COMMIT;`);
    if (version < 38)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE client_presentation_settings(id INTEGER PRIMARY KEY CHECK(id=1),revision INTEGER NOT NULL,definition TEXT NOT NULL CHECK(json_valid(definition)),updated_at INTEGER NOT NULL);
    CREATE TABLE invite_codes(user_id INTEGER PRIMARY KEY REFERENCES users(id),code TEXT NOT NULL UNIQUE COLLATE NOCASE CHECK(length(code)=6 AND code NOT GLOB '*[^A-Z0-9]*' AND code GLOB '*[A-Z]*' AND code GLOB '*[0-9]*'),created_at INTEGER NOT NULL);
    CREATE TABLE invite_bindings(invitee_id INTEGER PRIMARY KEY REFERENCES users(id),inviter_id INTEGER NOT NULL REFERENCES users(id),device_hash TEXT NOT NULL UNIQUE,created_at INTEGER NOT NULL,CHECK(invitee_id<>inviter_id));
    CREATE INDEX invite_members ON invite_bindings(inviter_id);
    CREATE TABLE invite_reward_mails(recipient_id INTEGER NOT NULL REFERENCES users(id),invitee_id INTEGER NOT NULL REFERENCES users(id),reward_key TEXT NOT NULL,mail_id TEXT NOT NULL,rewards TEXT NOT NULL CHECK(json_valid(rewards)),created_at INTEGER NOT NULL,PRIMARY KEY(recipient_id,invitee_id,reward_key));
    PRAGMA user_version=38;COMMIT;`);
    if (version < 39)
        db.exec(`BEGIN IMMEDIATE;
    CREATE TABLE restored_event_configs(id INTEGER PRIMARY KEY AUTOINCREMENT,kind TEXT NOT NULL CHECK(kind IN('investment','dispatch')),name TEXT NOT NULL,status TEXT NOT NULL CHECK(status IN('draft','published')),revision INTEGER NOT NULL DEFAULT 1,definition TEXT NOT NULL CHECK(json_valid(definition)),created_at INTEGER NOT NULL);
    CREATE TABLE restored_event_runs(user_id INTEGER NOT NULL REFERENCES users(id),occurrence_id TEXT NOT NULL,kind TEXT NOT NULL,config_id INTEGER NOT NULL REFERENCES restored_event_configs(id),snapshot TEXT NOT NULL CHECK(json_valid(snapshot)),state TEXT NOT NULL CHECK(json_valid(state)),revision INTEGER NOT NULL DEFAULT 0,updated_at INTEGER NOT NULL,PRIMARY KEY(user_id,occurrence_id,kind));
    CREATE TABLE restored_event_ops(user_id INTEGER NOT NULL REFERENCES users(id),request_id TEXT NOT NULL,fingerprint TEXT NOT NULL,occurrence_id TEXT NOT NULL,kind TEXT NOT NULL,action TEXT NOT NULL,result TEXT NOT NULL CHECK(json_valid(result)),created_at INTEGER NOT NULL,PRIMARY KEY(user_id,request_id));
    CREATE INDEX restored_event_history ON restored_event_ops(kind,created_at);
    CREATE TABLE player_notice_seen(user_id INTEGER NOT NULL REFERENCES users(id),kind TEXT NOT NULL,entity_id TEXT NOT NULL,quantity INTEGER NOT NULL DEFAULT 1,PRIMARY KEY(user_id,kind,entity_id));
    CREATE TABLE local_notice_settings(id INTEGER PRIMARY KEY CHECK(id=1),revision INTEGER NOT NULL,definition TEXT NOT NULL CHECK(json_valid(definition)));
    INSERT INTO player_notice_seen SELECT user_id,'hero',id,1 FROM player_heroes;
    INSERT INTO player_notice_seen SELECT user_id,'equipment',id,1 FROM player_equipment;
    INSERT INTO player_notice_seen SELECT user_id,'item',CAST(config_id AS TEXT),quantity FROM player_items;
    PRAGMA user_version=39;COMMIT;`);
    return db;
}
