#!/bin/sh battery=( script="$PLUGIN_DIR/battery.sh" icon.font="$FONT:Regular:19.0" padding_right=3
#!/bin/bash

battery=(
  script="$PLUGIN_DIR/battery.sh"
  icon.font="$FONT:Regular:19.0"
  padding_right=5
  padding_left=0
  label.drawing=off
  update_freq=120
  updates=on
)

battery_indicator=(
  drawing=off
  height=10
  width=10
  corner_radius=5
  padding_right=0
  padding_left=0
  margin_right=5
  margin_left=5
  color=$WHITE
)

sketchybar --add item battery right      \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
