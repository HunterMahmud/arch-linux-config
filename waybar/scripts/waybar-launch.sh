#!/bin/bash

# Waybar Launch Script for Hyprland
# Handles theme switching and proper waybar restart

CONFIG_DIR="$HOME/.config/waybar"
THEME_FILE="$CONFIG_DIR/current_theme"

# Kill existing waybar processes
killall waybar 2>/dev/null

# Wait a moment for clean shutdown
sleep 0.5

# Get current theme
if [[ -f "$THEME_FILE" ]]; then
    CURRENT_THEME=$(cat "$THEME_FILE")
else
    CURRENT_THEME="dark-theme"
    echo "dark-theme" > "$THEME_FILE"
fi

# Apply theme class to waybar
case "$CURRENT_THEME" in
    "light-theme")
        THEME_CLASS="light-theme"
        ;;
    "ocean-theme")
        THEME_CLASS="ocean-theme"
        ;;
    "sunset-theme")
        THEME_CLASS="sunset-theme"
        ;;
    *)
        THEME_CLASS=""
        ;;
esac

# Start waybar with theme class
if [[ -n "$THEME_CLASS" ]]; then
    # Create temporary CSS file with theme class
    TEMP_CSS="/tmp/waybar_themed.css"
    echo "window#waybar { @import url('$CONFIG_DIR/style.css'); }" > "$TEMP_CSS"
    echo "window#waybar { }" >> "$TEMP_CSS"
    
    # Start waybar and apply theme class after start
    waybar -c "$CONFIG_DIR/config" -s "$CONFIG_DIR/style.css" &
    
    # Wait for waybar to start
    sleep 1
    
    # Apply theme class using hyprctl
    hyprctl dispatch exec "gtk-update-icon-cache"
    
    # Add theme class to waybar window
    WAYBAR_PID=$!
    sleep 0.5
    
    # Apply CSS class via JavaScript injection (if available)
    if command -v xdotool >/dev/null 2>&1; then
        WAYBAR_ID=$(xdotool search --name "waybar" | head -1)
        if [[ -n "$WAYBAR_ID" ]]; then
            # Send theme update signal
            kill -USR1 $WAYBAR_PID 2>/dev/null || true
        fi
    fi
    
    # Manual CSS class injection
    sed -i "s/window#waybar {/window#waybar.$THEME_CLASS {/g" "$CONFIG_DIR/style.css" 2>/dev/null || true
    kill -USR2 $WAYBAR_PID 2>/dev/null || true
    sed -i "s/window#waybar.$THEME_CLASS {/window#waybar {/g" "$CONFIG_DIR/style.css" 2>/dev/null || true
    
else
    # Start waybar normally
    waybar -c "$CONFIG_DIR/config" -s "$CONFIG_DIR/style.css" &
fi

echo "Waybar started with theme: $CURRENT_THEME"
