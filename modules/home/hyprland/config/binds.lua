-- =====================================================================
--  config/binds.lua — All keybindings
--  Dispatcher API: wiki.hypr.land (Hyprland 0.55+)
-- =====================================================================

-- ── Modifier aliases ──────────────────────────────────────────────────
local SUPER = "SUPER"
local ALT   = "ALT"
local SHIFT = "SHIFT"
local CTRL  = "CTRL"

-- ── Noctalia v5 Shell IPC command maps ────────────────────────────────
-- Maps logical actions to Noctalia v5 `noctalia msg` subcommands.
local shell_cmds = {
    launcher   = "noctalia msg panel-toggle launcher",
    wallpaper  = "noctalia msg panel-toggle wallpaper",
    emoji      = "noctalia msg panel-toggle launcher /emoji",
    monitor    = "noctalia msg settings-toggle",
    settings   = "noctalia msg settings-toggle",
    clipboard  = "noctalia msg panel-toggle clipboard",
    bar        = "noctalia msg bar-toggle",
    lock       = "noctalia msg session lock",
    session    = "noctalia msg panel-toggle session",
}

-- ── Shell binds ───────────────────────────────────────────────────────
hl.bind(SUPER .. " + Tab",    hl.dsp.exec_cmd(shell_cmds.launcher))
hl.bind(SUPER .. " + W",      hl.dsp.exec_cmd(shell_cmds.wallpaper))
hl.bind(SUPER .. " + period", hl.dsp.exec_cmd(shell_cmds.emoji))
hl.bind(SUPER .. " + ESCAPE", hl.dsp.exec_cmd(shell_cmds.monitor))
hl.bind(SUPER .. " + I",      hl.dsp.exec_cmd(shell_cmds.settings))
hl.bind(SUPER .. " + V",      hl.dsp.exec_cmd(shell_cmds.clipboard))
hl.bind(SUPER .. " + U",      hl.dsp.exec_cmd(shell_cmds.bar))
hl.bind(SUPER .. " + L",      hl.dsp.exec_cmd(shell_cmds.lock))
hl.bind(SUPER .. " + M",      hl.dsp.exec_cmd(shell_cmds.session))

-- ── App shortcuts ─────────────────────────────────────────────────────
local screenshots_dir = (os.getenv("HOME") or "") .. "/Pictures/Screenshots"

hl.bind(SUPER .. " + T",      hl.dsp.exec_cmd("kitty"))
hl.bind(SUPER .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(SUPER .. " + G",      hl.dsp.exec_cmd("toggle-scrolling"))
hl.bind(SUPER .. " + Y",      hl.dsp.exec_cmd("pkill waybar || waybar"))
hl.bind(SUPER .. " + B",      hl.dsp.exec_cmd("brave"))

-- ── Screenshots ───────────────────────────────────────────────────────
hl.bind(ALT   .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m region -z -o "           .. screenshots_dir))
hl.bind(SHIFT .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m output -c -m active -o " .. screenshots_dir))
hl.bind(CTRL  .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window -z -o "           .. screenshots_dir))

-- ── Window management ─────────────────────────────────────────────────
hl.bind(SUPER .. " + Q",                          hl.dsp.window.close())
hl.bind(SUPER .. " + F",                          hl.dsp.window.fullscreen())
hl.bind(SUPER .. " + SPACE",                      hl.dsp.window.float({ action = "toggle" }))
hl.bind(SUPER .. " + " .. SHIFT .. " + SPACE",    hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))
hl.bind(SUPER .. " + H",                          hl.dsp.window.move({ workspace = "special:minimized" }))
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
hl.bind(SUPER .. " + " .. SHIFT .. " + mouse_up",
    hl.dsp.exec_cmd("hyprctl eval \"hl.config({ cursor = { zoom_factor = $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.25') } })\""))
hl.bind(SUPER .. " + " .. SHIFT .. " + mouse_down",
    hl.dsp.exec_cmd("hyprctl eval \"hl.config({ cursor = { zoom_factor = $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.8) | if . < 1 then 1 else . end') } })\""))

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
