#!/bin/bash
if powerprofilesctl get | grep -q "balanced"; then echo "true"; else echo "false"; fi
