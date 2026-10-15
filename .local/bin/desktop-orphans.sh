#!/bin/bash

# Find user .desktop launchers whose program no longer exists.
# Pacman removes its own launchers (/usr/share/applications), but Steam games
# and manual/AppImage installs leave theirs behind in ~/.local/share/applications,
# so uninstalled apps keep showing up in rofi.
#
# Usage:
#   desktop-orphans.sh           list orphans
#   desktop-orphans.sh --clean   delete orphans and rebuild the MIME cache
#   desktop-orphans.sh --notify  send a notification if orphans exist (autostart)

APP_DIR="$HOME/.local/share/applications"
STEAM_ROOT="$HOME/.local/share/Steam"

# Every steamapps dir across all Steam libraries (extra drives included)
steam_libs() {
    echo "$STEAM_ROOT/steamapps"
    local vdf="$STEAM_ROOT/steamapps/libraryfolders.vdf"
    [ -f "$vdf" ] && awk -F'"' '$2 == "path" { print $4 "/steamapps" }' "$vdf"
}

steam_game_installed() {
    local id="$1" lib
    while read -r lib; do
        [ -f "$lib/appmanifest_$id.acf" ] && return 0
    done < <(steam_libs | sort -u)
    return 1
}

# Print the reason if the launcher is orphaned, nothing otherwise
check_entry() {
    local file="$1" exec_line exe id
    exec_line=$(grep -m1 '^Exec=' "$file" | cut -d= -f2-)
    [ -z "$exec_line" ] && return

    # Steam game launchers: the game is gone when its manifest is gone
    if [[ "$exec_line" =~ steam://rungameid/([0-9]+) ]]; then
        id="${BASH_REMATCH[1]}"
        steam_game_installed "$id" || echo "Steam game $id not installed"
        return
    fi

    # First real word of Exec, skipping "env VAR=value" prefixes and quotes
    read -ra words <<< "$exec_line"
    for exe in "${words[@]}"; do
        [[ "$exe" == env || "$exe" == *=* ]] && continue
        break
    done
    exe="${exe//\"/}"

    if [[ "$exe" == /* ]]; then
        [ -e "$exe" ] || echo "missing $exe"
    else
        command -v "$exe" >/dev/null || echo "command '$exe' not found"
    fi
}

orphans=()
while IFS= read -r -d '' file; do
    reason=$(check_entry "$file")
    [ -n "$reason" ] && orphans+=("$file") && echo "$(basename "$file")  ->  $reason"
done < <(find "$APP_DIR" -maxdepth 1 -name '*.desktop' -print0 2>/dev/null)

[ ${#orphans[@]} -eq 0 ] && { [ "$1" != "--notify" ] && echo "No orphan launchers."; exit 0; }

case "$1" in
    --clean)
        rm -v -- "${orphans[@]}"
        update-desktop-database "$APP_DIR"
        ;;
    --notify)
        notify-send -a "desktop-orphans" "Orphan launchers in rofi" \
            "${#orphans[@]} app(s) no longer installed. Run: desktop-orphans.sh --clean"
        ;;
esac
