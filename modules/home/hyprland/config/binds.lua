-- =====================================================================
--  config/binds.lua — All keybindings
--  Dispatcher API: wiki.hypr.land (Hyprland 0.55+)
-- =====================================================================

-- ── Modifier aliases ──────────────────────────────────────────────────
local SUPER = "SUPER"
local ALT   = "ALT"
local SHIFT = "SHIFT"
local CTRL  = "CTRL"

-- ── Active shell selector ─────────────────────────────────────────────
-- Change this to "caelestia" to switch all shell binds over.
-- Must match the value set in startup.lua.
local active_shell = "noctalia"

-- ── Shell IPC command maps ────────────────────────────────────────────
-- Each entry maps a logical action to the shell's actual IPC command.
-- Only the active_shell's commands are registered as binds.
local shell_cmds = {
    noctalia = {
        launcher   = "noctalia-shell ipc call launcher toggle",
        wallpaper  = "noctalia-shell ipc call wallpaper toggle",
        emoji      = "noctalia-shell ipc call launcher emoji",
        monitor    = "noctalia-shell ipc call systemMonitor toggle",
        settings   = "noctalia-shell ipc call settings toggle",
        clipboard  = "noctalia-shell ipc call launcher clipboard",
        bar        = "noctalia-shell ipc call bar toggle",
        lock       = "noctalia-shell ipc call lockScreen lock",
        session    = "noctalia-shell ipc call sessionMenu",
    },
    caelestia = {
        launcher   = "hyprctl dispatch global caelestia:launcher",
        wallpaper  = "hyprctl dispatch global caelestia:wallpaper",
        emoji      = "hyprctl dispatch global caelestia:emoji",
        monitor    = nil,  -- no caelestia equivalent yet
        settings   = nil,  -- no caelestia equivalent yet
        clipboard  = "hyprctl dispatch global caelestia:clipboard",
        bar        = nil,  -- no caelestia equivalent yet; see sidebar comment below
        lock       = "hyprctl dispatch global caelestia:lock",
        session    = nil,  -- no caelestia equivalent yet
        -- sidebar = "hyprctl dispatch global caelestia:sidebar",  -- future SUPER+U equivalent
    },
}

-- Resolve active shell's command map
local sh = shell_cmds[active_shell]

-- ── Helper: bind only if command exists for active shell ──────────────
local function sbind(key, cmd)
    if cmd ~= nil then
        hl.bind(key, hl.dsp.exec_cmd(cmd))
    end
end

-- ── Shell binds ───────────────────────────────────────────────────────
sbind(SUPER .. " + Tab",    sh.launcher)
sbind(SUPER .. " + W",      sh.wallpaper)
sbind(SUPER .. " + period", sh.emoji)
sbind(SUPER .. " + ESCAPE", sh.monitor)
sbind(SUPER .. " + I",      sh.settings)
sbind(SUPER .. " + V",      sh.clipboard)
sbind(SUPER .. " + U",      sh.bar)
sbind(SUPER .. " + L",      sh.lock)
sbind(SUPER .. " + M",      sh.session)

-- ── App shortcuts ─────────────────────────────────────────────────────
local screenshots_dir = "/home/$USER/Pictures/Screenshots"

hl.bind(SUPER .. " + T",      hl.dsp.exec_cmd("kitty"))
hl.bind(SUPER .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(SUPER .. " + G",      hl.dsp.exec_cmd("toggle-scrolling"))
hl.bind(SUPER .. " + Y",      hl.dsp.exec_cmd("pkill waybar || waybar"))

-- ── Screenshots ───────────────────────────────────────────────────────
hl.bind(ALT   .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m region -z -o "           .. screenshots_dir))
hl.bind(SHIFT .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m output -c -m active -o " .. screenshots_dir))
hl.bind(CTRL  .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window -z -o "           .. screenshots_dir))

-- ── Window management ─────────────────────────────────────────────────
hl.bind(SUPER .. " + Q",                          hl.dsp.window.close())
hl.bind(SUPER .. " + F",                          hl.dsp.window.fullscreen())
hl.bind(SUPER .. " + SPACE",                      hl.dsp.window.float({ action = "toggle" }))
hl.bind(SUPER .. " + " .. SHIFT .. " + SPACE",    hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))
hl.bind(SUPER .. " + H",                          hl.dsp.exec_cmd("minimize"))
hl.bind(SUPER .. " + N",                          hl.dsp.workspace.toggle_special("minimized"))

-- ── Hardware: brightness ──────────────────────────────────────────────
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { repeating = true })

-- ── Hardware: volume ──────────────────────────────────────────────────
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })

-- ── Hardware: media ───────────────────────────────────────────────────
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ── Mouse binds (floating windows) ────────────────────────────────────
hl.bind(SUPER .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(SUPER .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Window resizing (arrow keys) ──────────────────────────────────────
hl.bind(SUPER .. " + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), { repeating = true })
hl.bind(SUPER .. " + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), { repeating = true })
hl.bind(SUPER .. " + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { repeating = true })
hl.bind(SUPER .. " + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { repeating = true })

-- ── Window movement (tiled, IJKL) ─────────────────────────────────────
hl.bind(ALT .. " + I", hl.dsp.window.move({ direction = "u" }))
hl.bind(ALT .. " + K", hl.dsp.window.move({ direction = "d" }))
hl.bind(ALT .. " + J", hl.dsp.window.move({ direction = "l" }))
hl.bind(ALT .. " + L", hl.dsp.window.move({ direction = "r" }))

-- ── Accessibility: zoom ───────────────────────────────────────────────
hl.bind(SUPER .. " + " .. SHIFT .. " + mouse_down",
    hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"))
hl.bind(SUPER .. " + " .. SHIFT .. " + mouse_up",
    hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"))

-- ── Workspace switching (ALT + 1–0) ───────────────────────────────────
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(ALT .. " + " .. key, hl.dsp.focus({ workspace = i }))
end

-- ── Move window to workspace (ALT+SHIFT + 1–0) ────────────────────────
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(ALT .. " + " .. SHIFT .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end
