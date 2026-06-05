# 0008: attachment storage

## Status

Accepted

## Context

経費申請では領収書などの添付ファイルを扱う。
初期段階では外部 object storage や CDN を導入すると、認証、署名 URL、
環境設定、運用手順が増える。

まずはローカル開発と単一環境で扱いやすい保存方式が必要である。

## Decision

初期の添付ファイル保存先はローカル volume とする。

backend は添付ファイルの実体をローカル volume に保存し、DB には
参照に必要なメタデータを保存する。保存パス、ファイル名の正規化、
サイズ制限、MIME type 検証、削除方針は添付実装 issue で決定する。

## Consequences

- 初期開発と検証で外部 storage への依存を避けられる。
- volume の backup、容量、削除、権限設定を運用上考慮する必要がある。
- 複数 backend instance や cloud storage が必要になった場合は、
  別 issue と ADR で保存方式を再検討する。
- 初期 ADR では upload API や storage 設定は作成しない。
