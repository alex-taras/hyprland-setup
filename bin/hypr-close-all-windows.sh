#!/bin/bash

# Get current window address
CURRENT=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address')

# Close all windows except current
hyprctl clients -j | \
  jq -r ".[].address" | \
  grep -v "^${CURRENT}$" | \
  xargs -I{} hyprctl dispatch closewindow address:{}

# Move to first workspace
hyprctl dispatch workspace 1
