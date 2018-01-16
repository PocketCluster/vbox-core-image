FROM ubuntu:xenial

RUN apt-get update && apt-get -y install \
                        unzip \
                        xz-utils \
                        curl \
                        bc \
                        git \
                        build-essential \
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
                        p7zip-full \
# (2018/01/15:stkim1) dependencies for dockerd
                        libapparmor-dev \
                        libsystemd-dev \
                        liblvm2-dev \
                        libseccomp-dev \
                        tzdata \
                        --no-install-recommends

# https://www.kernel.org/
ENV KERNEL_VERSION  4.4.76

# Fetch the kernel sources
COPY linux-$KERNEL_VERSION.tar.xz /tmp
RUN tar -xvJf /tmp/linux-$KERNEL_VERSION.tar.xz -C / && \
    mv /linux-$KERNEL_VERSION /linux-kernel


# http://aufs.sourceforge.net/
ENV AUFS_REPO       https://github.com/sfjro/aufs4-standalone
ENV AUFS_BRANCH     aufs4.4
ENV AUFS_COMMIT     63b3136735b9e84a467e9d430a0c9d90a2963ce3
# we use AUFS_COMMIT to get stronger repeatability guarantees

# Download AUFS and apply patches and files, then remove it
COPY ${AUFS_BRANCH}-${AUFS_COMMIT}.tar.gz /tmp
RUN tar -xvzf /tmp/${AUFS_BRANCH}-${AUFS_COMMIT}.tar.gz -C / && \
    cd /linux-kernel && \
    cp -r /aufs-standalone/Documentation /linux-kernel && \
    cp -r /aufs-standalone/fs /linux-kernel && \
    cp -r /aufs-standalone/include/uapi/linux/aufs_type.h /linux-kernel/include/uapi/linux/ && \
    set -e && for patch in \
        /aufs-standalone/aufs*-kbuild.patch \
        /aufs-standalone/aufs*-base.patch \
        /aufs-standalone/aufs*-mmap.patch \
        /aufs-standalone/aufs*-standalone.patch \
        /aufs-standalone/aufs*-loopback.patch \
    ; do \
        patch -p1 < "$patch"; \
    done

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
ENV LIBCAP2_VERSION 2.22

