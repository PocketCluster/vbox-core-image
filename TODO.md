# Boot2Docker -> PocketCore ToDo

## Kernel

- [x] Kernel Config & Rename
 * `CONFIG_DEFAULT_HOSTNAME` is set to `pc-core`
 * `CONFIG_LOCALVERSION` is not set
 * `CONFIG_VXLAN=y` (VXLAN for container cluster network)

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


## ISOLINUX

- [x] Rebrand logo `/rootfs/isolinux/boot.msg`
- [ ] ISOLINUX
  * what is `isolinux` ?
  * isolinux.cfg
  * boot.msg
  * default : boo2docker
  * label boot2docker


## Rootfs

- [x] Rebrand `/opt/bootsync.sh`
- [x] Rebrand `/opt/shutdown.sh`
- [x] Rebrand `/etc/profile.d/boot2docker` -> `/etc/profile.d/pc-core` (**Can we remove it?**)
- [x] Rebrand `/usr/local/etc/hostname` : boot2docker -> pc-core
- [x] Rebrand `/etc/motd`

- [x] Remove Parallels (prltoolsd)/ Xen (xedaemon)/ VMWare (vmtoolsd)/ Hyper-V KVP Supports
- [x] Remove `/rootfs/etc/rc.d/automated_script.sh`
- [x] Remove `/etc/rc.d/sshd`

- [ ] Clean up `/etc/rc.d/automount`
  * Remove _VMWare partition mount_ part

- [ ] Clean up `/opt/bootscript.sh`
  * extract `userdata.tar` to /
  * Remove `/etc/rc.d/sshd`
  * Remove customization


## Network

- [ ] Remove SSH Daemon
- [ ] Remove IP command
- [ ] Remove Serial Access


## Utils

- [ ] Remove Serial Console


## Certificate to Disk

- [x] Pre-generate Cluster ID
- [x] Pre-generate Teleport HostUUID
- [x] Add Username
- [x] Pre-generate TCP TLS AUTHCERT/KEYCERTS/PRVKEY
- [ ] Pre-generate Docker TLS AUTHCERT/KEYCERTS/PRVKEY
