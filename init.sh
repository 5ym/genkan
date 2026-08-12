#!/bin/sh
set -e

if [ -d genkan/.git ]; then
	cd genkan
	git pull --ff-only
else
	git clone https://github.com/danything/genkan.git
	cd genkan
fi
docker compose up -d
