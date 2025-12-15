#!/bin/bash
# Build and install Walker launcher

set -e

echo "=== Building Walker ==="

WORK_DIR=~/Work
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone or update Walker
if [ -d "walker" ]; then
    echo "Walker directory exists, pulling updates..."
    cd walker
    git pull
else
    git clone https://github.com/abenz1267/walker.git
    cd walker
fi

# Build
echo "Building Walker (this may take a few minutes)..."
cargo build --release

# Install
sudo cp target/release/walker /usr/local/bin/
echo "✓ Walker installed to /usr/local/bin/walker"
