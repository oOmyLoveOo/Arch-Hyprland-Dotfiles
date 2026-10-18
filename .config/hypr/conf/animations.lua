-- Bezier curves and animations

hl.config({
    animations = {
        enabled = true,
    },
})

-- name -> { {x1, y1}, {x2, y2} }
local curves = {
    wind         = { { 0.05, 0.9 }, { 0.1, 1.05 } },
    winIn        = { { 0.1, 1.1 },  { 0.1, 1.1 } },
    winOut       = { { 0.3, -0.3 }, { 0, 1 } },
    liner        = { { 1, 1 },      { 1, 1 } },
    almostLinear = { { 0.5, 0.5 },  { 0.75, 1.0 } },
}

for name, points in pairs(curves) do
    hl.curve(name, { type = "bezier", points = points })
end

-- { leaf, speed, curve, style? }
local animations = {
    { "windows",     6,    "wind",   "slide" },
    { "windowsIn",   6,    "winIn",  "slide" },
    { "windowsOut",  5,    "winOut", "slide" },
    { "windowsMove", 5,    "wind",   "slide" },
    { "border",      1,    "liner" },
    { "borderangle", 30,   "liner",  "loop" },
    { "layers",      6,    "wind",   "popin 90%" },
    { "layersIn",    6,    "winIn",  "popin 90%" },
    { "layersOut",   5,    "winOut", "popin 90%" },
    { "workspaces",  5,    "wind" },
    { "fadeIn",      1.73, "almostLinear" },
    { "fadeOut",     1.46, "almostLinear" },
    { "fade",        3.03, "almostLinear" },
}

for _, a in ipairs(animations) do
    hl.animation({ leaf = a[1], enabled = true, speed = a[2], bezier = a[3], style = a[4] })
end
