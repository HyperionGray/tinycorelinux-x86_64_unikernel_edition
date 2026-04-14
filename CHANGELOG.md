# Changelog

All notable changes to this TinyCore Linux x86_64 remaster project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to TinyCore Linux versioning.

## [6.4.1] - 2025

### Added
- Comprehensive boot optimization documentation (BOOT_OPTIMIZATION.md)
- Quick start boot optimization guide (QUICK_START_BOOT_OPTIMIZATION.md)
- Boot optimization summary (BOOT_OPTIMIZATION_SUMMARY.md)
- Unikernel optimization documentation suite
  - UNIKERNEL_SUMMARY.md
  - UNIKERNEL_OPTIMIZATION.md
  - IMPLEMENTATION_GUIDE.md
  - QUICK_REFERENCE.md
- System analysis documentation (TINYCORE_ANALYSIS.md)
- Boot configuration examples in examples/boot-configs/
- VM launch scripts in examples/vm-scripts/
- Benchmark tools for boot time testing
- Setup script for unikernel deployment (setup-unikernel.sh)

### Changed
- Optimized boot parameters for faster startup (6-8 second improvement)
- Enhanced documentation structure and organization
- Updated README with comprehensive optimization guides

### Performance Improvements
- Boot time reduction strategies documented:
  - Conservative approach: 45% size reduction (20MB → 11MB), <2s boot
  - Aggressive approach: 70% size reduction (20MB → 6MB), <1s boot
  - Extreme approach: 85% size reduction (20MB → 3MB), <500ms boot
- Kernel parameter optimizations: `quiet loglevel=3 norestore nodhcp`

### Documentation
- Added complete optimization implementation guides
- Created quick reference documentation
- Documented TinyCore Linux architecture and design decisions
- Added examples for various deployment scenarios

## [6.4.1] - Original Release

### Base
- Based on TinyCore Linux 6.4.1 x86_64 (Core Pure 64)
- Maintained un-modified sources in master branch
- Modified sources in version branch (6.4.1)

### Structure
- Core Pure 64 distribution files in corepure64/
- Extension management system
- Configuration files for system setup
- Boot scripts and initialization

### License
- GPL v2 licensed (following TinyCore Linux licensing)
- Additional MIT-licensed components (LICENSE-MIT)

## Notes

### Version Strategy
This project follows the TinyCore Linux version numbers for the base distribution. Modifications and enhancements are tracked in this changelog while maintaining compatibility with the upstream TinyCore Linux 6.4.1 release.

### Compatibility
All modifications maintain compatibility with TinyCore Linux 6.4.1 and can be applied to standard TinyCore installations following the documentation guides.

### Future Plans
- Additional boot optimization techniques
- Enhanced monitoring and diagnostics tools
- Improved documentation and examples
- Community-contributed optimization strategies

---

For detailed technical information about specific optimizations, refer to:
- BOOT_OPTIMIZATION.md for boot time improvements
- UNIKERNEL_OPTIMIZATION.md for deployment strategies
- IMPLEMENTATION_GUIDE.md for step-by-step instructions
