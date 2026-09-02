-- =====================================================================
--  hyprland.lua — Entry point
--  Requires all modular config files. Order matters:
--  general → decoration → animation → startup → plugins → binds
-- =====================================================================

require("config.general")
require("config.decoration")
require("config.animation")
require("config.startup")
require("config.plugins")
require("config.binds")

-- Noctalia color theme (kept as .conf — sourced directly)
-- hl.source("~/.config/hypr/noctalia.conf")
-- require ("config.noctalia")

-- For Noctalia Color templates
require("noctalia").apply_theme()

