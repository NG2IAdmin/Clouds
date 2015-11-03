#!/bin/bash 

if [ "$#" -ne 5 ]; then
	echo "provide arguments as " $0 "CameraIP InFileName OutFileName MaskWidth PeakWidth"
	echo "For example:"
	echo '              ' $0 "4 trial.jpg trial2.jpg 11 1.2"
	echo ' If you want to provide your own file, give CameraIP equal to 0.'
	exit 1
fi

IPs=$( cat ipCPUListUpd.txt | awk '{print $1}')
CPUs=$( cat ipCPUListUpd.txt | awk '{print $2}')

TotalCPUs=0
for cpu in $CPUs; do
	let TotalCPUs+=$cpu
done

SUBNET=$(ifconfig | grep "inet addr" | grep Bcast | awk '{print $2}' | awk -F"." '{print $3}')

if [ $1 -ne 0 ]; then
	ssh pi@192.168.$SUBNET.$1 raspistill -o $2
	scp pi@192.168.$SUBNET.$1:$2 .
fi

echo "Computing locally on 1 cpu"

bin/iojpegparts $2 $3 $4 $5 1 1 &
wait
bin/combinefun $3 $3 1
rm $3_part*

NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )
echo "Computing locally on " $NCPUS " CPUs."
for ((i=1;i<=NCPUS;i++))
do
	bin/iojpegparts $2 $3 $4 $5 $i $NCPUS &
done
wait
bin/combinefun $3 $3 $NCPUS 
rm $3_part*

echo "Computing on cloud with " $TotalCPUs " CPUs."

StartingBlockNr=1
i=0
for IP in $IPs; do
	./submitlocaljobs.sh $2 $3 $4 $5 $StartingBlockNr $TotalCPUs $IP &
	let StartingBlockNr+=8
done
wait
{bin/combinefun $3 $3 $TotalCPUs} 2>/dev/null
rm $3_part*
wait
echo "Computing using CUDA."

nvprof bin/iojpegCUDA $2 $3 $4 $5
