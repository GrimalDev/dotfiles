#!/bin/bash

# Launches a Kitty terminal window with Ranger and listens for 'q' to close the window.

# Launch Kitty with Ranger
kitty --single-instance --hold ranger &

# Get the PID of the last opened Kitty window
kitty_pid=$!

# Listen for 'q' keypress to close the window
while true; do
    read -rsn1 input
    if [ "$input" == "q" ]; then
        # Send CMD+W to close the window
        osascript -e 'tell application "System Events" to keystroke "w" using {command down}'
        break
    fi
done


