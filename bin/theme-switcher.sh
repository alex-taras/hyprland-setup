#!/bin/bash

# Theme Switcher - Select and apply themes system-wide
# Uses gum for TUI menu

export $(cat ~/.config/gum/gum.conf 2>/dev/null | xargs) || true

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$(dirname "$SCRIPT_DIR")/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/current-theme"

# Get available themes
get_themes() {
    local themes=()
    for theme_file in "$THEME_DIR"/*.conf; do
        if [ -f "$theme_file" ]; then
            theme_name=$(basename "$theme_file" .conf)
            themes+=("$theme_name")
        fi
    done
    echo "${themes[@]}"
}

# Get current theme
get_current_theme() {
    if [ -f "$CURRENT_THEME_FILE" ]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "gruvbox"
    fi
}

# Apply theme
apply_theme() {
    local theme="$1"
    local theme_file="$THEME_DIR/$theme.conf"

    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme file not found: $theme_file"
        return 1
    fi

    echo "Applying theme: $theme"

    # Generate waybar theme
    "$SCRIPT_DIR/generate-waybar-theme.sh" "$theme"

    # Generate kitty theme
    "$SCRIPT_DIR/generate-kitty-theme.sh" "$theme"

    # Generate starship theme
    "$SCRIPT_DIR/generate-starship-theme.sh" "$theme"

    # Update GTK/Qt fonts
    "$SCRIPT_DIR/generate-gtk-qt-fonts.sh" "$theme"

    # Generate hyprland theme
    "$SCRIPT_DIR/generate-hyprland-theme.sh" "$theme"

    # Reload applications
    pkill -SIGUSR2 waybar 2>/dev/null || true
    pkill -USR1 kitty 2>/dev/null || true
    hyprctl reload 2>/dev/null || true

    # Save current theme
    echo "$theme" > "$CURRENT_THEME_FILE"

    echo "Theme applied: $theme"
    echo "Restart terminal and other apps to see full changes"
}

# Show theme menu with gum
show_menu() {
    clear

    # Center vertically
    rows=$(tput lines)
    cols=$(tput cols)
    padding=$(( (rows - 6) / 2 ))
    printf '\n%.0s' $(seq 1 $padding)

    export GUM_CHOOSE_CURSOR=" "
    export GUM_CHOOSE_SHOW_HELP=false
    export GUM_CHOOSE_HEADER=""

    # Get themes and current theme
    themes=($(get_themes))
    current=$(get_current_theme)

    # Build menu items
    menu_items=()
    max_width=0

    for theme in "${themes[@]}"; do
        if [ "$theme" = "$current" ]; then
            item="󰸞 $theme (current)"
        else
            item="󰉼 $theme"
        fi
        menu_items+=("$item")

        # Calculate max width
        item_len=${#item}
        if [ $item_len -gt $max_width ]; then
            max_width=$item_len
        fi
    done

    # Add some padding to width
    max_width=$((max_width + 4))

    # Calculate horizontal padding
    h_padding=$(( (cols - max_width) / 2 ))
    h_padding=$((h_padding > 0 ? h_padding : 0))
    left_pad=$(printf '%*s' $h_padding '')

    # Build styled menu
    styled_items=()
    for item in "${menu_items[@]}"; do
        styled_items+=("${left_pad}$(gum style --align center --width $max_width "$item")")
    done

    # Show menu
    choice=$(gum choose --header="" "${styled_items[@]}")

    # Extract theme name
    theme=$(echo "$choice" | xargs | sed 's/^[^ ]* //' | sed 's/ (current)//')

    apply_theme "$theme"
}

# Main
if ! command -v gum &>/dev/null; then
    echo "Error: gum not found. Install it: sudo dnf install gum"
    exit 1
fi

# If theme provided as argument, apply it directly
if [ -n "$1" ]; then
    apply_theme "$1"
else
    show_menu
fi
