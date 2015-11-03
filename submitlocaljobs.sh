#!/bin/bash

# Called as: ./submitlocaljobs.sh $2 $3 $4 $5 $StartingBlockNr $TotalCPUs $IP &

SUBNET=$(ifconfig | grep "inet addr" | grep Bcast | awk '{print $2}' | awk -F"." '{print $3}')

scp $1 ng2i@192.168.$SUBNET.$7:/home/ng2i/Desktop/Clouds/
ssh ng2i@192.168.$SUBNET.$7 /home/ng2i/Desktop/Clouds/local.sh $5 $6 /home/ng2i/Desktop/Clouds/$1 /home/ng2i/Desktop/Clouds/$2 $3 $4
scp ng2i@192.168.$SUBNET.$7:/home/ng2i/Desktop/Clouds/$2_part* .
#ssh ng2i@192.168.1.$7 rm /home/ng2i/Desktop/Clouds/$1
#ssh ng2i@192.168.1.$7 rm /home/ng2i/Desktop/Clouds/$2_part*
