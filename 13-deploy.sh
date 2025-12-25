#!/bin/bash
# deploy.sh - Deploy dotfiles, scripts, and wallpapers

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo "============================================"
echo "Deploying dotfiles and configs"
echo "============================================"
echo ""

# Deploy dotfiles to ~/.config
log "Deploying dotfiles to ~/.config..."
if [ -d "$SCRIPT_DIR/dotfiles" ]; then
    mkdir -p "$HOME/.config"
    
    # Deploy directories
    for dir in "$SCRIPT_DIR/dotfiles"/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            
            if [ -d "$HOME/.config/$dirname" ]; then
                warn "~/.config/$dirname already exists, backing up"
                mv "$HOME/.config/$dirname" "$HOME/.config/$dirname.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            
            cp -r "$dir" "$HOME/.config/"
            log "Copied $dirname/ to ~/.config/"
        fi
    done
    
    # Deploy individual files (like starship.toml)
    for file in "$SCRIPT_DIR/dotfiles"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            
            if [ -f "$HOME/.config/$filename" ]; then
                warn "~/.config/$filename already exists, backing up"
                mv "$HOME/.config/$filename" "$HOME/.config/$filename.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            
            cp "$file" "$HOME/.config/"
            log "Copied $filename to ~/.config/"
        fi
    done
else
    warn "No dotfiles directory found, skipping..."
fi

