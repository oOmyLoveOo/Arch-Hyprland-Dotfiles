-- Window rules

-- Ignore maximize requests from all apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag issues on empty class/title windows
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Per-app transparency: class -> "active inactive"
local transparency = {
    vesktop  = "0.90 0.80",
    thunar   = "0.8 0.8",
    firefox  = "0.95 0.95",
    code     = "0.9 0.9",
    obsidian = "0.90 0.9",
}

for class, opacity in pairs(transparency) do
    hl.window_rule({
        name    = class .. "-transparency",
        match   = { class = "^(" .. class .. ")$" },
        opacity = opacity,
    })
end

-- Utility windows float centered instead of grabbing half the screen.
-- class -> { width, height } as fractions of the monitor
local utilities = {
    ["org.pulseaudio.pavucontrol"] = { 0.45, 0.60 },
    ["blueman-manager"]            = { 0.40, 0.55 },
    ["nm-connection-editor"]       = { 0.40, 0.55 },
    ["qt5ct"]                      = { 0.45, 0.65 },
    ["qt6ct"]                      = { 0.45, 0.65 },
    ["nwg-look"]                   = { 0.50, 0.65 },
    ["org.gnome.DiskUtility"]      = { 0.55, 0.65 },
    ["hyprpolkitagent"]            = { 0.30, 0.35 },
}

for class, size in pairs(utilities) do
    hl.window_rule({
        name   = class .. "-float",
        match  = { class = "^(" .. class:gsub("%.", "\\.") .. ")$" },
        float  = true,
        center = true,
        size   = { "monitor_w * " .. size[1], "monitor_h * " .. size[2] },
    })
end

-- File pickers and progress dialogs: float, keep their own size
hl.window_rule({
    name   = "dialogs-float",
    match  = { title = "^(Open File|Open Files|Save File|Save As|Open Folder|Select Folder|File Upload|File Operation Progress|Confirm to replace files)(.*)$" },
    float  = true,
    center = true,
})

-- Browser picture-in-picture: small, floating, visible on every workspace
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size  = { "monitor_w * 0.25", "monitor_h * 0.25" },
    move  = { "monitor_w * 0.74", "monitor_h * 0.72" },
})

hl.window_rule({
    name    = "matrix-no-blur",
    match   = { title = "^(cmatrix)$" },
    no_blur = true,
})
