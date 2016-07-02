FROM ubuntu:xenial

RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections && \
    echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections && \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
    wget \
    build-essential \
    libncurses-dev \
    rsync \
    unzip \
    bc \
    gnupg \
    python \
    libc6-i386 \
    cpio \
    locales \
    git-core

COPY rootfs /tmp/rootfs

## Buildroot is fixed for 2016.02
#ENV BUILDROOT_VERSION 2016.02
#RUN wget -qO- http://buildroot.uclibc.org/downloads/buildroot-$BUILDROOT_VERSION.tar.bz2 | tar xj && mv buildroot-$BUILDROOT_VERSION /tmp/buildroot
COPY buildroot-2016.02.tar.bz2 /tmp
RUN cd /tmp && tar xvjf buildroot-2016.02.tar.bz2 && rm buildroot-2016.02.tar.bz2 && mv buildroot-2016.02 buildroot

## DOCKER version is reverted to suport Swarm 2016/06/24
#ENV DOCKER_VERSION 1.10.3
#RUN cd /tmp; wget -qO- https://get.docker.io/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz | tar xz && mv docker/* /tmp/rootfs/usr/bin/
COPY docker-1.10.3.tgz /tmp 
RUN cd /tmp && tar xvzf docker-1.10.3.tgz && mv ./usr/local/bin/docker /tmp/rootfs/usr/bin/

RUN ln -s /tmp/config/buildroot /tmp/buildroot/.config

WORKDIR /tmp/buildroot
