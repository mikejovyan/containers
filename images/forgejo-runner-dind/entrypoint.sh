#!/bin/sh
set -e

echo "[entrypoint] Registering QEMU for cross-arch job containers"

# Mount first ourselves, otherwise binfmt unmounts it again once it returns
mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc

# Without this, QEMU drops argv[0], breaking busybox's argv0-based multi-call dispatch (e.g. /bin/sh -c ...)
export QEMU_PRESERVE_ARGV0=1
binfmt --install all

exec dockerd-entrypoint.sh "$@"
