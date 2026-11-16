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
