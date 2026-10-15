#!/bin/bash

# Toggle the Arzopa Z1RC between vertical (transform 1) and horizontal (0),
# then give it a random wallpaper matching the new orientation (colors are
# untouched — they keep following the laptop). Runtime-only change:
# monitors.conf restores the vertical default on the next Hyprland start.

MON="DP-1"
MON_RULE="desc:GWD ARZOPA 0x28320206, preferred, auto-right, 1.6, transform"
WALL_DIR="$HOME/Pictures/wallpapers"
VERT_DIR="$HOME/Pictures/wallpapers-vertical"

current=$(hyprctl monitors | awk -v mon="$MON" \
    '$1 == "Monitor" { in_mon = ($2 == mon) }
     in_mon && $1 == "transform:" { print $2; exit }')

if [ -z "$current" ]; then
    notify-send "Monitor" "Arzopa not connected" -i video-display
    exit 1
fi

if [ "$current" == "1" ]; then
    new=0
    label="horizontal"
else
    new=1
    label="vertical"
fi

hyprctl keyword monitor "$MON_RULE, $new"
sleep 0.5

# Pick the wallpaper folder matching the new orientation
if [ "$new" == "1" ] && [ -n "$(ls -A "$VERT_DIR" 2>/dev/null)" ]; then
    SEL_DIR="$VERT_DIR"
else
    SEL_DIR="$WALL_DIR"
fi
WALL=$(find "$SEL_DIR" -type f | shuf -n 1)
if [ -n "$WALL" ]; then
    awww img "$WALL" -o "$MON" --transition-type grow
    ln -sf "$WALL" "$HOME/.config/rofi/.current_wallpaper_second"
fi

# Swap the Waybar layout: horizontal gets the fuller Arzopa bar
if [ "$new" == "0" ]; then
    WAYBAR_CONF="$HOME/.config/waybar/config-horizontal.jsonc"
else
    WAYBAR_CONF="$HOME/.config/waybar/config.jsonc"
fi
killall waybar 2>/dev/null
sleep 0.3
hyprctl dispatch exec "waybar -c $WAYBAR_CONF"

notify-send "Monitor" "Arzopa rotated to $label" -i video-display
