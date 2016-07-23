FROM debian:jessie

RUN apt-get update && apt-get -y install  unzip \
                        xz-utils \
                        curl \
                        bc \
                        git \
                        build-essential \
                        golang \
                        cpio \
                        gcc libc6 libc6-dev \
                        kmod \
                        squashfs-tools \
                        genisoimage \
                        xorriso \
                        syslinux \
                        isolinux \
                        automake \
                        pkg-config \
                        p7zip-full

# https://www.kernel.org/
ENV KERNEL_VERSION  4.4.15

COPY linux-kernel-aufs-${KERNEL_VERSION}.tar.xz /
RUN cd / && \
    tar -xf linux-kernel-aufs-${KERNEL_VERSION}.tar.xz && \
    mv /linux-kernel-aufs-${KERNEL_VERSION} /linux-kernel
COPY kernel_config /linux-kernel/.config

RUN jobs=$(nproc); \
    cd /linux-kernel && \
    make -j ${jobs} oldconfig && \
    make -j ${jobs} bzImage && \
    make -j ${jobs} modules

# The post kernel build process

ENV ROOTFS /rootfs

# Make the ROOTFS
RUN mkdir -p $ROOTFS

# Prepare the build directory (/tmp/iso)
RUN mkdir -p /tmp/iso/boot

# Install the kernel modules in $ROOTFS
RUN cd /linux-kernel && \
    make INSTALL_MOD_PATH=$ROOTFS modules_install firmware_install

