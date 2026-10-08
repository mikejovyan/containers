FROM docker.io/library/docker:dind@sha256:1e08cdb63405ca788aea94ef35b792d1e299607c667d33d7bcbcae1fd2611ced

COPY --from=docker.io/tonistiigi/binfmt:latest@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 /usr/bin/ /usr/bin/

COPY entrypoint.sh /usr/local/bin/binfmt-entrypoint.sh
RUN chmod +x /usr/local/bin/binfmt-entrypoint.sh
ENTRYPOINT ["binfmt-entrypoint.sh"]
