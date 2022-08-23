#!/bin/bash

SCRIPT=`basename "$0"`

TV_IP=$1
if [ -z $TV_IP ]; then
    echo "Usage: $SCRIPT TV_IP [TV_NAME]"
    echo
    echo "The TV_IP argument is the IP address of the Tizen-based Samsung TV on"
    echo "which you want to install Jellyfin."
    echo
    echo "The TV_NAME argument is the internal name of the TV you will connect to."
    echo "This installer will try to find it for your automatically once connected"
    echo "to the TV."
    exit 1
fi
/opt/tizen/tizen-studio/tools/sdb connect $TV_IP >/tmp/sdb-connect.log

if grep -q "error:" /tmp/sdb-connect.log; then
    cat /tmp/sdb-connect.log
    exit 1
fi

TV_NAME=$2
if [ -z $TV_NAME ]; then
    /opt/tizen/tizen-studio/tools/sdb devices >/tmp/sdb-devices.log
    TV_NAME=`tail --lines=+2 /tmp/sdb-devices.log | sed -E "s/.*device\s+(.*)$/\1/"`
    echo "Found TV: $TV_NAME"
    echo
fi
if [ -z $TV_NAME ]; then
    echo "Could not find your TV name automatically."
    echo
    echo "Please provide the TV_NAME argument from the listing below:"
    echo -e "IP:port\t\t\tStatus\t\tName"
    tail --lines=+2 /tmp/sdb-devices.log
    echo
    echo "Usage: $SCRIPT $TV_IP TV_NAME"
    exit 1
fi

ulimit -n 10000
/opt/tizen/tizen-studio/tools/ide/bin/tizen install -n /opt/Jellyfin.wgt -t $TV_NAME
