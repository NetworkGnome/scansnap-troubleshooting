#!/bin/bash

# Wireshark/tcpdump capture script for ScanSnap IX1600 debugging
# This will capture all traffic to/from the scanner

# Default example values - CHANGE THESE to match your scanner
SCANNER_IP="${SCANNER_IP:-192.168.1.100}"
SCANNER_MAC="${SCANNER_MAC:-00:00:00:00:00:00}"
CAPTURE_FILE="scansnap_capture_$(date +%Y%m%d_%H%M%S).pcap"
INTERFACE=""

# Allow configuration via arguments or environment variables
if [ $# -eq 2 ]; then
    SCANNER_IP="$1"
    SCANNER_MAC="$2"
elif [ $# -eq 1 ]; then
    SCANNER_IP="$1"
fi

echo "========================================="
echo "ScanSnap Traffic Capture Script"
echo "========================================="
echo ""
echo "Scanner IP:  $SCANNER_IP"
echo "Scanner MAC: $SCANNER_MAC"
echo ""

if [ "$SCANNER_IP" = "192.168.1.100" ]; then
    echo "⚠️  WARNING: Using default IP address!"
    echo "   Configure: ./scansnap_wireshark.sh YOUR_IP YOUR_MAC"
    echo ""
fi

# Detect network interface
echo "Available network interfaces:"
ip link show | grep -E "^[0-9]+:" | cut -d: -f2 | tr -d ' '
echo ""
echo -n "Enter interface name (or press Enter to auto-detect): "
read user_interface

if [ -z "$user_interface" ]; then
    # Auto-detect interface that can reach the scanner
    INTERFACE=$(ip route get $SCANNER_IP | grep -oP '(?<=dev )\S+' | head -1)
    echo "Auto-detected interface: $INTERFACE"
else
    INTERFACE="$user_interface"
fi

echo ""
echo "Starting packet capture on interface $INTERFACE"
echo "Filtering for traffic to/from $SCANNER_IP"
echo "Output file: $CAPTURE_FILE"
echo ""
echo "Press Ctrl+C to stop capture"
echo ""

# Capture filter for scanner traffic
# This captures:
# - All traffic to/from scanner IP
# - mDNS broadcasts (UDP 5353)
# - ScanSnap discovery (UDP 8194)
# - ARP for the scanner MAC

sudo tcpdump -i $INTERFACE -w $CAPTURE_FILE -v \
    "(host $SCANNER_IP) or \
     (udp port 5353) or \
     (udp port 8194) or \
     (ether host $SCANNER_MAC)"

echo ""
echo "Capture saved to: $CAPTURE_FILE"
echo ""
echo "To analyze with Wireshark GUI:"
echo "  wireshark $CAPTURE_FILE &"
echo ""
echo "To analyze with tshark (CLI):"
echo "  tshark -r $CAPTURE_FILE -V | less"
echo ""
echo "To filter for specific protocols:"
echo "  tshark -r $CAPTURE_FILE -Y 'http or https or dns'"
echo ""
