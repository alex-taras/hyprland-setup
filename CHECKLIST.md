# Hyprland Setup - Important Changes & Maintenance Checklist

## Recent Major Updates (January 2026)

### 🔧 Hyprland 0.53 Breaking Changes
- [x] **New windowrule syntax** - Changed from regex patterns to `match:` syntax
  - Old: `windowrulev2 = float, class:^(floating-small)$`
  - New: `windowrule = float on, match:class floating-small`
  - All rules updated in `dotfiles/hypr/rules.conf`
  
- [x] **start-hyprland wrapper** - Hyprland now launches via wrapper for crash recovery
  - Updated `/usr/share/wayland-sessions/hyprland.desktop`
  - Updated `/etc/greetd/config.toml` to use `start-hyprland -- -c`
  - Provides automatic crash recovery and safe mode

### 🎨 Visual & Theming Updates

#### Transparency & Blur
- [x] **Window opacity** - `dotfiles/hypr/appearance.conf`
  - Active windows: `0.8` (20% transparency)
  - Inactive windows: `0.7` (30% transparency)
  - Blur enabled with vibrancy
  
- [x] **Kitty transparency** - `dotfiles/kitty/kitty.conf`
  - Background opacity: `0.95` (5% transparency)
  
- [x] **Waybar transparency** - `dotfiles/waybar/style.css`
  - Background: `rgba(29, 32, 33, 0.85)` (15% transparency)
  - Uses global blur from Hyprland (no layerrule needed)

#### Fonts
- [x] **Unified to CaskaydiaMono Nerd Font (14pt)**
  - GTK2, GTK3, GTK4
  - Qt5, Qt6
  - Kitty (16pt)
  - Waybar (18pt)
  - Rofi, Starship, Hyprlock
  - **Greeter**: sysc-greet kitty (14pt) - `/etc/greetd/kitty.conf`

#### Lock Screen (hyprlock)
- [x] **Weather & location display** - `dotfiles/hypr/hyprlock.conf`
  - Top of screen: Location and weather with Nerd Font icons
  - Uses `wttrbar --nerd` for cached data (instant display)
  - Format: Icon + temperature + °C (e.g., "󰖑 -3°C")
  - Location updates hourly, weather updates every minute

#### Waybar
- [x] **Weather icons** - `dotfiles/waybar/config.jsonc`
  - Changed from emoji to Nerd Font icons via `wttrbar --nerd`
  - Matches hyprlock icon style

### 🔐 LibreWolf Configuration
- [x] **Password manager enabled** - `dotfiles/librewolf/user.js`
  - `signon.rememberSignons = true`
  - `signon.generation.enabled = true` (password suggestions)
  - `signon.management.page.breach-alerts.enabled = true`
  - Must copy to `~/.librewolf/<profile>/user.js` after LibreWolf updates

### 🎵 Media & Tools

#### MPD/rmpc
- [x] **rmpc configuration** - `dotfiles/rmpc/config.ron`
  - 3-panel layout (AlbumArt, Queue, Cava)
  - Gruvbox theme with custom progress bar
  - Borders configured: LEFT, RIGHT, TOP
  
- [x] **Media key bindings** - `dotfiles/hypr/keybinds.conf`
  - Changed from `playerctl` to direct `mpc` commands
  - More reliable control

#### System Menu
- [x] **Update option added** - `bin/sys-menu.sh`
  - New menu item: "󰚰 Update"
  - Launches `kitty --class floating-medium -e ~/bin/sys-update.sh`
  - Wrapper script waits for keypress after `nobara-sync cli` completes
  - Access: `Super + Shift + Q` → Update

### 🌐 Network & Sharing

#### Samba Shares
- [x] **Configured in `05-tools.sh`**
  - Creates Samba user `alext` (prompts for password)
  - Share: `[DATA]` → `/mnt/DATA` (read/write, alext only)
  - Share: `[WORK]` → `/mnt/WORK` (read/write, alext only)
  - Services enabled: `smb`, `nmb`

#### File Manager
- [x] **Switched from Nemo to Nautilus**
  - Reason: Nemo cannot handle `network:///` protocol
  - Updated in `dotfiles/hypr/variables.conf`
  - Set xdg-mime defaults for directories

### 📦 Repository Structure
- [x] **Dotfiles path updated**
  - Changed from `../dotfiles` to `./dotfiles` in all scripts
  - Scripts and dotfiles are in same directory
  - Affects: `02-hyprland.sh`, `03-shell.sh`, `04-waybar.sh`, `05-tools.sh`, `06-browser.sh`

## ⚠️ Important Maintenance Tasks

### After System Updates

1. **Check Hyprland version**
   ```bash
   hyprland --version
   ```
   - Watch for breaking changes in window rules or layer rules
   - Check wiki: https://wiki.hypr.land/

