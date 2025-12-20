#!/bin/bash
# System update script - Update both official repos and AUR

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

log "Updating system packages..."
sudo pacman -Syu

log "Updating AUR packages..."
paru -Syu --aur

log "Cleaning package cache..."
paru -Sc --noconfirm

log "System update complete!"
