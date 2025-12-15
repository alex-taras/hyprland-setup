#!/bin/bash
# setup.sh
# Main orchestrator script

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_DIR="$SCRIPT_DIR/dependencies"

# Source state management library
source "$DEPS_DIR/lib-state.sh"

# Initialize state tracking
init_state

# Check critical dependencies before proceeding
if ! check_critical_deps; then
    exit 1
fi

# Parse command line options
SHOW_CHECK=false
CONFIGURE_MONITORS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            SHOW_CHECK=true
            shift
            ;;
        --configure-monitors)
            CONFIGURE_MONITORS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--check] [--configure-monitors]"
            echo "  --check               Show installation status without installing"
            echo "  --configure-monitors  Launch nwg-displays to configure monitors"
            exit 1
            ;;
    esac
done

# If --configure-monitors, launch nwg-displays
if [ "$CONFIGURE_MONITORS" = true ]; then
    echo "=== Monitor Configuration ==="
    
    if ! command -v nwg-displays &> /dev/null; then
        echo "ERROR: nwg-displays not found"
        echo "Run the full setup first: ./setup.sh"
        exit 1
    fi
    
    # Check if in Hyprland session
    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        echo "ERROR: Not running in a Hyprland session"
        echo "Please log into Hyprland first, then run:"
        echo "  ./setup.sh --configure-monitors"
        exit 1
    fi
    
    echo "Launching nwg-displays..."
    echo "Configure your monitors and click 'Apply' to save to Hyprland config"
    nwg-displays
    
    exit 0
fi

# If --check, show inventory and exit
if [ "$SHOW_CHECK" = true ]; then
    get_state_summary
    echo ""
    echo "=== Package Inventory ==="
    
    echo "Core Hyprland packages:"
    inventory_packages hyprland kitty dunst grim slurp hyprpaper wlogout firefox dolphin \
        waybar bluez blueman pamixer pavucontrol btop bc fontawesome-fonts \
        google-noto-emoji-fonts nwg-displays cargo rust go
    
    echo ""
    echo "Media control packages:"
    inventory_packages brightnessctl playerctl pipewire-utils
    
    echo ""
    echo "Custom binaries:"
    inventory_binaries elephant walker wttrbar brightnessctl playerctl wpctl
    
    echo ""
    echo "Configuration files:"
    inventory_configs \
        "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/waybar/config.jsonc" \
        "$HOME/.config/waybar/style.css" \
        "$HOME/.config/kitty/kitty.conf"
    
    exit 0
fi

echo "=== Hyprland Setup - Main Script ==="
echo "Running from: $SCRIPT_DIR"
echo "State tracking: $STATE_FILE"
echo ""

# Check if running Fedora
if ! grep -q "Fedora\|Nobara" /etc/os-release; then
    echo "Warning: This script is designed for Fedora/Nobara"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Check if dependencies directory exists
if [ ! -d "$DEPS_DIR" ]; then
    echo "Error: $DEPS_DIR directory not found"
    exit 1
fi

# Track successes and failures
declare -a COMPLETED_COMPONENTS
declare -a FAILED_COMPONENTS
declare -a SKIPPED_COMPONENTS

# Run sub-scripts in order with error handling
run_component() {
    local script="$1"
    local component_name="$2"
    
    echo ""
    if bash "$script"; then
        COMPLETED_COMPONENTS+=("$component_name")
        return 0
    else
        local exit_code=$?
        FAILED_COMPONENTS+=("$component_name")
        
        echo ""
        echo "⚠ Component '$component_name' failed (see above for details)"
        echo ""
        
        # Ask if user wants to continue with remaining components
        read -p "Continue with remaining components? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation aborted by user"
            exit $exit_code
        fi
        
        return 1
    fi
}

# Run components (critical first, then optional)
echo "=== Installing Critical Components ==="
run_component "$DEPS_DIR/hyprland-setup.sh" "hyprland_packages"
run_component "$DEPS_DIR/configs-setup.sh" "configs"
run_component "$DEPS_DIR/system-setup.sh" "system_config"

echo ""
echo "=== Installing Optional Components ==="
run_component "$DEPS_DIR/gum-setup.sh" "gum" || true
run_component "$DEPS_DIR/elephant-setup.sh" "elephant" || true
run_component "$DEPS_DIR/walker-setup.sh" "walker" || true
run_component "$DEPS_DIR/waybar-setup.sh" "waybar_tools" || true

echo ""
echo "=========================================="
echo "=== Installation Summary ==="
echo "=========================================="

if [ ${#COMPLETED_COMPONENTS[@]} -gt 0 ]; then
    echo "✓ Completed (${#COMPLETED_COMPONENTS[@]}):"
    for comp in "${COMPLETED_COMPONENTS[@]}"; do
        echo "  - $comp"
    done
fi

if [ ${#FAILED_COMPONENTS[@]} -gt 0 ]; then
    echo ""
    echo "✗ Failed (${#FAILED_COMPONENTS[@]}):"
    for comp in "${FAILED_COMPONENTS[@]}"; do
        echo "  - $comp"
    done
    echo ""
    echo "Review errors: $ERROR_FILE"
    echo "Check logs: $LOG_FILE"
    echo "You can re-run ./setup.sh to retry failed components"
fi

if [ ${#SKIPPED_COMPONENTS[@]} -gt 0 ]; then
    echo ""
    echo "⊘ Skipped (${#SKIPPED_COMPONENTS[@]}):"
    for comp in "${SKIPPED_COMPONENTS[@]}"; do
        echo "  - $comp"
    done
fi

echo ""
if [ ${#FAILED_COMPONENTS[@]} -eq 0 ]; then
    log "Setup completed successfully"
    echo "=== Setup Complete ==="
    echo "Please reboot and select 'Hyprland' at the login screen"
    echo ""
    echo "After logging into Hyprland, configure your monitors:"
    echo "  ./setup.sh --configure-monitors"
    echo ""
    echo "Power button menu: Press physical power button or Super+Escape"
else
    log "Setup completed with ${#FAILED_COMPONENTS[@]} failures"
    echo "Setup completed with errors. Review the summary above."
    exit 1
fi