COPY libcap2_${LIBCAP2_VERSION}.orig.tar.gz /tmp
RUN tar -xvzf /tmp/libcap2_${LIBCAP2_VERSION}.orig.tar.gz -C / && \
    cd /libcap-2.22 && \
    sed -i 's/LIBATTR := yes/LIBATTR := no/' Make.Rules && \
    make && \
    mkdir -p output && \
    make prefix=`pwd`/output install && \
    mkdir -p $ROOTFS/usr/local/lib && \
    cp -av `pwd`/output/lib64/* $ROOTFS/usr/local/lib

# Make sure the kernel headers are installed for aufs-util, and then build it
ENV AUFS_UTIL_REPO    git://git.code.sf.net/p/aufs/aufs-util
ENV AUFS_UTIL_BRANCH  aufs4.1
ENV AUFS_UTIL_COMMIT  bb75870054af06f3e76353de06a4894e9ccb0c5a

COPY aufs-util-${AUFS_UTIL_BRANCH}-${AUFS_UTIL_COMMIT}.tar.gz /tmp
RUN set -ex \
  && tar -xvzf /tmp/aufs-util-${AUFS_UTIL_BRANCH}-${AUFS_UTIL_COMMIT}.tar.gz -C / \
	&& make -C /linux-kernel headers_install INSTALL_HDR_PATH=/tmp/kheaders \
	&& export CFLAGS='-I/tmp/kheaders/include' \
	&& export CPPFLAGS="$CFLAGS" LDFLAGS="$CFLAGS" \
	&& make -C /aufs-util \
	&& make -C /aufs-util install DESTDIR="$ROOTFS" \
	&& rm -r /tmp/kheaders


# Prepare the ISO directory with the kernel
RUN cp -v /linux-kernel/arch/x86_64/boot/bzImage /tmp/iso/boot/vmlinuz64

ENV TCL_REPO_BASE   http://distro.ibiblio.org/tinycorelinux/7.x/x86_64
# Note that the ncurses is here explicitly so that top continues to work
ENV TCZ_DEPS        iptables \
                    iproute2 \
                    openssl \
                    tar \
                    gcc_libs \
                    ncurses \
                    acpid \
                    xz liblzma \
                    git expat2 libgpg-error libgcrypt \
                    nfs-utils tcp_wrappers portmap rpcbind libtirpc \
                    rsync attr acl \
                    curl ntpclient \
                    procps glib2 libtirpc libffi fuse pcre \
                    udev-lib udev-extra \
                    liblvm2 \
                    parted

# Download the rootfs, don't unpack it though:
COPY tcl_rootfs.gz /tmp
COPY /TCZDEPS /tmp

# Install the TCZ dependencies
RUN set -ex; \
	for dep in $TCZ_DEPS; do \
		echo "Extracting $TCL_REPO_BASE/tcz/$dep.tcz"; \
		unsquashfs -f -d "$ROOTFS" "/tmp/$dep.tcz"; \
#		rm -f "/tmp/$dep.tcz"; \
	done

# Install Tiny Core Linux rootfs
RUN cd "$ROOTFS" && zcat /tmp/tcl_rootfs.gz | cpio -f -i -H newc -d --no-absolute-filenames

# Extract ca-certificates
RUN set -x \
#  TCL changed something such that these need to be extracted post-install
	&& chroot "$ROOTFS" sh -xc 'ldconfig && /usr/local/tce.installed/openssl' \
#  Docker looks for them in /etc/ssl
	&& ln -sT ../usr/local/etc/ssl "$ROOTFS/etc/ssl" \
#  a little testing is always prudent
	&& cp "$ROOTFS/etc/resolv.conf" resolv.conf.bak \
	&& cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf" \
	&& chroot "$ROOTFS" curl -fsSL 'https://www.google.com' -o /dev/null \
	&& mv resolv.conf.bak "$ROOTFS/etc/resolv.conf"

# Apply horrible hacks
RUN ln -sT lib "$ROOTFS/lib64" \
# (2018/01/15:stkim1) dependencies for dockerd
    && ln -sT /usr/lib/x86_64-linux-gnu "$ROOTFS/usr/lib/x86_64-linux-gnu"

# get generate_cert
COPY generate_cert $ROOTFS/usr/local/bin/generate_cert
RUN chmod +x $ROOTFS/usr/local/bin/generate_cert


# Build VBox guest additions
#   http://download.virtualbox.org/virtualbox/
ENV VBOX_VERSION 5.1.30
#   https://www.virtualbox.org/download/hashes/$VBOX_VERSION/SHA256SUMS
ENV VBOX_SHA256 631ca8e8d513acf43a75de56a71a31aaffb5624864c57d10346ba657d991ec1e
#   (VBoxGuestAdditions_X.Y.Z.iso SHA256, for verification)

RUN mkdir -p /vboxguest
COPY vboxguest.iso /vboxguest
RUN set -x && \
    \
    cd /vboxguest && \
    echo "${VBOX_SHA256} *vboxguest.iso" | sha256sum -c - && \
    7z x vboxguest.iso -ir'!VBoxLinuxAdditions.run' && \
    rm vboxguest.iso && \
    \
    sh VBoxLinuxAdditions.run --noexec --target . && \
    mkdir amd64 && tar -C amd64 -xjf VBoxGuestAdditions-amd64.tar.bz2 && \
    rm VBoxGuestAdditions*.tar.bz2 && \
    \
    KERN_DIR=/linux-kernel/ make -C amd64/src/vboxguest-${VBOX_VERSION} && \
    cp amd64/src/vboxguest-${VBOX_VERSION}/*.ko $ROOTFS/lib/modules/$KERNEL_VERSION/ && \
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
RUN depmod -a -b "$ROOTFS" "$KERNEL_VERSION"

COPY VERSION $ROOTFS/etc/version
RUN cp -v "$ROOTFS/etc/version" /tmp/iso/version

# (2018/01/15:stkim1) use custom docker version
ENV DOCKER_VERSION "1.14"

COPY pcdckrd-binary-x86_64-${DOCKER_VERSION}.tar.gz /tmp
RUN set -ex \
    && tar -xvzf /tmp/pcdckrd-binary-x86_64-${DOCKER_VERSION}.tar.gz -C "$ROOTFS/usr/local/bin" --strip-components=1 \
    && rm /tmp/pcdckrd-binary-x86_64-${DOCKER_VERSION}.tar.gz \
# (2018/01/16:stkim1) this does not show lib dependencies in image created, but here to check it anyway
    && ldd "${ROOTFS}/usr/local/bin/pcdckrd" \
    && "${ROOTFS}/usr/local/bin/dockerd" -v

# Remove used deps
RUN set -ex \
  && (rm /tmp/*.tgz || true) \
  && (rm /tmp/*.tcz || true) \
  && (rm /tmp/*.gz || true) \
  && (rm /tmp/*.xz || true)

# Copy our custom rootfs
COPY rootfs/rootfs $ROOTFS

# --- need cleanup ---


# setup acpi config dir &
# tcl6's sshd is compiled without `/usr/local/sbin` in the path
# Boot2Docker and Docker Machine need `ip`, so link it elsewhere
RUN ln -svT /usr/local/etc/acpi "$ROOTFS/etc/acpi" \
	&& ln -svT /usr/local/sbin/ip "$ROOTFS/usr/sbin/ip"

# These steps should only be run once, so can't be in make_iso.sh (which can be run in chained Dockerfiles)
# see https://github.com/boot2docker/boot2docker/blob/master/doc/BUILD.md

# Make sure init scripts are executable
RUN find "$ROOTFS/etc/rc.d/" "$ROOTFS/usr/local/etc/init.d/" -type f -exec chmod --changes +x '{}' +

# move dhcp.sh out of init.d as we're triggering it manually so its ready a bit faster
RUN mv -v "$ROOTFS/etc/init.d/dhcp.sh" "$ROOTFS/etc/rc.d/"

# Add serial console
RUN set -ex; \
	for s in 0 1 2 3; do \
		echo "ttyS${s}:2345:respawn:/usr/local/bin/forgiving-getty ttyS${s}" >> "$ROOTFS/etc/inittab"; \
	done; \
	cat "$ROOTFS/etc/inittab"

# fix "su -"
RUN echo root > "$ROOTFS/etc/sysconfig/superuser"

# add some timezone files so we're explicit about being UTC
RUN echo 'UTC' > "$ROOTFS/etc/timezone" \
    && cp -vL /usr/share/zoneinfo/Etc/UTC "$ROOTFS/etc/localtime"

# make sure the "docker" group exists already
RUN chroot "$ROOTFS" addgroup -S docker

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
# (see also rootfs/rootfs/etc/sub{uid,gid})
RUN set -x \
	&& chroot "$ROOTFS" addgroup -S dockremap \
	&& chroot "$ROOTFS" adduser -S -G dockremap dockremap

# Get the git versioning info
COPY .git /git/.git
RUN set -ex \
	&& GIT_BRANCH="$(git -C /git rev-parse --abbrev-ref HEAD)" \
	&& GITSHA1="$(git -C /git rev-parse --short HEAD)" \
	&& DATE="$(date)" \
	&& echo "${GIT_BRANCH} : ${GITSHA1} - ${DATE}" \
		| tee "$ROOTFS/etc/pc-core"

# Copy boot params
COPY rootfs/isolinux /tmp/iso/boot/isolinux

COPY rootfs/make_iso.sh /tmp/make_iso.sh

# Following two steps are separated in Makefile
#RUN /tmp/make_iso.sh
#CMD ["sh", "-c", "[ -t 1 ] && exec bash || exec cat boot2docker.iso"]
