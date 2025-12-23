#!/bin/bash
# Launch VM with specified configuration
# Usage: ./launch-vm.sh [CONFIG_FILE]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

# Default configuration
DEFAULT_CONFIG="${SCRIPT_DIR}/../boot-configs/conservative.conf"
CONFIG_FILE="${1:-$DEFAULT_CONFIG}"

# Help function
show_help() {
    cat << EOF
Usage: $0 [CONFIG_FILE]

Launch TinyCore Linux VM with specified configuration.

Arguments:
    CONFIG_FILE    Path to configuration file (default: conservative.conf)

Examples:
    $0                                    # Use default conservative config
    $0 ../boot-configs/aggressive.conf   # Use aggressive optimization
    $0 ../boot-configs/extreme.conf      # Use extreme optimization

Configuration file format:
    [boot]
    kernel_params = quiet loglevel=3 norestore nodhcp
    memory = 256M
    optimization_level = conservative

For more information, see the documentation in the repository.
EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    "")
        # Use default config
        ;;
    *)
        if [ ! -f "$1" ]; then
            echo "Error: Configuration file not found: $1"
            echo "Use -h or --help for usage information."
            exit 1
        fi
        ;;
esac

# Main execution
main() {
    log "Starting VM launch script"
    
    # Check requirements
    if ! check_requirements; then
        log "Requirements check failed"
        exit 1
    fi
    
    # Validate and launch VM
    log "Using configuration: $CONFIG_FILE"
    
    if ! launch_vm "$CONFIG_FILE"; then
        log "VM launch failed"
        exit 1
    fi
    
    log "VM launch completed"
}

# Run main function
main "$@"