#!/bin/sh
# Minimal bootsync.sh for fastest boot
# Use this for stateless systems that don't need network setup
#
# Boot time savings: ~1-2 seconds compared to full network setup

# Only run application-specific startup
/opt/bootlocal.sh &
