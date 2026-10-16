#!/usr/bin/env bash
# Logs in with the API key (BW_CLIENTID / BW_CLIENTSECRET), unlocks with BW_PASSWORD, serves on :8087.
# BW_HOST is the server URL (Bitwarden or Vaultwarden).
set -euo pipefail

: "${BW_HOST:?}" "${BW_CLIENTID:?}" "${BW_CLIENTSECRET:?}" "${BW_PASSWORD:?}"

bw config server "$BW_HOST"
bw login --apikey --raw >/dev/null
BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
export BW_SESSION
bw unlock --check

# --hostname all: bw serve 2026.6+ otherwise rejects any Host header but localhost (the stores call it
# by service name). It has no authentication — the NetworkPolicy next to the Deployment is the guard.
exec bw serve --hostname all --port 8087
