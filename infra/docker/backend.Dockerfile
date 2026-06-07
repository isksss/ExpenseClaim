FROM golang:1.26-alpine AS build

WORKDIR /app/apps/backend

COPY apps/backend/go.mod apps/backend/go.sum ./

RUN go mod download

WORKDIR /app

COPY apps/backend apps/backend

WORKDIR /app/apps/backend

RUN go build -trimpath -ldflags="-s -w" -o /out/expenseclaim-server ./cmd/server

FROM alpine:3.22 AS runtime

RUN apk add --no-cache ca-certificates wget

ENV PORT=8080

COPY --from=build /out/expenseclaim-server /usr/local/bin/expenseclaim-server

EXPOSE 8080

CMD ["expenseclaim-server"]
