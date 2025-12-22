#!/bin/bash
# QEMU Balanced Configuration
#
# This script provides a balanced configuration with some features
# enabled but still optimized for reasonable boot time.
#
# Expected boot time: 8-12 seconds
#
# Usage: ./qemu-balanced-boot.sh

set -e

# Configuration
KERNEL="${KERNEL:-vmlinuz64}"
INITRD="${INITRD:-core.gz}"
MEMORY="${MEMORY:-512M}"
CPUS="${CPUS:-2}"
DISK="${DISK:-disk.img}"

# Balanced boot parameters
BOOT_PARAMS="quiet loglevel=3 restore=sda1 tce=sda1"

echo "Starting TinyCore Linux with balanced configuration..."
echo "Kernel: $KERNEL"
echo "Initrd: $INITRD"
echo "Memory: $MEMORY"
echo "CPUs: $CPUS"
echo "Boot params: $BOOT_PARAMS"
echo ""

# Create disk image if it doesn't exist
if [ ! -f "$DISK" ]; then
  echo "Creating disk image: $DISK"
  qemu-img create -f qcow2 "$DISK" 10G
fi

exec qemu-system-x86_64 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "$BOOT_PARAMS" \
  -m "$MEMORY" \
  -smp "$CPUS" \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -enable-kvm \
  -cpu host \
  -nographic \
  -serial mon:stdio
