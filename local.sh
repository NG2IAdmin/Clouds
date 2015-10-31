#!/bin/bash

# List of arguments: StartingBlockNr TotalBlocks InFileName OutFileName MaskWidth PeakWidth

NCPUS=$( cat /proc/cpuinfo | grep processor | wc -l )
echo "Computing locally on " $NCPUS
for ((i=$1;i<=NCPUS+$1;i++))
do
	bin/iojpegparts $3 $4 $5 $6 $i $2 &
done
wait
