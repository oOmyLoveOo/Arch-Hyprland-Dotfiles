-- Programs launched once at Hyprland start
-- exec_cmd runs through sh -c, so &, && and ~ work as in a shell.

-- Night/day mode based on current hour (computed in Lua, no bash -c needed)
local hour = tonumber(os.date("%H"))
local night_flag = (hour >= 20 or hour < 7) and "--force-night" or "--force-day"

local startup = {
    -- Indicators / applets
    "nm-applet --indicator",
    "blueman-applet",

    -- Bar and notifications
    "waybar",
    "swaync",

    -- Clipboard history
    "wl-paste --type text --watch cliphist store",
    "wl-paste --type image --watch cliphist store",
    "cliphist list | head -n -100 | cliphist delete",

    -- Cursor theme
    "hyprctl setcursor Bibata-Modern-Ice 24",

    -- Auto-mount removable drives
    "udiskie",

    "sleep 5 && ~/.local/bin/night-mode.sh " .. night_flag,

    -- Auth agent and keyring
    "systemctl --user start hyprpolkitagent",
    "gnome-keyring-daemon --start --components=secrets",

    -- Allow root (sudo/pkexec) to connect to this X/XWayland session,
    -- otherwise GUI apps that self-elevate (e.g. rpi-imager) fail to open
    "xhost +SI:localuser:root",

    -- Wallpaper daemon + random wallpaper on every monitor, Wallust colors
    -- from the laptop's (one ordered pass, no separate wallust run)
    "awww-daemon",
    "sleep 1 && ~/.local/bin/wallpaper_manager.sh startup",

    -- DBus env (required for portals, e.g. screen share / VS Code)
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",

    -- Fix backlight permissions on boot
    "~/.local/bin/fix_backlight.sh",

    -- Warn about launchers of uninstalled apps (Steam games, AppImages) left in rofi
    "sleep 10 && ~/.local/bin/desktop-orphans.sh --notify",

    -- Idle management daemon (lock/suspend/poweroff timers)
    "hypridle",
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(startup) do
        hl.exec_cmd(cmd)
    end
end)
