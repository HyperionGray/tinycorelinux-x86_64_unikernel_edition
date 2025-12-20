# Unikernel Optimization Implementation Guide

This guide provides concrete steps and configurations for optimizing TinyCore Linux for unikernel/microVM use cases.

## Quick Start: Minimal Changes for Ephemeral VMs

These changes provide immediate benefits with minimal risk:

### 1. Remove Persistence/Backup System

The backup and restore system is unnecessary for ephemeral VMs:

**Files to remove:**
```bash
# Remove backup/restore scripts (saves ~150 KB)
rm -f /usr/bin/filetool.sh
rm -f /usr/bin/filetool_orig.sh
rm -f /usr/bin/filetool_wrapper.sh
rm -f /etc/init.d/tc-restore.sh
rm -f /opt/.filetool.lst
rm -f /opt/.xfiletool.lst
```

**Update init script** (`/corepure64/init`):
```bash
#!/bin/sh
mount proc

# Set the initial date
export $(cat /proc/cmdline | tr ' ' '\n' | grep "^jido_builddate=")
if [ ! -z ${jido_builddate-} ]; then
  [ "$jido_builddate" -lt `/bin/date +%s` ] || /bin/date +%s -s @${jido_builddate}
fi

# REMOVED: backup_device configuration (not needed for ephemeral)
# REMOVED: filetool wrapper renaming (not needed)

grep -qw multivt /proc/cmdline && sed -i s/^#tty/tty/ /etc/inittab
if ! grep -qw noembed /proc/cmdline; then

  inodes=`grep MemFree /proc/meminfo | awk '{print $2/3}' | cut -d. -f1`

  mount / -o remount,size=90%,nr_inodes=$inodes
  umount proc
  exec /sbin/init
fi
umount proc
if mount -t tmpfs -o size=90% tmpfs /mnt; then
  if tar -C / --exclude=mnt -cf - . | tar -C /mnt/ -xf - ; then
    mkdir /mnt/mnt
    exec /sbin/switch_root mnt /sbin/init
  fi
fi
exec /sbin/init
```

### 2. Minimize TTY Support

For headless VMs, reduce TTY count:

**Update `/corepure64/etc/inittab`:**
```bash
# /etc/inittab: init configuration for busybox init.
# Boot-time system configuration/initialization script.
#
::sysinit:/etc/init.d/rcS

# Single TTY for console access only
tty1::respawn:/sbin/getty 38400 tty1

# REMOVED: tty2-6 (saves memory and reduces attack surface)
# tty2::respawn:/sbin/getty 38400 tty2
# tty3::respawn:/sbin/getty 38400 tty3
# tty4::askfirst:/sbin/getty 38400 tty4
# tty5::askfirst:/sbin/getty 38400 tty5
# tty6::askfirst:/sbin/getty 38400 tty6

# Stuff to do when restarting the init 
# process, or before rebooting.
::restart:/etc/init.d/rc.shutdown
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/etc/init.d/rc.shutdown
```

### 3. Minimal Boot Script

**Simplified `/corepure64/opt/bootsync.sh`:**
```bash
#!/bin/sh
# Minimal boot script for ephemeral microVM
# Only essential network and application setup

# Configure network (if needed)
# /opt/network.sh

# Launch application
# /opt/bootlocal.sh &
```

## Kernel Configuration for MicroVMs

### Minimal Kernel Config for KVM Guest

Create a minimal `.config` for kernel compilation:

