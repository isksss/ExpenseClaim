# Git ワークフロー

## 基本ブランチ

- `main`: 安定版を管理するブランチ。
- `develop`: 開発統合ブランチ。通常の feature ブランチはここから作成し、
  ここへ戻す。
- `feature/issue-{no}-{summary}`: issue ごとの作業ブランチ。

本リポジトリでは git-flow の考え方を参照し、日常開発は `develop` を
中心に進めます。

## issue ごとの作業

issue ごとに `gwq` を使って worktree を分離します。

```sh
gwq add -b feature/issue-{no}-{summary} develop
```

作業内容は `issues/issue_{no}_{summary}.md` に記録します。

## バグ・不具合の扱い

実装中に発見したバグ、不具合、想定外の修正は、現在の issue に混ぜません。
追加対応が必要な場合は `/issues/issue_{no}_{summary}.md` を別途作成し、
別 `feature/issue-{no}-{summary}` ブランチ、別 `gwq` worktree で対応します。

ただし、現在の issue の受け入れ条件を満たすために不可欠なごく小さい修正は、
issue ファイルに理由を明記した上で同一 issue に含めてもよいです。

## 統合手順

1. `develop` から issue 用の feature ブランチを作成する。
2. issue の対象範囲だけを実装する。
3. 検証結果を issue ファイルまたは Pull Request に記録する。
4. Pull Request を作成し、レビュー後に `develop` へ統合する。
5. `develop` がリリース可能な状態になったら `main` へ統合する。

## コミットメッセージ規約

コミットメッセージには英語 prefix を利用し、本文は日本語で記述します。
repo ルートの `.gitmessage` をテンプレートとして参照できます。

- `fix:` 不具合修正
- `add:` 追加
- `update:` 更新
- `remove:` 削除
- `docs:` ドキュメント変更
- `test:` テスト追加または修正
- `refactor:` 振る舞いを変えない整理
- `chore:` 設定、構成、補助作業

例:

```text
add: monorepo基盤を追加
```

テンプレートを Git に設定する場合:

```sh
git config commit.template .gitmessage
```

PR 本文は日本語で記述し、PR タイトルでも必要に応じて
同じ英語 prefix を利用します。

## 注意事項

- ユーザーの明示許可なしに commit、push、Pull Request 作成を行わない。
- 破壊的操作、force push、本番 deploy、secret 更新、package publish は
  事前に明示許可を得る。
- 無関係なファイル変更を含めない。
- Markdown 変更時は `mise.toml` で管理する `markdownlint-cli2` を使い、
  `pnpm format:md` と `pnpm lint:md` で整形・検証する。
- Nuxt / frontend 変更時は Oxlint と Oxfmt を使い、
  `pnpm format:frontend`、`pnpm lint:frontend`、
  `pnpm check:frontend` で整形・検証する。
- `apps/frontend` が空の場合、frontend の整形・検証は no-op 成功とし、
  Nuxt app 実体が追加された後に Oxlint / Oxfmt を実行する。
