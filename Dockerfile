# openclaw-gog-docker
# Base OpenClaw (image publiée sur Docker Hub)
FROM alpine/openclaw:latest

SHELL ["/bin/bash", "-lc"]

# L'image de base s'exécute en utilisateur non-root, on passe root
# pour installer les dépendances système.
USER root

# Dépendances minimales (la base alpine/openclaw est actuellement Debian-based)

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      tar \
      git \
      openssh-client \
      gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends gh; \
    rm -rf /var/lib/apt/lists/*; \
    update-ca-certificates; \
    git --version; \
    gh --version

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

# Scripts "in-image"
COPY scripts/in-image/ /usr/local/bin/openclaw-scripts/
RUN chmod +x /usr/local/bin/openclaw-scripts/*.sh

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
