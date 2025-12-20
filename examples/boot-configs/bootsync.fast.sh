#!/bin/sh
# Fast bootsync.sh with conditional network
# Use this when network setup might be needed but should be optional
#
# Boot time savings: ~500ms-1s if nodhcp is used

# Only setup network if not disabled
if ! grep -qw nodhcp /proc/cmdline; then
  /opt/network.sh
fi

# Run setup and local boot scripts
/opt/bootsetup.sh
/opt/bootlocal.sh &
