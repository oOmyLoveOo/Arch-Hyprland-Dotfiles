#!/bin/bash
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then
    killall hyprsunset 2>/dev/null
    nohup hyprsunset -t 4000 >/dev/null 2>&1 &
    brightnessctl set 35%
else
    killall hyprsunset 2>/dev/null
    brightnessctl set 70%
fi
