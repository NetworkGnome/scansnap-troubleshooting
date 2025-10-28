#!/bin/bash

# Setup script for ScanSnap Troubleshooting Toolkit
# This script prepares the environment and configures scanner details

echo "========================================="
echo "ScanSnap Troubleshooting Toolkit Setup"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️  Please do not run this setup script as root/sudo"
    echo "   Individual scripts will prompt for sudo when needed"
    exit 1
fi

echo "Step 1: Making scripts executable..."
chmod +x scripts/*.sh
echo "✓ Scripts are now executable"
echo ""

echo "Step 2: Checking dependencies..."
echo ""

# Check for required tools
MISSING_DEPS=()

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        MISSING_DEPS+=("$1")
        echo "✗ $1 - NOT FOUND"
    else
        echo "✓ $1 - found"
    fi
}

check_dependency "ping"
check_dependency "nc"
check_dependency "curl"
check_dependency "arp"
check_dependency "nslookup"

echo ""
echo "Optional but recommended:"
check_dependency "nmap"
check_dependency "tcpdump"
check_dependency "wireshark"

# Check for mDNS tools
if command -v avahi-browse &> /dev/null; then
    echo "✓ avahi-browse - found (Linux mDNS)"
elif command -v dns-sd &> /dev/null; then
    echo "✓ dns-sd - found (macOS mDNS)"
else
    echo "✗ mDNS tools - NOT FOUND"
    MISSING_DEPS+=("avahi-utils or dns-sd")
fi

echo ""

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "⚠️  Missing dependencies detected"
    echo ""
    echo "To install missing dependencies:"
    echo ""
    
    # Detect OS and provide appropriate install command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS (using Homebrew):"
        echo "  brew install nmap wireshark"
    elif [[ -f /etc/debian_version ]]; then
        echo "Debian/Ubuntu:"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install nmap tcpdump wireshark avahi-utils netcat-openbsd"
    elif [[ -f /etc/redhat-release ]]; then
        echo "Fedora/RHEL:"
        echo "  sudo dnf install nmap tcpdump wireshark avahi-tools nc"
    else
        echo "Please install: ${MISSING_DEPS[*]}"
    fi
    echo ""
fi

echo "Step 3: Scanner configuration..."
echo ""
echo "Enter your scanner details (or press Enter to skip and edit scripts manually later):"
echo ""

read -p "Scanner IP address (e.g., 10.100.10.61): " scanner_ip
read -p "Scanner MAC address (e.g., 84:25:3f:6d:b6:10): " scanner_mac

if [ -n "$scanner_ip" ] && [ -n "$scanner_mac" ]; then
    echo ""
    echo "Updating scripts with your scanner details..."
    
    # Update all scripts with the new IP and MAC
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            # Create backup
            cp "$script" "$script.bak"
            
            # Update IP and MAC
            sed -i.tmp "s/SCANNER_IP=\".*\"/SCANNER_IP=\"$scanner_ip\"/" "$script"
            sed -i.tmp "s/SCANNER_MAC=\".*\"/SCANNER_MAC=\"$scanner_mac\"/" "$script"
            
            # Clean up temp files
            rm -f "$script.tmp"
            
            echo "  ✓ Updated $(basename $script)"
        fi
    done
    
    echo ""
    echo "✓ Scripts configured with your scanner details"
    echo "  IP: $scanner_ip"
    echo "  MAC: $scanner_mac"
else
    echo ""
    echo "⚠️  Skipped scanner configuration"
    echo "   You'll need to edit the scripts manually and update:"
    echo "   SCANNER_IP and SCANNER_MAC variables"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Read the documentation:"
echo "   cat README.md"
echo "   cat docs/TROUBLESHOOTING_GUIDE.md"
echo ""
echo "2. Run the main diagnostics:"
echo "   ./scripts/scansnap_diagnostics.sh"
echo ""
echo "3. If you have hostname issues:"
echo "   sudo ./scripts/fix_probe_name_issue.sh"
echo ""
echo "4. For discovery protocol testing:"
echo "   sudo ./scripts/scansnap_discovery_test.sh"
echo ""
echo "5. To capture network traffic:"
echo "   sudo ./scripts/scansnap_wireshark.sh"
echo ""
echo "For more help, see README.md or open an issue on GitHub"
echo ""
