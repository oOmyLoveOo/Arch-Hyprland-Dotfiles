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

hl.window_rule({
    name    = "matrix-no-blur",
    match   = { title = "^(cmatrix)$" },
    no_blur = true,
})
