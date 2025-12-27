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

log "Installing CaskaydiaMono Nerd Font..."
if fc-list | grep -q "CaskaydiaMono Nerd Font"; then
    log "CaskaydiaMono Nerd Font already installed"
else
    mkdir -p ~/.local/share/fonts
    unzip -o ../fonts/CascadiaMono.zip -d ~/.local/share/fonts/
    fc-cache -f -v
    log "CaskaydiaMono Nerd Font installed"
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
if rpm -q kvantum qt6ct &>/dev/null; then
    log "Qt theme tools already installed"
else
    sudo dnf install -y kvantum qt6ct
fi

log "Configuring qt6ct for dark theme..."
mkdir -p ~/.config/qt6ct
cat > ~/.config/qt6ct/qt6ct.conf <<EOF
[Appearance]
color_scheme_path=/usr/share/qt6ct/colors/darker.conf
style=kvantum-dark

[Fonts]
general=@Variant(\0\0\0@\0\0\0\x1a\0\x43\0\x61\0s\0k\0\x61\0y\0\x64\0i\0\x61\0M\0o\0n\0o@(\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
EOF

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

# Hyprlock and hypridle
if rpm -q hyprlock hypridle &>/dev/null; then
    log "hyprlock and hypridle already installed"
else
    sudo dnf install -y hyprlock hypridle
fi

# brightnessctl for screen dimming
if rpm -q brightnessctl &>/dev/null; then
    log "brightnessctl already installed"
else
    sudo dnf install -y brightnessctl
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

log "Installing rofi..."
if rpm -q rofi &>/dev/null; then
    log "rofi already installed"
else
    sudo dnf install -y rofi
fi

log "Deploying rofi themes..."
mkdir -p ~/.local/share/rofi/themes
cp ../dotfiles/rofi/rounded-gruvebox-dark.rasi ~/.local/share/rofi/themes/
cp -r ../dotfiles/rofi/template ~/.local/share/rofi/themes/

log "Setting rofi theme..."
mkdir -p ~/.config/rofi
echo 'configuration { show-icons: true; }' > ~/.config/rofi/config.rasi
echo '@theme "~/.local/share/rofi/themes/rounded-gruvebox-dark.rasi"' >> ~/.config/rofi/config.rasi

log "Reloading Hyprland config..."
hyprctl reload

log "Hyprland setup complete!"
log "Dotfiles deployed and config reloaded."
