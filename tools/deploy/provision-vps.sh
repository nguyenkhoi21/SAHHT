#!/usr/bin/env bash
# Chạy bởi root qua phiên SSH tương tác đã xác minh, không chứa mật khẩu.
set -euo pipefail
test "$(id -u)" = 0 || { echo 'Cần root cho bước cấu hình hệ thống.'; exit 1; }
IP=45.76.177.247
test "$(. /etc/os-release; echo "$ID")" = ubuntu
echo 'Kiểm trước cài đặt:'; df -h /; ss -ltn
if ss -ltnH | awk '{print $4}' | grep -Eq ':(80|443|8787)$'; then echo 'Cổng dự kiến đang được dùng. Chưa thay dịch vụ.'; exit 1; fi
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx ufw curl ca-certificates xz-utils python3-venv sqlite3 logrotate
install -d -m 755 /opt/sahht/releases /opt/sahht/shared /usr/local/lib/sahht
id sahht >/dev/null 2>&1 || useradd --system --home-dir /var/lib/sahht --shell /usr/sbin/nologin sahht
install -d -m 750 -o sahht -g sahht /var/lib/sahht /var/log/sahht
install -d -m 700 -o sahht -g sahht /var/backups/sahht
install -d -m 750 -o root -g sahht /etc/sahht
chown sahht-deploy:sahht-deploy /opt/sahht/releases
install -d -m 700 -o sahht-deploy -g sahht-deploy /home/sahht-deploy/uploads
# Node24 có node:sqlite/Argon2; kiểm checksum từ endpoint TLS chính thức.
node_stage=$(mktemp -d); trap 'rm -rf -- "$node_stage"' EXIT
arch=$(dpkg --print-architecture); case "$arch" in amd64) node_arch=x64;;arm64) node_arch=arm64;;*) echo 'CPU chưa hỗ trợ';exit 1;;esac
curl --fail --proto '=https' --tlsv1.2 https://nodejs.org/dist/latest-v24.x/SHASUMS256.txt -o "$node_stage/SHASUMS256.txt"
node_file=$(awk -v a="linux-$node_arch.tar.xz" '$2 ~ a"$" {print $2}' "$node_stage/SHASUMS256.txt")
test -n "$node_file" && test "$(printf '%s\n' "$node_file" | wc -l)" -eq 1
curl --fail --proto '=https' --tlsv1.2 "https://nodejs.org/dist/latest-v24.x/$node_file" -o "$node_stage/$node_file"
(cd "$node_stage"; grep " $node_file$" SHASUMS256.txt | sha256sum -c -)
install -d -m 755 /opt/sahht/node
tar -xJf "$node_stage/$node_file" --strip-components=1 -C /opt/sahht/node
ln -sfn /opt/sahht/node/bin/node /usr/local/bin/node
ln -sfn /opt/sahht/node/bin/npm /usr/local/bin/npm
/usr/local/bin/node --version
if ! test -f /etc/sahht/backup.key; then umask 077; head -c 48 /dev/urandom | base64 > /etc/sahht/backup.key; chown root:sahht /etc/sahht/backup.key; chmod 440 /etc/sahht/backup.key; fi
if ! test -f /etc/sahht/online.env; then
 cat > /etc/sahht/online.env <<EOF
APP_ENV=online
PUBLIC_API_ORIGIN=https://$IP
ACCOUNT_DB_PATH=/var/lib/sahht/online.db
BACKUP_DIRECTORY=/var/backups/sahht
BACKUP_KEY_FILE=/etc/sahht/backup.key
JOURNAL_PATH=/var/log/sahht/requests.jsonl
PORT=8787
ALLOW_SYNTHETIC_AUTH=0
ADMIN_DEV=0
EOF
 chmod 640 /etc/sahht/online.env; chown root:sahht /etc/sahht/online.env
