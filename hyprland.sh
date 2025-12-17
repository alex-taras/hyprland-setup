#!/bin/bash
# hyprland.sh - Hyprland ecosystem

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing Hyprland tools..."
sudo pacman -S --noconfirm waybar starship hypridle cliphist wl-clipboard

log "Installing AUR packages (choose appropriate versions)..."
paru -S walker-git elephant-all gum wttrbar hyprmon swww hyprshot

log "Configuring hypridle..."
mkdir -p ~/.config/hypr
if [ ! -f ~/.config/hypr/hypridle.conf ]; then
    cat > ~/.config/hypr/hypridle.conf << 'EOF'
general {
    lock_cmd = notify-send "Idle timeout"
    before_sleep_cmd = notify-send "Going to sleep"
    after_sleep_cmd = notify-send "Waking up"
}

listener {
    timeout = 300  # 5 minutes
    on-timeout = $HOME/bin/random-wallpaper.sh
}

listener {
    timeout = 600  # 10 minutes
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
EOF
    log "Created hypridle.conf (wallpaper screensaver after 5min, screen off after 10min)"
else
    log "hypridle.conf already exists, skipping"
fi

log "Hyprland tools installed!"
log "Remember to add to your hyprland autostart:"
log "  exec-once = swww-daemon"
log "  exec-once = hypridle"
log "  exec-once = wl-paste --watch cliphist store"
