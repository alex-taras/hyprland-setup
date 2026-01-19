#!/bin/bash

# Generate kitty theme from theme definition
# Usage: generate-kitty-theme.sh <theme-name>

THEME=${1:-gruvbox}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$(dirname "$SCRIPT_DIR")/themes"
THEME_FILE="$THEME_DIR/$THEME.conf"
KITTY_DIR="$HOME/.config/kitty"
OUTPUT_FILE="$KITTY_DIR/current-theme.conf"

if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

# Create kitty directory if it doesn't exist
mkdir -p "$KITTY_DIR"

# Source the theme file
source "$THEME_FILE"

# Generate the kitty theme file
cat > "$OUTPUT_FILE" << EOF
# Kitty Theme - Auto-generated from $THEME theme
# Do not edit directly - use: generate-kitty-theme.sh $THEME

# Font configuration
font_family      $font_family_mono
font_size        $font_size_medium

# Cursor
cursor           $fg2
cursor_text_color $bg2

# URL
url_color        $info

# Selection
selection_foreground $fg1
selection_background $accent

# Background and foreground
foreground       $fg1
background       $bg0

# Black
color0  $bg2
color8  $bg3

# Red
color1  $critical
color9  $critical_light

# Green
color2  $success
color10 $success_light

# Yellow
color3  $warning
color11 $warning_light

# Blue
color4  $info
color12 $info_light

# Magenta
color5  $purple
color13 $purple_light

# Cyan
color6  $aqua
color14 $aqua_light

# White
color7  $fg3
color15 $fg0

# Tab bar
active_tab_foreground   $bg0
active_tab_background   $accent
inactive_tab_foreground $fg1
inactive_tab_background $bg2
EOF

echo "Generated kitty theme: $OUTPUT_FILE (theme: $THEME)"
