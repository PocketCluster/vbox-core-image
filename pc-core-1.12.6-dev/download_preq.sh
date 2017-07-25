#!/usr/bin/env bash

set -x

# --- Fetch the kernel sources ---
#   https://www.kernel.org/
export KERNEL_VERSION=${KERNEL_VERSION:-4.4.76}

curl -o ${PWD}/linux-$KERNEL_VERSION.tar.xz --retry 10 https://www.kernel.org/pub/linux/kernel/v${KERNEL_VERSION%%.*}.x/linux-$KERNEL_VERSION.tar.xz


# --- Download AUFS. We use AUFS_COMMIT to get stronger repeatability guarantees ---
#   http://aufs.sourceforge.net/
export AUFS_REPO=${AUFS_REPO:-"https://github.com/sfjro/aufs4-standalone"}
export AUFS_BRANCH=${AUFS_BRANCH:-"aufs4.4"}
export AUFS_COMMIT=${AUFS_COMMIT:-"63b3136735b9e84a467e9d430a0c9d90a2963ce3"}

pushd ${PWD}
git clone -b "$AUFS_BRANCH" "$AUFS_REPO" aufs-standalone
cd aufs-standalone
git checkout -q "$AUFS_COMMIT"
popd
tar -cvzf "${PWD}/${AUFS_BRANCH}-${AUFS_COMMIT}.tar.gz" ./aufs-standalone
rm -rf ${PWD}/aufs-standalone


# --- Install libcap ---
#    http://http.debian.net/debian/pool/main/libc/libcap2/
export LIBCAP2_VERSION=${LIBCAP2_VERSION-"2.22"}

curl -fL -o ${PWD}/libcap2_${LIBCAP2_VERSION}.orig.tar.gz http://http.debian.net/debian/pool/main/libc/libcap2/libcap2_${LIBCAP2_VERSION}.orig.tar.gz


# --- Make sure the kernel headers are installed for aufs-util, and then build it ---
export AUFS_UTIL_REPO=${AUFS_UTIL_REPO:-"git://git.code.sf.net/p/aufs/aufs-util"}
export AUFS_UTIL_BRANCH=${AUFS_UTIL_BRANCH:-"aufs4.1"}
export AUFS_UTIL_COMMIT=${AUFS_UTIL_COMMIT:-"bb75870054af06f3e76353de06a4894e9ccb0c5a"}

git clone -b ${AUFS_UTIL_BRANCH} ${AUFS_UTIL_REPO} ${PWD}/aufs-util
pushd ${PWD}
cd ${PWD}/aufs-util
git checkout --quiet ${AUFS_UTIL_COMMIT}
popd
tar -cvzf "${PWD}/aufs-util-${AUFS_UTIL_BRANCH}-${AUFS_UTIL_COMMIT}.tar.gz" ./aufs-util
rm -rf ${PWD}/aufs-util


# --- Tiny Core Linux rootfs ---
export TCL_REPO_BASE=${TCL_REPO_BASE:-"http://distro.ibiblio.org/tinycorelinux/7.x/x86_64"}
# Note that the ncurses is here explicitly so that top continues to work
export TCZ_DEPS=(iptables iproute2 openssh openssl tar gcc_libs ncurses acpid xz liblzma git expat2 libgpg-error libgcrypt libssh2 nfs-utils tcp_wrappers portmap rpcbind libtirpc rsync attr acl curl ntpclient procps glib2 libtirpc libffi fuse pcre udev-lib udev-extra liblvm2 parted)

# Download the TCL rootfs
curl -fL -o tcl_rootfs.gz $TCL_REPO_BASE/release/distribution_files/rootfs64.gz

# Download the TCZ dependencies
mkdir -p ${PWD}/TCZDEPS
for dep in ${TCZ_DEPS[@]}; do
	echo "Download $TCL_REPO_BASE/tcz/$dep.tcz"
	curl -fSL -o "${PWD}/TCZDEPS/$dep.tcz" "$TCL_REPO_BASE/tcz/$dep.tcz"
done


# --- get generate_cert ---
curl -fL -o generate_cert https://github.com/SvenDowideit/generate_cert/releases/download/0.2/generate_cert-0.2-linux-amd64


# --- Build VBox guest additions ---
#   http://download.virtualbox.org/virtualbox/
#   https://www.virtualbox.org/download/hashes/$VBOX_VERSION/SHA256SUMS
#   (VBoxGuestAdditions_X.Y.Z.iso SHA256, for verification)
export VBOX_VERSION=${VBOX_VERSION:-5.1.22}
export VBOX_SHA256=${VBOX_SHA256:-54df14f234b6aa484b94939ab0f435b5dd859417612b65a399ecc34a62060380}

curl -fL -o ${PWD}/vboxguest.iso http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso
echo "${VBOX_SHA256} *vboxguest.iso" | sha256sum -c -


# --- Get the Docker ---
export DOCKER_VERSION=${DOCKER_VERSION:-"1.12.6"}

curl -fSL -o ${PWD}/docker-${DOCKER_VERSION}.tgz "https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz"


# --- Get GoLang ---
#export GOLANG_VERSION=${GOLANG_VERSION:="1.7.6"}
#
#curl -fSL -o ${PWD}/go${GOLANG_VERSION}.linux-amd64.tar.gz  "https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz"
