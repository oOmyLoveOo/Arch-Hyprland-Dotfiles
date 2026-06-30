#!/bin/bash
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then
    nmcli radio wifi off && bluetoothctl power off
else
    nmcli radio wifi on && bluetoothctl power on
fi
