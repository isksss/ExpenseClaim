# issue 19: workflow strict PR

## 目的

ExpenseClaim の開発手順を厳格化し、`$expense-claim-workflow` 依頼時に
issue 作成、ブランチ作成、実装、commit、push、`develop` 向け Pull Request
作成までを一貫して行う。

## 背景

従来の repo ルールでは commit、push、Pull Request 作成が「ユーザー明示時のみ」
として記述されており、`$expense-claim-workflow` の依頼時にどこまで実施するかが
曖昧だった。

また、個人ローカルの作業記録はユーザー環境で管理するものであり、リポジトリ正本の
開発手順として管理しない。

## 対象範囲

- `AGENTS.md` の標準作業手順更新
- `.agents/skills/expense-claim-workflow/SKILL.md` の workflow ルール更新
- `docs/git-workflow.md` と関連 skill / ADR の branch 運用記述更新
- workflow 呼び出し時の commit、feature branch push、`develop` 向け PR 作成の明確化
- `main`、`develop` への direct push 禁止の明記
- repo 正本から個人ローカル作業記録への記載義務を削除
- worktree 分離を必須とする記述の削除

## 対象外

- 既存 issue ファイルに残る過去の個人ローカル作業記録に関する記載の変更
- Pull Request 作成後の merge
- `main`、`develop` への direct push

## 実装内容

- `$expense-claim-workflow` の依頼自体を、commit、feature branch push、
  `develop` 向け Pull Request 作成までの明示許可として扱う。
- workflow の branch 起点と PR base を `develop` に固定する。
- `main`、`develop` への direct push を禁止する。
- worktree 分離を必須とせず、通常の feature branch 作成を基本とする。
- 作業内容、検証結果、残作業の記録先を issue ファイルに限定する。

## 受け入れ条件

- `$expense-claim-workflow` の手順が issue 作成から `develop` 向け PR 作成まで
  一貫している。
- workflow が `develop` 起点の feature branch 作成を前提としている。
- `main`、`develop` への direct push 禁止が明記されている。
- repo 正本から個人ローカル作業記録への記載義務が削除されている。
- worktree 分離を必須とする記述が正本から削除されている。
- 既存 issue ファイルの過去記録は変更していない。

## 検証コマンド

```sh
pnpm format:md
pnpm lint:md
git diff --check
```

## 完了結果

- `AGENTS.md`、repo 専用 workflow / implementation skill、`docs/git-workflow.md`、
  ADR の開発手順を更新した。
- `$expense-claim-workflow` 依頼時は issue 作成から commit、feature branch push、
  `develop` 向け Pull Request 作成まで一貫して行うルールにした。
- `main`、`develop` への direct push 禁止を明記した。
- 個人ローカル作業記録への記載義務を repo 正本から削除した。
- worktree 分離を必須とする記述を repo 正本から削除した。
- 検証:
  - `pnpm format:md`
  - `pnpm lint:md`
  - `git diff --check`
