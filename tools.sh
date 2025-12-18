#!/bin/bash
# tools.sh - IO and TUI utilities

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing IO and TUI tools..."

# Core utilities for custom scripts
sudo pacman -S --noconfirm jq curl bc socat

# Audio (pipewire likely already installed, ensure full stack)
sudo pacman -S --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber

# Bluetooth
sudo pacman -S --noconfirm bluez bluez-utils
if systemctl is-enabled bluetooth &>/dev/null; then
    log "Bluetooth already enabled"
else
    sudo systemctl enable --now bluetooth
fi

# Network (NetworkManager likely already installed)
sudo pacman -S --noconfirm networkmanager
if systemctl is-enabled NetworkManager &>/dev/null; then
    log "NetworkManager already enabled"
else
    sudo systemctl enable --now NetworkManager
fi

# Firewall (UFW)
log "Installing UFW firewall..."
if pacman -Q ufw &>/dev/null; then
    log "UFW already installed"
else
    paru -S --noconfirm ufw
fi

if systemctl is-enabled ufw &>/dev/null; then
    log "UFW already enabled"
else
    log "Enabling UFW..."
    sudo systemctl enable --now ufw
    sudo ufw --force enable
    log "UFW enabled and started"
fi

# Allow LocalSend port
log "Configuring UFW for LocalSend..."
sudo ufw allow 53317/tcp comment 'LocalSend'
sudo ufw allow 53317/udp comment 'LocalSend'

# Disk management
sudo pacman -S --noconfirm gnome-disk-utility gparted

# Bonus TUI utilities
sudo pacman -S --noconfirm btop ncdu

# Quality of life CLI tools
sudo pacman -S --noconfirm ripgrep fd bat eza fzf zoxide rsync glow less

log "Installing TUI tools (choose appropriate versions, e.g., pacseek option 1)..."
paru -S wiremix bluetuith impala pacseek

# File sharing
log "Installing LocalSend..."
paru -S --noconfirm localsend-bin

log "IO and TUI tools installed!"
log "TUI tools:"
log "  wiremix - audio mixer"
log "  bluetuith - bluetooth manager"
log "  impala - WiFi manager"
log "  pacseek - package manager"
log "  btop - system monitor"
log "  ncdu - disk usage analyzer"
log ""
log "CLI tools:"
log "  rg (ripgrep) - fast grep"
log "  fd - fast find"
log "  bat - cat with syntax highlighting"
log "  eza - modern ls"
log "  fzf - fuzzy finder"
log "  zoxide - smart cd (use 'z' command)"
log ""
log "Network:"
log "  UFW firewall enabled and running"
log "  Use 'sudo ufw status' to check firewall rules"
log "  LocalSend port 53317 (TCP/UDP) allowed through firewall"
log ""
log "File Sharing:"
log "  localsend - cross-platform file sharing"
