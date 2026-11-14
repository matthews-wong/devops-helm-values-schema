#!/usr/bin/env bash
# Each case must be rejected by values.schema.json; a pass means the schema is too loose.
set -uo pipefail

CHART="$(dirname "$0")/../chart"
failed=0

expect_reject() {
  local label="$1"
  shift
  if helm template t "$CHART" "$@" >/dev/null 2>&1; then
    echo "FAIL: accepted ${label}"
    failed=1
  else
    echo "ok:   rejected ${label}"
  fi
}

expect_reject "latest tag" --set image.tag=latest
expect_reject "zero replicas" --set replicaCount=0
expect_reject "unknown top-level key" --set replicas=3
expect_reject "privileged port" --set containerPort=80
expect_reject "bad pull policy" --set image.pullPolicy=Sometimes
expect_reject "missing memory limit" --set resources.limits.memory=null
expect_reject "probe path without slash" --set probes.path=healthz
expect_reject "non-string config value" --set-json 'config={"A":1}'

exit "$failed"
