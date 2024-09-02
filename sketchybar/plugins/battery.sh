#!/bin/bash

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

DRAWING=on
COLOR=$WHITE
case ${PERCENTAGE} in
  9[0-9]|100) ICON=$BATTERY_100; COLOR=$GREEN
  ;;
  [6-8][0-9]) ICON=$BATTERY_75;
  ;;
  [3-5][0-9]) ICON=$BATTERY_50
  ;;
  [1-2][0-9]) ICON=$BATTERY_25; COLOR=$ORANGE
  ;;
  *) ICON=$BATTERY_0; COLOR=$RED
esac

if [[ $CHARGING != "" ]]; then
  ICON=$BATTERY_CHARGING
fi

sketchybar --set $NAME drawing=$DRAWING icon="$ICON" icon.color=$COLOR

mouse_entered() {
  sketchybar --set $NAME battery.indicator.drawing=on
}

mouse_exited() {
  sketchybar --set $NAME battery.indicator.drawing=off
}

case "$SENDER" in
  "mouse.entered") mouse_entered
  ;;
  "mouse.exited") mouse_exited
  ;;
esac
