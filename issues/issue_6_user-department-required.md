# issue 6: user department required

## 目的

OpenAPI の `User.department` が required である契約に合わせ、
DB 上も部署なしユーザーを作成できないようにする。

## 背景

- issue 5 の DB foundation 実装中レビューで、`users.department_id` が nullable かつ
  `ON DELETE SET NULL` になっている指摘を受けた。
- この定義では部署なしユーザーが DB 上成立し、OpenAPI の `User.department` required
  契約と不整合になる。

## 対象範囲

- `users.department_id` の NOT NULL 化
- `users.department_id` の削除時挙動を `ON DELETE RESTRICT` に変更
- sqlc 生成コードの再生成
- issue 5 の検証メモへの追記

## 対象外

- OpenAPI の変更
- frontend の変更
- 認証、CRUD、承認などの business logic

## 実装内容

- `apps/backend/db/migrations/00001_create_foundation_tables.sql` の
  `users.department_id` を `uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT`
  に変更する。
- sqlc を再生成し、`User.DepartmentID` が nullable 型ではなくなることを確認する。

## 受け入れ条件

- `users.department_id` が NOT NULL で作成される。
- 参照中の部署削除は `ON DELETE RESTRICT` により制限される。
- OpenAPI / frontend は変更しない。
- backend build と test が成功する。

## 検証コマンド

- `cd apps/backend && mise exec -- make generate-db`
- `cd apps/backend && mise exec -- make build`
- `cd apps/backend && mise exec -- make clean`
- `test ! -e apps/backend/bin/server`
- `cd apps/backend && mise exec -- go test ./...`
- `git diff --check`

## 完了結果

- `users.department_id` を `uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT`
  に変更した。
- sqlc を再生成し、`User.DepartmentID` が `pgtype.UUID` ではなく `uuid.UUID` として
  生成されることを確認した。
- OpenAPI / frontend は変更していない。
- Markdown lint、backend build、backend test、差分 whitespace check は成功した。
- `make build` が生成した `apps/backend/bin/server` は `make clean` で削除済み。

## 残リスク

- 実 DB への migration 適用確認は `DATABASE_URL` 未設定のため未実施。
