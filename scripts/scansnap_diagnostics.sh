#!/bin/bash

# ScanSnap IX1600 Network Diagnostics Script
# Configure these values for your scanner:

# Default example values - CHANGE THESE to match your scanner
SCANNER_IP="${SCANNER_IP:-192.168.1.100}"
SCANNER_MAC="${SCANNER_MAC:-00:00:00:00:00:00}"

# You can also set these as environment variables:
# export SCANNER_IP="your.scanner.ip"
# export SCANNER_MAC="your:mac:address"
# ./scansnap_diagnostics.sh

# Or pass them as arguments:
if [ $# -eq 2 ]; then
    SCANNER_IP="$1"
    SCANNER_MAC="$2"
elif [ $# -eq 1 ]; then
    SCANNER_IP="$1"
fi

echo "========================================="
echo "ScanSnap IX1600 Network Diagnostics"
echo "========================================="
echo ""
echo "Scanner IP:  $SCANNER_IP"
echo "Scanner MAC: $SCANNER_MAC"
echo ""

# Warn if using default values
if [ "$SCANNER_IP" = "192.168.1.100" ]; then
    echo "⚠️  WARNING: Using default IP address!"
    echo "   Please configure your scanner's IP address:"
    echo "   - Edit SCANNER_IP in this script, OR"
    echo "   - Run: ./scansnap_diagnostics.sh YOUR_IP YOUR_MAC, OR"
    echo "   - Run: export SCANNER_IP=YOUR_IP && ./scansnap_diagnostics.sh"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    echo ""
fi

# 1. Basic connectivity test
echo "1. Testing basic connectivity..."
ping -c 4 $SCANNER_IP
echo ""

# 2. Check ARP table entry
echo "2. Checking ARP table for MAC address..."
arp -n | grep -i "${SCANNER_MAC//:/-}" || arp -n | grep "$SCANNER_IP"
echo ""

# 3. Port scanning - ScanSnap typically uses specific ports
echo "3. Scanning common ScanSnap ports..."
echo "   - Port 443 (HTTPS management)"
echo "   - Port 80 (HTTP management)"
echo "   - Port 8194 (ScanSnap discovery)"
echo "   - Port 8080 (Alternative management)"
echo "   - Port 161/162 (SNMP)"
echo "   - Port 9000-9010 (Data transfer)"
echo ""

# Using nc (netcat) for port checks
for port in 80 443 8080 8194 9000 9001 161; do
    echo -n "Port $port: "
    timeout 2 nc -zv $SCANNER_IP $port 2>&1 | grep -q "succeeded\|open" && echo "OPEN" || echo "CLOSED/FILTERED"
done
echo ""

# Alternative using nmap if available
if command -v nmap &> /dev/null; then
    echo "4. Running nmap scan on common ports..."
    sudo nmap -p 80,443,8080,8194,9000-9010,161,162 $SCANNER_IP
    echo ""
fi

# 5. Test HTTP/HTTPS web interface
echo "5. Testing web interface access..."
echo "   Attempting HTTP connection..."
curl -m 5 -I http://$SCANNER_IP 2>&1 | head -5
echo ""
echo "   Attempting HTTPS connection (ignoring cert errors)..."
curl -k -m 5 -I https://$SCANNER_IP 2>&1 | head -5
echo ""

# 6. Check mDNS/Bonjour discovery
echo "6. Checking for mDNS/Bonjour broadcasts..."
if command -v avahi-browse &> /dev/null; then
    timeout 5 avahi-browse -a -t | grep -i "scan\|fujitsu"
elif command -v dns-sd &> /dev/null; then
    echo "Using dns-sd for service discovery..."
    timeout 5 dns-sd -B _scanner._tcp
fi
echo ""

# 7. UDP port 8194 test (ScanSnap Discovery Protocol)
echo "7. Testing ScanSnap Discovery Protocol (UDP 8194)..."
echo "   Sending discovery packet..."
# The scanner discovery typically uses UDP broadcasts
echo "   Note: This may require packet capture to verify"
echo ""

# 8. Check routing table
echo "8. Checking route to scanner..."
ip route get $SCANNER_IP
echo ""

# 9. Check firewall rules (if applicable)
echo "9. Checking local firewall status..."
if command -v ufw &> /dev/null; then
    sudo ufw status | grep -E "8194|Status"
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --list-all | grep -E "services|ports"
fi
echo ""

# 10. DNS/hostname resolution
echo "10. Attempting to resolve scanner hostname..."
nslookup $SCANNER_IP 2>/dev/null || echo "No PTR record found"
echo ""

echo "========================================="
echo "Diagnostics Complete"
echo "========================================="
echo ""
echo "NEXT STEPS:"
echo "1. Review port availability above"
echo "2. Check if ports 8194/UDP and 443/TCP are open"
echo "3. Run the Wireshark capture script for detailed analysis"
echo "4. Verify scanner firmware is up to date"
echo ""
