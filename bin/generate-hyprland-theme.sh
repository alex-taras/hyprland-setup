#!/bin/bash

# Generate hyprland theme from theme definition
# Usage: generate-hyprland-theme.sh <theme-name>

THEME=${1:-gruvbox}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$(dirname "$SCRIPT_DIR")/themes"
THEME_FILE="$THEME_DIR/$THEME.conf"
HYPR_DIR="$HOME/.config/hypr"
HYPR_DOTFILES="$(dirname "$SCRIPT_DIR")/dotfiles/hypr"

if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

# Create hypr directory if it doesn't exist
mkdir -p "$HYPR_DIR"

# Source the theme file
source "$THEME_FILE"

# Helper function to convert hex to rgb format for hyprlock
hex_to_rgb() {
    local hex="$1"
    hex="${hex#\#}"
    printf "rgb(%d, %d, %d)" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
}

# Helper function to convert hex to rgba format for hyprland (without #, with alpha)
hex_to_rgba() {
    local hex="$1"
    local alpha="${2:-ee}"
    hex="${hex#\#}"
    printf "rgba(${hex}${alpha})"
}

# Convert colors
ACTIVE_BORDER_1=$(hex_to_rgba "$accent" "ee")
ACTIVE_BORDER_2=$(hex_to_rgba "$warning" "ee")
INACTIVE_BORDER=$(hex_to_rgba "$bg2" "aa")
SHADOW_COLOR=$(hex_to_rgba "#1a1a1a" "ee")

INPUT_OUTER_COLOR=$(hex_to_rgb "$accent")
INPUT_INNER_COLOR=$(hex_to_rgb "$bg2")
INPUT_FONT_COLOR=$(hex_to_rgb "$fg0")
TIME_COLOR=$(hex_to_rgb "$accent")
DATE_COLOR=$(hex_to_rgb "$warning")
WEATHER_COLOR=$(hex_to_rgb "$success_light")
LOCATION_COLOR=$(hex_to_rgb "$info_light")

# Generate appearance.conf
if [ -f "$HYPR_DOTFILES/appearance.conf.template" ]; then
    sed -e "s|{{ACTIVE_BORDER_1}}|$ACTIVE_BORDER_1|g" \
        -e "s|{{ACTIVE_BORDER_2}}|$ACTIVE_BORDER_2|g" \
        -e "s|{{INACTIVE_BORDER}}|$INACTIVE_BORDER|g" \
        -e "s|{{SHADOW_COLOR}}|$SHADOW_COLOR|g" \
        "$HYPR_DOTFILES/appearance.conf.template" > "$HYPR_DIR/appearance.conf"
    echo "Generated hyprland appearance: $HYPR_DIR/appearance.conf"
fi

# Generate hyprlock.conf
if [ -f "$HYPR_DOTFILES/hyprlock.conf.template" ]; then
    sed -e "s|{{INPUT_OUTER_COLOR}}|$INPUT_OUTER_COLOR|g" \
        -e "s|{{INPUT_INNER_COLOR}}|$INPUT_INNER_COLOR|g" \
        -e "s|{{INPUT_FONT_COLOR}}|$INPUT_FONT_COLOR|g" \
        -e "s|{{TIME_COLOR}}|$TIME_COLOR|g" \
        -e "s|{{DATE_COLOR}}|$DATE_COLOR|g" \
        -e "s|{{WEATHER_COLOR}}|$WEATHER_COLOR|g" \
        -e "s|{{LOCATION_COLOR}}|$LOCATION_COLOR|g" \
        -e "s|{{FONT_FAMILY}}|$font_family|g" \
        -e "s|{{FONT_SIZE_LARGE}}|$font_size_large|g" \
        -e "s|{{FONT_SIZE_XLARGE}}|$font_size_xlarge|g" \
        -e "s|{{FONT_SIZE_XXLARGE}}|$font_size_xxlarge|g" \
        "$HYPR_DOTFILES/hyprlock.conf.template" > "$HYPR_DIR/hyprlock.conf"
    echo "Generated hyprlock config: $HYPR_DIR/hyprlock.conf"
fi

echo "Generated hyprland theme (theme: $THEME)"
