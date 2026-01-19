#!/bin/bash

# Update GTK and Qt font settings from theme definition
# Usage: generate-gtk-qt-fonts.sh <theme-name>

THEME=${1:-gruvbox}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$(dirname "$SCRIPT_DIR")/themes"
THEME_FILE="$THEME_DIR/$THEME.conf"

if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

# Source the theme file
source "$THEME_FILE"

# Update GTK 3.0 settings
GTK3_DIR="$HOME/.config/gtk-3.0"
GTK3_FILE="$GTK3_DIR/settings.ini"
mkdir -p "$GTK3_DIR"

if [ -f "$GTK3_FILE" ]; then
    # Update font-name in existing file
    sed -i.bak "s/^gtk-font-name=.*/gtk-font-name=$font_family $font_size/" "$GTK3_FILE"
else
    # Create new file with font setting
    cat > "$GTK3_FILE" << EOF
[Settings]
gtk-font-name=$font_family $font_size
gtk-application-prefer-dark-theme=1
EOF
fi

# Update GTK 4.0 settings
GTK4_DIR="$HOME/.config/gtk-4.0"
GTK4_FILE="$GTK4_DIR/settings.ini"
mkdir -p "$GTK4_DIR"

if [ -f "$GTK4_FILE" ]; then
    sed -i.bak "s/^gtk-font-name=.*/gtk-font-name=$font_family $font_size/" "$GTK4_FILE"
else
    cat > "$GTK4_FILE" << EOF
[Settings]
gtk-font-name=$font_family $font_size
gtk-application-prefer-dark-theme=1
EOF
fi

# Update GTK 2.0 settings
GTK2_FILE="$HOME/.config/gtk-2.0/gtkrc"
mkdir -p "$(dirname "$GTK2_FILE")"

if [ -f "$GTK2_FILE" ]; then
    sed -i.bak "s/^gtk-font-name=.*/gtk-font-name=\"$font_family $font_size\"/" "$GTK2_FILE"
else
    cat > "$GTK2_FILE" << EOF
gtk-font-name="$font_family $font_size"
EOF
fi

# Update Qt5ct settings
QT5CT_DIR="$HOME/.config/qt5ct"
QT5CT_FILE="$QT5CT_DIR/qt5ct.conf"
mkdir -p "$QT5CT_DIR"

if [ -f "$QT5CT_FILE" ]; then
    sed -i.bak "/^\[Fonts\]/,/^\[/ s|^general=.*|general=\"$font_family,$font_size,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"|" "$QT5CT_FILE"
    sed -i.bak "/^\[Fonts\]/,/^\[/ s|^fixed=.*|fixed=\"$font_family_mono,$font_size,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"|" "$QT5CT_FILE"
fi

# Update Qt6ct settings
QT6CT_DIR="$HOME/.config/qt6ct"
QT6CT_FILE="$QT6CT_DIR/qt6ct.conf"
mkdir -p "$QT6CT_DIR"

if [ -f "$QT6CT_FILE" ]; then
    sed -i.bak "/^\[Fonts\]/,/^\[/ s|^general=.*|general=\"$font_family,$font_size,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"|" "$QT6CT_FILE"
    sed -i.bak "/^\[Fonts\]/,/^\[/ s|^fixed=.*|fixed=\"$font_family_mono,$font_size,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"|" "$QT6CT_FILE"
fi

# Update via gsettings
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface font-name "$font_family $font_size" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name "$font_family_mono $font_size" 2>/dev/null || true
fi

echo "Updated GTK and Qt font settings (theme: $THEME, font: $font_family $font_size)"
