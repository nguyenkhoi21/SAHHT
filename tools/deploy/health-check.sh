#!/bin/bash
set -euo pipefail
curl --fail --silent --show-error https://45.76.177.247/health
systemctl is-active sahht.service nginx sahht-backup.timer sahht-cert-renew.timer
systemctl show sahht.service -p MemoryCurrent -p CPUUsageNSec -p NRestarts
df -h /var/lib/sahht /var/backups/sahht
echo | openssl s_client -connect 45.76.177.247:443 -servername 45.76.177.247 2>/dev/null | openssl x509 -noout -dates -checkend 86400
