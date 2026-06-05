# 0004: database migration と query generation

## Status

Accepted

## Context

ExpenseClaim は申請、承認、添付、ユーザー、部署などの永続データを扱う。
DB schema とアプリケーション query が乖離すると、実行時エラーや
データ不整合につながる。

Go から PostgreSQL を扱う前提で、migration と query の変更をレビュー可能に
管理する必要がある。

## Decision

DB 接続には pgx、SQL からの query code generation には sqlc、
database migration には goose を採用する。

schema 変更は goose migration として管理し、アプリケーションで利用する SQL は
sqlc の入力として管理する。生成された Go コードは schema と query の契約を
反映した型として利用する。

## Consequences

- SQL を明示的に管理しながら、Go 側では型付き query を利用できる。
- migration の順序と適用状態を goose で追跡できる。
- schema 変更、SQL 変更、生成コード更新を同じ issue 範囲で扱う必要がある。
- 初期 ADR では migration や sqlc 設定を作成しない。
