#!/bin/zsh
# Cmd-E summons one Kitty window; --session keeps it alive when Yazi quits.
set -eu
setopt pipefail
zmodload zsh/system
zmodload zsh/datetime

aero=/opt/homebrew/bin/aerospace
cache="$HOME/.cache/aerospace-yazi-shell"
script=${0:A}
parked=yazi-hidden
mkdir -p "$cache"
touch "$cache"/{toggle,session,placement}.lock
exec 2>>"$cache/errors.log"

popup() {
    local rows
    rows=$("$aero" list-windows --monitor all --app-bundle-id net.kovidgoyal.kitty \
        --format '%{window-id}|%{app-pid}|%{workspace}|%{window-title}' \
        | awk -F'|' '$4 == "yazi-popup" {print}') \
        || { print -u2 'Cannot query AeroSpace windows.'; exit 1; }
    if [[ "$rows" == *$'\n'* ]]; then
        print -u2 'Multiple Yazi popups found; close the duplicate.'
        exit 1
    fi
    IFS='|' read -r window_id kitty_pid window_workspace window_title <<< "$rows"
    [[ -n "$window_id" ]]
}

place() (
    # Serialize movement and centering so quitting cannot race with placement.
    zsystem flock -e -t 5 -i 0.02 "$cache/placement.lock"
    if [[ "$window_workspace" != "$1" ]]; then
        "$aero" move-node-to-workspace --window-id "$window_id" "$1"
    fi
    if [[ "$1" != "$parked" ]]; then
        "$aero" focus --window-id "$window_id"
        # Parking is temporary; remember the last visible monitor for this window.
        centered=''
        if [[ -r "$cache/centered" ]]; then
            centered=$(<"$cache/centered")
        fi
        if [[ "$centered" != "$window_id|$kitty_pid|$monitor_info" ]]; then
            /bin/bash "${script:h}/center-yazi.sh" "$window_id" "$kitty_pid" "$monitor"
            print -r -- "$window_id|$kitty_pid|$monitor_info" > "$cache/centered"
        fi
    fi
)

if [[ "${1:-}" == --session ]]; then
    zsystem flock -t 0 "$cache/session.lock"
    while true; do
        # A new ID on every restart avoids reusing a stale Yazi IPC identity.
        printf -v client_id '%.0f' "$(( EPOCHREALTIME * 1000000 ))"
        print -r -- "$PPID $client_id" > "$cache/client.next"
        mv "$cache/client.next" "$cache/client"
        /opt/homebrew/bin/yazi --client-id "$client_id" "$HOME"
        popup || exit 0
        [[ "$kitty_pid" == "$PPID" ]] || exit 1
        place "$parked"
    done
fi

# Repeated shortcut presses cannot launch duplicate windows.
zsystem flock -t 0 "$cache/toggle.lock" || exit 0
workspace=$("$aero" list-workspaces --focused)
[[ "$workspace" != "$parked" ]] || exit 0
monitor_info=$("$aero" list-monitors --focused --format '%{monitor-appkit-nsscreen-screens-id}|%{monitor-name}')
monitor=${monitor_info%%|*}

if ! popup; then
    rm -f "$cache/centered"
    /opt/homebrew/bin/kitty --title yazi-popup -e /bin/zsh "$script" --session \
        >>"$cache/kitty.log" 2>&1 &!
    for attempt in {1..100}; do
        popup && break
        sleep 0.05
    done
    [[ -n "$window_id" ]] || { print -u2 'Kitty popup did not appear.'; exit 1; }
else
    # AeroSpace returns exit 1 when the current workspace has no focused window.
    focused=$("$aero" list-windows --focused --format '%{window-id}' 2>/dev/null) || focused=''
    if [[ "$window_workspace" != "$parked" ]]; then
        read -r owner old_client < "$cache/client"
        [[ "$owner" == "$kitty_pid" ]] || { print -u2 'Stale popup session.'; exit 1; }
        /opt/homebrew/bin/ya emit-to "$old_client" quit
        for attempt in {1..100}; do
            read -r owner client_id < "$cache/client"
            [[ "$owner" == "$kitty_pid" && "$client_id" != "$old_client" ]] && break
            sleep 0.05
        done
        if [[ "$client_id" == "$old_client" ]]; then
            print -u2 'Yazi did not quit; check the popup for a task confirmation.'
            exit 1
        fi
        window_workspace=$parked
        if [[ "$focused" == "$window_id" ]]; then
            exit 0
        fi
    fi
fi

place "$workspace"
