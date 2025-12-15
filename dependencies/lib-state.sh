#!/bin/bash
# lib-state.sh
# State management library for hyprland-setup

STATE_DIR="$HOME/.hyprland-setup"
STATE_FILE="$STATE_DIR/state.json"
LOG_FILE="$STATE_DIR/install.log"
ERROR_FILE="$STATE_DIR/last_error.log"

# Current component being installed (set by each script)
CURRENT_COMPONENT=""

# Track if we're in an error state
IN_ERROR_HANDLER=false

# Initialize state directory and file
init_state() {
    mkdir -p "$STATE_DIR"
    
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << 'EOF'
{
  "version": "1.0",
  "last_run": "",
  "components": {}
}
EOF
        log "State file created: $STATE_FILE"
    fi
}

# Log message with timestamp
log() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
}

# Check if component is marked complete
is_complete() {
    local component="$1"
    
    if [ ! -f "$STATE_FILE" ]; then
        return 1
    fi
    
    # Use python3 or jq if available, otherwise grep (basic fallback)
    if command -v python3 &> /dev/null; then
        python3 -c "import json, sys; data=json.load(open('$STATE_FILE')); sys.exit(0 if data.get('components', {}).get('$component', {}).get('completed', False) else 1)"
    else
        # Simple grep fallback (less reliable but works without dependencies)
        grep -q "\"$component\".*\"completed\".*true" "$STATE_FILE"
    fi
}

# Mark component as complete
mark_complete() {
    local component="$1"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    
    init_state
    
    if command -v python3 &> /dev/null; then
        python3 << EOF
import json
with open('$STATE_FILE', 'r') as f:
    data = json.load(f)

data['last_run'] = '$timestamp'
if 'components' not in data:
    data['components'] = {}
data['components']['$component'] = {
    'completed': True,
    'timestamp': '$timestamp'
}

with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF
        log "✓ Marked $component as complete"
    else
        log "⚠ Warning: python3 not found, cannot update state file"
    fi
}

# Check if a package is installed (dnf/rpm based)
check_package() {
    local pkg="$1"
    rpm -q "$pkg" &> /dev/null
}

# Check if a binary/command exists
check_binary() {
    local cmd="$1"
    command -v "$cmd" &> /dev/null
}

# Check if a config file exists
check_config() {
    local path="$1"
    [ -f "$path" ]
}

# Check if a directory exists
check_dir() {
    local path="$1"
    [ -d "$path" ]
}

# Display inventory of packages
inventory_packages() {
    local packages=("$@")
    local all_installed=true
    
    for pkg in "${packages[@]}"; do
        if check_package "$pkg"; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg"
            all_installed=false
        fi
    done
    
    return $([ "$all_installed" = true ] && echo 0 || echo 1)
}

# Display inventory of binaries
inventory_binaries() {
    local binaries=("$@")
    local all_found=true
    
    for bin in "${binaries[@]}"; do
        if check_binary "$bin"; then
            echo "  ✓ $bin ($(command -v "$bin"))"
        else
            echo "  ✗ $bin"
            all_found=false
        fi
    done
    
    return $([ "$all_found" = true ] && echo 0 || echo 1)
}

# Display inventory of config files
inventory_configs() {
    local configs=("$@")
    local all_found=true
    
    for cfg in "${configs[@]}"; do
        if check_config "$cfg"; then
            echo "  ✓ $cfg"
        else
            echo "  ✗ $cfg"
            all_found=false
        fi
    done
    
    return $([ "$all_found" = true ] && echo 0 || echo 1)
}

# Get full state summary
get_state_summary() {
    init_state
    
    echo "=== Hyprland Setup State ==="
    echo "State file: $STATE_FILE"
    echo "Log file: $LOG_FILE"
    echo ""
    
    if [ -f "$STATE_FILE" ]; then
        if command -v python3 &> /dev/null; then
            python3 << 'EOF'
import json
with open("$STATE_FILE", "r") as f:
    data = json.load(f)
    
print(f"Last run: {data.get('last_run', 'Never')}")
print(f"\nComponents:")
for component, info in data.get('components', {}).items():
    status = "✓" if info.get('completed') else "✗"
    timestamp = info.get('timestamp', '')
    print(f"  {status} {component} {timestamp}")
EOF
        else
            cat "$STATE_FILE"
        fi
    else
        echo "No state file found"
    fi
}

# Mark component as failed
mark_failed() {
    local component="$1"
    local error_msg="$2"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    
    init_state
    
    if command -v python3 &> /dev/null; then
        python3 << EOF
import json
with open('$STATE_FILE', 'r') as f:
    data = json.load(f)

data['last_run'] = '$timestamp'
if 'components' not in data:
    data['components'] = {}
data['components']['$component'] = {
    'completed': False,
    'failed': True,
    'error': '''$error_msg''',
    'timestamp': '$timestamp'
}

with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF
        log "✗ Marked $component as failed: $error_msg"
    fi
}