fi
cat > /etc/systemd/system/sahht.service <<'EOF'
[Unit]
Description=SAHHT ONLINE
After=network.target
[Service]
User=sahht
Group=sahht
WorkingDirectory=/opt/sahht/current/server
EnvironmentFile=/etc/sahht/online.env
ExecStart=/usr/local/bin/node dist/index.js
Restart=on-failure
RestartSec=5
UMask=0077
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/lib/sahht /var/log/sahht /var/backups/sahht
MemoryMax=12G
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
cat > /etc/systemd/system/sahht-backup.service <<'EOF'
[Unit]
Description=SAHHT encrypted daily backup
After=sahht.service
[Service]
Type=oneshot
User=sahht
Group=sahht
WorkingDirectory=/opt/sahht/current/server
EnvironmentFile=/etc/sahht/online.env
ExecStart=/usr/local/bin/node dist/system/backup-cli.js daily
UMask=0077
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/backups/sahht
EOF
cat > /etc/systemd/system/sahht-backup.timer <<'EOF'
[Unit]
Description=SAHHT backup every day UTC+7
[Timer]
OnCalendar=*-*-* 20:15:00 UTC
RandomizedDelaySec=120
Persistent=true
[Install]
WantedBy=timers.target
EOF
cat > /etc/logrotate.d/sahht <<'EOF'
/var/log/sahht/*.jsonl {
 daily
 rotate 14
 maxsize 50M
 missingok
 notifempty
 compress
 delaycompress
 copytruncate
 su sahht sahht
}
EOF
cat > /usr/local/sbin/sahht-activate-release <<'EOF'
#!/bin/bash
set -euo pipefail
id=${1:-}; [[ "$id" =~ ^release-[0-9]{8}-[a-zA-Z0-9-]{1,40}$ ]] || exit 2
target=/opt/sahht/releases/$id
test -d "$target" && ! test -L "$target" && test -f "$target/server/dist/index.js"
if test -L /opt/sahht/current; then
 old=$(readlink -f /opt/sahht/current)
 runuser -u sahht -- env $(grep -v '^#' /etc/sahht/online.env | xargs) /usr/local/bin/node "$old/server/dist/system/backup-cli.js" pre-release
 printf '%s\n' "$old" > /opt/sahht/previous-release
fi
chmod -R a+rX "$target"
ln -sfn "$target" /opt/sahht/next
mv -Tf /opt/sahht/next /opt/sahht/current
systemctl restart sahht.service
systemctl enable sahht.service sahht-backup.timer
systemctl start sahht-backup.timer
EOF
chmod 755 /usr/local/sbin/sahht-activate-release
cat > /etc/sudoers.d/sahht-deploy <<'EOF'
sahht-deploy ALL=(root) NOPASSWD: /usr/local/sbin/sahht-activate-release *, /usr/bin/systemctl restart sahht.service, /usr/bin/systemctl start sahht-backup.service
EOF
chmod 440 /etc/sudoers.d/sahht-deploy; visudo -cf /etc/sudoers.d/sahht-deploy
install -d -m 755 /var/www/sahht-acme/.well-known/acme-challenge
cat > /etc/nginx/sites-available/sahht <<EOF
limit_req_zone \$binary_remote_addr zone=sahht_auth:10m rate=10r/m;
log_format sahht_safe '\$remote_addr \$request_method \$uri \$status \$request_time';
server {
 listen 80;
 server_name $IP;
 access_log /var/log/nginx/sahht-access.log sahht_safe;
 location /.well-known/acme-challenge/ { root /var/www/sahht-acme; }
 location / { return 404; }
}
EOF
ln -sfn /etc/nginx/sites-available/sahht /etc/nginx/sites-enabled/sahht
nginx -t; systemctl enable --now nginx; systemctl reload nginx
# Không đổi cấu hình SSH; luôn cho phép cổng SSH hiện có trước khi bật UFW.
ssh_ports=$(sshd -T | awk '$1=="port"{print $2}')
for p in $ssh_ports; do ufw allow "$p/tcp" comment 'Existing SSH access'; done
ufw allow 80/tcp; ufw allow 443/tcp
ufw --force enable
python3 -m venv /opt/sahht/certbot
/opt/sahht/certbot/bin/pip install --disable-pip-version-check 'certbot>=5.4,<6'
/opt/sahht/certbot/bin/certbot --version
systemctl daemon-reload
echo 'Đã chuẩn bị hệ thống; chưa có dữ liệu LOCAL trên ONLINE. SSH root giữ nguyên.'
