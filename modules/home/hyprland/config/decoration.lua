-- =====================================================================
--  config/decoration.lua — Blur, shadow, opacity, and window rules
-- =====================================================================

hl.config({
    decoration = {
        rounding         = 10,
        active_opacity   = 0.90,
        inactive_opacity = 0.90,

        blur = {
            enabled           = true,
            size              = 8,
            passes            = 4,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = true,
            vibrancy          = 0.1696,
            brightness        = 1.2,
        },

        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
    },
})

-- ── Window rules ────────────────────────────────────────────────────
-- Override global opacity to 1.0 (fully opaque) for specific apps.
-- opacity = "1.0 1.0" sets both active and inactive opacity.
local opaque_classes = {
    -- Browsers
    "brave-browser",
    "Vivaldi-stable",
    "librewolf",
    -- Apps & gaming
    "org.vinegarhq.Sober",
    "vesktop",
    "discord",
    ".scrcpy-wrapped",
    -- Productivity
    "LibreOffice.*",
    "virt-manager",
}

for _, class in ipairs(opaque_classes) do
    hl.window_rule({
        match   = { class = "^(" .. class .. ")$" },
        opacity = "1.0 1.0",  -- active opacity, inactive opacity
    })
end

-- scrcpy should always open floating
hl.window_rule({
    match = { class = "^(.scrcpy-wrapped)$" },
    float = true,
})
