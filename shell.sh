#!/bin/bash
# shell.sh - Shell customization

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Setting up starship prompt..."
if ! grep -q "starship init bash" ~/.bashrc; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    log "Added starship to .bashrc"
else
    log "Starship already in .bashrc"
fi

log "Setting up gum theming..."
if ! grep -q "gum.conf" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Gum TUI theming (Gruvbox Dark Hard)
if [ -f ~/.config/gum/gum.conf ]; then
    export $(cat ~/.config/gum/gum.conf | xargs)
fi
EOF
    log "Added gum config to .bashrc"
else
    log "Gum config already in .bashrc"
fi

if [ ! -f ~/.config/starship.toml ]; then
    log "Generating default starship config..."
    starship preset catppuccin-powerline -o ~/.config/starship.toml
else
    log "Starship config already exists, skipping generation"
fi

log "Shell configured! Run 'exec bash' to reload."
log "Note: Kitty theme and starship config will be deployed by deploy.sh"
