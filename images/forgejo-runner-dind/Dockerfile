FROM docker.io/library/docker:dind@sha256:7dcdfc4a20246236f558175182ccace1eb15a41bd3eb119dd2284f393498b7c1

COPY --from=docker.io/tonistiigi/binfmt:latest@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 /usr/bin/ /usr/bin/

COPY entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh
RUN chmod +x /usr/local/bin/binfmt-entrypoint.sh
ENTRYPOINT ["binfmt-entrypoint.sh"]
