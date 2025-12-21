#!/bin/bash

# Load gum theme
export $(cat ~/.config/gum/gum.conf 2>/dev/null | xargs) || true

# Show reboot message with spinner
gum spin --spinner dot --title "Rebooting..." -- sleep 5 2>/dev/null

# Reboot
systemctl reboot 2>/dev/null
