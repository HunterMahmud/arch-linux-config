#!/bin/bash

# Theme Switcher Script for Waybar
# Provides multiple theme options with smooth animations

CONFIG_DIR="$HOME/.config/waybar"
THEME_FILE="$CONFIG_DIR/current_theme"
WOFI_STYLE="$HOME/.config/wofi/style.css"
WAYBAR_CSS="$CONFIG_DIR/style.css"

# Create theme file if it doesn't exist
if [[ ! -f "$THEME_FILE" ]]; then
    echo "dark-theme" > "$THEME_FILE"
fi

# Current theme
CURRENT_THEME=$(cat "$THEME_FILE")

# Theme options for wofi menu
show_theme_menu() {
    THEMES=(
        "🌙 Dark Theme|dark-theme"
        "☀️ Light Theme|light-theme" 
        "🌊 Ocean Theme|ocean-theme"
        "🌅 Sunset Theme|sunset-theme"
    )
    
    # Create temporary theme list
    TEMP_FILE="/tmp/waybar_themes"
    printf '%s\n' "${THEMES[@]}" > "$TEMP_FILE"
    
    # Show wofi menu
    SELECTED=$(wofi --dmenu --width 300 --height 200 \
        --prompt "Select Theme" \
        --cache-file=/dev/null \
        --conf ~/.config/wofi/config \
        --style ~/.config/wofi/style.css \
        < "$TEMP_FILE")
    
    if [[ -n "$SELECTED" ]]; then
        # Extract theme name
        THEME_NAME=$(echo "$SELECTED" | cut -d'|' -f2)
        apply_theme "$THEME_NAME"
    fi
    
    rm -f "$TEMP_FILE"
}

# Apply theme with proper waybar restart
apply_theme() {
    local theme=$1
    
    if [[ "$theme" == "$CURRENT_THEME" ]]; then
        return
    fi
    
    # Update theme file
    echo "$theme" > "$THEME_FILE"
    
    # Update waybar CSS with theme class
    update_waybar_theme "$theme"
    
    # Update wofi theme to match
    update_wofi_theme "$theme"
    
    # Restart waybar to apply changes
    killall waybar 2>/dev/null
    sleep 0.5
    waybar -c "$CONFIG_DIR/config" -s "$WAYBAR_CSS" &
    
    # Send notification
    notify-send "Theme Applied" "Switched to $(echo $theme | sed 's/-/ /g' | sed 's/\b\w/\U&/g')" \
        --icon=preferences-desktop-theme --expire-time=2000 2>/dev/null || true
}

# Update waybar CSS for theme switching
update_waybar_theme() {
    local theme=$1
    
    # Backup original CSS if not exists
    if [[ ! -f "$WAYBAR_CSS.backup" ]]; then
        cp "$WAYBAR_CSS" "$WAYBAR_CSS.backup"
    fi
    
    # Restore original CSS
    cp "$WAYBAR_CSS.backup" "$WAYBAR_CSS"
    
    # Apply theme-specific modifications
    case "$theme" in
        "light-theme")
            # Replace dark colors with light colors
            sed -i 's/rgba(26, 26, 26, 0.8)/rgba(255, 255, 255, 0.9)/g' "$WAYBAR_CSS"
            sed -i 's/rgba(40, 40, 40, 0.9)/rgba(248, 249, 250, 0.9)/g' "$WAYBAR_CSS"
            sed -i 's/color: #ffffff/color: #2d3436/g' "$WAYBAR_CSS"
            sed -i 's/color: #888888/color: #636e72/g' "$WAYBAR_CSS"
            sed -i 's/#00d4aa/#00b894/g' "$WAYBAR_CSS"
            ;;
        "ocean-theme")
            # Replace with ocean colors
            sed -i 's/rgba(26, 26, 26, 0.8)/rgba(15, 52, 96, 0.8)/g' "$WAYBAR_CSS"
            sed -i 's/rgba(40, 40, 40, 0.9)/rgba(21, 101, 192, 0.3)/g' "$WAYBAR_CSS"
            sed -i 's/color: #ffffff/color: #e1f5fe/g' "$WAYBAR_CSS"
            sed -i 's/color: #888888/color: #81d4fa/g' "$WAYBAR_CSS"
            sed -i 's/#00d4aa/#00acc1/g' "$WAYBAR_CSS"
            sed -i 's/#74b9ff/#4fc3f7/g' "$WAYBAR_CSS"
            ;;
        "sunset-theme")
            # Replace with sunset colors
            sed -i 's/rgba(26, 26, 26, 0.8)/rgba(44, 24, 16, 0.8)/g' "$WAYBAR_CSS"
            sed -i 's/rgba(40, 40, 40, 0.9)/rgba(191, 54, 12, 0.3)/g' "$WAYBAR_CSS"
            sed -i 's/color: #ffffff/color: #fff3e0/g' "$WAYBAR_CSS"
            sed -i 's/color: #888888/color: #ffcc02/g' "$WAYBAR_CSS"
            sed -i 's/#00d4aa/#ff6f00/g' "$WAYBAR_CSS"
            sed -i 's/#74b9ff/#ff8f00/g' "$WAYBAR_CSS"
            ;;
    esac
}

