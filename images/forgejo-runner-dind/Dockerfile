# syntax=docker/dockerfile:1
FROM docker.io/tonistiigi/binfmt:latest@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 AS binfmt
FROM docker.io/library/docker:dind@sha256:3e5756e2b6dad6a5f1f5deacf0a19f9eaa2581b76ae092b2d4a118162e1d4d4e

# needed or QEMU drops argv[0], breaking busybox dispatch
ENV QEMU_PRESERVE_ARGV0=1

COPY --from=binfmt /usr/bin/ /usr/bin/
COPY --chmod=755 entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh

ENTRYPOINT ["binfmt-entrypoint.sh"]
