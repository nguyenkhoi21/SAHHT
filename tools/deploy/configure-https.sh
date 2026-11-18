#!/bin/bash
# Chỉ root, SSH tương tác. Không đổi SSH, không chép DB LOCAL.
set -euo pipefail
test "$(id -u)" = 0
IP=45.76.177.247
/opt/sahht/certbot/bin/certbot --version
/opt/sahht/certbot/bin/certbot certonly --non-interactive --agree-tos --register-unsafely-without-email --preferred-profile shortlived --webroot --webroot-path /var/www/sahht-acme --ip-address "$IP"
CERT=/etc/letsencrypt/live/$IP
test -s "$CERT/fullchain.pem" && test -s "$CERT/privkey.pem"
cat > /etc/nginx/sites-available/sahht <<'EOF'
limit_req_zone $binary_remote_addr zone=sahht_auth:10m rate=10r/m;
limit_req_zone $binary_remote_addr zone=sahht_api:10m rate=15r/s;
log_format sahht_safe '$remote_addr $request_method $uri $status $request_time';
server {
 listen 80;
 server_name 45.76.177.247;
 access_log /var/log/nginx/sahht-access.log sahht_safe;
 location /.well-known/acme-challenge/ { root /var/www/sahht-acme; }
 location / { return 308 https://45.76.177.247$request_uri; }
}
server {
 listen 443 ssl;
 server_name 45.76.177.247;
 ssl_certificate /etc/letsencrypt/live/45.76.177.247/fullchain.pem;
 ssl_certificate_key /etc/letsencrypt/live/45.76.177.247/privkey.pem;
 ssl_protocols TLSv1.2 TLSv1.3;
 ssl_session_cache shared:SAHHT_TLS:10m;
 ssl_session_tickets off;
 server_tokens off;
 access_log /var/log/nginx/sahht-access.log sahht_safe;
 # Không ghi query token vào error log/access log.
 error_log /var/log/nginx/sahht-error.log crit;
 client_max_body_size 64k;
 client_body_timeout 15s;
 send_timeout 60s;
 add_header Strict-Transport-Security "max-age=31536000" always;
 add_header X-Content-Type-Options nosniff always;
 location ~ ^/(?:debug|local-content|backups|data|\.git|\.env)(?:/|$) { return 404; }
 location ~ ^/(?:local-auth/(?:login|register|refresh|change-password)|admin/api/login|admin/api/backups/reauth)$ {
  limit_req zone=sahht_auth burst=10 nodelay;
  limit_req_status 429;
  include /etc/nginx/sahht-proxy.conf;
 }
 location / {
  limit_req zone=sahht_api burst=60 nodelay;
  limit_req_status 429;
  include /etc/nginx/sahht-proxy.conf;
 }
}
EOF
cat > /etc/nginx/sahht-proxy.conf <<'EOF'
proxy_pass http://127.0.0.1:8787;
proxy_http_version 1.1;
proxy_set_header Host 45.76.177.247;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $remote_addr;
proxy_set_header X-Forwarded-Proto https;
proxy_set_header Connection "";
proxy_connect_timeout 5s;
proxy_read_timeout 300s;
proxy_send_timeout 30s;
proxy_buffering off;
EOF
install -d -m 755 /etc/letsencrypt/renewal-hooks/deploy
printf '#!/bin/sh\n/usr/sbin/nginx -t && /usr/bin/systemctl reload nginx\n' > /etc/letsencrypt/renewal-hooks/deploy/sahht-nginx
chmod 755 /etc/letsencrypt/renewal-hooks/deploy/sahht-nginx
cat > /etc/systemd/system/sahht-cert-renew.service <<'EOF'
[Unit]
Description=SAHHT short-lived IP certificate renewal
[Service]
Type=oneshot
ExecStart=/opt/sahht/certbot/bin/certbot renew --quiet
EOF
cat > /etc/systemd/system/sahht-cert-renew.timer <<'EOF'
[Unit]
Description=Check SAHHT short-lived TLS every 4 hours
[Timer]
OnCalendar=*-*-* 00/4:20:00
RandomizedDelaySec=300
Persistent=true
[Install]
WantedBy=timers.target
EOF
cat > /usr/local/sbin/sahht-create-admin <<'EOF'
#!/bin/bash
set -euo pipefail
test -t 0 || exit 2
set -a
source /etc/sahht/online.env
set +a
cd /opt/sahht/current/server
exec runuser -u sahht --preserve-environment -- /usr/local/bin/node dist/admin/create-admin.js
EOF
chmod 755 /usr/local/sbin/sahht-create-admin
printf 'sahht-deploy ALL=(root) NOPASSWD: /usr/local/sbin/sahht-create-admin\n' > /etc/sudoers.d/sahht-admin-bootstrap
chmod 440 /etc/sudoers.d/sahht-admin-bootstrap
visudo -cf /etc/sudoers.d/sahht-admin-bootstrap
nginx -t
systemctl daemon-reload
systemctl reload nginx
systemctl enable --now sahht-cert-renew.timer
/opt/sahht/certbot/bin/certbot renew --dry-run
openssl x509 -in "$CERT/fullchain.pem" -noout -issuer -dates -ext subjectAltName
echo 'HTTPS và lịch gia hạn đã cấu hình; không có mật khẩu trong script.'
