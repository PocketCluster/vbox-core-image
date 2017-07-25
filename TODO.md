# Boot2Docker -> PocketCore ToDo

## Kernel

- [x] Kernel Config & Rename
 * `CONFIG_DEFAULT_HOSTNAME` is set to `pc-core`
 * `CONFIG_LOCALVERSION` is not set
 * `CONFIG_VXLAN=y` (VXLAN for container cluster network)


## Build (Dockerfile + Makefile)

- [x] `Makefile` to extract iso
- [x] [`openssh`](doc/openssh.tcz.info), [`libssh2`](doc/libssh2.tcz.info) removed from TinyCore Extension list

## ISO builds (`/make_iso.sh`)

- [x] Incorporated `.git` information to `/etc/pc-core` detail
- [x] Keep some handy symlinks (so these things are easier to find).
  * `ln -fs /var/lib/boot2docker/docker.log $ROOTFS/var/log/`
  * `ln -fs /usr/local/etc/init.d/docker $ROOTFS/etc/init.d/`

- [x] Rebrand ISO to `PocketCluster Core`
- [x] Rename ISO name to `pc-core`
- [x] `${ROOTFS}/etc/boot2docker` -> `${ROOTFS}/etc/pc-core`


## ISOLINUX

- [x] What is SYSLINUX

  * <http://www.syslinux.org/wiki/index.php?title=SYSLINUX#What_is_SYSLINUX.3F>
  * `isolinux.cfg` <http://www.tinycorelinux.net/corebook.pdf>
- [x] Rebrand logo `/rootfs/isolinux/boot.msg`
- [ ] Bootcode changed

  * `label pc-core` become default
  * `waitusb=10:LABEL=pc-core-data` (wait 10s for `pc-core-data` volume)
  * ~~`user=docker`~~ (create & default user : `docker`)
- [ ] Remove Serial Console


## Rootfs

- [x] Rebrand `/opt/bootsync.sh`
- [x] Rebrand `/opt/shutdown.sh`
- [x] Rebrand `/etc/profile.d/boot2docker` -> `/etc/profile.d/pc-core` (**Can we remove it?**)
- [x] Rebrand `/usr/local/etc/hostname` : boot2docker -> pc-core
- [x] Rebrand `/etc/motd`

- [x] Remove Parallels (prltoolsd)/ Xen (xedaemon)/ VMWare (vmtoolsd)/ Hyper-V KVP Supports
- [x] Remove `/rootfs/etc/rc.d/automated_script.sh`
- [x] Remove `/etc/rc.d/sshd`

- [x] Disable IPv6 `/etc/rc.d/sysctl.conf`


#### `/opt/bootsync.sh`

TinyCore (TC) boot chain : `/opt/bootsync.sh` -> `/opt/bootscript.sh` -> `/etc/rc.d/*`

> If you want commands executed every time you start the computer, add them to /opt/bootsync.sh or /opt/bootlocal.sh.  
> /opt/bootsync.sh is run early in the boot process.  
> /opt/bootlocal.sh is run later in the boot process.  
> Most commands should go in /opt/bootlocal.sh, except commands you want executed early in the boot process.  
- <http://wiki.tinycorelinux.net/wiki:bootlocal.sh_and_shutdown.sh>  


#### `/opt/bootscript.sh`

- [x] Extract `userdata.tar` to /
- [x] Remove `/etc/rc.d/sshd`
- [x] Remove custom bootsync

  ```diff
  -# Allow local bootsync.sh customisation
  -if [ -e /var/lib/boot2docker/bootsync.sh ]; then
  -    /bin/sh /var/lib/boot2docker/bootsync.sh
  -    echo "------------------- ran /var/lib/boot2docker/bootsync.sh"
  -fi
  ```
- [x] Remove custom hdd

  ```diff
  -# Allow local HD customisation
  -if [ -e /var/lib/boot2docker/bootlocal.sh ]; then
  -    /bin/sh /var/lib/boot2docker/bootlocal.sh > /var/log/bootlocal.log 2>&1 &
  -    echo "------------------- ran /var/lib/boot2docker/bootlocal.sh"
  -fi
  ```
- [x] Remove `docker` user handling

  ```diff
  -# TODO: move this (and the docker user creation&pwd out to its own over-rideable?))
  -if grep -q '^docker:' /etc/passwd; then
  -    # if we have the docker user, let's add it do the docker group
  -    /bin/addgroup docker docker
  -
  -    #preload data from boot2docker-cli
  -    if [ -e "/var/lib/boot2docker/userdata.tar" ]; then
  -        tar xf /var/lib/boot2docker/userdata.tar -C / > /var/log/userdata.log 2>&1
  -        rm -f '/home/docker/boot2docker, please format-me'
  -        chown -R docker:staff /home/docker
  -    fi
  -fi
  ```
- [x] Add Core User creation from `/etc/pocket/core.user.name`


#### `/etc/rc.d/automount`

- [x] Change the magic word to `pc-core, please format-me`
- [x] Remove _VMWare partition mount_ part
- [ ] Formalize swap space size
- [x] Remove old way of using persistent hdd (line 81)

  ```diff
  -    if [ -d /mnt/$PARTNAME/vm ]; then
  -        # The old behavior - use the entire disk for boot2docker data
  -        ln -s /mnt/$PARTNAME /var/lib/docker

  -        # Give us a link to the new cusomisation location
  -        ln -s /var/lib/docker/vm /var/lib/boot2docker
  -    else
  ```
- [x] link to /etc/pocket -> /mnt/$PARTNAME/etc/pocket


## Misc

- [x] Remove SSH Daemon
- [ ] Remove Serial Access
- [ ] Remove `ip` command
- [ ] Remove autologin
- [ ] Remove forgiving-getty
- [ ] Gerenrate Certificate with Network Interface `eth0` if possible
- [ ] Docker should listen one interface `eth1`


## Certificate to Disk

- [x] Extraction target patch changed to `/etc/pocket`
- [x] Change the magic word to `pc-core, please format-me`
- [x] Pre-generate Cluster ID
- [x] Pre-generate Teleport HostUUID
- [x] Add Username
- [x] Pre-generate Master Pubkey/Core Private, Public Keys
- [x] Pre-generate Docker TLS AUTHCERT/KEYCERTS/PRVKEY


## Boot

- [ ] Segfault for disable ipv6


## Backport to PocketCluster Node

- [ ] TinyCore
- [ ] Repartition
- [ ] User Namespace Remap

  * <https://docs.oracle.com/cd/E37670_01/E75728/html/ol-docker-userns-remap.html>
  * <https://docs.docker.com/edge/engine/reference/commandline/dockerd/#daemon-user-namespace-options>
- [ ] Disable Docker when there is no TLS certs available
- [ ] Append 'CA' <http://rt.openssl.org/Ticket/History.html?user=guest&pass=guest&id=3979>
- [ ] Run `dockerd` with script and check conditions there.
