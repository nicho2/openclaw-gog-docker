#!/usr/bin/env bash
set -euo pipefail

# Auth OAuth headless / remote (NAS, serveur)
# Selon versions gogcli, cette commande peut être la bonne.
gog auth add --remote
