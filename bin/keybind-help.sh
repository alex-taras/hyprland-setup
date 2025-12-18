#!/bin/bash

# Keybind Help Display using glow
set -e

show_keybinds() {
    # Create markdown content and pipe to less
    cat << 'EOF' | glow -s dark -w 80 | less -R
# Keybind Reference

## Applications
- `SUPER + RETURN` - Terminal
- `SUPER + SPACE` - App Launcher
- `SUPER + F` - File Manager
- `SUPER + B` - Browser
- `SUPER + SHIFT + B` - Browser (Incognito)

## Webapps
- `SUPER + A` - Claude AI
- `SUPER + SHIFT + W` - WhatsApp Web
- `SUPER + E` - ProtonMail
- `SUPER + M` - Spotify
- `SUPER + L` - Plex

## Window Management
- `SUPER + W` - Close Window
- `SUPER + T` - Toggle Fullscreen
- `SUPER + SHIFT + T` - Toggle Floating
- `SUPER + S` - Toggle Split
- `SUPER + Arrows` - Move Focus

## Workspaces
- `SUPER + 1-0` - Switch Workspace
- `SUPER + SHIFT + 1-0` - Move to Workspace
- `SUPER + Scroll` - Next/Prev Workspace

## System
- `SUPER + Q` - Toggle Waybar
- `SUPER + SHIFT + Q` - Logout Menu
- `SUPER + P` - Random Wallpaper
- `SUPER + K` - Keybind Help

---
*Press 'q' to close*
EOF
}

# Main
if command -v glow &>/dev/null; then
    show_keybinds
else
    echo "Install glow: sudo pacman -S glow"
    exit 1
fi
