#!/bin/bash
# Install Hyprland and core dependencies

set -e

echo "=== Installing Hyprland and Core Tools ==="

# Core Hyprland packages
sudo dnf install -y \
    hyprland \
    kitty \
    dunst \
    grim \
    slurp \
    hyprpaper \
    wlogout \
    firefox \
    dolphin

# Additional dependencies
sudo dnf install -y \
    waybar \
    bluez \
    blueman \
    pamixer \
    pavucontrol \
    btop \
    bc \
    fontawesome-fonts \
    google-noto-emoji-fonts \
    nwg-displays

# Enable bluetooth
sudo systemctl enable --now bluetooth

# Build tools for later scripts
sudo dnf install -y \
    cargo \
    rust \
    go \
    glib-devel \
    cairo-devel \
    cairo-gobject-devel \
    poppler-devel \
    poppler-glib-devel \
    gtk4-layer-shell-devel \
    protoc \
    wayland-devel \
    wayland-protocols-devel \
    libxkbcommon-devel \
    lz4-devel

echo "✓ Hyprland core installation complete"
