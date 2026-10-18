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
local ARZOPA_DESC = "GWD ARZOPA 0x28320206"
local ARZOPA      = "desc:" .. ARZOPA_DESC

local function arzopa_rule(transform)
    hl.monitor({
        output    = ARZOPA,
        mode      = "preferred",
        position  = "auto-right",
        scale     = 1.6,
        transform = transform,
    })
end

-- Every reload re-runs this file. Keep the rotation set at runtime by
-- monitor_rotate.sh (Super+O) instead of snapping back to vertical; the
-- default only applies when the monitor doesn't exist yet (startup).
local arzopa = hl.get_monitor(ARZOPA)
arzopa_rule(arzopa and arzopa.transform or 1)

-- Plugging the Arzopa in always starts vertical, with the matching Waybar
-- layout and its own wallpaper (arzopa-plugged.sh skips session startup).
-- Handlers don't pile up: every reload tears the Lua state down.
hl.on("monitor.added", function(m)
    if m.description ~= ARZOPA_DESC then
        return
    end
    arzopa_rule(1)
    hl.exec_cmd("~/.local/bin/arzopa-plugged.sh " .. m.name)
end)

-- Any other monitor that gets plugged in
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
