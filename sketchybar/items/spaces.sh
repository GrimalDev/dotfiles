#!/bin/sh

sketchybar --add event aerospace_workspace_change

for m in $(aerospace list-monitors | awk '{print $1}'); do
  for i in $(aerospace list-workspaces --monitor $m); do
    sid=$i
    space=(
      space="$sid"
      icon="$sid"
      icon.highlight_color=$RED
      icon.padding_left=10
      icon.padding_right=0
      display=$m
      padding_left=2
      padding_right=2
      label.padding_right=20
      label.color=$GREY
      label.highlight_color=$WHITE
      label.font="sketchybar-app-font:Regular:12.0"
      label.y_offset=-1
      background.color=$BACKGROUND_1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left \
               --set space.$sid "${space[@]}" \
               --subscribe space.$sid mouse.clicked
  done

done

sketchybar  --add item space_windows left \
            --set space_windows script="$PLUGIN_DIR/space_windows.sh" \
            --subscribe space_windows aerospace_workspace_change
