#!/bin/bash
# QEMU Direct Kernel Boot - Fastest Configuration
#
# This script demonstrates the fastest possible boot configuration
# by skipping the bootloader entirely and using direct kernel boot.
#
# Expected boot time: 2-4 seconds
#
# Requirements:
# - QEMU with KVM support
# - vmlinuz64 kernel file
# - core.gz (or optimized) initrd file
#
# Usage: ./qemu-fast-boot.sh

set -e

# Configuration
KERNEL="${KERNEL:-vmlinuz64}"
INITRD="${INITRD:-core.gz}"
MEMORY="${MEMORY:-512M}"
CPUS="${CPUS:-2}"

# Fastest boot parameters
BOOT_PARAMS="quiet loglevel=1 norestore nodhcp"

# Optional: Add these for even more aggressive optimization
# BOOT_PARAMS="$BOOT_PARAMS noembed nobootsync"

echo "Starting TinyCore Linux with fastest boot configuration..."
echo "Kernel: $KERNEL"
echo "Initrd: $INITRD"
echo "Memory: $MEMORY"
echo "CPUs: $CPUS"
echo "Boot params: $BOOT_PARAMS"
echo ""

exec qemu-system-x86_64 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "$BOOT_PARAMS" \
  -m "$MEMORY" \
  -smp "$CPUS" \
  -enable-kvm \
  -cpu host \
  -nographic \
  -serial mon:stdio
