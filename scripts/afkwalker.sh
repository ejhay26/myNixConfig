#!/usr/bin/env bash

# This is the name we use to find and kill the process
MARKER="DOTOOL_MACRO_SESSION"

# --- TOGGLE LOGIC ---
if pgrep -f "$MARKER" > /dev/null; then
    # --- TOGGLE OFF ---
    # We kill the process group (the loop AND the dotool it's piped into)
    pkill -f "$MARKER"

    notify-send "Macro" "Stopped" --icon=action-unavailable
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "action-unavailable" "OFF"
else
    # --- TOGGLE ON ---
    # We wrap the whole pipe in 'bash -c' so we can give it a unique MARKER name
    bash -c "
        (
            while true; do
                echo 'key w'
                sleep 4
            done | dotool
        ) # $MARKER
    " &

    notify-send "Macro" "Running Pipe Loop" --icon=media-playback-start
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "media-playback-start" "ON"
fi
