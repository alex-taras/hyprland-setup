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

# GPU drivers (AMD)
log "Installing AMD GPU drivers and Vulkan support..."
sudo pacman -S --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon

# Wine and dependencies
log "Installing Wine and dependencies..."
sudo pacman -S --noconfirm wine wine-gecko wine-mono winetricks

# Wine 32-bit libraries
log "Installing Wine 32-bit dependencies..."
sudo pacman -S --noconfirm lib32-gnutls lib32-libldap lib32-mpg123 lib32-openal \
    lib32-v4l-utils lib32-libpulse lib32-alsa-plugins lib32-libxcomposite \
    lib32-libxinerama lib32-ncurses lib32-libxml2 lib32-freetype2 lib32-libpng lib32-sdl2

# Core gaming packages
log "Installing gaming platforms and tools..."
sudo pacman -S --noconfirm steam lutris gamescope \
    goverlay mangohud lib32-mangohud gamemode lib32-gamemode

# ProtonUp-Qt for Proton-GE management
if pacman -Q protonup-qt &>/dev/null; then
    log "ProtonUp-Qt already installed"
else
    log "Installing ProtonUp-Qt (choose appropriate version)..."
    paru -S protonup-qt
fi

log "Gaming stack installed!"
log "Run 'protonup-qt' to install Proton-GE versions for Steam."
