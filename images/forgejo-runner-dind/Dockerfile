# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
FROM docker.io/tonistiigi/binfmt:latest@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 AS binfmt
FROM docker.io/library/docker:dind@sha256:ba3d67c44952ffc448696659a36ef91dd813f03a9c70a2bc0ad1d286d542f4fb

# needed or QEMU drops argv[0], breaking busybox dispatch
ENV QEMU_PRESERVE_ARGV0=1

COPY --from=binfmt /usr/bin/ /usr/bin/
COPY --chmod=755 entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh

ENTRYPOINT ["binfmt-entrypoint.sh"]
