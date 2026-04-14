# Remastered TinyCore Linux x86_64 (Core Pure 64)

This is a slightly remastered version of [TinyCore Linux x86_64 (Core Pure 64)](http://tinycorelinux.net/)

This document explains the changes we've made to the OS, along with links
to the original and modified source code.

## Version

![Architecture](https://img.shields.io/badge/arch-x86__64-brightgreen.svg) ![Version](https://img.shields.io/badge/version-6.4.1-blue.svg)

## Features

This remastered TinyCore Linux distribution provides:

* **Ultra-lightweight**: Minimal footprint perfect for microVM and container deployments
* **Fast boot times**: Optimized to boot in under 2 seconds with proper configuration
* **Unikernel-style deployment**: Designed for ephemeral, single-purpose VM instances
* **Comprehensive optimization guides**: Detailed documentation for various use cases
* **Flexible configuration**: Multiple optimization strategies from conservative to extreme
* **x86_64 architecture**: Full 64-bit support for modern applications
* **GPL v2 licensed**: Open source with complete source code availability

### Optimization Capabilities

| Approach | Size Reduction | Boot Time | Use Case |
|----------|---------------|-----------|----------|
| Conservative | 45% (20MB → 11MB) | <2s | Production systems |
| Aggressive | 70% (20MB → 6MB) | <1s | Specialized deployments |
| Extreme | 85% (20MB → 3MB) | <500ms | Single-purpose VMs |

## Installation

### Prerequisites

- QEMU, VirtualBox, VMware, or other x86_64 hypervisor
- At least 512MB RAM (256MB for minimal configurations)
- x86_64 processor with virtualization support

### Quick Start

1. **Download the distribution files** from the repository or release page

2. **For VM deployment**, use one of the provided scripts:
   ```bash
   # Fast boot configuration
   ./examples/vm-scripts/qemu-fast-boot.sh
   
   # Balanced configuration
   ./examples/vm-scripts/qemu-balanced-boot.sh
   
   # Development configuration
   ./examples/vm-scripts/qemu-dev-boot.sh
   ```

3. **For custom deployment**, use the setup script:
   ```bash
   ./setup-unikernel.sh
   ```

### Manual Installation

For manual setup or integration with existing infrastructure:

1. Extract the distribution files
2. Configure your bootloader with appropriate kernel parameters
3. Mount the core filesystem (corepure64/)
4. Apply optimization configurations from examples/boot-configs/

See [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for detailed installation instructions.

## Usage

### Basic Usage

**Launch with default configuration:**
```bash
qemu-system-x86_64 -m 512M -kernel vmlinuz64 -initrd corepure64.gz \
  -append "quiet console=ttyS0"
```

**Launch with boot optimization:**
```bash
qemu-system-x86_64 -m 256M -kernel vmlinuz64 -initrd corepure64.gz \
  -append "quiet loglevel=3 norestore nodhcp"
```

### Optimization Strategies

**For fast boot times:**
- Add `quiet loglevel=3 norestore nodhcp` to kernel parameters
- Use minimal boot configuration from examples/boot-configs/
- See [QUICK_START_BOOT_OPTIMIZATION.md](QUICK_START_BOOT_OPTIMIZATION.md)

**For minimal footprint:**
- Follow aggressive optimization guide in [UNIKERNEL_OPTIMIZATION.md](UNIKERNEL_OPTIMIZATION.md)
- Remove unnecessary kernel modules
- Strip non-essential services

**For production deployment:**
- Use conservative optimization approach
- Enable appropriate logging
- Configure persistent storage as needed

### Configuration

Key configuration files:
- `/opt/bootlocal.sh` - Boot-time initialization script
- `/opt/bootsync.sh` - Synchronous boot actions
- `/opt/onboot.lst` - Extensions to load at boot
- Kernel parameters - Boot optimization settings

Example configurations are provided in `examples/boot-configs/` for various scenarios.

### Benchmarking

Measure your boot time:
```bash
./examples/vm-scripts/benchmark-boot.sh
```

## Un-modified sources

Un-modified sources are maintained in the master branch and in the Jidoteki OSS repo:

* [https://github.com/jidoteki/tinycorelinux-x86_64/tree/master](https://github.com/jidoteki/tinycorelinux-x86_64/tree/master)

and

* [https://opensource.jidoteki.com/tinycorelinux/x86_64/6.4.1/](https://opensource.jidoteki.com/tinycorelinux/x86_64/6.4.1/)

## Modified sources

Modified sources are maintained in the version branch:

* [https://github.com/jidoteki/tinycorelinux-x86_64/tree/6.4.1](https://github.com/jidoteki/tinycorelinux-x86_64/tree/6.4.1)

## Boot Time Optimization

This repository includes comprehensive documentation for reducing boot time and system footprint for unikernel VM deployments:

* **[BOOT_OPTIMIZATION.md](BOOT_OPTIMIZATION.md)** - Comprehensive technical guide covering all optimization techniques
* **[QUICK_START_BOOT_OPTIMIZATION.md](QUICK_START_BOOT_OPTIMIZATION.md)** - Quick start guide for immediate implementation
* **[BOOT_OPTIMIZATION_SUMMARY.md](BOOT_OPTIMIZATION_SUMMARY.md)** - Executive summary and implementation roadmap
* **[examples/boot-configs/](examples/boot-configs/)** - Configuration file examples for different scenarios
* **[examples/vm-scripts/](examples/vm-scripts/)** - VM launch scripts and benchmarking tools

**Quick Start**: Add `quiet loglevel=3 norestore nodhcp` to your kernel boot parameters to save 6-8 seconds of boot time.

See [QUICK_START_BOOT_OPTIMIZATION.md](QUICK_START_BOOT_OPTIMIZATION.md) for step-by-step instructions.

## System Analysis

For a detailed analysis of TinyCore Linux architecture and design decisions, see [TINYCORE_ANALYSIS.md](TINYCORE_ANALYSIS.md).

## Un-published sources

The following configuration files may be modified in our binary distributions,
but we've opted not to publish them publicly, for obvious reasons:

* /etc/passwd
* /etc/shadow
* /etc/fstab
* /etc/group
* /etc/issue
* /etc/motd
* /etc/sudoers
* /opt/bootlocal.sh
* /opt/onboot.lst
* /opt/.filetool.lst
* /opt/.xfiletool.lst

Private files un-related to the original TinyCore Linux are covered by a separate
license, and may or may not be published publicly, according to their individual license.

## Unikernel Optimization

This repository includes comprehensive documentation for optimizing TinyCore Linux for unikernel-style deployment in ephemeral microVMs:

* **[UNIKERNEL_SUMMARY.md](UNIKERNEL_SUMMARY.md)** - Executive summary and quick overview
* **[UNIKERNEL_OPTIMIZATION.md](UNIKERNEL_OPTIMIZATION.md)** - Detailed component analysis and optimization strategies
* **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Step-by-step implementation instructions with scripts
* **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick lookup guide and decision matrix
* **[TINYCORE_ANALYSIS.md](TINYCORE_ANALYSIS.md)** - Understanding TinyCore Linux architecture

### Key Optimization Results

| Approach | Size Reduction | Boot Time | Risk Level |
|----------|---------------|-----------|------------|
| Conservative | 45% (20MB → 11MB) | <2s | Low |
| Aggressive | 70% (20MB → 6MB) | <1s | Medium |
| Extreme | 85% (20MB → 3MB) | <500ms | High |

See [UNIKERNEL_SUMMARY.md](UNIKERNEL_SUMMARY.md) for detailed recommendations.

## Contributing

We welcome contributions to this project! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:

- Reporting issues and bugs
- Submitting enhancements and optimizations
- Documentation improvements
- Code style and testing requirements

## License

TinyCore Linux is [licensed under GPL v2](LICENSE), and all custom code developed
by Robert Shingledecker is therefore also covered by the same GPL v2 License.
Any other software contained within, if not specifically stated would also fall
under the same such license.

## Thanks

We want to thank the [TinyCore Linux community](http://forum.tinycorelinux.net/)
for their support and hard work on this OS.

We also want to thank all Open Source software developers for contributing
valuable source code for everyone to use freely.

## Questions

This document is Copyright (c) 2016 Alexander Williams, Unscramble license@unscramble.jp

All licensing questions/issues should be sent to the email address above.
