# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

FROM codeberg.org/forgejo-contrib/forgejo-cli:0.7.0@sha256:fb3021ff1bb5286808ebf4449118ed24979459000bf2092882cd3ba1b99811e6 AS fj
FROM ghcr.io/prefix-dev/pixi:0.82.1@sha256:f83a5fc6d1bb9a2ced27faf2b26c04c5eb618eed22fe13eb60f9225db4817ce0 AS pixi
FROM ghcr.io/astral-sh/uv:0.13.5@sha256:32a7bb39b496babbd997b0a39a4d66c126bdaf5661b302bf6f06abda8deca6ff AS uv

FROM ubuntu:26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG APP_USER="coder"
ARG APP_UID="1000"
ARG APP_GID="1000"
# renovate: datasource=github-releases depName=microsoft/vscode
ARG APP_VERSION=1.143.1

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