# Update wofi theme to match waybar
update_wofi_theme() {
    local theme=$1
    
    mkdir -p "$(dirname "$WOFI_STYLE")"
    
    case "$theme" in
        "light-theme")
            cat > "$WOFI_STYLE" << 'EOF'
/* Main Window */
window {
    margin: 0px;
    border: 2px solid #00b894;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 15px;
    backdrop-filter: blur(20px);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
    animation: slideIn 0.2s ease-out;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: scale(0.9) translateY(-10px);
    }
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

#outer-box {
    margin: 10px;
    padding: 10px;
    border: none;
    background: transparent;
}

#inner-box {
    margin: 0px;
    padding: 0px;
    border: none;
    background: transparent;
}

#input {
    margin: 5px 10px 15px 10px;
    padding: 12px 15px;
    border: 2px solid rgba(0, 184, 148, 0.3);
    background: rgba(248, 249, 250, 0.9);
    border-radius: 10px;
    color: #2d3436;
    font-size: 14px;
    font-weight: bold;
    transition: all 0.3s ease;
}

#input:focus {
    border-color: #00b894;
    background: rgba(255, 255, 255, 0.9);
    box-shadow: 0 0 15px rgba(0, 184, 148, 0.3);
    outline: none;
}

#scroll {
    margin: 0px 5px;
    border: none;
    background: transparent;
}

#text {
    margin: 0px;
    padding: 8px 12px;
    border: none;
    background: transparent;
    color: #2d3436;
    font-size: 14px;
    font-weight: 500;
}

#entry {
    margin: 2px 5px;
    padding: 8px;
    border: 1px solid transparent;
    background: rgba(233, 236, 239, 0.4);
    border-radius: 8px;
    transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
    min-height: 40px;
}

#entry:hover {
    background: rgba(0, 184, 148, 0.15);
    border-color: rgba(0, 184, 148, 0.4);
    transform: translateX(3px);
}

#entry:selected {
    background: linear-gradient(45deg, rgba(0, 184, 148, 0.8), rgba(0, 160, 133, 0.8));
    border-color: #00b894;
    color: #ffffff;
    font-weight: bold;
    box-shadow: 0 4px 15px rgba(0, 184, 148, 0.3);
    transform: translateX(5px) scale(1.02);
}

#entry:selected #text {
    color: #ffffff;
    font-weight: bold;
}
EOF
            ;;
        "ocean-theme")
            cat > "$WOFI_STYLE" << 'EOF'
/* Main Window */
window {
    margin: 0px;
    border: 2px solid #00acc1;
    background: rgba(15, 52, 96, 0.95);
    border-radius: 15px;
    backdrop-filter: blur(20px);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    animation: slideIn 0.2s ease-out;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: scale(0.9) translateY(-10px);
    }
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

#outer-box {
    margin: 10px;
    padding: 10px;
    border: none;
    background: transparent;
}

#inner-box {
    margin: 0px;
    padding: 0px;
    border: none;
    background: transparent;
}

#input {
    margin: 5px 10px 15px 10px;
    padding: 12px 15px;
    border: 2px solid rgba(0, 172, 193, 0.3);
    background: rgba(21, 101, 192, 0.6);
    border-radius: 10px;
    color: #e1f5fe;
    font-size: 14px;
    font-weight: bold;
    transition: all 0.3s ease;
}

#input:focus {
    border-color: #00acc1;
    background: rgba(33, 150, 243, 0.8);
    box-shadow: 0 0 15px rgba(0, 172, 193, 0.3);
    outline: none;
}

#scroll {
    margin: 0px 5px;
    border: none;
    background: transparent;
}

#text {
    margin: 0px;
    padding: 8px 12px;
    border: none;
    background: transparent;
    color: #e1f5fe;
    font-size: 14px;
    font-weight: 500;
}

#entry {
    margin: 2px 5px;
    padding: 8px;
    border: 1px solid transparent;
    background: rgba(33, 150, 243, 0.2);
    border-radius: 8px;
    transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
    min-height: 40px;
}

#entry:hover {
    background: rgba(0, 172, 193, 0.15);
    border-color: rgba(0, 172, 193, 0.4);
    transform: translateX(3px);
}

#entry:selected {
    background: linear-gradient(45deg, rgba(0, 172, 193, 0.8), rgba(0, 151, 167, 0.8));
    border-color: #00acc1;
    color: #ffffff;
    font-weight: bold;
    box-shadow: 0 4px 15px rgba(0, 172, 193, 0.3);
    transform: translateX(5px) scale(1.02);
}

#entry:selected #text {
    color: #ffffff;
    font-weight: bold;
}
EOF
            ;;
        "sunset-theme")
            cat > "$WOFI_STYLE" << 'EOF'
