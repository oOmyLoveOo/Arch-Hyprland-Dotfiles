-- Keyboard, mouse, touchpad and gestures
-- Migrated from input.conf

hl.config({
    input = {
        kb_layout  = "us,es",
        kb_variant = "altgr-intl,",
        kb_model   = "pc105",
        kb_options = "grp:win_space_toggle",
        kb_rules   = "",

        follow_mouse       = 1,
        numlock_by_default = true,
        sensitivity        = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
