#!/bin/bash
# bootloader.sh - Automate Limine bootloader CachyOS kernel entry

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

LIMINE_CONF="/boot/EFI/arch-limine/limine.conf"

log "Configuring Limine bootloader for CachyOS kernel..."

# Check if limine.conf exists
if [ ! -f "$LIMINE_CONF" ]; then
    error "Limine config not found at $LIMINE_CONF"
    error "This script is designed for Limine bootloader"
    exit 1
fi

# Check if CachyOS kernel is installed
if ! pacman -Q linux-cachyos &>/dev/null; then
    error "CachyOS kernel not installed. Run base.sh first."
    exit 1
fi

# Check if CachyOS entry already exists
if grep -q "vmlinuz-linux-cachyos" "$LIMINE_CONF"; then
    log "CachyOS kernel entry already exists in limine.conf"
    exit 0
fi

# Auto-detect root partition
log "Detecting root partition..."
ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
if [ -z "$ROOT_DEVICE" ]; then
    error "Could not detect root partition"
    exit 1
fi
log "Root device: $ROOT_DEVICE"

# Get PARTUUID
log "Getting PARTUUID..."
PARTUUID=$(lsblk -no PARTUUID "$ROOT_DEVICE")
if [ -z "$PARTUUID" ]; then
    error "Could not get PARTUUID for $ROOT_DEVICE"
    exit 1
fi
log "PARTUUID: $PARTUUID"

# Detect filesystem type and subvolume
FSTYPE=$(findmnt -n -o FSTYPE /)
log "Filesystem type: $FSTYPE"

# Build rootflags
ROOTFLAGS=""
if [ "$FSTYPE" = "btrfs" ]; then
    SUBVOL=$(findmnt -n -o OPTIONS / | grep -oP 'subvol=\K[^,]+' || echo "@")
    ROOTFLAGS="rootflags=subvol=$SUBVOL "
    log "Btrfs subvolume: $SUBVOL"
fi

# Backup original config
log "Backing up limine.conf..."
sudo cp "$LIMINE_CONF" "$LIMINE_CONF.backup.$(date +%Y%m%d_%H%M%S)"

# Create temporary file with new entry at the top
log "Adding CachyOS kernel entry..."
TEMP_CONF=$(mktemp)

# Write CachyOS entry
cat > "$TEMP_CONF" << EOF
/Arch Linux (linux-cachyos)
    protocol: linux
    path: boot():/vmlinuz-linux-cachyos
    cmdline: root=PARTUUID=$PARTUUID zswap.enabled=0 ${ROOTFLAGS}rw rootfstype=$FSTYPE quiet loglevel=3 vt.global_cursor_default=0 splash
    module_path: boot():/initramfs-linux-cachyos.img

EOF

# Append original config
cat "$LIMINE_CONF" >> "$TEMP_CONF"

# Replace config
sudo mv "$TEMP_CONF" "$LIMINE_CONF"

log "CachyOS kernel entry added to limine.conf!"
log "Entry has been placed first (default boot option)"
echo ""
echo "Boot entry added:"
echo "  Kernel: vmlinuz-linux-cachyos"
echo "  PARTUUID: $PARTUUID"
echo "  Filesystem: $FSTYPE"
if [ -n "$SUBVOL" ]; then
    echo "  Subvolume: $SUBVOL"
fi
echo ""
warn "Review $LIMINE_CONF to verify the entry is correct"
warn "Backup saved to: $LIMINE_CONF.backup.*"
echo ""
log "Reboot to use the CachyOS kernel"
