#!/usr/bin/env bash
set -euo pipefail

# OAuth headless (QNAP / serveur sans navigateur) — selon version gogcli
docker exec -it openclaw-gateway gog auth add --remote
