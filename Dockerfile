
#デプロイ用コンテナに含めるバイナリを作成するコンテナ
FROM golang:1.20-bullseye as deploy-builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags "-w -s" -o app

# デプロイ用コンテナ
FROM debian:bullseye as deploy

RUN apt-get update && \
    apt-get install -y ca-certificates && \
    update-ca-certificates

COPY --from=deploy-builder /app/app .

CMD ["./app"]

# ローカル開発環境で利用するホットリロード環境
FROM golang:1.20-bullseye as dev

WORKDIR /app

RUN go install github.com/cosmtrek/air@latest

CMD ["air"]