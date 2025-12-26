#!/bin/bash
# hyprland.sh - Hyprland base installation

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing Hyprland..."
if rpm -q hyprland &>/dev/null; then
    log "Hyprland already installed"
else
    sudo dnf install -y hyprland
fi

log "Installing waybar..."
if rpm -q waybar &>/dev/null; then
    log "waybar already installed"
else
    sudo dnf install -y waybar
fi

log "Installing fonts..."
if rpm -q cascadia-mono-nf-fonts &>/dev/null; then
    log "CaskaydiaMono Nerd Font already installed"
else
    sudo dnf install -y cascadia-mono-nf-fonts
fi

log "Setting system-wide dark theme..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

mkdir -p ~/.config/gtk-3.0
if grep -q "gtk-application-prefer-dark-theme" ~/.config/gtk-3.0/settings.ini 2>/dev/null; then
    log "GTK3 dark theme already set"
else
    echo "[Settings]" >> ~/.config/gtk-3.0/settings.ini
    echo "gtk-application-prefer-dark-theme=1" >> ~/.config/gtk-3.0/settings.ini
fi

mkdir -p ~/.config/gtk-4.0
if grep -q "gtk-application-prefer-dark-theme" ~/.config/gtk-4.0/settings.ini 2>/dev/null; then
    log "GTK4 dark theme already set"
else
    echo "[Settings]" >> ~/.config/gtk-4.0/settings.ini
    echo "gtk-application-prefer-dark-theme=1" >> ~/.config/gtk-4.0/settings.ini
fi

log "Installing Qt theme tools..."
if rpm -q kvantum &>/dev/null; then
    log "Kvantum already installed"
else
    sudo dnf install -y kvantum
fi

log "Installing Hyprland tools..."

# Clipboard
if rpm -q wl-clipboard &>/dev/null && rpm -q cliphist &>/dev/null; then
    log "Clipboard tools already installed"
else
    sudo dnf install -y wl-clipboard cliphist
fi

# Screenshot tools
if rpm -q grim &>/dev/null && rpm -q slurp &>/dev/null; then
    log "Screenshot tools already installed"
else
    sudo dnf install -y grim slurp
fi

# Wallpaper daemon
if rpm -q swww &>/dev/null; then
    log "swww already installed"
else
    sudo dnf install -y swww
fi

log "Installing polkit authentication agent..."
if rpm -q xfce-polkit &>/dev/null; then
    log "xfce-polkit already installed"
else
    sudo dnf install -y xfce-polkit
fi

log "Deploying Hyprland dotfiles..."
mkdir -p ~/.config/hypr
cp -r ../dotfiles/hypr/* ~/.config/hypr/

log "Adding xfce-polkit to autostart..."
if ! grep -q "xfce-polkit" ~/.config/hypr/autostart.conf; then
    echo "exec-once = /usr/libexec/xfce-polkit" >> ~/.config/hypr/autostart.conf
    log "Added xfce-polkit to autostart"
else
    log "xfce-polkit already in autostart"
fi

log "Deploying wofi config..."
mkdir -p ~/.config/wofi
cp -r ../dotfiles/wofi/* ~/.config/wofi/

log "Starting xfce-polkit..."
/usr/libexec/xfce-polkit &

log "Reloading Hyprland config..."
hyprctl reload

log "Hyprland setup complete!"
log "Dotfiles deployed and config reloaded."
