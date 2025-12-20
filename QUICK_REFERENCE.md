# TinyCore Linux Unikernel Optimization - Quick Reference

## Size Comparison Matrix

### Component Breakdown by Optimization Level

| Component | Current (TinyCore) | Conservative | Aggressive | Extreme |
|-----------|-------------------|--------------|------------|---------|
| **Kernel** | ~10 MB | ~6 MB | ~4 MB | ~2 MB |
| **Initrd/Root** | ~10 MB | ~7 MB | ~4 MB | ~2 MB |
| **Libraries** | ~3-4 MB | ~2 MB | ~1 MB | ~500 KB |
| **BusyBox** | ~2 MB | ~1.5 MB | ~800 KB | ~200 KB |
| **Init System** | ~500 KB | ~300 KB | ~50 KB | ~20 KB |
| **Config Files** | ~1 MB | ~500 KB | ~100 KB | ~50 KB |
| **Persistence** | ~200 KB | 0 KB | 0 KB | 0 KB |
| **TTY Support** | ~100 KB | ~50 KB | 0 KB | 0 KB |
| **Total** | **~20 MB** | **~11 MB** | **~6 MB** | **~3 MB** |
| **Reduction** | Baseline | **45%** | **70%** | **85%** |

## Removable Components Checklist

### ✅ Safe to Remove (Low Risk)

#### For Ephemeral MicroVMs
- [x] Backup/restore system (filetool.sh, tc-restore.sh) - **200 KB**
- [x] Encryption support (bcrypt) - **50 KB**
- [x] Extra TTYs (tty2-6) - **50 KB**
- [x] Locale data (if English/UTF-8 only) - **100 KB**
- [x] Timezone data (if UTC only) - **50 KB**
- [x] Documentation/man pages - **100 KB**
- [x] /etc/services file - **50 KB**

#### Kernel Features
- [x] Sound drivers (ALSA) - **500 KB**
- [x] Bluetooth subsystem - **300 KB**
- [x] Wireless networking - **400 KB**
- [x] USB support (if network-only) - **500 KB**
- [x] Legacy hardware drivers - **1 MB**
- [x] Unused filesystems (XFS, Btrfs, NTFS) - **300 KB**
- [x] Suspend/hibernation - **100 KB**
- [x] Swap support - **50 KB**

**Total Safe Removals: ~3.5-4 MB**

### ⚠️ Remove with Testing (Medium Risk)

#### System Components
- [ ] Dynamic linking support (switch to static) - **500 KB**
- [ ] Shared libraries (if all apps static) - **2-3 MB**
- [ ] BusyBox applets (keep only needed) - **500 KB - 1 MB**
- [ ] Init system (replace with custom) - **300 KB**

#### Kernel Features
- [ ] Loadable module support - **200 KB**
- [ ] Network filesystems (NFS, CIFS) - **400 KB**
- [ ] Advanced networking (bridges, VLANs) - **200 KB**
- [ ] Extra filesystem support - **500 KB**

**Total Medium-Risk Removals: ~4-6 MB**

### ⛔ Remove with Caution (High Risk)

#### System Components
- [ ] Standard libc (replace with musl) - **2 MB savings**
- [ ] All of BusyBox (custom init only) - **1.5 MB**
- [ ] All debugging tools (ps, top, etc.) - **300 KB**

#### Kernel Features
- [ ] Security modules (SELinux, AppArmor) - **300 KB**
- [ ] Extensive driver removal - **2-3 MB**
- [ ] Networking protocols (keep TCP/IP only) - **500 KB**
- [ ] Kernel debugging features - **500 KB**

**Total High-Risk Removals: ~6-8 MB**

## Optimization Strategies by Use Case

### Use Case 1: Web Application MicroVM

**Requirements:**
- Network connectivity (TCP/IP)
- Single application (statically linked)
- No persistence needed
- Headless operation

**Recommended Removals:**
- ✅ All hardware drivers except virtio
- ✅ All filesystems except tmpfs, SquashFS
- ✅ Sound, Bluetooth, USB, wireless
- ✅ Backup/persistence system
- ✅ Multiple TTYs (keep 1 for console)
- ✅ BusyBox applets (minimal set)

**Target Size:** ~6-8 MB
**Boot Time:** <1 second
**Memory:** 128-256 MB

### Use Case 2: Database MicroVM

**Requirements:**
- Network connectivity
- Block storage (persistent disk)
- Memory-intensive operation
- Potential for swap (optional)

**Recommended Removals:**
- ✅ Hardware drivers except virtio-net, virtio-blk
- ✅ Sound, Bluetooth, USB, wireless
- ✅ Most filesystems (keep ext4 + tmpfs)
- ✅ Backup system (use database replication)
- ⚠️ Keep: Performance monitoring tools (top, ps)

**Target Size:** ~8-10 MB
**Boot Time:** <2 seconds
**Memory:** 512 MB - 2 GB

### Use Case 3: Function-as-a-Service

**Requirements:**
- Ultra-fast boot time
- Minimal memory footprint
- Single-purpose execution
- No persistence

