#!/usr/bin/env bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Select wallpaper using rofi
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | rofi -dmenu -p "Wallpaper" -i)

if [ -n "$SELECTED" ]; then
    # Apply wallpaper with circular expanding animation (outer)
    # --transition-pos 0.5,0.5 centers the circle
    swww img "$SELECTED" \
        --transition-type outer \
        --transition-pos 0.5,0.5 \
        --transition-step 90 \
        --transition-fps 60
    
    # Update Quickshell/System theme here if needed
    # Example: wallust run "$SELECTED"
    # notify-send "Theme Updated" "Wallpaper changed to $(basename "$SELECTED")"
fi
