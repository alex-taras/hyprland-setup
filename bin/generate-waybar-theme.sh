#!/bin/bash

# Generate waybar palette.css from theme definition
# Usage: generate-waybar-theme.sh <theme-name>

THEME=${1:-gruvbox}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$(dirname "$SCRIPT_DIR")/themes"
THEME_FILE="$THEME_DIR/$THEME.conf"
WAYBAR_DIR="$HOME/.config/waybar"
OUTPUT_FILE="$WAYBAR_DIR/palette.css"

if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

# Create waybar directory if it doesn't exist
mkdir -p "$WAYBAR_DIR"

# Source the theme file
source "$THEME_FILE"

# Generate the CSS file
cat > "$OUTPUT_FILE" << EOF
/* Waybar Theme Palette - Auto-generated from $THEME theme */
/* Do not edit directly - use: generate-waybar-theme.sh $THEME */

/* Background colors */
@define-color bg0 $bg0;
@define-color bg1 $bg1;
@define-color bg2 $bg2;
@define-color bg3 $bg3;

/* Foreground colors */
@define-color fg0 $fg0;
@define-color fg1 $fg1;
@define-color fg2 $fg2;
@define-color fg3 $fg3;

/* Accent colors */
@define-color accent $accent;
@define-color accent-light $accent_light;
@define-color active $active;
@define-color inactive $inactive;

/* Status colors */
@define-color critical $critical;
@define-color critical-light $critical_light;
@define-color success $success;
@define-color success-light $success_light;
@define-color warning $warning;
@define-color warning-light $warning_light;
@define-color info $info;
@define-color info-light $info_light;

/* Additional colors */
@define-color purple $purple;
@define-color purple-light $purple_light;
@define-color aqua $aqua;
@define-color aqua-light $aqua_light;

/* Special colors */
@define-color white $white;
@define-color black $black;

/* Legacy color names for compatibility */
@define-color dark-gray $bg1;
@define-color dark-red $critical;
@define-color dark-green $success;
@define-color dark-yellow $warning;
@define-color dark-blue $info;
@define-color dark-purple $purple;
@define-color dark-aqua $aqua;
@define-color dark-orange $accent;

@define-color light-gray $fg3;
@define-color light-red $critical_light;
@define-color light-green $success_light;
@define-color light-yellow $warning_light;
@define-color light-blue $info_light;
@define-color light-purple $purple_light;
@define-color light-aqua $aqua_light;
@define-color light-orange $accent_light;
EOF

echo "Generated waybar theme: $OUTPUT_FILE (theme: $THEME)"
