# Contributing to ScanSnap Troubleshooting Toolkit

Thank you for your interest in contributing! This project helps people troubleshoot their ScanSnap scanner connectivity issues.

## How to Contribute

### Reporting Issues

If you encounter a problem or have a suggestion:

1. **Check existing issues** to avoid duplicates
2. **Provide detailed information**:
   - Scanner model (iX1600, iX1500, etc.)
   - Operating system and version
   - Network setup (UniFi, router model, etc.)
   - Output from diagnostic scripts
   - Steps to reproduce the issue

### Submitting Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test thoroughly** - Run all scripts to ensure they work
5. **Commit with clear messages**: `git commit -m "Add feature: description"`
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Open a Pull Request** with a clear description

### Code Guidelines

#### Shell Scripts
- Use `#!/bin/bash` shebang
- Include descriptive comments
- Use meaningful variable names in CAPS for constants
- Test on both macOS and Linux when possible
- Handle errors gracefully
- Provide helpful output messages

#### Documentation
- Use clear, concise language
- Include code examples where helpful
- Keep formatting consistent with existing docs
- Update README.md if adding new features

### Ideas for Contributions

- **New Scripts**: Diagnostic tools for specific issues
- **Model Support**: Extend support to other ScanSnap models
- **Windows Scripts**: PowerShell equivalents of bash scripts
- **Documentation**: Improve guides, add screenshots, create video tutorials
- **Translations**: Translate documentation to other languages
- **Automated Fixes**: Scripts that automatically repair common issues

### Testing

Before submitting:

```bash
# Test all scripts
cd scansnap-troubleshooting
chmod +x scripts/*.sh

# Run each script to verify syntax
bash -n scripts/*.sh

# Test on your scanner if possible
./scripts/scansnap_diagnostics.sh
```

### Questions?

Open an issue with the `question` label, or reach out to the maintainers.

## Code of Conduct

- Be respectful and professional
- Provide constructive feedback
- Help others learn and grow
- Focus on what's best for the community

Thank you for helping make this project better! 🎉
