# AGENTS.md

## 基本方針

- 回答は日本語で行う。
- 推測より事実を優先し、不明点は明示する。
- 既存実装と既存規約を尊重し、変更は要求範囲に限定する。
- ユーザーの明示許可なしに commit、push、Pull Request 作成を行わない。
- commit メッセージには英語 prefix を利用し、本文は日本語で記述する。
- Pull Request の本文は日本語で記述し、PR タイトルでも必要に応じて英語 prefix を利用する。

## 行動記録

- リポジトリに対する作業は devlog に記録する。
- 記録には目的、変更内容、検証結果、残作業を含める。
- 個人情報、秘密情報、認証情報、API Key、Token、Password、Credential は記録しない。

## Markdown

- Markdown は `mise.toml` で管理する `markdownlint-cli2` を利用する。
- Markdown を変更した場合は、可能な範囲で `pnpm format:md` と `pnpm lint:md` を実行する。

## repo 専用 skills

- 計画は `.agents/skills/expense-claim-planning/SKILL.md` を参照する。
- 実装は `.agents/skills/expense-claim-implementation/SKILL.md` を参照する。
- 検証は `.agents/skills/expense-claim-verification/SKILL.md` を参照する。
- レビューは `.agents/skills/expense-claim-review/SKILL.md` を参照する。

## issue 管理

- issue ごとの作業内容は `/issues/issue_{no}_{summary}.md` に記録する。
- issue ファイルには目的、背景、対象範囲、実装内容、受け入れ条件、検証コマンド、完了結果を記述する。
- 作業対象外の issue や無関係ファイルは変更しない。
- 実装中に発見したバグ、不具合、想定外の修正は現在の issue に含めない。
- 追加対応が必要な場合は `/issues/issue_{no}_{summary}.md` を別途作成し、
  別 `feature/issue-{no}-{summary}` ブランチ、別 `gwq` worktree で対応する。
- 現在の issue の受け入れ条件を満たすために不可欠なごく小さい修正だけは、
  issue ファイルに理由を明記した上で同一 issue に含めてもよい。

## ADR

- 重要な設計判断は `docs/adr` に ADR として記録する。
- ADR の作成や更新は、対象 issue の範囲に含まれる場合のみ行う。

## フロントエンド実装

- Codex CLI で作業する場合、Nuxt / Nuxt UI 実装時は MCP server の `nuxt` と `nuxt-ui` を優先参照する。
- Nuxt の実装では Nuxt MCP を参照し、公式情報に基づいて判断する。
- Nuxt UI の実装では Nuxt UI MCP を参照し、公式情報に基づいて判断する。
- Nuxt / frontend の lint / format は Oxlint と Oxfmt を利用する。
- `apps/frontend` に対象拡張子のファイルがない場合、frontend lint / format は
  no-op 成功として扱う。
- MCP 設定と参照元 URL は `docs/ai-mcp.md` を確認する。
- VS Code や Cursor など IDE 個別の MCP 設定はユーザー環境で管理し、リポジトリへ保存しない。

## Git 運用

- ブランチ運用は `docs/git-workflow.md` を参照する。
- 開発統合ブランチは `develop` を利用する。
- issue ごとに `feature/issue-{no}-{summary}` 形式のブランチを作成する。
- 作業は `gwq` による worktree 分離を基本とする。
- `develop` へ統合後、リリース可能な状態で `main` へ統合する。
- 破壊的操作、force push、本番 deploy、secret 更新、package publish はユーザーの明示許可なしに行わない。
