#!/usr/bin/env bash
# The pod template must change when config changes, otherwise pods keep stale env vars.
set -euo pipefail

CHART="$(dirname "$0")/../chart"

checksum() {
  helm template t "$CHART" "$@" | grep 'checksum/config:'
}

before="$(checksum)"
same="$(checksum)"
after="$(checksum --set config.LOG_LEVEL=debug)"

[[ "$before" == "$same" ]] || { echo "FAIL: checksum is not deterministic"; exit 1; }
[[ "$before" != "$after" ]] || { echo "FAIL: config change did not alter checksum"; exit 1; }
echo "ok:   config change alters checksum/config"
