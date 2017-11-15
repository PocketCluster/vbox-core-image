#!/bin/sh
. /etc/init.d/tc-functions

echo "${YELLOW}Running pc-core init script...${NORMAL}"

# This log is started before the persistence partition is mounted
/opt/bootscript.sh 2>&1 | tee -a /var/log/pc-core.log


echo "${YELLOW}Finished pc-core init script...${NORMAL}"
