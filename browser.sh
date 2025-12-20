#!/bin/bash
# browser.sh - Browser installation with user choice

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Browser Installation"
echo ""
echo "Choose your preferred browser:"
echo "1) Firefox (official repo - faster install)"
echo "2) LibreWolf (official repo - privacy-focused Firefox fork)"
echo ""
read -p "Enter choice [1-2] (default: 1): " choice
choice=${choice:-1}

case $choice in
    1)
        log "Installing Firefox..."
        sudo pacman -S --noconfirm firefox
        log "Firefox installed!"
        ;;
    2)
        log "Installing LibreWolf..."
        sudo pacman -S --noconfirm librewolf
        log "LibreWolf installed!"
        ;;
    *)
        log "Invalid choice. Installing Firefox (default)..."
        sudo pacman -S --noconfirm firefox
        ;;
esac

log "Browser installation complete!"
