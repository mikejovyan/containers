#!/bin/sh
set -e

echo "[entrypoint] Registering QEMU for cross-arch job containers"
binfmt --install all

exec dockerd-entrypoint.sh "$@"
