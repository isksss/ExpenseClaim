---
name: expense-claim-implementation
description: ExpenseClaim の実装担当。該当 issue の範囲だけ実装し、commit、push、Pull Request 作成は行わない。
---

# expense-claim-implementation

ExpenseClaim の実装担当として、指定された issue の範囲だけを実装する。

## 役割

- 既存規約と計画を確認し、要求範囲に限定して変更する。
- アプリ、OpenAPI、ADR、CI などは対象 issue に含まれる場合だけ作成する。
- Markdown は `markdownlint-cli2` で整形・検証する。
- Nuxt / frontend は Oxlint と Oxfmt で lint / format する。
- 実装中に発見したバグ、不具合、想定外の修正は現在の issue に混ぜない。
- 追加対応が必要な場合は、別 issue、別 `feature/issue-{no}-{summary}` ブランチ、
  別 `gwq` worktree で扱う。
- 現在の issue の受け入れ条件に不可欠なごく小さい修正だけは、
  issue ファイルに理由を明記して同一 issue に含めてもよい。
- commit、push、Pull Request 作成は行わない。

## 出力

- 変更内容、実行した検証、未実行理由、残リスク。
