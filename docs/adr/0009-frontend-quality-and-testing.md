# 0009: frontend quality and testing

## Status

Accepted

## Context

frontend は申請入力、承認、経理確認などの業務画面を提供する。
画面の状態、入力制御、権限別表示、API 連携の品質を保つには、
静的検査、format、component 単位の確認、E2E の確認が必要である。

## Decision

frontend 品質管理には Oxlint、Oxfmt、Storybook、Playwright を利用する。

Nuxt の lint / format は Oxlint と Oxfmt を利用する。
component や画面状態の確認には Storybook を利用し、主要な業務フローの
ブラウザ検証には Playwright を利用する。

Storybook と Playwright の設定本体は後続 issue で作成する。

## Consequences

- 静的検査、format、component 確認、E2E 確認の役割が明確になる。
- UI 状態を Storybook でレビューしやすくなる。
- 申請から承認までの主要フローを Playwright で回帰確認できる。
- 初期 ADR では frontend 実装、Storybook 設定、Playwright 設定は作成しない。
