#!/usr/bin/env bash

# Find active interface
INTERFACE=$(ip route get 8.8.8.8 | grep -Po '(?<=dev )(\S+)')

# Get initial bytes
R1=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
sleep 1
# Get bytes after 1s
R2=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)

# Calculate speed in bytes
SPEED=$((R2 - R1))

# Convert to human readable
if [ "$SPEED" -ge 1048576 ]; then
    # MB/s Calculation using printf for formatting
    # We multiply by 10 to get one decimal place of precision without needing bc
    MB_TEN=$(( (SPEED * 10) / 1048576 ))
    BEFORE_DOT=$(( MB_TEN / 10 ))
    AFTER_DOT=$(( MB_TEN % 10 ))
    echo " $BEFORE_DOT.$AFTER_DOT MB/s"
elif [ "$SPEED" -ge 1024 ]; then
    echo " $((SPEED / 1024)) KB/s"
else
    echo " $SPEED B/s"
fi
