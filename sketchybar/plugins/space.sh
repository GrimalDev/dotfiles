#!/bin/bash

update() {
  if [ "$SENDER" = "space_change" ]; then
    source "$CONFIG_DIR/colors.sh"
    COLOR=$BACKGROUND_2
    if [ "$SELECTED" = "true" ]; then
      COLOR=$GREY
    fi
    # sketchybar --set $NAME icon.highlight=$SELECTED \
    #                        label.highlight=$SELECTED \
    #                        background.border_color=$COLOR

    sketchybar --set space.$(aerospace list-workspaces --focused) icon.highlight=true \
                      label.highlight=true \
                      background.border_color=$GREY
  fi
}

set_space_label() {
  sketchybar --set $NAME icon="$@"
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    # yabai -m space --destroy $SID
    echo ''
  else
    if [ "$MODIFIER" = "shift" ]; then
      if [ $? -eq 0 ]; then
        set_space_label "${NAME:6}"
      fi
    else
      #yabai -m space --focus $SID 2>/dev/null
      aerospace workspace ${NAME#*.}
    fi
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
