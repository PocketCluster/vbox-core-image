#!/bin/bash

KERNEL_VERSION=4.4.13
AUFS_REPO="https://github.com/sfjro/aufs4-standalone"
AUFS_BRANCH=aufs4.4
AUFS_COMMIT=12387bde8dd9a74508636601bfd5b2a576932174

set -ex

function download_kernel() {
    curl --retry 10 https://www.kernel.org/pub/linux/kernel/v${KERNEL_VERSION%%.*}.x/linux-${KERNEL_VERSION}.tar.xz | tar -C / -xJ
    mv linux-4.4.13 linux-kernel-aufs-${KERNEL_VERSION}
}

function download_aufs4() {
    git clone -b "$AUFS_BRANCH" "$AUFS_REPO"
    pushd $PWD
    cd ./aufs4-standalone
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

download_kernel
download_aufs4
patch_aufs4
create_archive