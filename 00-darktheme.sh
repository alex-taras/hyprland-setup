#!/bin/bash
# darktheme.sh - System-wide Gruvbox theme setup for GTK, Qt, and KDE apps

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log "Installing theme dependencies..."
if ! rpm -q sassc kvantum kvantum-qt6 qt5ct qt6ct &>/dev/null; then
    sudo dnf install -y sassc kvantum kvantum-qt6 qt5ct qt6ct
else
    log "Theme dependencies already installed"
fi

# Install Gruvbox GTK Theme
log "Installing Gruvbox GTK Theme (Medium Dark Orange)..."
if [ ! -d ~/.themes/Gruvbox-Orange-Dark-Medium ]; then
    cd /tmp
    if [ ! -d /tmp/Gruvbox-GTK-Theme ]; then
        git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git
    fi
    cd /tmp/Gruvbox-GTK-Theme/themes
    ./install.sh -t orange -c dark -s standard --tweaks medium -l
    log "Gruvbox GTK theme installed"
else
    log "Gruvbox GTK theme already installed"
fi

# Install Gruvbox Kvantum Theme
log "Installing Gruvbox Kvantum Theme..."
if [ ! -d ~/.config/Kvantum/gruvbox-kvantum ]; then
    cd /tmp
    if [ ! -d /tmp/Gruvbox-Kvantum ]; then
        git clone https://github.com/TheSerphh/Gruvbox-Kvantum.git
    fi
    mkdir -p ~/.config/Kvantum
    cp -r /tmp/Gruvbox-Kvantum/gruvbox-kvantum ~/.config/Kvantum/
    log "Gruvbox Kvantum theme installed"
else
    log "Gruvbox Kvantum theme already installed"
fi

# Install Gruvbox Icon Pack
log "Installing Gruvbox Icon Pack..."
mkdir -p ~/.local/share/icons
if [ ! -d ~/.local/share/icons/Gruvbox-Plus-Dark ]; then
    cd /tmp
    unzip -q "$SCRIPT_DIR/themes/gruvbox-plus-icon-pack-6.3.0.zip" -d /tmp/
    cp -r /tmp/Gruvbox-Plus-Dark ~/.local/share/icons/
    rm -rf /tmp/Gruvbox-Plus-Dark /tmp/Gruvbox-Plus-Light
    log "Gruvbox icon pack installed"
else
    log "Gruvbox icon pack already installed"
fi

# Configure icon folder colors
log "Configuring icon folder colors (gold)..."
if [ ! -d ~/work/gruvbox-plus-icon-pack ]; then
    mkdir -p ~/work
    cd ~/work
    git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git
    log "Gruvbox icon pack repo cloned"
fi

cd ~/work/gruvbox-plus-icon-pack/scripts
./folders-color-chooser -c gold
log "Icon folder colors set to gold"

# Configure GTK 2.0
log "Configuring GTK 2.0..."
mkdir -p ~/.config/gtk-2.0
cat > ~/.config/gtk-2.0/gtkrc <<'EOF'
gtk-font-name="CaskaydiaMono Nerd Font 14"
EOF

# Configure GTK 3.0
log "Configuring GTK 3.0..."
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-theme-name=Gruvbox-Orange-Dark-Medium
gtk-icon-theme-name=Gruvbox-Plus-Dark
gtk-font-name=CaskaydiaMono Nerd Font 14
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=1
EOF

# Configure GTK 4.0
log "Configuring GTK 4.0..."
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<'EOF'
[Settings]
gtk-font-name=CaskaydiaMono Nerd Font 14
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

# Apply GTK theme via gsettings
log "Applying GTK theme via gsettings..."
gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Orange-Dark-Medium"
gsettings set org.gnome.desktop.interface icon-theme "Gruvbox-Plus-Dark"
gsettings set org.gnome.desktop.interface font-name "CaskaydiaMono Nerd Font 14"
gsettings set org.gnome.desktop.interface monospace-font-name "CaskaydiaMono Nerd Font Mono 14"

# Configure Kvantum
log "Configuring Kvantum..."
mkdir -p ~/.config/Kvantum
cat > ~/.config/Kvantum/kvantum.conf <<'EOF'
[General]
theme=gruvbox-kvantum
EOF

