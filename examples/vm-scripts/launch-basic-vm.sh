#!/bin/bash
# Basic VM launch script
# Usage: ./launch-basic-vm.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Basic configuration
KERNEL_PATH="../../corepure64/boot/vmlinuz64"
INITRD_PATH="../../corepure64/boot/corepure64.gz"
MEMORY="256M"
KERNEL_PARAMS="quiet loglevel=3 norestore nodhcp"

# Check if files exist
if [ ! -f "$KERNEL_PATH" ]; then
    echo "Error: Kernel not found at $KERNEL_PATH"
    echo "Please ensure TinyCore Linux files are in the correct location."
    exit 1
fi

if [ ! -f "$INITRD_PATH" ]; then
    echo "Error: Initrd not found at $INITRD_PATH"
    echo "Please ensure TinyCore Linux files are in the correct location."
    exit 1
fi

# Check for QEMU
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "Error: qemu-system-x86_64 not found"
    echo "Please install QEMU to run virtual machines."
    exit 1
fi

echo "Launching TinyCore Linux VM..."
echo "Kernel: $KERNEL_PATH"
echo "Initrd: $INITRD_PATH"
echo "Memory: $MEMORY"
echo "Parameters: $KERNEL_PARAMS"
echo

# Launch VM
exec qemu-system-x86_64 \
    -kernel "$KERNEL_PATH" \
    -initrd "$INITRD_PATH" \
    -append "$KERNEL_PARAMS" \
    -m "$MEMORY" \
    -nographic \
    -enable-kvm 2>/dev/null || \
qemu-system-x86_64 \
    -kernel "$KERNEL_PATH" \
    -initrd "$INITRD_PATH" \
    -append "$KERNEL_PARAMS" \
    -m "$MEMORY" \
    -nographic