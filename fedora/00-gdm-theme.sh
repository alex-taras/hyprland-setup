#!/bin/bash
# gdm-theme.sh - Apply Gruvbox theme to GDM greeter

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Applying Gruvbox theme to GDM..."

# Create GDM dconf profile directory
sudo mkdir -p /etc/dconf/db/gdm.d

# Apply Gruvbox colors to GDM
sudo tee /etc/dconf/db/gdm.d/01-gruvbox <<'EOF'
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
color-scheme='prefer-dark'
cursor-theme='Adwaita'
font-name='CaskaydiaMono Nerd Font 11'

[org/gnome/desktop/background]
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/gnome/adwaita-d.jxl'
picture-uri-dark='file:///usr/share/backgrounds/gnome/adwaita-d.jxl'
primary-color='#3c3836'
secondary-color='#282828'
EOF

# Update dconf database
sudo dconf update

log "GDM Gruvbox theme applied!"
log "Changes will take effect on next logout/reboot"
