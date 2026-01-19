# Theme Manager System

This Hyprland setup includes a comprehensive theme manager that allows you to switch colors and fonts across all applications with a single command.

## Overview

The theme system uses:
- **Semantic color tokens** (bg, fg, accent, active, inactive, etc.)
- **Centralized theme definitions** in `~/themes/*.conf`
- **Template-based config generation** for each application
- **Automatic reload** for applications that support it

## Available Themes

### Gruvbox (Default)
- **Accent**: Warm orange (#d65d0e)
- **Font**: CaskaydiaMono Nerd Font
- **Style**: Warm, earthy tones with high contrast

### Nord
- **Accent**: Cool cyan (#88c0d0)
- **Font**: JetBrainsMono Nerd Font
- **Style**: Cool, arctic-inspired pastel colors

### Catppuccin Mocha
- **Accent**: Mauve/purple (#cba6f7)
- **Font**: FiraCode Nerd Font
- **Style**: Pastel colors with soft contrast

## Quick Start

### Switch Theme Interactively
```bash
~/bin/theme-switcher.sh
```

This opens a gum-based menu showing all available themes with the current theme marked.

### Switch Theme Directly
```bash
~/bin/theme-switcher.sh nord
~/bin/theme-switcher.sh gruvbox
~/bin/theme-switcher.sh catppuccin-mocha
```

### Check Current Theme
```bash
cat ~/.config/hypr/current-theme
```

## What Gets Themed

The theme system applies colors and fonts to:

### ✅ Auto-reload (instant changes)
- **Waybar** - Status bar colors and fonts
- **Hyprland** - Window borders, shadows, gaps
- **Kitty** - Terminal colors and fonts (new windows)

### 🔄 Restart Required
- **Starship** - Shell prompt colors (next shell session)
- **GTK 3/4** - Application themes and fonts (restart apps)
- **Qt 5/6** - Application themes and fonts (restart apps)
- **Hyprlock** - Lock screen colors and fonts (next lock)

## Theme File Structure

### Location
- **Source**: `themes/*.conf` in repo
- **Deployed**: `~/themes/*.conf` on system

### Format
```bash
# Background colors (darkest to lightest)
bg0="#1d2021"
bg1="#282828"
bg2="#3c3836"
bg3="#504945"

# Foreground colors (lightest to darkest)
fg0="#fbf1c7"
fg1="#ebdbb2"
fg2="#d5c4a1"
fg3="#bdae93"

# Semantic colors
accent="#d65d0e"          # Primary accent
accent_light="#fe8019"    # Light variant
active="#d65d0e"          # Active/selected items
inactive="#665c54"        # Inactive items

# Status colors
critical="#cc241d"        # Errors
success="#98971a"         # Success
warning="#d79921"         # Warnings
info="#458588"            # Information

# Fonts
font_family="CaskaydiaMono Nerd Font"
font_family_mono="CaskaydiaMono Nerd Font Mono"
font_size="14"
font_size_small="11"
font_size_medium="16"
font_size_large="18"
font_size_xlarge="24"
font_size_xxlarge="32"
```

## Creating a New Theme

1. **Create theme file**:
   ```bash
   cp ~/themes/gruvbox.conf ~/themes/my-theme.conf
   ```

2. **Edit colors and fonts**:
   ```bash
   nano ~/themes/my-theme.conf
   ```

   Update the hex color values and font names.

3. **Test the theme**:
   ```bash
   ~/bin/theme-switcher.sh my-theme
   ```

4. **Share it** (optional):
   Copy your theme file to the repo's `themes/` directory and submit a PR.

## Theme Generators

The system uses generator scripts to create application configs from theme definitions:

### `generate-waybar-theme.sh`
Generates:
- `~/.config/waybar/palette.css` - Color definitions
- `~/.config/waybar/style.css` - CSS with font variables

Auto-reloads waybar via `pkill -SIGUSR2 waybar`

### `generate-kitty-theme.sh`
Generates:
- `~/.config/kitty/current-theme.conf` - Colors and fonts

Applies to new kitty windows via `pkill -USR1 kitty`

### `generate-starship-theme.sh`
Generates:
- `~/.config/starship.toml` - Prompt colors

Takes effect in next shell session

### `generate-hyprland-theme.sh`
Generates:
- `~/.config/hypr/appearance.conf` - Border colors, shadows
- `~/.config/hypr/hyprlock.conf` - Lock screen colors

Reloads via `hyprctl reload`

### `generate-gtk-qt-fonts.sh`
Updates:
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-4.0/settings.ini`
- `~/.config/gtk-2.0/gtkrc`
- `~/.config/qt5ct/qt5ct.conf`
- `~/.config/qt6ct/qt6ct.conf`
- `gsettings` for system-wide fonts

Requires restarting GTK/Qt applications

## Templates

Generator scripts use templates with placeholder variables:

### Example: waybar style.css.template
```css
* {
  font-family: '{{FONT_FAMILY}}';
  font-size: {{FONT_SIZE_LARGE}}px;
}
```

### Example: hyprland appearance.conf.template
```
col.active_border = {{ACTIVE_BORDER_1}} {{ACTIVE_BORDER_2}} 45deg
col.inactive_border = {{INACTIVE_BORDER}}
```

Templates are stored in:
- `dotfiles/waybar/style.css.template`
- `dotfiles/hypr/appearance.conf.template`
- `dotfiles/hypr/hyprlock.conf.template`

## Installation

### Automatic (via setup scripts)
```bash
./07-apps.sh    # Deploys themes and scripts
./10-theming.sh # Generates initial configs
```

### Manual
```bash
# Copy themes
mkdir -p ~/themes
cp themes/*.conf ~/themes/

# Copy scripts
mkdir -p ~/bin
cp bin/generate-*.sh ~/bin/
cp bin/theme-switcher.sh ~/bin/
chmod +x ~/bin/*.sh

# Copy templates
cp dotfiles/waybar/style.css.template ~/.config/waybar/
cp dotfiles/hypr/*.template ~/.config/hypr/

# Generate initial theme
~/bin/theme-switcher.sh gruvbox
```

## Troubleshooting

### Theme doesn't apply
```bash
# Manually run generators
~/bin/generate-waybar-theme.sh gruvbox
~/bin/generate-kitty-theme.sh gruvbox
~/bin/generate-hyprland-theme.sh gruvbox

# Reload
pkill -SIGUSR2 waybar
hyprctl reload
```

### Script not found
```bash
# Ensure scripts are executable
chmod +x ~/bin/generate-*.sh
chmod +x ~/bin/theme-switcher.sh

# Check PATH
echo $PATH | grep -q "$HOME/bin" || export PATH="$HOME/bin:$PATH"
```

### Theme file missing
```bash
# Re-deploy themes
cp /path/to/hyprland-setup/themes/*.conf ~/themes/
```

### Colors wrong in GTK apps
```bash
# Regenerate GTK/Qt configs
~/bin/generate-gtk-qt-fonts.sh gruvbox

# Restart the application
```

## Keybindings

You can add a keybinding to open the theme switcher in `~/.config/hypr/keybinds.conf`:

```
# Theme switcher
bind = $mainMod SHIFT, T, exec, kitty --class floating-small -e ~/bin/theme-switcher.sh
```

Then reload Hyprland: `hyprctl reload`

## Architecture

```
themes/*.conf           # Color and font definitions
    ↓
generate-*-theme.sh     # Generator scripts
    ↓
dotfiles/*/*.template   # Config templates
    ↓
~/.config/*/config      # Generated configs
    ↓
Applications            # Themed apps
```

## Future Enhancements

Potential additions:
- [ ] Rofi theme generation
- [ ] nwg-dock color theming
- [ ] nwg-bar color theming
- [ ] Gum config generation
- [ ] GRUB theme switching
- [ ] Icon pack switching per theme
- [ ] Wallpaper selection per theme
- [ ] GTK theme switching (not just fonts)

## Contributing

To add a new theme:
1. Fork the repository
2. Create `themes/your-theme.conf` with all required variables
3. Test with `~/bin/theme-switcher.sh your-theme`
4. Submit a pull request

To add theme support for a new application:
1. Create a template in `dotfiles/app/config.template`
2. Create `bin/generate-app-theme.sh` generator script
3. Update `bin/theme-switcher.sh` to call your generator
4. Update this documentation

## Credits

- **Gruvbox** - Original theme by morhetz
- **Nord** - Original theme by Arctic Ice Studio
- **Catppuccin** - Original theme by Catppuccin Community
- **Theme System** - Built with Claude Sonnet 4.5
