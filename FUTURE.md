# Future ideas

Parked on purpose: worth doing once the situation changes, not before.

## Pentest mode (when moving offensive work to native Arch)

Today offensive work lives in the Kali VM (isolation + snapshots). If web
bug bounty moves to native Arch, a Hyprland "pentest mode" makes sense:

- One bind (submap) switches the rice into an engagement layout: border
  colors change, Burp/Caido, a terminal and Obsidian open in fixed spots.
- Mode-only binds (copy target IP, start/stop logging, screenshot to the
  engagement folder created by `init-target.sh`).
- Waybar module: `tun0` IP when the HTB/VPN is up and the current target set
  by `init-target.sh`, click to copy.
- Keep heavy AD/network tooling (impacket, responder, random GitHub
  exploits) in a VM or container even then: they run as root next to SSH
  keys, the vault and browser sessions.

## Game mode (with a more powerful machine)

`Super + G` toggles a performance profile from Lua: gaps, borders, blur,
shadows and animations off for games or OBS recording, everything restored
on the second press. `conf/powersave.lua` already shows the pattern.

## Neovim for offensive work

Decided against for now. If it comes back: kulala.nvim (`.http` request
files with variables, good for IDOR/BAC replay), obsidian.nvim for the
vault, and small Lua helpers to base64/URL/JWT-decode a selection.
