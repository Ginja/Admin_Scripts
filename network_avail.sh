#!/bin/bash

# Including functions inside rc.common
. /etc/rc.common

# Calling one of those functions we included
CheckForNetwork

# Looping until we know the network is available
while [ "${NETWORKUP}" != "-YES-" ]
do
        sleep 5
        NETWORKUP=""
        CheckForNetwork
done