-- Keybindings
-- Every bind carries a "Section | what it does" description, read back with
-- `hyprctl binds -j` by ~/.local/bin/keybinds.sh (Super + H menu, SHORTCUTS.md).

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "~/.config/rofi/launchers/type-6/launcher.sh"
local rofiTheme   = "~/.config/rofi/launchers/type-6/style-1.rasi"

-- Section used for the descriptions of the binds declared after it
local section = ""

-- key("SHIFT + S") -> "SUPER + SHIFT + S"
local function key(combo)
    return mainMod .. " + " .. combo
end

local function bind(combo, dispatcher, desc, opts)
    opts = opts or {}
    opts.description = section .. " | " .. desc
    hl.bind(combo, dispatcher, opts)
end

local function exec(combo, cmd, desc, opts)
    bind(key(combo), hl.dsp.exec_cmd(cmd), desc, opts)
end

section = "Apps"
exec("H", "~/.local/bin/keybinds.sh menu", "Shortcut cheat sheet (this list)")
exec("T", terminal, "Terminal (kitty)")
exec("E", fileManager, "File manager (thunar)")
exec("A", menu, "App launcher")
exec("L", "hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf", "Lock screen")
exec("SHIFT + S", 'grim -g "$(slurp)" - | tee >(wl-copy) | swappy -f -', "Screenshot a region (copy + edit)")
exec("SHIFT + O", "prime-run obs", "OBS on the NVIDIA GPU")
exec("M", "~/.config/rofi/powermenu/type-5/powermenu.sh", "Power menu")
exec("V", "cliphist list | rofi -dmenu -theme " .. rofiTheme .. " | cliphist decode | wl-copy", "Clipboard history")
exec("N", "~/.local/bin/night-mode.sh", "Toggle night mode")
-- Long string keeps the backslash-escaped quotes rofi expects
exec("period", [[rofimoji --action type --hidden-descriptions --selector-args "-theme ]] .. rofiTheme .. [[ -theme-str 'listview {columns: 6; lines: 6;} element {orientation: vertical; padding: 20px;} element-text {font: \"Noto Color Emoji 15\"; horizontal-align: 0.5; vertical-align: 0.5;}'"]], "Emoji picker")

section = "Wallpapers"
exec("R", "~/.local/bin/wallpaper_manager.sh random", "Random wallpaper on the focused monitor (dynamic colors)")
exec("W", "~/.local/bin/wallpaper_manager.sh select-static", "Pick wallpaper, static Tokyo Night colors")
exec("SHIFT + W", "~/.local/bin/wallpaper_manager.sh select-dynamic", "Pick wallpaper, colors from the image")
exec("CTRL + W", "~/.local/bin/wallpaper_manager.sh select-second", "Pick wallpaper for the Arzopa")
exec("ALT + W", "find ~/Pictures/wallpapers-animated -type f | shuf -n 1 | xargs -I {} awww img {} --transition-type grow", "Random animated wallpaper")
exec("O", "~/.local/bin/monitor_rotate.sh", "Rotate Arzopa vertical/horizontal")

section = "Windows"
bind(key("Q"), hl.dsp.window.close(), "Close window")
bind(key("F"), hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(key("P"), hl.dsp.window.pseudo(), "Toggle pseudotiling")
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind(key(dir), hl.dsp.focus({ direction = dir }), "Focus window " .. dir)
end
bind(key("CTRL + left"),  hl.dsp.window.move({ monitor = "l" }), "Send window to the left monitor")
bind(key("CTRL + right"), hl.dsp.window.move({ monitor = "r" }), "Send window to the right monitor")
bind(key("mouse:272"), hl.dsp.window.drag(),   "Drag to move window",   { mouse = true })
bind(key("mouse:273"), hl.dsp.window.resize(), "Drag to resize window", { mouse = true })

section = "Workspaces"
-- Workspaces 1-10 (key 0 = workspace 10)
for i = 1, 10 do
    local k = tostring(i % 10)
    bind(key(k),              hl.dsp.focus({ workspace = i }),       "Go to workspace " .. i)
    bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
end
bind(key("X"),          hl.dsp.workspace.toggle_special("magic"),            "Toggle scratchpad")
bind(key("SHIFT + X"),  hl.dsp.window.move({ workspace = "special:magic" }), "Move window to scratchpad")
bind(key("Tab"),        hl.dsp.focus({ workspace = "previous" }),            "Previous workspace")
bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }),                 "Next workspace (scroll)")
bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }),                 "Previous workspace (scroll)")

section = "Media"
-- swayosd-client changes the value and shows the on-screen indicator
-- (swayosd-server, started in autostart). { key, command, description, repeats while held }
local osd = "swayosd-client "
local media = {
    { "XF86AudioRaiseVolume",  osd .. "--output-volume raise",      "Volume up",       true },
    { "XF86AudioLowerVolume",  osd .. "--output-volume lower",      "Volume down",     true },
    { "XF86AudioMute",         osd .. "--output-volume mute-toggle", "Mute",           false },
    { "XF86AudioMicMute",      osd .. "--input-volume mute-toggle",  "Mute microphone", false },
    { "XF86MonBrightnessUp",   osd .. "--brightness raise",          "Brightness up",   true },
    { "XF86MonBrightnessDown", osd .. "--brightness lower",          "Brightness down", true },
    { "XF86AudioNext",         osd .. "--playerctl next",            "Next track",      false },
    { "XF86AudioPause",        osd .. "--playerctl play-pause",      "Play/pause",      false },
    { "XF86AudioPlay",         osd .. "--playerctl play-pause",      "Play/pause",      false },
    { "XF86AudioPrev",         osd .. "--playerctl prev",            "Previous track",  false },
}
for _, m in ipairs(media) do
    bind(m[1], hl.dsp.exec_cmd(m[2]), m[3], { locked = true, repeating = m[4] })
end
