#!/bin/bash
# Install waybar dependencies and tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="waybar_tools"

# Setup error handling for this component
setup_error_handling "$COMPONENT"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Waybar tools already installed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Setting up Waybar Tools ==="
log "Starting $COMPONENT installation"

# Check if cargo is available
if ! command -v cargo &> /dev/null; then
    log_error "Cargo toolchain not found"
    echo "ERROR: Cargo/Rust is required to build waybar tools"
    echo "Install it first: sudo dnf install -y cargo rust"
    exit 1
fi

WORK_DIR=~/Work
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Install wttrbar (weather widget)
if [ -d "wttrbar" ]; then
    echo "wttrbar directory exists, pulling updates..."
    cd wttrbar
    git pull
else
    git clone https://github.com/bjesus/wttrbar.git
    cd wttrbar
fi

echo "Building wttrbar..."
if ! safe_build "cargo" "cargo build --release"; then
    echo "Failed to build wttrbar"
    exit 1
fi

if [ -f "target/release/wttrbar" ]; then
    sudo cp target/release/wttrbar /usr/local/bin/
    echo "✓ Waybar tools installed"
    mark_complete "$COMPONENT"
else
    log_error "wttrbar binary not found after build"
    echo "ERROR: Build claimed success but binary not found"
    exit 1
fi
