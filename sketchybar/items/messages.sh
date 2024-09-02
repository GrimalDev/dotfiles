# sketchybar --add item messages right       \
#            --set messages  \
#                 icon.drawing=off \
# 	            update_freq=10 \
#                 background.color=$transparent_color \
#                 background.padding_left=3 \
#                 background.padding_right=5 \
#                 script="~/.config/sketchybar/plugins/messages.sh" \
#                 click_script="open -a /System/Applications/Messages.app"
#
# sketchybar \
# 	--add item messages_logo right \
# 	--set messages_logo icon=􀌤  \
#         icon.color=$current_app_color \
#         label.drawing=off \
#         background.color=$time_highlight \
source "$HOME/.config/sketchybar/icons.sh"

messages=(
  icon=$MESSAGE_NONE
  script="$PLUGIN_DIR/messages.sh"
  click_script="open -a /System/Applications/Messages.app"
  update_freq=10
)

sketchybar --add item messages right \
           --set messages "${messages[@]}"
