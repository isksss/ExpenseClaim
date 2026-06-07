# Deploy 手順

## 目的

ExpenseClaim の deploy は、`develop` で検証済みの変更を `main` へ統合し、
リリース可能な状態として扱ったうえで、VPS に手動配置して Docker Compose で
起動する手順を基本にする。

本番 secret、認証情報、接続情報はリポジトリに保存しない。VPS 上の `.env` と
server 側の権限管理で扱う。

## 対象ブランチ

- `develop`: 開発統合ブランチ。feature branch はここへ統合する。
- `main`: 安定版ブランチ。`develop` がリリース可能な状態になった後に統合する。

deploy 対象として扱う commit は、`main` に統合済みで CI が成功している commit とする。

## Deploy 前チェック

deploy または `main` への統合前に、次を確認する。

1. 対象 branch が最新の `develop` を含んでいる。
2. GitHub Actions CI が対象 commit で成功している。
3. 未コミットの差分がない。
4. local で必要な検証が成功している。

```sh
git status --short
mise exec -- pnpm lint:md
mise exec -- pnpm lint:actions
mise exec -- pnpm lint:openapi
mise exec -- pnpm lint:frontend
mise exec -- pnpm check:frontend
mise exec -- pnpm --filter frontend build
cd apps/backend && mise exec -- make generate
cd apps/backend && mise exec -- make generate-db
cd apps/backend && mise exec -- go test ./...
cd apps/backend && mise exec -- make build && mise exec -- make clean
git diff --check
```

DB migration を含む変更の場合は、local PostgreSQL で migration の up / status /
down / re-up を確認する。

```sh
docker compose up -d --wait postgres
export DATABASE_URL='postgres://expenseclaim:expenseclaim@localhost:5432/expenseclaim?sslmode=disable'
cd apps/backend
mise exec -- make migrate-up
mise exec -- make migrate-status
mise exec -- make migrate-down
mise exec -- make migrate-up
docker compose down
```

## Docker Compose 構成

`compose.yaml` は次の service を定義する。

- `frontend`: Nuxt production server。Cloudflare Tunnel 経由で公開する。
- `backend`: Go backend server。Cloudflare Tunnel 経由で公開する。
- `cloudflared`: Cloudflare Tunnel connector。VPS から Cloudflare へ outbound 接続する。
- `postgres`: PostgreSQL 17。DB data は Docker volume `postgres-data` に保存する。

frontend と backend は repository root を build context とし、次の Dockerfile を使う。

- `infra/docker/frontend.Dockerfile`
- `infra/docker/backend.Dockerfile`

backend の container healthcheck は `/healthz` を確認する。frontend は
`http://127.0.0.1:3000` の応答を確認する。

frontend、backend、PostgreSQL は host の `127.0.0.1` のみに bind する。
local 開発環境や VPS host 上では `http://localhost:3000` と
`http://localhost:8080/healthz` で確認できる。外部公開は Cloudflare Tunnel の
Public Hostname で行い、外部 network へ直接 port 公開しない。

`cloudflared` は `tunnel` profile で起動する。local 開発環境では
`COMPOSE_PROFILES` を空にし、VPS では `.env` に `COMPOSE_PROFILES=tunnel` を設定する。

## VPS 手動 Deploy

### 1. VPS 前提

VPS には次を用意する。

- Docker Engine
- Docker Compose plugin
- Git
- mise、Node.js、pnpm、Go、goose
- Cloudflare 管理下の `isksss.dev`
- Cloudflare Tunnel token

VPS 上で migration を実行する場合は、`mise install` で `mise.toml` の tool を
利用できる状態にする。

### 2. 配置

VPS 上の配置先例を `/opt/expenseclaim` とする。初回は repository を clone し、
2 回目以降は対象 branch または tag を fetch して checkout する。

```sh
sudo mkdir -p /opt/expenseclaim
sudo chown "$USER":"$USER" /opt/expenseclaim
git clone <repository-url> /opt/expenseclaim
cd /opt/expenseclaim
git checkout main
```

既存配置を更新する場合は次を実行する。

```sh
cd /opt/expenseclaim
git fetch --prune
git checkout main
git pull --ff-only
```

### 3. VPS 用 `.env`

`.env.example` を元に VPS 上で `.env` を作成する。`.env` は repository に
commit しない。

```sh
cp .env.example .env
chmod 600 .env
```

VPS の `.env` では、少なくとも次を環境に合わせて変更する。

