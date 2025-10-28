# ScanSnap iX1600 Network Troubleshooting Toolkit

A comprehensive collection of diagnostic scripts and guides for troubleshooting Fujitsu ScanSnap iX1600 network connectivity issues.

## 🔍 Problem This Solves

When your ScanSnap iX1600 is:
- Pingable on the network but not detected by ScanSnap Home/Manager application
- Showing incorrect hostname (e.g., pulling names from other network devices)
- Not appearing in device discovery despite being connected to Wi-Fi
- Experiencing intermittent connectivity issues

## 📋 What's Included

### Scripts

| Script | Purpose | Requires Sudo |
|--------|---------|---------------|
| `scansnap_diagnostics.sh` | Main diagnostic script - tests connectivity, ports, DNS, mDNS | No |
| `fix_probe_name_issue.sh` | Diagnoses and fixes incorrect hostname issues | Yes |
| `scansnap_discovery_test.sh` | Tests ScanSnap discovery protocol (UDP 8194) | Yes |
| `scansnap_wireshark.sh` | Captures network traffic for deep analysis | Yes |

### Documentation

- **[Troubleshooting Guide](docs/TROUBLESHOOTING_GUIDE.md)** - Comprehensive guide covering common issues, solutions, and advanced diagnostics

## 🚀 Quick Start

### Prerequisites

**macOS:**
```bash
brew install nmap wireshark
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install nmap tcpdump wireshark avahi-utils netcat-openbsd
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install nmap tcpdump wireshark avahi-tools nc
```

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/scansnap-troubleshooting.git
cd scansnap-troubleshooting

