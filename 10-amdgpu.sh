#!/bin/bash
# amdgpu.sh - AMD GPU configuration with LACT and kernel parameters

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

log "Installing LACT (Linux AMDGPU Control Application)..."
if rpm -q lact &>/dev/null; then
    log "LACT already installed"
else
    log "Installing LACT..."
    sudo dnf install -y lact
fi

log "Enabling LACT service..."
if systemctl is-enabled lactd &>/dev/null; then
    log "LACT service already enabled"
else
    sudo systemctl enable --now lactd
    log "LACT service enabled and started"
fi

log "Configuring AMD GPU kernel parameters..."
GRUB_FILE="/etc/default/grub"
AMD_PARAMS="amdgpu.ppfeaturemask=0xffffffff"

# Check if AMD parameters are already set
if grep -q "amdgpu.ppfeaturemask" "$GRUB_FILE"; then
    log "AMD GPU parameters already configured in GRUB"
else
    warn "Adding AMD GPU parameters to GRUB..."
    warn "This will enable advanced GPU features (overclocking, undervolting, etc.)"
    
    # Backup GRUB config
    sudo cp "$GRUB_FILE" "$GRUB_FILE.backup.$(date +%Y%m%d)"
    log "GRUB config backed up to $GRUB_FILE.backup.$(date +%Y%m%d)"
    
    # Add AMD parameters to GRUB_CMDLINE_LINUX
    sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$AMD_PARAMS /" "$GRUB_FILE"
    
    log "Updating GRUB configuration..."
    if [ -d /sys/firmware/efi ]; then
        # UEFI system
        sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    else
        # BIOS system
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
    
    log "AMD GPU parameters added to GRUB"
fi

log "AMD GPU configuration complete!"
log ""
log "Installed:"
log "  - LACT: AMD GPU control application (run 'lact' to launch GUI)"
log "  - lactd service: running and enabled"
log ""
log "GRUB parameters added:"
log "  - amdgpu.ppfeaturemask=0xffffffff (enables all GPU features)"
log ""
warn "IMPORTANT: Reboot required for GRUB changes to take effect!"
log ""
log "After reboot, verify with: cat /proc/cmdline | grep amdgpu"
log "Launch LACT GUI with: lact"
