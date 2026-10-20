# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
FROM codeberg.org/forgejo-contrib/forgejo-cli:0.7.0@sha256:fb3021ff1bb5286808ebf4449118ed24979459000bf2092882cd3ba1b99811e6 AS fj
FROM ghcr.io/prefix-dev/pixi:0.82.0@sha256:e6cca082e52de275f4e6fb4e6648522f30e4ed334fed37378cde393e07405200 AS pixi
FROM ghcr.io/astral-sh/uv:0.13.4@sha256:9f130421e930bfbdc563c00740466603f8723158e90297d07957c2294640262b AS uv
FROM ubuntu:26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944

ARG APP_USER=coder
# renovate: datasource=github-releases depName=microsoft/vscode
ARG CODE_VERSION=1.142.0
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        ca-certificates \
        curl \
        gh \
        git \
        jq \
        libgomp1 \
        openssh-client \
        python3 \
        rsync \
        sudo \
        tini \
        tzdata \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu \
    && useradd ${APP_USER} \
        --create-home \
        --shell=/bin/bash \
        --uid=1000 \
    && echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | install -m 0440 /dev/stdin /etc/sudoers.d/nopasswd

RUN VSCODE_ARCH="$TARGETARCH"; [ "$VSCODE_ARCH" = amd64 ] && VSCODE_ARCH=x64; \
    wget --no-hsts --quiet -O- "https://update.code.visualstudio.com/${CODE_VERSION}/cli-linux-${VSCODE_ARCH}/stable" \
    | tar -xz -C /usr/local/bin

COPY --from=fj /usr/local/bin/fj /usr/local/bin/fj
COPY --from=pixi /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=uv /uv /uvx /usr/local/bin/

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${APP_USER}

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
