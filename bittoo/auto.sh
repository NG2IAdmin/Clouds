#!/bin/bash
# AUTOMATIC LOGIN IN SERVER
echo "------------------------------------------------------"
ssh-keygen
ssh-copy-id dante@192.168.145.98
ssh dante@192.168.145.98
echo "automation complete"
