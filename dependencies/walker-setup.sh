#!/bin/bash
# Build and install Walker launcher

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="walker"

# Setup error handling for this component
setup_error_handling "$COMPONENT"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Walker already installed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Building Walker ==="
log "Starting $COMPONENT installation"

# Check if cargo is available
if ! command -v cargo &> /dev/null; then
    log_error "Cargo toolchain not found"
    echo "ERROR: Cargo/Rust is required to build Walker"
    echo "Install it first: sudo dnf install -y cargo rust"
    exit 1
fi

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
if ! safe_build "cargo" "cargo build --release"; then
    echo "Failed to build Walker"
    exit 1
fi

# Install
if [ -f "target/release/walker" ]; then
    sudo cp target/release/walker /usr/local/bin/
    echo "✓ Walker installed to /usr/local/bin/walker"
    mark_complete "$COMPONENT"
else
    log_error "Walker binary not found after build"
    echo "ERROR: Build claimed success but binary not found"
    exit 1
fi
