#!/bin/bash
# Install Gum TUI tool

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-state.sh"

COMPONENT="gum"

# Setup error handling for this component
setup_error_handling "$COMPONENT"

# Check if already completed
if is_complete "$COMPONENT"; then
    echo "✓ Gum already installed (skipping)"
    log "Skipped $COMPONENT (already complete)"
    exit 0
fi

echo "=== Installing Gum TUI Tool ==="
log "Starting $COMPONENT installation"

# Check if gum is already available
if command -v gum &> /dev/null; then
    echo "✓ Gum already installed"
    mark_complete "$COMPONENT"
    exit 0
fi

# Install from GitHub releases
GUM_VERSION="0.14.5"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Downloading gum v${GUM_VERSION}..."
curl -LO "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum-${GUM_VERSION}-1.x86_64.rpm"

echo "Installing gum..."
sudo dnf install -y "gum-${GUM_VERSION}-1.x86_64.rpm"

cd -
rm -rf "$TMP_DIR"

echo "✓ Gum installed"
mark_complete "$COMPONENT"
