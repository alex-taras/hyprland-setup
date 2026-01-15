#!/bin/bash
# grub-theme.sh - Install Gruvbox GRUB theme

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing Gruvbox GRUB theme..."

# Copy theme files
if [ -d /boot/grub2/themes/gruvbox ]; then
    log "Theme directory exists, updating files..."
else
    log "Creating theme directory..."
    sudo mkdir -p /boot/grub2/themes/gruvbox
fi

log "Copying theme files..."
sudo cp ./grub/theme/* /boot/grub2/themes/gruvbox/

# Update GRUB config
log "Updating GRUB configuration..."
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/gruvbox/theme.txt"|' /etc/default/grub
    log "Updated GRUB_THEME setting"
else
    echo 'GRUB_THEME="/boot/grub2/themes/gruvbox/theme.txt"' | sudo tee -a /etc/default/grub > /dev/null
    log "Added GRUB_THEME setting"
fi

# Regenerate GRUB config
log "Regenerating GRUB configuration..."
if [ -d /boot/efi/EFI/fedora ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    log "GRUB config updated (UEFI)"
else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    log "GRUB config updated (BIOS)"
fi

log "Gruvbox GRUB theme installed!"
log "Reboot to see the new theme."
