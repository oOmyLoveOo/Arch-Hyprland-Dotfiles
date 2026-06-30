#!/bin/bash
if LC_ALL=C nmcli radio wifi | grep -q "enabled"; then echo "true"; else echo "false"; fi
