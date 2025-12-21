#!/bin/bash

# Keybind Help Display using gum pager
set -e

# Load gum theme
export $(cat ~/.config/gum/gum.conf 2>/dev/null | xargs) || true

show_keybinds() {
    # Create markdown content and pipe to less
    #cat << 'EOF' | glow -s dark -w 80 | less -R
    gum pager < $HOME/bin/keybinds.MD
}

# Main
if command -v glow &>/dev/null; then
    show_keybinds
else
    echo "Install glow: sudo pacman -S glow"
    exit 1
fi
