FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7

ARG APP_USER=coder
# renovate: datasource=github-releases depName=microsoft/vscode
ARG CODE_VERSION=1.141.2
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

COPY --from=codeberg.org/forgejo-contrib/forgejo-cli:0.6.0@sha256:309b8759b7107a0da2b76b9b9be77c87464f9be9d4d1b6b4d1f9e22ba1145598 /usr/local/bin/fj /usr/local/bin/fj
COPY --from=ghcr.io/prefix-dev/pixi:0.81.0@sha256:788ae451641666e2d1f79d3dbe35392dfc7e9b394b16a3acb75c347f3badb2ab /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=ghcr.io/astral-sh/uv:0.13.1@sha256:4a1f3666816dafadd20ceb71eac9a7d56d7ef30279f7d64048519ab901ada336 /uv /uvx /usr/local/bin/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER ${APP_USER}

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
