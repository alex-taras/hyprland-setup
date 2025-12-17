#!/bin/bash
# TUI Config Menu
set -e

edit_file() {
    local file="$1"
    if [ -f "$file" ]; then
        nano "$file"
    else
        gum style --foreground="#ff0000" "File not found: $file"
        sleep 2
    fi
}

show_waybar_menu() {
    clear
    rows=$(tput lines)
    cols=$(tput cols)
    padding=$(( (rows - 4) / 2 ))
    printf '\n%.0s' $(seq 1 $padding)
    
    export GUM_CHOOSE_CURSOR_FOREGROUND="#33ccff"
    export GUM_CHOOSE_SELECTED_FOREGROUND="#33ccff"
    export GUM_CHOOSE_ITEM_FOREGROUND="#cdd6f4"
    export GUM_CHOOSE_CURSOR=" "
    export GUM_CHOOSE_SHOW_HELP=false
    export GUM_CHOOSE_HEADER=""
    
    # Calculate max width dynamically from menu items
    max_width=$(printf '%s\n' \
        " Edit Config" \
        " Edit Style" \
        "󰌍 Back" | wc -L)
    
    # Calculate horizontal padding to center the menu
    h_padding=$(( (cols - max_width) / 2 ))
    h_padding=$((h_padding > 0 ? h_padding : 0))
    left_pad=$(printf '%*s' $h_padding '')
    
    choice=$(gum choose --header="" \
        "${left_pad}$(gum style --align center --width $max_width ' Edit Config')" \
        "${left_pad}$(gum style --align center --width $max_width ' Edit Style ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰌍 Back       ')")
    
    action=$(echo "$choice" | xargs | sed 's/^[^ ]* //')
    
    case "$action" in
        "Edit Config")
            edit_file "$HOME/.config/waybar/config.jsonc"
            show_waybar_menu
            ;;
        "Edit Style")
            edit_file "$HOME/.config/waybar/style.css"
            show_waybar_menu
            ;;
        "Back"|*)
            main_menu
            ;;
    esac
}

show_hyprland_menu() {
    clear
    rows=$(tput lines)
    cols=$(tput cols)
    padding=$(( (rows - 4) / 2 ))
    printf '\n%.0s' $(seq 1 $padding)
    
    export GUM_CHOOSE_CURSOR_FOREGROUND="#33ccff"
    export GUM_CHOOSE_SELECTED_FOREGROUND="#33ccff"
    export GUM_CHOOSE_ITEM_FOREGROUND="#cdd6f4"
    export GUM_CHOOSE_CURSOR=" "
    export GUM_CHOOSE_SHOW_HELP=false
    export GUM_CHOOSE_HEADER=""
    
    # Calculate max width dynamically from menu items
    max_width=$(printf '%s\n' \
        " Edit Keybindings" \
        " Edit Rules" \
        " Run hyprmon" \
        "󰌍 Back" | wc -L)
    
    # Calculate horizontal padding to center the menu
    h_padding=$(( (cols - max_width) / 2 ))
    h_padding=$((h_padding > 0 ? h_padding : 0))
    left_pad=$(printf '%*s' $h_padding '')
    
    choice=$(gum choose --header="" \
        "${left_pad}$(gum style --align center --width $max_width ' Edit Keybindings')" \
        "${left_pad}$(gum style --align center --width $max_width ' Edit Rules      ')" \
        "${left_pad}$(gum style --align center --width $max_width ' Run hyprmon     ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰌍 Back           ')")
    
    action=$(echo "$choice" | xargs | sed 's/^[^ ]* //')
    
    case "$action" in
        "Edit Keybindings")
            edit_file "$HOME/.config/hypr/keybinds.conf"
            show_hyprland_menu
            ;;
        "Edit Rules")
            edit_file "$HOME/.config/hypr/rules.conf"
            show_hyprland_menu
            ;;
        "Run hyprmon")
            hyprmon
            show_hyprland_menu
            ;;
        "Back"|*)
            main_menu
            ;;
    esac
}

main_menu() {
    clear
    rows=$(tput lines)
    cols=$(tput cols)
    padding=$(( (rows - 4) / 2 ))
    printf '\n%.0s' $(seq 1 $padding)
    
    export GUM_CHOOSE_CURSOR_FOREGROUND="#33ccff"
    export GUM_CHOOSE_SELECTED_FOREGROUND="#33ccff"
    export GUM_CHOOSE_ITEM_FOREGROUND="#cdd6f4"
    export GUM_CHOOSE_CURSOR=" "
    export GUM_CHOOSE_SHOW_HELP=false
    export GUM_CHOOSE_HEADER=""
    
    # Calculate max width dynamically from menu items
    max_width=$(printf '%s\n' \
        " Waybar" \
        " Hyprland" \
        "󰜺 Exit" | wc -L)
    
    # Calculate horizontal padding to center the menu
    h_padding=$(( (cols - max_width) / 2 ))
    h_padding=$((h_padding > 0 ? h_padding : 0))
    left_pad=$(printf '%*s' $h_padding '')
    
    choice=$(gum choose --header="" \
        "${left_pad}$(gum style --align center --width $max_width ' Waybar   ')" \
        "${left_pad}$(gum style --align center --width $max_width ' Hyprland ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰜺 Exit     ')")
    
    action=$(echo "$choice" | xargs | sed 's/^[^ ]* //')
    
    case "$action" in
        "Waybar")
            show_waybar_menu
            ;;
        "Hyprland")
            show_hyprland_menu
            ;;
        "Exit"|*)
            exit 0
            ;;
    esac
}

# Main
if command -v gum &>/dev/null; then
    main_menu
else
    echo "Install gum: paru -S gum"
    exit 1
fi
