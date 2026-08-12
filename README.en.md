# local-dev-proxy

[日本語](./README.md)

## Description

A reverse proxy for local development, so you never have to manage published ports per project.

One shared [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) container listens on ports 80/443 and routes `*.localhost` hostnames to your containers. The infrastructure side is just the `compose.yml` in this repository — no config files to maintain. Each project opts in explicitly with labels; nothing is exposed automatically based on container names.

## How to use

```sh
curl -sf https://raw.githubusercontent.com/5ym/local-dev-proxy/main/init.sh | sh -s
```

On first run it clones this repository and starts the proxy; on subsequent runs it pulls the latest `compose.yml` and re-applies it. Or manually:

```sh
git clone https://github.com/5ym/local-dev-proxy.git
cd local-dev-proxy
docker compose up -d
```

To update, run `init.sh` again, or `git pull && docker compose up -d` in the clone.

## Adding a project

Add two labels and join the `proxy` network. The hostname and upstream port are declared explicitly in each project.

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

- `{{upstreams 5173}}` expands to "this container's IP:5173". Always specify the port your app listens on inside the container — there is no auto-detection from `EXPOSE`
- Do not publish ports in the project's compose file; the proxy reaches the container over the shared network, which is what makes port conflicts impossible
- `*.localhost` resolves to loopback in modern browsers, so no DNS setup is needed

Then open http://myapp.localhost (it redirects to HTTPS automatically).

## HTTPS

Caddy issues certificates for `*.localhost` from its internal CA automatically, so https://myapp.localhost works out of the box. To avoid browser warnings, trust Caddy's root certificate once:

```sh
docker compose cp proxy:/data/caddy/pki/authorities/local/root.crt .
```

Then install `root.crt` into your OS/browser trust store.

## Other functions

It comes with [Portainer](https://www.portainer.io), a tool for managing Docker via web UI, available at http://portainer.localhost.
