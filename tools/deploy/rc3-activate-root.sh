#!/usr/bin/env bash
# Dùng một lần qua SSH root tương tác. Không đổi SSH/firewall/quyền sudo.
set -euo pipefail
test "$(id -u)" = 0
release=/opt/sahht/releases/release-20261028-phase30-rc3
old=$(readlink -f /opt/sahht/current)
test "$old" = /opt/sahht/releases/release-20261028-giftcode-resources
test -f "$release/release-manifest.json"
umask 077
audit=/var/backups/sahht/rc3-20261028
test ! -e "$audit"
install -d -m 700 -o sahht -g sahht "$audit"
export RC3_AUDIT_DIRECTORY="$audit" RC3_PREVIOUS_RELEASE="$old"
set -a
source /etc/sahht/online.env
set +a
test "$ACCOUNT_DB_PATH" = /var/lib/sahht/online.db
test "$BACKUP_DIRECTORY" = /var/backups/sahht
# Đóng băng bộ kiểm đã review trong vùng root; không chạy script uploads có thể đổi giữa chừng.
install -m 644 /home/sahht-deploy/uploads/rc3-data-check.mjs "$audit/data-check.mjs"
install -m 644 /home/sahht-deploy/uploads/rc3-backup-recipient.pem "$audit/backup-recipient.pem"
service_stopped=0
trap 'code=$?; if (( code != 0 )); then printf "RC3 FAILED exit=%s; giữ nguyên snapshot, không restore DB tự động.\n" "$code"; if (( service_stopped == 1 )); then echo "Dịch vụ đang dừng để bảo vệ dữ liệu; cần đọc báo cáo trước khi xử lý."; fi; fi' EXIT
systemctl is-active --quiet sahht.service
df -Pk /var/backups/sahht | awk 'NR==2{if($4<2097152)exit 1}'
cd "$release"
runuser -u sahht --preserve-environment -- node "$audit/data-check.mjs" prepare
exports=/home/sahht-deploy/rc3-private-export
install -d -m 700 -o sahht-deploy -g sahht-deploy "$exports"
python3 - "$audit" "$exports" <<'PY'
import json,sys,shutil,os,pwd
audit,dest=sys.argv[1:];p=json.load(open(audit+'/prepared.json'))
assert p['ok'] and p['migration']['idempotent']
uid=pwd.getpwnam('sahht-deploy').pw_uid
for src,name in [(p['backup']['archive'],p['backup']['id']+'.sahht'),(audit+'/prepared.json','prepared.json'),(audit+'/backup-key-escrow.json','backup-key-escrow.json')]:
    out=dest+'/'+name
    with open(out,'xb') as f,open(src,'rb') as r:shutil.copyfileobj(r,f)
    os.chmod(out,0o600);os.chown(out,uid,uid)
PY
echo 'RC3_PREPARED: backup/restore/migration cô lập đạt. Chờ Codex tải bản mã hoá về máy và xác minh checksum.'
deadline=$((SECONDS+1200))
while ! test -f "$exports/offserver-verified.sha256"; do
 if (( SECONDS >= deadline )); then echo 'Chưa có bản off-server xác minh; KHÔNG đổi live.'; exit 1; fi
 sleep 2
done
python3 - "$audit" "$exports" <<'PY'
import json,sys
p=json.load(open(sys.argv[1]+'/prepared.json'))
assert open(sys.argv[2]+'/offserver-verified.sha256').read().strip()==p['backup']['sha256']
PY
# Dừng ghi ngắn; backup nhất quán mới, rồi migration kiểm chính xác mọi bảng cũ trước start.
systemctl stop sahht-backup.timer
while systemctl is-active --quiet sahht-backup.service; do sleep 1; done
systemctl stop sahht.service
service_stopped=1
runuser -u sahht --preserve-environment -- node "$audit/data-check.mjs" migrate-live
printf '%s\n' "$old" > /opt/sahht/previous-release
chmod -R a+rX "$release"
ln -sfn "$release" /opt/sahht/next
mv -Tf /opt/sahht/next /opt/sahht/current
systemctl start sahht.service
service_stopped=0
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
python3 - "$audit" "$exports" <<'PY'
import json,sys,shutil,os,pwd
audit,dest=sys.argv[1:];uid=pwd.getpwnam('sahht-deploy').pw_uid
for name in ['migration.json','post.json','health.json']:
    out=dest+'/'+name;shutil.copyfile(audit+'/'+name,out);os.chmod(out,0o600);os.chown(out,uid,uid)
for name in ['migration','post']:
    p=json.load(open(audit+'/'+name+'.json'));b=p['backup'];out=dest+'/'+b['id']+'.sahht'
    with open(out,'xb') as f,open(b['archive'],'rb') as r:shutil.copyfileobj(r,f)
    os.chmod(out,0o600);os.chown(out,uid,uid)
PY
echo 'RC3_DEPLOYED: migration23 giữ nguyên dữ liệu cũ, backend/Admin đã cập nhật, backup sau triển khai đã kiểm.'
