#!/bin/sh
set -e

# mount first so binfmt doesn't unmount it on exit
mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
binfmt --install all

# drop to the rootless "podman" user after the root-only mount above
chown -R podman:podman /home/podman/.local/share/containers
export HOME=/home/podman
exec setpriv --reuid=1000 --regid=1000 --init-groups "$@"
