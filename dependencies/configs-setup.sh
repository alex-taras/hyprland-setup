#!/bin/bash
# Copy configs from local configs directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="configs"

# Setup error handling for this component
setup_error_handling "$COMPONENT"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Configurations already deployed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Setting up Configurations ==="
log "Starting $COMPONENT deployment"

# Get the repo root directory (parent of dependencies/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS_DIR="$REPO_ROOT/configs"

echo "Repository root: $REPO_ROOT"
echo "Configs directory: $CONFIGS_DIR"

# Check if configs directory exists
if [ ! -d "$CONFIGS_DIR" ]; then
    echo "Error: $CONFIGS_DIR not found"
    echo "Make sure you have the configs directory in your repo"
    exit 1
fi

# Create config directories
echo "Creating config directories..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wlogout
mkdir -p ~/.config/kitty
mkdir -p ~/bin

# Copy Hyprland config
if [ -f "$CONFIGS_DIR/hypr/hyprland.conf" ]; then
    cp "$CONFIGS_DIR/hypr/hyprland.conf" ~/.config/hypr/
    echo "✓ Copied hyprland.conf"
else
    echo "⚠ Warning: hyprland.conf not found"
fi

# Copy Waybar configs
if [ -f "$CONFIGS_DIR/waybar/config.jsonc" ]; then
    cp "$CONFIGS_DIR/waybar/config.jsonc" ~/.config/waybar/
    echo "✓ Copied waybar config"
else
    echo "⚠ Warning: waybar config.jsonc not found"
fi

if [ -f "$CONFIGS_DIR/waybar/style.css" ]; then
    cp "$CONFIGS_DIR/waybar/style.css" ~/.config/waybar/
    echo "✓ Copied waybar style"
else
    echo "⚠ Warning: waybar style.css not found"
fi

# Copy wlogout configs
if [ -f "$CONFIGS_DIR/wlogout/layout" ]; then
    cp "$CONFIGS_DIR/wlogout/layout" ~/.config/wlogout/
    echo "✓ Copied wlogout layout"
else
    echo "⚠ Warning: wlogout layout not found"
fi

if [ -f "$CONFIGS_DIR/wlogout/style.css" ]; then
    cp "$CONFIGS_DIR/wlogout/style.css" ~/.config/wlogout/
    echo "✓ Copied wlogout style"
else
    echo "⚠ Warning: wlogout style.css not found"
fi

# Copy Kitty config
if [ -f "$CONFIGS_DIR/kitty/kitty.conf" ]; then
    cp "$CONFIGS_DIR/kitty/kitty.conf" ~/.config/kitty/
    echo "✓ Copied kitty config"
else
    echo "⚠ Warning: kitty.conf not found"
fi

# Copy bin scripts
if [ -d "$CONFIGS_DIR/bin" ]; then
    cp "$CONFIGS_DIR/bin"/*.sh ~/bin/ 2>/dev/null || true
    chmod +x ~/bin/*.sh 2>/dev/null || true
    echo "✓ Copied bin scripts ($(ls -1 "$CONFIGS_DIR/bin"/*.sh 2>/dev/null | wc -l) files)"
else
    echo "⚠ Warning: bin directory not found"
fi

echo ""
echo "✓ Configuration files installed"
echo ""
echo "Installed configs:"
echo "  ~/.config/hypr/hyprland.conf"
echo "  ~/.config/waybar/config.jsonc"
echo "  ~/.config/waybar/style.css"
echo "  ~/.config/wlogout/layout"
echo "  ~/.config/wlogout/style.css"
echo "  ~/.config/kitty/kitty.conf"
echo "  ~/bin/*.sh"
mark_complete "$COMPONENT"