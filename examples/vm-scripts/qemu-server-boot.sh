#!/bin/bash
# QEMU Headless Server Configuration
#
# This script configures TinyCore for headless server operation
# with network support and persistence.
#
# Expected boot time: 10-15 seconds
#
# Usage: ./qemu-server-boot.sh

set -e

# Configuration
KERNEL="${KERNEL:-vmlinuz64}"
INITRD="${INITRD:-core.gz}"
MEMORY="${MEMORY:-1024M}"
CPUS="${CPUS:-4}"
DISK="${DISK:-server.img}"
SSH_PORT="${SSH_PORT:-2222}"

# Server boot parameters
BOOT_PARAMS="quiet loglevel=3 restore=sda1 tce=sda1"

echo "Starting TinyCore Linux server configuration..."
echo "Kernel: $KERNEL"
echo "Initrd: $INITRD"
echo "Memory: $MEMORY"
echo "CPUs: $CPUS"
echo "SSH forwarding: localhost:$SSH_PORT -> VM:22"
echo "Boot params: $BOOT_PARAMS"
echo ""

# Create disk image if it doesn't exist
if [ ! -f "$DISK" ]; then
  echo "Creating disk image: $DISK"
  qemu-img create -f qcow2 "$DISK" 20G
fi

exec qemu-system-x86_64 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "$BOOT_PARAMS" \
  -m "$MEMORY" \
  -smp "$CPUS" \
  -drive file="$DISK",if=virtio,format=qcow2 \
  -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
  -device virtio-net-pci,netdev=net0 \
  -enable-kvm \
  -cpu host \
  -nographic \
  -serial mon:stdio \
  -daemonize \
  -pidfile tinycore-server.pid
  
echo "Server started. PID saved to tinycore-server.pid"
echo "Connect via: ssh -p $SSH_PORT tc@localhost"
