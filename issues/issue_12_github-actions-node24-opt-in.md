# issue 12: github actions node24 opt in

## 目的

GitHub Actions の JavaScript action 実行環境を Node.js 24 に opt-in し、
Node.js 20 actions deprecation warning を解消する。

## 背景

- issue 10 の CI を GitHub Actions 上で実行したところ、`actions/checkout@v4` と
  `jdx/mise-action@v2` が Node.js 20 action として実行される warning が出た。
- GitHub Actions は 2026 年に Node.js 24 へ既定を移行するため、初期 CI の時点で
  opt-in しておく。

## 対象範囲

- `.github/workflows/ci.yml` に `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` を設定する。

## 対象外

- CI job の追加
- Deploy
- Docker build
- backend / frontend 実装コードの変更
- secret を必要とする処理

## 実装内容

- workflow 全体の `env` に `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: "true"` を追加する。

## 受け入れ条件

- `issues/issue_12_github-actions-node24-opt-in.md` が存在する。
- `.github/workflows/ci.yml` に Node.js 24 opt-in env が存在する。
- `actionlint` が成功する。
- GitHub Actions CI が成功する。

## 検証コマンド

```sh
mise exec -- pnpm lint:actions
mise exec -- pnpm lint:md
git diff --check
```

## 完了結果

- `.github/workflows/ci.yml` に `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: "true"` を追加した。

## 残リスク

- GitHub Actions 上での annotation 解消は PR CI 再実行で確認する。
