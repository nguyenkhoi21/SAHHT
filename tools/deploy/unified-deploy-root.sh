#!/usr/bin/env bash
# Chủ VPS chạy qua SSH root tương tác; không nhận/lưu mật khẩu trong script.
set -euo pipefail
test "$(id -u)" = 0
export UNIFIED_RELEASE=release-20261101-unified-v12
release=/opt/sahht/releases/$UNIFIED_RELEASE
export UNIFIED_PREVIOUS_RELEASE=/opt/sahht/releases/release-20261029-than-vuc-v11
export UNIFIED_ROLLBACK_RELEASE=$release-rollback
old=$UNIFIED_PREVIOUS_RELEASE
rollback=$UNIFIED_ROLLBACK_RELEASE
audit=/var/backups/sahht/$UNIFIED_RELEASE
test "$(readlink -f /opt/sahht/current)" = "$old"
test -f "$release/release-manifest.json"
test ! -e "$audit" && test ! -e "$rollback"
umask 077
install -d -m 700 -o sahht -g sahht "$audit"
set -a; source /etc/sahht/online.env; set +a
test "$APP_ENV" = online
test "$ACCOUNT_DB_PATH" = /var/lib/sahht/online.db
test "$BACKUP_DIRECTORY" = /var/backups/sahht
df -Pk /var/backups/sahht | awk 'NR==2{if($4<6291456)exit 1}'
systemctl is-active --quiet sahht.service
systemctl is-enabled --quiet sahht.service
# Lưu code/cấu hình và uploads ngoài release. SQLite chỉ dùng Online Backup API ở bước Node.
tar -czf "$audit/config-root-only.tar.gz" /etc/sahht /etc/nginx /etc/systemd/system/sahht* 2>"$audit/config-tar.log"
tar -czf "$audit/previous-release.tar.gz" -C /opt/sahht/releases "$(basename "$old")"
tar -czf "$audit/persistent-files.tar.gz" --exclude=online.db --exclude=online.db-wal --exclude=online.db-shm /var/lib/sahht /opt/sahht/shared 2>"$audit/persistent-tar.log"
for archive in "$audit"/*.tar.gz; do tar -tzf "$archive" >/dev/null; done
sha256sum "$audit"/*.tar.gz > "$audit/recovery-checksums.txt"
# Rollback code v11 mở được schema32, giữ dữ liệu mới; không hạ DB hoặc restore snapshot cũ.
cp -a "$old" "$rollback"
install -m 644 "$release/server/dist/db/database.js" "$rollback/server/dist/db/database.js"
python3 - "$rollback" "$release" <<'PY'
import hashlib,json,sys
from pathlib import Path
p=Path(sys.argv[1]);m=json.loads((p/'release-manifest.json').read_text());new=json.loads((Path(sys.argv[2])/'release-manifest.json').read_text())
m.update(release=p.name,schemaVersion=32,rollbackCompatibilitySource=new['sourceCommit'])
m['files']['server/dist/db/database.js']=hashlib.sha256((p/'server/dist/db/database.js').read_bytes()).hexdigest()
(p/'release-manifest.json').write_text(json.dumps(m,indent=2))
PY
cd "$release"
runuser -u sahht --preserve-environment -- node tools/deploy/unified-data-check.mjs prepare
echo 'BACKUP_RESTORE_MIGRATION_ROLLBACK_MODULE_VERIFIED'
stopped=0
switched=0
recover(){
 code=$?
 if ((code!=0)); then
  echo 'UNIFIED_FAILED: giữ DB/backup/log; không tự restore DB cũ.'
  if ((switched==1)); then
   ln -sfn "$rollback" /opt/sahht/next
   mv -Tf /opt/sahht/next /opt/sahht/current
   systemctl restart sahht.service || true
   echo 'Đã chuyển về code rollback tương thích schema32; cần kiểm health.'
  elif ((stopped==1)); then
   # Kể cả migration chỉ hoàn thành một phần additive, adapter32 xử lý tiếp idempotent.
   ln -sfn "$rollback" /opt/sahht/next
   mv -Tf /opt/sahht/next /opt/sahht/current
   systemctl start sahht.service || true
  fi
  systemctl start sahht-backup.timer || true
 fi
}
trap recover EXIT
systemctl stop sahht-backup.timer
while systemctl is-active --quiet sahht-backup.service; do sleep 1; done
systemctl stop sahht.service; stopped=1
# Upload/config không còn ghi trong thời gian quiesce, lưu snapshot cuối nhất.
tar -czf "$audit/persistent-quiesced.tar.gz" --exclude=online.db --exclude=online.db-wal --exclude=online.db-shm /var/lib/sahht /opt/sahht/shared 2>"$audit/persistent-quiesced.log"
tar -tzf "$audit/persistent-quiesced.tar.gz" >/dev/null
sha256sum "$audit/persistent-quiesced.tar.gz" >> "$audit/recovery-checksums.txt"
runuser -u sahht --preserve-environment -- node tools/deploy/unified-data-check.mjs migrate-live
python3 - /etc/sahht/online.env "$UNIFIED_RELEASE" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]);lines=p.read_text().splitlines();keys={'ONLINE_UNIFIED_RELEASE':'1','RELEASE_ID':sys.argv[2]}
lines=[x for x in lines if x.split('=',1)[0] not in keys]
p.write_text('\n'.join(lines+[k+'='+v for k,v in keys.items()])+'\n')
PY
printf '%s\n' "$rollback" > /opt/sahht/previous-release
chmod -R a+rX "$release" "$rollback"
ln -sfn "$release" /opt/sahht/next
mv -Tf /opt/sahht/next /opt/sahht/current
switched=1
systemctl start sahht.service; stopped=0
for attempt in $(seq 1 25); do
 if curl --fail --silent https://45.76.177.247/health > "$audit/health.json"; then break; fi
 sleep 1
done
python3 - "$audit/health.json" "$UNIFIED_RELEASE" <<'PY'
import json,sys
h=json.load(open(sys.argv[1]));assert h['ok'] and h['scope']=='online' and h['schema']==32 and h['protocol']=='sahht-unified-v12' and h['release']==sys.argv[2]
PY
curl -fsS https://45.76.177.247/admin/ > "$audit/admin.html"
runuser -u sahht --preserve-environment -- node tools/deploy/unified-data-check.mjs post
systemctl start sahht-backup.timer
systemctl is-active sahht.service nginx sahht-backup.timer sahht-cert-renew.timer
systemctl is-enabled sahht.service nginx sahht-backup.timer sahht-cert-renew.timer
exports=/home/sahht-deploy/unified-v12-private-reports
install -d -m 700 -o sahht-deploy -g sahht-deploy "$exports"
for name in prepared quiesced-baseline migration post health; do install -m 600 -o sahht-deploy -g sahht-deploy "$audit/$name.json" "$exports/$name.json"; done
echo 'UNIFIED_BACKEND_DEPLOYED: schema32; tiếp public/API/device gates trước chấp nhận release.'
