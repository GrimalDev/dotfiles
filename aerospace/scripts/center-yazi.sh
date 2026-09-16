#!/usr/bin/env bash
#
# Open the yazi (kitty "file") window at a fixed size, centered on the focused
# monitor.
#
# AeroSpace has no absolute reposition command (only relative `resize`), so the
# final position/size is applied through System Events. The focused monitor is
# mapped to its NSScreen via AeroSpace's `%{monitor-appkit-nsscreen-screens-id}`
# so the window centers on the screen you are actually looking at.
#
# Invoked from the `on-window-detected` callback for `net.kovidgoyal.kitty`
# windows titled `file`.
#
# Change SIZE_W / SIZE_H to taste; the size is clamped to the screen.

set -o nounset
set -o pipefail

AEROSPACE_BIN=/opt/homebrew/bin/aerospace
KITTY_BUNDLE=net.kovidgoyal.kitty
YAZI_TITLE='file'
SIZE_W=1600
SIZE_H=1000

# The persistent popup supplies its exact window and monitor. Keep the legacy
# lookup for manually launched Kitty windows titled file.
if [ "$#" -eq 3 ]; then
    win_id="$1"
    win_pid="$2"
    ns_index="$3"
else
    win_id=""
    win_pid=""
    for _ in $(seq 1 100); do
        read -r win_id win_pid <<<"$("$AEROSPACE_BIN" list-windows --monitor all \
            --app-bundle-id "$KITTY_BUNDLE" \
            --format '%{window-id}|%{app-pid}|%{window-title}' \
            | awk -F'|' -v t="$YAZI_TITLE" '$3 == t { print $1 " " $2; exit }')" || true
        [ -n "$win_id" ] && break
        sleep 0.05
    done
    [ -z "$win_id" ] && exit 0
    "$AEROSPACE_BIN" layout floating --window-id "$win_id"
    ns_index=$("$AEROSPACE_BIN" list-monitors --focused \
        --format '%{monitor-appkit-nsscreen-screens-id}')
fi
[ -z "$ns_index" ] && ns_index=1

# Compute the top-left origin in System Events coordinates (top-left origin of
# the primary display) for a SIZE_W x SIZE_H window centered in the focused
# screen's visible frame. NSScreen coordinates are bottom-left origin, hence the
# primary-height flip.
read -r se_x se_y out_w out_h <<< "$(osascript -l JavaScript -e '
ObjC.import("AppKit");
function run(argv) {
  var idx = parseInt(argv[0], 10);
  var w = parseFloat(argv[1]);
  var h = parseFloat(argv[2]);
  var screens = $.NSScreen.screens;
  var i = idx - 1;
  if (!(i >= 0 && i < screens.count)) i = 0;
  var vf = screens.objectAtIndex(i).visibleFrame;
  var primaryH = screens.objectAtIndex(0).frame.size.height;
  var ww = Math.min(w, vf.size.width);
  var hh = Math.min(h, vf.size.height);
  var nsX = vf.origin.x + (vf.size.width - ww) / 2;
  var nsY = vf.origin.y + (vf.size.height - hh) / 2;
  var seX = nsX;
  var seY = primaryH - (nsY + hh);
  return Math.round(seX) + " " + Math.round(seY) + " " + Math.round(ww) + " " + Math.round(hh);
}' "$ns_index" "$SIZE_W" "$SIZE_H")"

[ -z "${se_x:-}" ] && exit 0

osascript -e "
with timeout of 2 seconds
tell application \"System Events\"
  tell (first process whose unix id is $win_pid)
    set position of window 1 to {$se_x, $se_y}
    set size of window 1 to {$out_w, $out_h}
  end tell
end tell
end timeout"
