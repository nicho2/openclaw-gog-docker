#!/usr/bin/env bash
set -euo pipefail

# OAuth standard (si tu as un navigateur sur la machine)
docker exec -it openclaw-gateway gog auth
