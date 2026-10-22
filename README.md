# X-Tunnel — OpenWrt Stable Core (single-file Go)

This `openwrt` branch uses the **exact original source** supplied by the owner as `x-tunnel(1).go` (2,489 lines; Git blob SHA-1 `06555ffc42dc4f78f27f79f4157dc7dac36e70f1`). The original known-working Linux AMD64 ELF has SHA-256 `ae3a79a4d2a6a8d7e1377afb2e022c5ed75b0157a694fb6aead9d86ab873ccc2`, is Go 1.26.0 and uses only uuid v1.6.0, gorilla/websocket v1.5.3 and smux v1.5.57. Structural, import and function matches indicate this is the source family of the working binary; the compiled hashes may differ due to build environment.

**Build from `./x-tunnel.go` exclusively. NEVER build `./cmd/x-tunnel` for this OpenWrt stable release.** That legacy directory is retained for comparison only; it uses another codebase that previously omitted SOCKS5 listener initialization, and also introduced GeoIP/GeoSite routing that this project does not need.

## Features and limits

- Single WSS/WS + ECH + smux client supporting `-l socks5://127.0.0.1:PORT`, `-f wss://...`, `-token`, `-ip` with comma-separated CF IPs, `-n`, `-ech`, `-dns`, `-ips` and `-fallback`.
- Each client process supplies SOCKS5, HTTP or TCP proxy listeners. It **does not** install TUN, transparent proxy, policy routing, GeoIP/GeoSite rules or DNS interception.
- Compatible with the existing `fsyllkn/x-tunnel-cf-ip-autotest` supervisor: one process per node; typically 127.0.0.1 ports 32322 onwards, UID 29002.
- The Go core itself does **not** perform CF IP speedtests, provider export or automatic IP replacement; the OpenWrt Python manager handles those separately.
- Windows and other systems can use the CLI binary, but this source does not contain the GUI/TUN feature set from the unrelated later `cmd/` implementation.

## Local Linux AMD64 build

Requires Go **1.26.0**:

```sh
go version
go mod download
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -trimpath -ldflags="-s -w" -o x-tunnel-linux-amd64 ./x-tunnel.go
go version -m ./x-tunnel-linux-amd64
```

Do not replace a live `/usr/bin/x-tunnel` without backing it up and passing the local SOCKS5 listener smoke test. The known-working binary can remain in production indefinitely.

## Multi-platform artifacts

GitHub Actions `.github/workflows/openwrt-socks5.yml` pins Go 1.26.0, builds the **same single-file source** with `CGO_ENABLED=0`, uploads executables and publishes versioned assets at:

[openwrt-stable-go126-v1](https://github.com/fsyllkn/x-tunnel/releases/tag/openwrt-stable-go126-v1)

Targets: linux amd64/arm64/386/armv5/armv6/armv7/mips64; android arm64; darwin amd64/arm64; dragonfly amd64; freebsd 386/amd64/arm/arm64; windows amd64/arm64 (Windows files end with `.exe`). Release is published only if the matrix builds and the Linux amd64 local SOCKS5 handshake smoke test pass. Cross-compilation is not a device-level connectivity test.

## OpenWrt integration

Use the `openwrt` branch of [x-tunnel-cf-ip-autotest](https://github.com/fsyllkn/x-tunnel-cf-ip-autotest/tree/openwrt), which can install versioned, independently preflight-verified Linux binaries after backing up the previous core. Avoid accidentally using the previous `openwrt-socks5-v1` release constructed from the later `cmd/x-tunnel` source.

The verified local SOCKS5 test is:

```sh
netstat -lnt | grep 32322
curl -q --noproxy '' --proxy socks5h://127.0.0.1:32322 \
  --connect-timeout 8 --max-time 20 https://api.ipify.org
```
