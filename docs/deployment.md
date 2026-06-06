# Deploy 手順

## 目的

ExpenseClaim の deploy は、`develop` で検証済みの変更を `main` へ統合し、
リリース可能な状態として扱う手動手順を基本にする。

現時点では本番 hosting、DB、secret 管理、artifact 配布、監視、backup の
方式が未確定である。そのため、この文書では特定の cloud や production
environment に接続する手順は定義しない。

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

## 手動リリース判断

以下のいずれかが未確定の場合、実環境への deploy は実行しない。

- hosting 先
- production DB
- secret 管理
- migration 実行手順
- rollback 手順
- 監視、log、backup の確認方法

未確定事項が残っている場合は、`develop` から `main` への統合までを
リリース可能状態の作成として扱い、実 deploy は別 issue で扱う。

## Deploy 後チェック

実環境の deploy 手順が確定した後は、deploy 後に次を確認する。

- frontend が起動し、主要画面へアクセスできる。
- backend API が起動し、health check または主要 endpoint が応答する。
- DB migration の適用状態が期待どおりである。
- application log に起動直後の error が出ていない。
- 監視、alert、backup が期待どおりに動作している。

## Rollback 方針

rollback は、直前に安定していた `main` の commit または release tag へ戻す
ことを基本方針にする。具体的な command、artifact、DB rollback 可否は
hosting 先と production DB の方式が決まった時点でこの文書に追記する。

DB migration を含む release では、schema の後方互換性と rollback 可否を
deploy 前に確認する。不可逆 migration を含む場合は、別途 rollback 不可の
判断理由と復旧手順を issue または ADR に残す。

## 未定事項

- 本番 hosting 先
- production DB
- secret 管理
- artifact 作成と配布方法
- migration 実行責任者と実行場所
- 監視、alert、log 保存先
- backup と restore 手順
