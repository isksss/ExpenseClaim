# issue 4: backend skeleton

## 目的

OpenAPI First の契約に従い、Go / Echo / oapi-codegen を利用した backend の
最小 skeleton を作成する。

## 背景

- ADR 0003 で backend framework は Echo、code generation は oapi-codegen を採用している。
- `packages/openapi/openapi.yaml` を契約の正本として、server interface と models を生成する必要がある。

## 対象範囲

- `apps/backend` の Go module 作成
- Echo server skeleton 作成
- `packages/openapi/openapi.yaml` から Echo server と models を生成する設定作成
- 生成コードを `apps/backend/internal/generated/openapi` 配下に配置
- 生成 interface を満たす stub handler 作成
- `mise.toml` への oapi-codegen tool 追加
- `apps/backend/Makefile` 作成

## 対象外

- 実ビジネスロジック
- 認証実装
- DB / sqlc / migration
- CRUD 実装
- 添付保存
- 監査ログ永続化

## 実装内容

- `github.com/isksss/ExpenseClaim/apps/backend` を module path とする Go module を作成する。
- `cmd/server/main.go` は `PORT` を参照し、未設定時は `8080` で Echo server を起動する。
- `internal/server/server.go` は Echo instance を作成し、生成コードの
  `RegisterHandlers` で stub handler を登録する。
- `internal/handler/stub.go` は生成 interface の全 endpoint を実装し、
  501 Not Implemented の JSON を返す。
- `oapi-codegen.yaml` と `Makefile` で OpenAPI から生成コードを再生成できるようにする。

## 受け入れ条件

- `apps/backend/internal/generated/openapi/server.gen.go` に直接編集禁止の生成コメントがある。
- 生成コードは `packages/openapi/openapi.yaml` から Echo server と models を生成している。
- stub handler が生成 interface を満たし、全 endpoint が 501 Not Implemented JSON を返す。
- `cmd/server/main.go` は env `PORT` を見て、未設定なら `8080` で起動する。
- server は Echo instance を作り、生成 `RegisterHandlers` で stub を登録する。

## 検証コマンド

- `mise install`
- `mise exec -- pnpm format:md`
- `mise exec -- pnpm lint:md`
- `cd apps/backend && mise exec -- make generate`
- `cd apps/backend && mise exec -- make build`
- `cd apps/backend && mise exec -- go test ./...`
- `git diff --check`

## 完了結果

- backend Go module、Echo server skeleton、oapi-codegen 設定、生成コード、stub handler を追加した。
- oapi-codegen 2.7.0 は OpenAPI 3.1 の `type: [string|object, "null"]` を直接生成できないため、
  `Makefile` の生成時だけ一時 spec を OpenAPI 3.0 nullable 形式へ変換している。
  `packages/openapi/openapi.yaml` は変更していない。
- `make build` は `./bin/server` に server binary を出力し、`apps/backend/server` は生成しない。
- 指定された検証コマンドはすべて成功した。
