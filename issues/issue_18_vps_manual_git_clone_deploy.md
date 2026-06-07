# issue 18: vps manual git clone deploy

## 目的

VPS への deploy 方針を、local から `rsync` する方式から VPS 上で repository を
`git clone` / `git pull` して Docker Compose を起動する方式へ切り替える。

## 背景

- local から IPv6 VPS へ `rsync` する deploy script では、実行環境の SSH / IPv6 経路差分に
  依存しやすい。
- VPS には Git と Docker Compose を用意しているため、VPS 上で repository を取得し、
  `$HOME/ExpenseClaim` を配置先として更新する方針に統一する。
- deploy 接続情報は root `.env` に持たず、VPS 側の runtime secret は VPS 上の `.env` に
  限定して管理する。

## 対象範囲

- `docs/deployment.md` の VPS 手動 deploy 手順更新
- `.env.example` から local deploy 用 SSH 設定の削除
- `scripts/deploy-vps.sh` の削除

## 対象外

- 実 VPS への deploy 実行
- commit、push、Pull Request 作成
- Cloudflare Tunnel、Docker Compose service、migration の仕様変更
- 過去 issue の履歴修正

## 実装内容

- VPS 配置先を `$HOME/ExpenseClaim` に統一する。
- 初回配置は `git clone <repository-url> "$HOME/ExpenseClaim"` とする。
- 更新と rollback は `cd "$HOME/ExpenseClaim"` から `git fetch` / `git checkout` /
  `git pull --ff-only` を実行する手順にする。
- local から VPS へ `rsync` する deploy 手順を削除する。
- root `.env` で使っていた `DEPLOY_SSH_HOST`、`DEPLOY_SSH_USER`、
  `DEPLOY_SSH_PORT` の example を削除する。

## 受け入れ条件

- `scripts/deploy-vps.sh` が存在しない。
- `.env.example` に `DEPLOY_SSH_*` が残っていない。
- `docs/deployment.md` に local から VPS へ `rsync` する deploy 手順が残っていない。
- `docs/deployment.md` の VPS 配置先が `$HOME/ExpenseClaim` になっている。
- Markdown lint が成功する。

## 検証コマンド

```sh
pnpm format:md
pnpm lint:md
rg -n "deploy-vps|DEPLOY_SSH|local から VPS|rsync|/opt/expenseclaim" \
  docs README.md .env.example scripts
test ! -e scripts/deploy-vps.sh
git diff --check
```

## 完了結果

- `scripts/deploy-vps.sh` を削除した。
- `.env.example` から `DEPLOY_SSH_HOST`、`DEPLOY_SSH_USER`、
  `DEPLOY_SSH_PORT` を削除した。
- `docs/deployment.md` から local から VPS へ `rsync` する deploy 手順を削除した。
- `docs/deployment.md` の VPS 配置先を `$HOME/ExpenseClaim` に統一した。
- `pnpm format:md`、`pnpm lint:md`、`git diff --check` が成功した。
- 現行 docs / README / `.env.example` / `scripts` に `deploy-vps`、`DEPLOY_SSH`、
  `local から VPS`、`rsync`、`/opt/expenseclaim` の参照が残っていないことを確認した。
