# Security Policy

## Supported Versions

This project is based on TinyCore Linux 6.4.1 x86_64. Security updates and support follow the upstream TinyCore Linux project.

| Version | Supported          | Notes |
| ------- | ------------------ | ----- |
| 6.4.1   | :white_check_mark: | Current remastered version |

## Security Context

This is a remastered Linux distribution based on TinyCore Linux, optimized for unikernel-style deployment in ephemeral microVMs. The security model assumes:

- **Ephemeral deployment**: VMs are short-lived and frequently recreated
- **Minimal attack surface**: Reduced system footprint minimizes vulnerabilities
- **Immutable infrastructure**: System files are read-only in production
- **Network isolation**: Designed for controlled network environments

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly:

### For TinyCore Linux Base System Issues

Report to the upstream TinyCore Linux project:
- **Forum**: https://forum.tinycorelinux.net/
- **Mailing List**: Use the TinyCore Linux community channels

### For Remaster-Specific Issues

For vulnerabilities specific to our modifications, optimizations, or custom scripts:

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. **Email** the maintainers at: license@unscramble.jp
3. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

### What to Expect

- **Acknowledgment**: Within 48 hours of your report
- **Assessment**: Initial security assessment within 7 days
- **Updates**: Regular communication about remediation progress
- **Disclosure**: Coordinated disclosure after a fix is available

## Security Best Practices

When using this remastered distribution:

### Boot Configuration
- Review and customize kernel boot parameters for your security requirements
- Use `norestore` for ephemeral deployments to prevent state persistence
- Disable unnecessary services and network interfaces

### File System
- Mount system partitions as read-only when possible
- Use encryption for sensitive data storage
- Implement proper file permissions for custom scripts

### Network Security
- Use `nodhcp` and configure static networking in controlled environments
- Implement firewall rules appropriate for your use case
- Minimize exposed services

### Extension Management
- Only install trusted extensions from the official TinyCore repository
- Verify extension signatures when available
- Keep extensions updated to their latest versions

### VM Security
- Use secure VM configurations (e.g., disable unnecessary devices)
- Implement proper resource limits
- Use secure boot when supported by your hypervisor

## Known Security Considerations

### Optimized Boot Parameters

This project documents aggressive boot optimizations that may affect security:

- **`quiet` and `loglevel=3`**: Reduces logging, which may impact security monitoring
  - **Mitigation**: Enable detailed logging in production environments requiring audit trails

- **`norestore`**: Disables persistent storage restoration
  - **Impact**: Prevents loading saved configurations, including security policies
  - **Mitigation**: Bake security configurations into the base image

- **`nodhcp`**: Disables DHCP client
  - **Impact**: Reduces network stack but requires manual network configuration
  - **Mitigation**: Pre-configure static networking

### Minimal System

The aggressive optimization strategies reduce system size but may:
- Remove debugging tools needed for security analysis
- Eliminate certain kernel modules that could be needed for security features
- Reduce system observability

**Recommendation**: Use conservative optimization approaches for security-sensitive deployments.

## Security Updates

### Upstream Updates
Monitor TinyCore Linux security announcements:
- https://tinycorelinux.net/
- https://forum.tinycorelinux.net/

### This Repository
Security-related updates to our modifications will be:
- Committed to the repository with clear security notes
- Documented in CHANGELOG.md
- Announced via GitHub releases when significant

## Security Disclosure Policy

### Public Disclosure Timeline
- **Day 0**: Vulnerability reported privately
- **Day 7**: Assessment complete, fix development begins
- **Day 30**: Fix released (or timeline communicated)
- **Day 90**: Public disclosure (or earlier if fix deployed)

### Exceptions
- Critical vulnerabilities may be disclosed sooner
- Actively exploited vulnerabilities will be expedited
- Disclosure coordinated with upstream TinyCore when applicable

## Vulnerability Assessment

We use automated security scanning where applicable, but as a Linux distribution remaster, traditional application security tools have limited applicability. Security focus areas:

1. **Shell Script Security**: Review custom scripts for injection vulnerabilities
2. **Configuration Security**: Ensure secure defaults in boot and system configurations
3. **Dependency Management**: Track security updates for included extensions
4. **Documentation Security**: Ensure documentation doesn't expose sensitive patterns

## Contact

For security concerns:
- **Email**: license@unscramble.jp
- **PGP**: Available upon request

For general questions, use GitHub issues with appropriate labels.

---

**Note**: This project inherits the security characteristics of TinyCore Linux. Review the upstream security documentation and follow Linux security best practices for production deployments.
