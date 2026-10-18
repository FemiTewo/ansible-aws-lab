#!/usr/bin/env bash
# Usage: ./scripts/make-inventory.sh <web-private-ip> <db-private-ip>
set -euo pipefail
[ $# -eq 2 ] || { echo "Usage: $0 <web-private-ip> <db-private-ip>"; exit 1; }
cat > inventory/hosts.ini <<INV
[web]
web1 ansible_host=$1

[db]
db1 ansible_host=$2

[lab:children]
web
db
INV
echo "Wrote inventory/hosts.ini"
