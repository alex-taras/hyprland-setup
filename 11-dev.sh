#!/bin/bash
# dev.sh - Development tools

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing coding tools..."

# Languages and runtimes (rust already installed from base)
sudo pacman -S --noconfirm go python python-pip ruby

# Editors and IDEs
sudo pacman -S --noconfirm code neovim

# Retro dev tools
if pacman -Q dosbox-staging &>/dev/null; then
    log "DOSBox Staging already installed"
else
    log "Installing DOSBox Staging (choose appropriate version)..."
    paru -S dosbox-staging
fi

log "Setting VSCode as default text editor..."
# Set VSCode as default for common text file types
for mime in text/plain text/x-log text/x-python text/x-shellscript text/x-csrc text/x-c++src text/x-makefile text/markdown application/x-yaml application/json application/xml text/x-script.python application/x-shellscript; do
    gio mime "$mime" code-oss.desktop 2>/dev/null || true
done

log "Coding tools installed!"
log "VSCode: run 'code' to launch (set as default text editor)"
log "Neovim: run 'nvim' (add Lazyvim config later if wanted)"
