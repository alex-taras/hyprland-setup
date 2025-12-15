#!/bin/bash
# Build and install Elephant

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="elephant"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Elephant already installed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Building Elephant ==="
log "Starting $COMPONENT installation"

WORK_DIR=~/Work
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone or update Elephant
if [ -d "elephant" ]; then
    echo "Elephant directory exists, pulling updates..."
    cd elephant
    git pull
else
    git clone https://github.com/abenz1267/elephant
    cd elephant
fi

# Build main binary
cd cmd/elephant
go install elephant.go

# Setup providers
mkdir -p ~/.config/elephant/providers
cd ../../internal/providers/desktopapplications
go build -buildmode=plugin
cp desktopapplications.so ~/.config/elephant/providers/

# Ensure go/bin is in PATH
if ! grep -q 'export PATH="$HOME/go/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
fi

echo "✓ Elephant installed to ~/go/bin/elephant"
echo "  Note: ~/go/bin must be in your PATH (added to ~/.bashrc)"
mark_complete "$COMPONENT"
