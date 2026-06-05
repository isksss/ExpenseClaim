# 0010: initial architecture boundaries

## Status

Accepted

## Context

ExpenseClaim は monorepo で frontend、backend、OpenAPI、DB、infra、
docs を管理する。境界が曖昧なまま実装を始めると、frontend が DB 構造に
依存したり、backend が画面都合の型を直接受け取ったりしやすい。

初期段階で責務境界を決め、後続 issue の実装先を判断できるようにする。

## Decision

初期アーキテクチャ境界を以下のように定義する。

- OpenAPI は API 契約の正本とする。
- backend は認証、権限判定、業務ルール、永続化、添付ファイル管理を担当する。
- frontend は Nuxt による画面、入力、表示状態、API client 利用を担当する。
- DB schema と migration は backend の永続化境界として扱う。
- docs は設計判断、運用、開発手順を管理する。
- infra は実行環境や永続 volume などの構成を管理する。

## Consequences

- 変更をどの領域に置くべきか判断しやすくなる。
- frontend は DB に直接依存せず、OpenAPI 経由で backend と接続する。
- backend は frontend 固有の見た目や表示状態を持たない。
- 境界を越える変更が必要な場合は、対象 issue の範囲と ADR 更新要否を
  先に確認する。
