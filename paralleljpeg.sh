#!/bin/bash 

if [ "$#" -ne 5 ]; then
	echo "provide arguments as " $0 "CameraIP InFileName OutFileName MaskWidth PeakWidth"
	echo "For example:"
	echo '              ' $0 "4 trial.jpg trial2.jpg 11 1.2"
	exit 1
fi

# To get list of machines
nmap -v 192.168.1.1-15 | grep "port 22/" | awk '{print $6}' | awk -F"." '{print $NF}'
ifconfig | grep "inet addr" | grep Bcast | awk '{print $2}' | awk -F"." '{print $NF}'
ssh ng2i@192.168.1.10 cat /proc/cpuinfo | grep processor | wc -l


# ssh pi@192.168.1.$1 raspistill -o $2
# scp pi@192.168.1.$1:$2 .

NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )
for ((i=1;i<=NCPUS;i++))
do
	bin/iojpegparts $2 $3 $4 $5 $i $NCPUS &
done
wait

bin/combinefun $3 $3 $NCPUS 
rm $3_part*
