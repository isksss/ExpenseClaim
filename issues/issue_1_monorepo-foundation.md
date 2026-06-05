# issue 1: monorepo 基盤

## 目的

ExpenseClaim の開発を開始できるように、monorepo の最小基盤を整備する。

## 背景

フロントエンド、バックエンド、OpenAPI、SDK、インフラ設定を
同じリポジトリで管理するため、最初に共通のディレクトリ構成、
ツール管理、workspace 設定、開発ルールを用意する必要がある。

## 対象範囲

- monorepo 基盤
- mise によるツールバージョン管理
- pnpm workspace 設定
- markdownlint-cli2 による Markdown lint / format
- Oxlint / Oxfmt による Nuxt lint / format
- repo 専用 skills
- バグ、不具合、想定外修正の別 issue 運用
- README
- agents 向けルール
- Pull Request テンプレート
- Git ワークフロー文書
- コミットメッセージテンプレート
- Nuxt / Nuxt UI MCP 利用方針
- issue ファイル
- 基本ディレクトリ

対象外:

- アプリケーション実装
- OpenAPI 本体
- ADR 本体
- CI 本体
- Storybook 本体
- テスト本体

## 実装内容

- `README.md` にシステム概要、技術スタック、開発環境、主要コマンド、
  ブランチ運用、issue、ADR、Storybook、テスト方針を記述する。
- `AGENTS.md` に agents 向けルールを記述する。
- `mise.toml` に Node.js、Go、pnpm、Playwright、markdownlint-cli2、
  Oxlint、Oxfmt の管理設定を追加する。
- `pnpm-workspace.yaml` に `apps/*` と `packages/*` を追加する。
- `package.json` に workspace root として最小 scripts を追加し、
  Markdown 用の `format:md` と `lint:md`、frontend 用の
  `format:frontend`、`lint:frontend`、`check:frontend` を追加する。
- `scripts/run-frontend-tool.sh` を追加し、`apps/frontend` に対象拡張子の
  ファイルがない場合は frontend lint / format / check を no-op 成功にする。
- `.gitignore` に Node、Nuxt、Go、test、build、env、uploads 系の
  除外設定を追加する。
- `.github/pull_request_template.md` に日本語テンプレートを追加する。
- `docs/git-workflow.md` に git-flow 参照の運用を記述する。
- `.gitmessage` に英語 prefix と日本語本文の
  コミットメッセージテンプレートを追加する。
- `.github/pull_request_template.md` に PR タイトルや関連コミットで利用する
  英語 prefix 例を HTML コメントで追加する。
- Codex CLI で Nuxt / Nuxt UI MCP server の `nuxt` と `nuxt-ui` を
  参照する手順を README と `docs/ai-mcp.md` に記述する。
- `docs/ai-mcp.md` に Nuxt / Nuxt UI MCP の目的、参照元 URL、
  対象 AI ツール、Codex CLI コマンド、IDE 個別設定を
  リポジトリ管理しない方針、注意点を記述する。
- `.gitignore` に `.vscode/` と `.cursor/` を追加し、
  IDE 個別設定をリポジトリへ保存しない。
- `.agents/skills/` に計画、実装、検証、レビュー担当の
  repo 専用 skill を追加する。
- 実装中に発見したバグ、不具合、想定外の修正は
  `/issues/issue_{no}_{summary}.md` の別 issue、
  別 `feature/issue-{no}-{summary}` ブランチ、別 `gwq` worktree で
  対応する運用を記述する。
- 必要な基本ディレクトリを `.gitkeep` で作成する。

## 受け入れ条件

- 指定されたファイルが作成または更新されている。
- README が日本語で記述され、開発開始に必要な情報を含んでいる。
- `mise.toml` で Node.js 24、Go 1.26、pnpm latest、Playwright latest、
  markdownlint-cli2 latest、Oxlint latest、Oxfmt latest を管理している。
- `pnpm-workspace.yaml` が `apps/*` と `packages/*` を対象にしている。
- `package.json` が private な workspace root になっている。
- `package.json` に Markdown 用の `format:md` と `lint:md` が
  定義されている。
- `package.json` に frontend 用の `format:frontend`、`lint:frontend`、
  `check:frontend` が定義されている。
- 空の `apps/frontend` では frontend scripts が no-op 成功し、
  Nuxt app 実体が追加された後は Oxlint / Oxfmt が実行される。
- `.agents/skills/` 配下に 4 つの repo 専用 skill が作成されている。
- バグ、不具合、想定外の修正を現在の issue に混ぜず、
  別 issue として扱う運用が記述されている。
- `.gitmessage` に英語 prefix と日本語本文の
  コミットメッセージテンプレートが記述されている。
- `docs/git-workflow.md` のコミット規約が英語 prefix に統一されている。
- Codex CLI で Nuxt / Nuxt UI MCP を参照する登録コマンドと
  確認コマンドが記述されている。
- IDE 個別の MCP 設定はユーザー環境で管理し、リポジトリでは
  管理しない方針が記述されている。
- `.vscode/` と `.cursor/` が `.gitignore` で除外されている。
- `docs/ai-mcp.md` に MCP 設定の目的と注意点が日本語で記述されている。
- アプリ実装、OpenAPI 本体、ADR 本体、CI 本体が作成されていない。

## 検証コマンド

```sh
git status --short
find apps packages infra docs issues .github -maxdepth 3 -type f | sort
pnpm format:md
pnpm lint:md
pnpm format:frontend
pnpm lint:frontend
pnpm check:frontend
pnpm format
pnpm check
```

## 完了結果

- monorepo 基盤、mise、pnpm workspace、基本ディレクトリ、README、
  AGENTS、PR テンプレート、Git ワークフロー、issue ファイルを追加した。
- markdownlint-cli2 を mise 管理に追加し、
  Markdown lint / format 用 scripts を追加した。
- Oxlint と Oxfmt を mise 管理に追加し、
  Nuxt / frontend 用 scripts を追加した。
- 空の `apps/frontend` では frontend scripts が no-op 成功するようにした。
- `.agents/skills/` に計画、実装、検証、レビュー担当の
  repo 専用 skill を追加した。
- バグ、不具合、想定外の修正を別 issue、別 `feature/issue-{no}-{summary}`
  ブランチ、別 `gwq` worktree で扱う運用を追記した。
- 英語 prefix と日本語本文を使うコミットメッセージ規約を追加し、
  `.gitmessage` と PR テンプレートに反映した。
- Codex CLI から Nuxt / Nuxt UI MCP を参照するための手順を追加した。
- IDE 個別の MCP 設定はユーザー環境で管理し、リポジトリでは
  管理しない方針へ変更した。
- アプリ実装、OpenAPI 本体、ADR 本体、CI 本体は作成していない。
