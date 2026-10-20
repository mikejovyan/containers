#!/bin/sh
set -e

# mount first so binfmt doesn't unmount it on exit
mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
binfmt --install all

exec dockerd-entrypoint.sh "$@"
