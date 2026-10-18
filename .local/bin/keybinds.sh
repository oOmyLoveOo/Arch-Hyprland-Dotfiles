#!/bin/bash
# Keybind reference built from the live Hyprland binds.
# Descriptions come from conf/keybinds.lua ("Section | what it does").
#
#   keybinds.sh menu         searchable rofi cheat sheet (Super + H)
#   keybinds.sh md [output]  write SHORTCUTS.md (default: ~/dotfiles/SHORTCUTS.md)

ROFI_THEME="$HOME/.config/rofi/launchers/type-6/style-1.rasi"

# Print "Section<TAB>Combo<TAB>Description" for every described bind
list_binds() {
    hyprctl binds -j | python3 -c '
import json, sys

MODS = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]
KEYS = {
    "mouse:272": "Left click (drag)", "mouse:273": "Right click (drag)",
    "mouse_down": "Scroll down", "mouse_up": "Scroll up",
    "period": ".", "slash": "/",
    "left": "←", "right": "→", "up": "↑", "down": "↓",
    "XF86AudioRaiseVolume": "Volume Up", "XF86AudioLowerVolume": "Volume Down",
    "XF86AudioMute": "Mute", "XF86AudioMicMute": "Mic Mute",
    "XF86MonBrightnessUp": "Brightness Up", "XF86MonBrightnessDown": "Brightness Down",
    "XF86AudioNext": "Next", "XF86AudioPrev": "Prev", "XF86TouchpadToggle": "Touchpad Toggle",
    "XF86AudioPlay": "Play", "XF86AudioPause": "Pause",
}

for b in json.load(sys.stdin):
    if not b["has_description"] or " | " not in b["description"]:
        continue
    section, desc = b["description"].split(" | ", 1)
    combo = [name for bit, name in MODS if b["modmask"] & bit]
    combo.append(KEYS.get(b["key"], b["key"].upper() if len(b["key"]) == 1 else b["key"]))
    print(section, " + ".join(combo), desc, sep="\t")
'
}

case "$1" in
    menu)
        # Toggle: a second Super + H closes the open menu
        pkill -x rofi && exit 0
        # The theme's image panel would take half the width: list only.
        # A rotated (vertical) monitor gets a narrower layout without the
        # section column.
        transform=$(hyprctl monitors -j | python3 -c '
import json, sys
print(next((m["transform"] for m in json.load(sys.stdin) if m["focused"]), 0))')
        if [ "$transform" == "1" ] || [ "$transform" == "3" ]; then
            vertical=1; width="95%"; font=10
        else
            vertical=0; width="1150px"; font=11
        fi
        list_binds | awk -F'\t' -v vertical="$vertical" '{
                if (vertical) printf "%-26s  %s\n", $2, $3
                else          printf "%-11s  %-28s  %s\n", $1, $2, $3
            }' \
            | rofi -dmenu -i -p "Shortcuts" -no-custom -theme "$ROFI_THEME" \
                   -theme-str "window { width: $width; } mainbox { children: [ \"listbox\" ]; } listview { lines: 14; } element-text { font: \"JetBrainsMono Nerd Font $font\"; }" \
            > /dev/null
        ;;
    md)
        OUT="${2:-$HOME/dotfiles/SHORTCUTS.md}"
        list_binds | python3 -c '
import sys
sections = {}
for line in sys.stdin:
    section, combo, desc = line.rstrip("\n").split("\t")
    sections.setdefault(section, []).append((combo, desc))
print("# Keyboard shortcuts\n")
print("Generated from the live Hyprland binds by `~/.local/bin/keybinds.sh md`.")
print("Edit `.config/hypr/conf/keybinds.lua`, then re-run the script.")
print("Press `Super + H` for a searchable version of this list.\n")
for section, rows in sections.items():
    print(f"## {section}\n")
    print("| Shortcut | Action |")
    print("| --- | --- |")
    for combo, desc in rows:
        print(f"| `{combo}` | {desc} |")
    print()
' > "$OUT" && echo "Wrote $OUT"
        ;;
    *)
        echo "Usage: $0 {menu|md [output]}" >&2
        exit 1
        ;;
esac
