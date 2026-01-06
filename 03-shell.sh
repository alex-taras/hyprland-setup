#!/bin/bash
# shell.sh - Shell customization

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing starship..."
if rpm -q starship &>/dev/null; then
    log "Starship already installed"
else
    sudo dnf install -y starship
fi

log "Setting up starship prompt..."
if ! grep -q "starship init bash" ~/.bashrc; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    log "Added starship to .bashrc"
else
    log "Starship already in .bashrc"
fi

log "Copying dotfiles..."
cp -r ./dotfiles/starship.toml ~/.config/
cp -r ./dotfiles/kitty ~/.config/

log "Shell configured! Run 'exec bash' to reload."
