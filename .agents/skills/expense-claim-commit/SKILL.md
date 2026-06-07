---
name: expense-claim-commit
description: ExpenseClaim の現在差分を確認し、対象変更だけを stage して、repo 規約に沿った英語 prefix 付き日本語 commit を作成する。
---

# expense-claim-commit

ExpenseClaim の Git 差分を安全に commit するための skill。

## 役割

- 現在の作業ツリーを確認し、対象 issue に関係する変更だけを commit する。
- secret、生成物、無関係変更を commit に含めない。
- repo 規約に沿って英語 prefix 付き日本語 commit message を作る。
- commit 後の状態を確認して報告する。
- push、Pull Request 作成、merge は行わない。

## 手順

1. 状態確認
   - `git status --short --branch` を実行する。
   - `git diff --stat` と `git diff --cached --stat` を確認する。
   - 必要に応じて `git diff --name-only` と `git diff --cached --name-only` を確認する。
   - 未追跡ファイルは stage 前に内容と必要性を確認する。

2. 差分確認
   - 対象 issue の範囲に含まれる差分だけを読む。
   - `.env`、秘密情報、認証情報、個人情報、ローカル設定、巨大ファイル、
     キャッシュ、依存ディレクトリ、生成物の混入を確認する。
   - 無関係変更がある場合は stage しない。必要なら残す理由を報告する。

3. 検証確認
   - 変更範囲に応じた format、lint、test、build が済んでいるか確認する。
   - 未実行の検証がある場合は commit 前に実行するか、未実行理由を明確にする。
   - Markdown 変更では可能な範囲で `pnpm format:md` と `pnpm lint:md` を確認する。
   - 最低限 `git diff --check` を確認する。

4. stage
   - `git add .` は原則使わない。
   - 必要なファイルをパス指定で stage する。
   - stage 後に `git diff --cached --stat` と必要な `git diff --cached` を確認する。

5. commit message
   - 1 行目は `prefix: 日本語の要約` 形式にする。
   - prefix は `add`、`fix`、`update`、`remove`、`docs`、`test`、
     `refactor`、`chore`、`perf`、`ci` から選ぶ。
   - 要約は「何をどうしたか」が分かる 40〜60 文字程度を目安にする。
   - 本文には主な変更内容、理由、検証結果を日本語で書く。
   - `Co-authored-by: Copilot` は付けない。

6. commit 実行
   - 選択した message で `git commit` を実行する。
   - Git metadata の書き込みが sandbox で失敗した場合は、承認付きで再実行する。
   - hook 失敗時は内容を確認し、自動修正可能なら修正後に再検証する。

7. 結果確認
   - `git status --short` を実行する。
   - `git log -1 --oneline` を実行する。
   - commit hash、message、残った未 commit 変更を報告する。

## 出力

- commit hash と commit message。
- commit 対象の概要。
- 実行した検証と結果。
- 未 commit 変更がある場合は、その内容と残した理由。
