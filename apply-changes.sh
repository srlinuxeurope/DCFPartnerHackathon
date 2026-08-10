#!/usr/bin/env bash
# Apply the 2026-branch cleanup: remove NSP/SR OS leftovers, update telemetry,
# topology diagram and EDA intents for the reduced all-SR Linux topology.
# Run from the root of the DCFPartnerHackathon repo, on branch 2026:
#   bash apply-changes.sh /path/to/dcf-2026-updated-files.tar.gz
set -euo pipefail
TARBALL="${1:-dcf-2026-updated-files.tar.gz}"
git rev-parse --is-inside-work-tree >/dev/null

# ---------- 1. deletions ----------
git rm -q \
  clab/configs/client/interfaces-client01 \
  clab/configs/client/interfaces-client02 \
  clab/configs/client/interfaces-client03 \
  clab/configs/client/interfaces-client04 \
  clab/configs/grafana/dashboards/nokia_generic_telemetry.json \
  clab/configs/grafana/dashboards/nokia_sros_telemetry.json \
  clab/configs/grafana/dashboards/nokia_sros_17_flexalgo_srmpls.json \
  clab/configs/grafana/dashboards/nokia_sros_17_flexalgo_srv6.json \
  clab/configs/radius/dictionary.alcatel.sr.extended \
  docs/images/18-custom-traffic-scapy.svg \
  docs/images/grafana-srl-telemetry.drawio

git rm -q -r \
  clab/configs/syslog \
  docs/images/18-secure-gRPC-mTLS \
  docs/images/25-override-radius-attributes-subscribers \
  docs/images/41-ANYsec \
  docs/images/51-MACsec \
  docs/images/72-convert-epipe-from-tldp-to-evpn \
  docs/images/activity-22 \
  docs/images/activity-49 \
  docs/images/159-custom-grpcserver-configuration \
  docs/images/43-grafana-dashboard

# ---------- 2. modified / new files ----------
tar xzf "$TARBALL"
git add -A
# do not stage this script / the tarball if they were copied into the repo
git reset -q -- apply-changes.sh dcf-2026-updated-files.tar.gz 2>/dev/null || true

echo "Staged changes:"
git status --short
echo
echo "Review with 'git diff --staged', then:"
echo "  git commit -m 'Remove NSP/SR OS leftovers; update telemetry, diagram and EDA intents for the all-SRL reduced topology'"
