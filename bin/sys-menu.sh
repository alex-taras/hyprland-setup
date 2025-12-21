#!/bin/bash

export $(cat ~/.config/gum/gum.conf 2>/dev/null | xargs) || true

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
        "$action?"
    return $?
}
execute_action() {
    case "$1" in
        "Packages")
            kitty --detach --class floating-large -e $HOME/bin/pkg-install.sh &
            sleep 0.1
            pkill -P $$ kitty
            exec $0
            ;;
        "AUR")
            kitty --detach --class floating-large -e $HOME/bin/pkg-aur-install.sh &
            sleep 0.1
            pkill -P $$ kitty
            exec $0
            ;;
        "Uninstall")
            kitty --detach --class floating-large -e $HOME/bin/pkg-remove.sh &
            sleep 0.1
            pkill -P $$ kitty
            exec $0
            ;;
        "Update SYS")
            if confirm_action "Update System"; then
                kitty --detach --class floating-large -e $HOME/bin/sys-update.sh
                sleep 0.1
                pkill -P $$ kitty
            fi
            ;;
        "Lock")
            hyprctl dispatch exec hyprlock
            ;;
        "Shutdown")
            if confirm_action "Shutdown"; then
                kitty --detach --class floating-small -e $HOME/bin/sys-shutdown.sh &
                sleep 0.1
                pkill -P $$ kitty
            fi
            ;;
        "Reboot")
            if confirm_action "Reboot"; then
                kitty --detach --class floating-small -e $HOME/bin/sys-reboot.sh &
                sleep 0.1
                pkill -P $$ kitty
            fi
            ;;

        "Reboot")
            if confirm_action "Reboot"; then
                $HOME/bin/sys-reboot.sh
            fi
            ;;
        "Logout")
            if confirm_action "Logout"; then
                logout_session
            fi
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
    export GUM_CHOOSE_CURSOR=" "
    # export GUM_CHOOSE_SHOW_HELP=false
    export GUM_CONFIRM_SHOW_HELP=false
    export GUM_CHOOSE_HEADER=""
    
    # Calculate max width dynamically from menu items
    max_width=$(printf '%s\n' \
        "󱧕 Packages" \
        "󰏖 AUR" \
        "󱧙 Uninstall" \
        "󰚰 Update SYS" \
        "━━━━━━━━━━━━" \
        " Lock" \
        "󰤁 Shutdown" \
        "󰜉 Reboot" \
        "󰍃 Logout" | wc -L)
    
    # Calculate horizontal padding to center the menu
    h_padding=$(( (cols - max_width) / 2 ))
    h_padding=$((h_padding > 0 ? h_padding : 0))
    left_pad=$(printf '%*s' $h_padding '')
    
    # Center the menu block itself
    choice=$(gum choose --header="" \
        "${left_pad}$(gum style --align center --width $max_width '󱧕 Packages  ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰏖 AUR       ')" \
        "${left_pad}$(gum style --align center --width $max_width '󱧙 Uninstall ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰚰 Update SYS')" \
        "${left_pad}$(gum style --align center --width $max_width --foreground '#504945' '━━━━━━━━━━━━')" \
        "${left_pad}$(gum style --align center --width $max_width ' Lock      ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰤁 Shutdown  ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰜉 Reboot    ')" \
        "${left_pad}$(gum style --align center --width $max_width '󰍃 Logout    ')")
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
