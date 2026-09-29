FROM docker.io/library/docker:dind@sha256:5efed980cba3fc126cf54e21a5a6ff8849d05b6e0623d6e7612f48e9cd6cd17e

COPY --from=docker.io/tonistiigi/binfmt:latest@sha256:d3b963f787999e6c0219a48dba02978769286ff61a5f4d26245cb6a6e5567ea3 /usr/bin/ /usr/bin/

COPY entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh
RUN chmod +x /usr/local/bin/binfmt-entrypoint.sh
ENTRYPOINT ["binfmt-entrypoint.sh"]
