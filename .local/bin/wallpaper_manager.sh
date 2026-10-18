#!/bin/bash

# Absolute paths to avoid failures from systemd/cron contexts
WALL_DIR="$HOME/Pictures/wallpapers"
VERT_DIR="$HOME/Pictures/wallpapers-vertical"
CURRENT_WALL="$HOME/.config/rofi/.current_wallpaper"                 # laptop — drives colors + rofi backgrounds
CURRENT_WALL_SECOND="$HOME/.config/rofi/.current_wallpaper_second"   # Arzopa — rofi background only
MAIN_MON="eDP-1"
SECOND_MON="DP-1"   # Arzopa Z1RC over USB-C
STATIC_DIR="$HOME/.config/wallust/static"
MODE_STATE="$HOME/.cache/wallpaper-mode"
ROFI_DIR="$HOME/.config/rofi/launchers/type-6"

apply_static_colors() {
    cp "$STATIC_DIR/kitty-colors.conf"    ~/.config/kitty/colors.conf
    cp "$STATIC_DIR/hyprland-colors.lua"  ~/.config/hypr/conf/colors.lua
    cp "$STATIC_DIR/swaync-colors.css"    ~/.config/swaync/colors.css
    cp "$STATIC_DIR/cava-colors.conf"     ~/.config/cava/config
    cp "$STATIC_DIR/btop-colors.theme"    ~/.config/btop/themes/wallust.theme
    cp "$STATIC_DIR/yazi-colors.toml"     ~/.config/yazi/theme.toml
}

# Monitor that currently has the focus — every mode acts only on it
focused_mon() {
    hyprctl monitors | awk '$1 == "Monitor" { m = $2 } /focused: yes/ { print m; exit }'
}

transform_of() {
    hyprctl monitors | awk -v mon="$1" \
        '$1 == "Monitor" { in_mon = ($2 == mon) }
         in_mon && $1 == "transform:" { print $2; exit }'
}

is_vertical() {
    local t
    t=$(transform_of "$1")
    [ "$t" == "1" ] || [ "$t" == "3" ]
}

# Wallpaper dir for a given monitor: the vertical folder when the monitor
# is rotated and the folder has images, main folder otherwise
wall_dir_for() {
    if is_vertical "$1" && [ -n "$(ls -A "$VERT_DIR" 2>/dev/null)" ]; then
        echo "$VERT_DIR"
    else
        echo "$WALL_DIR"
    fi
}

# Rofi theme when picking for monitor $1: the preview shows that monitor's
# current wallpaper; the layout matches the monitor rofi opens on (focused)
theme_for() {
    if [ "$1" == "$MAIN_MON" ]; then
        echo "$ROFI_DIR/wallpaper-style.rasi"
    elif is_vertical "$(focused_mon)"; then
        echo "$ROFI_DIR/wallpaper-style-vertical.rasi"
    else
        echo "$ROFI_DIR/wallpaper-style-second.rasi"
    fi
}

# Remember each monitor's current wallpaper (used as rofi backgrounds)
track_wall() {
    if [ "$1" == "$MAIN_MON" ]; then
        ln -sf "$2" "$CURRENT_WALL"
    else
        ln -sf "$2" "$CURRENT_WALL_SECOND"
    fi
}

# ==========================================
# MODE 1: RANDOM (random wallpaper on the focused monitor + Wallust colors)
# ==========================================
if [ "$1" == "random" ]; then
    MON=$(focused_mon)
    SELECTED_WALL=$(find "$(wall_dir_for "$MON")" -type f | shuf -n 1)
    awww img "$SELECTED_WALL" -o "$MON" --transition-type grow --transition-step 90
    track_wall "$MON" "$SELECTED_WALL"
    # Colors always follow the laptop wallpaper: on any other monitor the
    # mode only swaps that screen's image
    if [ "$MON" == "$MAIN_MON" ]; then
        wallust run "$SELECTED_WALL"
        hyprctl reload
        echo "dynamic" > "$MODE_STATE"
    fi

