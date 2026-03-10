#!/usr/bin/env bash

# Check for the specific audio-only scrcpy process
if pgrep -f "scrcpy.*--no-video" > /dev/null; then
    # --- TOGGLE OFF ---
    pkill -f "scrcpy.*--no-video"
    rm -f /tmp/audio_active.lock

    # Notifications
    notify-send "Mobile Audio" "Stopped" --icon=audio-volume-muted --expire-time=2000
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "audio-volume-muted" "Audio: OFF"
else
    # Check if phone is connected
    if ! adb get-state 1>/dev/null 2>&1; then
        notify-send "Mobile Audio" "Error: No Phone Connected" --icon=error
        exit 1
    fi

    # --- TOGGLE ON ---
    # --no-window hides the app UI completely
    scrcpy --no-video --no-control --no-window --audio-codec=raw &
    touch /tmp/audio_active.lock

    # Notifications
    notify-send "Mobile Audio" "Enabled" --icon=audio-volume-high --expire-time=2000
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "audio-volume-high" "Audio: ON"
fi
