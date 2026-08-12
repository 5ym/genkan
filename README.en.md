# genkan

[日本語](./README.md)

Genkan (玄関) is the entryway of a Japanese home — here, the entryway to your containers. A reverse proxy that routes hostnames to containers.

A [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) container listens on ports 80/443 and routes each hostname to its container. The entire setup is this single `compose.yml`. Each project opts in with two labels and publishes no ports, so port conflicts cannot happen.

For local development, `*.localhost` works out of the box (no DNS setup). Point a real domain at it and certificates come from Let's Encrypt automatically, so the same setup works on servers too.

## How to use

```sh
curl -sf https://raw.githubusercontent.com/5ym/genkan/main/init.sh | sh -s
```

On first run it clones this repository and starts the proxy; on subsequent runs it pulls the latest changes and re-applies them. Or manually:

```sh
git clone https://github.com/5ym/genkan.git
cd genkan
docker compose up -d
```

## Adding a project

Add two labels and join the `proxy` network.

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
- Do not publish ports in the project's compose file; not publishing is exactly what makes port conflicts impossible

Then open http://myapp.localhost (it redirects to HTTPS automatically).

## HTTPS

Caddy's internal CA issues certificates for `*.localhost` automatically. To avoid browser warnings, trust the root certificate once:

```sh
docker compose cp proxy:/data/caddy/pki/authorities/local/root.crt .
```

For real domains, certificates are obtained from Let's Encrypt automatically.

## Extras

Comes with [Portainer](https://www.portainer.io), a web UI for managing Docker → http://portainer.localhost
