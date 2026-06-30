#!/bin/bash
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then 
    powerprofilesctl set performance
    swaync-client -rs
fi
