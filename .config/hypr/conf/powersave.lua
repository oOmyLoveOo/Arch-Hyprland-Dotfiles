-- Battery saver: on battery, turn off the GPU-heavy eye candy; back on AC,
-- restore it. Must be required after decoration and animations, since it
-- overrides their values while unplugged.

local AC_ONLINE = "/sys/class/power_supply/ACAD/online"

local function on_ac()
    local f = io.open(AC_ONLINE)
    if not f then
        return true -- no adapter info: never degrade
    end
    local online = f:read("l")
    f:close()
    return online == "1"
end

local function apply(ac)
    hl.config({
        decoration = {
            blur   = { enabled = ac },
            shadow = { enabled = ac },
        },
    })
    -- The looping border gradient forces a redraw every frame even when idle
    hl.animation({ leaf = "borderangle", enabled = ac, speed = 30, bezier = "liner", style = "loop" })
end

-- Every reload re-runs this file (and resets decoration/animations), so
-- start from the real state and only touch the config when it changes
local last = on_ac()
if not last then
    apply(false)
end

local function check()
    local now = on_ac()
    if now == last then
        return
    end
    last = now
    apply(now)
    hl.notification.create({
        text    = now and "AC power: effects back on" or "On battery: blur, shadows and border animation off",
        timeout = 4000,
    })
end

-- Creating an hl.timer crashes `Hyprland --verify-config` (no event loop
-- there; config.reloaded fires in it too). The validator has no monitors:
-- on a reload of a live session they exist, so start right away; on the
-- very first load they don't exist yet, so wait for hyprland.start.
local timer
local function start_timer()
    if not timer then
        timer = hl.timer(check, { timeout = 5000, type = "repeat" })
    end
end

if #hl.get_monitors() > 0 then
    start_timer()
end
hl.on("hyprland.start", start_timer)
