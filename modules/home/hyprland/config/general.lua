-- =====================================================================
--  config/general.lua — Input, general layout, env vars, scrolling
-- =====================================================================

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    input = {
        kb_layout               = "us",
        float_switch_override_focus = 0,
        -- follow_mouse = 2,  -- uncomment for click-to-focus
    },

    general = {
        gaps_in          = 8,
        gaps_out         = 12,
        border_size      = 0,
        col = {
            active_border   = "rgba(ffffffff)",
            inactive_border = "rgba(595959aa)",
        },
        layout           = "dwindle",
        resize_on_border = true,
    },

    scrolling = {
        follow_min_visible = 0.1,
        focus_fit_method   = 0,
        follow_focus       = false,
        direction          = "right",
    },
})
