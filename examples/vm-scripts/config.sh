#!/bin/bash
# VM Script Configuration
# Configuration file for VM management scripts

# VM Configuration
VM_MEMORY="256M"
VM_CPU_COUNT=1
VM_DISK_SIZE="1G"
VM_NETWORK="user"

# Boot Configuration  
BOOT_TIMEOUT=30
KERNEL_PATH="corepure64/boot/vmlinuz64"
INITRD_PATH="corepure64/boot/corepure64.gz"

# Optimization Settings
OPTIMIZATION_LEVEL="conservative"
ENABLE_KVM=true
ENABLE_GRAPHICS=false

# Performance Monitoring
MEASURE_BOOT_TIME=true
LOG_PERFORMANCE=true
BENCHMARK_ITERATIONS=5

# Paths
QEMU_BINARY="qemu-system-x86_64"
LOG_DIR="/tmp/vm-logs"
RESULTS_DIR="/tmp/vm-results"

# Default kernel parameters by optimization level
CONSERVATIVE_PARAMS="quiet loglevel=3 norestore nodhcp"
AGGRESSIVE_PARAMS="quiet loglevel=0 norestore nodhcp noautologin nozswap"
EXTREME_PARAMS="quiet loglevel=0 norestore nodhcp noautologin nozswap nosound nofirewire"