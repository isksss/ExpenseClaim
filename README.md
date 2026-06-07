# ExpenseClaim

ExpenseClaim は、経費申請と承認の業務を扱うためのシステムです。
このリポジトリでは、フロントエンド、バックエンド、OpenAPI 定義、SDK、
インフラ設定を monorepo として管理します。

## 技術スタック

- フロントエンド: Nuxt を想定し、`apps/frontend` に配置する。
- バックエンド: Go を想定し、`apps/backend` に配置する。
- API 契約: OpenAPI を `packages/openapi` に配置する。
- SDK: 生成または手書き SDK を `packages/sdk` に配置する。
- パッケージ管理: pnpm workspace を利用する。
- ツールバージョン管理: mise を利用する。
- E2E: Playwright を利用する。

## 開発環境

必要なツールは `mise.toml` で管理します。

```sh
mise install
pnpm install
```

管理対象の主要ツールは次のとおりです。

- Node.js 24
- Go 1.26
- pnpm latest
- Playwright latest
- markdownlint-cli2 latest
- Oxlint latest
- Oxfmt latest

## AI / MCP

フロントエンド実装では、Nuxt と Nuxt UI の MCP を参照して
公式情報に基づく実装を行います。
MCP の設定と利用方針は `docs/ai-mcp.md` を参照します。

- Nuxt MCP: `https://nuxt.com/mcp`
- Nuxt UI MCP: `https://ui.nuxt.com/mcp`

Codex CLI では次のコマンドで MCP server を登録します。

```sh
codex mcp add nuxt --url https://nuxt.com/mcp
codex mcp add nuxt-ui --url https://ui.nuxt.com/mcp
```

設定状態は次のコマンドで確認します。

```sh
codex mcp list
```

`nuxt` と `nuxt-ui` が `enabled` と表示されていれば利用可能です。
VS Code や Cursor など IDE 個別の MCP 設定はユーザー環境に置き、
リポジトリでは管理しません。

## ディレクトリ構成

```text
apps/
  frontend/
  backend/
packages/
  openapi/
  sdk/
infra/
  docker/
  nginx/
docs/
  adr/
  screens/
issues/
.agents/
  skills/
```

## 主要コマンド

root の npm scripts は workspace 配下の実装へ委譲します。

```sh
pnpm format
pnpm format:md
pnpm format:frontend
pnpm check
pnpm lint:md
pnpm lint:frontend
pnpm check:frontend
pnpm test
pnpm build
pnpm storybook
pnpm playwright
```

現時点では monorepo 基盤のみを作成しているため、各 workspace に実体が
追加されたあとに実行可能になります。
Markdown は `mise.toml` で管理する `markdownlint-cli2` を使い、
`pnpm format:md` と `pnpm lint:md` で整形・検証します。
Nuxt / frontend は Oxlint と Oxfmt を使い、`pnpm format:frontend`、
`pnpm lint:frontend`、`pnpm check:frontend` で整形・検証します。
対象拡張子のファイルがない空の `apps/frontend` では no-op 成功になり、
Nuxt app 実体が追加された後は Oxlint / Oxfmt が実行されます。

## ローカル PostgreSQL と migration 検証

ローカル開発用 PostgreSQL は Docker Compose で起動します。設定値は開発用の
固定値であり、secret ではありません。接続文字列の例は `.env.example` を参照します。

```sh
docker compose up -d --wait postgres
docker compose ps postgres
```

goose migration は `apps/backend` の Make target で実行します。

```sh
export DATABASE_URL='postgres://expenseclaim:expenseclaim@localhost:5432/expenseclaim?sslmode=disable'
cd apps/backend
mise exec -- make migrate-up
mise exec -- make migrate-status
mise exec -- make migrate-down
mise exec -- make migrate-up
```

検証後に DB を止める場合は次を実行します。

```sh
docker compose down
```

初期状態から migration を再検証する場合は、volume も削除します。

```sh
docker compose down -v
```

## Codex skills

repo 専用 skill は `.agents/skills/` に配置します。

- `expense-claim-planning`: issue 分割、ADR、OpenAPI、画面、テスト計画、
  受け入れ条件を決める。
- `expense-claim-implementation`: 該当 issue の範囲だけ実装する。
- `expense-claim-verification`: format、lint、test、build、受け入れ条件を
  確認する。
- `expense-claim-review`: 差分をレビューし、重大度順に指摘する。

## ブランチ運用

ブランチ運用は `docs/git-workflow.md` を参照します。

- `main` は安定版を管理する。
- `develop` は開発統合ブランチとして利用する。
- issue ごとに `feature/issue-{no}-{summary}` 形式のブランチを作成する。
- 作業は `gwq` による issue ごとの worktree 分離を基本とする。
- `develop` へ統合後、リリース可能な状態で `main` へ統合する。
- コミットメッセージは英語 prefix と日本語本文で記述する。
  詳細は `.gitmessage` と `docs/git-workflow.md` を参照する。

## Deploy 方針

deploy 手順とリリース前後の確認観点は `docs/deployment.md` を参照します。
Docker Compose で frontend、backend、PostgreSQL を起動する構成と、
Cloudflare Tunnel で `claim.isksss.dev` と `claim-api.isksss.dev` へ公開する
手順を管理します。VPS 上の secret は `.env` で管理し、リポジトリには保存しません。

## issue 管理

issue ごとの作業内容は `issues/issue_{no}_{summary}.md` に記録します。
各 issue ファイルには、目的、背景、対象範囲、実装内容、受け入れ条件、
検証コマンド、完了結果を記述します。
実装中に見つけたバグ、不具合、想定外の修正は原則として別 issue、
別ブランチ、別 `gwq` worktree で対応します。

## ADR 方針

重要な設計判断は `docs/adr` に ADR として記録します。
この issue では ADR 本体は作成せず、保存先ディレクトリのみ用意します。

## Storybook 方針

UI コンポーネントを追加する場合は Storybook で確認できる状態を目指します。
この issue では Storybook 本体や設定は作成せず、将来の実装で workspace 側に追加します。

## テスト方針

- フロントエンド、バックエンド、SDK それぞれの単体テストを
  workspace 配下で管理する。
- API 契約に関わる変更は OpenAPI と実装の整合性を確認する。
- 主要なユーザーフローは Playwright による E2E テストで確認する。
- root の `pnpm test` と `pnpm playwright` は各 workspace の
  テスト実装へ委譲する。
