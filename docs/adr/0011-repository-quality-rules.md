# 0011: repository quality rules

## Status

Accepted

## Context

monorepo では Markdown、frontend、backend、docs、issue、ADR など
種類の異なる成果物を同じ履歴で管理する。品質ルールが曖昧だと、
format 差分、IDE 個別設定、対象外修正、想定外のバグ修正が混ざりやすい。

実装前に repository 全体の基本ルールを明文化する必要がある。

## Decision

repository 品質ルールを以下のように定義する。

- Markdown lint / format は markdownlint-cli2 を利用する。
- Markdown を変更した場合は、可能な範囲で `pnpm format:md` と
  `pnpm lint:md` を実行する。
- Nuxt / frontend の lint / format は Oxlint と Oxfmt を利用する。
- IDE 個別設定はユーザー環境で管理し、Git 管理しない。
- issue の対象外ファイルは変更しない。
- 実装中に発見したバグ、不具合、想定外修正は現在の issue に混ぜない。
- 追加対応が必要な場合は、別 issue、別 `feature/issue-{no}-{summary}`
  ブランチで扱う。

## Consequences

- 文書と frontend の品質確認コマンドが明確になる。
- IDE 依存の設定差分が repository に混ざりにくくなる。
- issue の責務境界が保たれ、レビュー範囲を絞りやすくなる。
- 現在の issue の受け入れ条件に不可欠な修正かどうかを判断し、
  迷う場合は別 issue として扱う必要がある。
