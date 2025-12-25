#!/bin/bash
# install.sh - Run all setup scripts in order

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "Arch Linux Post-Install Setup"
echo "============================================"
echo ""

if [ "$1" != "--continue" ]; then
    bash "$SCRIPT_DIR/01-base.sh"
    bash "$SCRIPT_DIR/02-bootloader.sh"
    
    echo ""
    echo "============================================"
    echo "IMPORTANT: REBOOT to CachyOS kernel"
    echo "After reboot, run:"
    echo "  bash install.sh --continue"
    echo "============================================"
    exit 0
fi

echo ""
echo "Continuing with remaining setup scripts..."
echo ""

bash "$SCRIPT_DIR/03-aur.sh"
bash "$SCRIPT_DIR/04-greeter.sh"
bash "$SCRIPT_DIR/05-hyprland.sh"
bash "$SCRIPT_DIR/06-waydroid-network.sh"
bash "$SCRIPT_DIR/07-shell.sh"
bash "$SCRIPT_DIR/08-browser.sh"
bash "$SCRIPT_DIR/09-tools.sh"
bash "$SCRIPT_DIR/10-apps.sh"
bash "$SCRIPT_DIR/11-dev.sh"
bash "$SCRIPT_DIR/12-gaming.sh"
bash "$SCRIPT_DIR/13-deploy.sh"
bash "$SCRIPT_DIR/14-plymouth.sh"

echo ""
echo "============================================"
echo "Setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Reload Hyprland config: hyprctl reload"
echo "2. Run 'kitty +kitten themes' to pick kitty theme (if not using deployed config)"
echo "3. Use 'nwg-look' to customize GTK theme further"
echo "4. Reboot and enjoy!"
echo ""
