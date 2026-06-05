# issue 8: compose postgres health wait

## 目的

ローカル PostgreSQL 起動直後に migration を実行しても、PostgreSQL が ready になる前の
接続失敗を避けられる手順に修正する。

## 背景

- issue 7 の手順では `docker compose down -v && docker compose up -d postgres`
  直後に migration を実行すると、PostgreSQL の起動完了前に接続して失敗することがある。
- `compose.yaml` の `postgres` service には healthcheck があるため、
  手順側で healthcheck が healthy になるまで待つべき。

## 対象範囲

- README のローカル PostgreSQL 起動手順
- issue 7 の受け入れ条件、検証コマンド、完了結果
- issue 8 の作業記録

## 対象外

- migration ファイル内容の変更
- backend runtime 実装の変更
- Docker Compose service 定義の変更
- secret の追加

## 実装内容

- README の `docker compose up -d postgres` を
  `docker compose up -d --wait postgres` に修正する。
- issue 7 の検証コマンドと受け入れ条件を `--wait` 付きに修正する。
- issue 7 の完了結果に、初期 volume から `--wait` 付きで検証した旨を追記する。

## 受け入れ条件

- README の PostgreSQL 起動手順が `docker compose up -d --wait postgres` になっている。
- issue 7 の検証コマンドが `docker compose up -d --wait postgres` になっている。
- 初期 volume から PostgreSQL の healthcheck 待機後に migration up/status/down/up を
  実行できる。
- migration ファイル内容と backend runtime 実装を変更しない。

## 検証コマンド

```sh
docker compose down -v
docker compose up -d --wait postgres
DATABASE_URL='postgres://expenseclaim:expenseclaim@localhost:5432/expenseclaim'
export DATABASE_URL="${DATABASE_URL}?sslmode=disable"
cd apps/backend
mise exec -- make migrate-up
mise exec -- make migrate-status
mise exec -- make migrate-down
mise exec -- make migrate-up
cd ../..
docker compose down
mise exec -- pnpm lint:md
git diff --check
```

## 完了結果

- README と issue 7 の PostgreSQL 起動手順を
  `docker compose up -d --wait postgres` に修正した。
- 初期 volume から `--wait` 付きで PostgreSQL の healthcheck 待機後に migration
  up/status/down/up を検証した。
- migration ファイル内容と backend runtime 実装は変更していない。

## 残リスク

- `docker compose up --wait` は Docker Compose v2 の機能であり、古い Compose では
  利用できない可能性がある。
