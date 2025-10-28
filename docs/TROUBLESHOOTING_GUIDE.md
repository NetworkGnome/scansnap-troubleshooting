# ScanSnap IX1600 Connection Troubleshooting Guide

## Your Scanner Details
- **IP Address:** 10.100.10.61
- **MAC Address:** 84:25:3f:6d:b6:10
- **Model:** Fujitsu ScanSnap iX1600
- **Status:** Pingable but not detected by ScanSnap application

## Issue: "Pulling name of my Probes"
This suggests the scanner might be showing up with an incorrect hostname/identifier, possibly pulling from your UniFi network device names instead of its own identity. This is often related to DNS/mDNS configuration issues.

---

## Quick Start Diagnostic Steps

### 1. Run the Basic Diagnostics
```bash
chmod +x scansnap_diagnostics.sh
./scansnap_diagnostics.sh | tee diagnostics_output.txt
```

### 2. Capture Network Traffic
```bash
chmod +x scansnap_wireshark.sh
sudo ./scansnap_wireshark.sh
# Let it run for 30-60 seconds while trying to connect via the app
# Then press Ctrl+C
```

### 3. Test Discovery Protocol
```bash
chmod +x scansnap_discovery_test.sh
sudo ./scansnap_discovery_test.sh
```

---

## Common Issues & Solutions

### Issue 1: Scanner Not Broadcasting Discovery Packets
**Symptoms:** App doesn't see scanner, but ping works

**Diagnosis:**
```bash
# Check if UDP 8194 is blocked
sudo iptables -L -n | grep 8194
sudo ufw status | grep 8194

# Listen for scanner broadcasts
sudo tcpdump -i any -n udp port 8194
```

**Solutions:**
- Ensure firewall allows UDP port 8194 (inbound and outbound)
- Check if scanner is in correct network mode (not USB-only mode)
- Verify scanner firmware is up to date

### Issue 2: mDNS/Bonjour Resolution Failure
**Symptoms:** Scanner shows with wrong name or "Probes" name

**Diagnosis:**
```bash
# Check mDNS services
avahi-browse -a -t | grep -i scan
avahi-resolve -a 10.100.10.61

# Check DNS PTR record
dig -x 10.100.10.61
nslookup 10.100.10.61
```

**Solutions:**
```bash
# Install/restart Avahi daemon (Linux)
sudo apt-get install avahi-daemon avahi-utils
sudo systemctl restart avahi-daemon

# For macOS, restart mDNSResponder
sudo killall -HUP mDNSResponder

# Force scanner hostname resolution
echo "10.100.10.61 ScanSnap-iX1600.local" | sudo tee -a /etc/hosts
```

### Issue 3: VLAN/Subnet Isolation
**Symptoms:** Ping works but discovery fails

**Your Network:** UniFi network (KNX-AP01 on Default network)

**Check:**
```bash
# Verify you're on same subnet
ip addr show | grep inet
# Should show 10.100.10.x address

# Check multicast routing
ip mroute show

# Test if broadcasts reach the subnet
ping -b -c 3 10.100.10.255
```

**UniFi-Specific Checks:**
- Ensure mDNS/multicast DNS is enabled in UniFi controller
- Check if "IGMP Snooping" is blocking multicast (disable for testing)
- Verify "Allow Multicast and Broadcast" is enabled on the network
- Check for client isolation settings that might block device discovery

### Issue 4: Firewall Blocking Scanner Ports
**Required Ports:**
- **UDP 8194** - Scanner discovery protocol (CRITICAL)
- **TCP 443** - HTTPS management interface
- **TCP 80** - HTTP management interface  
- **UDP 5353** - mDNS/Bonjour
- **TCP 9000-9010** - Data transfer ports

**Test:**
```bash
# Quick port test
nc -zv 10.100.10.61 443
nc -zv 10.100.10.61 80

# UDP test (harder, needs special approach)
echo "test" | nc -u -w1 10.100.10.61 8194
```

---

## Advanced Wireshark Analysis

### What to Look For:

1. **Start Wireshark capture:**
```bash
sudo wireshark -i <your-interface> -k -f "host 10.100.10.61 or udp port 8194 or udp port 5353"
```

2. **Key Traffic Patterns:**
   - **UDP 8194**: Should see periodic broadcasts from scanner
   - **mDNS (UDP 5353)**: Should see `_scanner._tcp.local` or similar
   - **HTTP/HTTPS**: Should see responses if you access web interface
   - **ARP**: Should see ARP replies from 84:25:3f:6d:b6:10

3. **Wireshark Filters:**
```
# All scanner traffic
ip.addr == 10.100.10.61

# Discovery protocol only
udp.port == 8194

# mDNS traffic
udp.port == 5353 and dns

# Scanner HTTP traffic
http and ip.addr == 10.100.10.61

# Look for scanner advertisements
dns.qry.name contains "scan" or mdns
```

### Red Flags in Capture:
- ❌ No UDP 8194 broadcasts from scanner
- ❌ ARP requests with no replies
- ❌ TCP RST packets on connection attempts
- ❌ ICMP "Destination Unreachable" messages
- ❌ No mDNS responses for scanner

