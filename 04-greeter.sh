#!/bin/bash
# greeter.sh - Display manager setup

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

log "Installing sysc-greet-hyprland..."
if pacman -Q sysc-greet-hyprland &>/dev/null; then
    log "sysc-greet-hyprland already installed"
else
    paru -S sysc-greet-hyprland
fi

if systemctl is-enabled sddm &>/dev/null; then
    log "Disabling sddm..."
    sudo systemctl disable sddm
else
    log "SDDM not enabled, skipping..."
fi

if systemctl is-enabled greetd &>/dev/null; then
    log "Greetd already enabled"
else
    log "Enabling greetd..."
    sudo systemctl enable greetd
fi

log "Configuring greetd for sysc-greet-hyprland..."
if [ -f /etc/greetd/config.toml ]; then
    if grep -q "tuigreet" /etc/greetd/config.toml; then
        warn "Backing up old tuigreet config..."
        sudo cp /etc/greetd/config.toml /etc/greetd/config.toml.backup.$(date +%Y%m%d_%H%M%S)
    fi
fi

sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "Hyprland -c /etc/greetd/hyprland-greeter-config.conf"
user = "greeter"

[initial_session]
command = "Hyprland -c /etc/greetd/hyprland-greeter-config.conf"
user = "greeter"
EOF

log "Configuring greetd to suppress boot spam..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo mkdir -p /etc/systemd/system/greetd.service.d
sudo cp "$SCRIPT_DIR/dotfiles/greetd-no-spam.conf" /etc/systemd/system/greetd.service.d/no-spam.conf
sudo systemctl daemon-reload
log "Greetd drop-in configured to clean TTY and suppress errors"

log "Greeter configured! sysc-greet-hyprland will launch automatically."
warn "Restart greetd or reboot to see the new greeter:"
warn "  sudo systemctl restart greetd (will kill current session!)"
warn "  or simply reboot"
