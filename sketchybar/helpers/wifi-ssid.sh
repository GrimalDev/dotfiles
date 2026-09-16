#!/bin/bash
set -euo pipefail
source_dir="$(cd "$(dirname "$0")" && pwd)"
cache="$HOME/Library/Caches/com.grimaldev.sketchybar-wifi"
app="$cache/SketchyBar Wi-Fi.app"
binary="$app/Contents/MacOS/wifi-ssid"
mkdir -p "$cache"
chmod 700 "$cache"
if [ ! -x "$binary" ] || [ "$source_dir/wifi-ssid.m" -nt "$binary" ]; then
    mkdir -p "$app/Contents/MacOS"
    cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.grimaldev.sketchybar-wifi</string>
<key>CFBundleName</key><string>SketchyBar Wi-Fi</string>
<key>CFBundleDisplayName</key><string>SketchyBar Wi-Fi</string>
<key>CFBundleExecutable</key><string>wifi-ssid</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSUIElement</key><true/>
<key>NSLocationUsageDescription</key><string>Show the connected Wi-Fi network name in your SketchyBar popup. No geographic coordinates are requested or collected.</string>
<key>NSLocationWhenInUseUsageDescription</key><string>Show the connected Wi-Fi network name in your SketchyBar popup. No geographic coordinates are requested or collected.</string>
</dict></plist>
PLIST
    if ! /usr/bin/xcrun clang -O2 -fobjc-arc "$source_dir/wifi-ssid.m" -framework AppKit -framework CoreLocation -framework CoreWLAN -o "$binary" 2>"$cache/build.log"; then
        /usr/bin/xcrun clang -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -O2 -fobjc-arc "$source_dir/wifi-ssid.m" -framework AppKit -framework CoreLocation -framework CoreWLAN -o "$binary" 2>>"$cache/build.log"
    fi
    /usr/bin/codesign --force --sign - --identifier com.grimaldev.sketchybar-wifi "$app" 2>>"$cache/build.log"
fi
if [ "${1:-}" = '--build-only' ]; then exit 0; fi
if [ "${1:-}" = '--request' ]; then
    /usr/bin/open -W "$app" --args --request
else
    /usr/bin/open -g -W "$app" --args --read
fi
if [ -f "$cache/ssid" ]; then cat "$cache/ssid"; else printf 'Hidden by macOS'; fi
printf '\n'
