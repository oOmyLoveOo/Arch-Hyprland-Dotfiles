#!/bin/bash
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then 
    powerprofilesctl set balanced
    swaync-client -rs
fi
