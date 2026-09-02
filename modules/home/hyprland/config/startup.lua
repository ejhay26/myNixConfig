-- =====================================================================
--  config/startup.lua — exec-once autostart entries
-- =====================================================================

-- ── Active shell ──────────────────────────────────────────────────────
-- Autostart Noctalia shell (v5)

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("noctalia -d")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ── NixOS plugin loading ─────────────────────────────────────────────
-- Plugin loading via hyprctl is NixOS-managed through the flake.
-- Uncomment and adjust paths if you switch to manual loading.
--
-- hl.exec_once("hyprctl plugin load <path>/libhyprbars.so")
-- hl.exec_once("hyprctl plugin load <path>/libhyprexpo.so")
