#!/bin/bash
if LC_ALL=C bluetoothctl show | grep -q "Powered: yes"; then echo "true"; else echo "false"; fi