```bash
# Save this as kernel_microvm_minimal.config

# Essential for boot
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_SMP=y
CONFIG_PRINTK=y
CONFIG_BUG=y

# Virtualization guest support (ESSENTIAL for KVM)
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_SPINLOCKS=y
CONFIG_KVM_GUEST=y
CONFIG_VIRTIO=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_NET=y
CONFIG_VIRTIO_BLK=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_HW_RANDOM_VIRTIO=y

# Basic networking (TCP/IP only)
CONFIG_NET=y
CONFIG_INET=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y

# Essential filesystems
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XZ=y
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y

# Basic block device support
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_LOOP=y

# Disable unnecessary features
CONFIG_MODULES=n              # No loadable modules (static kernel)
CONFIG_SWAP=n                 # No swap support
CONFIG_SUSPEND=n              # No suspend/resume
CONFIG_HIBERNATION=n          # No hibernation
CONFIG_PM=n                   # No power management
CONFIG_ACPI=n                 # No ACPI (or minimal)
CONFIG_BT=n                   # No Bluetooth
CONFIG_WIRELESS=n             # No wireless
CONFIG_WLAN=n                 # No WLAN
CONFIG_SOUND=n                # No sound
CONFIG_SND=n                  # No ALSA
CONFIG_DRM=n                  # No graphics (or minimal VGA)
CONFIG_FB=n                   # No framebuffer
CONFIG_USB_SUPPORT=n          # No USB
CONFIG_HID=n                  # No HID devices
CONFIG_MTD=n                  # No MTD
CONFIG_RAID=n                 # No RAID
CONFIG_MD=n                   # No MD
CONFIG_NETWORK_FILESYSTEMS=n  # No NFS/CIFS
CONFIG_KALLSYMS=n            # No kernel symbols
CONFIG_DEBUG_KERNEL=n        # No debug features
CONFIG_FTRACE=n              # No function tracing
CONFIG_KPROBES=n             # No kernel probes

# Security (keep minimal hardening)
CONFIG_SECURITY=y
CONFIG_SECCOMP=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_CGROUPS=y

# Size optimization
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_KERNEL_XZ=y            # XZ compression for kernel
```

### Building the Minimal Kernel

```bash
# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.tar.xz
tar -xf linux-5.15.tar.xz
cd linux-5.15

# Apply minimal config
cp ../kernel_microvm_minimal.config .config
make olddefconfig

# Build kernel (optimized for size)
make -j$(nproc) KCFLAGS="-Os -march=x86-64 -mtune=generic"

# Result: Kernel should be ~3-4 MB (vs ~10 MB standard)
ls -lh arch/x86/boot/bzImage
```

## Building with musl libc

### Why musl for Unikernels?

- **Small size**: ~600-800 KB vs 2.5-3 MB for glibc
- **Static linking friendly**: Designed for static compilation
- **Clean, auditable code**: Easier security review
- **Fast**: Optimized for performance

### Setup musl Cross-Compiler

```bash
# Install musl-gcc wrapper
wget https://musl.libc.org/releases/musl-1.2.3.tar.gz
tar -xf musl-1.2.3.tar.gz
cd musl-1.2.3

./configure --prefix=/usr/local/musl
make -j$(nproc)
sudo make install

# Test musl-gcc
/usr/local/musl/bin/musl-gcc --version
```

### Rebuilding BusyBox with musl

```bash
# Download BusyBox
wget https://busybox.net/downloads/busybox-1.35.0.tar.bz2
tar -xf busybox-1.35.0.tar.bz2
cd busybox-1.35.0

# Minimal config for microVM
make defconfig
make menuconfig  # Configure as below

# Build statically with musl
make CC=/usr/local/musl/bin/musl-gcc \
     LDFLAGS=--static \
     -j$(nproc)

# Result: Single ~1.5 MB binary (vs ~2 MB with glibc)
ls -lh busybox
```

### BusyBox Configuration for MicroVM

In `make menuconfig`, enable/disable:

**Essential (ENABLE):**
- Shell (ash)
- Core utilities: ls, cat, cp, mv, rm, mkdir, mount, umount
- Init system: init, halt, reboot, poweroff
- Networking: ip, route, ifconfig (if needed)
- Process: ps, kill (if needed)

**Remove for Single-App (DISABLE):**
- Editors: vi, sed (unless app needs them)
- Archiving: tar, gzip, gunzip (unless unpacking needed)
- File utils: find, sort, uniq (unless needed)
- Network: wget, telnet, ftp, ftpd, httpd
- System: cron, syslogd, klogd
- Process: top, free (for minimal systems)

