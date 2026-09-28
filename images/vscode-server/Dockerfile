FROM ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78

ARG APP_USER=coder
# renovate: datasource=github-releases depName=microsoft/vscode
ARG CODE_VERSION=1.139.1

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        ca-certificates \
        curl \
        forgejo-cli \
        gh \
        git \
        jq \
        openssh-client \
        python3 \
        python3-ipykernel \
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

RUN wget --no-hsts --quiet -O- "https://update.code.visualstudio.com/${CODE_VERSION}/cli-linux-x64/stable" \
    | tar -xz -C /usr/local/bin

COPY --from=ghcr.io/prefix-dev/pixi:0.81.0@sha256:788ae451641666e2d1f79d3dbe35392dfc7e9b394b16a3acb75c347f3badb2ab /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=ghcr.io/astral-sh/uv:0.12.19@sha256:04d046b13e60d6bcec73cbc5e1cad25d680dea90c8573340950a0ac2d1aef424 /uv /uvx /usr/local/bin/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER ${APP_USER}

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
