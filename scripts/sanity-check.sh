#!/usr/bin/env bash
set -euo pipefail

echo "[1/3] OpenClaw version (si dispo):"
docker exec -it openclaw-gateway openclaw --version || true

echo
echo "[2/3] gog version:"
docker exec -it openclaw-gateway gog version

echo
echo "[3/3] test calendar (après auth):"
docker exec -it openclaw-gateway gog calendar today || true
