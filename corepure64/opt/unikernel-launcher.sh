#!/bin/sh
# Unikernel Application Launcher
# Optimized for single-purpose ephemeral microvm deployment
#
# This script replaces the traditional getty/shell approach with direct
# application execution suitable for unikernel deployment scenarios.

# Configuration
APP_NAME="${APP_NAME:-myapp}"
APP_PATH="${APP_PATH:-/opt/app}"
APP_USER="${APP_USER:-root}"
APP_ARGS="${APP_ARGS:-}"
LOG_LEVEL="${LOG_LEVEL:-info}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [unikernel-launcher] [$1] $2"
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Pre-application setup
setup_environment() {
    log "INFO" "Setting up unikernel environment for $APP_NAME"
    
    # Set up basic environment variables
    export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/bin"
    export HOME="/root"
    export TERM="linux"
    
    # Create necessary directories
    mkdir -p /tmp /var/log /var/run
    
    # Set up basic networking if needed
    if [ "$ENABLE_NETWORK" = "true" ]; then
        log "INFO" "Initializing network interface"
        ip link set lo up
        # Add specific network configuration here if needed
    fi
    
    # Application-specific setup
    if [ -f "/opt/app-setup.sh" ]; then
        log "INFO" "Running application-specific setup"
        /opt/app-setup.sh || error_exit "Application setup failed"
    fi
}

# Application health check
check_application() {
    if [ ! -f "$APP_PATH" ] && [ ! -d "$APP_PATH" ]; then
        error_exit "Application not found at $APP_PATH"
    fi
    
    if [ -f "$APP_PATH" ] && [ ! -x "$APP_PATH" ]; then
        error_exit "Application at $APP_PATH is not executable"
    fi
}

# Launch application
launch_application() {
    log "INFO" "Launching application: $APP_NAME"
    log "INFO" "Application path: $APP_PATH"
    log "INFO" "Application args: $APP_ARGS"
    
    # Change to application user if specified and not root
    if [ "$APP_USER" != "root" ]; then
        log "INFO" "Switching to user: $APP_USER"
        su -c "$APP_PATH $APP_ARGS" "$APP_USER"
    else
        # Execute application directly
        exec "$APP_PATH" $APP_ARGS
    fi
}

# Handle application failure
handle_failure() {
    log "ERROR" "Application $APP_NAME failed or exited unexpectedly"
    
    # In unikernel mode, we typically want to restart or shutdown
    case "${FAILURE_ACTION:-restart}" in
        "restart")
            log "INFO" "Restarting application in 5 seconds..."
            sleep 5
            exec "$0" "$@"
            ;;
        "shutdown")
            log "INFO" "Shutting down system due to application failure"
            /sbin/halt
            ;;
        "shell")
            log "INFO" "Dropping to emergency shell"
            /bin/sh
            ;;
        *)
            log "INFO" "No failure action specified, shutting down"
            /sbin/halt
            ;;
    esac
}

# Signal handlers
trap 'log "INFO" "Received SIGTERM, shutting down gracefully"; exit 0' TERM
trap 'log "INFO" "Received SIGINT, shutting down gracefully"; exit 0' INT

# Main execution
main() {
    log "INFO" "Starting unikernel application launcher"
    
    # Setup environment
    setup_environment
    
    # Check application
    check_application
    
    # Launch application
    launch_application
    
    # If we reach here, the application exited
    handle_failure
}

# Execute main function with all arguments
main "$@"