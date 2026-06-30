#!/bin/bash
if LC_ALL=C pactl get-sink-mute @DEFAULT_SINK@ | grep -q "Mute: yes"; then echo "true"; else echo "false"; fi
