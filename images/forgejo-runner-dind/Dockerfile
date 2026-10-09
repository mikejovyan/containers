FROM docker.io/library/docker:dind@sha256:0b6d18a4a222e71c88be6034926b4f6cde2fc33c2218643d03ccfddc65995470

COPY --from=docker.io/tonistiigi/binfmt:latest@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 /usr/bin/ /usr/bin/

COPY entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh
RUN chmod +x /usr/local/bin/binfmt-entrypoint.sh
ENTRYPOINT ["binfmt-entrypoint.sh"]
