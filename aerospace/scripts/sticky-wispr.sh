#!/usr/bin/env bash
#
# Sticky-window workaround for the Wispr Flow "Status" HUD.
#
# AeroSpace has no sticky windows (open feature request:
# https://github.com/nikitabobko/AeroSpace/issues/2). A window assigned to a
# hidden workspace is parked off-screen, so the HUD disappears when you switch
# away from its workspace. This script re-homes the HUD onto whichever
# workspace you switch to, keeping it visible (and, because the app keeps it at
# a floating window level, on top) across every workspace.
#
# Invoked from the 'exec-on-workspace-change' callback. Takes the target
# workspace as $1; falls back to the focused workspace when run by hand.

set -o nounset
set -o pipefail

AEROSPACE_BIN=/opt/homebrew/bin/aerospace
BUNDLE_ID=com.electron.wispr-flow

target_ws="${1:-}"
if [ -z "$target_ws" ]; then
    target_ws="$("$AEROSPACE_BIN" list-workspaces --focused)"
fi
[ -z "$target_ws" ] && exit 0

# Re-home every Wispr window that is not already on the target workspace.
while IFS='|' read -r win_id win_ws; do
    [ -n "$win_id" ] || continue
    [ "$win_ws" = "$target_ws" ] && continue
    "$AEROSPACE_BIN" move-node-to-workspace --window-id "$win_id" "$target_ws"
done < <("$AEROSPACE_BIN" list-windows --monitor all \
    --app-bundle-id "$BUNDLE_ID" \
    --format '%{window-id}|%{workspace}')
