#!/usr/bin/env bash

INTERNAL="eDP-1"
# Get the name of the first external monitor found
EXTERNAL=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -n 1)

if [ "$1" = "close" ]; then
    # Only disable internal if an external monitor exists
    if [ -n "$EXTERNAL" ]; then
        hyprctl keyword monitor "$INTERNAL, disable"
    fi
elif [ "$1" = "open" ]; then
    # 1. Re-enable the internal monitor
    hyprctl keyword monitor "$INTERNAL, preferred, auto, 1.6"

    # 2. Wait a brief moment for the monitor to initialize
    sleep 0.5

    # 3. Move workspaces 1 through 9 back to internal
    # Workspace 10 remains on the external monitor per your requirements
    for i in {1..9}; do
        hyprctl dispatch moveworkspacetomonitor "$i $INTERNAL"
    done

    # 4. Refocus the internal monitor
    hyprctl dispatch focusmonitor "$INTERNAL"
fi
