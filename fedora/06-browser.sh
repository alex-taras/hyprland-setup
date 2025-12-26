#!/bin/bash
# browser.sh - Browser installation

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing browsers..."

# Chromium
if rpm -q chromium &>/dev/null; then
    log "Chromium already installed"
else
    sudo dnf install -y chromium
fi

# LibreWolf
if rpm -q librewolf &>/dev/null; then
    log "LibreWolf already installed"
else
    sudo dnf install -y librewolf
fi

log "Deploying LibreWolf user.js..."
if [ -f ../dotfiles/librewolf/user.js ]; then
    # Check if LibreWolf profile exists
    if [ ! -d "$HOME/.librewolf" ]; then
        log "Creating LibreWolf profile..."
        librewolf --headless &
        LIBREWOLF_PID=$!
        sleep 3
        kill $LIBREWOLF_PID 2>/dev/null || true
        wait $LIBREWOLF_PID 2>/dev/null || true
    fi
    
    # Deploy to all profiles
    for profile in "$HOME/.librewolf"/*.default*; do
        if [ -d "$profile" ]; then
            profile_name=$(basename "$profile")
            cp ../dotfiles/librewolf/user.js "$profile/"
            log "Deployed user.js to LibreWolf profile: $profile_name"
        fi
    done
else
    log "No LibreWolf user.js found in dotfiles, skipping..."
fi

log "Browsers installed!"
