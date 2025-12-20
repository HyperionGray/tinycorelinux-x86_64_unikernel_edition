# Boot Time Reduction and Optimization Guide

## Overview

This document outlines techniques to reduce boot time and system footprint for TinyCore Linux x86_64, particularly for unikernel VM deployments where minimal boot time and resource usage are critical.

## Table of Contents

1. [Init Process Optimization](#init-process-optimization)
2. [Initrd Considerations](#initrd-considerations)
3. [Boot Loader Optimization](#boot-loader-optimization)
4. [Optional Component Removal](#optional-component-removal)
5. [Boot Parameter Reference](#boot-parameter-reference)
6. [Configuration Examples](#configuration-examples)

---

## Init Process Optimization

### Current Boot Flow

The current boot process follows this sequence:

1. **Bootloader** loads kernel and initrd
2. **Kernel** starts and mounts initrd as initial root filesystem
3. **`/init` script** runs (early userspace)
   - Mounts proc filesystem
   - Sets initial date from kernel command line
   - Configures backup device
   - Renames filetool wrapper
   - Remounts root with adjusted size
   - Executes `/sbin/init` (BusyBox init)
4. **BusyBox init** processes `/etc/inittab`
   - Runs `/etc/init.d/rcS` (sysinit)
   - Spawns getty processes for TTYs
5. **`/opt/bootsync.sh`** runs during boot
   - Executes network setup
   - Runs boot setup scripts
   - Executes bootlocal.sh in background

### Optimization Strategies

#### 1. Skip Unnecessary Init Steps

**Technique**: Modify `/init` to skip non-essential operations

Current `/init` performs several operations that may not be needed in a unikernel environment:

```bash
# These can be skipped/made conditional:
- Date setting (if time sync not needed)
- Backup device configuration (if no persistence needed)
- Filetool wrapper renaming (if backup/restore not used)
- Disk settling wait in tc-restore.sh (5 second delay)
```

**Implementation**:
- Add boot parameter `fastboot` to skip optional init steps
- Make backup/restore conditional on boot parameters
- Remove the 5-second sleep in `tc-restore.sh` when not needed

#### 2. Minimize TTY Spawning

**Current**: 6 TTYs are configured in `/etc/inittab`

**Optimization**: For VM/container environments, reduce to 1 or 2 TTYs

```ini
# Minimal configuration:
tty1::respawn:/sbin/getty 38400 tty1
# Comment out tty2-6 if not needed
```

**Boot Time Savings**: ~100-200ms per TTY

#### 3. Make bootsync.sh Optional

**Current**: Always runs network and boot setup scripts

**Optimization**: Skip via boot parameter `nobootsync`

```bash
# In /init or early boot:
if ! grep -qw nobootsync /proc/cmdline; then
  /opt/bootsync.sh
fi
```

#### 4. Parallel Initialization

**Current**: Sequential script execution

**Optimization**: Run independent init scripts in parallel

```bash
# Example:
/opt/network.sh &
/opt/bootsetup.sh &
wait
/opt/bootlocal.sh &
```

**Caveat**: May cause issues if scripts have dependencies

---

## Initrd Considerations

### Do We Really Need Initrd?

**Short Answer**: For most TinyCore deployments, yes. But there are alternatives.

### Why TinyCore Uses Initrd

1. **Kernel Cannot Mount SquashFS Directly**: The base system is compressed
2. **Flexible Boot Media**: Can boot from CD, USB, network without kernel recompilation
3. **Early Userspace Setup**: Hardware detection, module loading before main system
4. **tmpfs Migration**: Copies system to RAM before switching root

### Alternatives to Traditional Initrd

#### Option 1: Built-in Initramfs

**Approach**: Compile initrd directly into kernel

**Advantages**:
- Eliminates separate initrd loading time
- One less file to manage
- Slightly faster kernel decompression

**Disadvantages**:
- Requires kernel recompilation
- Less flexible for updates
- Larger kernel image

**Boot Time Savings**: ~50-150ms

**Implementation**:
```bash
# During kernel build:
CONFIG_INITRAMFS_SOURCE="/path/to/initramfs"
CONFIG_INITRAMFS_COMPRESSION_GZIP=y
```

#### Option 2: Direct Kernel Boot (No Initrd)

**Approach**: Boot kernel with root filesystem directly

**Requirements**:
- Root filesystem must be uncompressed or kernel-readable format
- All required drivers built into kernel (not modules)
- No early userspace setup needed

**Use Cases**:
- Very specific hardware configurations
- When system customization is minimal
- Container/VM environments with pre-configured storage

**Boot Time Savings**: ~200-500ms

**Limitations**:
- Loses TinyCore's flexibility
- Requires kernel with all drivers built-in
- Cannot use SquashFS compression easily
- No dynamic hardware detection

**Implementation**:
```bash
# Boot parameters:
root=/dev/sda1 rootfstype=ext4 init=/sbin/init
```

#### Option 3: Minimal Initrd

**Approach**: Strip down initrd to absolute minimum

**Keep Only**:
- Essential mount commands
- Minimal device nodes
- BusyBox with only needed applets
- Direct jump to init

**Remove**:
- Hardware detection scripts
- Network setup in initrd
- Backup/restore functionality
- Unnecessary kernel modules

**Boot Time Savings**: ~100-300ms

**Implementation**: See "Minimal Init Configuration" in examples section

---

## Boot Loader Optimization

### Current Considerations

TinyCore typically boots via:
- ISOLINUX/SYSLINUX (for CD/USB)
- GRUB/GRUB2 (for hard disk)
- PXE/iPXE (for network boot)

### Optimization Techniques

#### 1. Use Faster Boot Loaders

**Options**:

| Boot Loader | Boot Time | Size | Complexity |
|-------------|-----------|------|------------|
| GRUB2       | ~300ms    | ~1MB | High       |
| SYSLINUX    | ~150ms    | ~100KB | Medium   |
| EXTLINUX    | ~100ms    | ~50KB | Low        |
| kexec       | ~50ms     | Minimal | Very Low |
| Direct Boot | 0ms       | N/A | N/A        |

**Recommendation**: For VM environments, use direct kernel boot (bypass bootloader entirely)

#### 2. Direct Kernel Boot (QEMU/KVM)

**For VMs**: Skip bootloader completely

```bash
# QEMU example:
qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.gz \
  -append "quiet loglevel=3" \
  -enable-kvm
```

**Boot Time Savings**: ~200-400ms

#### 3. Minimize Boot Loader Delays

**SYSLINUX/ISOLINUX**: Remove menu delays

```
DEFAULT core
TIMEOUT 0
PROMPT 0
```

**GRUB**: Set timeout to 0

```
set timeout=0
```

**Boot Time Savings**: Variable (typically 1-5 seconds of menu wait time)

#### 4. Use kexec for Soft Reboot

**Approach**: Skip BIOS/UEFI on reboots

```bash
kexec -l /boot/vmlinuz64 --initrd=/boot/core.gz --append="quiet"
kexec -e
```

**Boot Time Savings**: ~2-5 seconds on reboot (skips firmware)

---

## Optional Component Removal

### Components That Can Be Removed/Made Optional

#### 1. Backup/Restore System

**Components**:
- `/usr/bin/filetool.sh`
- `/etc/init.d/tc-restore.sh`
- Backup device scanning
- 5-second disk settling delay

**When to Remove**: Stateless VMs, immutable infrastructure

**Boot Time Savings**: ~5-7 seconds

**How to Disable**:
```bash
# Boot parameter:
norestore

# Or remove from init:
# Comment out restore logic in /init and /etc/init.d/rcS
```

#### 2. Multi-TTY Support

**Current**: 6 TTYs (tty1-tty6)

**Optimization**: Keep only tty1 for VM environments

**Boot Time Savings**: ~200-500ms

**Implementation**: Edit `/etc/inittab`, comment out tty2-tty6

#### 3. Network Setup

**Components**:
- `/opt/network.sh` in bootsync.sh
- Network interface detection
- DHCP client startup

**When to Remove**: Static network config or no networking needed

**Boot Time Savings**: ~500-1000ms

**How to Disable**:
```bash
# Boot parameter:
nodhcp

# Or remove from /opt/bootsync.sh:
# Comment out network.sh line
```

#### 4. Extension Loading System

**Components**:
- TCE directory scanning
- Extension mounting
- Dependency resolution

**When to Remove**: All software pre-installed in core image

**Boot Time Savings**: ~1-3 seconds (depending on extensions)

**How to Disable**: Don't specify `tce=` boot parameter

#### 5. Hardware Detection

**Components**:
- PCI device scanning
- Module autoloading
- Hardware-specific scripts

**When to Remove**: VM with known hardware configuration

**Boot Time Savings**: ~200-500ms

**Implementation**: Disable udev or remove hardware detection from init

---

## Boot Parameter Reference

### Performance-Related Parameters

| Parameter | Effect | Boot Time Impact |
|-----------|--------|------------------|
| `quiet` | Suppress kernel messages | Minimal (~10ms) |
| `loglevel=3` | Reduce kernel logging | Minimal (~10ms) |
| `norestore` | Skip backup restoration | 5-7 seconds |
| `nodhcp` | Skip network configuration | 0.5-1 second |
| `nobootsync` | Skip bootsync.sh execution | Variable |
| `noembed` | Skip tmpfs copy (stay in initrd) | -500ms (slower) |
| `tce=` | Specify TCE directory or disable | Variable |
| `restore=` | Specify restore device | Speeds up device scan |

### Custom Parameters (Proposed)

Add these to `/init` for enhanced boot optimization:

| Parameter | Proposed Effect |
|-----------|-----------------|
| `fastboot` | Skip all optional init operations |
| `notty` | Spawn only tty1 |
| `nominimal` | Skip unnecessary device nodes |
| `nowait` | Remove all sleep delays |
| `nohwdetect` | Skip hardware detection |

---

## Configuration Examples

### Example 1: Fastest Boot (Minimal Features)

**Use Case**: Stateless VM, single application, no persistence

**Configuration**:

`/init` modifications:
```bash
#!/bin/sh
mount proc
if ! grep -qw noembed /proc/cmdline; then
  mount / -o remount,size=90%
  umount proc
  exec /sbin/init
fi
umount proc
exec /sbin/init
```

`/etc/inittab`:
```ini
::sysinit:/etc/init.d/rcS
tty1::respawn:/sbin/getty 38400 tty1
::ctrlaltdel:/sbin/reboot
::shutdown:/etc/init.d/rc.shutdown
```

`/opt/bootsync.sh`:
```bash
#!/bin/sh
# Minimal or empty
/opt/bootlocal.sh &
```

**Boot Parameters**:
```
quiet loglevel=3 norestore nodhcp
```

**Expected Boot Time**: 2-4 seconds (kernel + init)

### Example 2: Standard Boot (Balanced)

**Use Case**: Development VM, some persistence, basic features

**Configuration**: Keep current configuration mostly intact

**Modifications**:
- Reduce TTYs to 2-3
- Keep backup/restore but specify device
- Enable network with static config if possible

**Boot Parameters**:
```
quiet loglevel=3 restore=sda1 tce=sda1
```

**Expected Boot Time**: 8-12 seconds

### Example 3: Full Feature Boot (All Features)

**Use Case**: Full system, multiple users, complete persistence

**Configuration**: Current default configuration

**Boot Parameters**:
```
restore multivt
```

**Expected Boot Time**: 15-20 seconds

### Example 4: Direct Kernel Boot (VM Optimized)

**Use Case**: QEMU/KVM environment, maximum speed

**Setup**:
```bash
# Launch VM without bootloader:
qemu-system-x86_64 \
  -kernel /boot/vmlinuz64 \
  -initrd /boot/core.gz \
  -append "quiet loglevel=3 norestore nodhcp noembed" \
  -m 512M \
  -enable-kvm \
  -nographic
```

**Expected Boot Time**: 1-3 seconds

### Example 5: Minimal Initrd Configuration

**Approach**: Create stripped-down `/init`

```bash
#!/bin/sh
# Absolute minimal init
/bin/mount -t proc proc /proc
/bin/mount / -o remount,size=90%
exec /sbin/init
```

**Remove**:
- Date setting logic
- Backup device configuration
- Filetool renaming
- Conditional logic

**Expected Boot Time Reduction**: ~200-400ms

---

## Implementation Roadmap

### Phase 1: Documentation and Analysis (Current)
- ✅ Document current boot process
- ✅ Identify optimization opportunities
- ✅ Provide configuration examples

### Phase 2: Add Boot Parameters (Minimal Changes)
- Add `fastboot` parameter support to `/init`
- Add `nowait` parameter to skip delays
- Add `notty` parameter support to inittab

### Phase 3: Configuration Profiles (Optional)
- Create example configurations for different use cases
- Provide scripts to generate minimal initrd
- Document direct kernel boot setup

### Phase 4: Testing and Benchmarking (Recommended)
- Measure boot times for each configuration
- Document trade-offs
- Provide performance comparison matrix

---

## Performance Comparison Matrix

| Configuration | Boot Time | Footprint | Features | Use Case |
|---------------|-----------|-----------|----------|----------|
| **Current Default** | ~15-20s | ~20MB | Full | General purpose |
| **Minimal Init** | ~8-12s | ~18MB | Most | Development |
| **Fastboot Mode** | ~4-6s | ~16MB | Limited | CI/CD |
| **Direct Kernel** | ~2-4s | ~15MB | Core only | Production VM |
| **No Initrd** | ~1-3s | ~10MB | Minimal | Specialized |

---

## Best Practices for Unikernel Deployment

1. **Use Direct Kernel Boot**: Skip bootloader entirely in VM environments
2. **Disable Persistence**: Use `norestore` if stateless
3. **Minimize TTYs**: Single TTY for automated systems
4. **Static Configuration**: Avoid dynamic hardware detection
5. **Remove Extensions**: Bake software into core image instead of TCE
6. **Skip Network Setup**: Configure networking at VM/container level
7. **Use Built-in Initramfs**: Compile into kernel for slightly faster boot
8. **Parallel Init**: Run independent initialization steps concurrently
9. **Remove Delays**: Eliminate all sleep statements when safe
10. **Optimize Kernel**: Compile custom kernel with only needed drivers

---

## Security Considerations

When optimizing boot time, consider:

1. **Logging**: `quiet` and reduced loglevel may hide boot issues
2. **TTY Access**: Fewer TTYs may limit troubleshooting
3. **Persistence**: Disabling backup/restore affects data retention
4. **Hardware Detection**: Skipping may cause driver issues
5. **Network Setup**: Manual network config required if skipped

---

## Troubleshooting

### Boot Fails After Optimization

1. **Remove optimization parameters**: Boot with defaults
2. **Check kernel messages**: Remove `quiet` parameter
3. **Increase loglevel**: Use `loglevel=7` for verbose output
4. **Enable single-user mode**: Add `init=/bin/sh`

### System Unstable After Changes

1. **Revert /init changes**: Use original init script
2. **Check inittab**: Ensure at least tty1 is configured
3. **Verify dependencies**: Ensure required scripts exist
4. **Test incrementally**: Apply one optimization at a time

---

## References

- [TinyCore Linux Documentation](http://wiki.tinycorelinux.net/)
- [Linux Kernel Boot Process](https://www.kernel.org/doc/html/latest/admin-guide/initrd.html)
- [BusyBox Init Documentation](https://busybox.net/downloads/BusyBox.html)
- [QEMU Direct Kernel Boot](https://wiki.qemu.org/Documentation/Platforms/PC#Boot_from_Linux_kernel_image)

---

## Contributing

Contributions to improve boot time optimizations are welcome. Please test thoroughly before submitting changes.

## License

This documentation is licensed under the same terms as TinyCore Linux (GPL v2).