**Recommended Removals:**
- ✅ Everything except kernel + app
- ✅ Custom minimal init (direct exec)
- ✅ Static-linked application
- ✅ Minimal kernel (virtio only)
- ✅ No BusyBox (if app doesn't need it)

**Target Size:** ~3-5 MB
**Boot Time:** <500ms
**Memory:** 64-128 MB

### Use Case 4: IoT Edge Gateway

**Requirements:**
- Multiple network interfaces
- Various hardware support
- Persistent configuration
- Long-running operation

**Recommended Removals:**
- ⚠️ Conservative approach
- ✅ Remove only clearly unused hardware
- ⚠️ Keep most networking features
- ⚠️ Keep persistence system
- ✅ Remove: Sound, Bluetooth, USB (if not needed)

**Target Size:** ~12-15 MB
**Boot Time:** <3 seconds
**Memory:** 256-512 MB

## Quick Wins by Effort/Impact

### High Impact, Low Effort ⭐⭐⭐

1. **Remove Backup System** (10 minutes)
   - Effort: Very Low
   - Savings: ~200 KB
   - Risk: None for ephemeral VMs
   - Files: filetool.sh, tc-restore.sh

2. **Disable Extra TTYs** (5 minutes)
   - Effort: Very Low
   - Savings: ~50-100 KB
   - Risk: Low
   - Edit: /etc/inittab

3. **Remove Sound Drivers from Kernel** (1 hour)
   - Effort: Low
   - Savings: ~500 KB
   - Risk: None for servers
   - Config: CONFIG_SOUND=n

4. **Remove Wireless Drivers** (1 hour)
   - Effort: Low
   - Savings: ~400 KB
   - Risk: None for wired VMs
   - Config: CONFIG_WIRELESS=n

### Medium Impact, Medium Effort ⭐⭐

5. **Minimize Kernel Config** (1 day)
   - Effort: Medium
   - Savings: ~3-4 MB
   - Risk: Medium (requires testing)
   - Action: Custom .config

6. **Build with musl libc** (2-3 days)
   - Effort: Medium
   - Savings: ~2-3 MB
   - Risk: Medium (compatibility)
   - Action: Rebuild all binaries

7. **Minimal BusyBox Config** (1-2 days)
   - Effort: Medium
   - Savings: ~500 KB - 1 MB
   - Risk: Medium (need analysis)
   - Action: Custom .config

### Lower Impact, High Effort ⭐

8. **Custom Init System** (1 week)
   - Effort: High
   - Savings: ~300-500 KB
   - Risk: High (requires testing)
   - Action: Write custom init

9. **Custom libc Subset** (2-4 weeks)
   - Effort: Very High
   - Savings: ~300-500 KB
   - Risk: Very High
   - Action: Only for extreme cases

## Commands Quick Reference

### Analyze Current System

```bash
# Check kernel size
ls -lh /boot/vmlinuz*

# Check initrd size
ls -lh /boot/core.gz

# List loaded kernel modules
lsmod

# Check memory usage
free -m
cat /proc/meminfo

# List processes and memory
ps aux --sort=-rss

# Check disk usage
df -h
du -sh /*

# List shared libraries
ldd /bin/busybox
```

### Build Minimal Kernel

```bash
# Start with minimal config
make tinyconfig

# Enable essentials
make menuconfig
# Enable: PROC_FS, SYSFS, TMPFS, SQUASHFS, virtio drivers

# Build optimized for size
make -j$(nproc) KCFLAGS="-Os" bzImage
```

### Build Static Binary with musl

```bash
# Compile application
musl-gcc -static -Os -flto \
  -ffunction-sections -fdata-sections \
  -Wl,--gc-sections -s \
  myapp.c -o myapp

# Verify static
ldd myapp  # Should say "not a dynamic executable"

# Check size
ls -lh myapp
```

### Create Minimal Root Filesystem

```bash
# Create directories
mkdir -p rootfs/{bin,sbin,etc,dev,proc,sys,tmp,app}

# Copy essentials
cp busybox rootfs/bin/
cp myapp rootfs/app/

# Create SquashFS
mksquashfs rootfs rootfs.squashfs -comp xz -Xbcj x86 -b 1M

# Check size
ls -lh rootfs.squashfs
```

### Test with QEMU

```bash
# Boot minimal system
qemu-system-x86_64 \
  -M microvm \
  -enable-kvm \
  -cpu host \
  -m 256M \
  -nographic \
  -serial stdio \
  -kernel vmlinuz \
  -initrd rootfs.squashfs \
  -append "console=ttyS0 quiet"
```

## Boot Time Optimization

### Current vs Optimized Boot Sequence

#### Standard TinyCore Boot (~3-5 seconds)
1. Kernel initialization (1-2s)
2. initrd extraction (0.5s)
3. BusyBox init starts (0.2s)
4. rcS scripts run (1-2s)
5. TTY spawning (0.5s)
6. Backup restore check (0.5s)
7. Application start (variable)

#### Optimized Boot (~0.5-1 second)
1. Minimal kernel init (0.3s)
2. Custom init mounts filesystems (0.05s)
3. Network setup (0.1s)
4. Direct application exec (0.05s)

### Boot Time Improvements

| Optimization | Time Saved | Cumulative |
|--------------|------------|------------|
| Minimal kernel | 0.5-1s | 0.5-1s |
| No initrd scripts | 1-2s | 1.5-3s |
| Custom init | 0.3s | 1.8-3.3s |
| Static linking | 0.2s | 2-3.5s |
| No TTY spawn | 0.5s | 2.5-4s |
| No backup check | 0.5s | **3-4.5s** |

**Total Boot Time: 0.5-1s (from 3-5s)**

## Memory Footprint Comparison

### Runtime Memory Usage

| Configuration | Kernel | Init | Filesystem Cache | Userspace | Total |
|---------------|--------|------|------------------|-----------|-------|
| Standard TinyCore | 60 MB | 5 MB | 30 MB | 10 MB | **105 MB** |
| Conservative Opt | 40 MB | 3 MB | 20 MB | 5 MB | **68 MB** |
| Aggressive Opt | 25 MB | 2 MB | 10 MB | 3 MB | **40 MB** |
| Extreme Opt | 15 MB | 1 MB | 5 MB | 2 MB | **23 MB** |

**Memory Savings: 60-80%** compared to standard configuration

## Decision Matrix

### Choose Your Optimization Level

| Factor | Conservative | Aggressive | Extreme |
|--------|-------------|------------|---------|
| **Time Investment** | Days | Weeks | Months |
| **Risk Level** | Low | Medium | High |
| **Size Reduction** | 45% | 70% | 85% |
| **Boot Time** | 1-2s | <1s | <500ms |
| **Maintenance** | Low | Medium | High |
| **Compatibility** | High | Medium | Low |
| **Testing Required** | Moderate | Extensive | Very Extensive |

### Recommendation by Scenario

- **Production workload, proven app:** Conservative
- **New deployment, flexibility needed:** Conservative
- **Specific use case, well-defined:** Aggressive
- **Research, proof-of-concept:** Aggressive or Extreme
- **Function-as-a-Service, cold starts:** Extreme
- **Cost optimization critical:** Aggressive
- **Security-critical, minimal attack surface:** Aggressive or Extreme

## Common Pitfalls

### ❌ Don't Do This

1. **Remove kernel features you need**
   - Test thoroughly with target workload
   - Keep virtio drivers for KVM
   - Don't remove TCP/IP for networked apps

2. **Break the init process**
   - PID 1 must never exit
   - Handle SIGCHLD properly
   - Mount essential filesystems

3. **Forget about security**
   - Keep seccomp for sandboxing
   - Enable kernel hardening options
   - Use read-only root filesystem

4. **Optimize prematurely**
   - Profile first, optimize second
   - Measure actual impact
   - Document what you remove

### ✅ Do This Instead

1. **Start conservative, measure, iterate**
2. **Test each optimization independently**
3. **Keep detailed notes on removals**
4. **Maintain rollback capability**
5. **Automate build and testing**
6. **Monitor production metrics**

## Success Metrics

### Key Performance Indicators

| Metric | Baseline | Target Conservative | Target Aggressive |
|--------|----------|-------------------|------------------|
| Image Size | 20 MB | 11 MB | 6 MB |
| Boot Time | 3-5s | 1-2s | <1s |
| Memory Usage | 100 MB | 70 MB | 40 MB |
| Build Time | - | <10 min | <30 min |
| Attack Surface | 100% | 60% | 30% |

### Validation Checklist

- [ ] Application starts successfully
- [ ] All required functionality works
- [ ] Boot time meets requirements
- [ ] Memory usage within limits
- [ ] Network connectivity functional
- [ ] Logging/monitoring works (if needed)
- [ ] Error handling proper
- [ ] Security hardening validated
- [ ] Performance acceptable
- [ ] Cost reduction achieved

## Next Steps

1. **Read full documentation:**
   - UNIKERNEL_OPTIMIZATION.md - Detailed analysis
   - IMPLEMENTATION_GUIDE.md - Step-by-step instructions

2. **Choose optimization level:**
   - Assess requirements and constraints
   - Consider time and risk factors
   - Start conservative, iterate

3. **Begin with quick wins:**
   - Remove backup system
   - Disable extra TTYs
   - Profile current usage

4. **Measure and validate:**
   - Test each change
   - Measure impact
   - Document results

5. **Iterate and refine:**
   - Apply next optimization
   - Retest and measure
   - Repeat until targets met

## Resources

- **TinyCore Linux:** http://tinycorelinux.net/
- **musl libc:** https://musl.libc.org/
- **BusyBox:** https://busybox.net/
- **Linux Kernel:** https://kernel.org/
- **Unikraft:** https://unikraft.org/
- **OSv:** http://osv.io/

## Summary

This quick reference provides a roadmap for optimizing TinyCore Linux for unikernel/microVM deployments:

- **40-85% size reduction** possible
- **3-10x faster boot times**
- **60-80% memory savings**
- Multiple optimization paths based on risk tolerance
- Clear migration strategy from conservative to aggressive

Start with **quick wins** (backup removal, TTY reduction), then progress to **kernel optimization** and **musl libc**, and finally consider **custom init** for extreme optimization.
