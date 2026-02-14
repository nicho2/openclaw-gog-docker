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

## Scripts disponibles

- Scripts hôte: `scripts/host/*.sh` (appellent `docker exec ...`)
- Scripts in-image: `scripts/in-image/*.sh` (copiés dans `/usr/local/bin/openclaw/`)

## Utilisation depuis l’hôte

```bash
./scripts/host/sanity-check.sh
./scripts/host/gog-auth-remote.sh
./scripts/host/calendar-today.sh
```

## Utilisation depuis le conteneur

```bash
docker exec -it openclaw-gateway bash
/usr/local/bin/openclaw/sanity-check.sh
/usr/local/bin/openclaw/gog-auth-remote.sh
```

## Persistance des tokens gog

Le `docker-compose.yml` configure:
- `XDG_CONFIG_HOME=/home/node/.openclaw/.config`
- `XDG_DATA_HOME=/home/node/.openclaw/.local/share`

Cela force l’écriture des credentials dans le volume persistant `.openclaw`.
