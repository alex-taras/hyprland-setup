#!/bin/bash
# lib-state.sh
# State management library for hyprland-setup

STATE_DIR="$HOME/.hyprland-setup"
STATE_FILE="$STATE_DIR/state.json"
LOG_FILE="$STATE_DIR/install.log"

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

# Export functions
export -f init_state
export -f log
export -f is_complete
export -f mark_complete
export -f check_package
export -f check_binary
export -f check_config
export -f check_dir
export -f inventory_packages
export -f inventory_binaries
export -f inventory_configs
export -f get_state_summary