/* Main Window */
window {
    margin: 0px;
    border: 2px solid #ff6f00;
    background: rgba(44, 24, 16, 0.95);
    border-radius: 15px;
    backdrop-filter: blur(20px);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    animation: slideIn 0.2s ease-out;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: scale(0.9) translateY(-10px);
    }
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

#outer-box {
    margin: 10px;
    padding: 10px;
    border: none;
    background: transparent;
}

#inner-box {
    margin: 0px;
    padding: 0px;
    border: none;
    background: transparent;
}

#input {
    margin: 5px 10px 15px 10px;
    padding: 12px 15px;
    border: 2px solid rgba(255, 111, 0, 0.3);
    background: rgba(191, 54, 12, 0.6);
    border-radius: 10px;
    color: #fff3e0;
    font-size: 14px;
    font-weight: bold;
    transition: all 0.3s ease;
}

#input:focus {
    border-color: #ff6f00;
    background: rgba(255, 111, 0, 0.4);
    box-shadow: 0 0 15px rgba(255, 111, 0, 0.3);
    outline: none;
}

#scroll {
    margin: 0px 5px;
    border: none;
    background: transparent;
}

#text {
    margin: 0px;
    padding: 8px 12px;
    border: none;
    background: transparent;
    color: #fff3e0;
    font-size: 14px;
    font-weight: 500;
}

#entry {
    margin: 2px 5px;
    padding: 8px;
    border: 1px solid transparent;
    background: rgba(255, 111, 0, 0.2);
    border-radius: 8px;
    transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
    min-height: 40px;
}

#entry:hover {
    background: rgba(255, 111, 0, 0.15);
    border-color: rgba(255, 111, 0, 0.4);
    transform: translateX(3px);
}

#entry:selected {
    background: linear-gradient(45deg, rgba(255, 111, 0, 0.8), rgba(230, 81, 0, 0.8));
    border-color: #ff6f00;
    color: #ffffff;
    font-weight: bold;
    box-shadow: 0 4px 15px rgba(255, 111, 0, 0.3);
    transform: translateX(5px) scale(1.02);
}

#entry:selected #text {
    color: #ffffff;
    font-weight: bold;
}
EOF
            ;;
        *)
            # Default dark theme
            cat > "$WOFI_STYLE" << 'EOF'
/* Main Window */
window {
    margin: 0px;
    border: 2px solid #00d4aa;
    background: rgba(26, 26, 26, 0.95);
    border-radius: 15px;
    backdrop-filter: blur(20px);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    animation: slideIn 0.2s ease-out;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: scale(0.9) translateY(-10px);
    }
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

#outer-box {
    margin: 10px;
    padding: 10px;
    border: none;
    background: transparent;
}

#inner-box {
    margin: 0px;
    padding: 0px;
    border: none;
    background: transparent;
}

#input {
    margin: 5px 10px 15px 10px;
    padding: 12px 15px;
    border: 2px solid rgba(0, 212, 170, 0.3);
    background: rgba(40, 40, 40, 0.8);
    border-radius: 10px;
    color: #ffffff;
    font-size: 14px;
    font-weight: bold;
    transition: all 0.3s ease;
}

#input:focus {
    border-color: #00d4aa;
    background: rgba(50, 50, 50, 0.9);
    box-shadow: 0 0 15px rgba(0, 212, 170, 0.3);
    outline: none;
}

#scroll {
    margin: 0px 5px;
    border: none;
    background: transparent;
}

#text {
    margin: 0px;
    padding: 8px 12px;
    border: none;
    background: transparent;
    color: #ffffff;
    font-size: 14px;
    font-weight: 500;
}

#entry {
    margin: 2px 5px;
    padding: 8px;
    border: 1px solid transparent;
    background: rgba(40, 40, 40, 0.4);
    border-radius: 8px;
    transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
    min-height: 40px;
}

#entry:hover {
    background: rgba(0, 212, 170, 0.15);
    border-color: rgba(0, 212, 170, 0.4);
    transform: translateX(3px);
}

#entry:selected {
    background: linear-gradient(45deg, rgba(0, 212, 170, 0.8), rgba(0, 160, 133, 0.8));
    border-color: #00d4aa;
    color: #1a1a1a;
    font-weight: bold;
    box-shadow: 0 4px 15px rgba(0, 212, 170, 0.3);
    transform: translateX(5px) scale(1.02);
}

#entry:selected #text {
    color: #1a1a1a;
    font-weight: bold;
}
EOF
            ;;
    esac
}

# Get current theme for display
get_current_theme_display() {
    case "$CURRENT_THEME" in
        "light-theme") echo "☀️" ;;
        "ocean-theme") echo "🌊" ;;
        "sunset-theme") echo "🌅" ;;
        *) echo "🌙" ;;
    esac
}

# Main execution
case "$1" in
    "--current")
        get_current_theme_display
        ;;
    "--apply")
        if [[ -n "$2" ]]; then
            apply_theme "$2"
        fi
        ;;
    *)
        show_theme_menu
        ;;
esac