**Settings:**
- Build Options → Build as static binary: **ENABLE**
- Installation Options → Don't use /usr: **ENABLE**

## Custom Minimal Init System

For single-application VMs, replace BusyBox init with a minimal launcher:

### Option 1: Minimal Shell Script Init

**`/init` (shell version):**
```bash
#!/bin/sh
# Minimal init for single-application microVM

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /tmp

# Configure loopback
ip link set lo up

# Configure network (if needed)
ip link set eth0 up
# Static IP example:
# ip addr add 192.168.1.100/24 dev eth0
# ip route add default via 192.168.1.1
# Or DHCP:
# udhcpc -i eth0 -s /etc/udhcpc/default.script

# Set hostname
hostname microvm

# Launch application (replace with your app)
exec /app/myapp
```

### Option 2: Compiled Minimal Init (C)

**`minimal_init.c`:**
```c
/* Minimal init system for single-application microVM
 * Compile: musl-gcc -static -Os -s minimal_init.c -o init
 * Size: ~20-30 KB
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/reboot.h>
#include <signal.h>
#include <sys/wait.h>

static pid_t app_pid = 0;

void signal_handler(int sig) {
    if (sig == SIGCHLD) {
        // Child (application) died, reboot or shutdown
        int status;
        waitpid(-1, &status, WNOHANG);
        
        sync();
        reboot(RB_AUTOBOOT);  // Or RB_POWER_OFF for shutdown
    }
}

int main(int argc, char *argv[]) {
    // Must be PID 1
    if (getpid() != 1) {
        fprintf(stderr, "This init must be run as PID 1\n");
        return 1;
    }

    // Mount essential filesystems
    if (mount("proc", "/proc", "proc", MS_NODEV | MS_NOSUID | MS_NOEXEC, NULL) < 0) {
        perror("mount /proc");
    }
    
    if (mount("sysfs", "/sys", "sysfs", MS_NODEV | MS_NOSUID | MS_NOEXEC, NULL) < 0) {
        perror("mount /sys");
    }
    
    if (mount("devtmpfs", "/dev", "devtmpfs", MS_NOSUID, NULL) < 0) {
        perror("mount /dev");
    }
    
    if (mount("tmpfs", "/tmp", "tmpfs", MS_NOSUID | MS_NODEV, "size=50%") < 0) {
        perror("mount /tmp");
    }

    // Set up signal handling for child death
    signal(SIGCHLD, signal_handler);

    // Configure network (simplified)
    system("/sbin/ip link set lo up");
    system("/sbin/ip link set eth0 up");
    // Uncomment for DHCP:
    // system("/sbin/udhcpc -i eth0 -b -q");

    // Fork and exec application
    app_pid = fork();
    if (app_pid == 0) {
        // Child process - exec application
        char *app_argv[] = { "/app/myapp", NULL };
        char *app_envp[] = { 
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "HOME=/root",
            NULL 
        };
        
        execve("/app/myapp", app_argv, app_envp);
        perror("execve /app/myapp");
        _exit(1);
    } else if (app_pid < 0) {
        perror("fork");
        return 1;
    }

    // PID 1 must never exit - reap zombies and wait
    while (1) {
        pause();  // Wait for signals
    }

    return 0;
}
```

**Compile:**
```bash
musl-gcc -static -Os -s minimal_init.c -o init
strip init
ls -lh init  # Should be ~20-30 KB
```

## Filesystem Layout for Optimized System

### Minimal Directory Structure

