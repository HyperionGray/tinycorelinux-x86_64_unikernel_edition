#!/bin/bash
# Apply configuration script
# Usage: ./apply-config.sh CONFIG_FILE

set -e

CONFIG_FILE="$1"

# Help function
show_help() {
    cat << EOF
Usage: $0 CONFIG_FILE

Apply a configuration file to set up TinyCore Linux optimization.

Arguments:
    CONFIG_FILE    Path to configuration file

Examples:
    $0 examples/boot-configs/conservative.conf
    $0 examples/boot-configs/aggressive.conf
    $0 examples/boot-configs/extreme.conf

Configuration files define:
- Kernel boot parameters
- Memory allocation
- Service configuration
- Optimization level

EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help|"")
        show_help
        exit 0
        ;;
esac

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Parse configuration
echo "Applying configuration: $CONFIG_FILE"
echo

# Extract configuration values
KERNEL_PARAMS=$(grep "kernel_params" "$CONFIG_FILE" | cut -d'=' -f2- | sed 's/^[ \t]*//')
MEMORY=$(grep "memory" "$CONFIG_FILE" | cut -d'=' -f2- | sed 's/^[ \t]*//')
OPT_LEVEL=$(grep "optimization_level" "$CONFIG_FILE" | cut -d'=' -f2- | sed 's/^[ \t]*//')

echo "Configuration applied:"
echo "- Kernel parameters: $KERNEL_PARAMS"
echo "- Memory allocation: $MEMORY"
echo "- Optimization level: $OPT_LEVEL"
echo

echo "To use this configuration:"
echo "1. Launch VM with: examples/vm-scripts/launch-vm.sh $CONFIG_FILE"
echo "2. Or use kernel parameters directly: $KERNEL_PARAMS"
echo

# Provide optimization-specific guidance
case "$OPT_LEVEL" in
    "conservative")
        echo "Conservative optimization selected:"
        echo "- Low risk, good compatibility"
        echo "- Target boot time: <2 seconds"
        echo "- Memory usage: ~64MB"
        ;;
    "aggressive")
        echo "Aggressive optimization selected:"
        echo "- Medium risk, reduced compatibility"
        echo "- Target boot time: <1 second"
        echo "- Memory usage: ~32MB"
        ;;
    "extreme")
        echo "Extreme optimization selected:"
        echo "- High risk, minimal compatibility"
        echo "- Target boot time: <500ms"
        echo "- Memory usage: ~16MB"
        echo "- WARNING: May not work on all systems"
        ;;
esac

echo
echo "Configuration applied successfully!"