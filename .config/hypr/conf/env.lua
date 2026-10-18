-- Environment variables and cursor
-- Migrated from env.conf

hl.config({
    cursor = {
        no_hardware_cursors = false,
    },
})

local cursor_theme = "Bibata-Modern-Ice"
local cursor_size  = "24"

local env = {
    XCURSOR_THEME        = cursor_theme,
    XCURSOR_SIZE         = cursor_size,
    HYPRCURSOR_THEME     = cursor_theme,
    HYPRCURSOR_SIZE      = cursor_size,

    -- env.conf set qt5ct then qt6ct; the last one won, so only qt6ct is kept
    QT_QPA_PLATFORMTHEME = "qt6ct",
    QT_QPA_PLATFORM      = "wayland;xcb",

    XDG_CURRENT_DESKTOP  = "Hyprland",
    XDG_SESSION_TYPE     = "wayland",
    XDG_SESSION_DESKTOP  = "Hyprland",

    TERMINAL             = "kitty",
    EDITOR               = "nano",
    FILEMANAGER          = "thunar",

    MOZ_ENABLE_WAYLAND   = "1",
}

for name, value in pairs(env) do
    hl.env(name, value)
end
