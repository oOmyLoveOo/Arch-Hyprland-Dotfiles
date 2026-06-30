#!/bin/bash

# Absolute paths to avoid failures from systemd/cron contexts
WALL_DIR="$HOME/Pictures/wallpapers"
CURRENT_WALL="$HOME/.config/rofi/.current_wallpaper"
STATIC_DIR="$HOME/.config/wallust/static"
MODE_STATE="$HOME/.cache/wallpaper-mode"

apply_static_colors() {
    cp "$STATIC_DIR/kitty-colors.conf"    ~/.config/kitty/colors.conf
    cp "$STATIC_DIR/hyprland-colors.conf" ~/.config/hypr/colors.conf
    cp "$STATIC_DIR/swaync-colors.css"    ~/.config/swaync/colors.css
    cp "$STATIC_DIR/cava-colors.conf"     ~/.config/cava/config
    cp "$STATIC_DIR/btop-colors.theme"    ~/.config/btop/themes/wallust.theme
    cp "$STATIC_DIR/yazi-colors.toml"     ~/.config/yazi/theme.toml
}

# ==========================================
# MODE 1: RANDOM (random wallpaper + Wallust dynamic colors)
# ==========================================
if [ "$1" == "random" ]; then
    SELECTED_WALL=$(find "$WALL_DIR" -type f | shuf -n 1)
    awww img "$SELECTED_WALL" --transition-type grow --transition-step 90
    ln -sf "$SELECTED_WALL" "$CURRENT_WALL"
    wallust run "$SELECTED_WALL"
    hyprctl reload
    echo "dynamic" > "$MODE_STATE"

# ==========================================
# MODE 2: DYNAMIC (choose wallpaper + Wallust dynamic colors)
# ==========================================
elif [ "$1" == "select-dynamic" ]; then
    SELECTED_NAME=$(ls "$WALL_DIR" | while read A; do echo -en "$A\0icon\x1f$WALL_DIR/$A\n"; done | rofi -dmenu -i -p "Dynamic Wallpapers" -theme "$HOME/.config/rofi/launchers/type-6/wallpaper-style.rasi")

    if [ -n "$SELECTED_NAME" ]; then
        SELECTED_WALL="$WALL_DIR/$SELECTED_NAME"
        awww img "$SELECTED_WALL" --transition-type grow
        ln -sf "$SELECTED_WALL" "$CURRENT_WALL"
        wallust run "$SELECTED_WALL"
        hyprctl reload
        echo "dynamic" > "$MODE_STATE"
    fi

# ==========================================
# MODE 3: STATIC (choose wallpaper + fixed Tokyo Night colors everywhere)
# ==========================================
elif [ "$1" == "select-static" ]; then
    SELECTED_NAME=$(ls "$WALL_DIR" | while read A; do echo -en "$A\0icon\x1f$WALL_DIR/$A\n"; done | rofi -dmenu -i -p "Static Wallpapers" -theme "$HOME/.config/rofi/launchers/type-6/wallpaper-style.rasi")

    if [ -n "$SELECTED_NAME" ]; then
        SELECTED_WALL="$WALL_DIR/$SELECTED_NAME"
        awww img "$SELECTED_WALL" --transition-type grow
        ln -sf "$SELECTED_WALL" "$CURRENT_WALL"

        apply_static_colors
        hyprctl reload

        # Reload kitty without going through Wallust
        killall -SIGUSR1 kitty
        echo "static" > "$MODE_STATE"
    fi

# ==========================================
# MODE 4: REAPPLY (used on startup, respects last saved color mode,
#                   but always rotates to a new random wallpaper)
# ==========================================
elif [ "$1" == "reapply" ]; then
    SAVED_MODE=$(cat "$MODE_STATE" 2>/dev/null || echo "static")
    SELECTED_WALL=$(find "$WALL_DIR" -type f | shuf -n 1)

    awww img "$SELECTED_WALL" --transition-type grow --transition-step 90
    ln -sf "$SELECTED_WALL" "$CURRENT_WALL"

    if [ "$SAVED_MODE" == "dynamic" ]; then
        wallust run "$SELECTED_WALL"
    else
        apply_static_colors
    fi
    hyprctl reload
fi

# Notify Waybar / SwayNC to reload
killall -SIGUSR2 waybar 2>/dev/null
swaync-client -rs 2>/dev/null
