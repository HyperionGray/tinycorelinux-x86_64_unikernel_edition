# TinyCore Linux Unikernel Edition

## Overview

This is an optimized version of TinyCore Linux specifically designed for unikernel deployment in ephemeral microvms. The system has been stripped down to essential components and optimized for single-purpose applications with fast boot times and minimal resource usage.

## Key Optimizations

### ✅ Completed Optimizations

1. **Persistence Layer Removal**
   - Removed backup/restore system (filetool.sh)
   - Eliminated backup device configuration
   - Removed file encryption/decryption capabilities

2. **Init System Simplification**
   - Reduced from 6 TTY processes to 1
   - Simplified init script (removed complex tmpfs switching)
   - Streamlined memory management

3. **Extension System Removal**
   - Removed TCE (TinyCore Extensions) loading mechanisms
   - Eliminated dynamic extension mounting
   - Simplified filesystem structure

4. **Network Configuration Optimization**
   - Simplified boot synchronization
   - Optional network initialization
   - Removed complex network setup scripts

## System Architecture

### Resource Usage (Estimated)
- **Memory**: ~40-60MB (down from ~80-100MB)
- **Boot Time**: ~3-5 seconds (down from ~10-15 seconds)
- **Process Count**: ~5-8 processes (down from ~15-20 processes)

### Core Components Retained
- BusyBox utilities (essential Unix tools)
- Basic init system
- RAM-based filesystem (tmpfs)
- Single TTY for console access
- Clean shutdown handling

## Usage Scenarios

### Ideal For:
- **Microservices** - HTTP APIs, REST services
- **Data Processing** - Batch jobs, stream processing
- **Network Services** - Proxies, load balancers, gateways
- **Edge Computing** - IoT applications, edge processing
- **Serverless Functions** - Function-as-a-Service platforms

### Not Suitable For:
- Interactive applications requiring shell access
- Multi-user systems
- Applications requiring persistent storage
- Complex multi-service applications

## Deployment Options

### Option 1: Traditional Shell Access (Current Default)
The system boots to a single TTY with shell access for debugging and development.

```bash
# Current inittab configuration
tty1::respawn:/sbin/getty 38400 tty1
```

### Option 2: Direct Application Launch (Recommended for Production)
Replace the getty process with direct application execution.

```bash
# Copy the example configuration
cp /etc/inittab.unikernel-example /etc/inittab

# Edit to enable direct application launch
sed -i 's/^# tty1::respawn:\/opt\/unikernel-launcher.sh/tty1::respawn:\/opt\/unikernel-launcher.sh/' /etc/inittab
sed -i 's/^tty1::respawn:\/sbin\/getty/# tty1::respawn:\/sbin\/getty/' /etc/inittab
```

## Application Integration

### Using the Unikernel Launcher

The included `unikernel-launcher.sh` script provides a framework for launching applications directly:

```bash
# Environment variables for configuration
export APP_NAME="myapp"
export APP_PATH="/opt/myapp/bin/server"
export APP_ARGS="--port 8080 --config /opt/myapp/config.json"
export APP_USER="root"
export ENABLE_NETWORK="true"
export FAILURE_ACTION="restart"  # or "shutdown", "shell"
```

### Custom Application Setup

1. **Place your application** in `/opt/app/` or specify custom path
2. **Create setup script** at `/opt/app-setup.sh` for initialization
3. **Configure environment** variables in `/opt/bootlocal.sh`
4. **Modify inittab** to use direct application launch

### Example Application Integration

```bash
#!/bin/sh
# /opt/app-setup.sh - Application-specific setup

# Create application directories
mkdir -p /var/log/myapp /var/run/myapp

# Set up configuration
cp /opt/myapp/config.template /opt/myapp/config.json

# Initialize database or data structures
/opt/myapp/bin/init-db

# Set permissions
chown -R myapp:myapp /var/log/myapp /var/run/myapp
```

## Network Configuration

### Basic Network Setup
```bash
# Enable basic networking in unikernel-launcher.sh
export ENABLE_NETWORK="true"
```

### Custom Network Configuration
```bash
# Add to /opt/app-setup.sh
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1
```

## Build and Deployment

### Creating Custom Images

1. **Modify the system** according to your application needs
2. **Test the configuration** in a development environment
3. **Create filesystem image** using your preferred method
4. **Deploy to target environment** (VM, container, bare metal)

### Container Integration
```dockerfile
FROM scratch
COPY corepure64/ /
CMD ["/init"]
```

### VM Deployment
- Use the optimized system as initrd
- Configure kernel parameters for your environment
- Set up networking and storage as needed

## Monitoring and Debugging

### Logging
- System logs to console by default
- Application logs can be configured via APP_SETUP
- Use external log aggregation for production

### Debugging
- Enable shell access by reverting inittab changes
- Use `FAILURE_ACTION="shell"` for emergency access
- Monitor system resources via /proc filesystem

### Health Checks
- Implement application-specific health checks
- Use external monitoring for production deployments
- Configure restart policies based on application needs

## Security Considerations

### Improved Security
- Minimal attack surface (fewer processes and services)
- No persistent storage (malware cannot survive reboot)
- Single application focus reduces privilege escalation
- Immutable infrastructure approach

### Security Trade-offs
- No automatic security updates (requires image rebuilding)
- Limited debugging tools available
- No advanced security frameworks (SELinux, AppArmor)
- Basic logging and audit capabilities

### Recommendations
- Use external security scanning for images
- Implement network-level security controls
- Regular image rebuilding for security updates
- Monitor application behavior externally

## Performance Tuning

### Memory Optimization
```bash
# Adjust tmpfs size in init script
mount / -o remount,size=50%,nr_inodes=$inodes
```

### CPU Optimization
```bash
# Set CPU affinity for application
taskset -c 0-1 /opt/myapp/bin/server
```

### Network Optimization
```bash
# Tune network parameters
echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
echo 1 > /proc/sys/net/ipv4/tcp_fin_timeout
```

## Troubleshooting

### Common Issues

1. **Application won't start**
   - Check APP_PATH and permissions
   - Verify application dependencies
   - Review logs in /var/log

2. **Network connectivity issues**
   - Verify ENABLE_NETWORK setting
   - Check network interface configuration
   - Validate routing table

3. **Memory issues**
   - Adjust tmpfs size in init script
   - Monitor memory usage with /proc/meminfo
   - Optimize application memory usage

### Emergency Access
```bash
# Boot with shell access
# Modify inittab to use getty instead of application launcher
tty1::respawn:/sbin/getty 38400 tty1
```

## Contributing

This optimized TinyCore Linux distribution is designed to be a starting point for unikernel deployments. Contributions and improvements are welcome, particularly:

- Application-specific optimizations
- Additional security hardening
- Performance improvements
- Documentation enhancements

## License

This work is based on TinyCore Linux and maintains the same GPL v2 license. See LICENSE file for details.

## Support

For issues specific to the unikernel optimizations, please refer to:
- UNIKERNEL_OPTIMIZATIONS.md for detailed changes
- TINYCORE_ANALYSIS.md for original system analysis
- TinyCore Linux community for base system support