#!/bin/bash
# apps.sh - General applications

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing general applications..."

# File managers & productivity
sudo dnf install -y nemo nemo-fileroller libreoffice zathura zathura-pdf-mupdf

# Fonts & icons
sudo dnf install -y google-noto-emoji-fonts

# Media players
sudo dnf install -y vlc imv

# System utilities
sudo dnf install -y nwg-look gnome-themes-extra p7zip p7zip-plugins unrar \
    unzip zip gvfs-smb samba-client tumbler gnome-keyring seahorse qalculate-gtk

log "Setting nemo as default file manager..."
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

log "Setting VLC as default media player..."
xdg-mime default vlc.desktop video/mp4 video/x-matroska video/avi video/mpeg \
    video/quicktime video/x-msvideo video/webm audio/mpeg audio/x-wav \
    audio/flac audio/ogg audio/mp4 audio/x-vorbis+ogg audio/x-opus+ogg

log "Setting imv as default image viewer..."
xdg-mime default imv.desktop image/png image/jpeg image/jpg image/gif \
    image/webp image/bmp image/svg+xml

log "Deploying bin scripts..."
mkdir -p ~/bin
cp -r ../bin/* ~/bin/
chmod +x ~/bin/*.sh

log "Apps installed and bin scripts deployed!"
