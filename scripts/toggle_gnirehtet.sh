#!/usr/bin/env bash

if pgrep -f "gnirehtet autorun" > /dev/null; then
    # --- TOGGLE OFF ---
    gnirehtet stop
    pkill -f "gnirehtet autorun"
    rm -f /tmp/gnirehtet_active.lock

    notify-send "Gnirehtet" "Watcher Stopped" --icon=network-disconnect --expire-time=2000
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "network-disconnect" "Gnirehtet: OFF"
else
    # --- TOGGLE ON ---
    gnirehtet autorun &
    touch /tmp/gnirehtet_active.lock

    notify-send "Gnirehtet" "Watcher Active" --icon=network-wired --expire-time=2000
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "network-wired" "Gnirehtet: ON"
fi
