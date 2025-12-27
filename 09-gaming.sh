#!/bin/bash
# gaming.sh - Gaming setup

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing retro gaming tools..."

# DOSBox Staging
if rpm -q dosbox-staging &>/dev/null; then
    log "DOSBox Staging already installed"
else
    sudo dnf install -y dosbox-staging
fi

log "Gaming tools installed!"
log "DOSBox Staging: run 'dosbox' to launch"