# ==========================================
# MODE 2: DYNAMIC (choose wallpaper for the focused monitor + Wallust colors)
# ==========================================
elif [ "$1" == "select-dynamic" ]; then
    MON=$(focused_mon)
    SEL_DIR=$(wall_dir_for "$MON")
    SELECTED_NAME=$(ls "$SEL_DIR" | while read A; do echo -en "$A\0icon\x1f$SEL_DIR/$A\n"; done | rofi -dmenu -i -p "Dynamic Wallpapers ($MON)" -theme "$(theme_for "$MON")")

    if [ -n "$SELECTED_NAME" ]; then
        SELECTED_WALL="$SEL_DIR/$SELECTED_NAME"
        awww img "$SELECTED_WALL" -o "$MON" --transition-type grow
        track_wall "$MON" "$SELECTED_WALL"
        # Colors always follow the laptop wallpaper
        if [ "$MON" == "$MAIN_MON" ]; then
            wallust run "$SELECTED_WALL"
            hyprctl reload
            echo "dynamic" > "$MODE_STATE"
        fi
    fi

# ==========================================
# MODE 3: STATIC (choose wallpaper for the focused monitor + fixed Tokyo
#                 Night colors everywhere)
# ==========================================
elif [ "$1" == "select-static" ]; then
    MON=$(focused_mon)
    SEL_DIR=$(wall_dir_for "$MON")
    SELECTED_NAME=$(ls "$SEL_DIR" | while read A; do echo -en "$A\0icon\x1f$SEL_DIR/$A\n"; done | rofi -dmenu -i -p "Static Wallpapers ($MON)" -theme "$(theme_for "$MON")")

    if [ -n "$SELECTED_NAME" ]; then
        SELECTED_WALL="$SEL_DIR/$SELECTED_NAME"
        awww img "$SELECTED_WALL" -o "$MON" --transition-type grow
        track_wall "$MON" "$SELECTED_WALL"
        # Colors always follow the laptop wallpaper
        if [ "$MON" == "$MAIN_MON" ]; then
            apply_static_colors
            hyprctl reload

            # Reload kitty without going through Wallust
            killall -SIGUSR1 kitty
            echo "static" > "$MODE_STATE"
        fi
    fi

# ==========================================
# MODE 4: SECOND SCREEN (choose a wallpaper for the external monitor only,
#                        from wherever it is launched; colors/Wallust are
#                        untouched — they keep following the laptop)
# ==========================================
elif [ "$1" == "select-second" ]; then
    SEL_DIR=$(wall_dir_for "$SECOND_MON")
    SELECTED_NAME=$(ls "$SEL_DIR" | while read A; do echo -en "$A\0icon\x1f$SEL_DIR/$A\n"; done | rofi -dmenu -i -p "Second Screen" -theme "$(theme_for "$SECOND_MON")")

    if [ -n "$SELECTED_NAME" ]; then
        awww img "$SEL_DIR/$SELECTED_NAME" -o "$SECOND_MON" --transition-type grow
        track_wall "$SECOND_MON" "$SEL_DIR/$SELECTED_NAME"
    fi

# ==========================================
# MODE 5: REAPPLY (used on startup, respects last saved color mode; gives
#                  every connected monitor a random wallpaper from its
#                  orientation-matching folder, colors follow the laptop's)
# ==========================================
elif [ "$1" == "reapply" ]; then
    SAVED_MODE=$(cat "$MODE_STATE" 2>/dev/null || echo "static")

    SELECTED_WALL=""
    for MON in $(hyprctl monitors | awk '$1 == "Monitor" { print $2 }'); do
        WALL=$(find "$(wall_dir_for "$MON")" -type f | shuf -n 1)
        [ -z "$WALL" ] && continue
        awww img "$WALL" -o "$MON" --transition-type grow --transition-step 90
        track_wall "$MON" "$WALL"
        [ "$MON" == "$MAIN_MON" ] && SELECTED_WALL="$WALL"
    done
    [ -z "$SELECTED_WALL" ] && SELECTED_WALL="$WALL"

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