# Remove useless kernel modules, based on unclejack/debian2docker
RUN cd $ROOTFS/lib/modules && \
    rm -rf ./*/kernel/sound/* && \
    rm -rf ./*/kernel/drivers/gpu/* && \
    rm -rf ./*/kernel/drivers/infiniband/* && \
    rm -rf ./*/kernel/drivers/isdn/* && \
    rm -rf ./*/kernel/drivers/media/* && \
    rm -rf ./*/kernel/drivers/staging/lustre/* && \
    rm -rf ./*/kernel/drivers/staging/comedi/* && \
    rm -rf ./*/kernel/fs/ocfs2/* && \
    rm -rf ./*/kernel/net/bluetooth/* && \
    rm -rf ./*/kernel/net/mac80211/* && \
    rm -rf ./*/kernel/net/wireless/*

# Install libcap
COPY libcap2_2.22.orig.tar.gz /
RUN tar xvzf libcap2_2.22.orig.tar.gz && \
    cd /libcap-2.22 && \
    sed -i 's/LIBATTR := yes/LIBATTR := no/' Make.Rules && \
    make && \
    mkdir -p output && \
    make prefix=`pwd`/output install && \
    mkdir -p $ROOTFS/usr/local/lib && \
    cp -av `pwd`/output/lib64/* $ROOTFS/usr/local/lib

# Make sure the kernel headers are installed for aufs-util, and then build it
RUN cd /linux-kernel && \
    make INSTALL_HDR_PATH=/tmp/kheaders headers_install
COPY aufs-util-5e0c348bd8b1898beb1e043b026bcb0e0c7b0d54.tar.gz /
RUN mkdir /aufs-util && \
    tar -xvzf aufs-util.tar.gz -C /aufs-util && \
    cd /aufs-util && \
    CPPFLAGS="-I/tmp/kheaders/include" CLFAGS=$CPPFLAGS LDFLAGS=$CPPFLAGS make && \
    DESTDIR=$ROOTFS make install && \
    rm -rf /tmp/kheaders

# Prepare the ISO directory with the kernel
RUN cp -v /linux-kernel/arch/x86_64/boot/bzImage /tmp/iso/boot/vmlinuz64


#------------------------------ INSTALL TINYCORE ------------------------------


ENV TCL_REPO_BASE   http://tinycorelinux.net/7.x/x86_64
# Note that the ncurses is here explicitly so that top continues to work
ENV TCZ_DEPS        iptables \
                    iproute2 \
                    openssh openssl \
                    tar \
                    gcc_libs \
                    ncurses \
                    acpid \
                    xz liblzma \
                    git expat2 libgpg-error libgcrypt libssh2 \
                    nfs-utils tcp_wrappers portmap rpcbind libtirpc \
                    rsync attr acl \
                    curl ntpclient \
                    procps glib2 libtirpc libffi fuse pcre \
                    udev-lib udev-extra \
                    liblvm2 \
                    parted

# Download the rootfs, don't unpack it though:
RUN curl -fL -o /tcl_rootfs.gz $TCL_REPO_BASE/release/distribution_files/rootfs64.gz

# Install the TCZ dependencies
RUN set -ex && \
    for dep in $TCZ_DEPS; do \
        echo "Download $TCL_REPO_BASE/tcz/$dep.tcz"; \
        curl -fL -o /tmp/$dep.tcz $TCL_REPO_BASE/tcz/$dep.tcz; \
        unsquashfs -f -d $ROOTFS /tmp/$dep.tcz; \
        rm -f /tmp/$dep.tcz; \
    done

# Install Tiny Core Linux rootfs
RUN cd $ROOTFS && zcat /tcl_rootfs.gz | cpio -f -i -H newc -d --no-absolute-filenames

# Apply horrible hacks
RUN cd $ROOTFS && ln -s lib lib64

# get generate_cert
RUN curl -fL -o $ROOTFS/usr/local/bin/generate_cert https://github.com/SvenDowideit/generate_cert/releases/download/0.2/generate_cert-0.2-linux-amd64 && \
    chmod +x $ROOTFS/usr/local/bin/generate_cert

#------------------------------ COMPLETE INSTALL TINYCORE ------------------------------



# Build VBox guest additions
ENV VBOX_VERSION 5.1.2
RUN mkdir -p /vboxguest
COPY VBoxGuestAdditions_${VBOX_VERSION}.iso /vboxguest
RUN set -x && \
    cd /vboxguest && \
    mv VBoxGuestAdditions_${VBOX_VERSION}.iso vboxguest.iso && \
    \
    7z x vboxguest.iso -ir'!VBoxLinuxAdditions.run' && \
    rm vboxguest.iso && \
    \
    sh VBoxLinuxAdditions.run --noexec --target . && \
    mkdir amd64 && tar -C amd64 -xjf VBoxGuestAdditions-amd64.tar.bz2 && \
    rm VBoxGuestAdditions*.tar.bz2 && \
    \
    KERN_DIR=/linux-kernel/ make -C amd64/src/vboxguest-${VBOX_VERSION} && \
    cp amd64/src/vboxguest-${VBOX_VERSION}/*.ko $ROOTFS/lib/modules/$KERNEL_VERSION-PocketCluster/ && \
    \
    mkdir -p $ROOTFS/sbin && \
    cp amd64/lib/VBoxGuestAdditions/mount.vboxsf amd64/sbin/VBoxService $ROOTFS/sbin/ && \
    mkdir -p $ROOTFS/bin && \
    cp amd64/bin/VBoxClient amd64/bin/VBoxControl $ROOTFS/bin/

# TODO figure out how to make this work reasonably (these tools try to read /proc/self/exe at startup, even for a simple "--version" check)
## verify that all the above actually worked (at least producing a valid binary, so we don't repeat issue #1157)
#RUN set -x && \
#    chroot "$ROOTFS" VBoxControl --version && \
#    chroot "$ROOTFS" VBoxService --version

# Make sure that all the modules we might have added are recognized (especially VBox guest additions)
RUN depmod -a -b $ROOTFS $KERNEL_VERSION-PocketCluster

COPY VERSION $ROOTFS/etc/version
RUN cp -v $ROOTFS/etc/version /tmp/iso/version

# Get the Docker binaries with version
COPY docker-1.10.3.tgz /tmp 
RUN cd /tmp && \
    tar -xvzf docker-1.10.3.tgz --strip-components=1 && \
    mv /tmp/local/bin/docker "$ROOTFS/usr/local/bin" && \
    rm /tmp/docker-1.10.3.tgz && \
    chroot "$ROOTFS" docker -v

# Copy our custom rootfs
COPY rootfs/rootfs $ROOTFS

# setup acpi config dir &
# tcl6's sshd is compiled without `/usr/local/sbin` in the path
# Boot2Docker and Docker Machine need `ip`, so I'm linking it in here
RUN cd $ROOTFS \
    && ln -s /usr/local/etc/acpi etc/ \
    && ln -s /usr/local/sbin/ip usr/sbin/

# These steps can only be run once, so can't be in make_iso.sh (which can be run in chained Dockerfiles)

# Make sure init scripts are executable
RUN find $ROOTFS/etc/rc.d/ $ROOTFS/usr/local/etc/init.d/ -exec chmod +x '{}' ';'

# move dhcp.sh out of init.d as we're triggering it manually so its ready a bit faster
RUN mv $ROOTFS/etc/init.d/dhcp.sh $ROOTFS/etc/rc.d/

# Make sure we have the correct bootsync
RUN mv $ROOTFS/boot*.sh $ROOTFS/opt/ && \
    chmod +x $ROOTFS/opt/*.sh

# Make sure we have the correct shutdown
RUN mv $ROOTFS/shutdown.sh $ROOTFS/opt/shutdown.sh && \
    chmod +x $ROOTFS/opt/shutdown.sh

# Add serial console
RUN echo "#!/bin/sh" > $ROOTFS/usr/local/bin/autologin && \
    echo "/bin/login -f docker" >> $ROOTFS/usr/local/bin/autologin && \
    chmod 755 $ROOTFS/usr/local/bin/autologin && \
    echo 'ttyS0:2345:respawn:/sbin/getty -l /usr/local/bin/autologin 9600 ttyS0 vt100' >> $ROOTFS/etc/inittab && \
    echo 'ttyS1:2345:respawn:/sbin/getty -l /usr/local/bin/autologin 9600 ttyS1 vt100' >> $ROOTFS/etc/inittab

# fix "su -"
RUN echo root > $ROOTFS/etc/sysconfig/superuser

# add some timezone files so we're explicit about being UTC
RUN echo 'UTC' > $ROOTFS/etc/timezone \
    && cp -L /usr/share/zoneinfo/UTC $ROOTFS/etc/localtime

# make sure the "docker" group exists already
RUN chroot "$ROOTFS" addgroup -S docker

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
# (see also rootfs/rootfs/etc/sub{uid,gid})
RUN set -x \
    && chroot "$ROOTFS" addgroup -S dockremap \
    && chroot "$ROOTFS" adduser -S -G dockremap dockremap

# Get the git versioning info
COPY pocketcluster.info $ROOTFS/etc/pocketcluster.info

# Copy boot params
COPY rootfs/isolinux /tmp/iso/boot/isolinux

COPY rootfs/make_iso.sh /
