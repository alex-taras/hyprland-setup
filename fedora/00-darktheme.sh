#!/bin/bash
# darktheme.sh - System-wide dark theme setup for GTK, Qt, and KDE apps

set -e
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

log "Setting GTK dark theme..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

mkdir -p ~/.config/gtk-3.0
if grep -q "gtk-application-prefer-dark-theme" ~/.config/gtk-3.0/settings.ini 2>/dev/null; then
    log "GTK3 dark theme already set"
else
    echo "[Settings]" >> ~/.config/gtk-3.0/settings.ini
    echo "gtk-application-prefer-dark-theme=1" >> ~/.config/gtk-3.0/settings.ini
fi

mkdir -p ~/.config/gtk-4.0
if grep -q "gtk-application-prefer-dark-theme" ~/.config/gtk-4.0/settings.ini 2>/dev/null; then
    log "GTK4 dark theme already set"
else
    echo "[Settings]" >> ~/.config/gtk-4.0/settings.ini
    echo "gtk-application-prefer-dark-theme=1" >> ~/.config/gtk-4.0/settings.ini
fi

log "Installing Qt theme tools..."
if rpm -q kvantum qt6ct &>/dev/null; then
    log "Qt theme tools already installed"
else
    sudo dnf install -y kvantum qt6ct
fi

log "Configuring qt6ct for dark theme..."
mkdir -p ~/.config/qt6ct
cat > ~/.config/qt6ct/qt6ct.conf <<EOF
[Appearance]
color_scheme_path=/usr/share/qt6ct/colors/darker.conf
style=kvantum-dark

[Fonts]
general=@Variant(\0\0\0@\0\0\0\x1a\0\x43\0\x61\0s\0k\0\x61\0y\0\x64\0i\0\x61\0M\0o\0n\0o@(\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
EOF

log "Configuring KDE dark theme (for Discover, etc)..."
cat > ~/.config/kdeglobals <<'EOF'
[General]
ColorScheme=BreezeDark

[Colors:Button]
BackgroundAlternate=30,87,116
BackgroundNormal=49,54,59
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=161,169,177
ForegroundLink=29,153,243
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Selection]
BackgroundAlternate=30,87,116
BackgroundNormal=61,174,233
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=252,252,252
ForegroundInactive=161,169,177
ForegroundLink=253,188,75
ForegroundNegative=176,55,69
ForegroundNeutral=198,92,0
ForegroundNormal=252,252,252
ForegroundPositive=23,104,57
ForegroundVisited=155,89,182

[Colors:Tooltip]
BackgroundAlternate=42,46,50
BackgroundNormal=35,38,41
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=161,169,177
ForegroundLink=29,153,243
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:View]
BackgroundAlternate=35,38,41
BackgroundNormal=27,30,32
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=161,169,177
ForegroundLink=29,153,243
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Window]
BackgroundAlternate=49,54,59
BackgroundNormal=42,46,50
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=161,169,177
ForegroundLink=29,153,243
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[WM]
activeBackground=42,46,50
activeBlend=252,252,252
activeForeground=252,252,252
inactiveBackground=42,46,50
inactiveBlend=161,169,177
inactiveForeground=161,169,177
EOF

log "Dark theme configured for GTK, Qt, and KDE applications!"
log "Restart applications to apply the theme changes."
