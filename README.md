# Hyprland Setup Script

Automated setup script for Hyprland on Fedora/Nobara Linux with personalized configurations and dotfiles.

## Overview

This script automates the complete installation and configuration of Hyprland, including all dependencies, custom utilities, and backed-up dotfiles. Run one command to get your Hyprland environment exactly the way you like it.

## Features

- **Automated Installation**: Installs Hyprland and all required dependencies
- **Custom Configurations**: Deploys your personalized dotfiles for Hyprland, Waybar, Kitty, and more
- **Modular Design**: Each component has its own installation script for easy maintenance
- **Build Tools**: Includes Rust and Go toolchains for custom components
- **Custom Utilities**: Installs custom bin scripts for network status, stock ticker, and more
- **System Integration**: Enables Bluetooth and other system services automatically

## Prerequisites

- Fedora or Nobara Linux (warnings will appear for other distributions)
- sudo privileges
- Internet connection

## Quick Start

```bash
git clone <your-repo-url>
cd hyprland-setup
chmod +x setup.sh
./setup.sh
```

After installation completes, reboot and select "Hyprland" at the login screen.

## What Gets Installed

### Core Packages
- **Hyprland**: Tiling Wayland compositor
- **Kitty**: Terminal emulator
- **Waybar**: Status bar
- **Dunst**: Notification daemon
- **wlogout**: Power menu
- **Firefox**: Web browser
- **Dolphin**: File manager

### Utilities
- **grim & slurp**: Screenshot tools
- **hyprpaper**: Wallpaper manager
- **blueman**: Bluetooth manager
- **pamixer & pavucontrol**: Audio control
- **btop**: System monitor
- **nwg-displays**: Display configuration

### Development Tools
- Rust & Cargo
- Go
- Various development libraries (GTK4, Wayland, Cairo, etc.)

## Configuration Files

The script deploys the following configurations from the `configs/` directory:

```
~/.config/hypr/hyprland.conf       # Main Hyprland configuration
~/.config/waybar/config.jsonc      # Waybar configuration
~/.config/waybar/style.css         # Waybar styling
~/.config/wlogout/layout           # Power menu layout
~/.config/wlogout/style.css        # Power menu styling
~/.config/kitty/kitty.conf         # Kitty terminal config
~/bin/*.sh                         # Custom utility scripts
```

## Project Structure

```
hyprland-setup/
├── setup.sh                       # Main orchestrator script
├── dependencies/                  # Component installation scripts
│   ├── hyprland-setup.sh         # Core Hyprland packages
│   ├── elephant-setup.sh         # Elephant component
│   ├── walker-setup.sh           # Walker launcher
│   ├── waybar-setup.sh           # Waybar setup
│   ├── configs-setup.sh          # Dotfiles deployment
│   └── system-setup.sh           # System configuration
└── configs/                       # Backed-up dotfiles
    ├── hypr/                     # Hyprland configs
    ├── waybar/                   # Waybar configs
    ├── wlogout/                  # Power menu configs
    ├── kitty/                    # Terminal configs
    └── bin/                      # Custom utility scripts
```

## Custom Scripts

Located in `configs/bin/`:
- `gs.sh` - Git status utility
- `network-wired.sh` - Network status monitor
- `sonarrq.sh` - Sonarr integration
- `stocktick.sh` - Stock ticker display

## Key Bindings

Check `~/.config/hypr/hyprland.conf` after installation for your custom keybindings.

Power menu: Press physical power button or `Super+Escape`

## Customization

To customize your setup:

1. Modify files in the `configs/` directory
2. Edit individual setup scripts in `dependencies/` to add/remove packages
3. Commit changes to version control
4. Re-run `./setup.sh` to apply updates

## Troubleshooting

**Script fails on non-Fedora systems:**
You'll be prompted to continue anyway. Proceed at your own risk.

**Missing configuration files:**
The script will show warnings for any missing files but continue installation.

**Permission errors:**
Ensure you have sudo privileges and the script is executable (`chmod +x setup.sh`).

## Backup

Before running this script on an existing system, consider backing up your current configurations:

```bash
cp -r ~/.config/hypr ~/.config/hypr.backup
cp -r ~/.config/waybar ~/.config/waybar.backup
cp -r ~/.config/kitty ~/.config/kitty.backup
```

## Contributing

Feel free to fork and customize for your own setup. This is a personal configuration repository.

## License

Personal use configuration files.
