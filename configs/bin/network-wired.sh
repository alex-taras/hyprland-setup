#!/bin/bash
# ~/bin/network-wired.sh

# Find active wired interface
IFACE=$(ip -o link show | grep -E 'state UP.*ether' | grep -v 'docker\|veth\|br-' | awk -F': ' '{print $2}' | head -1)

if [ -z "$IFACE" ]; then
    printf '{"text":"󰈀 off","tooltip":"No wired connection","class":"down"}\n'
    exit 0
fi

# Get IP
IP=$(ip -4 addr show "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Get current RX/TX bytes
RX1=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes)
TX1=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes)

sleep 1

# Get new RX/TX bytes
RX2=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes)
TX2=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes)

# Calculate Mbps
RX_MBPS=$(echo "scale=2; ($RX2 - $RX1) * 8 / 1000000" | bc)
TX_MBPS=$(echo "scale=2; ($TX2 - $TX1) * 8 / 1000000" | bc)

# Use echo instead of printf with floats
echo "{\"text\":\" on\",\"tooltip\":\"$IFACE\\n$IP\\n↓ ${RX_MBPS} Mbps ↑ ${TX_MBPS} Mbps\",\"class\":\"up\"}"
