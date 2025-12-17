#!/bin/bash
# gaming.sh - Gaming setup

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing gaming packages..."

# Enable multilib (32-bit support)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    log "Enabling multilib repository..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy
else
    log "Multilib already enabled"
fi

# Core gaming packages
sudo pacman -S --noconfirm steam lutris gamescope \
    goverlay mangohud lib32-mangohud gamemode lib32-gamemode \
    wine-staging winetricks

# ProtonUp-Qt for Proton-GE management
if pacman -Q protonup-qt &>/dev/null; then
    log "ProtonUp-Qt already installed"
else
    log "Installing ProtonUp-Qt (choose appropriate version)..."
    paru -S protonup-qt
fi

log "Gaming stack installed!"
log "Run 'protonup-qt' to install Proton-GE versions for Steam."
