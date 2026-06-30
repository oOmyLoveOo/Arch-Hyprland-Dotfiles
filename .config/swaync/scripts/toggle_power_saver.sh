#!/bin/bash
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then 
    powerprofilesctl set power-saver
    swaync-client -rs
fi
