# issue 13: deployment docs

## 目的

ExpenseClaim の deploy 手順をドキュメント化し、現時点で実行できる
リリース判断と deploy 前後の確認観点を明確にする。

## 背景

- issue 10 で CI は導入済みだが、deploy、Docker build、本番接続は対象外としている。
- `develop` から `main` へ統合するブランチ運用はあるが、deploy 前後の確認観点や
  未定事項をまとめた文書がない。
- hosting、production DB、secret 管理は未確定のため、特定環境へ接続する手順ではなく
  現状のリリース判断を文書化する必要がある。

## 対象範囲

- deploy 手順ドキュメントの追加
- README から deploy 手順への導線追加
- issue ファイルへの作業内容記録

## 対象外

- 実環境への deploy
- GitHub Actions deploy job の追加
- Dockerfile または Docker build 設定の追加
- 本番 hosting、production DB、secret 管理の決定
- secret、本番接続情報、credential の追加
- commit、push、Pull Request 作成

## 実装内容

- `docs/deployment.md` を追加し、対象ブランチ、deploy 前チェック、手動リリース判断、
  deploy 後チェック、rollback 方針、未定事項を記述する。
- `README.md` に deploy 方針セクションを追加し、`docs/deployment.md` への導線を
  記述する。
- 実 deploy、CI deploy job、secret、本番接続情報は追加しない。

## 受け入れ条件

- `issues/issue_13_deployment-docs.md` が存在する。
- `docs/deployment.md` が存在する。
- `docs/deployment.md` に deploy 前チェック、手動リリース判断、deploy 後チェック、
  rollback 方針、未定事項が記述されている。
- `README.md` から deploy 手順へ辿れる。
- secret、本番接続情報、deploy job、Docker build 設定が追加されていない。
- Markdown lint が成功する。

## 検証コマンド

```sh
mise exec -- pnpm format:md
mise exec -- pnpm lint:md
git diff --check
```

## 完了結果

- `docs/deployment.md` を追加し、現時点の手動リリース判断と deploy 前後の確認観点を
  記述した。
- `README.md` に deploy 方針セクションを追加し、`docs/deployment.md` への導線を
  追加した。
- 実 deploy、CI deploy job、secret、本番接続情報、Docker build 設定は追加していない。

## 残リスク

- hosting、production DB、secret 管理、artifact 配布、監視、backup は未確定であり、
  実環境向けの具体手順は別 issue で更新する必要がある。
