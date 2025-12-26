#!/bin/bash
# base.sh - SSH and CachyOS repos

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Enabling SSH..."
if systemctl is-enabled sshd &>/dev/null; then
    log "SSH already enabled"
else
    sudo systemctl enable --now sshd
fi

log "Setting up CachyOS repos..."
if pacman-key --list-keys F3B607488DB35A47 &>/dev/null; then
    log "CachyOS key already imported"
else
    sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key F3B607488DB35A47
fi

if ! grep -q "^\[cachyos\]" /etc/pacman.conf; then
    log "Adding CachyOS repository to pacman.conf"
    sudo sed -i '/^\[core\]/i [cachyos]\nServer = https://mirror.cachyos.org/repo/$arch/$repo\n' /etc/pacman.conf
else
    log "CachyOS repository already in pacman.conf"
fi

if pacman -Q cachyos-keyring &>/dev/null && pacman -Q cachyos-mirrorlist &>/dev/null; then
    log "CachyOS keyring and mirrorlist already installed"
else
    sudo pacman -Sy --noconfirm cachyos-keyring cachyos-mirrorlist
fi

if grep -q "^Server = " /etc/pacman.conf | grep -A1 "^\[cachyos\]" | grep -q "cachyos-mirrorlist"; then
    log "CachyOS mirrorlist already configured"
else
    sudo sed -i '/^\[cachyos\]/,/^Server = / s|^Server = .*|Include = /etc/pacman.d/cachyos-mirrorlist|' /etc/pacman.conf
fi

sudo pacman -Sy --noconfirm

if pacman -Q linux-cachyos &>/dev/null; then
    log "CachyOS kernel already installed"
else
    sudo pacman -S --noconfirm linux-cachyos linux-cachyos-headers
fi

if pacman -Q linux-zen &>/dev/null; then
    log "Zen kernel already installed"
else
    sudo pacman -S --noconfirm linux-zen linux-zen-headers
fi

log "Disabling systemd-networkd-wait-online (conflicts with NetworkManager)..."
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

log "Done! CachyOS kernel installed."
log "Run 'bash bootloader.sh' to configure Limine bootloader automatically."
log "Then reboot to cachyos kernel before continuing with install.sh --continue"
