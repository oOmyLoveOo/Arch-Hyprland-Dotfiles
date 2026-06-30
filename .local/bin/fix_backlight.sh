#!/bin/bash
# Detect the active backlight device and patch it into swaync's config,
# since the device name (amdgpu_bl1, amdgpu_bl2, etc.) can change between boots.
#
# IMPORTANT: uses --follow-symlinks so sed edits the real file in place
# instead of replacing the symlink with a new regular file (which would
# break the stow-managed link between ~/.config/swaync and ~/dotfiles).

# 1. Wait for backlight drivers to settle
sleep 1

# 2. Read the current device name
ACTUAL_BL=$(ls /sys/class/backlight/ | head -n 1)

# 3. Patch the device field in swaync's config.json, preserving the symlink
sed -i --follow-symlinks "s/\"device\": \".*\"/\"device\": \"$ACTUAL_BL\"/" ~/.config/swaync/config.json

# 4. Force SwayNC to reload the new config
swaync-client -R
swaync-client -rs
