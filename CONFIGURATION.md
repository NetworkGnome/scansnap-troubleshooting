# Configuration Guide

## Protecting Your Network Information

This toolkit has been designed to keep your personal network information private. The scripts use **placeholder values** by default and never expose your actual scanner IP or MAC address to GitHub.

## Three Ways to Configure

### Method 1: Environment Variables (Recommended)

```bash
# Create your configuration file
cp .env.example .env

# Edit with your scanner details
nano .env
# Update SCANNER_IP and SCANNER_MAC

# Use it
source .env
./scripts/scansnap_diagnostics.sh
```

### Method 2: Command Line Arguments

```bash
# Run with your scanner's IP and MAC
./scripts/scansnap_diagnostics.sh 192.168.1.50 aa:bb:cc:dd:ee:ff

# Or just IP (for most scripts)
./scripts/scansnap_discovery_test.sh 192.168.1.50
```

### Method 3: One-Time Export

```bash
# Set for current terminal session
export SCANNER_IP="192.168.1.50"
export SCANNER_MAC="aa:bb:cc:dd:ee:ff"

# Now run any script
./scripts/scansnap_diagnostics.sh
./scripts/fix_probe_name_issue.sh
```

## Finding Your Scanner Information

### On the Scanner Touch Screen

1. Tap **Setup** on the home screen
2. Tap **Wi-Fi Settings** or **Network Settings**  
3. View **IP Address** and **MAC Address**

### From Your Router

1. Log into your router's admin panel
2. Look for **DHCP Clients** or **Connected Devices**
3. Find device named **ScanSnap** or **Fujitsu**

### Using Command Line

```bash
# Scan your network for Fujitsu devices
nmap -sP 192.168.1.0/24 | grep -B 2 "Fujitsu"

# Or check ARP table
arp -a | grep -i "fujitsu\|pfu"

# Or use the scanner's web interface
# Usually accessible at https://scanner-ip
```

## Security Notes

✅ **Safe to commit:**
- Scripts with placeholder values (192.168.1.100)
- .env.example file
- Documentation

❌ **Never commit:**
- .env file (your actual configuration)
- Output files (*.pcap, *.txt)
- Backup files (*.bak)

The `.gitignore` file automatically prevents these from being committed.

## Configuration File Example

Your `.env` file should look like this (with your actual values):

```bash
# ScanSnap Configuration
SCANNER_IP=192.168.1.100
SCANNER_MAC=aa:bb:cc:dd:ee:ff
```

**⚠️ This file is private and will NOT be uploaded to GitHub**

## Verification

After configuring, verify your setup:

```bash
# Check if .env is ignored by git
git status
# Should NOT show .env as a changed file

# Test configuration
source .env
echo "IP: $SCANNER_IP"
echo "MAC: $SCANNER_MAC"

# Run diagnostics
./scripts/scansnap_diagnostics.sh
```

## What Information Is Exposed?

When you push to GitHub, only these **safe placeholder values** are shared:

- `SCANNER_IP=192.168.1.100` (example)
- `SCANNER_MAC=00:00:00:00:00:00` (example)

Your actual network details remain on your computer only.

## For Contributors

If you're contributing improvements to these scripts:

1. Always use placeholder values in code
2. Never hardcode your own IP/MAC addresses
3. Test with the example values: `192.168.1.100` / `00:00:00:00:00:00`
4. Ensure `.env` is in `.gitignore`

## Troubleshooting Configuration

### Issue: "WARNING: Using default IP address"

**Solution:** You haven't configured your scanner details yet.

```bash
# Option 1: Create .env file
cp .env.example .env
nano .env
source .env

# Option 2: Pass as argument
./scripts/scansnap_diagnostics.sh YOUR_IP YOUR_MAC

# Option 3: Export for session
export SCANNER_IP="YOUR_IP"
export SCANNER_MAC="YOUR_MAC"
```

### Issue: Scripts still show my old IP

**Solution:** Clear any cached environment variables.

```bash
# Unset old values
unset SCANNER_IP
unset SCANNER_MAC

# Re-source your config
source .env

# Or restart your terminal
```

### Issue: Accidentally committed .env file

**Solution:** Remove it from git history.

```bash
# Remove from git but keep local file
git rm --cached .env

# Commit the removal
git commit -m "Remove sensitive .env file"

# Push
git push

# Verify .env is in .gitignore
grep ".env" .gitignore
```

## Additional Privacy Tips

1. **Review before pushing:**
   ```bash
   git diff HEAD
   ```

2. **Check what will be committed:**
   ```bash
   git status
   git diff --staged
   ```

3. **Never hardcode in scripts:**
   - ❌ `SCANNER_IP="192.168.1.100"`
   - ✅ `SCANNER_IP="${SCANNER_IP:-192.168.1.100}"`

4. **Sanitize output files:**
   - Don't commit diagnostic outputs
   - Don't share pcap files publicly
   - Redact IPs in screenshots

## Questions?

If you're unsure whether something is safe to commit, open an issue on GitHub and ask!
