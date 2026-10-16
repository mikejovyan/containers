FROM docker.io/library/docker:dind@sha256:3e5756e2b6dad6a5f1f5deacf0a19f9eaa2581b76ae092b2d4a118162e1d4d4e

COPY --from=docker.io/tonistiigi/binfmt:latest@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 /usr/bin/ /usr/bin/

COPY entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh
RUN chmod +x /usr/local/bin/binfmt-entrypoint.sh
ENTRYPOINT ["binfmt-entrypoint.sh"]
