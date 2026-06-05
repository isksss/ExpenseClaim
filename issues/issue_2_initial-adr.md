# issue 2: initial ADR

## 目的

ExpenseClaim の初期設計判断を ADR として記録し、以後の OpenAPI、
backend、frontend、DB、品質管理の実装方針をそろえる。

## 背景

monorepo 基盤は整備済みだが、実装前に主要な設計判断を明文化しておかないと、
API 契約、認証、承認フロー、権限、ツールチェーン、品質基準が
実装ごとにばらつくリスクがある。

この issue では初期 ADR を作成し、後続 issue が参照できる判断の基準を用意する。

## 対象範囲

- 初期 ADR 11 本の作成
- OpenAPI First 方針
- Bearer JWT / Refresh Token 方針
- Echo + oapi-codegen 方針
- pgx + sqlc + goose 方針
- mise による toolchain 管理方針
- 固定承認フロー
- 経理権限の部署判定方針
- 添付ファイルのローカル volume 保存方針
- Storybook / Playwright を含む frontend 品質方針
- 初期アーキテクチャ境界
- repository 品質ルール
- バグ、不具合、想定外修正の別 issue 運用

対象外:

- OpenAPI 本体の作成
- backend 実装
- frontend 実装
- DB migration
- CI 設定
- Storybook 設定
- Playwright 設定

## 実装内容

- `docs/adr/0001-openapi-first.md` を作成し、OpenAPI First 方針を記録する。
- `docs/adr/0002-authentication-token-policy.md` を作成し、
  Bearer JWT / Refresh Token 方針を記録する。
- `docs/adr/0003-backend-framework-and-code-generation.md` を作成し、
  Echo + oapi-codegen 方針を記録する。
- `docs/adr/0004-database-migration-and-query-generation.md` を作成し、
  pgx + sqlc + goose 方針を記録する。
- `docs/adr/0005-toolchain-management.md` を作成し、
  mise による toolchain 管理方針を記録する。
- `docs/adr/0006-approval-workflow.md` を作成し、
  社員から課長、経理最終承認までの固定承認フローを記録する。
- `docs/adr/0007-accounting-permission-model.md` を作成し、
  経理権限を部署判定で扱う方針を記録する。
- `docs/adr/0008-attachment-storage.md` を作成し、
  添付ファイルをローカル volume に保存する方針を記録する。
- `docs/adr/0009-frontend-quality-and-testing.md` を作成し、
  Storybook、Playwright、Oxlint、Oxfmt を使う品質方針を記録する。
- `docs/adr/0010-initial-architecture-boundaries.md` を作成し、
  初期アーキテクチャ境界を記録する。
- `docs/adr/0011-repository-quality-rules.md` を作成し、
  Markdown lint、IDE 設定、別 issue 運用を含む品質ルールを記録する。

## 受け入れ条件

- `issues/issue_2_initial-adr.md` が作成されている。
- `docs/adr/` 配下に指定された ADR 11 本が作成されている。
- 各 ADR が日本語で記述されている。
- 各 ADR に `Status`、`Context`、`Decision`、`Consequences` が含まれている。
- ADR に指定された初期方針が含まれている。
- OpenAPI 本体、backend/frontend 実装、DB migration、CI、
  Storybook / Playwright 設定が作成されていない。
- バグ、不具合、想定外修正を別 issue として扱う運用が記述されている。

## 検証コマンド

```sh
pnpm format:md
pnpm lint:md
find docs/adr -maxdepth 1 -type f | sort
find issues -maxdepth 1 -type f | sort
git diff --check
```

## 完了結果

- 初期 ADR 11 本を作成した。
- issue 2 の目的、背景、対象範囲、実装内容、受け入れ条件、
  検証コマンド、完了結果を記録した。
- OpenAPI 本体、backend/frontend 実装、DB migration、CI、
  Storybook / Playwright 設定は作成していない。
- 実装中に発見したバグ、不具合、想定外修正は現在の issue に混ぜず、
  別 issue、別 `feature/issue-{no}-{summary}` ブランチ、別 `gwq`
  worktree で扱う。
