#!/bin/bash
# Each radio is toggled independently so a failure on one (e.g. nmcli)
# doesn't silently leave the other one untouched.
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then
    nmcli radio wifi off || echo "!! Failed to disable wifi radio" >&2
    bluetoothctl power off || echo "!! Failed to disable bluetooth" >&2
else
    nmcli radio wifi on || echo "!! Failed to enable wifi radio" >&2
    bluetoothctl power on || echo "!! Failed to enable bluetooth" >&2
fi
