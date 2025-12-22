# Remastered TinyCore Linux x86_64 (Core Pure 64)

This is a slightly remastered version of [TinyCore Linux x86_64 (Core Pure 64)](http://tinycorelinux.net/)

This document explains the changes we've made to the OS, along with links
to the original and modified source code.

## Version

![Architecture](https://img.shields.io/badge/arch-x86__64-brightgreen.svg) ![Version](https://img.shields.io/badge/version-6.4.1-blue.svg)

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
