#!/bin/bash

export $(cat ~/.config/gum/gum.conf | xargs)

# TUI System Menu
set -e
logout_session() {
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        hyprctl dispatch exit 2>/dev/null || \
        swaymsg exit 2>/dev/null || \
        loginctl terminate-user "$USER"
    else
        pkill -KILL -u "$USER" || loginctl terminate-user "$USER"
    fi
}
confirm_action() {
    local action="$1"
    clear
    rows=$(tput lines)
    padding=$(( (rows - 2) / 2 ))
    printf '\n%.0s' $(seq 1 $padding)
    gum confirm --default=false \
        --affirmative="Yes" \
        --negative="No" \
        --prompt.foreground="#33ccff" \
        --selected.foreground="#33ccff" \
        "$action?"
    return $?
}
execute_action() {
    case "$1" in
        "Packages")
            kitty --detach $HOME/bin/pkg-install.sh &
            sleep 0.1
            pkill -P $$ kitty
            ;;
        "AUR")
            kitty --detach $HOME/bin/pkg-aur-install.sh &
            sleep 0.1
            pkill -P $$ kitty
            ;;
        "Help")
            kitty --detach $HOME/bin/keybind-help.sh &
            sleep 0.1
            pkill -P $$ kitty
            ;;
        "Lock")
            hyprctl dispatch exec hyprlock
            ;;
        "Shutdown")
            confirm_action "Shutdown" && systemctl poweroff
            ;;
        "Reboot")
            confirm_action "Reboot" && systemctl reboot
            ;;
        "Logout")
            confirm_action "Logout" && logout_session
            ;;
        "Cancel"|*)
            exit 0
            ;;
    esac
}
main_gum() {
    clear
    # Center vertically
    rows=$(tput lines)
    cols=$(tput cols)
    padding=$(( (rows - 4) / 2 ))
    printf '\n%.0s' $(seq 1 $padding)
    export GUM_CHOOSE_CURSOR_FOREGROUND="#33ccff"
    export GUM_CHOOSE_SELECTED_FOREGROUND="#33ccff"
    export GUM_CHOOSE_ITEM_FOREGROUND="#cdd6f4"
    export GUM_CHOOSE_CURSOR=" "
    export GUM_CHOOSE_SHOW_HELP=false
    export GUM_CONFIRM_SHOW_HELP=false
    export GUM_CHOOSE_HEADER=""
    
    # Calculate max width dynamically from menu items
    max_width=$(printf '%s\n' \
        " Packages" \
        "󰏖 AUR" \
        "󰞋 Help" \
        "━━━━━━━━━━" \
        " Lock" \
        "󰤁 Shutdown" \
        "󰜉 Reboot" \
        "󰍃 Logout" \
        "━━━━━━━━━━" \
        "󰠚 Cancel" | wc -L)
    
    # Calculate horizontal padding to center the menu
    h_padding=$(( (cols - max_width) / 2 ))
    h_padding=$((h_padding > 0 ? h_padding : 0))
    left_pad=$(printf '%*s' $h_padding '')
    
    # Center the menu block itself
    choice=$(gum choose --header="" \
        "${left_pad}$(gum style --align center --width $max_width ' Packages')" \
        "${left_pad}$(gum style --align center --width $max_width '󰏖 AUR     ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰞋 Help    ')" \
        "${left_pad}$(gum style --align center --width $max_width --foreground '#888888' '━━━━━━━━━━')" \
        "${left_pad}$(gum style --align center --width $max_width ' Lock    ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰤁 Shutdown')" \
        "${left_pad}$(gum style --align center --width $max_width '󰜉 Reboot  ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰍃 Logout  ')" \
        "${left_pad}$(gum style --align center --width $max_width --foreground '#888888' '━━━━━━━━━━')" \
        "${left_pad}$(gum style --align center --width $max_width '󰠚 Cancel  ')")
    # Strip padding and icon prefix
    action=$(echo "$choice" | xargs | sed 's/^[^ ]* //')
    execute_action "$action"
}
# Main
if command -v gum &>/dev/null; then
    main_gum
else
    echo "Install gum: sudo dnf install gum"
    exit 1
fi
