#!/bin/bash
# setup.sh
# Main orchestrator script

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_DIR="$SCRIPT_DIR/dependencies"

echo "=== Hyprland Setup - Main Script ==="
echo "Running from: $SCRIPT_DIR"
echo ""

# Check if running Fedora
if ! grep -q "Fedora\|Nobara" /etc/os-release; then
    echo "Warning: This script is designed for Fedora/Nobara"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Check if dependencies directory exists
if [ ! -d "$DEPS_DIR" ]; then
    echo "Error: $DEPS_DIR directory not found"
    exit 1
fi

# Run sub-scripts in order
bash "$DEPS_DIR/hyprland-setup.sh"
bash "$DEPS_DIR/elephant-setup.sh"
bash "$DEPS_DIR/walker-setup.sh"
bash "$DEPS_DIR/waybar-setup.sh"
bash "$DEPS_DIR/configs-setup.sh"
bash "$DEPS_DIR/system-setup.sh"

echo ""
echo "=== Setup Complete ==="
echo "Please reboot and select 'Hyprland' at the login screen"
echo "Power button menu: Press physical power button or Super+Escape"