```
/
├── app/                    # Application directory
│   ├── myapp               # Your static-linked application
│   └── data/               # Application data (if needed)
├── bin/                    # Essential binaries (if not using minimal init)
│   ├── busybox             # Or individual applets
│   └── sh -> busybox
├── dev/                    # Device nodes (mounted via devtmpfs)
├── etc/                    # Minimal configuration
│   ├── hostname
│   ├── hosts
│   ├── resolv.conf
│   └── passwd              # If multi-user needed
├── init                    # Init script or binary (at root)
├── lib64/                  # Only if dynamic linking (avoid)
├── proc/                   # Mounted at runtime
├── root/                   # Root home (if needed)
├── sbin/                   # System binaries (minimal)
│   └── ip                  # For networking
├── sys/                    # Mounted at runtime
├── tmp/                    # Mounted as tmpfs
└── usr/                    # Additional tools (if needed)
    └── bin/
```

### Minimal Configuration Files

**`/etc/hostname`:**
```
microvm
```

**`/etc/hosts`:**
```
127.0.0.1   localhost microvm
::1         localhost microvm
```

**`/etc/resolv.conf`:**
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

**`/etc/passwd` (if needed):**
```
root:x:0:0:root:/root:/bin/sh
```

## Building the Optimized Root Filesystem

### Script to Create Minimal Rootfs

```bash
#!/bin/bash
# build_minimal_rootfs.sh - Create minimal root filesystem

set -e

ROOTFS_DIR="rootfs_minimal"
OUTPUT_FILE="rootfs_minimal.squashfs"

# Create directory structure
mkdir -p ${ROOTFS_DIR}/{bin,sbin,etc,dev,proc,sys,tmp,root,app,usr/bin}

# Copy init system
if [ -f minimal_init ]; then
    cp minimal_init ${ROOTFS_DIR}/init
    chmod +x ${ROOTFS_DIR}/init
else
    cat > ${ROOTFS_DIR}/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /tmp
ip link set lo up
ip link set eth0 up
exec /app/myapp
EOF
    chmod +x ${ROOTFS_DIR}/init
fi

# Copy BusyBox (if using)
if [ -f busybox ]; then
    cp busybox ${ROOTFS_DIR}/bin/
    # Create symlinks for essential applets
    for applet in sh ls cat mount umount ip; do
        ln -sf /bin/busybox ${ROOTFS_DIR}/bin/${applet}
    done
fi

# Copy application
if [ -f myapp ]; then
    cp myapp ${ROOTFS_DIR}/app/
    chmod +x ${ROOTFS_DIR}/app/myapp
fi

# Create minimal config files
echo "microvm" > ${ROOTFS_DIR}/etc/hostname

cat > ${ROOTFS_DIR}/etc/hosts << EOF
127.0.0.1   localhost microvm
::1         localhost microvm
EOF

cat > ${ROOTFS_DIR}/etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# Create device nodes (if not using devtmpfs)
# mknod ${ROOTFS_DIR}/dev/null c 1 3
# mknod ${ROOTFS_DIR}/dev/zero c 1 5
# mknod ${ROOTFS_DIR}/dev/console c 5 1

# Set permissions
chmod 755 ${ROOTFS_DIR}
chmod 755 ${ROOTFS_DIR}/{bin,sbin,etc,dev,proc,sys,tmp,root,app}
chmod 1777 ${ROOTFS_DIR}/tmp

# Create SquashFS image
mksquashfs ${ROOTFS_DIR} ${OUTPUT_FILE} \
    -comp xz \
    -Xbcj x86 \
    -b 1M \
    -noappend \
    -no-xattrs

# Show result
ls -lh ${OUTPUT_FILE}
echo "Minimal rootfs created: ${OUTPUT_FILE}"
```

## Size Optimization Techniques

### 1. Strip Binaries

```bash
# Strip all binaries to remove debug symbols
find rootfs_minimal -type f -executable | while read f; do
    file "$f" | grep -q ELF && strip -s "$f" 2>/dev/null || true
done
```

### 2. Compress Kernel

```bash
# Use XZ compression for maximum compression
# In kernel config: CONFIG_KERNEL_XZ=y

# Or compress manually after build
xz -9 -C crc32 vmlinux
```

### 3. Optimize SquashFS

