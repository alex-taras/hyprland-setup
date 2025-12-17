#!/bin/bash
W=$(hyprctl monitors -j | jq '.[] | select(.focused) | .width')
H=$(hyprctl monitors -j | jq '.[] | select(.focused) | .height')
R=$(hyprctl monitors -j | jq '.[] | select(.focused) | .refreshRate | floor')

gamescope --force-grab-cursor -W $W -H $H -r $R --adaptive-sync -f -- env MANGOHUD=1 "$@"