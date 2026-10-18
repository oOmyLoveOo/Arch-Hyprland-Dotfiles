#!/bin/bash
# Generate SHORTCUTS.md from the live Hyprland binds.
# Descriptions come from conf/keybinds.lua ("Section | what it does").
# Usage: keybinds-md.sh [output]   (default: ~/dotfiles/SHORTCUTS.md)

OUT="${1:-$HOME/dotfiles/SHORTCUTS.md}"

hyprctl binds -j | python3 -c '
import json, sys

MODS = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]
KEYS = {
    "mouse:272": "Left click (drag)", "mouse:273": "Right click (drag)",
    "mouse_down": "Scroll down", "mouse_up": "Scroll up",
    "period": ".", "Tab": "Tab",
    "left": "←", "right": "→", "up": "↑", "down": "↓",
    "XF86AudioRaiseVolume": "Volume Up", "XF86AudioLowerVolume": "Volume Down",
    "XF86AudioMute": "Mute", "XF86AudioMicMute": "Mic Mute",
    "XF86MonBrightnessUp": "Brightness Up", "XF86MonBrightnessDown": "Brightness Down",
    "XF86AudioNext": "Next", "XF86AudioPrev": "Prev",
    "XF86AudioPlay": "Play", "XF86AudioPause": "Pause",
}

sections = {}
for b in json.load(sys.stdin):
    if not b["has_description"] or " | " not in b["description"]:
        continue
    section, desc = b["description"].split(" | ", 1)
    combo = [name for bit, name in MODS if b["modmask"] & bit]
    combo.append(KEYS.get(b["key"], b["key"].upper() if len(b["key"]) == 1 else b["key"]))
    sections.setdefault(section, []).append((" + ".join(combo), desc))

print("# Keyboard shortcuts\n")
print("Generated from the live Hyprland binds by `~/.local/bin/keybinds-md.sh`.")
print("Edit `.config/hypr/conf/keybinds.lua`, then re-run the script.\n")
for section, rows in sections.items():
    print(f"## {section}\n")
    print("| Shortcut | Action |")
    print("| --- | --- |")
    for combo, desc in rows:
        print(f"| `{combo}` | {desc} |")
    print()
' > "$OUT" && echo "Wrote $OUT"
