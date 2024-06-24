# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM golang:1.18-alpine AS builder

# 환경 변수 설정
ENV CGO_ENABLED=0 \
    GOPATH=/go \
    GOCACHE=/go-build \
    APP_PORT=8080 \
    APP_VERSION=1.0

WORKDIR /code

# 라벨 추가
LABEL maintainer="your-email@example.com"
LABEL description="My Go backend application"

# 빌드 단계
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod/cache \
    go mod download

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod/cache \
    --mount=type=cache,target=/go-build \
    go build -o bin/backend main.go

# 최종 빌드 단계
FROM alpine:latest

# 환경 변수 설정
ENV APP_PORT=$APP_PORT

WORKDIR /app

# 멀티 스테이지 빌드에서 빌더 스테이지에서 생성된 바이너리 복사
COPY --from=builder /code/bin/backend .

# 추가적인 설치나 설정은 필요에 따라 추가할 수 있습니다.

CMD ["./backend"]
