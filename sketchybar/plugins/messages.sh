source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

TEXT=$(sqlite3 ~/Library/Messages/chat.db "SELECT COUNT(guid) FROM message WHERE NOT(is_read) AND NOT(is_from_me) AND text !=''")

if [ $TEXT = 0 ]; then
  ICON=$MESSAGE_NONE
  COLOR=$WHITE
else
  ICON=$MESSAGE_NEW
  COLOR=$BLUE
fi

sketchybar --set messages icon="$ICON" icon.color=$COLOR
