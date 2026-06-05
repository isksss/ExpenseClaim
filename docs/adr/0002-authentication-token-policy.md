# 0002: 認証トークン方針

## Status

Accepted

## Context

ExpenseClaim は Web frontend から backend API を利用する。
API 呼び出しでは利用者を識別し、申請、承認、経理処理の操作権限を
一貫して判定する必要がある。

短命な認証情報だけでは再ログインが頻発し、長命な認証情報だけでは
漏えい時の影響が大きくなる。

## Decision

API 認証は Bearer JWT と Refresh Token の組み合わせを採用する。

通常の API 呼び出しでは `Authorization: Bearer <token>` で JWT を送信する。
JWT は短命にし、期限切れ時は Refresh Token によって再発行する。
Refresh Token は JWT より長命にし、失効や再発行の管理対象とする。

## Consequences

- API はステートレスに近い形で認証済みユーザーを扱える。
- Refresh Token の保管、失効、ローテーション方針が必要になる。
- 権限判定は JWT の内容だけに固定せず、必要に応じて backend 側の
  最新データを参照する。
- トークンの有効期限や保存場所の詳細は、認証実装 issue で決定する。
