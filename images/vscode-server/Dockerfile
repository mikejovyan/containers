# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
FROM codeberg.org/forgejo-contrib/forgejo-cli:0.7.0@sha256:fb3021ff1bb5286808ebf4449118ed24979459000bf2092882cd3ba1b99811e6 AS fj
FROM ghcr.io/prefix-dev/pixi:0.82.1@sha256:f83a5fc6d1bb9a2ced27faf2b26c04c5eb618eed22fe13eb60f9225db4817ce0 AS pixi
FROM ghcr.io/astral-sh/uv:0.13.4@sha256:9f130421e930bfbdc563c00740466603f8723158e90297d07957c2294640262b AS uv
FROM ubuntu:26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG APP_USER=coder
ARG APP_UID=1000
ARG APP_GID=1000
# renovate: datasource=github-releases depName=microsoft/vscode
ARG APP_VERSION=1.142.0
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=${APP_USER}

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        ca-certificates \
        catatonit \
        curl \
        gh \
        git \
        git-lfs \
        jq \
        libgomp1 \
        locales \
        openssh-client \
        python3 \
        rsync \
        sudo \
        tzdata \
        unzip \
        wget \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
    && locale-gen
ENV LANG=en_US.UTF-8

RUN userdel -r ubuntu \
    && groupadd --gid=${APP_GID} ${APP_USER} \
    && useradd ${APP_USER} \
        --create-home \
        --gid=${APP_GID} \
        --shell=/bin/bash \
        --uid=${APP_UID} \
    && echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | install -m 0440 /dev/stdin /etc/sudoers.d/nopasswd

RUN --mount=type=bind,source=install-vscode-cli.sh,target=/install-vscode-cli.sh \
    sh /install-vscode-cli.sh "$TARGETARCH" "$APP_VERSION"

COPY --from=fj /usr/local/bin/fj /usr/local/bin/fj
COPY --from=pixi /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=uv /uv /uvx /usr/local/bin/

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${APP_USER}
WORKDIR /home/${APP_USER}

EXPOSE 8000
ENTRYPOINT ["catatonit", "--", "/usr/local/bin/entrypoint.sh"]
