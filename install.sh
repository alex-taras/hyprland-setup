#!/bin/bash
# install.sh - Run all setup scripts in order

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "Arch Linux Post-Install Setup"
echo "============================================"
echo ""

if [ "$1" != "--continue" ]; then
    bash "$SCRIPT_DIR/base.sh"
    bash "$SCRIPT_DIR/bootloader.sh"
    
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

bash "$SCRIPT_DIR/aur.sh"
bash "$SCRIPT_DIR/browser.sh"
bash "$SCRIPT_DIR/apps.sh"
bash "$SCRIPT_DIR/hyprland.sh"
bash "$SCRIPT_DIR/greeter.sh"
bash "$SCRIPT_DIR/shell.sh"
bash "$SCRIPT_DIR/gaming.sh"
bash "$SCRIPT_DIR/dev.sh"
bash "$SCRIPT_DIR/tools.sh"
bash "$SCRIPT_DIR/deploy.sh"

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
