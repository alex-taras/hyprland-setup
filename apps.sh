#!/bin/bash
# apps.sh - General applications

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing general applications..."
sudo pacman -S --noconfirm firefox nemo nemo-fileroller libreoffice-fresh \
    zathura zathura-pdf-mupdf ttf-cascadia-code-nerd noto-fonts-emoji \
    ffmpeg gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad \
    gst-plugins-ugly gst-libav libva-mesa-driver libva-utils \
    nwg-look gnome-themes-extra gsettings-desktop-schemas dconf \
    p7zip unrar unzip zip imv polkit-gnome

if pacman -Q dolphin &>/dev/null; then
    log "Removing dolphin..."
    sudo pacman -Rns --noconfirm dolphin
else
    log "Dolphin not installed, skipping..."
fi

log "Setting nemo as default file manager..."
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

if pacman -Q lact &>/dev/null; then
    log "LACT already installed"
else
    log "Installing LACT (GPU control)..."
    paru -S lact
fi

log "Setting GTK dark theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

log "General apps installed!"
log "GTK dark theme enabled. Use 'nwg-look' to customize further."
