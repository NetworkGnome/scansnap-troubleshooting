# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-28

### Added
- Initial release of ScanSnap Troubleshooting Toolkit
- `scansnap_diagnostics.sh` - Main diagnostic script
- `scansnap_discovery_test.sh` - Discovery protocol testing
- `scansnap_wireshark.sh` - Network traffic capture tool
- `fix_probe_name_issue.sh` - Hostname/DNS issue diagnostics
- Comprehensive troubleshooting guide
- README with quick start instructions
- MIT License
- Contributing guidelines

### Features
- Tests basic connectivity and port availability
- Checks mDNS/Bonjour service discovery
- Diagnoses incorrect hostname issues
- Captures network traffic for analysis
- UniFi-specific troubleshooting steps
- Support for macOS and Linux

### Known Issues
- Windows support not yet implemented (contributions welcome!)
- Some features require sudo/root access
- nmap and wireshark must be installed separately

## [Unreleased]

### Planned Features
- Windows PowerShell script equivalents
- Support for additional ScanSnap models (iX1400, iX1500, etc.)
- Automated fix scripts
- GUI wrapper for easier usage
- Docker container for portable diagnostics