# Make scripts executable
chmod +x scripts/*.sh
```

### Configuration

**🔒 Your network information stays private!** Scripts use placeholder values and support multiple configuration methods:

```bash
# Method 1: Create a config file (recommended)
cp .env.example .env
nano .env  # Add your scanner's IP and MAC address
source .env

# Method 2: Use command line arguments
./scripts/scansnap_diagnostics.sh 192.168.1.50 aa:bb:cc:dd:ee:ff

# Method 3: Export environment variables
export SCANNER_IP="192.168.1.50"
export SCANNER_MAC="aa:bb:cc:dd:ee:ff"
```

**📖 See [CONFIGURATION.md](CONFIGURATION.md) for detailed setup instructions.**

### Basic Usage

```bash
# 1. Run main diagnostics (update IP address to match your scanner)
./scripts/scansnap_diagnostics.sh

# 2. If scanner shows wrong name/hostname
sudo ./scripts/fix_probe_name_issue.sh

# 3. Test discovery protocol
sudo ./scripts/scansnap_discovery_test.sh

# 4. Capture network traffic for analysis
sudo ./scripts/scansnap_wireshark.sh
```

## 🔧 Common Issues & Quick Fixes

### Issue 1: Scanner Not Detected by App

**Likely Causes:**
- UDP port 8194 blocked by firewall
- mDNS/Bonjour service not running
- Scanner and computer on different VLANs/subnets

**Quick Test:**
```bash
# Check if discovery port is reachable
sudo ./scripts/scansnap_discovery_test.sh
```

### Issue 2: Scanner Shows Wrong Hostname

**Likely Causes:**
- DNS PTR record pointing to wrong device
- mDNS broadcasting incorrect name
- UniFi or other network controller overriding hostname

**Quick Fix:**
```bash
# Add correct hostname to hosts file
echo "10.100.10.61 ScanSnap-iX1600.local" | sudo tee -a /etc/hosts

# Flush DNS cache (Linux)
sudo systemd-resolve --flush-caches

# Flush DNS cache (macOS)
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```

### Issue 3: UniFi Network Specific Issues

**Check UniFi Controller Settings:**
1. Settings → Networks → [Your Network]
2. Enable "Multicast DNS" (mDNS)
3. Temporarily disable "IGMP Snooping" for testing
4. Check for manual DNS entries that might conflict

## 📊 Understanding the Output

### Port Status
- **Port 443 (HTTPS)** - Scanner web interface (should be OPEN)
- **Port 8194 (UDP)** - Discovery protocol (CRITICAL - must be accessible)
- **Port 5353 (UDP)** - mDNS/Bonjour (needed for automatic discovery)

### Expected Behavior
When working correctly:
- Scanner broadcasts UDP packets on port 8194 every 30-60 seconds
- mDNS advertises scanner as `_scanner._tcp.local`
- Scanner web interface accessible at `https://[scanner-ip]`
- ScanSnap app discovers scanner within 5-10 seconds

## 🛠️ Advanced Troubleshooting

### Wireshark Analysis

```bash
# Start capture
sudo ./scripts/scansnap_wireshark.sh

# In another terminal, try to connect with ScanSnap app
# Let it run for 30-60 seconds, then Ctrl+C

# Analyze the capture
wireshark scansnap_capture_*.pcap
```

**Key Wireshark Filters:**
```
ip.addr == 10.100.10.61
udp.port == 8194
udp.port == 5353 and dns
```

### Manual Scanner Configuration

Access scanner web interface:
```bash
# HTTP
curl http://[scanner-ip]

# HTTPS (ignore cert warnings)
curl -k https://[scanner-ip]

# Or open in browser
open https://[scanner-ip]  # macOS
xdg-open https://[scanner-ip]  # Linux
```

## 🌐 Network Requirements

### Ports Required
- **TCP 443, 80** - Web interface
- **UDP 8194** - Scanner discovery (CRITICAL)
- **UDP 5353** - mDNS/Bonjour
- **TCP 9000-9010** - Data transfer

### Firewall Rules

**Linux (ufw):**
```bash
sudo ufw allow 8194/udp comment 'ScanSnap Discovery'
sudo ufw allow 5353/udp comment 'mDNS'
```

**macOS:**
```bash
# Check System Settings > Network > Firewall
# Add ScanSnap Home/Manager to allowed apps
```

## 📝 Configuration

### Multiple Configuration Methods

Scripts support three ways to specify your scanner details:

**1. Configuration File (Recommended):**
```bash
cp .env.example .env
nano .env  # Edit with your scanner details
source .env
./scripts/scansnap_diagnostics.sh
```

**2. Command Arguments:**
```bash
./scripts/scansnap_diagnostics.sh YOUR_IP YOUR_MAC
./scripts/fix_probe_name_issue.sh YOUR_IP YOUR_MAC
```

**3. Environment Variables:**
```bash
export SCANNER_IP="192.168.1.50"
export SCANNER_MAC="aa:bb:cc:dd:ee:ff"
./scripts/scansnap_diagnostics.sh
```

### Privacy & Security

- ✅ Scripts use **placeholder values** (192.168.1.100) by default
- ✅ Your `.env` file is **automatically ignored** by git
- ✅ **No personal network information** is shared when you push to GitHub
- 📖 See [CONFIGURATION.md](CONFIGURATION.md) for complete privacy guide

## 🤝 Contributing

Found a bug or have a suggestion? Please open an issue or submit a pull request!

### Contribution Ideas
- Additional diagnostic tests
- Support for other ScanSnap models (iX1400, iX1500, etc.)
- Windows-specific troubleshooting scripts
- Automated repair scripts

## 📚 Additional Resources

- [Fujitsu ScanSnap Support](https://www.fujitsu.com/global/support/products/computing/peripheral/scanners/scansnap/)
- [ScanSnap iX1600 Manual](https://www.fujitsu.com/global/support/products/computing/peripheral/scanners/scansnap/manual/)
- [UniFi Network Documentation](https://help.ui.com/)

## ⚠️ Troubleshooting Support

If you're still experiencing issues after trying all diagnostics:

1. Run the full diagnostic suite:
   ```bash
   ./scripts/scansnap_diagnostics.sh > diagnostics_output.txt 2>&1
   ```

2. Capture network traffic:
   ```bash
   sudo ./scripts/scansnap_wireshark.sh
   # Save the .pcap file
   ```

3. Check scanner firmware version (via web interface)

4. Open an issue in this repository with:
   - Diagnostic output
   - Network configuration details
   - Scanner firmware version
   - Operating system and ScanSnap app version

## 📄 License

MIT License - Feel free to use, modify, and distribute.

## 🙏 Acknowledgments

Created to solve real-world ScanSnap connectivity issues, particularly in UniFi network environments.

---

**Note:** These scripts are provided as-is for diagnostic purposes. Always ensure you have proper authorization before running network scanning tools on your network.
