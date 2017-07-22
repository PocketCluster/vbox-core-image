# Boot2Docker -> PocketCore ToDo

## Kernel

- [x] Kernel Config & Rename

## Build

- [x] `Makefile` to extract iso


## Boot

- [ ] ISOLINUX
  * what is `isolinux` ?
  * isolinux.cfg
  * boot.msg
  * default : boo2docker
  * label boot2docker


## ISO builds

- [x] Incorporated `.git` information to `/etc/pc-core` detail
- [x] Keep some handy symlinks (so these things are easier to find).
  * `ln -fs /var/lib/boot2docker/docker.log $ROOTFS/var/log/`
  * `ln -fs /usr/local/etc/init.d/docker $ROOTFS/etc/init.d/`

- [x] Rebrand ISO to `PocketCluster Core`
- [x] Rename ISO name to `pc-core`


## Network

- [ ] Remove SSH connection
- [ ] Remove IP command


## Version & Naming

- [ ] `${ROOTFS}/etc/boot2docker` rename


## Rootfs


## Utils

- [ ] Remove Serial Console
