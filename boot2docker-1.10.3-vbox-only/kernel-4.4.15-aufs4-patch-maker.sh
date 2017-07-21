#!/bin/bash

KERNEL_VERSION=4.4.15
AUFS_REPO="https://github.com/sfjro/aufs4-standalone"
AUFS_BRANCH=aufs4.4
AUFS_COMMIT=ab2083cbed8619eccef23941c2c0c83357af7199
AUFS_UTIL_COMMIT=5e0c348bd8b1898beb1e043b026bcb0e0c7b0d54

set -ex

function download_kernel() {
    if [[ ! -d ./linux-kernel-aufs-${KERNEL_VERSION} ]]; then
        curl --retry 10 https://www.kernel.org/pub/linux/kernel/v${KERNEL_VERSION%%.*}.x/linux-${KERNEL_VERSION}.tar.xz | tar -xJ
        mv linux-${KERNEL_VERSION} linux-kernel-aufs-${KERNEL_VERSION}
    fi
}

function download_aufs4() {
    if [[ ! -d ./aufs4-standalone ]]; then
        git clone "$AUFS_BRANCH" "$AUFS_REPO"
    fi
    pushd $PWD
    cd ./aufs4-standalone
    git checkout master && git fetch --all 
    git checkout -q "$AUFS_COMMIT"
    popd
}

function patch_aufs4() {
    pushd $PWD
    cp -r ./aufs4-standalone/Documentation ./linux-kernel-aufs-${KERNEL_VERSION}
    cp -r ./aufs4-standalone/fs ./linux-kernel-aufs-${KERNEL_VERSION}
    cp -r ./aufs4-standalone/include/uapi/linux/aufs_type.h ./linux-kernel-aufs-${KERNEL_VERSION}/include/uapi/linux/
    cd ./linux-kernel-aufs-${KERNEL_VERSION}
    set -e && for patch in \
        ../aufs4-standalone/aufs*-kbuild.patch \
        ../aufs4-standalone/aufs*-base.patch \
        ../aufs4-standalone/aufs*-mmap.patch \
        ../aufs4-standalone/aufs*-standalone.patch \
        ../aufs4-standalone/aufs*-loopback.patch \
    ; do \
        patch -p1 < "$patch"; \
    done
    popd
}

function create_archive() {
    tar cJvf linux-kernel-aufs-${KERNEL_VERSION}.tar.xz ./linux-kernel-aufs-${KERNEL_VERSION}
}

function download_aufs_util() {

    if [[ ! -d ./aufs-util ]]; then
        git clone https://github.com/Distrotech/aufs-util.git
    fi
    pushd $PWD
    cd ./aufs-util
    git checout master && git fetch --all && git checkout ${AUFS_UTIL_COMMIT}
    tar cvzf ../aufs-util-${AUFS_UTIL_COMMIT} *
    git checkout master
    popd
}

download_kernel
download_aufs4
patch_aufs4
create_archive
download_aufs_util