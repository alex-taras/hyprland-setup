#!/bin/bash
# setup.sh
# Main orchestrator script

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_DIR="$SCRIPT_DIR/dependencies"

# Source state management library
source "$DEPS_DIR/lib-state.sh"

# Initialize state tracking
init_state

# Parse command line options
SHOW_CHECK=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            SHOW_CHECK=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--check]"
            echo "  --check    Show installation status without installing"
            exit 1
            ;;
    esac
done

# If --check, show inventory and exit
if [ "$SHOW_CHECK" = true ]; then
    get_state_summary
    echo ""
    echo "=== Package Inventory ==="
    
    echo "Core Hyprland packages:"
    inventory_packages hyprland kitty dunst grim slurp hyprpaper wlogout firefox dolphin \
        waybar bluez blueman pamixer pavucontrol btop bc fontawesome-fonts \
        google-noto-emoji-fonts nwg-displays cargo rust go
    
    echo ""
    echo "Custom binaries:"
    inventory_binaries elephant walker wttrbar
    
    echo ""
    echo "Configuration files:"
    inventory_configs \
        "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/waybar/config.jsonc" \
        "$HOME/.config/waybar/style.css" \
        "$HOME/.config/kitty/kitty.conf"
    
    exit 0
fi

echo "=== Hyprland Setup - Main Script ==="
echo "Running from: $SCRIPT_DIR"
echo "State tracking: $STATE_FILE"
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
log "Setup completed successfully"
echo "Please reboot and select 'Hyprland' at the login screen"
echo "Power button menu: Press physical power button or Super+Escape"