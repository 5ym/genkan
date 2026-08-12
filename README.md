# local-dev-proxy

[English](./README.en.md)

## 概要

ローカル開発用のリバースプロキシです。プロジェクトごとのポート管理・ポート競合をなくします。

共有の [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) コンテナが80/443番ポートで待ち受け、`*.localhost` のホスト名を各コンテナにルーティングします。インフラ側の設定はこのリポジトリの `compose.yml` 1枚だけで、設定ファイルの管理は不要です。各プロジェクトはラベルで明示的にオプトインします（コンテナ名からの自動公開はしません）。

## 使い方

```sh
curl -sf https://raw.githubusercontent.com/5ym/local-dev-proxy/main/init.sh | sh -s
```

初回はこのリポジトリをクローンして起動し、2回目以降は `git pull` で `compose.yml` の変更に追従してから再適用します。手動でやる場合:

```sh
git clone https://github.com/5ym/local-dev-proxy.git
cd local-dev-proxy
docker compose up -d
```

更新するときはもう一度 `init.sh` を実行するか、クローン先で `git pull && docker compose up -d` してください。

## プロジェクトの追加

ラベルを2行追加して `proxy` ネットワークに参加させるだけです。ホスト名と転送先ポートは各プロジェクト側に明示的に書きます。

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

- `{{upstreams 5173}}` は「このコンテナ自身のIP:5173」に展開されます。ポート番号は**コンテナ内でアプリが待ち受けているポート**を必ず指定してください（`EXPOSE` からの自動検出はありません）
- プロジェクト側で `ports:` を公開しないでください。プロキシは共有ネットワーク経由でコンテナに到達するので、公開しないことがポート競合をなくす仕組みそのものです
- `*.localhost` はモダンブラウザがループバックに解決するので、DNSやhostsの設定は不要です

追加したら http://myapp.localhost を開くだけです（自動的にHTTPSへリダイレクトされます）。

## HTTPS

Caddyが内部CAで `*.localhost` の証明書を自動発行するので、https://myapp.localhost がそのまま使えます。ブラウザの警告を消したい場合はCaddyのルート証明書を一度だけ信頼させてください:

```sh
docker compose cp proxy:/data/caddy/pki/authorities/local/root.crt .
```

取り出した `root.crt` をOS・ブラウザの信頼ストアに登録します。警告を許容するなら何もしなくても動きます。

## その他の機能

DockerをWeb UIで管理できる [Portainer](https://www.portainer.io) が同梱されており、http://portainer.localhost からアクセスできます。
