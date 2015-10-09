#! /bin/bash
#output = "output.text"
for i in prince@192.168.145.137 kshitij@192.168.145.48 cheetah@192.168.145.127
do 
ssh $i date  &
done
wait
