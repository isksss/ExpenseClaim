# issue 7: local postgres migration verification

## 目的

ローカル PostgreSQL Docker Compose を追加し、goose migration の up/down/re-up を
実 DB で検証できるようにする。

## 背景

- issue 5、issue 6 では `DATABASE_URL` 未設定のため、migration target の実 DB
  適用確認が未実施だった。
- ローカル開発用 PostgreSQL を compose で起動できれば、migration の適用状態と
  down/up の往復を再現しやすくなる。

## 対象範囲

- root の `compose.yaml` 追加
- root の `.env.example` 追加
- README へのローカル PostgreSQL と migration 検証手順の追記
- 実 DB に対する `make migrate-up`、`make migrate-status`、`make migrate-down`、
  再 `make migrate-up` の検証

## 対象外

- migration ファイル内容の変更
- backend runtime 実装の変更
- 本番向け DB 設定
- secret の追加
- IDE 固有ファイルの追加

## 実装内容

- `compose.yaml` にローカル開発用の `postgres` service を追加する。
- `POSTGRES_DB`、`POSTGRES_USER`、`POSTGRES_PASSWORD` は secret ではない
  ローカル開発用の固定値にする。
- `.env.example` に `DATABASE_URL` と `POSTGRES_PORT` の例を記載する。
- README に compose 起動、`DATABASE_URL` 設定、migration up/status/down/re-up
  の手順を記載する。

## 受け入れ条件

- `docker compose up -d --wait postgres` でローカル PostgreSQL が起動し、
  healthcheck が healthy になるまで待機できる。
- 実 DB に対して `make migrate-up` が成功する。
- 実 DB に対して `make migrate-status` で migration 適用状態を確認できる。
- 実 DB に対して `make migrate-down` が成功する。
- 再度 `make migrate-up` が成功する。
- migration ファイル内容、backend runtime 実装、IDE 固有ファイルを変更しない。

## 検証コマンド

```sh
docker compose up -d --wait postgres
docker compose ps postgres
DATABASE_URL='postgres://expenseclaim:expenseclaim@localhost:5432/expenseclaim'
export DATABASE_URL="${DATABASE_URL}?sslmode=disable"
cd apps/backend
mise exec -- make migrate-up
mise exec -- make migrate-status
mise exec -- make migrate-down
mise exec -- make migrate-up
cd ../..
mise exec -- pnpm format:md
mise exec -- pnpm lint:md
git diff --check
```

## 完了結果

- `compose.yaml` にローカル開発用 PostgreSQL service を追加した。
- `.env.example` に `DATABASE_URL` と `POSTGRES_PORT` の例を追加した。
- README に Docker Compose による PostgreSQL 起動と migration 検証手順を追記した。
- 実 DB に対して `make migrate-up`、`make migrate-status`、`make migrate-down`、
  再 `make migrate-up` が成功することを確認した。
- 初期 volume から `docker compose up -d --wait postgres` で PostgreSQL の
  healthcheck 待機後に migration 検証が成功することを確認した。
- migration ファイル内容、backend runtime 実装、IDE 固有ファイルは変更していない。

## 残リスク

- compose の PostgreSQL はローカル開発・migration 検証用であり、本番用途の
  credential や運用設定ではない。
- 検証後の DB volume には migration 適用済み状態が残るため、初期状態から再検証する
  場合は `docker compose down -v` で volume を削除する。
