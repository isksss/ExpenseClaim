# issue 11: actionlint ci workflow validation

## 目的

GitHub Actions workflow YAML を `actionlint` で厳密に検証し、workflow typo による
CI 事故を早期に検出できるようにする。

## 背景

- issue 10 で GitHub Actions CI を追加した。
- workflow YAML の確認が静的な目視確認に寄っており、GitHub Actions 固有の構文や
  typo をローカルと CI で検出する仕組みが不足していた。

## 対象範囲

- `mise.toml` への `actionlint` 追加
- root `package.json` への `lint:actions` script 追加
- `.github/workflows/ci.yml` への `lint:actions` step 追加
- issue 10 の検証コマンドと完了結果への `lint:actions` 追記

## 対象外

- backend 実装コードの変更
- frontend 実装コードの変更
- Docker build
- deploy
- secret を必要とする処理
- commit、push、Pull Request 作成

## 実装内容

- `mise.toml` に `actionlint` を追加し、mise 経由で実行できるようにする。
- root `package.json` に `lint:actions` script を追加し、`actionlint` の標準探索で
  `.github/workflows` 配下を検証する。
- `.github/workflows/ci.yml` に `Lint GitHub Actions workflows` step を追加し、
  CI 上でも `mise exec -- pnpm lint:actions` を実行する。
- `issues/issue_10_github-actions-ci.md` の検証コマンドと完了結果に
  `lint:actions` を追記する。

## 受け入れ条件

- `issues/issue_11_actionlint-ci-workflow-validation.md` が存在する。
- `mise.toml` に `actionlint` が存在する。
- root `package.json` に `lint:actions` script が存在する。
- CI で `lint:actions` step が実行される。
- issue 10 の完了結果と検証コマンドに `lint:actions` が記録されている。

## 検証コマンド

```sh
mise exec -- pnpm lint:actions
mise exec -- pnpm lint:md
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

- `mise.toml` に `actionlint` を追加し、mise 経由で実行できるようにした。
- root `package.json` に `lint:actions` script を追加し、`actionlint` の標準探索で
  `.github/workflows` 配下を検証するようにした。
- `.github/workflows/ci.yml` に `Lint GitHub Actions workflows` step を追加し、
  CI 上でも workflow YAML を検証するようにした。
- `issues/issue_10_github-actions-ci.md` の検証コマンドと完了結果に
  `lint:actions` を追記した。
- backend、frontend の実装コード、Dockerfile、deploy、secret 関連は変更していない。

## 残リスク

- GitHub Actions 上の実行は未確認。
- Nuxt build では依存 package 由来の Rollup PURE コメント警告と Tailwind sourcemap
  警告が出るが、build は成功している。
