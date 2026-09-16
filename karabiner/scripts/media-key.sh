#!/bin/bash
set -euo pipefail
base="$(cd "$(dirname "$0")" && pwd)"
cache="$HOME/.cache/karabiner-media"
mkdir -p "$cache"
chmod 700 "$cache"
binary="$cache/media-control"
mode="${1:-}"; action="${2:-}"; delta="${3:-0}"
case "$action" in volume-up|volume-down) control=volume ;; brightness-up|brightness-down) control=brightness ;; mute) control=mute ;; *) exit 2 ;; esac
state="$cache/$action.held"
if [ "$mode" = release ]; then rm -f "$state"; exit 0; fi
if [ ! -x "$binary" ] || [ "$base/media-control.c" -nt "$binary" ]; then
  /usr/bin/xcrun clang -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk "$base/media-control.c" -framework CoreAudio -framework CoreGraphics -o "$binary"
fi
case "$mode" in
 press)
   printf '%s\n' "$$" > "$state"
   "$binary" "$control" "$delta"
   ;;
 hold)
   [ "$action" != mute ] || exit 0
   [ -f "$state" ] || exit 0
   token=$(cat "$state")
   # A lost release cannot leave an adjustment loop running indefinitely.
   for ((i=0; i<60; i++)); do
     [ -f "$state" ] && [ "$(cat "$state")" = "$token" ] || break
     "$binary" "$control" "$delta" || break
     /bin/sleep 0.08
   done
   ;;
 *) exit 2 ;;
esac
