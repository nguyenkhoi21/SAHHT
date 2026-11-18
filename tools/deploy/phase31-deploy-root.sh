#!/usr/bin/env bash
# Root nhập qua SSH tương tác. Không đổi SSH/firewall/quyền sudo/TLS.
set -euo pipefail
test "$(id -u)" = 0
release=/opt/sahht/releases/release-20261028-phase31-v10
old=/opt/sahht/releases/release-20261028-phase30-rc3
test "$(readlink -f /opt/sahht/current)" = "$old"
test -f "$release/release-manifest.json"
umask 077
audit=/var/backups/sahht/phase31-v10-20261028
test ! -e "$audit"
install -d -m 700 -o sahht -g sahht "$audit"
export PHASE31_AUDIT_DIRECTORY="$audit"
set -a; source /etc/sahht/online.env; set +a
test "$ACCOUNT_DB_PATH" = /var/lib/sahht/online.db
test "$BACKUP_DIRECTORY" = /var/backups/sahht
install -m 644 "$release/tools/deploy/phase31-data-check.mjs" "$audit/data-check.mjs"
systemctl is-active --quiet sahht.service
df -Pk /var/backups/sahht | awk 'NR==2{if($4<2097152)exit 1}'
stopped=0
trap 'code=$?; if ((code!=0)); then echo "PHASE31_FAILED: giữ backup/log; không tự restore DB."; if ((stopped==1)); then echo "Dịch vụ đang dừng; cần đọc báo cáo trước bước tiếp."; fi; fi' EXIT
cd "$release"
runuser -u sahht --preserve-environment -- node "$audit/data-check.mjs" prepare
echo 'BACKUP_AND_RESTORE_VERIFIED: schema23→23, không migration.'
systemctl stop sahht-backup.timer
while systemctl is-active --quiet sahht-backup.service; do sleep 1; done
systemctl stop sahht.service; stopped=1
runuser -u sahht --preserve-environment -- node "$audit/data-check.mjs" quiesced
printf '%s\n' "$old" > /opt/sahht/previous-release
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
runuser -u sahht --preserve-environment -- node "$audit/data-check.mjs" post
systemctl start sahht-backup.timer
systemctl is-active sahht.service nginx sahht-backup.timer sahht-cert-renew.timer
apk=/home/sahht-deploy/uploads/SAHHT-ONLINE-v10.apk.part
downloads=/opt/sahht/releases/online-downloads
test -f "$apk" && ! test -L "$apk"
test ! -e "$downloads/SAHHT-ONLINE-v10.apk"
echo '5142552d35e41bb498707653369a46202ca5ec9dafe95545268edb373441a3f8  '"$apk" | sha256sum -c -
install -m 644 "$apk" "$downloads/SAHHT-ONLINE-v10.apk.partial"
mv -T "$downloads/SAHHT-ONLINE-v10.apk.partial" "$downloads/SAHHT-ONLINE-v10.apk"
exports=/home/sahht-deploy/phase31-private-reports
install -d -m 700 -o sahht-deploy -g sahht-deploy "$exports"
python3 - "$audit" "$exports" <<'PY'
import os,pwd,shutil,sys
uid=pwd.getpwnam('sahht-deploy').pw_uid
for name in ['prepared.json','quiesced.json','post.json','health.json']:
    out=sys.argv[2]+'/'+name
    with open(out,'xb') as dst,open(sys.argv[1]+'/'+name,'rb') as src:shutil.copyfileobj(src,dst)
    os.chmod(out,0o600);os.chown(out,uid,uid)
PY
echo 'PHASE31_DEPLOYED: backend/Admin mới, dữ liệu schema23 được giữ; backup/restore trước và sau đạt.'
