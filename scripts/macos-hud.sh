#!/bin/bash
# Temporarily hide/restore Apple's volume and brightness HUD for this user.
# Uses the same process-suspension approach as SlimHUD's OSDUIManager.
# macOS 27 banners require the Karabiner SlimHUD media-key rules instead.
set -euo pipefail
macos_major=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d. -f1)
case "${1:-}" in
  hide)
    # Tahoe renders its new banners in Control Center, outside OSDUIHelper.
    if [ "$macos_major" -eq 26 ]; then
      /usr/bin/defaults write com.apple.controlcenter EnableSystemBanners -bool false
      /usr/bin/killall ControlCenter || true
    fi
    /bin/launchctl kickstart "gui/$(/usr/bin/id -u)/com.apple.OSDUIHelper"
    /bin/sleep 0.5
    /usr/bin/killall -u "$(/usr/bin/id -un)" -STOP OSDUIHelper
    ;;
  show)
    if [ "$macos_major" -eq 26 ]; then
      /usr/bin/defaults delete com.apple.controlcenter EnableSystemBanners 2>/dev/null || true
      /usr/bin/killall ControlCenter || true
    fi
    /usr/bin/killall -u "$(/usr/bin/id -un)" -CONT OSDUIHelper
    ;;
  *)
    printf 'Usage: bash ~/.config/scripts/macos-hud.sh hide|show\n' >&2
    exit 2
    ;;
esac
