#!/bin/bash
if powerprofilesctl get | grep -q "performance"; then echo "true"; else echo "false"; fi
