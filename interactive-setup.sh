#!/bin/bash
# Interactive TUI wrapper for setup.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_DIR="$SCRIPT_DIR/dependencies"

# Ensure gum is available
if ! command -v gum &> /dev/null; then
    echo "Installing Gum TUI tool first..."
    bash "$DEPS_DIR/gum-setup.sh"
    
    # Check again
    if ! command -v gum &> /dev/null; then
        echo "ERROR: Failed to install gum"
        echo "Falling back to standard setup.sh"
        exec bash "$SCRIPT_DIR/setup.sh" "$@"
    fi
fi

# Show banner
gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    'Hyprland Setup' 'Interactive Installation'

# Main menu loop
while true; do
    echo ""
    CHOICE=$(gum choose \
        "Check installation status" \
        "Run full installation" \
        "Configure monitors" \
        "Exit" \
        --header "What would you like to do?" \
        --height 8)
    
    case "$CHOICE" in
        "Check installation status")
            echo ""
            gum spin --spinner dot --title "Checking installation status..." -- sleep 1
            echo ""
            bash "$SCRIPT_DIR/setup.sh" --check
            echo ""
            gum style --foreground 212 "Press Enter to continue..."
            read -r
            ;;
            
        "Run full installation")
            echo ""
            if gum confirm "This will install Hyprland and all components. Continue?"; then
                echo ""
                gum style --foreground 212 "Starting installation..."
                sleep 1
                bash "$SCRIPT_DIR/setup.sh"
                EXIT_CODE=$?
                
                echo ""
                if [ $EXIT_CODE -eq 0 ]; then
                    gum style --foreground 46 "✓ Installation completed successfully!"
                else
                    gum style --foreground 196 "✗ Installation completed with errors"
                fi
                
                echo ""
                gum style --foreground 212 "Press Enter to continue..."
                read -r
            else
                echo "Installation cancelled"
            fi
            ;;
            
        "Configure monitors")
            echo ""
            if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
                gum style --foreground 196 "ERROR: Not running in a Hyprland session"
                echo ""
                echo "Please log into Hyprland first"
            else
                if gum confirm "Launch nwg-displays to configure monitors?"; then
                    bash "$SCRIPT_DIR/setup.sh" --configure-monitors
                fi
            fi
            echo ""
            gum style --foreground 212 "Press Enter to continue..."
            read -r
            ;;
            
        "Exit")
            echo ""
            gum style --foreground 212 "Goodbye!"
            exit 0
            ;;
    esac
done
