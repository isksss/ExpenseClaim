# issue 5: database foundation

## 目的

Go backend から利用する PostgreSQL の基礎 schema、migration、sqlc query、
DB 接続 helper を追加する。

## 背景

- issue 4 までで backend skeleton と OpenAPI 生成が追加済み。
- 認証、CRUD、承認、添付保存、監査ログ永続化の実装前に、基礎 table と
  query 生成の土台が必要。

## 対象範囲

- goose migration の追加
- sqlc v2 config の追加
- 基本 query の追加
- `DATABASE_URL` から `pgxpool.Pool` を作る接続 helper の追加
- `mise.toml` と `apps/backend/Makefile` への DB 関連 task 追加

## 対象外

- 認証の business logic
- 経費申請 CRUD の business logic
- 承認状態遷移の business logic
- 添付ファイル保存処理
- 監査ログ永続化処理
- OpenAPI / frontend の変更

## 実装内容

- `departments`, `users`, `expense_requests`, `expense_items`, `attachments`,
  `approvals`, `audit_logs`, `refresh_tokens` table を作成する migration を追加する。
- PostgreSQL の `gen_random_uuid()` を使うため、`pgcrypto` extension を有効化する。
- `expense_request_status` enum は `draft`, `submitted`, `manager_approved`,
  `accounting_approved`, `sent_back`, `rejected`, `canceled` を定義し、
  OpenAPI の `ExpenseClaimStatus` と一致させる。
- `approval_action` enum は `submit`, `approve`, `return`, `reject`, `cancel`
  を定義する。
- `expense_requests.description` を追加し、OpenAPI の申請 description を保存できるようにする。
- `expense_requests` の承認日時は単一の `approved_at` ではなく
  `manager_approved_at` / `accounting_approved_at` を持たせ、
  OpenAPI の `managerApprovedAt` / `accountingApprovedAt` と対応させる。
- `attachments` は申請単位の添付として `expense_request_id` に紐づけ、
  `uploaded_by` でアップロードユーザーを参照する。
- `users.manager_user_id` を自己参照 FK として追加する。
- `refresh_tokens` に有効期限と失効日時の時系列を保証する check 制約を追加する。
- UUID primary key、FK、check 制約、基本 index を追加する。
- `departments.identifier` は unique とし、経理部署判定などに使う安定識別子であることを
  migration comment に記録する。
- `expense_requests.total_amount` と `expense_items.amount` は OpenAPI の JPY integer
  契約に合わせ、`bigint` と正の整数 check 制約で定義する。
- sqlc は v2 config、package `db`、出力先 `internal/generated/db`、
  `pgx/v5` を使う設定とする。
- `internal/db/connection.go` に `context.Context` を受け取り、`DATABASE_URL` から
  `pgxpool.Pool` を作成する helper を追加する。migration 実行機能は持たせない。
- migration 系 Make target は `DATABASE_URL` 未設定時に分かりやすいエラーで失敗する。

## 受け入れ条件

- goose migration で基礎 table、enum、制約、index を作成できる。
- `departments.identifier` が unique で、経理部署判定に使う旨が記録されている。
- 状態遷移の業務制御は DB helper や query に含まれていない。
- sqlc で指定 query の Go code を生成できる。
- backend build と test が成功する。

## 検証コマンド

- `mise install`
- `mise exec -- pnpm format:md`
- `mise exec -- pnpm lint:md`
- `cd apps/backend && mise exec -- make generate-db`
- `cd apps/backend && mise exec -- make build`
- `cd apps/backend && mise exec -- make clean`
- `test ! -e apps/backend/bin/server`
- `cd apps/backend && mise exec -- go test ./...`
- `git diff --check`
- `cd apps/backend && mise exec -- make migrate-status`

## 完了結果

- DB foundation として、goose migration、sqlc 設定、基本 query、
  `pgxpool` 接続 helper を追加した。
- 認証、CRUD、承認、添付保存、監査ログ永続化の business logic は追加していない。
- OpenAPI / frontend は変更していない。
- 最終レビュー指摘対応として、`expense_requests.total_amount` と
  `expense_items.amount` を `numeric(12, 2)` から `bigint` に変更し、
  整数円かつ正の値のみ許容する DB 契約に合わせた。
- レビュー指摘対応として、DB enum、申請 description、申請単位添付、上長 FK、
  Refresh Token 制約、migration target guard を OpenAPI 契約に合わせて修正した。
- 最終レビュー指摘対応として、migration target が `DATABASE_URL` を echo しないように
  recipe echo を抑止し、make 展開ではなく shell 変数を goose に渡すようにした。
- 最終レビュー指摘対応として、`expense_requests.approved_at` を廃止し、
  `manager_approved_at` / `accounting_approved_at` と sqlc query /
  generated model を OpenAPI の承認日時に合わせて更新した。
- 実装中に見つかった不具合として issue 6 を作成し、`users.department_id` を
  `NOT NULL` かつ `ON DELETE RESTRICT` に修正した。これにより OpenAPI の
  `User.department` required 契約と DB 制約を一致させた。
- `DATABASE_URL` が未設定だったため、`make migrate-status` は未実行。
  migration の実 DB 適用確認は接続先設定後に実施する。
- `make build` が生成した `apps/backend/bin/server` は `make clean` で削除できるようにした。
- 検証では `make build` 後に `make clean` を実行し、`apps/backend/bin/server` が
  残らないことを確認する。

## 残リスク

- `Department.isAccounting` は `departments.identifier` から導出する方針だが、
  経理部署 identifier の正本は後続の seed/config issue で明確化する。
- `approvals.action` は今回 `approve` として定義しているが、上長承認と経理承認の
  段階区別は後続の承認実装 issue で `manager_approve` / `accounting_approve` への分割、
  または status snapshot の保存を検討する。
