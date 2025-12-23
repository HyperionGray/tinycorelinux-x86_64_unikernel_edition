# Security Policy

## Supported Versions

We provide security updates for the following versions of TinyCore Linux x86_64:

| Version | Supported          |
| ------- | ------------------ |
| 6.4.1   | :white_check_mark: |
| < 6.4.1 | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in this TinyCore Linux remaster, please report it responsibly.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please send an email to: **license@unscramble.jp**

Include the following information in your report:

- **Description**: A clear description of the vulnerability
- **Impact**: Potential impact and attack scenarios
- **Reproduction**: Step-by-step instructions to reproduce the issue
- **Environment**: TinyCore version, configuration, and environment details
- **Proof of Concept**: If applicable, include a minimal proof of concept
- **Suggested Fix**: If you have ideas for fixing the issue

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
- **Initial Assessment**: We will provide an initial assessment within 5 business days
- **Updates**: We will keep you informed of our progress
- **Resolution**: We aim to resolve critical vulnerabilities within 30 days
- **Disclosure**: We will coordinate with you on responsible disclosure timing

### Security Considerations

This TinyCore Linux remaster includes several security-relevant modifications:

#### Boot Process Security

- **Kernel Parameters**: Some optimizations may affect security features
- **Service Reduction**: Disabled services may include security-relevant components
- **Network Configuration**: Network optimizations may impact security posture

#### Unikernel Deployment Security

- **Minimal Attack Surface**: Reduced components limit potential vulnerabilities
- **Container Security**: Consider container runtime security implications
- **Ephemeral Deployment**: Temporary nature may affect logging and monitoring

#### Configuration Security

- **Default Passwords**: Ensure default credentials are changed in production
- **Network Services**: Review enabled services for security implications
- **File Permissions**: Verify file permissions after applying optimizations

### Security Best Practices

When using this TinyCore Linux remaster:

1. **Regular Updates**: Keep the base TinyCore Linux updated
2. **Security Scanning**: Regularly scan for vulnerabilities
3. **Access Control**: Implement proper access controls
4. **Network Security**: Use appropriate network security measures
5. **Monitoring**: Implement security monitoring where applicable
6. **Backup**: Maintain secure backups of critical data

### Known Security Considerations

#### Boot Optimizations

- **Quiet Boot**: May hide security-relevant boot messages
- **Service Reduction**: Disabled services may include security features
- **Fast Boot**: May skip some security checks

#### Unikernel Optimizations

- **Minimal Footprint**: Reduced logging and monitoring capabilities
- **Ephemeral Nature**: Limited forensic capabilities
- **Container Runtime**: Security depends on container runtime configuration

### Security Testing

We encourage security testing of this distribution:

- **Vulnerability Scanning**: Use tools like OpenVAS, Nessus, or similar
- **Penetration Testing**: Conduct appropriate penetration testing
- **Configuration Review**: Review security configurations
- **Compliance Checking**: Verify compliance with relevant standards

### Responsible Disclosure

We follow responsible disclosure practices:

1. **Private Reporting**: Initial reports should be private
2. **Coordinated Disclosure**: We coordinate disclosure timing
3. **Credit**: We provide appropriate credit to reporters
4. **Public Disclosure**: We publish security advisories when appropriate

### Security Resources

- **TinyCore Security**: [TinyCore Linux Security Information](http://tinycorelinux.net/security.html)
- **CVE Database**: [Common Vulnerabilities and Exposures](https://cve.mitre.org/)
- **Security Advisories**: Check our releases for security-related updates

### Contact Information

For security-related questions or concerns:

- **Email**: license@unscramble.jp
- **Subject Line**: Please use "SECURITY:" prefix in subject line
- **Encryption**: PGP encryption is welcome (key available on request)

### Legal

This security policy is provided in good faith. We make no warranties about the security of this software and users are responsible for their own security assessments and implementations.

---

**Note**: This TinyCore Linux remaster is based on the upstream TinyCore Linux distribution. For security issues in the base TinyCore Linux, please also report to the upstream TinyCore Linux project.