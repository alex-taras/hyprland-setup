#!/bin/bash
# theming.sh - Theme manager setup and deployment

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log "Setting up theme manager..."

# Deploy theme definitions
log "Deploying theme definitions..."
mkdir -p ~/themes
cp -r "$SCRIPT_DIR/themes"/*.conf ~/themes/
log "Themes copied to ~/themes/"

# Ensure theme generator scripts are in ~/bin
log "Ensuring theme scripts are in ~/bin..."
mkdir -p ~/bin
for script in generate-waybar-theme.sh generate-kitty-theme.sh generate-starship-theme.sh \
              generate-gtk-qt-fonts.sh generate-hyprland-theme.sh theme-switcher.sh; do
    if [ -f "$SCRIPT_DIR/bin/$script" ]; then
        cp "$SCRIPT_DIR/bin/$script" ~/bin/
        chmod +x ~/bin/"$script"
    fi
done
log "Theme scripts deployed to ~/bin/"

# Ensure waybar template is in place
log "Deploying waybar template..."
mkdir -p ~/.config/waybar
if [ -f "$SCRIPT_DIR/dotfiles/waybar/style.css.template" ]; then
    cp "$SCRIPT_DIR/dotfiles/waybar/style.css.template" ~/.config/waybar/
    log "Waybar template deployed"
fi

# Ensure hyprland templates are in place
log "Deploying hyprland templates..."
mkdir -p ~/.config/hypr
if [ -f "$SCRIPT_DIR/dotfiles/hypr/appearance.conf.template" ]; then
    cp "$SCRIPT_DIR/dotfiles/hypr/appearance.conf.template" ~/.config/hypr/
fi
if [ -f "$SCRIPT_DIR/dotfiles/hypr/hyprlock.conf.template" ]; then
    cp "$SCRIPT_DIR/dotfiles/hypr/hyprlock.conf.template" ~/.config/hypr/
fi
log "Hyprland templates deployed"

# Detect current theme or set default
CURRENT_THEME_FILE="$HOME/.config/hypr/current-theme"
if [ -f "$CURRENT_THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
    log "Current theme: $CURRENT_THEME"
else
    CURRENT_THEME="gruvbox"
    echo "$CURRENT_THEME" > "$CURRENT_THEME_FILE"
    log "Set default theme: $CURRENT_THEME"
fi

# Generate all theme configs for current theme
log "Generating theme configs for: $CURRENT_THEME"
~/bin/generate-waybar-theme.sh "$CURRENT_THEME"
~/bin/generate-kitty-theme.sh "$CURRENT_THEME"
~/bin/generate-starship-theme.sh "$CURRENT_THEME"
~/bin/generate-gtk-qt-fonts.sh "$CURRENT_THEME"
~/bin/generate-hyprland-theme.sh "$CURRENT_THEME"

log "Theme manager setup complete!"
log ""
log "Available themes:"
for theme in ~/themes/*.conf; do
    theme_name=$(basename "$theme" .conf)
    if [ "$theme_name" = "$CURRENT_THEME" ]; then
        log "  • $theme_name (current)"
    else
        log "  • $theme_name"
    fi
done
log ""
log "To switch themes, run: ~/bin/theme-switcher.sh"
