#!/usr/bin/env bash
# PDB must never block drains outright, and the NetworkPolicy must be switchable.
set -euo pipefail

CHART="$(dirname "$0")/../chart"

render() {
  helm template t "$CHART" "$@"
}

render | grep -q '^kind: PodDisruptionBudget' || { echo "FAIL: no PodDisruptionBudget rendered"; exit 1; }
render | grep -q '^kind: NetworkPolicy' || { echo "FAIL: no NetworkPolicy rendered by default"; exit 1; }
if render --set networkPolicy.enabled=false | grep -q '^kind: NetworkPolicy'; then
  echo "FAIL: NetworkPolicy rendered while disabled"; exit 1
fi
min="$(render | awk '/minAvailable:/ {print $2}')"
replicas="$(render | awk '/replicas:/ {print $2}')"
(( min < replicas )) || { echo "FAIL: minAvailable ($min) must stay below replicas ($replicas)"; exit 1; }
echo "ok:   pdb and networkpolicy render as expected"

# The test pod must carry the test hook and stay out of the Service selector.
hook="$(render --show-only templates/tests/test-connection.yaml)"
grep -q 'helm.sh/hook: test' <<<"$hook" || { echo "FAIL: test pod lacks the test hook annotation"; exit 1; }
if grep -q "app.kubernetes.io/name: echo-service$" <<<"$hook"; then
  echo "FAIL: test pod matches the Service selector"; exit 1
fi
echo "ok:   test hook pod renders outside the Service selector"
