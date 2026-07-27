-- =====================================================================
--  config/startup.lua — exec-once autostart entries
-- =====================================================================

-- ── Active shell ──────────────────────────────────────────────────────
-- Set this to "noctalia" or "caelestia" to choose which shell to autostart.
-- Only one shell runs at a time.
local active_shell = "caelestia"

local shell_start = {
    noctalia  = "noctalia-shell",
    caelestia = "caelestia shell -d",
}

hl.config({
    exec = {
        once = {
            shell_start[active_shell],
            "hyprpm reload",
            "wl-paste --type text --watch cliphist store",
            "wl-paste --type image --watch cliphist store",
        },
    },
})

-- ── NixOS plugin loading ─────────────────────────────────────────────
-- Plugin loading via hyprctl is NixOS-managed through the flake.
-- Uncomment and adjust paths if you switch to manual loading.
--
-- hl.exec_once("hyprctl plugin load <path>/libhyprbars.so")
-- hl.exec_once("hyprctl plugin load <path>/libhyprexpo.so")
