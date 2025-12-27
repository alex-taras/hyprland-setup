#!/bin/bash
# copr.sh - SSH and COPR repos for Hyprland on Fedora

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Enabling SSH..."
if systemctl is-enabled sshd &>/dev/null; then
    log "SSH already enabled"
else
    sudo systemctl enable --now sshd
fi

log "Setting up COPR repos for Hyprland..."

# Main Hyprland repo
if dnf copr list | grep -q "solopasha/hyprland"; then
    log "solopasha/hyprland already enabled"
else
    sudo dnf copr enable -y solopasha/hyprland
fi

# Hyprland ecosystem tools (waybar, etc)
if dnf copr list | grep -q "erikreider/SwayNotificationCenter"; then
    log "erikreider/SwayNotificationCenter already enabled"
else
    sudo dnf copr enable -y erikreider/SwayNotificationCenter
fi

log "Done! COPR setup complete."
log "Run the next script to install Hyprland."
