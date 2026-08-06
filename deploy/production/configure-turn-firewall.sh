#!/usr/bin/env sh
set -eu

if ! command -v ufw >/dev/null 2>&1; then
  echo "ufw is not installed; open TCP/UDP 3478 and UDP 49160-49200 manually." >&2
  exit 1
fi

ufw allow 3478/tcp comment "Monica TURN TCP"
ufw allow 3478/udp comment "Monica TURN UDP"
ufw allow 49160:49200/udp comment "Monica TURN relay"
ufw status
