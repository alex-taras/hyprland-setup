# Hyprland Setup for Nobara/Fedora

Automated setup scripts for a complete Fedora/Nobara desktop environment with Hyprland, Gruvbox theme, and custom configurations.

> **Note**: This is the Fedora/Nobara branch. For Arch Linux setup, see the `main` branch.

## Overview

This repository contains modular installation scripts that set up a complete Fedora/Nobara system with:

- **Hyprland** - Modern Wayland compositor with Gruvbox theme
- **Dark theme** - System-wide dark theme for GTK, Qt, and KDE apps
- **Custom tools** - MPD, Waybar, Rofi, and more
- **Development tools** - VSCode, PulseView, multiple languages
- **Dotfiles deployment** - Automated configuration with CaskaydiaMono Nerd Font

## Quick Start

```bash
# Clone the repository (fedora branch)
git clone -b fedora https://github.com/alex-taras/hyprland-setup.git
cd hyprland-setup

# Run scripts in order
bash 00-base.sh          # Build tools, NFS, SSH
bash 00-darktheme.sh     # System-wide dark theme
bash 01-copr.sh          # COPR repositories
bash 02-hyprland.sh      # Hyprland + greeter
bash 03-shell.sh         # Starship prompt
bash 04-waybar.sh        # Waybar + MPD
bash 05-tools.sh         # TUI/CLI tools
bash 06-browser.sh       # Chromium + LibreWolf
bash 07-apps.sh          # Desktop apps + Spotify
bash 08-dev.sh           # Development tools
bash 09-gaming.sh        # DOSBox Staging
```

## Installation Scripts

| Script | Description | Key Packages |
|--------|-------------|--------------|
| `00-base.sh` | Build tools, NFS client, SSH | rust, golang, git, nfs-utils, rpcbind |
| `00-darktheme.sh` | System-wide dark theme | gtk, qt6ct, kvantum, KDE BreezeDark |
| `01-copr.sh` | COPR repositories | solopasha/hyprland, erikreider/SwayNotificationCenter |
| `02-hyprland.sh` | Hyprland environment | hyprland, hyprlock, hypridle, rofi, xfce-polkit, sysc-greet |
| `03-shell.sh` | Shell customization | starship, kitty configs |
| `04-waybar.sh` | Status bar and music | waybar, mpd, mpdris2, wttrbar (built from source), btop |
| `05-tools.sh` | System utilities | gum, bluetui, wiremix, rmpc, ripgrep, fd-find, bat, fzf, zoxide |
| `06-browser.sh` | Web browsers | chromium, librewolf |
| `07-apps.sh` | Desktop applications | nemo, libreoffice, vlc, imv, spotify (flatpak) |
| `08-dev.sh` | Development tools | VSCode, python, ruby, nodejs, pulseview |
| `09-gaming.sh` | Retro gaming | dosbox-staging |

## Key Features

