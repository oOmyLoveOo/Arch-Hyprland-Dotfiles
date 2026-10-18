-- Monitor layout

-- Laptop panel
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- Arzopa Z1RC (USB-C) — vertical, to the right of the laptop
-- Native panel is 2560x1600@60 (2.5K 16:10); 1.6 scale = 1000x1600 logical
-- transform 1 = 90° rotation; switch to 3 (270°) if it ends up upside down
local ARZOPA = "desc:GWD ARZOPA 0x28320206"

-- Every reload re-runs this file. Keep the rotation set at runtime by
-- monitor_rotate.sh (Super+O) instead of snapping back to vertical; the
-- default only applies when the monitor doesn't exist yet (startup/plug-in).
local arzopa = hl.get_monitor(ARZOPA)

hl.monitor({
    output    = ARZOPA,
    mode      = "preferred",
    position  = "auto-right",
    scale     = 1.6,
    transform = arzopa and arzopa.transform or 1,
})

-- Any other monitor that gets plugged in
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
