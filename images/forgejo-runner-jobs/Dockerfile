# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

FROM docker.io/library/buildpack-deps:26.10@sha256:80f52ba2ecac89db7d06b4f97e1544b8e6b1d52ef0d7a07e9ff27fb6e1e27b5b

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
        buildah \
        fuse-overlayfs \
        podman \
    && git config --system --add safe.directory '*' \
    && apt-get dist-clean \
    && rm -rf /var/cache/* /var/log/* /tmp/*

ENV DEPLOYMENT_BASEPATH=/opt/runner \
    IMAGE_OS=ubuntu26 \
    ImageOS=ubuntu26 \
    LSB_OS_VERSION=2604 \
    LSB_RELEASE=26.04 \
    RUNNER_USER=root \
    USER=root

COPY --chmod=644 containers.conf storage.conf /etc/containers/
VOLUME /var/tmp
VOLUME /var/lib/containers

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache \
    RUNNER_TOOL_CACHE=/opt/hostedtoolcache
RUN mkdir -m 0777 -p /opt/hostedtoolcache
VOLUME /opt/hostedtoolcache

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock

ENV BUILDAH_ISOLATION=chroot