2. **Verify start-hyprland wrapper**
   ```bash
   # Should NOT see warning about direct Hyprland launch
   # Check greeter config
   cat /etc/greetd/config.toml | grep start-hyprland
   ```

3. **LibreWolf user.js**
   - Check if profile was reset after update
   ```bash
   ls ~/.librewolf/*.default-default/user.js
   # If missing, redeploy:
   cp dotfiles/librewolf/user.js ~/.librewolf/<profile>/
   ```

4. **Test password suggestions in LibreWolf**
   - Visit a login form
   - Verify password manager offers to save/suggest

5. **Verify greeter configs** (if greetd updated)
   ```bash
   sudo diff /etc/greetd/config.toml dotfiles/greetd/config.toml
   sudo diff /etc/greetd/kitty.conf dotfiles/greetd/kitty.conf
   ```

### After Hyprland Updates

1. **Reload configuration**
   ```bash
   hyprctl reload
   ```

2. **Check for config errors**
   ```bash
   # Look for warnings/errors in hyprland logs
   journalctl --user -u hyprland -n 50
   ```

3. **Verify transparency and blur**
   - Check active/inactive window opacity
   - Verify Waybar blur effect
   - Check hyprlock weather display

### Regular Checks (Weekly)

1. **Sync dotfiles from live configs**
   ```bash
   # Repository dotfiles should match ~/.config
   cd ~/work/hyprland-setup
   # Compare and update if needed
   diff -r ~/.config/hypr/ dotfiles/hypr/
   diff -r ~/.config/waybar/ dotfiles/waybar/
   ```

2. **Backup Samba configuration**
   ```bash
   sudo cp /etc/samba/smb.conf dotfiles/smb.conf
   ```

3. **Test system update menu**
   - `Super + Shift + Q` → Update
   - Verify it completes and waits for keypress

## 🐛 Known Issues & Workarounds

### Media Keys
- **Issue**: Hardware media keys may not be detected by Hyprland
- **Status**: Switched from `playerctl` to direct `mpc` commands
- **Workaround**: Use Waybar MPD controls or keybinds work if detected

### Mesa/Freeworld Package Conflicts
- **Issue**: RPMFusion freeworld packages lag behind official repos by 1-2 days
- **Workaround**: Wait 1-2 days if `nobara-sync` reports Mesa conflicts
- **Tip**: Update every 2-3 days to catch smaller changes

### Kitty in Greeter
- **Important**: Greeter uses separate config at `/etc/greetd/kitty.conf`
- Must manually copy after changes: `sudo cp dotfiles/greetd/kitty.conf /etc/greetd/`

## 📝 Configuration Files to Watch

### System Files (require sudo)
- `/etc/greetd/config.toml` - Greeter session config
- `/etc/greetd/hyprland-greeter-config.conf` - Greeter Hyprland rules
- `/etc/greetd/kitty.conf` - Greeter terminal config
- `/etc/samba/smb.conf` - Samba shares

### User Configs (auto-deployed by scripts)
- `~/.config/hypr/*.conf` - Hyprland configuration
- `~/.config/waybar/*` - Status bar
- `~/.config/kitty/kitty.conf` - Terminal
- `~/.config/rmpc/config.ron` - MPD TUI client
- `~/.librewolf/<profile>/user.js` - Browser preferences

### Custom Scripts
- `~/bin/sys-menu.sh` - System menu with update option
- `~/bin/sys-update.sh` - Update wrapper for nobara-sync
- `~/bin/sys-keybind-help.sh` - Keybinding reference
- `~/bin/hypr-*.sh` - Various Hyprland utilities

## 🚀 Quick Recovery Commands

```bash
# Reload Hyprland config
hyprctl reload

# Restart Waybar
killall waybar; waybar &

# Restart MPD services
systemctl --user restart mpd mpdris2

# Redeploy all dotfiles
cd ~/work/hyprland-setup
bash 02-hyprland.sh  # Hyprland + Rofi
bash 03-shell.sh     # Kitty + Starship
bash 04-waybar.sh    # Waybar + MPD
bash 05-tools.sh     # TUI tools + rmpc

# Sync dotfiles to repository
cd ~/work/hyprland-setup
# Copy live configs to dotfiles/
git add dotfiles/
git commit -m "Sync from live configs"
git push
```

## 📚 References

- Hyprland Wiki: https://wiki.hypr.land/
- Window Rules (0.53+): https://wiki.hypr.land/Configuring/Window-Rules/
- Layer Rules: https://wiki.hypr.land/Configuring/Layer-Rules/
- Repository: https://github.com/alex-taras/hyprland-setup (fedora branch)

---

**Last Updated**: 2026-01-06
**Hyprland Version**: 0.53.1
**System**: Nobara 43 (Fedora-based)
