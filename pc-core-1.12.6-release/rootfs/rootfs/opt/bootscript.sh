#!/bin/sh

# Configure sysctl
/etc/rc.d/sysctl

# Load TCE extensions
/etc/rc.d/tce-loader

# Automount a hard drive
/etc/rc.d/automount

# set the hostname
/etc/rc.d/hostname

# Trigger the DHCP request sooner (the x64 bit userspace appears to be a second slower)
echo "$(date) dhcp -------------------------------"
/etc/rc.d/dhcp.sh
echo "$(date) dhcp -------------------------------"

# Mount cgroups hierarchy
/etc/rc.d/cgroupfs-mount
# see https://github.com/tianon/cgroupfs-mount

mkdir -p /var/lib/boot2docker/log

# Add any custom certificate chains for secure private registries
/etc/rc.d/install-ca-certs

# import settings from profile (or unset them)
test -f "/var/lib/boot2docker/profile" && . "/var/lib/boot2docker/profile"

# sync the clock
/etc/rc.d/ntpd &

# start cron
/etc/rc.d/crond

# Preload data from disk
if [ -e "/var/lib/boot2docker/userdata.tar" ]; then
    tar xvf /var/lib/boot2docker/userdata.tar -C /etc/pocket > /var/log/userdata.log 2>&1
    rm -f '/etc/pocket/pc-core, please format-me'
    # since userdata is now persisted, we can safely remove it
    rm -f /var/lib/boot2docker/userdata.tar
fi

# User Creation
if [ -f "/etc/pocket/core.user.name" ]; then
    CORE_USER=$(cat /etc/pocket/core.user.name)
    CORE_UID=$(cat /etc/pocket/core.user.uid)
    CORE_GID=$(cat /etc/pocket/core.user.gid)
    echo "Adding Core User \"${CORE_USER}\""
    /bin/adduser -g "PocketCluster Core User" -s /bin/false -G docker -D -u ${CORE_UID} ${CORE_USER}
fi

# Automount Shared Folders (VirtualBox, etc.); start VBox services
/etc/rc.d/vbox

# Launch ACPId
/etc/rc.d/acpid

echo "-------------------"
date
#maybe the links will be up by now - trouble is, on some setups, they may never happen, so we can't just wait until they are
sleep 5
date
ip a
echo "-------------------"

# Launch PocketD w/ log cleanup
cat /dev/null > /var/lib/boot2docker/pocket.log
/etc/rc.d/pocket

# Launch Docker w/ log cleanup
cat /dev/null > /var/lib/boot2docker/docker.log
/etc/rc.d/docker
