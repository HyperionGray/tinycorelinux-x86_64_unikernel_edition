#!/bin/bash
# Boot Time Benchmark Script
#
# This script benchmarks boot time with different configurations
# to help you find the optimal setup for your use case.
#
# Usage: ./benchmark-boot.sh

set -e

# Configuration
KERNEL="${KERNEL:-vmlinuz64}"
INITRD="${INITRD:-core.gz}"
MEMORY="512M"
RUNS="${RUNS:-5}"

echo "========================================="
echo "TinyCore Linux Boot Time Benchmark"
echo "========================================="
echo "Kernel: $KERNEL"
echo "Initrd: $INITRD"
echo "Runs per configuration: $RUNS"
echo ""

# Test configurations
declare -A CONFIGS=(
  ["Default"]=""
  ["Quiet"]="quiet loglevel=3"
  ["No Restore"]="quiet loglevel=3 norestore"
  ["No DHCP"]="quiet loglevel=3 nodhcp"
  ["Fast"]="quiet loglevel=3 norestore nodhcp"
  ["Fastest"]="quiet loglevel=1 norestore nodhcp noembed"
)

benchmark_config() {
  local name="$1"
  local params="$2"
  local total=0
  
  echo "Testing: $name"
  echo "Params: $params"
  
  for i in $(seq 1 $RUNS); do
    echo -n "  Run $i: "
    
    # Start time
    start=$(date +%s.%N)
    
    # Boot VM and wait for init to complete
    timeout 60s qemu-system-x86_64 \
      -kernel "$KERNEL" \
      -initrd "$INITRD" \
      -append "$params" \
      -m "$MEMORY" \
      -enable-kvm \
      -nographic \
      -serial file:/tmp/boot-test-$$.log \
      &> /dev/null || true
    
    # End time
    end=$(date +%s.%N)
    
    # Calculate duration using awk (more portable than bc)
    duration=$(awk "BEGIN {printf \"%.2f\", $end - $start}")
    total=$(awk "BEGIN {printf \"%.2f\", $total + $duration}")
    
    echo "${duration}s"
    
    # Small delay between runs
    sleep 1
  done
  
  # Calculate average using awk
  avg=$(awk "BEGIN {printf \"%.2f\", $total / $RUNS}")
  echo "  Average: ${avg}s"
  echo ""
}

# Run benchmarks
for config in "${!CONFIGS[@]}"; do
  benchmark_config "$config" "${CONFIGS[$config]}"
done

# Cleanup
rm -f /tmp/boot-test-$$.log

echo "========================================="
echo "Benchmark Complete"
echo "========================================="
