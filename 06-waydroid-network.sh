#!/bin/bash
# waydroid-network.sh - Configure UFW for Waydroid networking

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "============================================"
echo "Waydroid Network Configuration"
echo "============================================"
echo ""

# Check if UFW is installed
if ! command -v ufw &>/dev/null; then
    error "UFW is not installed. Install it first with: paru -S ufw"
    exit 1
fi

# Check if UFW is enabled
if ! systemctl is-enabled ufw &>/dev/null; then
    warn "UFW is not enabled. Enabling it now..."
    sudo systemctl enable --now ufw
    sudo ufw --force enable
fi

# Detect the main network interface
log "Detecting main network interface..."
MAIN_IFACE=$(ip route show default | awk '/default/ {print $5}' | head -n1)
if [ -z "$MAIN_IFACE" ]; then
    error "Could not detect main network interface"
    exit 1
fi
log "Main network interface: $MAIN_IFACE"

# Configure UFW for Waydroid
log "Configuring UFW for Waydroid..."

log "Setting default routed policy to allow..."
sudo ufw default allow routed

log "Allowing traffic on waydroid0 interface..."
sudo ufw allow in on waydroid0
sudo ufw allow out on waydroid0

# Backup before.rules
log "Backing up /etc/ufw/before.rules..."
sudo cp /etc/ufw/before.rules /etc/ufw/before.rules.backup.$(date +%Y%m%d_%H%M%S)

# Check if NAT rules already exist
if grep -q "# NAT table rules for Waydroid" /etc/ufw/before.rules; then
    warn "Waydroid NAT rules already exist in before.rules, skipping..."
else
    log "Adding NAT/masquerading rules to /etc/ufw/before.rules..."
    
    # Create temporary file with NAT rules at the top
    TEMP_FILE=$(mktemp)
    
    # Write NAT rules
    cat > "$TEMP_FILE" << EOF
# NAT table rules for Waydroid
*nat
:POSTROUTING ACCEPT [0:0]

# Forward Waydroid traffic to main network interface
-A POSTROUTING -s 192.168.240.0/24 -o $MAIN_IFACE -j MASQUERADE

COMMIT

EOF
    
    # Append original file
    cat /etc/ufw/before.rules >> "$TEMP_FILE"
    
    # Replace original file
    sudo mv "$TEMP_FILE" /etc/ufw/before.rules
    log "NAT rules added successfully"
fi

# Enable IP forwarding in sysctl
log "Ensuring IP forwarding is enabled..."
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.d/99-waydroid.conf 2>/dev/null; then
    echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-waydroid.conf > /dev/null
    sudo sysctl -p /etc/sysctl.d/99-waydroid.conf
fi

# Add FORWARD rules to before.rules if not present
log "Adding FORWARD rules to /etc/ufw/before.rules..."
if ! grep -q "# Waydroid FORWARD rules" /etc/ufw/before.rules; then
    # Find the line with "# ok icmp code for FORWARD"
    sudo sed -i '/# ok icmp code for FORWARD/i\
# Waydroid FORWARD rules\
-A ufw-before-forward -s 192.168.240.0/24 -j ACCEPT\
-A ufw-before-forward -d 192.168.240.0/24 -j ACCEPT\
' /etc/ufw/before.rules
    log "FORWARD rules added"
else
    warn "FORWARD rules already exist, skipping..."
fi

# Reload UFW
log "Reloading UFW..."
sudo ufw reload

# Manually add iptables rules as backup (in case UFW config doesn't work)
log "Adding direct iptables rules as backup..."
sudo iptables -t nat -C POSTROUTING -s 192.168.240.0/24 -o $MAIN_IFACE -j MASQUERADE 2>/dev/null || \
    sudo iptables -t nat -A POSTROUTING -s 192.168.240.0/24 -o $MAIN_IFACE -j MASQUERADE
sudo iptables -C FORWARD -i waydroid0 -j ACCEPT 2>/dev/null || \
    sudo iptables -A FORWARD -i waydroid0 -j ACCEPT
sudo iptables -C FORWARD -o waydroid0 -j ACCEPT 2>/dev/null || \
    sudo iptables -A FORWARD -o waydroid0 -j ACCEPT

# Restart Waydroid container if running
if systemctl is-active waydroid-container &>/dev/null; then
    log "Restarting Waydroid container..."
    sudo systemctl restart waydroid-container
    sleep 2
fi

echo ""
echo "============================================"
echo "Waydroid network configuration complete!"
echo "============================================"
echo ""
echo "Summary:"
echo "  - UFW default routed: allow"
echo "  - Waydroid interface: waydroid0 (allowed)"
echo "  - Main interface: $MAIN_IFACE"
echo "  - NAT/masquerading: enabled (192.168.240.0/24 -> $MAIN_IFACE)"
echo ""
echo "Next steps:"
echo "1. Stop Waydroid session: waydroid session stop"
echo "2. Start Waydroid: waydroid show-full-ui"
echo "3. Test internet in Waydroid"
echo ""
echo "If you still have issues, check:"
echo "  - sudo ufw status verbose"
echo "  - sudo iptables -t nat -L -n -v | grep waydroid"
echo ""
