#!/bin/bash
WALLPAPER=$(find ~/Pictures/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) 2>/dev/null | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers found in ~/Pictures/Wallpapers"
    exit 1
fi

if ! pgrep -x swww-daemon >/dev/null; then
    echo "swww-daemon is not running"
    exit 1
fi

swww img "$WALLPAPER" --transition-type fade --transition-fps 60

# listen for monitor hotplug
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2 - | while read -r line; do
    if echo "$line" | grep -q "^monitoradded"; then
        sleep 0.5
        swww img "$WALLPAPER" --transition-type fade --transition-fps 60
    fi
done
