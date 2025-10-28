#!/bin/bash

# ScanSnap Discovery Protocol Tester
# The ScanSnap app uses UDP broadcasts on port 8194 to discover scanners

SCANNER_IP="10.100.10.61"
BROADCAST_PORT="8194"

echo "========================================="
echo "ScanSnap Discovery Protocol Test"
echo "========================================="
echo ""

# Check if socat is available (better for UDP testing)
if ! command -v socat &> /dev/null; then
    echo "Installing socat for UDP testing..."
    sudo apt-get update && sudo apt-get install -y socat
fi

echo "1. Testing UDP port 8194 (ScanSnap Discovery)..."
echo ""

# Listen for any responses on UDP 8194
echo "Setting up listener on UDP 8194..."
echo "This will capture any scanner discovery broadcasts"
echo "Press Ctrl+C after 10 seconds..."
echo ""

timeout 10 sudo tcpdump -i any -A -n udp port 8194 2>/dev/null &
TCPDUMP_PID=$!

sleep 2

# Try to send a discovery broadcast
echo "Sending UDP broadcast on port 8194..."
# Note: The actual discovery protocol payload may be proprietary
# This sends a simple probe
echo "DISCOVER" | socat - UDP-DATAGRAM:255.255.255.255:8194,broadcast

sleep 8

echo ""
echo "2. Testing direct UDP communication to scanner..."
echo "   Sending probe to $SCANNER_IP:8194..."
echo "PING" | timeout 3 socat - UDP:$SCANNER_IP:8194

echo ""
echo "3. Checking if scanner responds to SSDP/UPnP discovery..."
# Some network scanners respond to SSDP
(
echo "M-SEARCH * HTTP/1.1"
echo "Host: 239.255.255.250:1900"
echo "Man: \"ssdp:discover\""
echo "ST: ssdp:all"
echo "MX: 3"
echo ""
) | timeout 5 socat - UDP-DATAGRAM:239.255.255.250:1900,broadcast

echo ""
echo "4. Testing Bonjour/mDNS query for scanner..."
if command -v avahi-browse &> /dev/null; then
    timeout 5 avahi-browse -a -t -r | grep -i "scan\|fujitsu" || echo "No scanner found via mDNS"
elif command -v dns-sd &> /dev/null; then
    timeout 5 dns-sd -B _scanner._tcp || echo "No scanner services found"
fi

echo ""
echo "========================================="
echo "Discovery Test Complete"
echo "========================================="
echo ""
echo "TROUBLESHOOTING:"
echo "- If no packets captured: Scanner may not be broadcasting"
echo "- Check if scanner is in 'network mode' not 'USB direct mode'"
echo "- Verify scanner and computer are on same subnet/VLAN"
echo "- Check for firewall blocking UDP 8194"
echo "- Scanner may need to be reset or have network settings reconfigured"
echo ""
