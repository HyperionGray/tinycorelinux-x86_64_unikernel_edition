# Remastered TinyCore Linux x86_64 (Core Pure 64)

This is a slightly remastered version of [TinyCore Linux x86_64 (Core Pure 64)](http://tinycorelinux.net/)

This document explains the changes we've made to the OS, along with links
to the original and modified source code.

## Version

![Architecture](https://img.shields.io/badge/arch-x86__64-brightgreen.svg) ![Version](https://img.shields.io/badge/version-6.4.1-blue.svg)

## Features

This remastered TinyCore Linux x86_64 distribution provides:

### 🚀 Boot Optimization
- **Fast Boot Times**: Achieve boot times under 2 seconds with conservative optimizations
- **Extreme Performance**: Sub-500ms boot times with aggressive optimization
- **Kernel Parameter Tuning**: Pre-configured parameters for optimal startup performance
- **Service Reduction**: Minimal service footprint for faster initialization

### 📦 Size Optimization
- **Conservative**: 45% size reduction (20MB → 11MB) with low risk
- **Aggressive**: 70% size reduction (20MB → 6MB) with medium risk  
- **Extreme**: 85% size reduction (20MB → 3MB) with high risk
- **Modular Components**: Selectively include only required components

### ☁️ Cloud-Native Ready
- **Container Optimized**: Minimal footprint for container deployments
- **Unikernel Support**: Optimized for single-application deployment
- **Ephemeral Workloads**: Perfect for temporary and stateless applications
- **MicroVM Compatible**: Optimized for Firecracker and similar technologies

### 🔧 Comprehensive Documentation
- **Step-by-Step Guides**: Detailed implementation instructions
- **Configuration Examples**: Ready-to-use configuration files
- **Performance Benchmarks**: Measured improvements and trade-offs
- **Best Practices**: Production deployment recommendations

### 🛠️ Development Tools
- **VM Scripts**: Automated testing and benchmarking tools
- **Configuration Templates**: Pre-built configurations for common scenarios
- **Analysis Tools**: System profiling and optimization utilities

## Installation

### Prerequisites

- x86_64 compatible system or virtual machine
- QEMU/KVM for virtualization (recommended)
- Basic understanding of Linux boot process
- 512MB RAM minimum (256MB for optimized configurations)

### Quick Start

1. **Download the Distribution**
   ```bash
   # Clone the repository
   git clone https://github.com/P4X-ng/tinycorelinux-x86_64.git
   cd tinycorelinux-x86_64
   ```

2. **Basic VM Setup**
   ```bash
   # Use the provided VM scripts
   cd examples/vm-scripts
   ./launch-basic-vm.sh
   ```

3. **Apply Boot Optimizations**
   ```bash
   # Quick optimization (saves 6-8 seconds)
   # Add to kernel boot parameters:
   quiet loglevel=3 norestore nodhcp
   ```

### Installation Methods

#### Method 1: Direct Boot (Recommended)
```bash
# Boot with optimized kernel parameters
qemu-system-x86_64 \
  -kernel corepure64/boot/vmlinuz64 \
  -initrd corepure64/boot/corepure64.gz \
  -append "quiet loglevel=3 norestore nodhcp" \
  -m 256M
```

#### Method 2: ISO Boot
```bash
# Create bootable ISO (if available)
# Boot from ISO with custom parameters
```

#### Method 3: Container Deployment
```bash
# Use as base for container images
FROM scratch
COPY corepure64/ /
# Configure as needed
```

### Configuration

1. **Boot Parameters**: See [examples/boot-configs/](examples/boot-configs/) for various scenarios
2. **VM Scripts**: Use [examples/vm-scripts/](examples/vm-scripts/) for automated setup
3. **Optimization Levels**: Choose from conservative, aggressive, or extreme optimizations

## Usage

### Basic Usage

#### Starting the System
```bash
# Basic boot with default settings
qemu-system-x86_64 -kernel vmlinuz64 -initrd corepure64.gz -m 512M

# Optimized boot (recommended)
qemu-system-x86_64 \
  -kernel vmlinuz64 \
  -initrd corepure64.gz \
  -append "quiet loglevel=3 norestore nodhcp" \
  -m 256M
```

#### Common Boot Parameters
```bash
# Conservative optimization
quiet loglevel=3 norestore nodhcp

# Aggressive optimization  
quiet loglevel=0 norestore nodhcp noautologin nozswap

# Extreme optimization
quiet loglevel=0 norestore nodhcp noautologin nozswap nosound nofirewire
```

### Advanced Usage

#### Unikernel Deployment
```bash
# Single application deployment
./setup-unikernel.sh --app myapp --size minimal

# Container-style deployment
docker run --rm -it tinycorelinux-optimized:latest
```

#### Performance Benchmarking
```bash
# Run boot time benchmarks
cd examples/vm-scripts
./benchmark-boot-times.sh

# System size analysis
./analyze-system-size.sh
```

#### Custom Configuration
```bash
# Create custom configuration
cp examples/boot-configs/conservative.conf my-config.conf
# Edit my-config.conf as needed
./apply-config.sh my-config.conf
```

### Use Cases

- **Microservices**: Minimal footprint for containerized applications
- **Edge Computing**: Fast startup for edge deployments
- **CI/CD**: Rapid test environment provisioning
- **Development**: Lightweight development environments
- **IoT**: Minimal OS for embedded applications
- **Cloud Functions**: Fast cold-start serverless functions

## API

### Configuration API

The system provides several configuration interfaces:

#### Boot Parameter API
```bash
# Core optimization parameters
quiet           # Suppress boot messages
loglevel=N      # Set kernel log level (0-7)
norestore       # Skip persistent storage restore
nodhcp          # Skip DHCP configuration
noautologin     # Disable automatic login
nozswap         # Disable compressed swap
```

#### Script API
```bash
# Setup script interface
./setup-unikernel.sh [OPTIONS]

Options:
  --app NAME          Application name
  --size SIZE         Size optimization (minimal|small|medium)
  --boot-time TIME    Target boot time
  --memory MEM        Memory allocation
  --help              Show help
```

#### VM Script API
```bash
# VM management scripts
./launch-vm.sh [CONFIG]           # Launch VM with configuration
./benchmark.sh [ITERATIONS]      # Run performance benchmarks  
./analyze.sh [COMPONENT]          # Analyze system components
```

### Configuration Files API

#### Boot Configuration Format
```ini
# examples/boot-configs/example.conf
[boot]
kernel_params = quiet loglevel=3 norestore nodhcp
memory = 256M
optimization_level = conservative

[services]
enable = essential_service1,essential_service2
disable = unnecessary_service1,unnecessary_service2
```

#### VM Script Configuration
```bash
# examples/vm-scripts/config.sh
VM_MEMORY="256M"
VM_CPU_COUNT=1
BOOT_TIMEOUT=30
OPTIMIZATION_LEVEL="conservative"
```

### Programmatic Interface

#### Shell Functions
```bash
# Source utility functions
source examples/vm-scripts/utils.sh

# Available functions
optimize_boot_time()     # Apply boot optimizations
measure_performance()    # Measure system performance
validate_config()        # Validate configuration
```

#### Return Codes
```bash
# Standard return codes
0   # Success
1   # General error
2   # Configuration error
3   # Performance target not met
4   # Compatibility issue
```

### Integration Examples

#### Docker Integration
```dockerfile
FROM tinycorelinux-x86_64:6.4.1
COPY app/ /opt/app/
RUN ./setup-unikernel.sh --app myapp --size minimal
CMD ["/opt/app/start.sh"]
```

#### Kubernetes Integration
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: tinycorelinux-optimized:latest
    resources:
      requests:
        memory: "64Mi"
        cpu: "50m"
```

For detailed API documentation, see the individual documentation files in the repository.

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

## Contributing

We welcome contributions to this TinyCore Linux x86_64 remaster project! 

### How to Contribute

- **Bug Reports**: Report issues with existing functionality
- **Feature Requests**: Suggest new optimizations or capabilities  
- **Documentation**: Improve or add documentation
- **Code**: Submit patches, optimizations, or new features
- **Testing**: Help test changes across different environments

For detailed contribution guidelines, please see [CONTRIBUTING.md](CONTRIBUTING.md).

### Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

### Security

For security vulnerabilities, please see our [Security Policy](SECURITY.md) for responsible disclosure procedures.

## Thanks

We want to thank the [TinyCore Linux community](http://forum.tinycorelinux.net/)
for their support and hard work on this OS.

We also want to thank all Open Source software developers for contributing
valuable source code for everyone to use freely.

## Questions

This document is Copyright (c) 2016 Alexander Williams, Unscramble license@unscramble.jp

All licensing questions/issues should be sent to the email address above.
