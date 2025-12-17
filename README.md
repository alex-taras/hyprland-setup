# Arch Linux Post-Install Setup

Automated setup scripts for a complete Arch Linux desktop environment with Hyprland, CachyOS kernel, and custom configurations.

## Overview

This repository contains modular installation scripts that set up a complete Arch Linux system with:

- **CachyOS kernel** - Optimized Linux kernel with performance improvements
- **Hyprland** - Modern Wayland compositor
- **Custom TUI tools** - Terminal-based system management tools
- **Gaming stack** - Steam, Lutris, Proton-GE, and performance overlays
- **Development tools** - VSCode, Neovim, Go, Python, Ruby, and more
- **Dotfiles deployment** - Automated configuration file deployment

## Quick Start

### Initial Installation

```bash
# Clone the repository
git clone <your-repo-url> ~/archsetup
cd ~/archsetup

# Run the main installer
bash install.sh
```

The installer will:
1. Install CachyOS repositories and kernel
2. Configure Limine bootloader automatically
3. Prompt you to reboot

### After Reboot

```bash
# Continue the installation after rebooting to CachyOS kernel
cd ~/archsetup
bash install.sh --continue
```

This will install and configure:
- AUR helper (paru)
- General applications
- Hyprland and ecosystem tools
- Display manager (greetd + sysc-greet-hyprland)
- Shell customization (starship)
- Gaming packages
- Development tools
- IO/TUI utilities
- Your dotfiles, scripts, and wallpapers

## Installation Scripts

### Core Scripts

| Script | Description |
|--------|-------------|
| `install.sh` | Main installer that orchestrates all other scripts |
| `base.sh` | Sets up SSH and CachyOS repositories |
| `bootloader.sh` | Automatically configures Limine bootloader for CachyOS kernel |
| `aur.sh` | Installs build tools and paru AUR helper |

### Feature Scripts

| Script | Description | Key Packages |
|--------|-------------|--------------|
| `apps.sh` | General desktop applications | Firefox, Nemo, LibreOffice, Zathura, fonts, codecs |
| `hyprland.sh` | Hyprland window manager and ecosystem | Waybar, Hypridle, Walker, Gum, Swww, Hyprshot |
| `greeter.sh` | Display manager setup | greetd, sysc-greet-hyprland |
| `shell.sh` | Shell customization | Starship prompt with Catppuccin theme |
| `gaming.sh` | Gaming environment | Steam, Lutris, Gamescope, MangoHud, Wine, Proton-GE |
| `dev.sh` | Development tools | VSCode, Neovim, Go, Python, Ruby, DOSBox |
| `tools.sh` | IO and TUI utilities | Pacseek, Wiremix, Bluetuith, Impala, btop, ncdu, UFW |
| `deploy.sh` | Deploys dotfiles, scripts, and wallpapers | Copies configs to ~/.config, ~/bin, ~/Pictures |

## Custom Scripts (bin/)

The `bin/` directory contains custom utility scripts that are deployed to `~/bin/`:

| Script | Description |
|--------|-------------|
| `sysmenu.sh` | TUI system menu with power options and AUR package manager |
| `random-wallpaper.sh` | Randomly selects and sets wallpaper from ~/Pictures/Wallpapers |
| `config.sh` | Quick access to edit common config files |
| `gs.sh` | Git status wrapper with additional features |
| `sonarrq.sh` | Sonarr API interaction tool |
| `stocktick.sh` | Stock ticker display utility |

### System Menu

The `sysmenu.sh` provides a centered TUI menu with:
- **AUR** - Opens pacseek in a new tiled terminal window
- **Shutdown** - Power off the system
- **Reboot** - Restart the system
- **Logout** - Exit current session
- **Cancel** - Close menu

All power actions require confirmation before executing.

## Directory Structure

```
archsetup/
├── install.sh          # Main installer
├── base.sh             # CachyOS setup
├── bootloader.sh       # Limine configuration
├── aur.sh              # AUR helper
├── apps.sh             # Applications
├── hyprland.sh         # Hyprland ecosystem
├── greeter.sh          # Display manager
├── shell.sh            # Shell customization
├── gaming.sh           # Gaming stack
├── dev.sh              # Development tools
├── tools.sh            # IO/TUI utilities
├── deploy.sh           # Dotfiles deployment
├── bin/                # Custom scripts
│   ├── sysmenu.sh
│   ├── random-wallpaper.sh
│   ├── config.sh
│   ├── gs.sh
│   ├── sonarrq.sh
│   └── stocktick.sh
├── dotfiles/           # Configuration files
│   ├── hypr/
│   ├── kitty/
│   ├── waybar/
│   └── starship.toml
└── Pictures/
    └── Wallpapers/     # Wallpaper collection
```

## Key Features

### CachyOS Kernel
- Performance-optimized Linux kernel
- Automatic repository setup
- Automatic Limine bootloader configuration
- Detects filesystem type and btrfs subvolumes automatically

### Hyprland Ecosystem
- **Waybar** - Status bar
- **Starship** - Cross-shell prompt with Catppuccin theme
- **Hypridle** - Idle daemon (wallpaper screensaver at 5min, screen off at 10min)
- **Walker** - Application launcher
- **Gum** - TUI components for scripts
- **Swww** - Wallpaper daemon
- **Hyprshot** - Screenshot tool
- **Cliphist** - Clipboard manager