```bash
# Best compression for rootfs
mksquashfs rootfs_minimal rootfs.squashfs \
    -comp xz \
    -Xbcj x86 \           # x86 binary filter
    -b 1M \               # Large block size
    -Xdict-size 100% \    # Maximum dictionary
    -noappend \
    -no-xattrs \
    -no-fragments         # May reduce size for small files
```

### 4. Dead Code Elimination

For custom compiled applications:

```bash
# Use LTO (Link Time Optimization) and dead code elimination
musl-gcc -static -Os -flto -ffunction-sections -fdata-sections \
         -Wl,--gc-sections -s myapp.c -o myapp
```

## Testing the Optimized System

### Boot with QEMU/KVM

```bash
# Test optimized system with QEMU
qemu-system-x86_64 \
    -M microvm \                    # MicroVM machine type (minimal)
    -enable-kvm \
    -cpu host \
    -m 256M \                       # Memory
    -nodefaults \
    -no-user-config \
    -nographic \
    -serial stdio \
    -kernel vmlinuz \               # Minimal kernel
    -initrd rootfs.squashfs \       # Minimal rootfs
    -append "console=ttyS0 quiet"
```

### Measure Boot Time

```bash
# Add timestamps to init script
#!/bin/sh
echo "Init start: $(cat /proc/uptime | cut -d' ' -f1)"
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
echo "Mounts done: $(cat /proc/uptime | cut -d' ' -f1)"
ip link set lo up
echo "Network up: $(cat /proc/uptime | cut -d' ' -f1)"
exec /app/myapp
```

### Memory Usage Analysis

```bash
# Check memory usage
free -m
cat /proc/meminfo

# Check process memory
ps aux
```

## Migration Path

### Phase 1: Quick Wins (1-2 days)
1. Remove backup/persistence system
2. Reduce TTY count to 1
3. Remove unused configuration files
4. **Expected savings: ~200-300 KB**

### Phase 2: Kernel Optimization (1 week)
1. Audit kernel .config
2. Disable unused drivers and features
3. Build and test minimal kernel
4. **Expected savings: ~3-4 MB**

### Phase 3: Userspace Optimization (2 weeks)
1. Rebuild with musl libc
2. Create minimal BusyBox configuration
3. Static link application
4. **Expected savings: ~2-3 MB**

### Phase 4: Custom Init (1 week)
1. Develop custom init system
2. Test application lifecycle
3. Validate error handling
4. **Expected savings: ~500 KB**

**Total Expected Savings: 6-8 MB (40-50% reduction)**

## Troubleshooting

### Application Won't Start

1. Check if application is statically linked: `ldd /app/myapp`
2. Verify all dependencies are present
3. Check file permissions: `ls -l /app/myapp`
4. Add debugging to init script: `set -x`

### Network Not Working

1. Check if virtio_net is in kernel: `lsmod | grep virtio`
2. Verify network interface: `ip link`
3. Test DHCP: `udhcpc -i eth0 -n -q`
4. Check routes: `ip route`

### Boot Hangs

1. Add `console=ttyS0` to kernel command line
2. Enable kernel debug: `debug` in command line
3. Check init script syntax: `sh -n /init`
4. Verify init is executable: `ls -l /init`

### Out of Memory

1. Increase VM memory allocation
2. Check tmpfs size: `df -h /tmp`
3. Reduce tmpfs size in mount options
4. Profile application memory usage

## Conclusion

This implementation guide provides practical steps to optimize TinyCore Linux for unikernel/microVM deployments. Start with the quick wins, then progressively optimize based on your specific requirements and risk tolerance.

**Key Takeaways:**
- Remove persistence system for ephemeral VMs (~200 KB)
- Minimize kernel configuration (~3-4 MB savings)
- Use musl libc instead of glibc (~2-3 MB savings)
- Custom minimal init system (~500 KB savings)
- Static linking for simplicity and security

**Total achievable optimization: 40-70% size reduction** with moderate effort.
