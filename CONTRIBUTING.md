# Contributing to TinyCore Linux x86_64 Remaster

Thank you for your interest in contributing to this TinyCore Linux x86_64 remaster project! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/tinycorelinux-x86_64.git
   cd tinycorelinux-x86_64
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Areas for Contribution

- **Boot Optimization**: Improvements to boot time and system startup
- **Unikernel Optimization**: Enhancements for microVM and container deployments
- **Documentation**: Updates to guides, examples, and reference materials
- **Configuration Examples**: New boot configurations and VM scripts
- **Testing**: Validation of optimizations across different environments
- **Security**: Security hardening and vulnerability fixes

### Types of Contributions

- **Bug Reports**: Report issues with existing functionality
- **Feature Requests**: Suggest new optimizations or capabilities
- **Documentation**: Improve or add documentation
- **Code**: Submit patches, optimizations, or new features
- **Testing**: Help test changes across different environments

## Development Guidelines

### Documentation Standards

- Use clear, concise language
- Include practical examples where applicable
- Update relevant documentation when making changes
- Follow the existing documentation structure and style

### Configuration Changes

- Test configurations in isolated environments
- Document performance impacts and trade-offs
- Provide rollback instructions for aggressive optimizations
- Include compatibility notes for different TinyCore versions

### Boot Optimization Guidelines

- Measure and document boot time improvements
- Consider impact on system functionality
- Provide different optimization levels (conservative, aggressive, extreme)
- Test across different hardware configurations

### Unikernel Optimization Guidelines

- Focus on minimal footprint and fast startup
- Consider ephemeral deployment scenarios
- Document size reduction achievements
- Maintain compatibility with container runtimes

## Submitting Changes

### Pull Request Process

1. **Update documentation** as needed
2. **Test your changes** thoroughly
3. **Write clear commit messages** following conventional commit format:
   ```
   type(scope): description
   
   Longer description if needed
   
   Fixes #issue-number
   ```
4. **Submit a pull request** with:
   - Clear description of changes
   - Performance impact measurements (if applicable)
   - Testing methodology and results
   - Screenshots or logs (if relevant)

### Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters or less
- Reference issues and pull requests liberally

### Types of Commits

- `feat`: New features or optimizations
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

- **Environment details**: TinyCore version, hardware specs, VM configuration
- **Steps to reproduce**: Clear, step-by-step instructions
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Logs and output**: Relevant error messages or system logs
- **Configuration files**: Boot parameters, VM scripts, etc.

### Feature Requests

When requesting features, please include:

- **Use case**: Why is this feature needed?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Other approaches you've thought about
- **Impact assessment**: Performance, compatibility, or security implications

## Development Environment

### Prerequisites

- Linux development environment (preferably Ubuntu/Debian)
- QEMU/KVM for testing VM configurations
- Basic understanding of Linux boot process
- Familiarity with TinyCore Linux architecture

### Testing

- Test boot optimizations in clean VM environments
- Measure boot times with consistent methodology
- Validate functionality after applying optimizations
- Test across different hardware configurations when possible

## Community

- **Discussions**: Use GitHub Discussions for questions and ideas
- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Pull Requests**: Use GitHub Pull Requests for code contributions

## Recognition

Contributors will be recognized in:
- Project documentation
- Release notes
- Contributors section (if applicable)

## Questions?

If you have questions about contributing, please:
1. Check existing documentation
2. Search existing issues and discussions
3. Create a new discussion or issue
4. Contact the maintainers

Thank you for contributing to TinyCore Linux x86_64 optimization!