# openclaw-gog-docker

Image Docker: `alpine/openclaw:latest` + `gog` (gogcli) pour connecter Google Workspace (Calendar, Gmail, Drive…).

## Pré-requis
- Docker + Docker Compose
- Un volume persistant monté sur `/home/node/.openclaw` (sinon tu perds les tokens OAuth au reboot)
- Un projet Google Cloud avec Calendar API activée + OAuth Client (voir doc OpenClaw)

## Démarrage

```bash
cp .env.example .env
# édite .env (OPENCLAW_GATEWAY_TOKEN, chemins volumes, ports…)
docker compose up -d --build
```

## Authentification Google

```bash
./scripts/gog-auth.sh
# ou pour un serveur headless
./scripts/gog-auth-remote.sh
```

## Vérification rapide

```bash
./scripts/sanity-check.sh
```
