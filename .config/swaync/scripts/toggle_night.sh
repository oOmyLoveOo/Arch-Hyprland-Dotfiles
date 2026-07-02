#!/bin/bash
# Delegates to night-mode.sh so the on/off behavior lives in one place
# instead of being reimplemented (and able to drift) here.
if [[ $SWAYNC_TOGGLE_STATE == true ]]; then
    "$HOME/.local/bin/night-mode.sh" --force-night
else
    "$HOME/.local/bin/night-mode.sh" --force-day
fi