---

## Scanner Web Interface Access

Try accessing the scanner's web interface directly:

```bash
# HTTP
curl -v http://10.100.10.61

# HTTPS (ignore cert warnings)
curl -k -v https://10.100.10.61

# Or in browser
open https://10.100.10.61  # macOS
xdg-open https://10.100.10.61  # Linux
```

The web interface often has:
- Network settings reset option
- Hostname configuration
- Firmware update capability
- Diagnostic logs

---

## "Probes" Name Issue - Specific Fix

The scanner showing "Probes" name suggests it's picking up:
1. PTR record from DNS server (likely UniFi)
2. mDNS advertisement with wrong name
3. NetBIOS/LLMNR name resolution issue

**Fix Steps:**

```bash
# 1. Check what name the scanner is broadcasting
sudo tcpdump -i any -A -n port 5353 | grep -i "ix1600\|scan\|probe"

# 2. Check UniFi DNS entries
# Log into UniFi controller and check:
# - Settings > Networks > Default > DNS
# - Check if 10.100.10.61 has a manual DNS entry

# 3. Force correct hostname in local hosts file
echo "10.100.10.61 ScanSnap-iX1600 ScanSnap-iX1600.local" | sudo tee -a /etc/hosts

# 4. Clear DNS cache
sudo systemd-resolve --flush-caches  # Linux
sudo dscacheutil -flushcache  # macOS

# 5. Restart scanner network:
# - Power off scanner
# - Wait 30 seconds
# - Power on
# - Wait for full boot (2-3 minutes)
```

---

## ScanSnap App-Specific Troubleshooting

### macOS:
```bash
# Check ScanSnap service status
ps aux | grep ScanSnap

# Reset ScanSnap Home settings
rm -rf ~/Library/Preferences/jp.co.pfu.ScanSnapHome.plist
rm -rf ~/Library/Application\ Support/PFU/ScanSnap\ Home

# Check app logs
cat ~/Library/Logs/PFU/ScanSnap\ Home/*.log
```

### Windows:
```powershell
# Check service status
Get-Service -Name "*ScanSnap*"

# Check logs
Get-EventLog -LogName Application -Source "ScanSnap*" -Newest 20

# Reset network discovery
netsh advfirewall firewall show rule name=all | findstr ScanSnap
```

### Linux:
```bash
# If using ScanSnap Manager for Linux
ps aux | grep -i scan

# Check SANE backend
scanimage -L

# Reset scanner connection
sudo rm -rf ~/.sane/*
```

---

## Nuclear Options (Try in Order)

### 1. Scanner Network Reset
- Press and hold Wi-Fi button on scanner for 3+ seconds
- Scanner will reset network settings
- Reconfigure via touchscreen

### 2. Force Static IP Configuration
If DHCP is causing issues:
- Scanner touchscreen > Settings > Network
- Set static IP: 10.100.10.61
- Gateway: 10.100.10.1 (your UniFi gateway)
- DNS: 10.100.10.1 or 8.8.8.8

### 3. Disable IPv6 (if enabled)
```bash
# Temporarily disable IPv6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
```

### 4. Factory Reset Scanner
- Access via touchscreen menu
- Will need to reconfigure everything

---

## Data Collection for Support

If still having issues, collect this data:

```bash
# Run all diagnostics and save
./scansnap_diagnostics.sh > full_diagnostics.txt 2>&1

# Capture 60 seconds of traffic while reproducing issue
sudo timeout 60 tcpdump -i any -w scansnap_debug.pcap \
  "host 10.100.10.61 or udp port 8194 or udp port 5353"

# Get UniFi network info
# Export from controller: Settings > System > Backup > Download

# Get scanner system info (from web interface if accessible)
curl -k https://10.100.10.61/system/info > scanner_info.json
```

---

## Expected Normal Behavior

When working correctly, you should see:
1. Scanner broadcasts UDP 8194 discovery packets every 30-60 seconds
2. mDNS advertises scanner as `_scanner._tcp.local`
3. Scanner web interface accessible at https://10.100.10.61
4. ARP table shows correct MAC address association
5. ScanSnap app finds scanner within 5-10 seconds of launch

---

## Quick Reference Commands

```bash
# Test connectivity
ping -c 4 10.100.10.61

# Check open ports
nmap -p 80,443,8194 10.100.10.61

# Monitor for discovery broadcasts
sudo tcpdump -i any -n udp port 8194

# Check mDNS
avahi-browse -a -t | grep -i scan

# Access web interface
curl -k https://10.100.10.61

# View ARP entry
arp -a | grep 10.100.10.61

# Check routing
ip route get 10.100.10.61
```

---

## Still Stuck?

1. **Check scanner firmware** - Visit Fujitsu support website
2. **Verify app version** - Update ScanSnap Home/Manager to latest
3. **Test from different device** - Rules out client-side issues
4. **Contact Fujitsu support** - Provide pcap and diagnostic files
5. **Check UniFi forums** - Others may have had similar issues with their setup

Good luck! Let me know what you find from the diagnostics.
