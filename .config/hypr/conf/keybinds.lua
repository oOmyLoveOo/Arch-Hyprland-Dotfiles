-- Keybindings

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "~/.config/rofi/launchers/type-6/launcher.sh"
local rofiTheme   = "~/.config/rofi/launchers/type-6/style-1.rasi"

-- bind("SHIFT + S", ...) -> "SUPER + SHIFT + S"; bind("", ...) -> "SUPER"
local function key(combo)
    return combo == "" and mainMod or (mainMod .. " + " .. combo)
end

local function exec(combo, cmd, opts)
    hl.bind(key(combo), hl.dsp.exec_cmd(cmd), opts)
end

-- Launch apps
exec("T", terminal)
exec("E", fileManager)
exec("A", menu)
exec("L", "hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf")
exec("SHIFT + S", 'grim -g "$(slurp)" - | tee >(wl-copy) | swappy -f -')
exec("SHIFT + O", "prime-run obs")
exec("M", "~/.config/rofi/powermenu/type-5/powermenu.sh")

-- Wallpapers
exec("R", "~/.local/bin/wallpaper_manager.sh random")
exec("W", "~/.local/bin/wallpaper_manager.sh select-static")
exec("SHIFT + W", "~/.local/bin/wallpaper_manager.sh select-dynamic")
exec("ALT + W", "find ~/Pictures/wallpapers-animated -type f | shuf -n 1 | xargs -I {} awww img {} --transition-type grow")
exec("CTRL + W", "~/.local/bin/wallpaper_manager.sh select-second")
exec("O", "~/.local/bin/monitor_rotate.sh") -- Toggle Arzopa vertical/horizontal

-- Window management
hl.bind(key("Q"), hl.dsp.window.close())
hl.bind(key("F"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("P"), hl.dsp.window.pseudo())

-- Focus movement
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(key(dir), hl.dsp.focus({ direction = dir }))
end

-- Send active window to the monitor in that direction
hl.bind(key("CTRL + left"),  hl.dsp.window.move({ monitor = "l" }))
hl.bind(key("CTRL + right"), hl.dsp.window.move({ monitor = "r" }))

-- Workspaces 1-10 (key 0 = workspace 10)
for i = 1, 10 do
    local k = tostring(i % 10)
    hl.bind(key(k),             hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(key("X"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("SHIFT + X"), hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(key("Tab"),        hl.dsp.focus({ workspace = "previous" }))

-- Mouse drag (LMB move, RMB resize)
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Media keys (bindel = locked + repeating, bindl = locked)
local media = {
    XF86AudioRaiseVolume  = { "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", true },
    XF86AudioLowerVolume  = { "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",      true },
    XF86AudioMute         = { "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",     true },
    XF86AudioMicMute      = { "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",   true },
    XF86MonBrightnessUp   = { "brightnessctl -e4 -n2 set 5%+",                  true },
    XF86MonBrightnessDown = { "brightnessctl -e4 -n2 set 5%-",                  true },
    XF86AudioNext         = { "playerctl next",       false },
    XF86AudioPause        = { "playerctl play-pause", false },
    XF86AudioPlay         = { "playerctl play-pause", false },
    XF86AudioPrev         = { "playerctl previous",   false },
}

for k, m in pairs(media) do
    hl.bind(k, hl.dsp.exec_cmd(m[1]), { locked = true, repeating = m[2] })
end

-- Clipboard
exec("V", "cliphist list | rofi -dmenu -theme " .. rofiTheme .. " | cliphist decode | wl-copy")

-- Night mode toggle
exec("N", "~/.local/bin/night-mode.sh")

-- Emoji picker (long string keeps the backslash-escaped quotes rofi expects)
exec("period", [[rofimoji --action type --hidden-descriptions --selector-args "-theme ]] .. rofiTheme .. [[ -theme-str 'listview {columns: 6; lines: 6;} element {orientation: vertical; padding: 20px;} element-text {font: \"Noto Color Emoji 15\"; horizontal-align: 0.5; vertical-align: 0.5;}'"]])
