# Contributing to TinyCore Linux x86_64 Remaster

Thank you for your interest in contributing to this project! This document provides guidelines for contributing to the remastered TinyCore Linux x86_64 distribution.

## Overview

This repository maintains a remastered version of TinyCore Linux x86_64 (Core Pure 64) with optimizations for unikernel-style deployment and boot time improvements.

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker to report bugs or suggest enhancements
- Provide detailed information about your environment and steps to reproduce issues
- Include relevant logs, configuration files, or error messages

### Submitting Changes

1. **Fork the repository** and create a new branch for your changes
2. **Make your changes** following the project conventions
3. **Test your changes** thoroughly in a TinyCore Linux environment
4. **Document your changes** in comments and update relevant documentation
5. **Submit a pull request** with a clear description of your changes

### Code Style

- Follow the existing shell script style for consistency
- Use clear, descriptive variable names
- Add comments for complex logic
- Keep modifications minimal and focused

### Documentation Updates

When contributing documentation:
- Update relevant markdown files (README.md, optimization guides, etc.)
- Keep documentation clear, concise, and technically accurate
- Include examples where appropriate
- Test any commands or procedures before documenting them

### Testing

- Test changes in a TinyCore Linux 6.4.1 x86_64 environment
- Verify boot optimizations don't break core functionality
- Test in both VM and bare metal environments when possible
- Document any testing performed in your pull request

## Types of Contributions

We welcome various types of contributions:

- **Boot optimization improvements** - Better configurations for faster boot times
- **Documentation enhancements** - Clearer guides, examples, and references
- **Bug fixes** - Corrections to scripts, configurations, or documentation
- **Performance optimizations** - Improvements to system efficiency
- **Security improvements** - Security hardening and vulnerability fixes

## Development Environment

To work with this project:

1. Download TinyCore Linux 6.4.1 x86_64 from https://tinycorelinux.net/
2. Set up a development VM (QEMU recommended)
3. Review the documentation in this repository:
   - BOOT_OPTIMIZATION.md
   - UNIKERNEL_OPTIMIZATION.md
   - IMPLEMENTATION_GUIDE.md

## Licensing

By contributing to this project, you agree that your contributions will be licensed under the same GPL v2 license that covers TinyCore Linux. See the LICENSE file for details.

## Questions?

If you have questions about contributing:
- Open an issue with the "question" label
- Reference existing documentation and examples
- Be specific about what you're trying to accomplish

## Recognition

Contributors will be acknowledged in the project documentation and commit history. We appreciate all contributions, whether large or small!

## Code of Conduct

Please be respectful and professional in all interactions. We're building open source software together and maintaining a positive community is important.
