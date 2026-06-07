# issue 15: Agent skill workflow 整備

## 目的

ExpenseClaim の repo 専用 skill に、issue 作業の統括、commit、
Pull Request 作成の手順を追加し、AGENTS.md から参照できるようにする。

## 背景

既存の repo 専用 skill は計画、実装、検証、レビューを分離していたが、
ブランチ作成から Pull Request 作成までの一連の作業と、commit / PR 作成時の
安全確認手順が明文化されていなかった。

## 対象範囲

- `.agents/skills/expense-claim-workflow/SKILL.md` の追加
- `.agents/skills/expense-claim-commit/SKILL.md` の追加
- `.agents/skills/expense-claim-create-pr/SKILL.md` の追加
- `AGENTS.md` への参照と標準作業手順の追記

## 対象外

- 既存アプリケーションコードの変更
- CI、OpenAPI、backend、frontend、infra の変更
- Pull Request 作成後の merge

## 実装内容

- 課題整理から Pull Request 作成までを統括する workflow skill を追加する。
- 現在差分を確認し、対象変更だけを stage / commit する commit skill を追加する。
- 現在ブランチを push し、`develop` 向け Pull Request を作成する PR skill を追加する。
- AGENTS.md に repo 専用 skill、開発手法、標準作業手順、領域別検証コマンドを追記する。

## 受け入れ条件

- repo 専用 skill の workflow、commit、PR 作成手順が文書化されている。
- AGENTS.md から追加 skill を参照できる。
- Markdown の format / lint が成功する。
- `git diff --check` が成功する。
- 作業内容が devlog に記録されている。

## 検証コマンド

```sh
pnpm format:md
pnpm lint:md
git diff --check
```

## 完了結果

- `expense-claim-workflow`、`expense-claim-commit`、
  `expense-claim-create-pr` skill を追加した。
- `AGENTS.md` に追加 skill の参照、標準作業手順、領域別検証コマンドを追記した。
- `pnpm format:md`、`pnpm lint:md`、`git diff --check` が成功した。
- Pull Request 作成後の merge は対象外として未実施。