# Deploy LibreWolf user.js to all profiles
log "Deploying LibreWolf configuration..."
if [ -f "$SCRIPT_DIR/dotfiles/librewolf/user.js" ]; then
    if pacman -Q librewolf &>/dev/null; then
        # Start LibreWolf to create profile if needed
        if [ ! -d "$HOME/.librewolf" ]; then
            log "Starting LibreWolf to create profile..."
            librewolf --headless &
            LIBREWOLF_PID=$!
            sleep 3
            kill $LIBREWOLF_PID 2>/dev/null || true
            wait $LIBREWOLF_PID 2>/dev/null || true
        fi
        
        # Find all profile directories
        for profile in "$HOME/.librewolf"/*.default*; do
            if [ -d "$profile" ]; then
                profile_name=$(basename "$profile")
                cp "$SCRIPT_DIR/dotfiles/librewolf/user.js" "$profile/"
                log "Deployed user.js to LibreWolf profile: $profile_name"
            fi
        done
    else
        warn "LibreWolf not installed, skipping user.js deployment"
    fi
else
    warn "No LibreWolf user.js found in dotfiles, skipping..."
fi

# Deploy MPD playlists
log "Deploying MPD playlists..."
if [ -d "$SCRIPT_DIR/dotfiles/mpd/playlists" ]; then
    mkdir -p "$HOME/.mpd/playlists"
    cp "$SCRIPT_DIR/dotfiles/mpd/playlists"/*.m3u "$HOME/.mpd/playlists/"
    log "Deployed MPD playlists to ~/.mpd/playlists/"
    
    # Update MPD database if it's running
    if systemctl --user is-active mpd &>/dev/null; then
        mpc update &>/dev/null || true
        log "Updated MPD database"
    fi
    
    # Enable mpd-mpris for playerctl integration
    if pacman -Q mpd-mpris &>/dev/null; then
        systemctl --user enable --now mpd-mpris &>/dev/null || true
        log "Enabled mpd-mpris for media key support"
    fi
else
    warn "No MPD playlists found in dotfiles, skipping..."
fi

# Deploy Samba configuration
log "Deploying Samba configuration..."
if [ -f "$SCRIPT_DIR/dotfiles/smb.conf" ]; then
    if pacman -Q samba &>/dev/null; then
        sudo cp "$SCRIPT_DIR/dotfiles/smb.conf" /etc/samba/smb.conf
        log "Deployed smb.conf to /etc/samba/"
        warn "Don't forget to set Samba password with: sudo smbpasswd -a $USER"
    else
        warn "Samba not installed, skipping smb.conf deployment"
    fi
else
    warn "No smb.conf found in dotfiles, skipping..."
fi

# Deploy bin scripts to ~/bin
log "Deploying scripts to ~/bin..."
if [ -d "$SCRIPT_DIR/bin" ]; then
    mkdir -p "$HOME/bin"
    
    # Deploy .sh scripts
    for script in "$SCRIPT_DIR/bin"/*.sh; do
        if [ -f "$script" ]; then
            scriptname=$(basename "$script")
            
            # Skip backup files
            if [[ "$scriptname" == *.bak ]]; then
                continue
            fi
            
            if [ -f "$HOME/bin/$scriptname" ]; then
                warn "$scriptname already exists in ~/bin, backing up"
                mv "$HOME/bin/$scriptname" "$HOME/bin/$scriptname.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            
            cp "$script" "$HOME/bin/"
            chmod +x "$HOME/bin/$scriptname"
            log "Copied $scriptname to ~/bin/"
        fi
    done
    
    # Deploy keybinds.MD
    if [ -f "$SCRIPT_DIR/bin/keybinds.MD" ]; then
        cp "$SCRIPT_DIR/bin/keybinds.MD" "$HOME/bin/"
        log "Copied keybinds.MD to ~/bin/"
    fi
    
    # Ensure ~/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        warn "~/bin is not in your PATH"
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
            log "Added ~/bin to PATH in .bashrc"
            warn "Run 'source ~/.bashrc' or restart shell to update PATH"
        fi
    fi
else
    warn "No bin directory found, skipping..."
fi

# Deploy wallpapers to ~/Pictures
log "Deploying wallpapers to ~/Pictures..."
if [ -d "$SCRIPT_DIR/Pictures" ]; then
    mkdir -p "$HOME/Pictures"
    
    if [ -d "$HOME/Pictures/Wallpapers" ]; then
        warn "~/Pictures/Wallpapers already exists, backing up"
        mv "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Wallpapers.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp -r "$SCRIPT_DIR/Pictures/Wallpapers" "$HOME/Pictures/"
    log "Copied Wallpapers to ~/Pictures/"
    
    wallpaper_count=$(find "$HOME/Pictures/Wallpapers" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) 2>/dev/null | wc -l)
    log "Deployed $wallpaper_count wallpapers"
else
    warn "No Pictures directory found, skipping..."
fi

# Detect and set default browser in variables.conf
log "Detecting installed browser..."
BROWSER=""
if pacman -Q firefox &>/dev/null; then
    BROWSER="firefox"
    log "Detected Firefox - setting as default browser"
elif pacman -Q librewolf &>/dev/null; then
    BROWSER="librewolf"
    log "Detected LibreWolf - setting as default browser"
else
    warn "No browser detected (firefox or librewolf), keeping variables.conf as-is"
fi

if [ -n "$BROWSER" ]; then
    if [ -f "$HOME/.config/hypr/variables.conf" ]; then
        sed -i "s|^\$browser = .*|\$browser = $BROWSER|" "$HOME/.config/hypr/variables.conf"
        log "Updated \$browser in variables.conf to: $BROWSER"
    else
        warn "~/.config/hypr/variables.conf not found, cannot set browser"
    fi
fi

echo ""
echo "============================================"
echo "Deployment complete!"
echo "============================================"
echo ""
echo "Summary:"
echo "- Dotfiles deployed to ~/.config/"
echo "- Scripts deployed to ~/bin/"
echo "- Wallpapers deployed to ~/Pictures/Wallpapers/"
echo ""
echo "Next steps:"
echo "1. Reload Hyprland config: hyprctl reload"
echo "2. If using hypr-random-wallpaper.sh, add to hyprland autostart:"
echo "   exec-once = $HOME/bin/hypr-random-wallpaper.sh"
echo ""
