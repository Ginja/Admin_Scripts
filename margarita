#!/bin/bash
#
# Author: Riley Shott (https://github.com/Ginja/Admin_Scripts)
#
# margarita        Startup script for the maragita webinterface
#
# chkconfig: 356 90 20
# description: Margarita is a web front-end to reposado
# the Apple Software Update replication and
# catalog management tool. This script has only been tested
# on RHEL 6, and would need modification before use on a Debian
# flavour of Linux.
 
# Source function library
. /etc/rc.d/init.d/functions
 
# Variables
PID=$(ps aux | grep "[p]ython /var/www/margarita/margarita.py" | awk '{print $2}')
RETVAL=0
 
# Methods
start()
{
 echo -n "Starting margarita: "
 if [ -z $PID ]; then
 	python /var/www/margarita/margarita.py -b ip_address_here &> /var/log/margarita.log &
 	RETVAL=$?
	if [ $RETVAL -eq 0 ]
		then success
		else failure
	fi
 	echo
 	return $RETVAL
 else
 	failure
 	RETVAL=1
 	echo "Margarita already running: "
 	return $RETVAL
 fi
}
 
stop()
{
 echo -n "Stopping margarita: "
 if [ $PID ]; then
 	kill $PID
 RETVAL=$?
	if [ $RETVAL -eq 0 ]
 		then success
 		else failure
	fi
 	PID=""
 	echo
 	return $RETVAL
 else
 	failure
 	RETVAL=1
 	echo "Maragarita wasn't running: "
 	return $RETVAL
 fi
}
 
# Punch it
case "$1" in
start)
  start
;;
stop)
  stop
;;
restart)
  stop
  start
;;
*)
  echo $"Usage: $0 {start|stop|restart}"
  exit 1
esac
 
exit $RETVAL