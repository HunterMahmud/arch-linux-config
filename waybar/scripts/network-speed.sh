#!/bin/bash

# Network Speed Monitor Script for Waybar
# Shows real-time upload/download speeds in MB/KB with 3 decimal precision

# Get active network interface
INTERFACE=$(ip route | awk '/default/ { print $5 ; exit }')

if [[ -z "$INTERFACE" ]]; then
    echo "No Connection"
    exit 1
fi

# File to store previous values
CACHE_FILE="/tmp/waybar_network_speed"

# Read current bytes
RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
CURRENT_TIME=$(date +%s)

# Read previous values if file exists
if [[ -f "$CACHE_FILE" ]]; then
    read PREV_RX PREV_TX PREV_TIME < "$CACHE_FILE"
    
    # Calculate time difference
    TIME_DIFF=$((CURRENT_TIME - PREV_TIME))
    
    if [[ $TIME_DIFF -gt 0 ]]; then
        # Calculate bytes difference
        RX_DIFF=$((RX_BYTES - PREV_RX))
        TX_DIFF=$((TX_BYTES - PREV_TX))
        
        # Calculate speed in bytes per second
        RX_SPEED=$((RX_DIFF / TIME_DIFF))
        TX_SPEED=$((TX_DIFF / TIME_DIFF))
        
        # Function to format speed
        format_speed() {
            local speed=$1
            
            if [[ $speed -ge 1048576 ]]; then
                # MB/s (with 3 decimal places)
                printf "%.2f MB/s" $(echo "scale=3; $speed / 1048576" | bc)
            elif [[ $speed -ge 1024 ]]; then
                # KB/s (with 3 decimal places)
                printf "%.2f KB/s" $(echo "scale=3; $speed / 1024" | bc)
            else
                # B/s
                printf "%d B/s" $speed
            fi
        }
        
        # Format download and upload speeds
        DOWN_SPEED=$(format_speed $RX_SPEED)
        UP_SPEED=$(format_speed $TX_SPEED)
        
        # Output for waybar
        echo "↓ $DOWN_SPEED ↑ $UP_SPEED"
        
        # Tooltip with detailed info
        echo "Download: $DOWN_SPEED | Upload: $UP_SPEED | Interface: $INTERFACE"
        
    else
        echo "Calculating..."
    fi
else
    echo "Initializing..."
fi

# Save current values for next iteration
echo "$RX_BYTES $TX_BYTES $CURRENT_TIME" > "$CACHE_FILE"
