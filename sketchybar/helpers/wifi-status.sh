#!/bin/sh
# Find Wi-Fi independently of Ethernet/USB interface ordering.
export LC_ALL=C
interface=$(/usr/sbin/networksetup -listallhardwareports 2>/dev/null | /usr/bin/awk '/Hardware Port: (Wi-Fi|AirPort)/ { found=1; next } found && /Device:/ { print $2; exit }')
if [ -z "$interface" ]; then
    printf 'Unavailable\n—\n—\n'
    exit 0
fi
power=$(/usr/sbin/networksetup -getairportpower "$interface" 2>/dev/null)
info=$(/sbin/ifconfig "$interface" 2>/dev/null)
case "$power" in
    *': Off') status='Wi-Fi off' ;;
    *': On')
        if printf '%s\n' "$info" | /usr/bin/grep -q 'status: active'; then
            status='Connected'
        else
            status='Not connected'
        fi ;;
    *) status='Unavailable' ;;
esac
ip=$(printf '%s\n' "$info" | /usr/bin/awk '$1 == "inet" { print $2; exit }')
[ -n "$ip" ] || ip='—'
ssid='—'
if [ "$status" = 'Connected' ]; then
    ssid=$(/usr/sbin/networksetup -getairportnetwork "$interface" 2>/dev/null | /usr/bin/sed -n 's/^Current Wi-Fi Network: //p')
    if [ -z "$ssid" ]; then
        ssid=$(/usr/sbin/ipconfig getsummary "$interface" 2>/dev/null | /usr/bin/sed -n 's/^  SSID : //p')
    fi
    case "$ssid" in
        ''|'<redacted>')
            helper_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
            ssid=$(/bin/bash "$helper_dir/wifi-ssid.sh" --read 2>/dev/null) || ssid='Hidden by macOS'
            [ -n "$ssid" ] || ssid='Hidden by macOS'
            ;;
    esac
fi
printf '%s\n%s\n%s\n' "$status" "$ip" "$ssid"
