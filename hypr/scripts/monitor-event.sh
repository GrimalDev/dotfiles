#!/usr/bin/env bash

handle() {
  case $1 in
    monitoradded*)
      MON=$(echo "$1" | cut -d '>' -f 3)
      if [[ "$MON" != "eDP-1" ]]; then
        # 1. Move workspace 10 to the new external monitor
        hyprctl dispatch moveworkspacetomonitor 10 "$MON"
        # 2. Ensure it's in extended mode (placed to the right of internal)
        hyprctl keyword monitor "$MON, preferred, auto, 1"
      fi
      ;;
  esac
}

socat - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.hypr" | while read -r line; do handle "$line"; done
