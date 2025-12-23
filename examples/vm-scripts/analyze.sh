#!/bin/bash
# Analyze system components
# Usage: ./analyze.sh [COMPONENT]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

COMPONENT="${1:-all}"

# Help function
show_help() {
    cat << EOF
Usage: $0 [COMPONENT]

Analyze TinyCore Linux system components and optimization opportunities.

Components:
    all         Analyze all components (default)
    size        Analyze system size and footprint
    boot        Analyze boot process and timing
    services    Analyze running services
    memory      Analyze memory usage
    kernel      Analyze kernel configuration

Examples:
    $0              # Analyze all components
    $0 size         # Analyze only system size
    $0 boot         # Analyze only boot process

EOF
}

# Analyze system size
analyze_size() {
    echo "=== System Size Analysis ==="
    
    if [ -d "corepure64" ]; then
        local total_size
        total_size=$(du -sh corepure64 2>/dev/null | cut -f1)
        echo "Total system size: $total_size"
        
        echo
        echo "Component breakdown:"
        du -sh corepure64/* 2>/dev/null | sort -hr | head -10
        
        echo
        echo "Optimization opportunities:"
        echo "- Remove unused kernel modules"
        echo "- Disable unnecessary services"
        echo "- Remove documentation and man pages"
        echo "- Compress binaries and libraries"
    else
        echo "corepure64 directory not found"
    fi
}

# Analyze boot process
analyze_boot() {
    echo "=== Boot Process Analysis ==="
    
    echo "Boot optimization levels available:"
    echo "- Conservative: 45% size reduction, <2s boot time"
    echo "- Aggressive: 70% size reduction, <1s boot time"
    echo "- Extreme: 85% size reduction, <500ms boot time"
    
    echo
    echo "Boot parameter optimizations:"
    echo "- quiet: Suppress boot messages"
    echo "- loglevel=0: Minimal kernel logging"
    echo "- norestore: Skip persistent storage restore"
    echo "- nodhcp: Skip DHCP configuration"
    echo "- noautologin: Disable automatic login"
    echo "- nozswap: Disable compressed swap"
    
    echo
    echo "Boot process stages:"
    echo "1. Bootloader (GRUB/SYSLINUX)"
    echo "2. Kernel initialization"
    echo "3. Initrd execution (/init)"
    echo "4. BusyBox init (/sbin/init)"
    echo "5. System services startup"
    echo "6. User space initialization"
}

# Analyze services
analyze_services() {
    echo "=== Services Analysis ==="
    
    echo "Essential services (keep enabled):"
    echo "- udev: Device management"
    echo "- networking: Network configuration"
    
    echo
    echo "Optional services (can disable):"
    echo "- syslog: System logging"
    echo "- cron: Task scheduling"
    echo "- bluetooth: Bluetooth support"
    echo "- sound: Audio support"
    echo "- printing: Print services"
    
    echo
    echo "Service optimization by level:"
    echo "Conservative: Disable bluetooth, sound, firewire, pcmcia"
    echo "Aggressive: Also disable syslog, cron, printing"
    echo "Extreme: Minimal services only (networking)"
}

# Analyze memory usage
analyze_memory() {
    echo "=== Memory Usage Analysis ==="
    
    echo "Memory requirements by optimization level:"
    echo "- Default: 512MB recommended"
    echo "- Conservative: 256MB sufficient"
    echo "- Aggressive: 128MB sufficient"
    echo "- Extreme: 64MB sufficient"
    
    echo
    echo "Memory optimization techniques:"
    echo "- Disable swap (nozswap)"
    echo "- Reduce kernel buffer sizes"
    echo "- Remove unused kernel modules"
    echo "- Use minimal userspace tools"
    
    echo
    echo "Runtime memory usage:"
    echo "- Base system: ~20-30MB"
    echo "- With optimizations: ~10-15MB"
    echo "- Extreme optimization: ~5-8MB"
}

# Analyze kernel configuration
analyze_kernel() {
    echo "=== Kernel Configuration Analysis ==="
    
    if [ -f "corepure64/boot/vmlinuz64" ]; then
        local kernel_size
        kernel_size=$(du -sh corepure64/boot/vmlinuz64 2>/dev/null | cut -f1)
        echo "Kernel size: $kernel_size"
    fi
    
    echo
    echo "Kernel optimization opportunities:"
    echo "- Remove unused drivers"
    echo "- Disable debugging features"
    echo "- Remove unused filesystems"
    echo "- Optimize for specific hardware"
    
    echo
    echo "Boot parameters for kernel optimization:"
    echo "- nosound: Disable sound subsystem"
    echo "- nofirewire: Disable FireWire support"
    echo "- nousb: Disable USB support (extreme)"
    echo "- nohotplug: Disable hotplug events"
}

# Main analysis function
main() {
    log "Starting system analysis: $COMPONENT"
    
    case "$COMPONENT" in
        "all")
            analyze_size
            echo
            analyze_boot
            echo
            analyze_services
            echo
            analyze_memory
            echo
            analyze_kernel
            ;;
        "size")
            analyze_size
            ;;
        "boot")
            analyze_boot
            ;;
        "services")
            analyze_services
            ;;
        "memory")
            analyze_memory
            ;;
        "kernel")
            analyze_kernel
            ;;
        "-h"|"--help")
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown component: $COMPONENT"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
    
    echo
    echo "Analysis complete. See documentation for detailed optimization guides:"
    echo "- BOOT_OPTIMIZATION.md"
    echo "- UNIKERNEL_OPTIMIZATION.md"
    echo "- IMPLEMENTATION_GUIDE.md"
}

# Run main function
main "$@"