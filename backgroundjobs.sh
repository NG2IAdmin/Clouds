#!/bin/bash

# To get list of machines
SUBNET=$(ifconfig | grep "inet addr" | grep Bcast | awk '{print $2}' | awk -F"." '{print $3}')
CMD="( nmap -v 192.168.$SUBNET.1-127 | grep \"port 22/\" | awk '{print $6}')"

MACHINES=$( eval $CMD | awk -F"." '{print $NF}' )
OWNIP=$( ifconfig | grep "inet addr" | grep Bcast | awk '{print $2}' | awk -F"." '{print $NF}')
NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )

echo $OWNIP $NCPUS > ipCPUList.txt

for MACHINE in $MACHINES
do
	if [ $MACHINE -eq $OWNIP ]; then continue; fi
	if [ $MACHINE -eq 1 ]; then continue; fi
	# if [ $MACHINE -eq 51 ]; then continue; fi # For raspberry pi, not needed anymore
	NCPU=$( ssh ng2i@192.168.$SUBNET.$MACHINE cat /proc/cpuinfo | awk {'print $1'} | grep processor | wc -l)
	if [ $NCPU -eq 1 ]; then
		echo "Possible IP of the Camera is 192.168."$SUBNET"."$MACHINE
		echo "Use "$MACHINE "as argument 2 of paralleljpeg.sh"
		continue;
	fi
	echo $MACHINE $NCPU >> ipCPUList.txt
done

tail -n +2 "ipCPUList.txt" > "ipCPUListUpd.txt"
