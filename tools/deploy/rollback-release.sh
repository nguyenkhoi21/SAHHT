#!/bin/bash
# Chỉ đổi code khi schema tương thích; không tự restore database.
set -euo pipefail
id=${1:-}
[[ "$id" =~ ^release-[0-9]{8}-[a-zA-Z0-9-]{1,40}$ ]] || exit 2
test "${2:-}" = 'XAC-NHAN-SCHEMA-TUONG-THICH' || { echo 'Kiểm schema của snapshot/live và release đích trước; cần xác nhận.'; exit 2; }
sudo -n /usr/local/sbin/sahht-activate-release "$id"
sleep 3
curl --fail --silent https://45.76.177.247/health
