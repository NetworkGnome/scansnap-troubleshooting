# Quick Reference Card

## Installation
```bash
git clone https://github.com/YOUR-USERNAME/scansnap-troubleshooting.git
cd scansnap-troubleshooting
./setup.sh
```

## Basic Diagnostics
```bash
# Run full diagnostics
./scripts/scansnap_diagnostics.sh | tee output.txt

# Test specific port
nc -zv 192.168.1.100 443

# Check if scanner is pingable
ping -c 4 192.168.1.100

# Check ARP table
arp -a | grep 192.168.1.100
```

## Network Discovery
```bash
# Test discovery protocol
sudo ./scripts/scansnap_discovery_test.sh

# Check mDNS (Linux)
avahi-browse -a -t | grep -i scan

# Check mDNS (macOS)
dns-sd -B _scanner._tcp
```

## Hostname Issues
```bash
# Diagnose hostname problem
sudo ./scripts/fix_probe_name_issue.sh

# Quick fix - add to hosts file
echo "192.168.1.100 ScanSnap-iX1600.local" | sudo tee -a /etc/hosts

# Flush DNS cache (Linux)
sudo systemd-resolve --flush-caches

# Flush DNS cache (macOS)
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```

## Traffic Capture
```bash
# Capture all scanner traffic
sudo ./scripts/scansnap_wireshark.sh

# Manual capture with tcpdump
sudo tcpdump -i any -w scanner.pcap host 192.168.1.100

# Analyze capture
wireshark scanner.pcap
```

## Web Interface
```bash
# Access scanner web UI
curl -k https://192.168.1.100

# Or open in browser
open https://192.168.1.100  # macOS
xdg-open https://192.168.1.100  # Linux
```

## Port Testing
```bash
# Test individual ports
nc -zv 192.168.1.100 443  # HTTPS
nc -zv 192.168.1.100 80   # HTTP

# Scan all common ports
nmap -p 80,443,8080,8194,9000-9010 192.168.1.100
```

## UniFi Specific
```bash
# Check multicast routing
ip mroute show

# Test broadcast
ping -b -c 3 192.168.1.255

# Check firewall rules
sudo iptables -L -n | grep 8194
```

## Firewall Configuration
```bash
# Linux (ufw)
sudo ufw allow 8194/udp
sudo ufw allow 5353/udp

# Check status
sudo ufw status
```

## Common Ports
- **TCP 443** - HTTPS management
- **TCP 80** - HTTP management  
- **UDP 8194** - Scanner discovery (CRITICAL)
- **UDP 5353** - mDNS/Bonjour
- **TCP 9000-9010** - Data transfer

## Wireshark Filters
```
ip.addr == 192.168.1.100
udp.port == 8194
udp.port == 5353 and dns
http or https
```

## Reset Scanner Network
1. Scanner touchscreen → Setup → Network Settings
2. Hold Wi-Fi button for 3+ seconds
3. Reconfigure network settings

## Get Help
```bash
# View full troubleshooting guide
cat docs/TROUBLESHOOTING_GUIDE.md | less

# View README
cat README.md | less
```

## Update Scanner IP/MAC in Scripts
```bash
# Edit all scripts at once
./setup.sh

# Or manually edit each script:
# SCANNER_IP="your.ip.address"
# SCANNER_MAC="your:mac:address"
```
