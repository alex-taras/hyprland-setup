#!/bin/bash
# Install waybar dependencies and tools

set -e

echo "=== Setting up Waybar Tools ==="

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
