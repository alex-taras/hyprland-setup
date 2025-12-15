#!/bin/bash
# Install Hyprland and core dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="hyprland_packages"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Hyprland packages already installed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Installing Hyprland and Core Tools ==="
log "Starting $COMPONENT installation"

# Show what's currently installed
echo "Checking current installation status..."
CORE_PACKAGES=(hyprland kitty dunst grim slurp hyprpaper wlogout firefox dolphin)
ADDITIONAL_PACKAGES=(waybar bluez blueman pamixer pavucontrol btop bc fontawesome-fonts google-noto-emoji-fonts nwg-displays)
BUILD_PACKAGES=(cargo rust go glib-devel cairo-devel cairo-gobject-devel poppler-devel poppler-glib-devel gtk4-layer-shell-devel protoc wayland-devel wayland-protocols-devel libxkbcommon-devel lz4-devel)

ALL_PACKAGES=("${CORE_PACKAGES[@]}" "${ADDITIONAL_PACKAGES[@]}" "${BUILD_PACKAGES[@]}")
MISSING_PACKAGES=()

for pkg in "${ALL_PACKAGES[@]}"; do
    if ! check_package "$pkg"; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    echo "✓ All packages already installed"
else
    echo "Installing ${#MISSING_PACKAGES[@]} missing packages..."
    sudo dnf install -y "${MISSING_PACKAGES[@]}"
fi

# Enable bluetooth
if systemctl is-enabled bluetooth &> /dev/null; then
    echo "✓ Bluetooth already enabled"
else
    echo "Enabling bluetooth..."
    sudo systemctl enable --now bluetooth
fi

echo "✓ Hyprland core installation complete"
mark_complete "$COMPONENT"
