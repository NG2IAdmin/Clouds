#!/bin/bash

# List of arguments: StartingBlockNr TotalBlocks InFileName OutFileName MaskWidth PeakWidth

NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )
for ((i=$1;i<=NCPUS+$1;i++))
do
	/home/ng2i/Desktop/Clouds/bin/iojpegparts $3 $4 $5 $6 $i $2 &
done
wait
