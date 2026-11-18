#!/usr/bin/env bash
# Chủ máy nhập root qua SSH tương tác. Không đổi SSH/firewall/cấu hình dịch vụ.
set -euo pipefail
test "$(id -u)" = 0
release=/opt/sahht/releases/release-20261029-than-vuc-v11
old=/opt/sahht/releases/release-20261028-phase31-v10
rollback=/opt/sahht/releases/release-20261029-v10-schema26-rollback
test "$(readlink -f /opt/sahht/current)" = "$old"
test -f "$release/release-manifest.json"
umask 077
audit=/var/backups/sahht/than-vuc-v11-20261029
test ! -e "$audit"
install -d -m 700 -o sahht -g sahht "$audit"
export PHASE35_AUDIT_DIRECTORY="$audit" PHASE35_PREVIOUS_RELEASE="$old" PHASE35_ROLLBACK_RELEASE="$rollback"
set -a; source /etc/sahht/online.env; set +a
test "$APP_ENV" = online
test "$ACCOUNT_DB_PATH" = /var/lib/sahht/online.db
test "$BACKUP_DIRECTORY" = /var/backups/sahht
export LOCAL_HIGHWAY_PLAY=0
systemctl is-active --quiet sahht.service
df -Pk /var/backups/sahht | awk 'NR==2{if($4<3145728)exit 1}'
# Bản cấu hình và code phục hồi chỉ root đọc, nằm ngoài release/public.
tar -czf "$audit/production-config-root-only.tar.gz" /etc/sahht /etc/nginx /etc/systemd/system/sahht* 2>"$audit/config-tar.log"
tar -tzf "$audit/production-config-root-only.tar.gz" > "$audit/config-files.txt"
tar -czf "$audit/previous-release.tar.gz" -C /opt/sahht/releases "$(basename "$old")"
tar -tzf "$audit/previous-release.tar.gz" > "$audit/previous-files.txt"
sha256sum "$audit/production-config-root-only.tar.gz" "$audit/previous-release.tar.gz" > "$audit/recovery-checksums.txt"
# v10 cũ chặn DB>23. Adapter rollback chỉ thay module migration additive,
# giữ code/Admin v10 và toàn bộ DB26, không hạ schema hoặc restore dữ liệu cũ.
test ! -e "$rollback"
cp -a "$old" "$rollback"
install -m 644 "$release/server/dist/db/database.js" "$rollback/server/dist/db/database.js"
python3 - "$rollback" "$release" <<'PY'
import hashlib,json,sys
from pathlib import Path
r=Path(sys.argv[1]);m=json.loads((r/'release-manifest.json').read_text());new=json.loads((Path(sys.argv[2])/'release-manifest.json').read_text())
m.update(release=r.name,schemaVersion=26,rollbackCompatibilitySource=new['sourceCommit'],previousSourceCommit=m['sourceCommit'])
m['files']['server/dist/db/database.js']=hashlib.sha256((r/'server/dist/db/database.js').read_bytes()).hexdigest()
(r/'release-manifest.json').write_text(json.dumps(m,indent=2))
PY
chmod -R a+rX "$rollback"
cd "$release"
runuser -u sahht --preserve-environment -- node tools/deploy/phase35-data-check.mjs prepare
echo 'BACKUP_RESTORE_MIGRATION_ROLLBACK_VERIFIED: schema23→26, dữ liệu cũ nguyên.'
stopped=0
trap 'code=$?; if ((code!=0)); then echo "PHASE35_FAILED: giữ backup/log, không tự restore DB."; if ((stopped==1)); then echo "Dịch vụ đang dừng: cần đọc báo cáo trước bước tiếp."; fi; fi' EXIT
systemctl stop sahht-backup.timer
while systemctl is-active --quiet sahht-backup.service; do sleep 1; done
systemctl stop sahht.service; stopped=1
runuser -u sahht --preserve-environment -- node tools/deploy/phase35-data-check.mjs migrate-live
printf '%s\n' "$rollback" > /opt/sahht/previous-release
chmod -R a+rX "$release"
ln -sfn "$release" /opt/sahht/next
mv -Tf /opt/sahht/next /opt/sahht/current
systemctl start sahht.service; stopped=0
for attempt in $(seq 1 20); do
 if curl --fail --silent https://45.76.177.247/health > "$audit/health.json"; then break; fi
 sleep 1
done
python3 - "$audit/health.json" <<'PY'
import json,sys
h=json.load(open(sys.argv[1]));assert h['ok'] and h['scope']=='online'
PY
runuser -u sahht --preserve-environment -- node tools/deploy/phase35-data-check.mjs post
systemctl start sahht-backup.timer
systemctl is-active sahht.service nginx sahht-backup.timer sahht-cert-renew.timer
apk=/home/sahht-deploy/uploads/SAHHT-ONLINE-v11.apk.part
test -f "$apk" && ! test -L "$apk"
echo 'c89140d7361562addc2b249e45d4d71ceea263cd9ee3e6fff042c8cd38057f70  '"$apk" | sha256sum -c -
downloads=/opt/sahht/releases/online-downloads
test ! -e "$downloads/SAHHT-ONLINE-v11.apk"
install -m 644 "$apk" "$downloads/SAHHT-ONLINE-v11.apk.partial"
mv -T "$downloads/SAHHT-ONLINE-v11.apk.partial" "$downloads/SAHHT-ONLINE-v11.apk"
exports=/home/sahht-deploy/than-vuc-v11-private-reports
install -d -m 700 -o sahht-deploy -g sahht-deploy "$exports"
python3 - "$audit" "$exports" <<'PY'
import os,pwd,shutil,sys
uid=pwd.getpwnam('sahht-deploy').pw_uid
for name in ['prepared.json','quiesced-baseline.json','migration.json','post.json','health.json']:
 out=sys.argv[2]+'/'+name
 with open(out,'xb') as dst,open(sys.argv[1]+'/'+name,'rb') as src:shutil.copyfileobj(src,dst)
 os.chmod(out,0o600);os.chown(out,uid,uid)
PY
echo 'PHASE35_DEPLOYED: backend/Admin ONLINEv11, schema26 và dữ liệu cũ giữ nguyên; backup/restore/rollback đạt.'
