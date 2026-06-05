# 0003: backend framework と code generation

## Status

Accepted

## Context

backend は OpenAPI First の契約に従い、HTTP API を安定して提供する必要がある。
手書きのルーティングや型定義だけに依存すると、OpenAPI と実装の不一致が
発生しやすい。

Go で軽量に HTTP API を構築しつつ、OpenAPI から型と handler 境界を
生成できる構成が必要である。

## Decision

backend framework は Echo を採用し、OpenAPI からの code generation には
oapi-codegen を採用する。

OpenAPI を契約の正本とし、oapi-codegen で生成した型や server interface を
backend 実装で利用する。Echo 固有の middleware や routing は、生成コードとの
境界を崩さない範囲で利用する。

## Consequences

- OpenAPI と backend の型不一致を減らせる。
- Echo の middleware により認証、ログ、エラー処理を組み込みやすい。
- 生成コードを直接編集せず、再生成できる状態を維持する必要がある。
- OpenAPI 本体と生成設定は後続 issue で作成する。
