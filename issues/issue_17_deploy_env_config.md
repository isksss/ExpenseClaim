# issue 17: deploy env config

## 目的

local から VPS へ deploy する際の SSH 接続先情報を `.env` で管理できるようにする。

## 背景

- issue 16 で `scripts/deploy-vps.sh` を追加し、環境変数で deploy 先を指定できるようにした。
- compose 用の設定や VPS 側 secret は `.env` で管理しているため、deploy 接続情報も
  `.env` に寄せて管理方法を揃える。
- `.env` を shell として読み込むと placeholder や secret 文字列が shell 構文として
  解釈される可能性があるため、script 側では必要な key だけを読み取る。

## 対象範囲

- `scripts/deploy-vps.sh` の deploy 接続情報読み取り方法変更
- `.env.example` への deploy 接続情報例追加
- deploy 手順ドキュメントの更新
- issue ファイルと devlog への作業内容記録

## 対象外

- 実 VPS への deploy 実行
- secret、本番接続情報、`.env` の追加
- `DEPLOY_REMOTE_DIR`、`DEPLOY_COMPOSE` の仕様変更
- commit、push、Pull Request 作成

## 実装内容

- `scripts/deploy-vps.sh` が repository root の `.env` から
  `DEPLOY_SSH_HOST`、`DEPLOY_SSH_USER`、`DEPLOY_SSH_PORT` を読み取るようにする。
- `.env` は shell として source せず、対象 key の値だけを読み取る。
- `.env` が存在しない場合、または `DEPLOY_SSH_HOST` / `DEPLOY_SSH_USER` が
  未設定の場合は停止する。
- `DEPLOY_SSH_PORT` が未設定の場合は `22` を使う。
- 既存の IPv6/hostname validation、numeric port validation、VPS 側 `.env` を
  同期しない挙動は維持する。
- `.env.example` に deploy 接続情報の例を追加する。
- `docs/deployment.md` の local deploy 手順を `.env` に接続情報を書く説明へ更新する。

## 受け入れ条件

- deploy 接続情報を root `.env` で指定できる。
- root `.env` がない場合は `scripts/deploy-vps.sh --dry-run` でも停止する。
- `DEPLOY_SSH_HOST` と `DEPLOY_SSH_USER` が `.env` にない場合は停止する。
- `DEPLOY_SSH_PORT` が `.env` にない場合は `22` を使う。
- `DEPLOY_SSH_PORT` が数値でない場合は停止する。
- `.env.example` に deploy 接続情報の例がある。
- `docs/deployment.md` に `.env` 管理の local deploy 手順が記述されている。

## 検証コマンド

```sh
sh -n scripts/deploy-vps.sh
scripts/deploy-vps.sh --dry-run
pnpm format:md
pnpm lint:md
git diff --check
```

## 完了結果

- `scripts/deploy-vps.sh` が `.env` から deploy 接続情報を読み取るようにした。
- `.env` を shell として source せず、対象 key だけを読み取るようにした。
- `.env.example` に `DEPLOY_SSH_HOST`、`DEPLOY_SSH_USER`、`DEPLOY_SSH_PORT` の例を追加した。
- `docs/deployment.md` の local deploy 手順を `.env` 管理へ更新した。

## 残リスク

- 実 VPS への deploy は本番環境変更に当たるため、この issue では実行しない。