# Configure Qt5ct
log "Configuring Qt5ct..."
mkdir -p ~/.config/qt5ct
cat > ~/.config/qt5ct/qt5ct.conf <<'EOF'
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=Gruvbox-Plus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed="CaskaydiaMono Nerd Font Mono,14,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="CaskaydiaMono Nerd Font,14,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray()

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF

# Configure Qt6ct
log "Configuring Qt6ct..."
mkdir -p ~/.config/qt6ct
cat > ~/.config/qt6ct/qt6ct.conf <<'EOF'
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=Gruvbox-Plus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed="CaskaydiaMono Nerd Font Mono,14,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="CaskaydiaMono Nerd Font,14,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray()

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF

# Create Gruvbox KDE Color Scheme
log "Creating Gruvbox KDE Color Scheme..."
mkdir -p ~/.local/share/color-schemes
cat > ~/.local/share/color-schemes/GruvboxDark.colors <<'EOF'
[ColorEffects:Disabled]
Color=56,54,53
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=60,56,54
BackgroundNormal=60,56,54
DecorationFocus=214,93,14
DecorationHover=214,93,14
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:Selection]
BackgroundAlternate=102,92,84
BackgroundNormal=214,93,14
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=251,241,199
ForegroundInactive=235,219,178
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=251,241,199
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:Tooltip]
BackgroundAlternate=40,40,40
BackgroundNormal=40,40,40
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:View]
BackgroundAlternate=40,40,40
BackgroundNormal=29,32,33
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:Window]
BackgroundAlternate=60,56,54
BackgroundNormal=40,40,40
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[General]
ColorScheme=GruvboxDark
Name=Gruvbox Dark
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=40,40,40
activeBlend=235,219,178
activeForeground=235,219,178
inactiveBackground=29,32,33
inactiveBlend=146,131,116
inactiveForeground=146,131,116
EOF

# Configure KDE to use Gruvbox colors
log "Configuring KDE (kdeglobals) with Gruvbox colors..."
cat > ~/.config/kdeglobals <<'EOF'
[General]
ColorScheme=GruvboxDark

[Colors:Button]
BackgroundAlternate=60,56,54
BackgroundNormal=60,56,54
DecorationFocus=214,93,14
DecorationHover=214,93,14
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:Selection]
BackgroundAlternate=102,92,84
BackgroundNormal=214,93,14
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=251,241,199
ForegroundInactive=235,219,178
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=251,241,199
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:Tooltip]
BackgroundAlternate=40,40,40
BackgroundNormal=40,40,40
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:View]
BackgroundAlternate=40,40,40
BackgroundNormal=29,32,33
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[Colors:Window]
BackgroundAlternate=60,56,54
BackgroundNormal=40,40,40
DecorationFocus=214,93,14
DecorationHover=215,153,33
ForegroundActive=215,153,33
ForegroundInactive=146,131,116
ForegroundLink=131,165,152
ForegroundNegative=251,73,52
ForegroundNeutral=250,189,47
ForegroundNormal=235,219,178
ForegroundPositive=184,187,38
ForegroundVisited=177,98,134

[WM]
activeBackground=40,40,40
activeBlend=235,219,178
activeForeground=235,219,178
inactiveBackground=29,32,33
inactiveBlend=146,131,116
inactiveForeground=146,131,116
EOF

# Configure Nemo file manager
log "Configuring Nemo file manager..."
# Ignore per-directory view metadata (use universal settings)
gsettings set org.nemo.preferences ignore-view-metadata true
# Set default zoom levels to 'large' for consistent sizing
gsettings set org.nemo.icon-view default-zoom-level 'large'
gsettings set org.nemo.list-view default-zoom-level 'large'
# Clear existing per-directory metadata
rm -rf ~/.local/share/nemo/metafiles 2>/dev/null || true
log "Nemo configured with universal sizing (large zoom)"

log "Gruvbox theme configured for GTK, Qt, and KDE applications!"
log "NOTE: Restart applications (or logout/login) to apply theme changes."
log ""
log "Configured:"
log "  - GTK 3/4: Gruvbox-Orange-Dark-Medium theme"
log "  - Qt 5/6: Kvantum with gruvbox-kvantum theme"
log "  - KDE: GruvboxDark color scheme"
log "  - Icons: Gruvbox-Plus-Dark"
log "  - Fonts: CaskaydiaMono Nerd Font 14 (UI & monospace)"
log "  - Nemo: Universal large sizing (no per-directory zoom)"
