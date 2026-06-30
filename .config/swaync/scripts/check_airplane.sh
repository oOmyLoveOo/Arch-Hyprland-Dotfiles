#!/bin/bash
if LC_ALL=C nmcli radio wifi | grep -q "disabled"; then echo "true"; else echo "false"; fi
