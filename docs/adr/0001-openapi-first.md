# 0001: OpenAPI First

## Status

Accepted

## Context

ExpenseClaim は backend、frontend、SDK、テストが同じ API 契約を共有する。
先に実装から API を生やすと、画面、サーバー、テストの期待値がずれやすい。

初期段階では API の契約を実装より先に固定し、レビュー可能な成果物として
管理する必要がある。

## Decision

API 設計は OpenAPI First とする。

OpenAPI 本体は後続 issue で作成し、backend と frontend は OpenAPI を
契約の正本として参照する。API 仕様の変更が必要な場合は、先に OpenAPI を
更新し、その差分に合わせて実装とテストを変更する。

## Consequences

- API の入出力、エラー、認証要件を実装前にレビューできる。
- backend と frontend の認識差分を OpenAPI 差分として検知しやすくなる。
- OpenAPI を更新せずに API 実装だけを変更する運用は認めない。
- 初期 ADR では OpenAPI 本体を作成しないため、具体的なスキーマは後続 issue で
  決定する。
