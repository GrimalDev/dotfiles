#!/bin/bash
set -euo pipefail
cache="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
binary="$cache/sketchybar_portrait"
config="$(cd "$(dirname "$0")/.." && pwd)"
case "${1:-}" in
  start)
    mkdir -p "$cache"
    if [ ! -L "$binary" ]; then ln -s "$(command -v sketchybar)" "$binary"; fi
    if ! "$binary" --query bar 2>/dev/null | /usr/bin/grep -q '"position"'; then
      SKETCHYBAR_ROLE=portrait /usr/bin/nohup "$binary" --config "$config/sketchybarrc" >"$cache/portrait.log" 2>&1 </dev/null &
    fi
    ;;
  stop) [ ! -x "$binary" ] || "$binary" --quit ;;
  trigger) [ ! -x "$binary" ] || "$binary" --trigger aerospace_workspace_change ;;
  *) exit 2 ;;
esac
