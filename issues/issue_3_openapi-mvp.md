# issue 3: OpenAPI MVP

## 目的

ExpenseClaim の MVP API 契約を OpenAPI 3.1.0 として定義し、後続の
backend、frontend、SDK 実装で参照する正本を用意する。

## 背景

初期 ADR で OpenAPI First、Bearer JWT / Refresh Token、固定承認フロー、
経理権限の部署判定、添付ファイル保存方針が決定済みである。

この issue では実装を増やさず、認証、ユーザー、部署、経費申請、添付、
監査ログの API 形状と主要 schema を先に固定する。

## 対象範囲

- `packages/openapi/openapi.yaml` の作成
- OpenAPI 3.1.0 としての API 契約定義
- 認証、ユーザー、部署、経費申請、添付、監査ログの path 定義
- Bearer JWT と Refresh Token の API 契約定義
- 固定承認フローの operation description / schema description への記述
- 経理権限を role ではなく部署判定で扱うことの description への記述
- PDF / PNG / JPEG 添付の multipart upload、download、delete 定義

対象外:

- backend 実装
- frontend 実装
- 生成コード
- CI 設定
- package scripts の追加・変更
- DB migration
- バグ、不具合、想定外修正

## 実装内容

- `packages/openapi/openapi.yaml` を OpenAPI 3.1.0 として作成する。
- tags として `auth`、`users`、`departments`、`expenseClaims`、
  `attachments`、`auditLogs` を定義する。
- `bearerAuth` を HTTP Bearer JWT の security scheme として定義する。
- `/auth/login` と `/auth/refresh` 以外は Bearer JWT を要求する。
- Refresh Token は `/auth/refresh` の request body で受け取る。
- 指定された path と schema を定義する。
- 社員から課長、経理最終承認までの固定承認フローを API description と
  schema description に記述する。
- 経理権限は role ではなく部署判定で扱うことを schema / description に記述する。
- 添付は PDF / PNG / JPEG の multipart upload と download / delete を定義する。

## 定義対象一覧

endpoint:

- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`
- `GET /users`
- `GET /users/{userId}`
- `GET /departments`
- `GET /departments/{departmentId}`
- `GET /expense-claims`
- `POST /expense-claims`
- `GET /expense-claims/{claimId}`
- `PATCH /expense-claims/{claimId}`
- `DELETE /expense-claims/{claimId}`
- `POST /expense-claims/{claimId}/submit`
- `POST /expense-claims/{claimId}/cancel`
- `POST /expense-claims/{claimId}/manager-approve`
- `POST /expense-claims/{claimId}/accounting-approve`
- `POST /expense-claims/{claimId}/send-back`
- `POST /expense-claims/{claimId}/reject`
- `POST /expense-claims/{claimId}/attachments`
- `GET /expense-claims/{claimId}/attachments/{attachmentId}/download`
- `DELETE /expense-claims/{claimId}/attachments/{attachmentId}`
- `GET /audit-logs`

schema:

- `LoginRequest`
- `TokenPair`
- `RefreshTokenRequest`
- `CurrentUser`
- `User`
- `Department`
- `ExpenseClaim`
- `ExpenseClaimCreateRequest`
- `ExpenseClaimUpdateRequest`
- `ExpenseClaimStatus`
- `ExpenseItem`
- `ExpenseItemInput`
- `ApprovalCommentRequest`
- `ApprovalReasonRequest`
- `Attachment`
- `AuditLog`
- `Pagination`
- `ErrorResponse`
- `ValidationErrorDetail`

## 受け入れ条件

- `issues/issue_3_openapi-mvp.md` が作成されている。
- `packages/openapi/openapi.yaml` が OpenAPI 3.1.0 として作成されている。
- 指定された tags、securitySchemes、paths、schemas が定義されている。
- issue に定義対象の endpoint / schema 一覧が明記され、
  `packages/openapi/openapi.yaml` の paths / components.schemas と一致している。
- `/auth/login` と `/auth/refresh` 以外の operation が Bearer JWT を要求している。
- Refresh Token が `/auth/refresh` の request body で定義されている。
- 主要な status code と error response が定義されている。
- 固定承認フローと経理権限の部署判定が description に明記されている。
- 添付ファイル API が PDF / PNG / JPEG の multipart upload と
  download / delete を定義している。
- backend/frontend 実装、生成コード、CI、package scripts、DB migration が
  作成されていない。

## 検証コマンド

```sh
mise exec -- pnpm format:md
mise exec -- pnpm lint:md
mise exec -- pnpm --package=@redocly/cli dlx redocly lint packages/openapi/openapi.yaml
git diff --check
```

## 完了結果

- `packages/openapi/openapi.yaml` に MVP API 契約を OpenAPI 3.1.0 で作成した。
- 認証、ユーザー、部署、経費申請、添付、監査ログの指定 path と schema を定義した。
- Bearer JWT、Refresh Token body、固定承認フロー、経理権限の部署判定、
  PDF / PNG / JPEG 添付を API 契約に反映した。
- backend/frontend 実装、生成コード、CI、package scripts、DB migration は
  作成していない。
- バグ、不具合、想定外修正は現在の issue に混ぜず、別 issue、
  別 `feature/issue-{no}-{summary}` ブランチ、別 `gwq` worktree で扱う。