# Log error with context
log_error() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" | tee -a "$LOG_FILE" >> "$ERROR_FILE"
}

# Error handler - called on script failure
handle_error() {
    local exit_code=$?
    local line_number=$1
    
    # Prevent recursive error handling
    if [ "$IN_ERROR_HANDLER" = true ]; then
        return
    fi
    IN_ERROR_HANDLER=true
    
    echo ""
    echo "=========================================="
    echo "ERROR: Installation failed!"
    echo "=========================================="
    echo "Component: ${CURRENT_COMPONENT:-unknown}"
    echo "Exit code: $exit_code"
    echo "Line: $line_number"
    echo ""
    
    log_error "Component '${CURRENT_COMPONENT}' failed at line $line_number with exit code $exit_code"
    
    if [ -n "$CURRENT_COMPONENT" ]; then
        mark_failed "$CURRENT_COMPONENT" "Failed at line $line_number with exit code $exit_code"
    fi
    
    echo "Troubleshooting:"
    echo "  1. Check logs: $LOG_FILE"
    echo "  2. Check errors: $ERROR_FILE"
    echo "  3. Review what succeeded: ./setup.sh --check"
    echo ""
    
    # Component-specific guidance
    case "$CURRENT_COMPONENT" in
        hyprland_packages)
            echo "Package installation failed. Common fixes:"
            echo "  - Check internet connection"
            echo "  - Run: sudo dnf update --refresh"
            echo "  - Check if a package was renamed/removed from repos"
            ;;
        elephant|walker|waybar_tools)
            echo "Build failed. Common fixes:"
            echo "  - Ensure build tools are installed (cargo/go)"
            echo "  - Check if upstream repo has build issues"
            echo "  - Try cleaning build: rm -rf ~/Work/${CURRENT_COMPONENT}"
            echo "  - This component is optional, you can continue without it"
            ;;
        configs)
            echo "Config deployment failed. Common fixes:"
            echo "  - Ensure configs/ directory exists in repo"
            echo "  - Check file permissions"
            ;;
        system_config)
            echo "System configuration failed. Common fixes:"
            echo "  - Check sudo permissions"
            echo "  - Review systemd configuration"
            ;;
    esac
    
    echo ""
    echo "To resume installation after fixing the issue:"
    echo "  ./setup.sh"
    echo ""
    echo "To skip this component and continue:"
    echo "  mark_complete \"$CURRENT_COMPONENT\" (edit state manually)"
    echo ""
    
    exit $exit_code
}

# Setup error trap for a script
setup_error_handling() {
    local component="$1"
    CURRENT_COMPONENT="$component"
    
    # Enable error tracing
    set -E
    
    # Set up trap to call handle_error with line number
    trap 'handle_error $LINENO' ERR
    
    log "Starting $component with error handling enabled"
}

# Check for critical dependencies
check_critical_deps() {
    local missing_deps=()
    
    # Critical system tools
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v sudo &> /dev/null; then
        missing_deps+=("sudo")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "ERROR: Missing critical dependencies: ${missing_deps[*]}"
        echo "Install with: sudo dnf install -y ${missing_deps[*]}"
        return 1
    fi
    
    # Check sudo permissions
    if ! sudo -n true 2>/dev/null; then
        echo "Note: This script requires sudo privileges"
        echo "You may be prompted for your password"
        sudo -v || {
            echo "ERROR: Unable to obtain sudo privileges"
            return 1
        }
    fi
    
    return 0
}

# Safe wrapper for dnf install - continues on non-critical failures
safe_dnf_install() {
    local packages=("$@")
    local failed_packages=()
    
    echo "Installing ${#packages[@]} packages..."
    
    if sudo dnf install -y "${packages[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ Successfully installed all packages"
        return 0
    else
        log_error "Some packages failed to install"
        
        # Try to identify which packages failed
        echo "Note: Some packages may have failed to install"
        echo "Continuing with available packages..."
        return 0  # Non-fatal - partial success is OK
    fi
}

# Safe wrapper for cargo/go builds - non-fatal
safe_build() {
    local build_type="$1"  # "cargo" or "go"
    local build_cmd="$2"
    
    log "Building with $build_type: $build_cmd"
    
    if eval "$build_cmd" 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ Build succeeded"
        return 0
    else
        log_error "Build failed: $build_cmd"
        echo ""
        echo "⚠ Build failed, but this is non-critical"
        echo "You can continue without this component"
        return 1
    fi
}

# Export functions
export -f init_state
export -f log
export -f log_error
export -f is_complete
export -f mark_complete
export -f mark_failed
export -f handle_error
export -f setup_error_handling
export -f check_critical_deps
export -f safe_dnf_install
export -f safe_build
export -f check_package
export -f check_binary
export -f check_config
export -f check_dir
export -f inventory_packages
export -f inventory_binaries
export -f inventory_configs
export -f get_state_summary
