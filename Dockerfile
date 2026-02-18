# openclaw-gog-docker
# Base OpenClaw (image publiée sur Docker Hub)
FROM alpine/openclaw:latest

SHELL ["/bin/bash", "-lc"]

# L'image de base s'exécute en utilisateur non-root, on passe root
# pour installer les dépendances système.
USER root

# Dépendances minimales (la base alpine/openclaw est actuellement Debian-based)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl tar \
 && rm -rf /var/lib/apt/lists/* \
 && update-ca-certificates

# Version gogcli (sans le "v") ex: 0.10.0
ARG GOG_VERSION=0.10.0

# Télécharger gogcli depuis GitHub Releases (assets GoReleaser):
# gogcli_<version>_linux_<arch>.tar.gz contenant le binaire "gog"
RUN set -euo pipefail; \
  arch="$(dpkg --print-architecture)"; \
  case "${arch}" in \
    amd64) gog_arch="amd64" ;; \
    arm64) gog_arch="arm64" ;; \
    *) echo "Unsupported arch: ${arch}" >&2; exit 1 ;; \
  esac; \
  url="https://github.com/steipete/gogcli/releases/download/v${GOG_VERSION}/gogcli_${GOG_VERSION}_linux_${gog_arch}.tar.gz"; \
  echo "Downloading: ${url}"; \
  curl -fsSL "${url}" -o /tmp/gogcli.tgz; \
  tar -xzf /tmp/gogcli.tgz -C /usr/local/bin gog; \
  chmod +x /usr/local/bin/gog; \
  /usr/local/bin/gog version

# Scripts "in-image" (exécutables dans le conteneur)
COPY scripts/in-image/ /usr/local/bin/openclaw/
RUN chmod +x /usr/local/bin/openclaw/*.sh

# Wrapper openclaw -> node /app/dist/index.js
RUN cat >/usr/local/bin/openclaw <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ -f /app/dist/index.js ]]; then
  exec node /app/dist/index.js "$@"
elif [[ -f /app/dist/index.mjs ]]; then
  exec node /app/dist/index.mjs "$@"
elif [[ -f /app/dist/index.cjs ]]; then
  exec node /app/dist/index.cjs "$@"
else
  echo "OpenClaw dist introuvable dans /app/dist (index.js|mjs|cjs)" >&2
  exit 1
fi
EOF
RUN chmod +x /usr/local/bin/openclaw


# Restaurer l'utilisateur applicatif par défaut.
USER node
