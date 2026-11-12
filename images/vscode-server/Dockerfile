# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

FROM codeberg.org/forgejo-contrib/forgejo-cli:0.7.0@sha256:fb3021ff1bb5286808ebf4449118ed24979459000bf2092882cd3ba1b99811e6 AS fj
FROM ghcr.io/prefix-dev/pixi:0.84.2@sha256:8201f134655a8261f382ee565ddf1498e5f215887bb14e812e1f47c09f4f7196 AS pixi
FROM ghcr.io/astral-sh/uv:0.13.7@sha256:96f40d3904aad8d0bd010539001d36c8e2188b981e1334471a90c4a1d93bb490 AS uv

FROM ubuntu:26.04@sha256:065aa8626841f16057b78b027b464cd59c4fac36c204c72dcbf48d66f5fa8a96

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG APP_USER="coder"
ARG APP_UID="1000"
ARG APP_GID="1000"
# renovate: datasource=github-releases depName=microsoft/vscode
ARG APP_VERSION=1.146.0

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
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
        unzip \
        wget \
    && git lfs install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "C.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen

ENV SHELL=/bin/bash \
    APP_USER="${APP_USER}" \
    APP_UID=${APP_UID} \
    APP_GID=${APP_GID} \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    HOME="/home/${APP_USER}"

RUN if id -un "${APP_UID}" >/dev/null 2>&1; then \
        userdel --remove "$(id -un "${APP_UID}")"; \
    fi \
    && groupadd --gid=${APP_GID} ${APP_USER} \
    && useradd ${APP_USER} \
        --uid=${APP_UID} \
        --gid=${APP_GID} \
        --create-home \
        --no-log-init \
        --shell=/bin/bash \
    # disable the %admin/%sudo group grants, so only the explicit rule below can grant sudo
    && sed -i 's/^%admin/#%admin/' /etc/sudoers \
    && sed -i 's/^%sudo/#%sudo/' /etc/sudoers \
    && echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | install -m 0440 /dev/stdin /etc/sudoers.d/nopasswd \
    # group-writable so an arbitrary-UID `docker run --user` can self-register in /etc/passwd at startup
    && chmod g+w /etc/passwd \
    && mkdir -p "${HOME}/Projects" \
    && chown ${APP_USER}:${APP_GID} "${HOME}/Projects"

ARG TARGETARCH

RUN --mount=type=bind,source=install-vscode-cli.sh,target=/install-vscode-cli.sh \
    bash /install-vscode-cli.sh "$TARGETARCH" "$APP_VERSION"

USER ${APP_UID}

COPY --from=fj /usr/local/bin/fj /usr/local/bin/fj
COPY --from=pixi /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=uv /uv /uvx /usr/local/bin/

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["catatonit", "-g", "--", "/usr/local/bin/entrypoint.sh"]

WORKDIR "${HOME}"
