-- Gaps, borders, layouts and misc

local colors = require("conf.palette")

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = { colors = { colors.color4, colors.color5 }, angle = 45 },
            inactive_border = colors.background,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})
