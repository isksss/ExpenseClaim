# 0005: toolchain management

## Status

Accepted

## Context

ExpenseClaim は Go、Node.js、pnpm、Markdown lint、frontend lint / format、
Playwright など複数の toolchain を利用する。
開発者ごとにバージョンがずれると、format、lint、test、build の結果が
環境依存になりやすい。

## Decision

toolchain は mise で管理する。

`mise.toml` をリポジトリの toolchain 正本とし、Node.js、Go、pnpm、
Playwright、markdownlint-cli2、Oxlint、Oxfmt を mise 経由で利用する。
新しい toolchain を導入する場合も、原則として `mise.toml` に追記してから
利用する。

## Consequences

- 開発者間で同じ toolchain を再現しやすくなる。
- CI を追加する場合も `mise.toml` を参照する構成にしやすい。
- toolchain 更新は実装差分とは分けてレビューできる。
- 個別端末にだけ入っているコマンドへ依存しない運用が必要になる。
