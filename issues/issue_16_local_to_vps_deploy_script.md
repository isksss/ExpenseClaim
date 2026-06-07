# issue 16: local to vps deploy script

## 目的

local 環境から IPv6 の VPS へ ExpenseClaim を deploy するための
script と手順を整備する。

## 背景

- issue 14 で VPS 上の Docker Compose deploy 手順は整備済み。
- 今回は local から VPS へ deploy するため、tracked files を `rsync` で同期し、
  VPS 上で既存の Compose 手順を実行できるようにする。
- VPS 側の secret と `.env` は repository に保存せず、同期対象にも含めない。

## 対象範囲

- local から IPv6 VPS へ同期して deploy する shell script の追加
- DB migration を option 実行にする
- deploy 手順ドキュメントの更新
- issue ファイルと devlog への作業内容記録
- commit、push、Pull Request 作成、develop/main への merge

## 対象外

- 実 VPS への deploy 実行
- secret、本番接続情報、`.env` の追加
- GitHub Actions deploy job の追加

## 実装内容

- `scripts/deploy-vps.sh` を追加し、`DEPLOY_SSH_HOST`、`DEPLOY_SSH_USER`、
  `DEPLOY_SSH_PORT`、`DEPLOY_REMOTE_DIR`、`DEPLOY_COMPOSE` で接続先と
  deploy 先を指定できるようにする。
- `rsync` は IPv6 literal を `user@[addr]:path` として扱い、
  `git ls-files -z` の tracked files のみを同期する。
- `--migrate` 指定時だけ、VPS 上で `mise exec -- make migrate-up` を実行する。
- `.env` は VPS 側に事前配置されたものを利用し、存在しない場合は停止する。
- `rsync --delete` でも VPS 側 `.env` を保護する。
- `docs/deployment.md` に local から VPS へ deploy する手順を追記する。

## 受け入れ条件

- `scripts/deploy-vps.sh` が存在する。
- deploy 先 host は IPv6 address を指定できる。
- 接続情報は環境変数で指定できる。
- `rsync` は repository の tracked files のみを同期する。
- working tree が clean でない場合は実 deploy を停止する。
- `.env` と secret は同期されない。
- VPS 側 `.env` は `rsync --delete` でも削除されない。
- migration は `--migrate` 指定時だけ実行される。
- `docs/deployment.md` に local から VPS へ deploy する手順が記述されている。

## 検証コマンド

```sh
sh -n scripts/deploy-vps.sh
DEPLOY_SSH_HOST='2001:db8::10' DEPLOY_SSH_USER=deploy scripts/deploy-vps.sh --dry-run
mise exec -- pnpm format:md
mise exec -- pnpm lint:md
docker compose config
git diff --check
```

## 完了結果

- `scripts/deploy-vps.sh` を追加し、local の tracked files を IPv6 VPS へ
  `rsync` で同期できるようにした。
- `DEPLOY_SSH_HOST`、`DEPLOY_SSH_USER`、`DEPLOY_SSH_PORT`、
  `DEPLOY_REMOTE_DIR`、`DEPLOY_COMPOSE` で接続先と実行コマンドを指定できる
  ようにした。
- deploy 前に working tree が clean であることを確認し、未コミット差分や
  未追跡ファイルの混入を防ぐようにした。
- `--dry-run` は dirty な作業ツリーでも実行内容の表示だけを行えるようにした。
- VPS 側 `.env` は同期せず、存在しない場合に停止するようにした。
- `rsync --delete` でも VPS 側 `.env` を保護するようにした。
- `--migrate` 指定時だけ migration を実行するようにした。
- `docs/deployment.md` に local から VPS へ deploy する手順を追記した。

## 残リスク

- 実 VPS への deploy は本番環境変更に当たるため、この issue では実行しない。
