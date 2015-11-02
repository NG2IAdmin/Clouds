#!/bin/bash

# To get list of machines
MACHINES=$( nmap -v 192.168.1.1-15 | grep "port 22/" | awk '{print $6}' | awk -F"." '{print $NF}')
OWNIP=$( ifconfig | grep "inet addr" | grep Bcast | awk '{print $2}' | awk -F"." '{print $NF}')
NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )

echo $OWNIP $NCPUS > ipCPUList.txt

for MACHINE in $MACHINES
do
	if [ $MACHINE -eq $OWNIP ]; then continue; fi
	if [ $MACHINE -eq 1 ]; then continue; fi
	if [ $MACHINE -eq 4 ]; then continue; fi # For raspberry pi
	NCPU=$( ssh ng2i@192.168.1.$MACHINE cat /proc/cpuinfo | grep processor | wc -l)
	echo $MACHINE $NCPU >> ipCPUList.txt
done

tail -n +2 "ipCPUList.txt" > "ipCPUListUpd.txt"
