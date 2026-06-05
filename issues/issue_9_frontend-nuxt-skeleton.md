# issue 9: frontend nuxt skeleton

## 目的

`apps/frontend` に Nuxt 3 + TypeScript + Nuxt UI の最小 skeleton を追加し、
経費申請管理ツールの実アプリ shell を表示する。

## 背景

- backend、DB、OpenAPI spec の土台は既存 issue で作成済み。
- 申請、承認、経理確認の UI を後続 issue で実装する前に、frontend app の実行単位、
  品質コマンド、Storybook の最小構成が必要。

## 対象範囲

- `apps/frontend` の Nuxt 3 app skeleton
- Nuxt UI、Pinia、VueUse の導入と設定
- `openapi-typescript` を利用する型生成 script
- Storybook の最小構成と script
- frontend 向け Oxlint / Oxfmt が root helper から実行される状態
- 静的 mock によるアプリ shell

## 対象外

- backend 実装
- DB、migration、seed
- OpenAPI spec の変更
- API client 接続
- 認証実装
- IDE 固有設定
- commit、push、Pull Request 作成

## 実装内容

- `apps/frontend/package.json` を追加し、Nuxt、Nuxt UI、Pinia、VueUse、
  Storybook、`openapi-typescript` の script と依存関係を定義する。
- `apps/frontend/nuxt.config.ts` で `@nuxt/ui`、`@pinia/nuxt`、
  `@vueuse/nuxt` を module として設定する。
- 初期画面確認時に UI と重ならないよう、Nuxt DevTools は skeleton では無効化する。
- `AppShell`、`SummaryCard`、Pinia store、VueUse 利用 composable を追加し、
  sidebar、header、summary、list placeholder を持つ社内経費申請管理 shell を表示する。
- `.storybook` と story を追加し、`build-storybook` を検証対象にする。
- root の `format:frontend`、`lint:frontend`、`check:frontend` は既存 helper が
  `apps/frontend` の対象拡張子を検出し、Oxlint / Oxfmt を実行する。

## 受け入れ条件

- `issues/issue_9_frontend-nuxt-skeleton.md` が存在する。
- `apps/frontend` に Nuxt 3 + TypeScript app が存在する。
- Nuxt UI が設定され、初期画面で Nuxt UI component を利用している。
- Pinia と VueUse が導入され、軽い store / composable で利用されている。
- `openapi-typescript` を利用できる script または dev dependency がある。
- Storybook の最小構成と script がある。
- frontend scripts が no-op ではなく Oxlint / Oxfmt を実行する。
- 初期画面は landing / hero ではなく、業務アプリ shell である。
- API 接続、認証、backend、DB、OpenAPI spec を変更していない。

## 検証コマンド

```sh
mise exec -- pnpm install
mise exec -- pnpm format:frontend
mise exec -- pnpm lint:frontend
mise exec -- pnpm check:frontend
mise exec -- pnpm --filter frontend build
mise exec -- pnpm lint:md
git diff --check
mise exec -- pnpm --filter frontend build-storybook
mise exec -- playwright screenshot --full-page \
  http://127.0.0.1:3000/ /tmp/expenseclaim-frontend-desktop.png
mise exec -- playwright screenshot --viewport-size=390,844 --full-page \
  http://127.0.0.1:3000/ /tmp/expenseclaim-frontend-mobile.png
```

## 完了結果

- `apps/frontend` に Nuxt 3.21.7 + TypeScript の app skeleton を追加した。
- Nuxt UI 3.3.7、Pinia、VueUse を Nuxt module として設定した。
- Pinia store と VueUse composable を利用し、sidebar、header、summary、list、
  status placeholder を持つ社内経費申請管理 shell を表示するようにした。
- `openapi-typescript` を dev dependency として追加し、
  `generate:api-types` script で `packages/openapi/openapi.yaml` から型生成できるようにした。
- Storybook の最小構成と `AppShell` story を追加し、静的 build を検証した。
- `pnpm-workspace.yaml` に pnpm v11 の build script 承認設定を追加し、
  `mise exec -- pnpm install` が非対話で完了するようにした。
- `.gitignore` に `storybook-static/` を追加し、Storybook 静的 build 成果物を
  Git 管理対象外にした。
- `.markdownlint-cli2.yaml` を追加し、install 後の `node_modules` 配下 Markdown を
  lint 対象外にした。
- Nuxt DevTools を無効化し、dev server のスクリーンショットでもアプリ shell に
  浮動 UI が重ならないようにした。
- desktop 1280px と mobile 390px のスクリーンショットで、Nuxt Welcome ではなく
  申請ダッシュボード shell が表示されることを確認した。
- backend、DB、OpenAPI spec、IDE 固有設定は変更していない。

## 残リスク

- Nuxt build / Storybook build では依存 package 由来の Rollup PURE コメント警告、
  Tailwind sourcemap 警告、Storybook chunk size 警告が出るが、build は成功している。
- 初期画面は静的 placeholder のみで、API 接続、認証、権限制御、実データ表示は
  後続 issue の対象。
