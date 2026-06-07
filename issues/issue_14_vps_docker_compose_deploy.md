# issue 14: vps docker compose deploy

## 目的

ExpenseClaim の frontend、backend、PostgreSQL を Docker Compose で起動できるようにし、
手動で VPS に配置して deploy するための手順を整備する。

## 背景

- issue 13 では deploy 方針と未定事項を整理したが、実環境へ配置できる
  Docker build 設定は対象外だった。
- VPS で手動 deploy するには、frontend/backend の container image build、
  PostgreSQL との接続、起動確認、migration 実行、rollback の手順が必要になる。
- 本番接続情報や secret はリポジトリへ保存せず、VPS 上の `.env` で管理する。
- 外部公開は Cloudflare Tunnel を利用し、`claim.isksss.dev` を frontend、
  `claim-api.isksss.dev` を backend に接続する。

## 対象範囲

- frontend/backend 用 Dockerfile の追加
- Docker Compose による frontend、backend、PostgreSQL 起動設定
- Docker Compose による Cloudflare Tunnel 起動設定
- backend 起動確認用 health endpoint の追加
- `claim.isksss.dev` から `claim-api.isksss.dev` へ接続するための CORS 設定
- VPS 手動 deploy 手順ドキュメントの更新
- issue ファイルと devlog への作業内容記録

## 対象外

- 実 VPS への接続、ファイル転送、deploy 実行
- 本番 secret、認証情報、接続情報の追加
- GitHub Actions deploy job の追加
- nginx、TLS、独自 domain、監視、backup の本格設定
- commit、push、Pull Request 作成

## 実装内容

- `infra/docker/frontend.Dockerfile` で Nuxt frontend を production build し、
  `.output` を Node.js runtime で起動する。
- `infra/docker/backend.Dockerfile` で Go backend を multi-stage build し、
  runtime image で binary を起動する。
- `compose.yaml` に `frontend`、`backend`、`postgres` を定義し、
  healthcheck と service dependency を設定する。
- `compose.yaml` に `cloudflared` を定義し、VPS 上の `.env` に置いた
  Cloudflare Tunnel token で起動する。
- `cloudflared` は `tunnel` profile に置き、local 開発では token なしで
  `docker compose up` できるようにする。
- frontend/backend は host の `127.0.0.1` のみに bind し、Cloudflare Tunnel からも
  Compose network 内の service name へ接続する。
- `apps/backend/internal/server/server.go` に CORS middleware を追加し、
  `CORS_ALLOWED_ORIGINS` で許可 origin を管理する。
- `apps/backend/internal/server/server.go` に `/healthz` を追加し、
  container healthcheck と deploy 後確認に利用する。
- `docs/deployment.md` に VPS 手動 deploy 手順、migration、起動確認、
  更新、rollback、未定事項を追記する。

## 受け入れ条件

- `issues/issue_14_vps_docker_compose_deploy.md` が存在する。
- Docker Compose で `frontend`、`backend`、`postgres`、`cloudflared` service が
  定義されている。
- local 開発環境では `COMPOSE_PROFILES` を空にすると localhost 接続で起動できる。
- VPS では `COMPOSE_PROFILES=tunnel` と token を設定すると Cloudflare Tunnel も起動する。
- frontend/backend の Dockerfile が存在する。
- frontend/backend は host の `127.0.0.1` のみに bind し、外部公開は
  Cloudflare Tunnel 経由で行う。
- backend に `/healthz` があり、healthcheck から利用できる。
- backend は `https://claim.isksss.dev` を CORS 許可 origin として扱える。
- `docs/deployment.md` に Cloudflare Tunnel の Public Hostname 設定が記述されている。
- VPS 手動 deploy 手順が `docs/deployment.md` に記述されている。
- secret、本番接続情報、deploy job が追加されていない。
- Markdown lint、backend test、frontend build、Docker Compose config、
  `git diff --check` が成功する。

## 検証コマンド

```sh
mise exec -- pnpm format:md
mise exec -- pnpm lint:md
cd apps/backend && mise exec -- go test ./...
mise exec -- pnpm --filter frontend build
docker compose config
docker compose build backend frontend
docker compose up -d --wait postgres backend frontend
git diff --check
```

## 完了結果

- `infra/docker/frontend.Dockerfile` を追加し、Nuxt frontend を production build して
  Node.js runtime で起動できるようにした。
- `infra/docker/backend.Dockerfile` を追加し、Go backend を multi-stage build して
  runtime image で起動できるようにした。
- `compose.yaml` に `frontend`、`backend`、`postgres` service を定義し、
  healthcheck と service dependency を設定した。
- `compose.yaml` に `cloudflared` service を追加し、VPS の `.env` に置く
  `CLOUDFLARE_TUNNEL_TOKEN` で起動するようにした。
- `cloudflared` を `tunnel` profile に置き、local 開発環境では token なしでも
  frontend/backend/postgres を localhost で起動できるようにした。
- frontend/backend を `127.0.0.1` のみに bind し、local 開発環境では localhost で
  確認でき、外部公開は Cloudflare Tunnel に限定されるようにした。
- PostgreSQL は migration 用に `127.0.0.1` bind のみにした。
- backend に CORS middleware を追加し、`CORS_ALLOWED_ORIGINS` で
  `claim.isksss.dev` を許可できるようにした。
- `apps/backend/internal/server/server.go` に GET/HEAD 対応の `/healthz` を追加した。
- `docs/deployment.md` に VPS 手動 deploy、migration、起動確認、更新、
  rollback、Cloudflare Tunnel Public Hostname の手順を追記した。
- `POSTGRES_PORT=15432` を指定してローカル Compose 起動を検証し、
  frontend、backend、postgres が healthy になることを確認した。

## 残リスク

- VPS への実 deploy は本番環境変更に当たるため、この issue では実行しない。
- Cloudflare Tunnel token の rotate、監視、backup は必要に応じて別 issue で扱う。
