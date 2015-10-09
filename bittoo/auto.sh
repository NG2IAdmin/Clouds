#!/bin/bash
# AUTOMATIC LOGIN IN SERVER
echo "------------------------------------------------------"
#ssh-keygen
ssh-copy-id cheetah@192.168.145.127
ssh cheetah@192.168.145.127
echo "automation complete"
