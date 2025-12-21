#!/bin/bash

# Load gum theme
export $(cat ~/.config/gum/gum.conf 2>/dev/null | xargs) || true

# Show shutdown message with spinner
gum spin --spinner dot --title "Shutting Down..." -- sleep 5 2>/dev/null

# Shutdown
systemctl poweroff 2>/dev/null
