#!/bin/bash
# Run by Hyprland (conf/monitors.lua, monitor.added) when the Arzopa is
# plugged in. monitors.lua has already forced it back to vertical; this
# gives it the vertical Waybar layout and a wallpaper of its own.
# Usage: arzopa-plugged.sh <monitor-name>

MON="${1:-DP-1}"

# At session start the autostart already handles every monitor
HYPR_PID=$(pgrep -x Hyprland | head -1)
[ -n "$HYPR_PID" ] && [ "$(ps -o etimes= -p "$HYPR_PID")" -lt 20 ] && exit 0

# Let the output finish its modeset before drawing on it
sleep 1

# The horizontal layout may still be running if it was unplugged rotated
if pgrep -af '^waybar' | grep -q 'config-horizontal'; then
    killall waybar 2>/dev/null
    sleep 0.3
    hyprctl dispatch "hl.dsp.exec_cmd('waybar')" > /dev/null
fi

"$HOME/.local/bin/wallpaper_manager.sh" monitor "$MON"
