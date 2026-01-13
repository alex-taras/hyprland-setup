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

# Primary Hyprland repo (acidburnmonkey)
if dnf copr list | grep -q "acidburnmonkey/hyprland"; then
    log "acidburnmonkey/hyprland already enabled"
else
    sudo dnf copr enable -y acidburnmonkey/hyprland
fi

# Secondary Hyprland repo for extras (solopasha)
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

log "Configuring repo priorities..."

# Set acidburnmonkey as highest priority for Hyprland
ACIDBURN_REPO="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:acidburnmonkey:hyprland.repo"
if ! grep -q "^priority=" "$ACIDBURN_REPO"; then
    echo "priority=1" | sudo tee -a "$ACIDBURN_REPO" > /dev/null
    log "Set acidburnmonkey priority to 1"
fi

# Set solopasha as lower priority and exclude hyprland packages
SOLOPASHA_REPO="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:solopasha:hyprland.repo"
if ! grep -q "^priority=" "$SOLOPASHA_REPO"; then
    echo "priority=10" | sudo tee -a "$SOLOPASHA_REPO" > /dev/null
    log "Set solopasha priority to 10"
fi
if ! grep -q "^excludepkgs=" "$SOLOPASHA_REPO"; then
    echo "excludepkgs=hyprland hyprland-*" | sudo tee -a "$SOLOPASHA_REPO" > /dev/null
    log "Excluded hyprland packages from solopasha"
fi

log "Done! COPR setup complete."
log "Run the next script to install Hyprland."
