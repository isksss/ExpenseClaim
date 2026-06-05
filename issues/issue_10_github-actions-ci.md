# issue 10: github actions ci

## 目的

GitHub Actions CI を初期導入し、PR、`develop`、`main` で lint、
OpenAPI validation、sqlc generate、Go test/build、Nuxt build を自動実行する。

## 背景

- backend、OpenAPI、DB、frontend の最小構成が揃い、変更時に横断的な検証を
  自動化する必要がある。
- CI は初期導入のため、secret、本番接続、deploy、Docker build を含めず、
  既存のローカル検証コマンドを GitHub Actions 上で再現する。

## 対象範囲

- `.github/workflows/ci.yml` の追加
- root `package.json` への OpenAPI validation script 追加
- CI で secret なしに動作する OpenAPI validator の mise tool 追加

## 対象外

- backend 実装コードの変更
- frontend 実装コードの変更
- Dockerfile の追加
- Docker build
- deploy
- 本番環境への接続
- secret を必要とする処理
- IDE 固有ファイル
- commit、push、Pull Request 作成

## 実装内容

- `.github/workflows/ci.yml` を追加し、`pull_request` と `develop` / `main` への
  `push` で CI を実行する。
- CI は `mise exec -- pnpm install --frozen-lockfile` 後に Markdown lint、
  OpenAPI validation、frontend lint/typecheck/build、backend generate/test/build を
  実行する。
- backend build 後に `make clean` を実行し、`apps/backend/bin` を残さない。
- root `package.json` に `lint:openapi` script を追加し、
  `@redocly/cli` で `packages/openapi/openapi.yaml` を検証する。
- `@redocly/cli` は `mise.toml` で管理し、pnpm の lockfile は変更しない。

## 受け入れ条件

- `issues/issue_10_github-actions-ci.md` が存在する。
- `.github/workflows/ci.yml` が存在する。
- root `package.json` に `lint:openapi` script が存在する。
- CI は PR、`develop`、`main` で実行される。
- CI は lint、OpenAPI validation、sqlc generate、Go test/build、Nuxt build を実行する。
- CI は secret、Deploy、Docker build、本番接続を含まない。
- backend build 後に `make clean` を実行し、`apps/backend/bin` を残さない。

## 検証コマンド

```sh
mise exec -- pnpm install
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

## 完了結果

- `.github/workflows/ci.yml` を追加し、`pull_request` と `develop` / `main` への
  `push` で CI を実行するようにした。
- CI は `mise exec -- pnpm install --frozen-lockfile` を実行し、依存関係を
  lockfile 固定で install する。
- CI は Markdown lint、OpenAPI validation、frontend lint/check/build、
  backend OpenAPI codegen、sqlc generate、Go test、Go build を実行する。
- issue 11 で GitHub Actions workflow の厳密な構文検証として `lint:actions` を
  CI と検証コマンドに追加した。
- backend build は `make build && make clean` とし、`apps/backend/bin` を残さない。
- root `package.json` に `lint:openapi` script を追加し、`@redocly/cli` で
  `packages/openapi/openapi.yaml` を検証するようにした。
- `@redocly/cli` を `mise.toml` の `npm:@redocly/cli` tool として追加し、
  pnpm 依存と lockfile に CI validator を混ぜない構成にした。
- backend、frontend の実装コード、Dockerfile、IDE 固有ファイルは変更していない。

## 残リスク

- GitHub Actions 上の実行は未確認。ローカルでは CI 相当の指定コマンドが成功している。
- Nuxt build では依存 package 由来の Rollup PURE コメント警告と Tailwind sourcemap
  警告が出るが、build は成功している。
- Redocly は config 未配置のため built-in recommended configuration で検証している。
