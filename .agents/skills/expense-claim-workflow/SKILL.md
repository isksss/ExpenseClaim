---
name: expense-claim-workflow
description: ExpenseClaim の課題や提案から issue ファイル作成、ブランチ作成、計画、実装、検証、レビュー、commit、push、GitHub PR 作成までを統括する。マージは行わない。
---

# expense-claim-workflow

ExpenseClaim の issue 単位作業を最初から Pull Request 作成まで進めるための
統括 skill。

## 役割

- ユーザーから与えられた課題、提案、問題を issue として実装可能な単位へ整理する。
- `issues/issue_{no}_{summary}.md` を作成または更新する。
- `develop` から `feature/issue-{no}-{summary}` ブランチを作成する。
- 既存 skill を順に使い、計画、実装、検証、レビューを分離して実行する。
- `$expense-claim-workflow` の依頼は、commit、feature branch への push、
  `develop` 向け GitHub PR 作成までの明示許可を含むものとして扱う。
- PR 作成後の merge は行わない。
- `main`、`develop` への direct push は行わない。

## 標準手順

1. 前提確認
   - `AGENTS.md`、`AGENTS.local.md` または `.AGENTS.local.md`、対象 issue、
     関連 ADR、既存実装を確認する。
   - `git status --short --branch` で作業ツリーを確認し、無関係変更を壊さない。

2. issue 整理
   - issue 番号が未指定なら `issues/issue_*.md` から次番号を採番する。
   - summary は小文字英数字と `-` を基本にし、ファイル名では `_` 区切りにする。
   - issue ファイルには目的、背景、対象範囲、実装内容、受け入れ条件、
     検証コマンド、完了結果を記述する。
   - 対象外のバグ、不具合、想定外修正は別 issue に切り出す。

3. ブランチ作成
   - `develop` を起点にする。
   - branch 作成は次を基本にする。

   ```sh
   git switch develop
   git switch -c feature/issue-{no}-{summary}
   ```

   - 既に対象ブランチがある場合は再利用可否を確認してから進める。
   - `main`、`develop` 上で直接作業しない。

4. 計画
   - `.agents/skills/expense-claim-planning/SKILL.md` を使う。
   - 実装範囲、対象外、受け入れ条件、検証コマンドを確定する。

5. 実装
   - `.agents/skills/expense-claim-implementation/SKILL.md` を使う。
   - 計画と issue 範囲に限定して変更する。
   - OpenAPI、backend、frontend、DB、infra、docs の責務境界を守る。

6. 検証
   - `.agents/skills/expense-claim-verification/SKILL.md` を使う。
   - 変更範囲に応じて format、lint、test、build、`git diff --check` を実行する。
   - 未実行の検証は理由を issue または最終報告に残す。

7. レビュー
   - `.agents/skills/expense-claim-review/SKILL.md` を使う。
   - バグ、回帰、仕様不整合、テスト不足を重大度順に確認する。
   - 指摘があれば実装へ戻り、再検証する。

8. commit
   - `.agents/skills/expense-claim-commit/SKILL.md` を使う。
   - commit 前に secret、生成物、無関係変更が含まれないことを確認する。

9. push と Pull Request
   - `.agents/skills/expense-claim-create-pr/SKILL.md` を使う。
   - feature branch だけを push し、`main`、`develop` へ direct push しない。
   - GitHub PR は `gh` コマンドで作成し、base branch は `develop` に固定する。
   - PR 作成後も merge は行わない。

## 出力

- issue ファイルの場所。
- 作成または利用したブランチ名。
- 変更内容、検証結果、レビュー結果。
- commit hash と PR URL。
- 残作業、残リスク、追加 issue 候補。
