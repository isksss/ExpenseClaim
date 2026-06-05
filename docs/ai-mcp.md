# AI / MCP 設定

## 目的

フロントエンド実装時に、Nuxt と Nuxt UI の公式情報を AI ツールから参照できるようにする。
これにより、Nuxt の設定、ディレクトリ構成、API、Nuxt UI のコンポーネント利用方法を公式情報に基づいて確認する。

## 参照元 URL

- Nuxt MCP: `https://nuxt.com/mcp`
- Nuxt UI MCP: `https://ui.nuxt.com/mcp`

## 対象 AI ツール

- Codex CLI
- VS Code
- Cursor

## Codex CLI

Codex CLI では、Nuxt / Nuxt UI の MCP server をグローバルな Codex 設定に登録して利用する。
フロントエンド実装時は、Codex CLI で利用できる MCP server の `nuxt` と `nuxt-ui` を優先して参照する。

登録コマンド:

```sh
codex mcp add nuxt --url https://nuxt.com/mcp
codex mcp add nuxt-ui --url https://ui.nuxt.com/mcp
```

確認コマンド:

```sh
codex mcp list
```

`nuxt` と `nuxt-ui` が `enabled` と表示されていれば、Codex CLI から参照できる。

## IDE 個別設定

VS Code や Cursor など IDE 個別の MCP 設定は、各ユーザーのローカル環境に置く。
`.vscode/mcp.json` や `.cursor/mcp.json` はリポジトリでは管理しない。

IDE 側で Nuxt / Nuxt UI MCP を利用する場合は、各 IDE の設定手順に従い、次の URL をユーザー環境へ登録する。

- Nuxt MCP: `https://nuxt.com/mcp`
- Nuxt UI MCP: `https://ui.nuxt.com/mcp`

## 注意点

- フロントエンド実装では、Nuxt と Nuxt UI の判断に MCP の公式情報を優先して参照する。
- Codex CLI で作業する場合は、`nuxt` と `nuxt-ui` の MCP server を優先参照する。
- IDE 個別の MCP 設定はユーザー環境で管理し、リポジトリへ保存しない。
- MCP は参照用の設定であり、この issue では Nuxt アプリ本体や Nuxt UI の導入は行わない。
- MCP server URL を変更する場合は、README、AGENTS、issue ファイルの記述も合わせて確認する。
