#!/bin/bash
# QEMU Development Configuration
#
# This script provides a development-friendly configuration
# with debugging features enabled.
#
# Expected boot time: 12-15 seconds
#
# Usage: ./qemu-dev-boot.sh

set -e

# Configuration
KERNEL="${KERNEL:-vmlinuz64}"
INITRD="${INITRD:-core.gz}"
MEMORY="${MEMORY:-1024M}"
CPUS="${CPUS:-2}"
DISK="${DISK:-dev.img}"

# Development boot parameters (more verbose for debugging)
BOOT_PARAMS="loglevel=7 restore=sda1 tce=sda1 multivt"

echo "Starting TinyCore Linux development configuration..."
echo "Kernel: $KERNEL"
echo "Initrd: $INITRD"
echo "Memory: $MEMORY"
echo "CPUs: $CPUS"
echo "Boot params: $BOOT_PARAMS"
echo ""
echo "Development features enabled:"
echo "  - Verbose logging (loglevel=7)"
echo "  - Multiple virtual terminals (multivt)"
echo "  - Persistence enabled"
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
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -enable-kvm \
  -nographic \
  -serial mon:stdio
