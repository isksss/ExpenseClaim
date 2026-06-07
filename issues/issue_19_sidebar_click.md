# issue 19: sidebar click

## 目的

サイドバーのメニューをクリックしても反応が見えない状態を解消し、クリックした項目が
選択状態として表示されるようにする。

## 背景

- `AppShell` のサイドバーは `UButton` を並べているが、クリック時の状態更新や遷移先がない。
- Nuxt app skeleton の段階ではルーティング未実装のため、まずは UI shell 内でクリック反応を
明確にする必要がある。

## 対象範囲

- `apps/frontend/components/AppShell.vue`
- サイドバー項目の選択状態
- 選択中項目に連動するヘッダー表示

## 対象外

- backend 実装
- DB、migration、seed
- OpenAPI spec の変更
- API client 接続
- 認証、権限制御
- Nuxt route 追加
- commit、push、Pull Request 作成

## 実装内容

- サイドバー項目に安定した `id` と header title を追加する。
- `selectedNavigationId` を持ち、クリックした項目を選択中として扱う。
- 選択中項目の `color`、`variant`、`aria-current` を状態から決める。
- ヘッダーの見出しを選択中項目に連動させ、クリック反応を画面上で確認できるようにする。

## 受け入れ条件

- サイドバー項目をクリックすると選択状態が切り替わる。
- 選択中の項目だけが active 表示になる。
- ヘッダー見出しが選択中の項目に連動して変わる。
- 既存のダッシュボード表示が壊れていない。
- backend、DB、OpenAPI spec を変更していない。

## 検証コマンド

```sh
pnpm format:frontend
pnpm format:md
pnpm lint:frontend
pnpm check:frontend
pnpm --filter frontend check
pnpm --filter frontend build
pnpm lint:md
git diff --check
```

## 完了結果

- `AppShell` のサイドバー項目に `id` と `title` を追加した。
- `selectedNavigationId` によりクリックした項目を選択中として保持するようにした。
- 選択中項目に応じて `color`、`variant`、`aria-current`、ヘッダー見出しが変わるようにした。
- backend、DB、OpenAPI spec は変更していない。

## 残リスク

- Playwright CLI によるブラウザ実機確認は、ローカルに Chrome / Firefox / WebKit が
  未インストールのため未実行。
- Nuxt build 中に sandbox の DNS 制限で Nuxt Icon の font provider 取得警告が出たが、
  build は成功している。
