-- Rounding, opacity, shadow, glow, dimming and blur

local colors = require("conf.palette")

hl.config({
    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- Slightly darken unfocused windows so focus reads at a glance
        dim_inactive = true,
        dim_strength = 0.08,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        -- Soft halo in the Wallust accent around the focused window only
        glow = {
            enabled        = true,
            range          = 12,
            render_power   = 3,
            color          = colors.alpha(colors.color5, "55"),
            color_inactive = "rgba(00000000)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
})

-- Frosted glass behind the bar and notifications. ignore_alpha keeps the
-- fully transparent parts of each layer (gaps, rounded corners) unblurred.
for _, namespace in ipairs({ "waybar", "swaync-control-center", "swaync-notification-window", "rofi" }) do
    hl.layer_rule({
        name         = namespace .. "-blur",
        match        = { namespace = namespace },
        blur         = true,
        ignore_alpha = 0.3,
    })
end
