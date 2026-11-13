#!/bin/sh
set -e

# mount first so binfmt doesn't unmount it on exit
mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
binfmt --install all

# the mount above needs real root; the engine itself runs rootless as
# "user" (aio's baked-in UID 1000), so fix up ownership then drop down
chown -R user:user /home/user/.local/share/containers
export HOME=/home/user
exec setpriv --reuid=1000 --regid=1000 --init-groups "$@"
