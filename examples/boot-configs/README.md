# Boot Configuration Examples

This directory contains example configurations for optimizing TinyCore Linux boot time for different use cases.

## Configuration Files

### Init Scripts

| File | Use Case | Boot Time | Features |
|------|----------|-----------|----------|
| `init.minimal` | Stateless VMs | Fastest (~300-500ms savings) | Basic mounting only |
| `init.fast` | Balanced setup | Fast (~200-300ms savings) | Conditional features |
| `init.ultra-minimal` | Specialized deployments | Ultra-fast (~500-800ms savings) | Minimal features only |

### Inittab Configurations

| File | Use Case | TTYs | Boot Time Savings |
|------|----------|------|-------------------|
| `inittab.minimal` | VM/Container | 1 | ~200-500ms |
| `inittab.optimized` | Development | 3 | ~150-300ms |
| `inittab.headless` | Headless server | 0 | ~500ms+ |

### Bootsync Scripts

| File | Use Case | Network | Boot Time Savings |
|------|----------|---------|-------------------|
| `bootsync.minimal.sh` | Stateless | No | ~1-2 seconds |
| `bootsync.fast.sh` | Conditional | Optional | ~500ms-1s |
| `bootsync.parallel.sh` | Standard | Yes | ~200-500ms |

## Quick Usage

### 1. Replace Init Script

```bash
# Backup original
cp /init /init.backup

# Use minimal init
cp examples/boot-configs/init.minimal /init

# Rebuild initrd
cd /
find . | cpio -o -H newc | gzip > /boot/core.minimal.gz
```

### 2. Replace Inittab

```bash
# Backup original
cp /etc/inittab /etc/inittab.backup

# Use minimal inittab
cp examples/boot-configs/inittab.minimal /etc/inittab
```

### 3. Replace Bootsync

```bash
# Backup original
cp /opt/bootsync.sh /opt/bootsync.sh.backup

# Use minimal bootsync
cp examples/boot-configs/bootsync.minimal.sh /opt/bootsync.sh
chmod +x /opt/bootsync.sh
```

## Configuration Profiles

### Profile 1: Maximum Speed (Unikernel/Microservice)

**Target Boot Time**: 2-4 seconds

**Files to use**:
- `init.ultra-minimal`
- `inittab.headless`
- `bootsync.minimal.sh`

**Boot parameters**:
```
quiet loglevel=1 norestore nodhcp
```

### Profile 2: Balanced (Development VM)

**Target Boot Time**: 8-12 seconds

**Files to use**:
- `init.fast`
- `inittab.optimized`
- `bootsync.fast.sh`

**Boot parameters**:
```
quiet loglevel=3 restore=sda1
```

### Profile 3: Feature-Rich (Production)

**Target Boot Time**: 12-15 seconds

**Files to use**:
- Original files (with optimizations)
- `inittab.optimized`
- `bootsync.parallel.sh`

**Boot parameters**:
```
quiet restore=sda1 tce=sda1
```

## Testing

After applying configurations, test boot time:

```bash
# Method 1: Check uptime after boot
awk '{print "Boot time: " $1 " seconds"}' /proc/uptime

# Method 2: Time VM boot
time qemu-system-x86_64 -kernel vmlinuz64 -initrd core.gz \
  -append "quiet loglevel=3 norestore nodhcp" \
  -enable-kvm -nographic
```

## Rollback

To restore original configuration:

```bash
# Restore init
cp /init.backup /init

# Restore inittab
cp /etc/inittab.backup /etc/inittab

# Restore bootsync
cp /opt/bootsync.sh.backup /opt/bootsync.sh
```

## Integration with Build Process

To apply during image build:

```bash
#!/bin/bash
# build-optimized-image.sh

# Extract initrd
mkdir -p build/initrd
cd build/initrd
zcat ../../core.gz | cpio -i -d

# Apply optimizations
cp ../../examples/boot-configs/init.minimal init
cp ../../examples/boot-configs/inittab.minimal etc/inittab
cp ../../examples/boot-configs/bootsync.minimal.sh opt/bootsync.sh

# Repack
find . | cpio -o -H newc | gzip > ../../core.optimized.gz
```

## Notes

- Always test configurations in a non-production environment first
- Keep backups of original files
- Some configurations may not work on all hardware
- VM-specific optimizations may not apply to bare metal

## See Also

- [BOOT_OPTIMIZATION.md](../../BOOT_OPTIMIZATION.md) - Comprehensive boot optimization guide
- [QUICK_START_BOOT_OPTIMIZATION.md](../../QUICK_START_BOOT_OPTIMIZATION.md) - Quick start guide
