#!/bin/bash

# Script to diagnose and fix the "Probes" name issue with ScanSnap
# When the scanner appears with wrong hostname

# Default example values - CHANGE THESE to match your scanner
SCANNER_IP="${SCANNER_IP:-192.168.1.100}"
SCANNER_MAC="${SCANNER_MAC:-00:00:00:00:00:00}"

# Allow configuration via arguments or environment variables
if [ $# -eq 2 ]; then
    SCANNER_IP="$1"
    SCANNER_MAC="$2"
elif [ $# -eq 1 ]; then
    SCANNER_IP="$1"
fi

echo "========================================="
echo "ScanSnap 'Probes' Name Issue Diagnostics"
echo "========================================="
echo ""
echo "Scanner IP:  $SCANNER_IP"
echo "Scanner MAC: $SCANNER_MAC"
echo ""

if [ "$SCANNER_IP" = "192.168.1.100" ]; then
    echo "⚠️  WARNING: Using default IP address!"
    echo "   Configure: ./fix_probe_name_issue.sh YOUR_IP YOUR_MAC"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    echo ""
fi

echo "ISSUE: Scanner showing incorrect name (e.g., pulling from network device list)"
echo "This usually means DNS/mDNS name resolution is misconfigured"
echo ""

# 1. Check DNS reverse lookup
echo "1. Checking DNS PTR record for scanner IP..."
nslookup $SCANNER_IP 2>&1 | grep -A5 "name =" || echo "   No PTR record found"
dig -x $SCANNER_IP +short || echo "   No reverse DNS entry"
echo ""

# 2. Check mDNS broadcasts
echo "2. Checking mDNS/Bonjour name advertisements..."
echo "   Listening for 10 seconds..."
if command -v avahi-browse &> /dev/null; then
    timeout 10 avahi-browse -a -t -r 2>/dev/null | grep -A10 -B5 "$SCANNER_IP\|$SCANNER_MAC" || echo "   No mDNS advertisements found"
fi
echo ""

# 3. Check ARP and NetBIOS
echo "3. Checking ARP table and hostname..."
arp -a | grep "$SCANNER_IP\|${SCANNER_MAC//:/-}"
echo ""

# 4. Check if NetBIOS name resolution is interfering
if command -v nmblookup &> /dev/null; then
    echo "4. Checking NetBIOS name resolution..."
    nmblookup -A $SCANNER_IP
    echo ""
fi

# 5. Capture actual name being broadcast
echo "5. Capturing mDNS packets to see advertised hostname..."
echo "   (Running for 15 seconds - scanner should broadcast every 10-30s)"
sudo timeout 15 tcpdump -i any -A -n udp port 5353 2>/dev/null | \
    grep -A5 -B5 -i "$SCANNER_IP\|scan\|ix1600\|fujitsu\|probe" || \
    echo "   No relevant mDNS traffic captured"
echo ""

# 6. Check local hosts file
echo "6. Checking /etc/hosts for scanner entry..."
grep "$SCANNER_IP" /etc/hosts || echo "   No entry found in /etc/hosts"
echo ""

# 7. Try to get hostname from scanner itself
echo "7. Attempting to query scanner web interface for hostname..."
HOSTNAME=$(curl -k -s -m 5 https://$SCANNER_IP/system/info 2>/dev/null | grep -o '"hostname"[^,]*' || echo "   Unable to fetch")
echo "   $HOSTNAME"
echo ""

echo "========================================="
echo "SUGGESTED FIXES"
echo "========================================="
echo ""

echo "FIX 1: Add correct hostname to /etc/hosts"
echo "----------------------------------------"
echo "sudo tee -a /etc/hosts <<EOF"
echo "$SCANNER_IP ScanSnap-iX1600 ScanSnap-iX1600.local ix1600"
echo "EOF"
echo ""

echo "FIX 2: Check UniFi Controller Settings"
echo "----------------------------------------"
echo "1. Log into UniFi controller (https://$(ip route | grep default | awk '{print $3}'):8443)"
echo "2. Go to Settings > Networks > Default"
echo "3. Check DNS settings"
echo "4. Look for manual DNS entry for 192.168.1.100"
echo "5. Either remove it or change it to 'ScanSnap-iX1600'"
echo ""

echo "FIX 3: Flush DNS caches"
echo "----------------------------------------"
if command -v systemd-resolve &> /dev/null; then
    echo "sudo systemd-resolve --flush-caches"
    echo "sudo systemctl restart systemd-resolved"
elif command -v dscacheutil &> /dev/null; then
    echo "sudo dscacheutil -flushcache"
    echo "sudo killall -HUP mDNSResponder"
else
    echo "# Clear DNS cache (method varies by OS)"
fi
echo ""

echo "FIX 4: Reset scanner network settings"
echo "----------------------------------------"
echo "1. On scanner touchscreen: Setup > Network Settings"
echo "2. Press and hold Wi-Fi button for 3+ seconds to reset"
echo "3. Reconfigure network with correct hostname"
echo "   Suggested hostname: ScanSnap-iX1600"
echo ""

echo "FIX 5: Restart mDNS/Avahi service"
echo "----------------------------------------"
if command -v systemctl &> /dev/null; then
    echo "sudo systemctl restart avahi-daemon"
    echo ""
    echo "Current status:"
    systemctl status avahi-daemon --no-pager | head -5
fi
echo ""

echo "========================================="
echo "QUICK TEST AFTER APPLYING FIXES"
echo "========================================="
echo ""
echo "# Test 1: Verify hostname resolves"
echo "ping -c 2 ScanSnap-iX1600.local"
echo ""
echo "# Test 2: Check mDNS again"
echo "avahi-browse -a -t | grep -i scan"
echo ""
echo "# Test 3: Verify ARP entry"
echo "arp -a | grep $SCANNER_IP"
echo ""
echo "# Test 4: Restart ScanSnap app and check if scanner is discovered"
echo ""
