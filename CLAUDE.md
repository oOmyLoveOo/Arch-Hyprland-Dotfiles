# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal Arch Linux + Hyprland dotfiles, managed with **GNU Stow**. The entire repo root is stowed into `$HOME` (`stow --target="$HOME" .`), so `.config/`, `.local/bin/`, `.zshrc`, etc. mirror their home-directory locations. `.stow-local-ignore` excludes `install.sh`, the readme, and git files from stowing.

**Critical: Stow symlinks.** Files under `$HOME` (e.g. `~/.config/hypr/...`) are symlinks into this repo. Never use `sed -i` on them without `--follow-symlinks`, or the symlink gets replaced by a plain file and the Stow link breaks. Editing files by their repo path (`~/dotfiles/...`) with Edit/Write is safe.

## Commands

- `./install.sh` — full setup on a fresh machine: enables multilib, installs packages from `arch_resource/pkglist_{native,aur,flatpak}.txt`, sets up Oh My Zsh/Powerlevel10k, stows, fixes script permissions, applies default colors.
- `stow --target="$HOME" --restow .` (from repo root) — (re)link configs only.
- `~/.local/bin/wallpaper_manager.sh {random|select-dynamic|select-static|reapply}` — apply wallpaper + color scheme.
- `~/.local/bin/backup.sh` — external-disk backup; also regenerates the `arch_resource/pkglist_*.txt` files (they are output of this script, not hand-maintained).
- Reload after config edits: `hyprctl reload` (Hyprland), `killall -SIGUSR2 waybar` (Waybar), `swaync-client -rs` (SwayNC), `killall -SIGUSR1 kitty` (Kitty colors).

There are no builds, tests, or linters — everything is config files and bash scripts.

## Theming architecture (the part that spans many files)

Two switchable color modes, orchestrated by `.local/bin/wallpaper_manager.sh` and persisted in `~/.cache/wallpaper-mode`:

- **Dynamic**: `wallust run <image>` renders the templates in `.config/wallust/templates/` (mapped by `.config/wallust/wallust.toml`) into per-app target files.
- **Static**: fixed Tokyo Night color files in `.config/wallust/static/` are copied over those same targets.

The **targets are generated files and are gitignored** — never edit or commit them:
`kitty/colors.conf`, `hypr/conf/colors.lua`, `swaync/colors.css`, `cava/config`, `btop/themes/wallust.theme`, `yazi/theme.toml`. To change colors, edit the corresponding file in `wallust/templates/` (dynamic mode) and/or `wallust/static/` (static mode) — usually both, so the modes stay in sync. After changing a target mapping in `wallust.toml`, also update `apply_static_colors()` in `wallpaper_manager.sh` and `.gitignore`.

App configs reference the generated files by sourcing/importing them (e.g. `hypr/conf/general.lua` loads `colors.lua` with `dofile`, kitty `include colors.conf`), so the rest of each config stays static and versioned.

## Structure notes

- **Hyprland** uses the Lua config (0.55+): `.config/hypr/hyprland.lua` only `require`s `.config/hypr/conf/*.lua` (keybinds, monitors, autostart, windowrules, etc.). Edit the piece, not the entry point. Validate with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` before reloading.
  - Hyprland resolves the Stow symlink, so `require()` searches `~/dotfiles/.config/hypr/`. Generated files that live outside the repo (like `colors.lua`) must be loaded by absolute path with `dofile`.
  - In Lua mode `hyprctl dispatch` takes Lua (`hyprctl dispatch 'hl.dsp.exit()'`) and `hyprctl eval` runs arbitrary Lua; the legacy `hyprctl dispatch workspace 1` / `hyprctl keyword` syntax no longer works. Scripts, Waybar and hypridle must use the Lua form.
  - `hypridle.conf` and `hyprlock/hyprlock.conf` keep their own hyprlang format; only Hyprland itself moved to Lua. The last hyprlang config is tagged `hyprlang-final`.
- **Waybar**: `config.jsonc` includes `modules/{left,center,right}.jsonc`; styling in `style.css`.
- **SwayNC** control-center toggles are paired scripts in `.config/swaync/scripts/` (`check_X.sh` reports state, `toggle_X.sh` switches it), wired up in `config.json`.
- **Rofi** launcher/powermenu themes live under `.config/rofi/launchers/type-6/` and `.config/rofi/powermenu/` (based on Adi1090x's collection).
- Scripts in `.local/bin/` must stay executable; rofi/swaync scripts too (`install.sh` re-applies permissions).
