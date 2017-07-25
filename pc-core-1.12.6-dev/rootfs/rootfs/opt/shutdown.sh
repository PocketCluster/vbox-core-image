#!/bin/sh
. /etc/init.d/tc-functions

echo "${YELLOW}Running pc-core shutdown script...${NORMAL}"

/usr/local/etc/init.d/docker stop
