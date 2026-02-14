#!/usr/bin/env bash
set -euo pipefail

echo "[1/3] gog version:"
gog version

echo
echo "[2/3] calendar today (après auth):"
gog calendar today || true

echo
echo "[3/3] OpenClaw version (si dispo):"
openclaw --version || true
