#!/bin/bash
# tools.sh - TUI and CLI utilities

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Installing gum (TUI tool for scripts)..."
if rpm -q gum &>/dev/null; then
    log "gum already installed"
else
    sudo dnf install -y gum
fi

log "Deploying gum config..."
mkdir -p ~/.config/gum
cp -r ./dotfiles/gum/* ~/.config/gum/

log "Installing core utilities..."
if rpm -q jq curl bc socat &>/dev/null; then
    log "Core utilities already installed"
else
    sudo dnf install -y jq curl bc socat
fi

log "Installing audio stack (pipewire)..."
if rpm -q pipewire pipewire-pulseaudio pipewire-alsa wireplumber &>/dev/null; then
    log "Pipewire stack already installed"
else
    sudo dnf install -y pipewire pipewire-pulseaudio pipewire-alsa wireplumber
fi

log "Installing wiremix (TUI audio mixer)..."
if rpm -q wiremix &>/dev/null; then
    log "wiremix already installed"
else
    sudo dnf install -y wiremix
fi

log "Installing bluetooth stack..."
if rpm -q bluez &>/dev/null; then
    log "Bluetooth already installed"
else
    sudo dnf install -y bluez bluez-tools
fi

log "Enabling bluetooth service..."
if systemctl is-enabled bluetooth &>/dev/null; then
    log "Bluetooth service already enabled"
else
    sudo systemctl enable --now bluetooth
fi

log "Installing bluetui build dependencies..."
if rpm -q dbus-devel pkgconf-pkg-config &>/dev/null; then
    log "dbus-devel already installed"
else
    sudo dnf install -y dbus-devel pkgconf-pkg-config
fi

log "Installing bluetui (TUI bluetooth manager)..."
if command -v bluetui &>/dev/null; then
    log "bluetui already installed"
else
    cargo install bluetui
fi

log "Adding cargo bin to PATH..."
if ! grep -q "/.cargo/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    log "Added ~/.cargo/bin to PATH in .bashrc"
else
    log "Cargo bin already in PATH"
fi

log "Installing NetworkManager..."
if rpm -q NetworkManager &>/dev/null; then
    log "NetworkManager already installed"
else
    sudo dnf install -y NetworkManager
fi

log "Enabling NetworkManager..."
if systemctl is-enabled NetworkManager &>/dev/null; then
    log "NetworkManager already enabled"
else
    sudo systemctl enable --now NetworkManager
fi

log "Configuring firewalld for Waydroid..."
# Add waydroid0 to trusted zone
sudo firewall-cmd --zone=trusted --add-interface=waydroid0 --permanent || true

# Enable masquerading on your main zone (probably FedoraWorkstation)
sudo firewall-cmd --zone=FedoraWorkstation --add-masquerade --permanent || true

sudo firewall-cmd --reload || true

log "Installing Samba..."
if rpm -q samba &>/dev/null; then
    log "Samba already installed"
else
    sudo dnf install -y samba
fi

log "Enabling Samba services..."
sudo systemctl enable --now smb nmb || true

log "Configuring Samba shares..."
# Add alext user to Samba (will prompt for password)
if sudo pdbedit -L | grep -q "^alext:"; then
    log "Samba user alext already exists"
else
    log "Adding Samba user alext (you will be prompted for password)..."
    sudo smbpasswd -a alext
fi

# Configure shares in smb.conf
if ! grep -q "\[DATA\]" /etc/samba/smb.conf; then
    log "Adding DATA share to smb.conf..."
    sudo tee -a /etc/samba/smb.conf > /dev/null <<EOF

[DATA]
    path = /mnt/DATA
    valid users = alext
    read only = no
    browseable = yes
    create mask = 0644
    directory mask = 0755
EOF
else
    log "DATA share already configured"
fi

if ! grep -q "\[WORK\]" /etc/samba/smb.conf; then
    log "Adding WORK share to smb.conf..."
    sudo tee -a /etc/samba/smb.conf > /dev/null <<EOF

[WORK]
    path = /mnt/WORK
    valid users = alext
    read only = no
    browseable = yes
    create mask = 0644
    directory mask = 0755
EOF
else
    log "WORK share already configured"
fi

log "Configuring firewall for Samba..."
# Get the active zone (usually FedoraWorkstation)
ACTIVE_ZONE=$(sudo firewall-cmd --get-default-zone)
sudo firewall-cmd --zone=$ACTIVE_ZONE --permanent --add-service=samba || true
sudo firewall-cmd --reload || true
log "Added Samba service to firewall zone: $ACTIVE_ZONE"

log "Restarting Samba services..."
sudo systemctl restart smb nmb

log "Installing impala (WiFi TUI)..."
if command -v impala &>/dev/null; then
    log "impala already installed"
else
    cargo install impala
fi

log "Installing TUI tools..."
if rpm -q ncdu &>/dev/null; then
    log "ncdu already installed"
else
    sudo dnf install -y btop ncdu
fi

log "Installing rmpc (MPD TUI client)..."
if command -v rmpc &>/dev/null; then
    log "rmpc already installed"
else
    cargo install rmpc
fi

log "Deploying rmpc config..."
mkdir -p ~/.config/rmpc/themes
cp -r ./dotfiles/rmpc/* ~/.config/rmpc/

log "Installing CLI tools..."
sudo dnf install -y ripgrep fd-find bat fzf zoxide rsync glow --skip-unavailable

log "Installing wf-recorder (Wayland screen recorder)..."
if rpm -q wf-recorder &>/dev/null; then
    log "wf-recorder already installed"
else
    sudo dnf install -y wf-recorder
fi

log "Installing superfile (TUI file manager)..."
if command -v spf &>/dev/null; then
    log "superfile already installed"
else
    bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
fi

log "Installing Nicotine+ (Soulseek client)..."
if rpm -q nicotine &>/dev/null; then
    log "Nicotine+ already installed"
else
    sudo dnf install -y nicotine
fi

log "Disabling systemd power button handling..."
if [ -f /etc/systemd/logind.conf ]; then
    if grep -q "^HandlePowerKey=ignore" /etc/systemd/logind.conf; then
        log "Power button already set to ignore"
    else
        sudo sed -i 's/#HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
        sudo sed -i 's/^HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
        log "Power button now handled by Hyprland"
    fi
else
    log "logind.conf not found, skipping power button config"
fi

log "Tools installed!"
log "Run 'exec bash' to reload PATH"
