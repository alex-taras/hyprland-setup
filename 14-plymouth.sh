#!/bin/bash
# plymouth.sh - Install and configure Plymouth boot splash

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Installing Plymouth..."
sudo pacman -S --noconfirm plymouth

log "Configuring mkinitcpio hooks..."
sudo sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems plymouth)/' /etc/mkinitcpio.conf

log "Installing arch-mac-style theme..."
if [ -f "$SCRIPT_DIR/plymouth/arch-mac-style.zip" ]; then
    TEMP_DIR=$(mktemp -d)
    unzip -q "$SCRIPT_DIR/plymouth/arch-mac-style.zip" -d "$TEMP_DIR"
    sudo cp -r "$TEMP_DIR/arch-mac-style" /usr/share/plymouth/themes/
    rm -rf "$TEMP_DIR"
    log "Theme installed to /usr/share/plymouth/themes/arch-mac-style"
else
    warn "arch-mac-style.zip not found in $SCRIPT_DIR/plymouth/"
    exit 1
fi

log "Setting arch-mac-style as default theme..."
sudo plymouth-set-default-theme -R arch-mac-style

log "Plymouth installed and configured!"
log "Theme: arch-mac-style"
log "Kernel params should include: quiet splash (already in limine.conf)"
