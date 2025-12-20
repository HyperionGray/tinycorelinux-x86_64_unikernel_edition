# VM Launch Scripts

This directory contains example scripts for launching TinyCore Linux in different VM configurations optimized for various use cases.

## Available Scripts

### Quick Start Scripts

| Script | Use Case | Boot Time | Features |
|--------|----------|-----------|----------|
| `qemu-fast-boot.sh` | Microservices, CI/CD | 2-4s | Minimal, no persistence |
| `qemu-balanced-boot.sh` | Development | 8-12s | Persistence, some features |
| `qemu-server-boot.sh` | Production server | 10-15s | Full features, networking |
| `qemu-dev-boot.sh` | Development/Debug | 12-15s | Verbose logging, multi-TTY |

### Utility Scripts

| Script | Purpose |
|--------|---------|
| `benchmark-boot.sh` | Benchmark different boot configurations |

## Usage

### Fast Boot (Fastest)

```bash
./qemu-fast-boot.sh
```

**Configuration**:
- Direct kernel boot
- No bootloader
- Minimal features
- No persistence
- No networking setup

**Best for**: Stateless VMs, containerized applications, CI/CD runners

### Balanced Boot

```bash
./qemu-balanced-boot.sh
```

**Configuration**:
- Direct kernel boot
- Persistence enabled
- Standard features
- Network support

**Best for**: Development environments, testing

### Server Boot

```bash
# Start server in background
./qemu-server-boot.sh

# Connect via SSH (if configured)
ssh -p 2222 tc@localhost

# Stop server
kill $(cat tinycore-server.pid)
```

**Configuration**:
- Full networking
- SSH port forwarding
- Persistence
- Daemonized

**Best for**: Long-running services, production environments

### Development Boot

```bash
./qemu-dev-boot.sh
```

**Configuration**:
- Verbose logging
- Multiple virtual terminals
- Development tools
- Full debugging output

**Best for**: Kernel development, debugging, learning

## Benchmarking

Compare boot times across configurations:

```bash
./benchmark-boot.sh
```

This will test multiple configurations and output average boot times.

## Customization

All scripts accept environment variables for customization:

```bash
# Use custom kernel and initrd
KERNEL=/path/to/vmlinuz INITRD=/path/to/core.gz ./qemu-fast-boot.sh

# Adjust memory and CPUs
MEMORY=2G CPUS=4 ./qemu-balanced-boot.sh

# Use custom disk
DISK=/path/to/disk.img ./qemu-server-boot.sh

# Custom SSH port
SSH_PORT=3333 ./qemu-server-boot.sh
```

## Direct Kernel Boot Benefits

These scripts use QEMU's direct kernel boot feature, which:

1. **Skips bootloader** - Saves 200-500ms
2. **No bootloader configuration** - Simpler setup
3. **Faster iteration** - Quick kernel/initrd testing
4. **Better for automation** - Scriptable, reproducible

## Boot Parameter Reference

Common parameters used in these scripts:

| Parameter | Effect | Savings |
|-----------|--------|---------|
| `quiet` | Suppress console messages | ~10ms |
| `loglevel=1` | Minimal kernel logging | ~10ms |
| `loglevel=3` | Standard kernel logging | ~5ms |
| `norestore` | Skip backup restoration | 5-7s |
| `nodhcp` | Skip network configuration | 0.5-1s |
| `multivt` | Enable multiple TTYs | -0.5s (slower) |

## Examples

### Example 1: Ultra-fast CI/CD Runner

```bash
#!/bin/bash
# ci-runner.sh

qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.minimal.gz \
  -append "quiet loglevel=1 norestore nodhcp noembed" \
  -m 256M \
  -smp 1 \
  -enable-kvm \
  -nographic
```

**Expected boot time**: ~2 seconds

### Example 2: Development VM with Snapshots

```bash
#!/bin/bash
# dev-vm.sh

qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.gz \
  -append "quiet loglevel=3 restore=sda1 tce=sda1" \
  -m 1G \
  -smp 2 \
  -drive file=dev.qcow2,if=virtio,format=qcow2,snapshot=on \
  -enable-kvm \
  -nographic
```

**Expected boot time**: ~8 seconds

### Example 3: Microservice Container

```bash
#!/bin/bash
# microservice.sh

qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.minimal.gz \
  -append "quiet loglevel=1 norestore nodhcp init=/opt/app.sh" \
  -m 128M \
  -smp 1 \
  -enable-kvm \
  -nographic \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0
```

**Expected boot time**: ~2-3 seconds

## Performance Tips

1. **Use KVM acceleration** - Always add `-enable-kvm` when available
2. **Minimize memory** - Use only what's needed (128M-512M often sufficient)
3. **Use virtio drivers** - Faster than emulated hardware
4. **Disable unnecessary devices** - Use `-nographic` if no GUI needed
5. **Optimize initrd** - Use minimal initrd for fastest boot
6. **Direct kernel boot** - Always preferred over bootloader in VMs

## Troubleshooting

### VM fails to boot

```bash
# Add verbose logging
BOOT_PARAMS="loglevel=7" ./qemu-fast-boot.sh

# Or boot to shell
BOOT_PARAMS="init=/bin/sh" ./qemu-fast-boot.sh
```

### Boot time slower than expected

```bash
# Check if KVM is enabled
lsmod | grep kvm

# Verify CPU supports virtualization
grep -E 'vmx|svm' /proc/cpuinfo

# Run benchmark to compare
./benchmark-boot.sh
```

### Cannot connect to VM

```bash
# Check if VM is running
ps aux | grep qemu

# Check port forwarding
netstat -tlnp | grep 2222

# Try different port
SSH_PORT=3333 ./qemu-server-boot.sh
```

## Integration with Build Systems

### Makefile Integration

```makefile
.PHONY: run-fast run-dev run-server

run-fast:
	cd examples/vm-scripts && ./qemu-fast-boot.sh

run-dev:
	cd examples/vm-scripts && ./qemu-dev-boot.sh

run-server:
	cd examples/vm-scripts && ./qemu-server-boot.sh

benchmark:
	cd examples/vm-scripts && ./benchmark-boot.sh
```

### Docker Integration

```dockerfile
FROM scratch
COPY vmlinuz64 /boot/vmlinuz64
COPY core.gz /boot/core.gz
COPY examples/vm-scripts/qemu-fast-boot.sh /boot/
ENTRYPOINT ["/boot/qemu-fast-boot.sh"]
```

## See Also

- [BOOT_OPTIMIZATION.md](../../BOOT_OPTIMIZATION.md) - Detailed optimization guide
- [QUICK_START_BOOT_OPTIMIZATION.md](../../QUICK_START_BOOT_OPTIMIZATION.md) - Quick start guide
- [boot-configs/](../boot-configs/) - Configuration file examples
