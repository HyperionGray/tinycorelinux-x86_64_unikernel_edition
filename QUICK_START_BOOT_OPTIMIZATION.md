# Quick Start: Boot Time Optimization

This guide provides immediate, actionable steps to reduce boot time in TinyCore Linux x86_64 for VM/unikernel deployments.

## Table of Contents

1. [Fastest Implementation (5 minutes)](#fastest-implementation-5-minutes)
2. [VM-Specific Optimizations](#vm-specific-optimizations)
3. [Incremental Optimizations](#incremental-optimizations)
4. [Benchmarking Your Changes](#benchmarking-your-changes)

---

## Fastest Implementation (5 minutes)

### Step 1: Use Direct Kernel Boot (QEMU/KVM)

**Skip the bootloader entirely** by loading kernel directly:

```bash
qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.gz \
  -append "quiet loglevel=3 norestore nodhcp" \
  -m 512M \
  -enable-kvm \
  -nographic
```

**Boot Time Reduction**: ~200-500ms

### Step 2: Disable Unnecessary Services

**Add these boot parameters** to your kernel command line:

```
quiet loglevel=3 norestore nodhcp
```

**Explanation**:
- `quiet` - Suppress console messages
- `loglevel=3` - Reduce kernel logging
- `norestore` - Skip backup restoration (~5-7 seconds saved)
- `nodhcp` - Skip network configuration (~0.5-1 second saved)

**Boot Time Reduction**: ~6-8 seconds

### Step 3: Reduce TTYs

**Edit** `/etc/inittab` to spawn only one TTY:

```bash
# Original:
tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::askfirst:/sbin/getty 38400 tty4
tty5::askfirst:/sbin/getty 38400 tty5
tty6::askfirst:/sbin/getty 38400 tty6

# Optimized:
tty1::respawn:/sbin/getty 38400 tty1
#tty2::respawn:/sbin/getty 38400 tty2
#tty3::respawn:/sbin/getty 38400 tty3
#tty4::askfirst:/sbin/getty 38400 tty4
#tty5::askfirst:/sbin/getty 38400 tty5
#tty6::askfirst:/sbin/getty 38400 tty6
```

**Boot Time Reduction**: ~200-500ms

**Total Savings**: ~7-9 seconds

---

## VM-Specific Optimizations

### For QEMU/KVM Environments

#### 1. Enable Virtio Drivers

**Modify kernel command line** to use virtio for faster I/O:

```bash
qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.gz \
  -drive file=disk.img,if=virtio \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -append "quiet loglevel=3 norestore nodhcp" \
  -enable-kvm
```

#### 2. Optimize VM Hardware Settings

```bash
qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd core.gz \
  -m 512M \
  -smp 2 \
  -enable-kvm \
  -cpu host \
  -append "quiet loglevel=3 norestore nodhcp" \
  -nographic
```

**Key flags**:
- `-enable-kvm` - Use KVM acceleration
- `-cpu host` - Pass through host CPU features
- `-nographic` - Disable graphical display overhead

### For Docker/Container Environments

**Use minimal init** with container-friendly settings:

```dockerfile
# Dockerfile example
FROM scratch
COPY corepure64/ /
CMD ["/init"]
```

**Run with**:
```bash
docker run --rm -it \
  --kernel-memory=256m \
  --memory=512m \
  your-tinycore-image
```

---

## Incremental Optimizations

### Level 1: Boot Parameter Tuning (No File Changes)

**Easy**: Just modify boot parameters

```
# Basic optimization:
quiet loglevel=3 norestore nodhcp

# Aggressive optimization:
quiet loglevel=1 norestore nodhcp noembed
```

**Expected Result**: 6-8 seconds reduction

### Level 2: Configuration File Changes (Low Risk)

#### 2.1 Simplify `/opt/bootsync.sh`

**Original**:
```bash
#!/bin/sh
/opt/network.sh
/opt/bootsetup.sh
/opt/bootlocal.sh &
```

**Optimized** (if no network needed):
```bash
#!/bin/sh
/opt/bootlocal.sh &
```

**Savings**: ~500ms-1s

#### 2.2 Remove Sleep Delays from `tc-restore.sh`

**Original** (line 10 in `/etc/init.d/tc-restore.sh`):
```bash
# wait 5 seconds for disks to settle
sleep 5
```

**Optimized** (if not using physical disks):
```bash
# Skip sleep in VM environments
# sleep 5
```

**Savings**: 5 seconds

### Level 3: Init Script Modifications (Medium Risk)

#### 3.1 Streamline `/init` Script

**Create** `/init.minimal` as a backup-free version:

```bash
#!/bin/sh
mount proc
mount / -o remount,size=90%
umount proc
exec /sbin/init
```

**Usage**: Modify bootloader to use `/init.minimal` instead of `/init`

**Savings**: ~200-500ms

#### 3.2 Make Bootsync Conditional

**Add to top of** `/init`:

```bash
# Skip bootsync if requested
if grep -qw nobootsync /proc/cmdline; then
  touch /tmp/skip_bootsync
fi
```

**Modify rcS** (if exists) to check for flag:

```bash
if [ ! -f /tmp/skip_bootsync ]; then
  /opt/bootsync.sh
fi
```

**Usage**: Add `nobootsync` to kernel parameters

**Savings**: Variable (depends on bootsync.sh contents)

### Level 4: Initrd Optimization (Advanced)

#### 4.1 Build Minimal Initrd

**Steps**:

1. Extract current initrd:
```bash
mkdir initrd_work
cd initrd_work
zcat ../core.gz | cpio -i -d
```

2. Remove unnecessary files:
```bash
# Remove if not needed:
rm -rf opt/bootlocal.sh.example
rm -rf etc/init.d/tc-restore.sh  # if norestore always used
rm -rf usr/bin/filetool*.sh      # if no backup/restore
```

3. Simplify init script (use minimal version above)

4. Repack:
```bash
find . | cpio -o -H newc | gzip > ../core.minimal.gz
```

**Usage**: Use `core.minimal.gz` as initrd

**Savings**: ~100-300ms + reduced memory footprint

---

## Benchmarking Your Changes

### Measure Boot Time

#### Method 1: Using System Timestamps

**Add to** `/opt/bootlocal.sh`:

```bash
#!/bin/sh
BOOT_TIME=$(awk '{print $1}' /proc/uptime)
echo "Boot completed in $BOOT_TIME seconds" | tee /tmp/boot_time.log
```

#### Method 2: Using systemd-analyze (if available)

```bash
systemd-analyze time
```

#### Method 3: Manual Timing

```bash
# On host:
time qemu-system-x86_64 -kernel vmlinuz64 -initrd core.gz \
  -append "quiet loglevel=3 norestore nodhcp" \
  -enable-kvm -nographic
```

### Boot Time Targets

| Configuration | Target Boot Time |
|---------------|------------------|
| Default | 15-20 seconds |
| Basic Optimization | 8-12 seconds |
| Aggressive Optimization | 4-6 seconds |
| VM Direct Boot | 2-4 seconds |
| Theoretical Minimum | 1-2 seconds |

---

## Configuration Templates

### Template 1: Development VM

**Use Case**: Development, debugging, some features needed

**Boot Parameters**:
```
quiet loglevel=3 restore=sda1 tce=sda1
```

**Modified Files**: None (keep defaults)

**Expected Boot Time**: ~10-12 seconds

### Template 2: CI/CD Runner

**Use Case**: Automated testing, stateless, fast boot priority

**Boot Parameters**:
```
quiet loglevel=1 norestore nodhcp nobootsync
```

**Modified Files**:
- `/etc/inittab` - Reduce to 1 TTY
- `/etc/init.d/tc-restore.sh` - Comment out sleep

**Expected Boot Time**: ~4-6 seconds

### Template 3: Production Microservice

**Use Case**: Single application, minimal overhead, maximum speed

**Boot Parameters**:
```
quiet loglevel=1 norestore nodhcp noembed
```

**Modified Files**:
- `/init` - Use minimal version
- `/etc/inittab` - Single TTY only
- `/opt/bootsync.sh` - Application startup only

**Expected Boot Time**: ~2-3 seconds

### Template 4: Embedded/IoT Device

**Use Case**: Resource-constrained, specific hardware, persistent operation

**Boot Parameters**:
```
quiet loglevel=3 restore=mmcblk0p1 nodhcp
```

**Modified Files**:
- `/etc/inittab` - Single TTY
- Pre-configure network (no DHCP)

**Expected Boot Time**: ~6-8 seconds

---

## Validation Checklist

After applying optimizations, verify:

- [ ] System boots successfully
- [ ] Console/TTY accessible (if needed)
- [ ] Network functions (if required)
- [ ] Applications start correctly
- [ ] Data persistence works (if enabled)
- [ ] No critical errors in dmesg
- [ ] Boot time meets target

---

## Rollback Procedures

### If Boot Fails

**Option 1**: Boot with original parameters
```
# Remove custom parameters, use defaults
```

**Option 2**: Emergency shell
```
# Add to kernel parameters:
init=/bin/sh
```

**Option 3**: Mount and fix from live system
```bash
# Mount system and edit configs
mkdir /mnt/fix
mount /dev/sda1 /mnt/fix
vi /mnt/fix/etc/inittab  # or other config files
```

### Restore Original Files

```bash
# If you made backups:
cp /init.backup /init
cp /etc/inittab.backup /etc/inittab
cp /opt/bootsync.sh.backup /opt/bootsync.sh
```

---

## Common Pitfalls

1. **Removing norestore breaks backup**: If you need persistence, don't use `norestore`
2. **No TTY means no console**: Always keep at least tty1
3. **Removing network breaks remote access**: Consider carefully for remote systems
4. **Too aggressive optimization causes instability**: Apply incrementally
5. **VM-specific settings don't work on bare metal**: Test in target environment

---

## Next Steps

1. Start with **Level 1** optimizations (boot parameters only)
2. Benchmark the results
3. Proceed to **Level 2** if more speed needed
4. Test thoroughly before production deployment
5. Document your specific configuration for reproducibility

---

## Support and Troubleshooting

**Debug Boot Issues**:
```
# Remove all optimizations and add verbose logging:
loglevel=7 debug init=/bin/sh
```

**View Boot Messages**:
```bash
dmesg | less
journalctl -b  # if systemd available
```

**Performance Analysis**:
```bash
# Check what's taking time:
ls -la /tmp/*.log
cat /proc/uptime
```

---

## Summary

**Quickest wins** (5 minutes):
1. Add `norestore nodhcp` boot parameters → ~6-8 seconds saved
2. Use direct kernel boot in VMs → ~0.5 seconds saved
3. Comment out extra TTYs in inittab → ~0.3 seconds saved

**Total time saved**: ~7-9 seconds with minimal effort

**For aggressive optimization** (1 hour):
1. All above
2. Minimal init script
3. Stripped initrd
4. Remove sleep delays

**Total time saved**: ~13-18 seconds, reaching 2-4 second boot times

Choose the optimization level that matches your requirements and risk tolerance.
