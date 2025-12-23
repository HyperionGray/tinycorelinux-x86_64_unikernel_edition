#!/bin/bash
# Utility functions for VM management and optimization

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_DIR}/vm-utils.log"
}

# Create necessary directories
setup_directories() {
    mkdir -p "${LOG_DIR}" "${RESULTS_DIR}"
}

# Optimize boot time based on configuration
optimize_boot_time() {
    local level="${1:-conservative}"
    local params=""
    
    case "$level" in
        "conservative")
            params="$CONSERVATIVE_PARAMS"
            ;;
        "aggressive") 
            params="$AGGRESSIVE_PARAMS"
            ;;
        "extreme")
            params="$EXTREME_PARAMS"
            ;;
        *)
            log "Unknown optimization level: $level"
            return 1
            ;;
    esac
    
    log "Applied $level optimization: $params"
    echo "$params"
}

# Measure system performance
measure_performance() {
    local start_time=$(date +%s%N)
    local end_time
    local duration
    
    # Run the command passed as arguments
    "$@"
    local exit_code=$?
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
    
    log "Performance measurement: ${duration}ms (exit code: $exit_code)"
    
    if [ "$LOG_PERFORMANCE" = true ]; then
        echo "${duration}ms,$(date),${*}" >> "${RESULTS_DIR}/performance.csv"
    fi
    
    return $exit_code
}

# Validate configuration
validate_config() {
    local config_file="$1"
    local errors=0
    
    if [ ! -f "$config_file" ]; then
        log "ERROR: Configuration file not found: $config_file"
        return 2
    fi
    
    # Check required sections
    if ! grep -q "^\[boot\]" "$config_file"; then
        log "ERROR: Missing [boot] section in $config_file"
        ((errors++))
    fi
    
    if ! grep -q "kernel_params" "$config_file"; then
        log "ERROR: Missing kernel_params in $config_file"
        ((errors++))
    fi
    
    if [ $errors -gt 0 ]; then
        log "Configuration validation failed with $errors errors"
        return 2
    fi
    
    log "Configuration validation passed: $config_file"
    return 0
}

# Launch VM with specified configuration
launch_vm() {
    local config_file="$1"
    local kernel_params
    local memory
    
    if ! validate_config "$config_file"; then
        return 2
    fi
    
    # Parse configuration
    kernel_params=$(grep "kernel_params" "$config_file" | cut -d'=' -f2- | tr -d ' ')
    memory=$(grep "memory" "$config_file" | cut -d'=' -f2- | tr -d ' ')
    
    log "Launching VM with config: $config_file"
    log "Kernel params: $kernel_params"
    log "Memory: $memory"
    
    # Build QEMU command
    local qemu_cmd=(
        "$QEMU_BINARY"
        "-kernel" "$KERNEL_PATH"
        "-initrd" "$INITRD_PATH"
        "-append" "$kernel_params"
        "-m" "${memory:-$VM_MEMORY}"
        "-smp" "$VM_CPU_COUNT"
    )
    
    if [ "$ENABLE_KVM" = true ] && [ -e /dev/kvm ]; then
        qemu_cmd+=("-enable-kvm")
    fi
    
    if [ "$ENABLE_GRAPHICS" = false ]; then
        qemu_cmd+=("-nographic")
    fi
    
    # Launch VM
    if [ "$MEASURE_BOOT_TIME" = true ]; then
        measure_performance "${qemu_cmd[@]}"
    else
        "${qemu_cmd[@]}"
    fi
}

# Run benchmarks
run_benchmarks() {
    local config_file="$1"
    local iterations="${2:-$BENCHMARK_ITERATIONS}"
    local total_time=0
    local i
    
    log "Running benchmarks: $iterations iterations"
    
    for ((i=1; i<=iterations; i++)); do
        log "Benchmark iteration $i/$iterations"
        
        local start_time=$(date +%s%N)
        timeout 60 launch_vm "$config_file" >/dev/null 2>&1
        local end_time=$(date +%s%N)
        
        local duration=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + duration))
        
        log "Iteration $i: ${duration}ms"
    done
    
    local avg_time=$((total_time / iterations))
    log "Average boot time: ${avg_time}ms over $iterations iterations"
    
    echo "${avg_time}ms"
}

# Check system requirements
check_requirements() {
    local errors=0
    
    # Check for QEMU
    if ! command -v "$QEMU_BINARY" >/dev/null 2>&1; then
        log "ERROR: $QEMU_BINARY not found"
        ((errors++))
    fi
    
    # Check for kernel and initrd
    if [ ! -f "$KERNEL_PATH" ]; then
        log "ERROR: Kernel not found: $KERNEL_PATH"
        ((errors++))
    fi
    
    if [ ! -f "$INITRD_PATH" ]; then
        log "ERROR: Initrd not found: $INITRD_PATH"
        ((errors++))
    fi
    
    # Check for KVM if enabled
    if [ "$ENABLE_KVM" = true ] && [ ! -e /dev/kvm ]; then
        log "WARNING: KVM requested but /dev/kvm not available"
    fi
    
    if [ $errors -gt 0 ]; then
        log "Requirements check failed with $errors errors"
        return 1
    fi
    
    log "Requirements check passed"
    return 0
}

# Initialize logging
setup_directories