#!/usr/bin/env bash

INTERNAL="eDP-1"
# Count active monitors
COUNT=$(hyprctl monitors -j | jq '. | length')

if [ "$1" = "close" ]; then
    if [ "$COUNT" -gt 1 ]; then
        # External monitor is connected: Disable internal, keep session active
        hyprctl keyword monitor "$INTERNAL, disable"
    else
        # No external monitor: Lock the screen
        1password --lock ; hyprlock
    fi
elif [ "$1" = "open" ]; then
    # Re-enable internal monitor
    hyprctl keyword monitor "$INTERNAL, preferred, auto, 1.6"

    # Optional: Move workspaces back if they scrambled during the lock/plug event
    sleep 0.5
    for i in {1..9}; do
        hyprctl dispatch moveworkspacetomonitor "$i $INTERNAL"
    done
fi
