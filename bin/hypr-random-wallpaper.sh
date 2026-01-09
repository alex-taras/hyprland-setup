#!/bin/bash

# Get two random wallpapers for the two monitors
WALLPAPERS=($(find ~/Pictures/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) 2>/dev/null | shuf -n 2))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No wallpapers found in ~/Pictures/Wallpapers"
    exit 1
fi

# If only one wallpaper found, use it for both monitors
if [ ${#WALLPAPERS[@]} -eq 1 ]; then
    WALLPAPERS[1]="${WALLPAPERS[0]}"
fi

if ! pgrep -x swww-daemon >/dev/null; then
    echo "swww-daemon is not running"
    exit 1
fi

# Set different wallpapers for each monitor
WALLPAPER_DP2="${WALLPAPERS[0]}"
WALLPAPER_HDMI="${WALLPAPERS[1]}"

swww img "$WALLPAPER_DP2" --outputs DP-2 --transition-type fade --transition-fps 60
swww img "$WALLPAPER_HDMI" --outputs HDMI-A-2 --transition-type fade --transition-fps 60

# listen for monitor hotplug
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2 - | while read -r line; do
    if echo "$line" | grep -q "^monitoradded"; then
        sleep 0.5
        swww img "$WALLPAPER_DP2" --outputs DP-2 --transition-type fade --transition-fps 60
        swww img "$WALLPAPER_HDMI" --outputs HDMI-A-2 --transition-type fade --transition-fps 60
    fi
done
