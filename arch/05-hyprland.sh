#!/bin/bash
# hyprland.sh - Hyprland ecosystem

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing Hyprland tools..."
sudo pacman -S --noconfirm waybar starship hypridle hyprlock cliphist wl-clipboard

log "Installing AUR packages (choose appropriate versions)..."
paru -S elephant-all-bin walker-bin gum wttrbar hyprmon-bin swww hyprshot

log "Hyprland tools installed!"
log "hypridle.conf will be deployed by 13-deploy.sh"
log "Remember to add to your hyprland autostart:"
log "  exec-once = swww-daemon"
log "  exec-once = hypridle"
log "  exec-once = wl-paste --watch cliphist store"
