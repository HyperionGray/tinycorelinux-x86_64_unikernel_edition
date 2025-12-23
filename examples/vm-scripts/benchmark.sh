#!/bin/bash
# Run performance benchmarks
# Usage: ./benchmark.sh [ITERATIONS] [CONFIG_FILE]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

# Default values
DEFAULT_ITERATIONS=5
DEFAULT_CONFIG="${SCRIPT_DIR}/../boot-configs/conservative.conf"

ITERATIONS="${1:-$DEFAULT_ITERATIONS}"
CONFIG_FILE="${2:-$DEFAULT_CONFIG}"

# Help function
show_help() {
    cat << EOF
Usage: $0 [ITERATIONS] [CONFIG_FILE]

Run performance benchmarks for TinyCore Linux boot times.

Arguments:
    ITERATIONS     Number of benchmark iterations (default: 5)
    CONFIG_FILE    Path to configuration file (default: conservative.conf)

Examples:
    $0                                    # 5 iterations with conservative config
    $0 10                                 # 10 iterations with conservative config
    $0 5 ../boot-configs/aggressive.conf # 5 iterations with aggressive config

Output:
    Results are logged to ${RESULTS_DIR}/performance.csv
    Summary is displayed on stdout

EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
esac

# Validate inputs
if ! [[ "$ITERATIONS" =~ ^[0-9]+$ ]] || [ "$ITERATIONS" -lt 1 ]; then
    echo "Error: ITERATIONS must be a positive integer"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Main execution
main() {
    log "Starting benchmark with $ITERATIONS iterations"
    log "Configuration: $CONFIG_FILE"
    
    # Check requirements
    if ! check_requirements; then
        log "Requirements check failed"
        exit 1
    fi
    
    # Initialize results file
    if [ ! -f "${RESULTS_DIR}/performance.csv" ]; then
        echo "duration,timestamp,command" > "${RESULTS_DIR}/performance.csv"
    fi
    
    # Run benchmarks
    local avg_time
    avg_time=$(run_benchmarks "$CONFIG_FILE" "$ITERATIONS")
    
    # Display results
    echo
    echo "=== Benchmark Results ==="
    echo "Configuration: $CONFIG_FILE"
    echo "Iterations: $ITERATIONS"
    echo "Average boot time: $avg_time"
    echo
    echo "Detailed results saved to: ${RESULTS_DIR}/performance.csv"
    echo "Logs saved to: ${LOG_DIR}/vm-utils.log"
    
    # Show optimization level performance
    local opt_level
    opt_level=$(grep "optimization_level" "$CONFIG_FILE" | cut -d'=' -f2- | tr -d ' ')
    
    case "$opt_level" in
        "conservative")
            echo "Target: <2000ms (Low risk)"
            ;;
        "aggressive")
            echo "Target: <1000ms (Medium risk)"
            ;;
        "extreme")
            echo "Target: <500ms (High risk)"
            ;;
    esac
    
    # Performance assessment
    local avg_ms
    avg_ms=$(echo "$avg_time" | sed 's/ms//')
    
    case "$opt_level" in
        "conservative")
            if [ "$avg_ms" -lt 2000 ]; then
                echo "✅ Performance target met"
            else
                echo "❌ Performance target not met"
            fi
            ;;
        "aggressive")
            if [ "$avg_ms" -lt 1000 ]; then
                echo "✅ Performance target met"
            else
                echo "❌ Performance target not met"
            fi
            ;;
        "extreme")
            if [ "$avg_ms" -lt 500 ]; then
                echo "✅ Performance target met"
            else
                echo "❌ Performance target not met"
            fi
            ;;
    esac
}

# Run main function
main "$@"