#!/bin/sh
# Parallel bootsync.sh for faster initialization
# Use this when multiple independent operations can run concurrently
#
# Boot time savings: ~200-500ms through parallelization

# Run network and setup scripts in parallel
/opt/network.sh &
/opt/bootsetup.sh &

# Wait for background tasks
wait

# Run local boot scripts
/opt/bootlocal.sh &
