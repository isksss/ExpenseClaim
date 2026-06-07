---
name: expense-claim-create-pr
description: ExpenseClaim の現在ブランチを push し、gh コマンドで GitHub Pull Request を作成する。PR 作成後の merge は行わない。
---

# expense-claim-create-pr

ExpenseClaim で GitHub Pull Request を作成するための skill。

## 役割

- 現在ブランチから `develop` への GitHub Pull Request を作成する。
- PR 作成には `gh` コマンドを使う。
- PR 本文は日本語で、変更内容と検証結果を明確にする。
- PR 作成後の merge は行わない。

## 手順

1. 前提確認
   - `git branch --show-current` で現在ブランチを確認する。
   - `main`、`master`、`develop` 上では PR 作成を中止する。
   - `git status --short` で未 commit 変更がないことを確認する。
   - 未 commit 変更がある場合は PR 作成を中止し、commit を先に行う。

2. GitHub CLI 確認
   - `command -v gh` で `gh` が利用可能か確認する。
   - `gh auth status` で GitHub 認証状態を確認する。
   - 未認証、権限不足、host 不一致の場合は PR 作成を中止し、結果を報告する。

3. base と commit 確認
   - base branch は原則 `develop` とする。
   - ユーザーが明示した場合のみ base branch を変更する。
   - `git log --oneline origin/develop..HEAD` で PR 対象 commit を確認する。
   - 対象 commit がない場合は PR 作成を中止する。

4. push
   - upstream を確認する。

   ```sh
   git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
   ```

   - upstream がなければ現在ブランチを push する。

   ```sh
   git push -u origin "$(git branch --show-current)"
   ```

   - upstream がある場合も、未 push commit があれば push する。

5. PR title と body
   - title は `add: ...`、`fix: ...`、`docs: ...` など repo 規約の
     prefix 付き日本語要約にする。
   - body は日本語で次を含める。
     - 概要
     - 変更内容
     - 検証結果
     - 関連 issue
     - 残作業または残リスク。なければ `なし`
   - PR template がある場合は、template の項目を優先して埋める。

6. PR 作成
   - `gh pr create` で作成する。

   ```sh
   gh pr create \
     --base develop \
     --head "$(git branch --show-current)" \
     --title "prefix: 日本語の要約" \
     --body "PR本文"
   ```

   - 作成された PR URL を報告する。
   - `gh pr merge` は実行しない。

## 出力

- PR URL。
- base branch と head branch。
- PR title。
- push の有無。
- merge は未実施であること。
