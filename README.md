# local-dev-proxy

## Description

A single-file reverse proxy for local development, so you never have to manage published ports per project.

One shared [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) container listens on ports 80/443 and routes `*.localhost` hostnames to your containers. There are no config files to maintain — the infrastructure side is just this `compose.yml`, and each project opts in explicitly with two labels. Nothing is exposed automatically.

## How to use

```sh
curl -sf https://raw.githubusercontent.com/5ym/local-dev-proxy/main/init.sh | sh -s
```

Or manually: download `compose.yml` and run `docker compose up -d`.

## Adding a project

Add two labels and join the `proxy` network. The hostname and upstream port are declared explicitly in each project — nothing is guessed from container names.

```yml
services:
  app:
    labels:
      caddy: myapp.localhost
      caddy.reverse_proxy: "{{upstreams 5173}}"
    networks: [default, proxy]

networks:
  proxy:
    external: true
```

Then open http://myapp.localhost — `*.localhost` resolves to loopback in modern browsers, so no DNS setup is needed. Do not publish the port in the project's compose file; the proxy reaches the container over the shared network, which is what makes port conflicts impossible.

## HTTPS

Caddy issues certificates for `*.localhost` from its internal CA automatically, so https://myapp.localhost works out of the box. To avoid browser warnings, trust Caddy's root certificate once:

```sh
docker compose cp proxy:/data/caddy/pki/authorities/local/root.crt .
```

Then install `root.crt` into your OS/browser trust store. Plain `http://` works without any of this (and `localhost` is already a secure context).

## Other functions

It comes with [Portainer](https://www.portainer.io), a tool for managing Docker via web UI, available at http://portainer.localhost.
