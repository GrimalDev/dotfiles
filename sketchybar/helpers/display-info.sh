#!/bin/bash
set -euo pipefail
source_dir="$(cd "$(dirname "$0")" && pwd)"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
mkdir -p "$cache"
binary="$cache/display-info"
if [ ! -x "$binary" ] || [ "$source_dir/display-info.m" -nt "$binary" ]; then
  tmp="$(mktemp "$cache/display-info.XXXXXX")"
  trap 'rm -f "$tmp"' EXIT
  if ! /usr/bin/xcrun clang -O2 -fobjc-arc "$source_dir/display-info.m" \
      -framework AppKit -framework CoreGraphics -o "$tmp" 2>"$cache/display-info-build.log"; then
    # A stale preview SDK may be selected even though CLT's default SDK works.
    sdk=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
    [ -d "$sdk" ] || exit 1
    /usr/bin/xcrun clang -isysroot "$sdk" -O2 -fobjc-arc "$source_dir/display-info.m" \
      -framework AppKit -framework CoreGraphics -o "$tmp" 2>>"$cache/display-info-build.log"
  fi
  chmod 755 "$tmp"
  mv -f "$tmp" "$binary"
fi
exec "$binary"
