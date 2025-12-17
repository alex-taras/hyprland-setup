#!/bin/bash
# aur.sh - Build tools and AUR helper

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing build tools..."
sudo pacman -S --needed --noconfirm base-devel git rust

if ! command -v paru &>/dev/null; then
    log "Installing paru..."
    cd /tmp
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd "$OLDPWD"
    log "Paru installed!"
else
    log "Paru already installed."
fi
