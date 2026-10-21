#!/bin/sh
set -eu

ARCH="$1"
VERSION="$2"

case "$ARCH" in
amd64) ARCH=x64 ;;
esac

base="https://update.code.visualstudio.com"
sha256="$(curl -fsSL "$base/api/versions/$VERSION/cli-linux-$ARCH/stable" | jq -r .sha256hash)"

curl -fsSL -o /tmp/vscode-cli.tar.gz "$base/$VERSION/cli-linux-$ARCH/stable"
echo "$sha256  /tmp/vscode-cli.tar.gz" | sha256sum -c -
tar -xzf /tmp/vscode-cli.tar.gz -C /usr/local/bin
rm /tmp/vscode-cli.tar.gz
