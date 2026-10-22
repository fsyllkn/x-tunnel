# OpenWrt branch builds the preserved 2,489-line single-file X-Tunnel.
# This must NOT compile the later cmd/x-tunnel implementation.
FROM golang:1.26.0-alpine AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY x-tunnel.go ./
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -trimpath -ldflags="-s -w" -o /build/x-tunnel ./x-tunnel.go

FROM alpine:3.21
RUN apk add --no-cache ca-certificates tzdata
RUN addgroup -S xtunnel && adduser -S xtunnel -G xtunnel
USER xtunnel
WORKDIR /app
COPY --from=builder /build/x-tunnel /app/x-tunnel
EXPOSE 8090
ENTRYPOINT ["/app/x-tunnel"]
