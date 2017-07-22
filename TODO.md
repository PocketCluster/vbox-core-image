# Boot2Docker -> PocketCore ToDo

## Kernel

- [x] Kernel Config & Rename

## Build

- [x] `Makefile` to extract iso


## ISO builds (`/make_iso.sh`)

- [x] Incorporated `.git` information to `/etc/pc-core` detail
- [x] Keep some handy symlinks (so these things are easier to find).
  * `ln -fs /var/lib/boot2docker/docker.log $ROOTFS/var/log/`
  * `ln -fs /usr/local/etc/init.d/docker $ROOTFS/etc/init.d/`

- [x] Rebrand ISO to `PocketCluster Core`
- [x] Rename ISO name to `pc-core`
- [x] `${ROOTFS}/etc/boot2docker` -> `${ROOTFS}/etc/pc-core`


## Boot

- [ ] ISOLINUX
  * what is `isolinux` ?
  * isolinux.cfg
  * boot.msg
  * default : boo2docker
  * label boot2docker


## Rootfs
- [x] Rebrand `/opt/bootsync.sh`
- [x] Rebrand `/opt/shutdown.sh`
- [x] Rebrand `/etc/profile.d/boot2docer` -> `/etc/profile.d/pc-core`
  * Can we remove it?

- [x] Remove Parallels (prltoolsd)/ Xen (xedaemon)/ VMWare (vmtoolsd)/ Hyper-V KVP Supports
- [x] Remove `/rootfs/etc/rc.d/automated_script.sh`

## Network

- [ ] Remove SSH connection
- [ ] Remove IP command


## Utils

- [ ] Remove Serial Console
