#!/bin/bash

# Get the current font size from kitty
if [ -n "$KITTY_PID" ] || [ -n "$KITTY_WINDOW_ID" ]; then
    # Extract font size from kitty config
    FONT_SIZE=$(kitty @ get-font-size 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)?' | head -1)
    if [ -n "$FONT_SIZE" ]; then
        echo " #[fg=#89b4fa,bold]󰍡 ${FONT_SIZE}px"
    else
        echo ""
    fi
else
    echo ""
fi

