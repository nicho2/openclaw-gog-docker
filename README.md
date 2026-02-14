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


## Démarrage avec une image déjà publiée

```bash
# optionnel: surcharger l'image publiée
export OPENCLAW_IMAGE=<dockerhub_user>/openclaw-gog-docker:latest
docker compose -f docker-compose-image.yml up -d
```

Le fichier `docker-compose-image.yml` n'effectue aucun build local et tire directement l'image définie par `OPENCLAW_IMAGE` (par défaut `openclaw-gog-docker:latest`).

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

## CI/CD (build & push Docker)

Une pipeline GitHub Actions est fournie dans `.github/workflows/docker-image.yml`.

### Déclenchement
- `push` sur `main` (build + push)
- `push` d'un tag `v*` (build + push)
- `pull_request` vers `main` (build uniquement, sans push)
- `workflow_dispatch` (manuel)

### Configuration GitHub requise
- Secrets:
  - `DOCKERHUB_USERNAME`
  - `DOCKERHUB_TOKEN`
- Variable (optionnelle):
  - `DOCKER_IMAGE_NAME` (ex: `monorg/openclaw-gog`)

Si `DOCKER_IMAGE_NAME` n'est pas défini, l'image cible par défaut est `<owner>/<repo>`.
