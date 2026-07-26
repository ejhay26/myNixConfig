-- =====================================================================
--  config/animation.lua — Bezier curves and animation definitions
-- =====================================================================

hl.config({
    animations = {
        enabled = true,
    },
})

-- Custom bezier curve: slight overshoot feel
hl.curve("overshoot", { type = "bezier", points = { { 0.34, 1.4 }, { 0.64, 1 } } })

-- ── Animations ──────────────────────────────────────────────────────
hl.animation({ leaf = "fade",       enabled = true, speed = 3,  bezier = "default"   })
hl.animation({ leaf = "windows",    enabled = true, speed = 5,  bezier = "overshoot", style = "slide" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 20, bezier = "default"   })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default"   })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default"   })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "overshoot", style = "slide" })
