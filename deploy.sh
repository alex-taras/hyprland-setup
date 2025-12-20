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

# Deploy bin scripts to ~/bin
log "Deploying scripts to ~/bin..."
if [ -d "$SCRIPT_DIR/bin" ]; then
    mkdir -p "$HOME/bin"
    
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
