#!/bin/bash
# base.sh - Base system setup: build tools, NFS, SSH

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing development tools..."
if rpm -q gcc make &>/dev/null; then
    log "Development tools already installed"
else
    sudo dnf groupinstall -y "Development Tools"
fi

log "Installing Rust..."
if command -v cargo &>/dev/null; then
    log "Rust already installed"
else
    sudo dnf install -y rust cargo
fi

log "Installing Go..."
if command -v go &>/dev/null; then
    log "Go already installed"
else
    sudo dnf install -y golang
fi

log "Installing Git..."
if rpm -q git &>/dev/null; then
    log "Git already installed"
else
    sudo dnf install -y git
fi

log "Installing NFS client..."
if rpm -q nfs-utils &>/dev/null && rpm -q libnfs &>/dev/null; then
    log "NFS already installed"
else
    sudo dnf install -y nfs-utils libnfs
fi

log "Enabling NFS services..."
if systemctl is-enabled rpcbind &>/dev/null; then
    log "rpcbind already enabled"
else
    sudo systemctl enable --now rpcbind
fi

if systemctl is-enabled nfs-client.target &>/dev/null; then
    log "nfs-client.target already enabled"
else
    sudo systemctl enable --now nfs-client.target
fi

log "Enabling SSH..."
if systemctl is-enabled sshd &>/dev/null; then
    log "SSH already enabled"
else
    sudo systemctl enable --now sshd
fi

log "Base system setup complete!"
