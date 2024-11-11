#!/bin/bash

app="$1"
title="$2"
options="$3"
mode="$4"

title_search=""
if [ -n "$title" ]; then
    title_search=" | select(.\"window-title\" == \"$title\")"
fi
# if app with title of $2 is not running, start it
is_running=$(aerospace list-windows --all --json | jq -r '.[] | select(."app-name" == "'"$app"'")'"$title_search")

if [ -z "$is_running" ]; then
# If cli mode param provided (3rd param to cli string)
  if [ "$mode" = "cli" ]; then
    echo "Starting $app with cli mode"
      /bin/bash -c "$app $options &"
  else
    echo "starting $app"
    open -a "$app"
  fi
fi
