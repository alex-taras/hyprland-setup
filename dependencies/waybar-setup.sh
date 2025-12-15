#!/bin/bash
# Install waybar dependencies and tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="waybar_tools"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Waybar tools already installed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Setting up Waybar Tools ==="
log "Starting $COMPONENT installation"

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
cargo build --release
sudo cp target/release/wttrbar /usr/local/bin/

echo "✓ Waybar tools installed"
mark_complete "$COMPONENT"
