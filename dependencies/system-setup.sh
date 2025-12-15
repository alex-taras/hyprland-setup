#!/bin/bash
# System-level configurations

set -e

echo "=== Configuring System Settings ==="

# Configure power button to not shutdown immediately
echo "Setting up power button handling..."
sudo mkdir -p /etc/systemd/logind.conf.d

cat << 'EOF' | sudo tee /etc/systemd/logind.conf.d/power-button.conf > /dev/null
[Login]
HandlePowerKey=ignore
HandlePowerKeyLongPress=ignore
EOF

echo "✓ Power button configured (requires reboot)"

# Ensure PATH includes go/bin
if ! grep -q 'export PATH="$HOME/go/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
    echo "✓ Added ~/go/bin to PATH in ~/.bashrc"
fi

echo ""
echo "=== System Configuration Complete ==="
echo ""
echo "IMPORTANT: Reboot required for power button changes to take effect"
echo "After reboot, log in and select 'Hyprland' from the session menu"
