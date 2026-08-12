#!/bin/sh
set -e

mkdir -p local-dev-proxy
cd local-dev-proxy
curl -fsSO https://raw.githubusercontent.com/5ym/local-dev-proxy/main/compose.yml
docker compose up -d
