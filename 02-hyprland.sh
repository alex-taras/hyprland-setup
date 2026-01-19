#!/bin/bash
# hyprland.sh - Hyprland base installation
# Note: Hyprland is launched via start-hyprland wrapper (crash recovery + safe mode)
# Configured in /usr/share/wayland-sessions/hyprland.desktop

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

log "Installing sysc-greet greeter..."
if command -v sysc-greet &>/dev/null; then
    log "sysc-greet already installed"
else
    curl -fsSL https://raw.githubusercontent.com/Nomadcxx/sysc-greet/master/install.sh | sudo bash
fi

log "Deploying greetd configs..."
if [ -d /etc/greetd ]; then
    sudo cp ./dotfiles/greetd/config.toml /etc/greetd/
    sudo cp ./dotfiles/greetd/hyprland-greeter-config.conf /etc/greetd/
    sudo cp ./dotfiles/greetd/kitty.conf /etc/greetd/
    log "Greetd configs deployed"
else
    log "WARNING: /etc/greetd not found, skipping greeter config deployment"
fi

log "Installing waybar..."
if rpm -q waybar &>/dev/null; then
    log "waybar already installed"
else
    sudo dnf install -y waybar
fi

log "Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts

# CaskaydiaMono (Gruvbox theme)
if fc-list | grep -q "CaskaydiaMono Nerd Font"; then
    log "CaskaydiaMono Nerd Font already installed"
else
    unzip -o ./fonts/CascadiaMono.zip -d ~/.local/share/fonts/
    log "CaskaydiaMono Nerd Font installed"
fi

# JetBrainsMono (Nord theme)
if fc-list | grep -q "JetBrainsMono Nerd Font"; then
    log "JetBrainsMono Nerd Font already installed"
else
    sudo dnf install -y jetbrains-mono-fonts-all
    log "JetBrainsMono Nerd Font installed"
fi

# FiraMono (Catppuccin theme)
if fc-list | grep -q "FiraMono Nerd Font"; then
    log "FiraMono Nerd Font already installed"
else
    if [ -f ./fonts/FiraMono.zip ]; then
        unzip -o ./fonts/FiraMono.zip -d ~/.local/share/fonts/
        log "FiraMono Nerd Font installed"
    else
        log "WARNING: FiraMono.zip not found in fonts/ - Catppuccin theme font missing"
    fi
fi

fc-cache -f -v
log "Font cache rebuilt"



log "Installing Hyprland tools..."

# Clipboard
if rpm -q wl-clipboard &>/dev/null && rpm -q cliphist &>/dev/null; then
    log "Clipboard tools already installed"
else
    sudo dnf install -y wl-clipboard cliphist --skip-unavailable
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

# Hyprland GUI utilities
if rpm -q hyprland-guiutils &>/dev/null; then
    log "hyprland-guiutils already installed"
else
    sudo dnf install -y hyprland-guiutils
fi

log "Installing nwg-dock-hyprland..."
if rpm -q nwg-dock-hyprland &>/dev/null; then
    log "nwg-dock-hyprland already installed"
else
    sudo dnf install -y nwg-dock-hyprland
fi

log "Deploying nwg-dock-hyprland config..."
mkdir -p ~/.config/nwg-dock-hyprland
cp -r ./dotfiles/nwg-dock-hyprland/* ~/.config/nwg-dock-hyprland/

log "Installing nwg-bar from source..."
if command -v nwg-bar &>/dev/null; then
    log "nwg-bar already installed"
else
    log "Installing nwg-bar build dependencies..."
    sudo dnf install -y gtk3-devel gtk-layer-shell-devel golang make

    if [ ! -d ~/build/nwg-bar ]; then
        mkdir -p ~/build
        git clone https://github.com/nwg-piotr/nwg-bar.git ~/build/nwg-bar
    fi

    cd ~/build/nwg-bar
    make get
    make build
    sudo make install
    cd -
    log "nwg-bar installed"
fi

log "Deploying nwg-bar config..."
mkdir -p ~/.config/nwg-bar/icons
cp -r ./dotfiles/nwg-bar/* ~/.config/nwg-bar/

log "Deploying webapp shortcuts..."
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons/hicolor/scalable/apps
cp ./dotfiles/applications/chrome-*.desktop ~/.local/share/applications/
cp ./dotfiles/applications/org.gnome.Nautilus.desktop ~/.local/share/applications/
cp ./dotfiles/icons/chrome-*.svg ~/.local/share/icons/hicolor/scalable/apps/
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
gtk-update-icon-cache ~/.local/share/icons/hicolor/ 2>/dev/null || true

log "Deploying Hyprland dotfiles..."
mkdir -p ~/.config/hypr
cp -r ./dotfiles/hypr/* ~/.config/hypr/

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
cp ./dotfiles/rofi/rounded-gruvebox-dark.rasi ~/.local/share/rofi/themes/
cp -r ./dotfiles/rofi/template ~/.local/share/rofi/themes/

log "Setting rofi theme..."
mkdir -p ~/.config/rofi
echo 'configuration { show-icons: true; }' > ~/.config/rofi/config.rasi
echo '@theme "~/.local/share/rofi/themes/rounded-gruvebox-dark.rasi"' >> ~/.config/rofi/config.rasi

log "Reloading Hyprland config..."
hyprctl reload

log "Hyprland setup complete!"
log "Dotfiles deployed and config reloaded."
