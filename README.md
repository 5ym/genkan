# genkan

[English](./README.en.md)

コンテナの玄関。ホスト名でコンテナにルーティングするリバースプロキシです。

[caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) のコンテナが80/443番で待ち受け、ホスト名を各コンテナに振り分けます。設定はこの `compose.yml` 1枚だけ。各プロジェクトはラベル2行でオプトインし、ポートを公開しないのでポート競合が起きません。

ローカル開発では `*.localhost` がそのまま使えます（DNS設定不要）。実ドメインを向ければLet's Encryptで証明書も自動取得されるので、サーバーでも同じ構成が使えます。

## 使い方

```sh
curl -sf https://raw.githubusercontent.com/danything/genkan/main/init.sh | sh -s
```

初回はこのリポジトリをクローンして起動し、2回目以降は `git pull` で変更に追従してから再適用します。手動なら:

```sh
git clone https://github.com/danything/genkan.git
cd genkan
docker compose up -d
```

## プロジェクトの追加

ラベルを2行追加して `proxy` ネットワークに参加させるだけです。

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

- `{{upstreams 5173}}` は「このコンテナ自身のIP:5173」に展開されます。ポートは**アプリがコンテナ内で待ち受けているポート**を必ず指定してください（`EXPOSE` からの自動検出はありません）
- プロジェクト側で `ports:` は公開しないでください。公開しないことがポート競合をなくす仕組みそのものです

あとは http://myapp.localhost を開くだけです（自動的にHTTPSへリダイレクトされます）。

## HTTPS

`*.localhost` にはCaddyの内部CAが証明書を自動発行します。ブラウザの警告を消したい場合は、ルート証明書を一度だけ信頼ストアに登録してください:

```sh
docker compose cp proxy:/data/caddy/pki/authorities/local/root.crt .
```

実ドメインの場合は何もしなくてもLet's Encryptで自動取得されます。

## その他

DockerをWeb UIで管理できる [Portainer](https://www.portainer.io) が同梱されています → http://portainer.localhost
