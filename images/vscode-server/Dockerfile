FROM ubuntu:26.04

ARG APP_USER=coder

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN \
  apt-get update \
  && apt-get install --no-install-recommends --yes \
    ca-certificates \
    curl \
    forgejo-cli \
    git \
    jq \
    openssh-client \
    rsync \
    sudo \
    tini \
    tzdata \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN \
  userdel -r ubuntu \
  && useradd ${APP_USER} \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
  && echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | install -m 0440 /dev/stdin /etc/sudoers.d/nopasswd

# renovate: depName=microsoft/vscode datasource=github-releases
ARG CODE_VERSION=1.133.0
RUN \
  wget --no-hsts --quiet -O- "https://update.code.visualstudio.com/${CODE_VERSION}/cli-linux-x64/stable" \
    | tar -xz -C /usr/local/bin

# renovate: depName=cli/cli datasource=github-releases
ARG GH_VERSION=2.97.0
RUN \
  wget --no-hsts --quiet -O- "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
    | tar -xz --wildcards --strip-components=2 -C /usr/local/bin '*/bin/gh'

COPY --from=ghcr.io/prefix-dev/pixi:0.76.2 /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=ghcr.io/astral-sh/uv:0.12.3 /uv /uvx /usr/local/bin/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER ${APP_USER}

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
