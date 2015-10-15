#!/bin/bash 

ssh pi@192.168.1.$1 raspistill -o $2
scp pi@192.168.1.$1:$2 .

NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )
for ((i=1;i<=NCPUS;i++))
do
	./iojpegparts $2 $3 $4 $5 $i $NCPUS &
done
wait
