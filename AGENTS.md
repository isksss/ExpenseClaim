# AGENTS.md

## 基本方針

- 回答は日本語で行う。
- 推測より事実を優先し、不明点は明示する。
- 既存実装と既存規約を尊重し、変更は要求範囲に限定する。
- ユーザーの明示許可なしに commit、push、Pull Request 作成を行わない。
  ただし `$expense-claim-workflow` を明示して依頼された場合は、
  issue 作成から commit、feature branch への push、`develop` 向け
  Pull Request 作成までの許可を含むものとして扱う。
- commit メッセージには英語 prefix を利用し、本文は日本語で記述する。
- Pull Request の本文は日本語で記述し、PR タイトルでも必要に応じて英語 prefix を利用する。
- `main`、`develop` への direct push は行わない。

## Markdown

- Markdown は `mise.toml` で管理する `markdownlint-cli2` を利用する。
- Markdown を変更した場合は、可能な範囲で `pnpm format:md` と `pnpm lint:md` を実行する。

## repo 専用 skills

- 課題から PR 作成までの統括は `.agents/skills/expense-claim-workflow/SKILL.md` を参照する。
- 計画は `.agents/skills/expense-claim-planning/SKILL.md` を参照する。
- 実装は `.agents/skills/expense-claim-implementation/SKILL.md` を参照する。
- 検証は `.agents/skills/expense-claim-verification/SKILL.md` を参照する。
- レビューは `.agents/skills/expense-claim-review/SKILL.md` を参照する。
- commit は `.agents/skills/expense-claim-commit/SKILL.md` を参照する。
- GitHub Pull Request 作成は `.agents/skills/expense-claim-create-pr/SKILL.md` を参照する。

## issue 管理

- issue ごとの作業内容は `/issues/issue_{no}_{summary}.md` に記録する。
- issue ファイルには目的、背景、対象範囲、実装内容、受け入れ条件、検証コマンド、完了結果を記述する。
- 作業対象外の issue や無関係ファイルは変更しない。
- 実装中に発見したバグ、不具合、想定外の修正は現在の issue に含めない。
- 追加対応が必要な場合は `/issues/issue_{no}_{summary}.md` を別途作成し、
  別 `feature/issue-{no}-{summary}` ブランチで対応する。
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

## 開発手法

- 開発は issue 単位で行い、課題整理、計画、実装、検証、レビューを分離する。
- OpenAPI は API 契約の正本とし、frontend と backend は OpenAPI 経由で接続する。
- backend は認証、権限判定、業務ルール、永続化、添付ファイル管理を担当する。
- frontend は画面、入力、表示状態、API client 利用を担当する。
- DB schema と migration は backend の永続化境界として扱う。
- docs は設計判断、運用、開発手順を管理する。
- infra は実行環境、永続 volume、nginx などの構成を管理する。
- 境界を越える変更が必要な場合は、対象 issue の範囲と ADR 更新要否を先に確認する。

## 標準作業手順

1. 課題、提案、問題を読み、対象範囲と受け入れ条件を整理する。
2. `issues/issue_{no}_{summary}.md` を作成または更新する。
3. `develop` から `feature/issue-{no}-{summary}` ブランチを作成する。
4. 計画 skill で実装方針、対象外、検証コマンドを決める。
5. 実装 skill で issue 範囲に限定して変更する。
6. 検証 skill で format、lint、test、build、`git diff --check` を確認する。
7. レビュー skill で差分を確認し、必要なら実装と検証へ戻る。
8. `$expense-claim-workflow` では commit skill で commit する。
   単独作業では、ユーザーが明示した場合のみ commit する。
9. `$expense-claim-workflow` では feature branch を push し、
   `develop` 向けに `gh pr create` で GitHub Pull Request を作成する。
   単独作業では、ユーザーが明示した場合のみ push と Pull Request 作成を行う。

- Pull Request 作成後の merge は行わない。
- `main`、`develop` への direct push は行わない。
- 作業内容、検証結果、残作業は issue ファイルに記録する。

## ディレクトリ構成

- `apps/frontend`: Nuxt、Nuxt UI、Pinia、Storybook による frontend。
- `apps/backend`: Go、Echo、sqlc、oapi-codegen、goose による backend。
- `packages/openapi`: OpenAPI 仕様の正本。
- `packages/sdk`: 生成 SDK 置き場。
- `docs/adr`: 重要な設計判断を記録する ADR。
- `docs/screens`: 画面仕様、画面メモ。
- `issues`: issue ごとの作業記録。
- `infra`: Docker、nginx などの実行環境構成。
- `scripts`: repository 共通の補助 script。
- `.agents/skills`: repo 専用 Codex skill。

## 言語・領域別規約

### Markdown ファイル

- Markdown は `markdownlint-cli2` を利用する。
- Markdown を変更した場合は、可能な範囲で次を実行する。

```sh
pnpm format:md
pnpm lint:md
```

### TypeScript / Vue / Nuxt

- frontend は `apps/frontend` に配置する。
- Nuxt / frontend の lint / format は Oxlint と Oxfmt を利用する。
- 型確認は Nuxt typecheck を利用する。
- frontend を変更した場合は、変更範囲に応じて次を実行する。

```sh
pnpm format:frontend
pnpm lint:frontend
pnpm check:frontend
pnpm --filter frontend build
```

- OpenAPI から frontend 型を更新する場合は次を実行する。

```sh
pnpm --filter frontend generate:api-types
```

### Go

- backend は `apps/backend` に配置する。
- Go コードは `gofmt` で整形する。
- backend を変更した場合は、変更範囲に応じて `apps/backend` で次を実行する。

```sh
gofmt -w <changed-go-files>
go test ./...
go build ./cmd/server
```

- OpenAPI から backend server code を更新する場合は次を実行する。

```sh
cd apps/backend
make generate
```

### SQL / Migration

- migration は `apps/backend/db/migrations` に配置する。
- sqlc query は `apps/backend/db/queries` に配置する。
- DB 生成コードを更新する場合は次を実行する。

```sh
cd apps/backend
make generate-db
```

- migration 実行には `DATABASE_URL` が必要。必要な場合だけ次を実行する。

```sh
cd apps/backend
make migrate-up
make migrate-status
```

### OpenAPI

- OpenAPI 仕様は `packages/openapi/openapi.yaml` を正本とする。
- OpenAPI を変更した場合は次を実行する。

```sh
pnpm lint:openapi
cd apps/backend
make generate
pnpm --filter frontend generate:api-types
```

### GitHub Actions

- GitHub Actions workflow を変更した場合は次を実行する。

```sh
pnpm lint:actions
```

### 全体確認

- 複数領域にまたがる変更では、可能な範囲で次を実行する。

```sh
pnpm format
pnpm check
pnpm test
pnpm build
```

## Git 運用

- ブランチ運用は `docs/git-workflow.md` を参照する。
- 開発統合ブランチは `develop` を利用する。
- issue ごとに `feature/issue-{no}-{summary}` 形式のブランチを作成する。
- `develop` へ統合後、リリース可能な状態で `main` へ統合する。
- GitHub Pull Request は `gh pr create` で作成する。
- Pull Request 作成後の merge は行わない。
- 破壊的操作、force push、本番 deploy、secret 更新、package publish はユーザーの明示許可なしに行わない。
