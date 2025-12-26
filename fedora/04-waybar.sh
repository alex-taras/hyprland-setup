#!/bin/bash
# waybar.sh - Waybar and dependencies

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing waybar dependencies..."

# MPD - Music Player Daemon
if rpm -q mpd &>/dev/null && rpm -q mpc &>/dev/null; then
    log "MPD already installed"
else
    sudo dnf install -y mpd mpc
fi

log "Deploying MPD config..."
mkdir -p ~/.mpd
cp -r ../dotfiles/mpd/* ~/.mpd/

log "Disabling system MPD service..."
if systemctl is-enabled mpd &>/dev/null 2>&1; then
    log "Stopping and disabling system MPD (using user service instead)..."
    sudo systemctl stop mpd
    sudo systemctl disable mpd
else
    log "System MPD not enabled"
fi

log "Enabling user MPD service..."
if systemctl --user is-enabled mpd &>/dev/null; then
    log "MPD service already enabled"
else
    systemctl --user enable --now mpd
fi

log "Installing mpdris2 for media key support..."
if rpm -q mpdris2 &>/dev/null; then
    log "mpdris2 already installed"
else
    sudo dnf install -y mpdris2
fi

log "Enabling mpdris2 service..."
if systemctl --user is-enabled mpdris2 &>/dev/null; then
    log "mpdris2 service already enabled"
else
    systemctl --user enable --now mpdris2
fi

# btop - system monitor
if rpm -q btop &>/dev/null; then
    log "btop already installed"
else
    sudo dnf install -y btop
fi

# wttrbar - weather widget (build from source)
if command -v wttrbar &>/dev/null; then
    log "wttrbar already installed"
else
    log "Building wttrbar from source..."
    if [ -d ~/build/wttrbar ]; then
        log "wttrbar repo already cloned"
    else
        mkdir -p ~/build
        git clone https://github.com/bjesus/wttrbar ~/build/wttrbar
    fi
    cd ~/build/wttrbar
    cargo build --release
    sudo cp target/release/wttrbar /usr/local/bin/
    cd -
    log "wttrbar installed to /usr/local/bin/"
fi

log "Deploying waybar dotfiles..."
mkdir -p ~/.config/waybar
cp -r ../dotfiles/waybar/* ~/.config/waybar/

log "Deploying custom scripts..."
mkdir -p ~/bin
cp ../bin/bar-*.sh ~/bin/
chmod +x ~/bin/bar-*.sh

log "Waybar setup complete!"
log "Restart waybar to apply changes: killall waybar && waybar &"
