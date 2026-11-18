#!/bin/bash
set -euo pipefail
sudo -n /usr/bin/systemctl start sahht-backup.service
systemctl show sahht-backup.service -p Result -p ExecMainStatus
