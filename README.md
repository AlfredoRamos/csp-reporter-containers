# About

Docker Compose setup for **CSP Reporter** using [PostgreSQL](https://www.postgresql.org/), [Redis](https://redis.io/) and [Nginx](https://nginx.org/).

[![Build Status - Main branch](https://img.shields.io/github/actions/workflow/status/AlfredoRamos/csp-reporter-docker/ci.yml?branch=main&style=flat-square&label=main)](https://github.com/AlfredoRamos/csp-reporter-docker/actions/workflows/ci.yml)
[![Build Status - Dev branch](https://img.shields.io/github/actions/workflow/status/AlfredoRamos/csp-reporter-docker/ci.yml?branch=dev&style=flat-square&label=dev)](https://github.com/AlfredoRamos/csp-reporter-docker/actions/workflows/ci.yml)
[![Latest Stable Version](https://img.shields.io/github/v/tag/AlfredoRamos/csp-reporter-docker?sort=semver&style=flat-square&label=stable)](https://github.com/AlfredoRamos/csp-reporter-docker/tags)

# Setup

## System

### Date and time

It requires [systemd-timesyncd](https://www.freedesktop.org/software/systemd/man/latest/systemd-timesyncd.service.html) to be installed in the system.

```shell
sudo timedatectl set-timezone America/Mexico_City
sudo timedatectl set-ntp on
```

### Docker cleanup

It will prune stopped images, containers and networks, as per the [official docs](https://docs.docker.com/config/pruning/#prune-everything).

```shell
sudo cp systemd/docker-prune.{service,timer} /usr/lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart docker-prune.service
sudo systemctl enable --now docker-prune.timer
```

## Requirements

- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.20.3

### VSCode extensions

- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)

## Submodules

### Clone with submodules

```shell
git clone -b master --recurse-submodules --remote-submodules -j 10 -- https://github.com/AlfredoRamos/csp-reporter-docker.git
```

### Initialize

```shell
git submodule init
```

### Add

```shell
git submodule add -b master -- https://github.com/AlfredoRamos/csp-reporter-backend.git backend
git submodule add -b master -- https://github.com/AlfredoRamos/csp-reporter-frontend.git frontend
```

### Update

```shell
git submodule update --init --remote -j 10
```

### Change branch

```shell
git submodule set-branch -b master -- backend && git submodule set-branch -b master -- frontend
```

### Reset

```shell
git submodule foreach 'git remote prune origin && git fetch origin && git checkout master && git reset --hard origin/master'
```

# Configuration

## Production

In order to work correctly, the environment variables need to be adjusted to use the appropiate Docker Compose service.

### Backend

See the README in the [AlfredoRamos/csp-reporter-backend](https://github.com/AlfredoRamos/csp-reporter-backend) repository.

### Frontend

See the README in the [AlfredoRamos/csp-reporter-frontend](https://github.com/AlfredoRamos/csp-reporter-frontend) repository.

# Run app

## Production

### Build images

```shell
docker compose --env-file backend/.env build
```

### Start containers

```shell
docker compose --env-file backend/.env up --no-build --force-recreate --remove-orphans -d
```

### Stop containers

```shell
docker compose down --remove-orphans
```

### Upgrade containers

The following commands help to minimize or avoid at all the downtime while upgrading the application.

```shell
docker compose --env-file backend/.env up --scale csp-reporter=2 --no-recreate -d
docker rm -f csp-reporter_csp-reporter_<n>
docker compose --env-file backend/.env up --scale csp-reporter=1 --no-recreate -d
```

### Remove cached application

The frontend and backend are created only once by Docker Compose, so if you don't see the changes you made in the application, remove the `appdata` volume after stoping the containers.

```shell
docker volume rm <prefix>_appdata
```

Where `<prefix>` is usually the folder where the YML file is located.

### SSL

The SSL public and private key files need their permissions to be fixed directly in the host, as they will be mounted inside, or inside the containers.

```shell
docker compose run --rm postgresql chmod 600 /var/lib/postgresql/server.{crt,key}
docker compose run --rm postgresql chown 70 /var/lib/postgresql/server.{crt,key}
```

### Manual frontend transpiling

The transpilation is done automatically by the containers, however if you need to do it manually you'll need to run the following commands.

```shell
docker compose run --rm csp-reporter npm --prefix frontend install frontend
docker compose run --rm csp-reporter npm run --prefix frontend build
```

## Development

### Setup

```shell
(cd frontend && npm ci --omit dev && npm run build)
```

### Start containers

```shell
docker compose -f docker compose.dev.yml --env-file backend/.env up --build --force-recreate --remove-orphans -d
```

### Stop containers

```shell
docker compose down --remove-orphans
```
