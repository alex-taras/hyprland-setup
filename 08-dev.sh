#!/bin/bash
# dev.sh - Development tools

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing coding tools..."

# Languages and runtimes (rust/go already installed from base)
log "Installing languages..."
sudo dnf install -y python3 python3-pip ruby nodejs

log "Installing Swift..."
if command -v swift &>/dev/null; then
    log "Swift already installed"
else
    log "Swift not available via dnf, install manually from swift.org if needed"
fi

# VSCode
if rpm -q code &>/dev/null; then
    log "VSCode already installed"
else
    log "Installing VSCode..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf install -y code
fi

log "Configuring VSCode settings..."
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json <<EOF
{
    "editor.fontFamily": "CaskaydiaMono Nerd Font",
    "editor.fontSize": 16,
    "terminal.integrated.fontFamily": "CaskaydiaMono Nerd Font",
    "terminal.integrated.fontSize": 16
}
EOF

log "Setting VSCode as default text editor..."
for mime in text/plain text/x-log text/x-python text/x-shellscript text/x-csrc text/x-c++src text/x-makefile text/markdown application/x-yaml application/json application/xml text/x-script.python application/x-shellscript; do
    xdg-mime default code.desktop "$mime" 2>/dev/null || true
done

log "Installing PulseView (Logic Analyzer)..."
if rpm -q pulseview &>/dev/null; then
    log "PulseView already installed"
else
    sudo dnf install -y pulseview
fi

log "Setting up USB permissions for PulseView..."
if groups | grep -q dialout; then
    log "User already in dialout group"
else
    sudo usermod -aG dialout $USER
    log "Added user to dialout group (re-login required)"
fi

log "Coding tools installed!"
log "VSCode: run 'code' to launch (set as default text editor)"
log "PulseView: run 'pulseview' (re-login required for USB access)"
