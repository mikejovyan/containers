FROM ubuntu:latest

USER root

ARG VSCODE_VERSION=latest

ENV USER=coder \
    CODE_DIR=/opt/code \
    CONDA_DIR=/opt/conda \
    PATH=/home/coder/.local/bin:/opt/conda/bin:$PATH

RUN \
  # tools & required packages
  apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y --no-install-recommends \
  	bzip2 ca-certificates curl git sudo tini unzip wget \

  # clean up
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  && ARCH="$(dpkg --print-architecture)" \

  # install visual studio code
  && mkdir -p $CODE_DIR \
  && case "$ARCH" in \
       amd64) ARCH_SUFFIX='x64' ;; \
       arm64) ARCH_SUFFIX='arm64' ;; \
     esac \
  && wget -qO- https://update.code.visualstudio.com/${VSCODE_VERSION}/cli-linux-${ARCH_SUFFIX}/stable | tar xvz -C "$CODE_DIR" \
  && ln -s $CODE_DIR/code /usr/local/bin/code \
  && chmod +x /usr/local/bin/code \

  # create user
  && if grep -q 1000 /etc/passwd; then \
      userdel -r "$(id -un 1000)"; \
    fi \
  && useradd -m -s /bin/bash coder \
  && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/coder \
  && chmod 0444 /etc/sudoers.d/coder \
  && usermod -aG sudo coder \

  # fix permissions
  && wget -qO- "https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - \
  && chown root:root /usr/local/bin/fixuid \
  && chmod 4755 /usr/local/bin/fixuid \
  && mkdir -p /etc/fixuid \
  && echo "user: coder\ngroup: coder\n" >> /etc/fixuid/config.yml \

  # install miniforge
  && mkdir -p /tmp/bin \
  && wget --progress=dot:giga -O /tmp/bin/Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" \
  && sh /tmp/bin/Miniforge3.sh -b -p "$CONDA_DIR" \
  && rm /tmp/bin/Miniforge3.sh \
  && mamba list --full-name 'python' | awk 'END{sub("[^.]*$", "*", $2); print $1 " " $2}' >> "${CONDA_DIR}/conda-meta/pinned" \
  && mamba clean --all -f -y \
  && chown -R coder:coder $CONDA_DIR
  
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
 
COPY --chown=coder:coder environment.yml /tmp/

USER coder
WORKDIR /home/coder

RUN \
  # mute sudo warning
  touch /home/coder/.sudo_as_admin_successful \

  # create config folder
  && mkdir -p /home/coder/.config \

  # # install environment
  && echo 'eval "$(/opt/conda/bin/conda shell.bash hook)"' >> /home/coder/.bashrc \
  && mamba env update --prefix=$CONDA_DIR --file=/tmp/environment.yml \
  && mamba clean --all -f -y \
  && rm /tmp/environment.yml

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
