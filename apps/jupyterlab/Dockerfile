FROM quay.io/jupyter/minimal-notebook
#TODO: REMOVE
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    # build-essential \
    # for latex labels
    # cm-super \
    # dvipng \
    # for matplotlib anim
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --chown=${NB_UID}:${NB_GID} environment.yml /tmp/

USER ${NB_UID}

# Install Python 3 packages
RUN mamba env update --prefix=$CONDA_DIR --file=/tmp/environment.yml && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    rm /tmp/environment.yml

# Import matplotlib the first time to build the font cache
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

# Install PyTorch with pip (https://pytorch.org/get-started/locally/)
# hadolint ignore=DL3013
# RUN pip install --no-cache-dir --index-url 'https://download.pytorch.org/whl/cpu' \
#     'torch' \
#     'torchaudio' \
#     'torchvision' && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"

# Configure JupyterLab user settings in a single RUN command
RUN SETTINGS_DIR="/home/${NB_USER}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension" && \
    CODE_FORMATTER_SETTINGS_DIR="/home/${NB_USER}/.jupyter/lab/user-settings/jupyterlab_code_formatter" && \
    mkdir -p "$SETTINGS_DIR" "$CODE_FORMATTER_SETTINGS_DIR" && \
    echo '{ "fetchNews": "true" }' > "$SETTINGS_DIR/notification.jupyterlab-settings" && \
    echo '{ "adaptive-theme": true }' > "$SETTINGS_DIR/themes.jupyterlab-settings" && \
    echo '{ "formatOnSave": true, "suppressFormatterErrorsIFFAutoFormatOnSave": true }' > "$CODE_FORMATTER_SETTINGS_DIR/settings.jupyterlab-settings"

WORKDIR "${HOME}"
