#!/bin/sh
set -e

if [ -d local-dev-proxy/.git ]; then
	cd local-dev-proxy
	git pull --ff-only
else
	git clone https://github.com/5ym/local-dev-proxy.git
	cd local-dev-proxy
fi
docker compose up -d
