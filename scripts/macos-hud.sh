#!/bin/bash
# Temporarily hide/restore Apple's volume and brightness HUD for this user.
# Uses the same process-suspension approach as SlimHUD's OSDUIManager.
set -euo pipefail
case "${1:-}" in
  hide)
    /bin/launchctl kickstart "gui/$(/usr/bin/id -u)/com.apple.OSDUIHelper"
    /bin/sleep 0.5
    /usr/bin/killall -u "$(/usr/bin/id -un)" -STOP OSDUIHelper
    ;;
  show)
    /usr/bin/killall -u "$(/usr/bin/id -un)" -CONT OSDUIHelper
    ;;
  *)
    printf 'Usage: bash ~/.config/scripts/macos-hud.sh hide|show\n' >&2
    exit 2
    ;;
esac