```sh
FRONTEND_PORT=3000
BACKEND_PORT=8080
POSTGRES_PORT=5432
COMPOSE_PROFILES=tunnel
POSTGRES_DB=expenseclaim
POSTGRES_USER=expenseclaim
POSTGRES_PASSWORD=<set-on-vps>
DATABASE_URL=postgres://expenseclaim:<set-on-vps>@postgres:5432/expenseclaim?sslmode=disable
NUXT_PUBLIC_API_BASE_URL=https://claim-api.isksss.dev
CORS_ALLOWED_ORIGINS=https://claim.isksss.dev
CLOUDFLARE_TUNNEL_TOKEN=<set-on-vps>
```

本番値は上の placeholder を置き換える。`CLOUDFLARE_TUNNEL_TOKEN` と
`POSTGRES_PASSWORD` は secret として扱い、repository、shell history、共有 log に
残さないように注意する。

### 4. Cloudflare Tunnel 設定

Cloudflare Dashboard の Zero Trust / Tunnels で remote-managed tunnel を作成し、
Public Hostname を次のように設定する。

| Hostname | Service |
| --- | --- |
| `claim.isksss.dev` | `http://frontend:3000` |
| `claim-api.isksss.dev` | `http://backend:8080` |

Public Hostname 設定後、Cloudflare DNS に tunnel 向けの CNAME が作成されていることを
確認する。

### 5. Build

```sh
docker compose build backend frontend
docker compose config
```

### 6. Migration

PostgreSQL を起動し、healthcheck 完了後に migration を実行する。

```sh
docker compose up -d --wait postgres
export HOST_DATABASE_URL='postgres://<user>:<url-encoded-password>@127.0.0.1:<published-port>/<db>?sslmode=disable'
cd apps/backend
DATABASE_URL="$HOST_DATABASE_URL" mise exec -- make migrate-up
DATABASE_URL="$HOST_DATABASE_URL" mise exec -- make migrate-status
cd ../..
```

`DATABASE_URL` は Compose 内の backend からは `postgres` host を使う。
VPS host から migration を実行する場合は、必要に応じて host 公開 port に合わせた
接続文字列を一時的に指定する。password に URL reserved character を含む場合は
percent-encoding する。

### 7. 起動

```sh
docker compose up -d --build --wait
docker compose ps
```

### 8. Deploy 後確認

```sh
curl -fsS http://localhost:8080/healthz
curl -fsS http://localhost:3000/
curl -fsS https://claim-api.isksss.dev/healthz
curl -fsS https://claim.isksss.dev/
docker compose logs --no-log-prefix --tail=100 backend
docker compose logs --no-log-prefix --tail=100 frontend
docker compose logs --no-log-prefix --tail=100 cloudflared
```

frontend から API を呼ぶ画面では、browser console に CORS error が出ないことを確認する。

### 9. 更新

```sh
cd /opt/expenseclaim
git fetch --prune
git checkout main
git pull --ff-only
docker compose build backend frontend
docker compose up -d --wait postgres
export HOST_DATABASE_URL='postgres://<user>:<url-encoded-password>@127.0.0.1:<published-port>/<db>?sslmode=disable'
cd apps/backend
DATABASE_URL="$HOST_DATABASE_URL" mise exec -- make migrate-up
cd ../..
docker compose up -d --build --wait
docker compose ps
```

### 10. 停止

```sh
docker compose down
```

DB volume を削除すると保存済み data が消えるため、本番では `docker compose down -v` を
実行しない。

## 手動リリース判断

以下のいずれかが未確定の場合、実環境への deploy は実行しない。

- secret 管理
- Cloudflare Tunnel の Public Hostname 設定
- rollback 手順
- 監視、log、backup の確認方法

未確定事項が残っている場合は、`develop` から `main` への統合までを
リリース可能状態の作成として扱い、実 deploy は別 issue で扱う。

## Deploy 後チェック

実環境の deploy 手順が確定した後は、deploy 後に次を確認する。

- frontend が起動し、主要画面へアクセスできる。
- backend API が起動し、health check または主要 endpoint が応答する。
- Cloudflare Tunnel が healthy である。
- DB migration の適用状態が期待どおりである。
- application log に起動直後の error が出ていない。
- 監視、alert、backup が期待どおりに動作している。

## Rollback 方針

rollback は、直前に安定していた `main` の commit または release tag へ戻す
ことを基本方針にする。

```sh
cd /opt/expenseclaim
git fetch --prune
git checkout <stable-commit-or-tag>
docker compose build backend frontend
docker compose up -d --wait
```

DB migration を含む release では、schema の後方互換性と rollback 可否を
deploy 前に確認する。不可逆 migration を含む場合は、別途 rollback 不可の
判断理由と復旧手順を issue または ADR に残す。

## 未定事項

- migration 実行責任者と実行場所
- 監視、alert、log 保存先
- backup と restore 手順
- Cloudflare Tunnel token の rotate 手順