### TUI Tools
- **Pacseek** - Package manager with TUI
- **Wiremix** - PipeWire audio mixer
- **Bluetuith** - Bluetooth manager
- **Impala** - WiFi manager
- **btop** - System monitor
- **ncdu** - Disk usage analyzer

### Quality of Life CLI Tools
- **ripgrep (rg)** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls replacement
- **fzf** - Fuzzy finder
- **zoxide** - Smart cd command

### Firewall
- **UFW** - Uncomplicated Firewall, automatically enabled and started
  - Check status: `sudo ufw status`
  - Allow ports: `sudo ufw allow <port>`
  - For Waydroid: Firewall is pre-configured to allow necessary traffic

## Configuration

### Hypridle Configuration

Automatically generated at `~/.config/hypr/hypridle.conf`:

```
listener {
    timeout = 300  # 5 minutes
    on-timeout = $HOME/bin/random-wallpaper.sh
}

listener {
    timeout = 600  # 10 minutes
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
```

### Hyprland Autostart Recommendations

Add to your `~/.config/hypr/hyprland.conf`:

```
exec-once = swww-daemon
exec-once = hypridle
exec-once = wl-paste --watch cliphist store
exec-once = $HOME/bin/random-wallpaper.sh
```

### Display Manager

greetd with sysc-greet-hyprland is configured to launch Hyprland automatically. The sysc-greet-hyprland package handles the greetd configuration and provides a graphical console greeter with ASCII art and themes for Hyprland sessions.

## Gaming

The gaming stack includes:
- **Steam** - Game platform
- **Lutris** - Game launcher and manager
- **Gamescope** - Gaming-focused Wayland compositor
- **MangoHud** - Performance overlay
- **GameMode** - System optimizations for gaming
- **Wine-staging** - Windows compatibility layer
- **ProtonUp-Qt** - Manage Proton-GE versions

Run `protonup-qt` to install Proton-GE for enhanced game compatibility.

## Development

Installed languages and tools:
- **Rust** (via base-devel)
- **Go**
- **Python** + pip
- **Ruby**
- **VSCode** - Set as default text editor for all common file types
- **Neovim**
- **DOSBox Staging** - For retro development/gaming

VSCode is automatically configured as the default application for:
- Plain text files (.txt, .log)
- Source code (.py, .sh, .c, .cpp, .h)
- Configuration files (.json, .yaml, .xml, .toml)
- Documentation (.md, Makefile)

## Deployment

The `deploy.sh` script automatically:

1. **Deploys dotfiles** to `~/.config/`
   - Backs up existing configs with timestamp
   - Copies all directories and files from `dotfiles/`

2. **Deploys scripts** to `~/bin/`
   - Makes all scripts executable
   - Adds `~/bin` to PATH if not already present
   - Backs up existing scripts

3. **Deploys wallpapers** to `~/Pictures/Wallpapers/`
   - Copies entire wallpaper collection
   - Reports count of deployed wallpapers

All existing files are backed up with timestamps before deployment.

## Troubleshooting

### Bootloader Issues

If the CachyOS kernel doesn't boot:
1. Check `/boot/EFI/arch-limine/limine.conf`
2. Backup is saved as `limine.conf.backup.*`
3. Verify PARTUUID matches your root partition: `lsblk -o NAME,PARTUUID`

### Display Manager Issues

If greetd doesn't start:
```bash
sudo systemctl status greetd
sudo journalctl -u greetd
```

### AUR Package Build Failures

If paru fails to build packages:
```bash
# Ensure base-devel is installed
sudo pacman -S --needed base-devel

# Clean paru cache and retry
paru -Sc
```

### Path Issues

If `~/bin` scripts aren't found after deployment:
```bash
# Reload your shell
exec bash

# Or source .bashrc
source ~/.bashrc
```

## Post-Installation

After installation completes:

1. **Reload Hyprland config**: `hyprctl reload`
2. **Choose Kitty theme**: `kitty +kitten themes` (if not using deployed config)
3. **Customize GTK theme**: Run `nwg-look`
4. **Install Proton-GE**: Run `protonup-qt`
5. **Configure GPU (AMD)**: Run `lact` for GPU control
6. **Set up Neovim**: Add Lazyvim or your preferred config
7. **Customize dotfiles**: Edit files in `~/.config/` as needed

## Customization

### Adding Your Own Dotfiles

1. Place your configs in the `dotfiles/` directory
2. Run `bash deploy.sh` to deploy them
3. Existing configs will be backed up automatically

### Adding Custom Scripts

1. Place scripts in the `bin/` directory
2. Run `bash deploy.sh` to deploy them
3. Scripts will be made executable automatically

### Adding Wallpapers

1. Place images in `Pictures/Wallpapers/`
2. Run `bash deploy.sh` to deploy them
3. Use `random-wallpaper.sh` to set random wallpapers

## Requirements

- Fresh Arch Linux installation
- Limine bootloader (bootloader script is Limine-specific)
- Internet connection
- User with sudo privileges

## Notes

- All scripts use `set -e` to exit on errors
- Color-coded logging: green for info, yellow for warnings, red for errors
- Existing packages are detected to avoid reinstallation
- System services are enabled automatically where needed
- Multilib repository is enabled for gaming (32-bit support)

## License

This is a personal setup script. Use at your own risk. Feel free to fork and customize for your needs.

## Contributing

This is a personal setup, but suggestions and improvements are welcome. Open an issue or PR if you have ideas!
