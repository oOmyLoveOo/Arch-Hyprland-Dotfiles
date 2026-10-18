#!/bin/bash
# Called by Hyprland (conf/privacy.lua) on screenshare.state.
# start: remember the current Do Not Disturb state and turn DND on, so no
#        notification pops up in front of whoever is watching.
# stop:  restore the DND state from before the share.

STATE="${XDG_RUNTIME_DIR:-/tmp}/screenshare-dnd-before"

case "$1" in
    start)
        # Several shares can overlap; only save the state on the first one
        [ -f "$STATE" ] || swaync-client -D > "$STATE"
        swaync-client -dn > /dev/null
        ;;
    stop)
        [ -f "$STATE" ] || exit 0
        [ "$(cat "$STATE")" == "false" ] && swaync-client -df > /dev/null
        rm -f "$STATE"
        ;;
    *)
        echo "Usage: $0 {start|stop}" >&2
        exit 1
        ;;
esac
