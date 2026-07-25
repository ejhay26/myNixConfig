-- =====================================================================
--  config/startup.lua — exec-once autostart entries
-- =====================================================================
hl.config(
    {
        exec = {
            once= {
            --"noctalia-shell",
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
