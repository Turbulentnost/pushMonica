#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl gnupg ufw

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

systemctl enable --now docker

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 9010/tcp
ufw --force enable || true

echo "Docker: $(docker --version)"
echo "Compose: $(docker compose version)"
echo "Server bootstrap done."