### Gruvbox Theme
- **Hyprland** - Orange (#d65d0e) and yellow (#d79921) borders
- **Waybar** - Gruvbox color scheme with orange accents
- **Rofi** - Custom rounded Gruvbox dark theme
- **Hyprlock** - Orange border, dark background, time + date display
- **System-wide** - GTK, Qt (Kvantum), and KDE apps (BreezeDark)

### Font Configuration
- **CaskaydiaMono Nerd Font** - Unified across all applications
  - Installed from local zip file to `~/.local/share/fonts`
  - Used in: Waybar, Kitty, Rofi, Starship, Hyprlock, VSCode

### Hyprland Ecosystem
- **Waybar** - Status bar with MPD, weather (wttrbar), custom scripts
- **Rofi** - Application launcher with flatpak support
- **Hyprlock** - Lock screen with blur, time, and date
- **Hypridle** - Idle daemon (lock 5min, dim 10min, display off 20min)
- **swww** - Wallpaper daemon
- **grim + slurp** - Screenshot tools
- **cliphist** - Clipboard manager
- **xfce-polkit** - Authentication agent

### MPD Music Setup
- **MPD** - Music Player Daemon with NFS support
- **mpdris2** - MPRIS interface for media keys
- **rmpc** - TUI client (built from source via cargo)
- **Waybar integration** - MPD widget with controls

### Development Environment
- **VSCode** - Configured with CaskaydiaMono Nerd Font (size 16)
- **Languages** - Python, Ruby, Node.js, Rust, Go, Swift (manual)
- **PulseView** - Logic analyzer with USB permissions (dialout group)

### Network & Services
- **NFS** - Client configured for network shares
- **SSH** - Server enabled
- **Firewalld** - Waydroid rules configured
- **Samba** - File sharing enabled

## Custom Scripts (bin/)

Deployed to `~/bin/`:

| Script | Description |
|--------|-------------|
| `sys-menu.sh` | System menu (lock, shutdown, reboot, logout) |
| `hypr-random-wallpaper.sh` | Random wallpaper selector |
| `hypr-launch-app.sh` | App launcher with focus management |
| `hypr-launch-webapp.sh` | Web app launcher |
| `bar-sonarrq.sh` | Sonarr status for Waybar |
| `bar-stocktick.sh` | Stock ticker for Waybar |

## Directory Structure

```
hyprland-setup/
├── 00-base.sh
├── 00-darktheme.sh
├── 01-copr.sh
├── 02-hyprland.sh
├── 03-shell.sh
├── 04-waybar.sh
├── 05-tools.sh
├── 06-browser.sh
├── 07-apps.sh
├── 08-dev.sh
├── 09-gaming.sh
├── bin/                # Custom scripts
├── dotfiles/           # Configuration files
│   ├── hypr/          # Hyprland configs (Gruvbox theme)
│   ├── kitty/         # Terminal config
│   ├── waybar/        # Status bar config (Gruvbox)
│   ├── rofi/          # Launcher theme (Gruvbox)
│   ├── wofi/          # Alternative launcher (deprecated)
│   ├── mpd/           # MPD config with playlists
│   ├── gum/           # TUI tool config
│   └── starship.toml  # Shell prompt (with Nobara icon)
├── fonts/             # CaskaydiaMono.zip
└── Pictures/Wallpapers/  # Spacescape collection
```

## Configuration Highlights

### Hyprland Keybinds
- `Super + Space` - Rofi launcher
- `Super + M` - Spotify (flatpak)
- `Super + L` - Lock screen (hyprlock)
- `Super + P` - Screenshot (full screen)
- `Super + Shift + P` - Screenshot (region)
- `Super + Shift + Q` - System menu

### Environment Variables
- `XDG_DATA_DIRS` - Includes flatpak paths for Rofi
- `QT_QPA_PLATFORMTHEME=qt6ct` - Qt dark theme
- `QT_STYLE_OVERRIDE=kvantum` - Kvantum theming

### Hypridle Timers
- **5 minutes** - Lock session (hyprlock)
- **10 minutes** - Dim screen to 10% brightness
- **20 minutes** - Turn display off

## Troubleshooting

### Qt Apps Not Dark (PulseView, Discover)
- Ensure qt6ct and kvantum are installed
- Check `~/.config/qt6ct/qt6ct.conf` exists
- Check `~/.config/kdeglobals` has BreezeDark config
- Restart the application

### Rofi Not Showing Flatpak Apps
- Check `~/.config/hypr/env.conf` has XDG_DATA_DIRS set
- Reload Hyprland: `hyprctl reload`

### MPD Not Starting
- Check system MPD is disabled: `systemctl status mpd`
- User service should be running: `systemctl --user status mpd`
- NFS libraries required: `libnfs`, `nfs-utils`

### Media Keys Not Working
- Check mpdris2 service: `systemctl --user status mpDris2`
- Restart if needed: `systemctl --user restart mpDris2`

## Post-Installation

1. **Reboot** to load all services and environment variables
2. **Test greeter** - sysc-greet should appear on reboot
3. **Configure Rofi** - Run `rofi-theme-selector` to preview themes
4. **Set wallpaper** - Use `~/bin/hypr-random-wallpaper.sh`
5. **Test lock** - `Super + L` to test hyprlock
6. **Add music** - Configure MPD music directory in `~/.mpd/mpd.conf`

## Requirements

- Nobara or Fedora (tested on Nobara 43)
- Internet connection
- User with sudo privileges

## Notes

- All scripts are idempotent (safe to run multiple times)
- Packages are checked before installation
- Services enabled automatically where needed
- Cargo packages built from source: bluetui, impala, rmpc, wttrbar
- Font installed locally (not from package manager)

## Branches

- **main** - Arch Linux setup
- **fedora** - Fedora/Nobara setup (this branch)

## License

Personal setup scripts. Use at your own risk. Feel free to fork and customize!
