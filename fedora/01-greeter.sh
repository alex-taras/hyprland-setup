#!/bin/bash
# greeter.sh - Switch from GDM to greetd with tuigreet

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

log "Installing greetd and tuigreet..."
if rpm -q greetd tuigreet &>/dev/null; then
    log "greetd and tuigreet already installed"
else
    sudo dnf install -y greetd tuigreet
fi

log "Disabling GDM..."
if systemctl is-enabled gdm &>/dev/null; then
    sudo systemctl disable gdm
    log "GDM disabled"
else
    log "GDM not enabled"
fi

log "Configuring greetd for Hyprland with tuigreet..."
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd Hyprland"
user = "greeter"

[initial_session]
command = "Hyprland"
user = "$USER"
EOF

# Replace $USER with actual username
sudo sed -i "s/\$USER/$USER/" /etc/greetd/config.toml

log "Enabling greetd..."
if systemctl is-enabled greetd &>/dev/null; then
    log "greetd already enabled"
else
    sudo systemctl enable greetd
fi

warn "Greeter switched to greetd + tuigreet!"
warn "IMPORTANT: On next reboot, you'll see tuigreet instead of GDM"
warn "If something goes wrong, boot to recovery and run:"
warn "  sudo systemctl disable greetd"
warn "  sudo systemctl enable gdm"
warn ""
warn "Reboot now to test the new greeter? (Ctrl+C to cancel, or wait 10s)"
sleep 10
sudo systemctl reboot
