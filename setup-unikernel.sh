#!/bin/sh
# TinyCore Linux Unikernel Setup Script
# This script helps configure the optimized system for specific use cases

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COREPURE_DIR="$SCRIPT_DIR/corepure64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Display banner
show_banner() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "  TinyCore Linux Unikernel Configuration Tool"
    echo "=================================================="
    echo -e "${NC}"
    echo "This tool helps configure TinyCore Linux for"
    echo "unikernel deployment in ephemeral microvms."
    echo ""
}

# Show optimization summary
show_optimizations() {
    log_info "Optimizations Applied:"
    echo "  ✅ Removed backup/restore system (filetool.sh)"
    echo "  ✅ Simplified init process"
    echo "  ✅ Reduced TTY processes (6 → 1)"
    echo "  ✅ Removed extension system"
    echo "  ✅ Simplified network setup"
    echo "  ✅ Added unikernel application launcher"
    echo ""
    
    log_info "Estimated Improvements:"
    echo "  📉 Memory usage: ~80-100MB → ~40-60MB"
    echo "  ⚡ Boot time: ~10-15s → ~3-5s"
    echo "  🔧 Process count: ~15-20 → ~5-8"
    echo ""
}

# Configuration options
configure_for_shell_access() {
    log_info "Configuring for shell access (development/debugging)..."
    
    if [ -f "$COREPURE_DIR/etc/inittab" ]; then
        # Ensure getty is enabled
        sed -i 's/^# tty1::respawn:\/sbin\/getty/tty1::respawn:\/sbin\/getty/' "$COREPURE_DIR/etc/inittab"
        sed -i 's/^tty1::respawn:\/opt\/unikernel-launcher.sh/# tty1::respawn:\/opt\/unikernel-launcher.sh/' "$COREPURE_DIR/etc/inittab"
        log_success "Configured for shell access on tty1"
    else
        log_error "inittab file not found"
        return 1
    fi
}

configure_for_direct_app() {
    log_info "Configuring for direct application launch (production)..."
    
    if [ -f "$COREPURE_DIR/etc/inittab" ]; then
        # Enable unikernel launcher
        sed -i 's/^tty1::respawn:\/sbin\/getty/# tty1::respawn:\/sbin\/getty/' "$COREPURE_DIR/etc/inittab"
        sed -i 's/^# tty1::respawn:\/opt\/unikernel-launcher.sh/tty1::respawn:\/opt\/unikernel-launcher.sh/' "$COREPURE_DIR/etc/inittab"
        log_success "Configured for direct application launch"
    else
        log_error "inittab file not found"
        return 1
    fi
}

# Setup application
setup_application() {
    local app_name="$1"
    local app_path="$2"
    
    log_info "Setting up application: $app_name"
    
    # Create application directory
    mkdir -p "$COREPURE_DIR/opt/app"
    
    # Create application configuration
    cat > "$COREPURE_DIR/opt/app-config.sh" << EOF
#!/bin/sh
# Application configuration for unikernel deployment

export APP_NAME="$app_name"
export APP_PATH="$app_path"
export APP_ARGS=""
export APP_USER="root"
export ENABLE_NETWORK="true"
export FAILURE_ACTION="restart"
export LOG_LEVEL="info"
EOF
    
    chmod +x "$COREPURE_DIR/opt/app-config.sh"
    
    # Update bootlocal.sh to source configuration
    cat > "$COREPURE_DIR/opt/bootlocal.sh" << 'EOF'
#!/bin/sh
# Load application configuration
if [ -f /opt/app-config.sh ]; then
    . /opt/app-config.sh
fi

# Application-specific setup can be added here
echo "Unikernel boot local script executed for $APP_NAME"
EOF
    
    chmod +x "$COREPURE_DIR/opt/bootlocal.sh"
    
    log_success "Application setup completed"
    log_info "Edit $COREPURE_DIR/opt/app-config.sh to customize your application"
}

# Validate configuration
validate_config() {
    log_info "Validating configuration..."
    
    local errors=0
    
    # Check required files
    if [ ! -f "$COREPURE_DIR/init" ]; then
        log_error "Missing init script"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "$COREPURE_DIR/etc/inittab" ]; then
        log_error "Missing inittab file"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "$COREPURE_DIR/opt/unikernel-launcher.sh" ]; then
        log_error "Missing unikernel launcher"
        errors=$((errors + 1))
    fi
    
    if [ ! -x "$COREPURE_DIR/opt/unikernel-launcher.sh" ]; then
        log_warning "Unikernel launcher is not executable, fixing..."
        chmod +x "$COREPURE_DIR/opt/unikernel-launcher.sh"
    fi
    
    if [ ! -x "$COREPURE_DIR/opt/bootlocal.sh" ]; then
        log_warning "bootlocal.sh is not executable, fixing..."
        chmod +x "$COREPURE_DIR/opt/bootlocal.sh"
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Configuration validation passed"
        return 0
    else
        log_error "Configuration validation failed with $errors errors"
        return 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  shell-access    Configure for shell access (development)"
    echo "  direct-app      Configure for direct application launch (production)"
    echo "  setup-app       Setup application configuration"
    echo "  validate        Validate current configuration"
    echo "  summary         Show optimization summary"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 shell-access                    # Enable shell access"
    echo "  $0 direct-app                      # Enable direct app launch"
    echo "  $0 setup-app myapp /opt/myapp/bin/server"
    echo "  $0 validate                        # Check configuration"
    echo ""
}

# Main function
main() {
    show_banner
    
    case "${1:-help}" in
        "shell-access")
            configure_for_shell_access
            ;;
        "direct-app")
            configure_for_direct_app
            ;;
        "setup-app")
            if [ -z "$2" ] || [ -z "$3" ]; then
                log_error "Usage: $0 setup-app <app_name> <app_path>"
                exit 1
            fi
            setup_application "$2" "$3"
            ;;
        "validate")
            validate_config
            ;;
        "summary")
            show_optimizations
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function with all arguments
main "$@"