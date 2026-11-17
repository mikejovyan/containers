#!/bin/bash
set -euo pipefail

ARCH="$TARGETARCH"
VERSION="$APP_VERSION"
DEST="${DEST:-/usr/local/bin}"

case "$ARCH" in
amd64) ARCH=x64 ;;
esac

base="https://update.code.visualstudio.com"
tmpfile="$(mktemp)"
trap 'rm -f "$tmpfile"' EXIT

headers="$(curl -fsSL -D - -o "$tmpfile" "$base/$VERSION/cli-linux-$ARCH/stable")"
sha256="$(grep -i '^x-sha256:' <<<"$headers" | tr -d '\r' | awk '{print $2}')"

echo "$sha256  $tmpfile" | sha256sum -c -
tar -xzf "$tmpfile" -C "$DEST"
