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
mkdir -p ~/.config/mpd
cp -r ./dotfiles/mpd/* ~/.config/mpd/

log "Creating MPD data directories..."
mkdir -p ~/.mpd/playlists

# Remove database if it's a directory (common mistake)
if [ -d ~/.mpd/database ]; then
    log "WARNING: database is a directory, removing it (MPD needs it to be a file)..."
    rm -rf ~/.mpd/database
fi
log "MPD will create database file on first run"

log "Configuring MPD to wait for network..."
mkdir -p ~/.config/systemd/user/mpd.service.d
cat > ~/.config/systemd/user/mpd.service.d/network-wait.conf <<'EOF'
[Unit]
After=network-online.target
Wants=network-online.target

[Service]
Restart=on-failure
RestartSec=5
EOF
log "MPD will wait for network and auto-restart on failure"

log "Disabling system MPD service..."
if systemctl is-enabled mpd &>/dev/null 2>&1; then
    log "Stopping and disabling system MPD (using user service instead)..."
    sudo systemctl stop mpd
    sudo systemctl disable mpd
else
    log "System MPD not enabled"
fi

log "Enabling user MPD service..."
systemctl --user daemon-reload
if systemctl --user is-enabled mpd &>/dev/null; then
    log "MPD service already enabled, restarting..."
    systemctl --user restart mpd || log "MPD restart failed (will retry on network)"
else
    systemctl --user enable --now mpd || log "MPD start failed (will retry on network)"
fi

log "Installing mpdris2 for media key support..."
if rpm -q mpdris2 &>/dev/null; then
    log "mpdris2 already installed"
else
    sudo dnf install -y mpdris2
fi

log "Enabling mpDris2 service..."
if systemctl --user is-enabled mpDris2 &>/dev/null; then
    log "mpDris2 service already enabled"
else
    systemctl --user enable --now mpDris2
fi

log "Installing cava (audio visualizer)..."
if rpm -q cava &>/dev/null; then
    log "cava already installed"
else
    sudo dnf install -y cava
fi

log "Creating MPD FIFO for cava..."
if [ -p /tmp/mpd.fifo ]; then
    log "MPD FIFO already exists"
else
    mkfifo /tmp/mpd.fifo
    chmod 666 /tmp/mpd.fifo
    log "Created /tmp/mpd.fifo for cava visualization"
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
cp -r ./dotfiles/waybar/* ~/.config/waybar/

log "Deploying custom scripts..."
mkdir -p ~/bin
cp ../bin/bar-*.sh ~/bin/
chmod +x ~/bin/bar-*.sh

log "Waybar setup complete!"
log "Restart waybar to apply changes: killall waybar && waybar &"
